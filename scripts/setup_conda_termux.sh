#!/bin/bash

__this=$0

function _setup_proot {
    pkg install -y proot proot-distro
}

function _setup_proot_debian_buster {
    proot-distro install debian-buster
    proot-distro login debian-buster --termux-home
}

function _setup_proot_fedora {
    (set +e; proot-distro install fedora || true)
    proot-distro login fedora --termux-home -- bash $__this installmambaforge
}

function _setup_proot_login {
    distroname=$1
    if [ -z "${distroname}" ]; then
        return 2
    fi
    proot-distro login "${distroname}" --termux-home -- bash
}


function _setup_miniforge {
    curl -OL https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh
    bash Miniforge3-Linux-aarch64.sh -b
}

function _setup_mambaforge {
    installersh="mambaforge-$(uname)-$(uname -m).sh"
    curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/${installersh}"
    bash "${installersh}" -b
}

function main {
    arg=$1
    if [ -z "${arg}" ] ; then
        _setup_proot
        _setup_proot_fedora
        _setup_proot_login "fedora"
    elif [ "${arg}" == "installmambaforge" ]; then
        _setup_mambaforge
    elif [ "${arg}" == "login" ]; then
        _setup_proot_login "fedora"
    fi
}

(set -x -v -e; main "${@}")
