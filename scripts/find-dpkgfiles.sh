#!/bin/sh
## find-dpkgfiles.sh

function find_dpkgfiles() {
    (set -x; _find_dpkgfiles ${@}; return)
    return
}
function _find_dpkgfiles() {
    # find-dpkgfiles()  -- sort dpkg /var/lib/dpkg/info/<name>.list
    cat /var/lib/dpkg/info/${1}.list | sort
    return
}

if [ "${BASH_SOURCE}" == "${0}" ]; then
    find_dpkgfiles ${@}
    exit
fi
