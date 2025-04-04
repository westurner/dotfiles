#!/bin/sh


__THIS=$0

genshelltests_with_vim() {
    source_script="scripts/usrlog.sh"
    test_script="${source_script}_test.sh"
    #| grep '\(\)\s*{\s*$'
    vim -c '%!cat '"${source_script}"' | grep ^function .* {|\(\)\s*{\s*$' \
        -c '%s:^function :function test_:g' \
        -c '%s:{:{\r    (set -x; echo NotImplemented); return 2;\r}\r\r:g'
}

genshelltests_list_functions() {
    ${1?"You must specify a filename"}
    grep -E '^\s*function .* {|\(\)\s*{\s*$' "${1}"
}


function genshelltests_print_usage {
    echo "Usage: ${__THIS} [-h][-v] [--test] --src <script.sh>"
    echo ""
    echo "Generate test_{fn} functions for all functions in a shell script"
    echo ""
    echo " --list <scrpt.sh>   List functions in a shell script"
    echo ' --src <script.sh>   Generate test_${func} functions for this file'
    echo ""
    echo " -h / --help         Print this help"
    echo " -v / --verbose      Be verbose with set +x"
    echo " --test              Run tests"
    echo ""
}

function _requires_src {
    src=$1;
    msg=$2
    if [ -z "${src}" ]; then
        echo "" >&2
        echo "ERROR: You must specify a filename ${msg}" >&2
        echo "" >&2
        genshelltests_print_usage
        return 1
    fi
}

function genshelltests_main {
    if [ $# -eq 0 ]; then
        genshelltests_print_usage
        return 1
    fi
    for arg in "${@}"; do
        case "${arg}" in
            -h|--help) genshelltests_print_usage;;
            -v|--verbose) set -x ;;
        esac
    done
    for arg in "${@}"; do
        case "${arg}" in
            --test) genshelltests_test_main;;
            --list)
                _requires_src "${2}" "to --list functions from" || return
                src="${2}"
                genshelltests_list_functions "${src}"
                ;;
            --src)
                _requires_src "${2}" "to generate test functions from" || return
                src="${2}"
                genshelltests_with_vim "${src}";
        esac
    done
}

genshelltests_test_main() {
    set -x
    src="${1:-"${__THIS}"}"
    genshelltests_list_functions "${src}"
    genshelltests_with_vim "${src}"
}

genshelltests_main "${@}"
