#!/bin/sh
## mnt-davfs.sh

function mnt_davfs() {
    (set -x; _mnt_davfs ${@}; return)
    return
}

function _mnt_davfs() {
    #  mnt_davfs()       -- mount a WebDAV mount
    URL="$1"
    MNTPT="$2"
    OPTIONS="-o rw,user,noauto"
    mount -t davfs $OPTIONS $URL $MNTPT
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    mnt_davfs ${@}
    exit
fi
