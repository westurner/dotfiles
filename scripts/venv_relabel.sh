#!/bin/sh

### venv_relabel.sh -- set virtualenv/venv fcontexts [semanage, restorecon]

function _setlabels {
    (set -x;
    _path="${1}"   # ${VIRTUAL_ENV}/tmp
    _equalpth="${2}"  # /tmp
    _deleteexisting="${3:-${_VENV_RELABEL_DELETE_EXISTING}}"
    if [ -n "${_deleteexisting}" ]; then
        sudo semanage fcontext -D "${_path}";
    fi
    sudo semanage fcontext --modify -e "${_equalpth}" "${_path}";
    sudo restorecon -Rv "${_path}";
    ls -alZd "${_path}") 
}

function venv_relabel {

    prefix="${1}"
    if [ "${prefix}" == "" ]; then
        echo "err"
    fi
    export _VENV_RELABEL_DELETE_EXISTING="${2:-"${_VENV_RELABEL_DELETE_EXISTING:-"true"}"}"
    _setlabels "${prefix}/bin"     "/usr/bin"
    _setlabels "${prefix}/etc"     "/usr/etc"
    _setlabels "${prefix}/include" "/usr/include"
    _setlabels "${prefix}/lib"     "/usr/lib"
    _setlabels "${prefix}/lib64"   "/usr/lib"
    _setlabels "${prefix}/man"     "/usr/man"
    _setlabels "${prefix}/share"   "/usr/share"
    _setlabels "${prefix}/tmp"     "/usr/tmp"
    _setlabels "${prefix}/var/cache" "/var/cache"
    _setlabels "${prefix}/var/log" "/var/log"
    _setlabels "${prefix}/var/run" "/var/run"
    _setlabels "${prefix}/var/www" "/var/www"

    ls -alZ "${prefix}"
}

function venv_relabel_main {
    venv_relabel "${1}"
}

venv_relabel_main "${1}"
