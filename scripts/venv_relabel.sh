#!/bin/bash

### venv_relabel.sh -- set virtualenv/venv fcontexts [semanage, restorecon]

function _venv_relabel_main_help {
    #  _venv_relabel_main_help -- print help
    echo "${progname} <prefix> [deleteexisting]"
    echo '    $1 (str): path prefix {eg $VIRTUAL_ENV, $WORKON_HOME/venvname}'
    echo '    $2 (str): $_=$2:-$_VENV_RELABEL_DELETE_EXISTING:-"true"'
    echo '      - (default: true) -- do run     `semanage fcontext -D $1`'
    echo '                destructively remove existing labels first'
    echo '      - {"",false,f)    -- dont run    semanage fcontext -D $1'
    echo '      - _setlabels references this variable'
    echo ''
    echo '    Note: by default this runs::'
    echo ''
    echo '      semanage fcontext -D "${_path}"  # if $2=="true"'
    echo '      semanage fcontext --modify -e "${_equalpth}" "${_path}" '
    echo '      restorecon -Rv "${_path}"'
    echo ''
    echo ' Usage:'
    echo ''
    echo "    ${progname} '~/.virtualenvs/venvname'"
    echo "    ${progname}"' "${WORKON_HOME}/venvname"'
    echo "    ${progname} '/chroot"
    echo "    ${progname} '/container/venv"
}

function venv_relabel_main {
    declare -a args
    EXPORT _VENV_SHOW_DIFF="true"
    for arg in "${@}"; do
        case $arg in
            -h|--help)
                (set +x +v; _venv_relabel_main_help)
                exit
                ;;
            -v|--verbose)
                set -x -v
                ;;
            -q|--quiet)
                set +x +v
                ;;
            --no-delete)
                deleteexisting=""
                _VENV_RELABEL_DELETE_EXISTING=
                ;;
            --no-diff)
                _VENV_SHOW_DIFF=;
                ;;
            *)
                args+=("${arg}")
        esac
    done
    export _VENV_SHOW_DIFF
    export _VENV_RELABEL_DELETE_EXISTING

    local prefix="${args[0]}"
    local deleteexisting="${args[1]:-"true"}"
    # if [ "${prefix}" == "/" ]; then
    #     prefix=""
    # fi
    venv_relabel "${prefix}" "${deleteexisting}"
    return
}


function _venv_delete_and_relabel {
    #  _venv_delete_and_relabel -- relabel selinux file contexts of _path
    #    $1 (str): _path:       # eg: ${VIRTUAL_ENV}/tmp
    #    $2 (str): _equalpath   # eg: /tmp
    #    $3 (str): _deleteexisting (default: _VENV_RELABEL_DELETE_EXISTING)
    (set -x;
    _path="${1}"
    _equalpth="${2}"  # /tmp
    _deleteexisting="${3:-${_VENV_RELABEL_DELETE_EXISTING}}"
    if [ -z "${_path}" ] || [ -z "${_equalpth}" ]; then
        echo "ERROR: _path and _equalpath must be set" >&2
        exit 2
    fi
    if [ -n "${_deleteexisting}" ]; then
        sudo semanage fcontext -D "${_path}";
    fi
    sudo semanage fcontext --modify -e "${_equalpth}" "${_path}";
    sudo restorecon -Rv "${_path}";
    ls -alZd "${_path}")
    return
}

function venv_relabel {
    #  venv_relabel -- relabel the ve fs like this system's policy
    #    $1 (str): path prefix (eg $VIRTUAL_ENV or $WORKON_HOME/venvname)
    #    $2 (str): sets _ := $2:-_VENV_RELABEL_DELETE_EXISTING:-"true"
    #
    #    .. note:: this is destructive of any existing labels::
    #
    #       if _VENV_RELABEL_DELETE_EXISTING != "" (default: "true")
    #
    #    .. note::
    #
    #       if [ "${prefix}" == "/" ]; then
    #           prefix=""
    #       fi
    local prefix="${1}"
    if [ "${prefix}" == "" ]; then
        echo "ERROR: prefix must be specified" >&2
        _venv_relabel_main_help
        return -1
    fi
    export _VENV_RELABEL_DELETE_EXISTING="${2:-"${_VENV_RELABEL_DELETE_EXISTING:-"true"}"}"
    declare -a paths
    declare -a paths12
    function _setlabels {
        paths+=("${1}")
        paths12+=("${1} ______ ${2}")
        # _venv_delete_and_relabel "${@}"
    }
    _setlabels "${prefix}/bin"     "/usr/bin"
    _setlabels "${prefix}/etc"     "/usr/etc"
    _setlabels "${prefix}/include" "/usr/include"
    _setlabels "${prefix}/lib64"   "/usr/lib"
    _setlabels "${prefix}/lib"     "/usr/lib"
    _setlabels "${prefix}/man"     "/usr/man"
    _setlabels "${prefix}/share"   "/usr/share"
    _setlabels "${prefix}/share"   "/usr/share"
    #_setlabels "${prefix}/src"    "/usr/local/src"  # usr_t
    _setlabels "${prefix}/tmp"     "/usr/tmp"
    _setlabels "${prefix}/usr"     "/usr"
    if [ -n "${_VENV_SHOW_USRLOCAL}" ]; then
        paths+=("${prefix}/usr/local")
        paths+=("${prefix}/usr/local/bin")
        paths+=("${prefix}/usr/local/etc")
        paths+=("${prefix}/usr/local/include")
        paths+=("${prefix}/usr/local/lib")
        paths+=("${prefix}/usr/local/lib64")
        paths+=("${prefix}/usr/local/libexec")
        paths+=("${prefix}/usr/local/sbin")
        paths+=("${prefix}/usr/local/share")
        paths+=("${prefix}/usr/local/src")
        paths+=("${prefix}/usr/share")
    fi
    _setlabels "${prefix}/var/cache" "/var/cache"
    _setlabels "${prefix}/var/log" "/var/log"
    _setlabels "${prefix}/var/run" "/var/run"
    _setlabels "${prefix}/var/www" "/var/www"

    function ls_paths {
        ( ls -d "${prefix}/"* ; printf "%s\n" "${paths[@]}" ) | sort -u | grep -v '^$'
    }
    readarray -t _ls_paths < <(ls_paths)
    if [ -n "${_VENV_SHOW_DIFF}" ]; then
        readarray -t before < <(ls -aldZ "${_ls_paths[@]}" | tee)
    fi
    local -n returncode=0
    for rowstr in "${paths12[@]}"; do
        local row=(${rowstr// ______ / })
        _venv_delete_and_relabel "${row[@]}"
        returncode+=$?
    done
    if [ -n "${_VENV_SHOW_DIFF}" ]; then
        readarray -t after < <(ls -aldZ "${_ls_paths[@]}" | tee)
        diff -Nau <(printf '%s\n' "${before[@]}") <(printf '%s\n' "${after[@]}")
    fi
    return $returncode
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    declare -r progname="$(basename ${BASH_SOURCE})"
    venv_relabel_main "${@}"
    exit
fi
