#!/usr/bin/env bash
### modprobe-l.sh ## modprobe -l/--list is gone.

# References:
# - http://forums.fedoraforum.org/showthread.php?t=283145

function modprobe_l {
    ## main()     ## print kernel modules for ${1:-"/lib/modules/`uname -r`"}
    echo '${@}: '"${@}" >&2
    local do_relative_path=
    local do_sort=
    for arg in ${@}; do
        case "${arg}" in
            --rel)
                do_relative_path="${arg}" ;
                shift
                ;;
            --sort)
                do_sort="${arg}"
                shift
                ;;
        esac
    done

    local modulesdir="${1:-"/lib/modules/$(uname -r)"}"
    local sortcmd="cat"

    if [ -n "${do_sort}" ]; then
        sortcmd="sort -n"
    fi

    if [ "${do_relative_path}" ]; then
        (cd "${modulesdir}" ; \
            find . -type f -printf '%f'$'\t''%p\n' \
            | ${sortcmd} )
    else
        find "${modulesdir}/kernel" -type f -printf '%f'$'\t''%p\n' \
            | ${sortcmd}
    fi
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    (set -x; modprobe_l "${@}")
fi
