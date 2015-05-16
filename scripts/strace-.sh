#!/bin/sh
## strace-.sh

function _strace_ () {
    strace -ttt -f -F $@ 2>&1
    return
}

function strace_ () {
    (set -x; _strace_ ${@}; return)
    return
}

if [ "${BASH_SOURCE}" == "${0}" ]; then
    strace_ ${@}
    exit
fi
