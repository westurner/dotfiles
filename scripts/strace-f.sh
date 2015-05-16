#!/bin/sh
## strace-f.sh

#HERE="${__DOTFILES}/scripts"
HERE=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${HERE}/strace-.sh

function strace_f () {
    (set -x; _strace_f ${@}; return)
    return
}

source ${HERE}/strace-.sh
function _strace_f () {
    # strace-f()        -- strace -e trace=file + helpful options
    _strace_ -e trace=file $@
}

if [ "${BASH_SOURCE}" == "${0}" ]; then
    strace_f ${@}
fi
