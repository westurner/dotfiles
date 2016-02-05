#!/usr/bin/env bash
## diff-stdin.sh

function diff_stdin () {
    (set -x; _diff_stdin ${@}; return)
    return
}

function _diff_stdin () {
    #  diff-stdin()      -- diff the output of commands $1 and $2
    DIFFBIN='diff'
    $DIFFBIN -u <($1) <($2)
    return
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    diff_stdin ${@}
    exit
fi
