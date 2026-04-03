#!/bin/sh




#_printvar_b() {
#    #printf "+%s=%s" $1 $(eval $1)
#    #declare -p "${1}"
#    declare -p "${1}" | sed 's/declare -- //'
#}

#_printvar_c() {
#    # Check if the variable is set before creating a reference
#    if [[ ! -v "$1" ]]; then
#        echo "Error: variable '$1' is not set." >&2
#        return 1
#    fi
#
#    # Create a nameref (a direct pointer) to the variable named in $1.
#    # This is extremely fast.
#    declare -n ref="$1"
#
#    # Use the printf builtin with %q to safely format the output.
#    # Note that `printf "%q"` does not format e.g. arrays
#    # such that they can be pasted into a shell
#    printf "%s=%q\n" "$1" "$ref"
#}

_printvar() {
    # Capture the output of `declare -p`.
    # Redirect stderr to handle unset variables.
    local definition=$(declare -p "$1" 2>/dev/null) || {
        echo "Error: variable '$1' is not set." >&2
            return 1
    }
    # Use parameter expansion to remove the "declare -<options> " prefix.
    # This is a built-in string operation and much faster than sed.
    echo "${definition#declare * }"
}

drivesizes() {

    #set -x
    #set -e
    drivesize="${1}";
    if [ -z "$drivesize" ]; then
        echo 'ERROR: $1 drivesize must be specified' >&2
        return 2
    fi
    drivesize_bytes_iec="$(numfmt --from=iec "$drivesize")"
    drivesize_bytes__si="$(numfmt --from=si "${drivesize}")"
    absolute_difference_between_si_and_iec_bytes=$(expr "$drivesize_bytes_iec" - "${drivesize_bytes__si}")
    absolute_difference_between_si_and_iec_bytes_si_units=$(numfmt --to si "${absolute_difference_between_si_and_iec_bytes}")
    #percent_difference_between_iec_and_si=$(expr "${absolute_difference_between_si_and_iec_bytes}"  / "$drivesize_bytes__si")
    #percent_difference_between_iec_and_si=$(expr \( "$drivesize_bytes_iec" - "${drivesize_bytes__si}" \) / "$drivesize_bytes__si")

    _printvar "drivesize"
    _printvar "drivesize_bytes_iec"
    _printvar "drivesize_bytes__si"
    _printvar "absolute_difference_between_si_and_iec_bytes"
    _printvar "absolute_difference_between_si_and_iec_bytes_si_units"
    _printvar "percent_difference_between_iec_and_si"
}

this=$(basename "${0}")
drivesize_print_usage() {
    echo "${this} [-h][-v] [-l] <sizestr>"
    echo ""
    echo '  <sizestr>   `numfmt -h`-style string: 1M, 1G, 1T'
    echo "  -l, --list-common-sizes"
    echo ""
    echo "## Usage:"
    echo "${this} -l"
    echo "${this} 1T"
    echo "${this} 4T"
}

drivesize_list_common_sizes() {
    if [ -n "${*}" ]; then
        echo '$@='"${@}"
        for size in "${@}"; do
            echo '--'
            drivesizes "${size}"
        done
    else
        sizes=( "1G" "1T" "4T" )
        for size in "${sizes[@]}"; do
            echo '--'
            drivesizes "${size}"
        done
    fi
}

_setup_ps4() {
    if [ -n "${_ORIG_PS4}" ]; then
        export _ORIG_PS4=$PS4
    fi
    case "$1" in
        off)
            export PS4=$_ORIG_PS4
            ;;
        on)
            export PS4='\e[0;30m#'$'\t''${BASH_SOURCE:+${BASH_SOURCE##*/}}:${LINENO}$'\t' ${FUNCNAME[0]:+"${FUNCNAME[0]}():"}\e[m  \n+';
            ;;
        other)
            export PS4='#+\e[0;30m${BASH_SOURCE:+${BASH_SOURCE##*/}}:${LINENO}\e[m$'\t' \e[0;32m${FUNCNAME[0]:+"${FUNCNAME[0]}():"}\e[m  \n+';
            ;;
        *)
            echo "Error: unknown option" >&2
            return 2
            ;;
    esac
    return 0
}

_test_all() {
    echo "INFO: Running tests..."

    _printvar "SHELL"
    _printvar

    drivesize_list_common_sizes # || true  # TODO: assertFails
    drivesize_list_common_sizes "1G"
    drivesize_list_common_sizes "1G" "1T"

    drivesizes || true  # TODO: assertFails
    drivesizes 1T
    drivesizes 4T

    drivesize_print_usage

    drivesize_main
    drivesize_main -h
    drivesize_main --help
    drivesize_main -v || true  # TODO: assertFails

    drivesize_main 1000G
    drivesize_main 1T

    drivesize_main -l

    echo "INFO: Running tests... done"
}


test_all() {
    (set -x -e; _test_all)
}

drivesize_main() {
    if [ -z "${*}" ]; then
        drivesize_print_usage
        return 0
    fi
    export _OPT_VERBOSE=
    for arg in "${@}"; do
        case "${arg}" in
            -h|--help)
                drivesize_print_usage
                return 0
                ;;
            -v|--verbose)
                shift
                export _OPT_VERBOSE=1
                set -x -v
                _setup_ps4 on
                ;;
        esac
    done
    for arg in "${@}"; do
        case "${arg}" in
            -l|--list-common-sizes)
                shift
                drivesize_list_common_sizes "${@}"
                return 0
                ;;
            --test)
                shift
                if [ -n "${_OPT_VERBOSE}" ]; then
                    return 3
                    _setup_ps4 on # pass -v/--verbose; -v --test
                fi
                test_all
                return $?
                ;;
        esac
    done
    drivesizes "$1"
}

if [ -z "${SKIP_MAIN}" ]; then
    drivesize_main "${@}"
fi
