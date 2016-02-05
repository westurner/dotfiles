#!/bin/sh
## find-lately.sh

function find_lately () {
    (set -x; _find_lately $@; return)
    return
}

function _find_lately () {
    # find-lately()     -- list and sort files in paths $@ by ISO8601 mtime
    #                      stderr > lately.$(date).errors
    #                      stdout > lately.$(date).files
    #                      stdout > lately.$(date).sorted
    paths=${@:-"/"}
    lately="lately.$(date +'%FT%T%z')"
    (find $paths -exec \
        stat -f '%Sc%t%N%t%z%t%Su%t%Sg%t%Sp%t%T' -t '%F %T%z' {} \; \
        2> ${lately}.errors \
        > ${lately}.files)
    sort "${lately}.files" > "${lately}.sorted"
    return
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    find_lately $@
    exit
fi
