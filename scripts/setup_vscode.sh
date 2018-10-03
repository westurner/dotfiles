#!/bin/bash
#
# Install VSCode on Fedora
#
# Usage:
# ```bash
# sudo bash ./setup_vscode.sh
# ```
#
# References:
# - https://code.visualstudio.com/docs/setup/linux
# - https://fedoraproject.org/wiki/Visual_Studio_Code

VSCODE_REPO_PATH='/etc/yum.repos.d/vscode.repo'

function _setup_vscode_add_repo_dnf {
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > '"${VSCODE_REPO_PATH}"
    dnf check-update
}
function _setup_vscode_install {
    dnf install -y code
}

function _setup_vscode_status {
    sudo -u nobody code --version
    # sudo -u nobody code --list-extensions
}

function _setup_vscode_main {
    if [ ! -f "${VSCODE_REPO_PATH}" ]; then
        _setup_vscode_add_repo_dnf
    fi

    which code
    _setup_vscode_install
    which code

    _setup_vscode_status
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    _setup_vscode_main # "${@}"
    exit
fi
