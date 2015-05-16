#!/bin/sh
## mnt-chroot-bind.sh

function mnt_chroot_bind() {
    (set -x; _mnt_chroot_bind ${@}; return)
    return
}

function _mnt_chroot_bind () {
    #  _mnt_chroot_bind() -- bind mount linux chroot directories
    DEST=$1
    #  /proc
    sudo mount proc -t proc ${DEST}/proc
    #  /dev
    sudo mount -o bind /dev ${DEST}/dev
    #  /sys
    sudo mount sysfs -t sysfs ${DEST}/sys
    #  /boot
    sudo mount -o bind,ro /boot ${DEST}/boot
    return
}

if [ "${BASH_SOURCE}" == "${0}" ]; then
    mnt_chroot_bind ${@}
    exit
fi
