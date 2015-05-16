#!/bin/bash
## diff-dirs.sh

function diff_dirs () {
    (set -x; _diff_dirs ${@}; return)
    return
}

function _diff_dirs () {
    #  diff-dirs()       -- list differences between find $1 and find $2
    #   $1 (str)   -- path to directory prefix 1
    #   $2 (str)   -- path to directory prefix 2
    #   $3 (str)   -- add'l args for 'find'
    #                   (default: "-printf '%T@\t%s\t%u\t%Y\t%p\n'")
    F1=$1
    F2=$2
    _FIND_OPTS=${3}
    if [ -z "${_FIND_OPTS}" ]; then
        if [ -n "${__IS_MAC}" ]; then
            echo "Err: __IS_MAC=true (running without 'find -printf')"
        else
            _FIND_OPTS="-printf '%T@\t%s\t%u\t%Y\t%p\n'"
        fi
    fi
    diff -Nau \
        <(cd $F1; find . ${_FIND_OPTS} | sort) \
        <(cd $F2; find . ${_FIND_OPTS} | sort)
    return
}

if [ "${BASH_SOURCE}" == "${0}" ]; then
    diff_dirs ${@}
    exit
fi
