#!/usr/bin/env bash
### modprobe-l.sh ## list kernel modules for the current or specified kernel

# References:
# - http://forums.fedoraforum.org/showthread.php?t=283145
#
#   * module-init-tools' modprobe supports a -l/--list option
#   * kmod's modprobe does not support a -l/--list option


function modprobe_l_help {
    local progname="${0}"
    echo "${progname} -- list kernel modules for the current or specified kernel"
    echo '  -h/--help   -- print this help text'
    echo '  --rel       -- print paths relative to /lib/modules/`uname-r` or $1'
    echo '  --path      -- print absolute file paths (default)'
    echo '  --basename  -- [also] print the module basename'
    echo '  --bf/--basename-first  -- print the basename first'
    echo '  --sort      -- apply `| sort -n`'
    echo '  --info      -- apply `| xargs modinfo`'
}

function modprobe_l {
    ## main()     ## print kernel modules for ${1:-"/lib/modules/`uname -r`"}
    echo '${@}: '"${@}" >&2
    local do_print_basename=
    local do_print_basename_first=
    local do_print_path=
    local do_relative_path=
    local do_sort=
    local do_info=
    for arg in ${@}; do
        case "${arg}" in
            -h|--help)
                do_help="${arg}" ;
                shift
                ;;
            --rel)
                do_relative_path="${arg}" ;
                shift
                ;;
            --path)
                do_print_path="${arg}" ;
                shift
                ;;
            --basename)
                do_print_basename="${arg}" ;
                shift
                ;;
            --basename-first|--bf)
                do_print_basename="${arg}" ;
                do_print_basename_first="${arg}" ;
                shift
                ;;
            --sort)
                do_sort="${arg}" ;
                shift
                ;;
            --info)
                do_info="${arg}" ;
                shift
                ;;
        esac
    done

    local modulesdir="${1:-"/lib/modules/$(uname -r)"}"

    local sortcmd="cat"
    if [ -n "${do_sort}" ]; then
        sortcmd="sort -n"
    fi

    local infocmd="cat"
    if [ -n "${do_info}" ]; then
        infocmd="xargs modinfo"
    fi

    local findprintfstr='%p\n'
    if [ -n "${do_print_basename}" ]; then
        if [ -n "${do_print_basename_first}" ]; then
            if [ -n "${do_print_path}" ]; then
                findprintfstr='%f'$'\t''%p\n'
            else
                findprintfstr='%f\n'
            fi
        else
            if [ -n "${do_print_path}" ]; then
                findprintfstr='%p'$'\t''%f\n'
            else
                findprintfstr='%f\n'
            fi

        fi
    fi

    if [ -n "${do_help}" ]; then
        (set +x +v; modprobe_l_help)
        exit
    fi

    if [ -n "${do_relative_path}" ]; then
        (cd "${modulesdir}" ; \
            find . -type f -name '*.ko*' \
            -printf "${findprintfstr}" \
            | ${sortcmd} \
            | ${infocmd} )
    else
        find "${modulesdir}/" -type f -name '*.ko*' \
            -printf "${findprintfstr}" \
            | ${sortcmd} \
            | ${infocmd}
    fi
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    (set -x; modprobe_l "${@}")
fi
