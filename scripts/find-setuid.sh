#!/bin/sh
## find-setuid.sh

function find_setuid() {
    (set -x; _find_setuid $@; return)
    return
}

function _find_setuid () {
    # find-setuid()     -- find all setuid and setgid files
    #                      stderr > find-setuid.errors
    #                      stdout > find-setuid.files
    sudo \
        find /  -type f \( -perm -4000 -o -perm -2000 \) -exec ls -ld '{}' \; \
        2> find-setuid.errors \
        > find-setuid.files
    return
}

if [ "${BASH_SOURCE}" == "${0}" ]; then
    find_setuid ${@}
    exit
fi
