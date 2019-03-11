#!/bin/sh

# Setup Mattermost Desktop Client

# SeeAlso:
# - https://github.com/mattermost/desktop/releases (.tar.gz, DEB)
# - https://copr.fedorainfracloud.org/coprs/agoston/mattermost/ (RPM)
# - https://github.com/matterhorn-chat/matterhorn
#   - https://github.com/matterhorn-chat/matterhorn/releases

function _setup_mattermost_desktop_fedora {
    # https://copr.fedorainfracloud.org/coprs/agoston/mattermost/
    sudo dnf copr enable agoston/mattermost
    sudo dnf install -y mattermost-desktop
}

function main {
    _setup_mattermost_desktop_fedora
}

main
