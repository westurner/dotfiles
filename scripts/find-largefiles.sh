#!/bin/sh
## find-largefiles.sh

function find_largefiles () {
    (set -x; _find_largefiles ${@}; return)
    return
}

function _find_largefiles () {
    # find-largefiles() -- find files larger than size (default: +10M)
    SIZE=${1:-"+10M"}
    find . -xdev -type f -size "${SIZE}" -exec ls -al {} \;
    return
}

if [ "${BASH_SOURCE}" == "${0}" ]; then
    find_largefiles ${@}
    exit
fi
