#!/bin/bash

__THIS="${0}"

print_usage() {
    printf "${__THIS} [-h] [upgrade_brew] [upgrade_macos]\n\n"
    printf 'Upgrade Brew, Brew Casks, and MacOS softwareupdate.\n\n'
    printf '# Upgrade everything:\n'
    printf "sudo ${__THIS}\n\n"
    printf '# Upgrade only brew:\n'
    printf "sudo ${__THIS} upgrade_brew\n\n"
    printf '# Upgrade only macos:\n'
    printf "sudo ${__THIS} upgrade_macos\n\n"
}

upgrade_brew() {
    sudo -u "${SUDO_USER}" brew upgrade $(sudo -u "${SUDO_USER}" brew list --formula)
    # ctags htop
    sudo -u "${SUDO_USER}" brew upgrade --cask \
        google-chrome firefox \
        visual-studio-code
}

upgrade_macos() {
    softwareupdate --list
    softwareupdate --download
    softwareupdate --install --all --restart
}

_main() {
    upgrade_brew
    upgrade_macos
}
main() {
    for arg in "${@}"; do
        case "${arg}" in
            -h|--help|help) print_usage; return;;
        esac
    done
    if test "$(id -u)" -gt 0; then
        echo "This script must be be run as root; e.g. prefixed with 'sudo ':"
        echo "sudo ${__THIS}"
        exit 2
    fi
    if [ -z "${*}" ]; then
        (set -x; _main)
    else
        for arg in "${@}"; do
            case "${arg}" in
                upgrade_brew) (set -x; upgrade_brew);;
                upgrade_macos) (set -x; upgrade_macos);;
            esac
        done
    fi
}

main "${@}"
