#!/bin/sh
## mnt-cifs.sh

function mnt_cifs() {
    (set -x; _mnt_cifs ${@}; return)
    return
}

function _mnt_cifs() {
    #  mnt_cifs()        -- mount a CIFS mount
    URI="$1" # //host/share
    MNTPT="$2"
    OPTIONS="-o user=$3,password=$4"
    mount -t cifs $OPTIONS $URI $MNTPT
    return
}
if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    mnt_cifs ${@}
    exit
fi
