#!/bin/sh

upgrade_brew() {
    sudo -u "${SUDO_USER}" brew upgrade $(sudo -u "${SUDO_USER}" brew list)
    sudo -u "${SUDO_USER}" brew cask upgrade visual-studio-code iterm2 google-chrome firefox
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
    if test "$(id -u)" -gt 0; then
        echo "This script must be be run as root (e.g. prefixed with 'sudo ')"
        exit 2
    fi
    (set -x; _main)
}

main "${@}"
