#!/bin/sh

function dnfoffline {
    sudo dnf --setopt=metadata_expire=-1 \
 --setopt=fedora.metadata_expire=-1 \
 --setopt=fedora-update.metadata_expire=-1 \
 --setopt=rpmfusion-free.metadata_expire=-1 \
 --setopt=rpmfusion-nonfree.metadata_expire=-1 \
 "${@}"
}

dnfoffline "${@}"
