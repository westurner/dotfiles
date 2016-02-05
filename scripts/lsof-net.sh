#!/bin/sh
## lsof-net.sh

function lsof_net() {
    (set -x; _lsof_net ${@}; return)
    return
}

function _lsof_net () {
    #  lsof_net()        -- lsof the network things
    ARGS=${@:-''}
    for pid in `lsof -n -t -U -i4 2>/dev/null`; do
        echo "-----------";
        ps $pid;
        lsof -n -a $ARGS -p $pid 2>/dev/null;
    done
    return
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    lsof_net ${@}
    exit
fi
