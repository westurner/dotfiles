#!/bin/sh
## lsof.sh

#__THIS=$(readlink -e "$0")

function lsof_sh() {
    (s_et -x; _lsof_sh "${@}"; return)
    return
}


function _lsof_sh_help {
    printf "${__THIS} [-h] [-p <pid>]\n"
    printf ' -p <pid>      _lsof_sh_pid "$pid"\n'
    printf ' -a            _lsof_sh (default if -p is not specified)\n'
    printf " -h / --help   Print help\n"
}

function _shell_escape_single {
    # _shell_escape_single()    -- "'" + sed "s,','\"'\"',g" + "'"
    echo "'""${1//\'/\'\"\'\"\'}""'"
}

function _lsof_sh_pid {
    p="/proc/${1#/proc/}"
    if ! [ -e "${p}" ]; then
        echo "ERROR: '${p}' does not exist"
        return 1
    fi
    if ! [ -r "${p}/maps" ]; then
        echo "ERROR: '${p}/maps' is not readable (Permission denied)"
        return 2
    fi

    cmdline=$(tr '\0' ' ' < "$p/cmdline")
    cmd=$(echo "$cmdline" | sed 's/\(.*\)\s.*/\1/g' | sed 's/\//\\\//g')
    echo "## $p :  cmdline=$cmdline"
    sed_pattern="s/\(.*\)/$pid \1\t\$\$\t$cmd/g"
    cat "$p/maps" 2>&1 | sed "$sed_pattern" | awk '{ print "'"${p#/proc/}\t${p}/maps\t"'"$0 }'
}

function _lsof_sh_ls_proc {
    find /proc -regextype egrep -maxdepth 1 -type d -regex '.*[[:digit:]]+' -print0 ! -readable -prune
}

function _lsof_sh {
    #  lsof_sh()         -- something like lsof (from /proc)
    _lsof_sh_ls_proc | while read -d $'\0' p
    do
        _lsof_sh_pid "${p#/proc/}"
    done
    #~ lsof_ | grep 'fb' | pycut -f 6,5,0,2,1,7 -O '%s' | sort -n 
    return
}

function _lsof_sh_main {
    args="${@}"
    if [ -z "${args}" ]; then
        _lsof_sh_help
        return 0
    fi

    for arg in "${@}"; do
        case "${arg}" in
            -h|--help)
                _lsof_sh_help
                return 0
                ;;
        esac
    done

    pids=""
    for arg in "${@}"; do
        case "${arg}" in
            -p|pid)
                shift;
                _pid="${1#/proc/}"
                _lsof_sh_pid "${_pid}"
                pids="${pids} ${pid}"  # POSIX shell does not have associative arrays
                ;;
            -a)
                _lsof_sh "${@}"
                ;;
        esac
    done

    # if -p was not specified any times:
    if [ -z "${pids}" ]; then
        _lsof_sh "${@}"
        return
    fi
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    _lsof_sh_main "${@}"
    exit
fi
