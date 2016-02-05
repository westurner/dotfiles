#!/bin/sh
## find-dpkgfile.sh

function _find_dpkgfile () {
    (set -x; find_dpkgfile ${@}; return)
    return
}

function find_dpkgfile() {
    # find-dpkgfile()   -- search dpkgs with apt-file
    apt-file search $@
    return
}


if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    find_dpkgfile ${@}
    exit
fi
