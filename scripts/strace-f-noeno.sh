#!/bin/sh
## strace-f-noeno.sh

#HERE="${__DOTFILES}/scripts"
HERE=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${HERE}/strace-.sh

function strace_f_noeno () {
    (set -x; _strace_f_noeno ${@}; return)
    return
}

function _strace_f_noeno () {
    # strace-f-noeno()  -- strace -e trace=file | grep -v ENOENT
    _strace_ -e trace=file $@ 2>&1 \
        | grep -v '-1 ENOENT (No such file or directory)$' 
    return
}

if [ "${BASH_SOURCE}" == "${0}" ]; then
    strace_f_noeno ${@}
    exit
fi
