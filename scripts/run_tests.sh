#!/bin/bash
## run_tests.sh

# Usage: ./run_tests.sh [pytest_arguments]
#
# Parameters:
#   $@ (Any): Any standard pytest arguments and flags (e.g., test file paths,
#             -v for verbose, -k for matching test names). These are directly
#             passed through to the underlying pytest executable.

# Wrapper script to run pytest with timestamped output directories
# for tests, coverage reports, and xml results.
#
# Ensures a 'latest' symlink points to the most recent run
# for example:
#
# ```sh
# # reports/latest -> reports/1712233845-2026-04-02T08-30-45-0400
#
# $ ln -s reports/1712233845-2026-04-02T08-30-45-0400 reports/latest
# $ ls -al reports/latest
# drwxr-x---. 3 vscode vscode   4096 Apr  5 13:35 .
# drwxr-x---. 4 vscode vscode   4096 Apr  5 13:35 ..
# -rw-r-----. 1 vscode vscode 410899 Apr  5 13:35 cov.xml
# drwxr-x---. 2 vscode vscode   4096 Apr  5 13:35 htmlcov
# -rw-r-----. 1 vscode vscode  13901 Apr  5 13:35 pytest-results.xml
#
# - pytest-results.xml : JUnit XML test results
# - .coverage          : Raw coverage data
# - cov.xml            : XML coverage report
# - htmlcov/           : HTML coverage report directory
# ```
#
set -e -x

function _cleanup_after_pytest() {
    local exit_code="$1"
    local out_dir_name="$2"
    local out_dir_parent="$3"
    local epoch_val="$4"
    local ts_val="$5"
    local out_dir="$6"
    local db_path="$7"

    # Update latest symlink
    ln -sfn "${out_dir_name}" "${out_dir_parent}/latest"

    # Update sqlite replog
    if command -v sqlite-utils >/dev/null 2>&1; then
        # Escape backslashes and double quotes to ensure valid JSON output
        local safe_ts="${ts_val//\\/\\\\}"
        safe_ts="${safe_ts//\"/\\\"}"
        local safe_out_dir="${out_dir//\\/\\\\}"
        safe_out_dir="${safe_out_dir//\"/\\\"}"
        
        # Safely construct the JSON string using printf.
        # %d enforces integer formatting for epoch_val and exit_code.
        printf '{"epoch": %d, "timestamp": "%s", "out_dir": "%s", "exit_code": %d}\n' \
            "${epoch_val}" "${safe_ts}" "${safe_out_dir}" "${exit_code}" \
            | sqlite-utils insert "${db_path}" test_runs --alter -
    fi
    exit "${exit_code}"
}

function run_tests() {
    local out_dir="$1"
    shift

    echo "---> Creating report directory: $out_dir"
    mkdir -p "$out_dir"

    # Disable the conftest.py timestamp logic so they don't combat each other
    export SKIP_PYTEST_REPLOG=1

    # Set COVERAGE_FILE environment variable for pytest-cov
    export COVERAGE_FILE="$out_dir/.coverage"

    # Update latest symlink and sqlite replog after tests run (whether they succeed or fail)
    local out_dir_name
    out_dir_name=$(basename "$out_dir")
    local out_dir_parent
    out_dir_parent=$(dirname "$out_dir")

    local epoch_val="${out_dir_name%%-*}"
    local ts_val="${out_dir_name#*-}"
    local db_path="${PYTEST_REPLOG_DB:-reports/pytest_replog.db}"

    # We use a trap to ensure this runs regardless of pytest exit status.
    # Arguments are safely shell-quoted at definition time to prevent injection errors.
    local cleanup_args
    cleanup_args=$(printf "%q " "${out_dir_name}" "${out_dir_parent}" "${epoch_val}" "${ts_val}" "${out_dir}" "${db_path}")
    trap "_cleanup_after_pytest \$? ${cleanup_args}" EXIT

    # Run pytest passing along any user arguments.
    # The output paths configured here will override the static defaults in pyproject.toml
    #  --cov=src \
    pytest \
        --junitxml="${out_dir}/pytest-results.xml" \
        --cov-report="html:${out_dir}/htmlcov" \
        --cov-report="xml:${out_dir}/cov.xml" \
        --cov-report=term \
        "$@"
}


function show_report {
    local reportdir=$1

    find "${reportdir}/" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' file; do
        printf "\n===== %s ===\n" "${file}"
        cat "${file}"
        if [[ "${file}" == *.xml ]] ; then
            xmllint --format "${file}" 
            #python3 -c "import sys,xml.dom.minidom as m; print(sys.argv); file=sys.argv[1]; print(file); open(file,'r').read() and print(m.parse(file).toprettyxml())" "${file}"
        elif [[ "${file}" == *.json ]]; then
            jq "." "${file}"
            # python -m json.tool "${file}"
        elif [[ "$(basename "${file}")" == ".coverage" ]]; then
            ls -al "${file}"
            sha256sum "${file}"
        else
            printf "\n"
            ls -al "${file}"
        fi
        printf "\n=====\n"
    done
}

export REPORTS_DIR=${REPORTS_DIR:-"./reports"}
export REPORTS_DIR_LATEST="${REPORTS_DIR}/latest"

function run_tests_main() {
    # Generate a timestamp (e.g., 1712233845-2026-04-04T08-30-45-0400)
    local epoch
    epoch=$(date +%s)
    local timestamp_local
    timestamp_local=$(date +"%Y-%m-%dT%H-%M-%S%z")
    local reports_dir=$REPORTS_DIR
    local out_dir="${reports_dir}/${epoch}-${timestamp_local}"

    case "$1" in
        ls)
            shift
            set -x
            ls -al "$@" "${REPORTS_DIR}"/*
            ;;
        show|latest)
            shift
            local reportdir="${1:-"${REPORTS_DIR_LATEST}"}"
            show_report "${reportdir}"
            ;;
        symlink|ln)
            shift
            ls -ltr "${REPORTS_DIR}" | tail -n 4
            ls -ald "${REPORTS_DIR_LATEST}"
            ;;
        *)
            run_tests "${out_dir}" "$@"
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests_main "$@"
fi


