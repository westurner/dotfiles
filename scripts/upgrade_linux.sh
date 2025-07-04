#!/bin/bash

__THIS="${0}"
__SCRIPTNAME=$(basename "${0}")

print_usage() {
    printf "${__SCRIPTNAME} [-h] [upgrade_brew] [upgrade_linux]\n\n"
    printf 'Upgrade all the things (See also: ujust, bakefile,)\n\n'
    printf " -y  --yes      Pass '-y' to commands that support the option\n"
    printf " upgrade_flatpak\n"
    printf " upgrade_linux\n"
    printf " upgrade_brew\n"
    printf "\n"
    printf '# Upgrade everything:\n'
    printf "sudo ${__SCRIPTNAME}\n\n"
    printf '# Upgrade only flatpak:\n'
    printf "sudo ${__SCRIPTNAME} upgrade_flatpak\n\n"
    printf '# Upgrade only brew:\n'
    printf "sudo ${__SCRIPTNAME} upgrade_brew\n\n"
    printf '# Upgrade only linux:\n'
    printf "sudo ${__SCRIPTNAME} upgrade_linux\n\n"
}

upgrade_flatpak() {
    _Y_YES=${1:-${Y_YES}}
    SUDO=${SUDO_USER:+"sudo -u ${SUDO_USER}"}
    $SUDO flatpak upgrade ${_Y_YES:+"${_Y_YES}"} \
        com.google.Chrome \
        org.chromium.Chromium
        #org.mozilla.firefox \
    $SUDO flatpak upgrade ${_Y_YES:+"${_Y_YES}"}
}

upgrade_brew() {
    SUDO=${SUDO_USER:+"sudo -u ${SUDO_USER}"}
    $SUDO brew upgrade $($SUDO brew list --formula)
    # ctags htop
    $SUDO brew upgrade --cask \
        google-chrome firefox \
        visual-studio-code
}

_setup_upgrade_linux () {
    declare -g ETC_OS_RELEASE__ID=$(test -e /etc/os-release && cat /etc/os-release | grep '^ID=' | sed 's/^ID=//')
    declare -g ETC_OS_RELEASE__DISTRIB_ID=$(test -e /etc/os-release && cat /etc/os-release | grep '^DISTRIB_ID=' | sed 's/^DISTRIB_ID=//')


    declare -g IS_FEDORA=$(test "${ETC_OS_RELEASE__ID}" == "fedora")

    declare -g HAS_YUM=$(type -P yum)
    declare -g HAS_DNF=$(type -P dnf)
    declare -g HAS_RPM_OSTREE=$(type -P rpm-ostree)
    declare -g HAS_OSTREE=$(type -P ostree)

    if [ -n "${HAS_YUM}" ]; then
        declare -g _YUM="${HAS_YUM}"
    fi
    if [ -n "${HAS_DNF}" ]; then
        declare -g _DNF="${HAS_DNF}"
    fi
    if [ -n "${HAS_RPM_OSTREE}" ]; then
        declare -g _RPM_OSTREE="${HAS_RPM_OSTREE}"
    fi


    declare -g IS_DEBIAN=$(test "${ETC_OS_RELEASE__ID}" == "debian")
    declare -g IS_UBUNTU=$(test "${ETC_OS_RELEASE__DISTRIB_ID}" == "Ubuntu")

    declare -g HAS_APT_GET=$(type -P apt-get)
    declare -g HAS_APT=$(type -P apt)
    declare -g HAS_DPKG=$(type -P dpkg)

    if [ -n "${HAS_APT_GET}" ]; then
        declare -g _APT_GET="${HAS_APT_GET}"
    fi
    if [ -n "${HAS_APT}" ]; then
        declare -g _APT="${HAS_APT}"
    fi
    if [ -n "${HAS_DPKG}" ]; then
        declare -g _DPKG="${HAS_DPKG}"
    fi
}

upgrade_linux() {
    _Y_YES=${1:-${Y_YES}}

    _setup_upgrade_linux

    if [ -x "${_DNF}" ]; then
        ${_DNF} upgrade "${_Y_YES}"
    fi
    if [ -x "${_RPM_OSTREE}" ]; then
        ${_RPM_OSTREE} upgrade  #"${_Y_YES}"
    fi
}

upgrade_linux__get_status() {
    _setup_upgrade_linux


    if [ -x "${_OSTREE}" ]; then
        ${_OSTREE} admin status
    fi
    if [ -x "${_RPM_OSTREE}" ]; then
        ${_RPM_OSTREE} --version
        ${_RPM_OSTREE} status
        ${_RPM_OSTREE} db diff
        #${_RPM_OSTREE} install --dry-run
        ${_RPM_OSTREE} upgrade --check
        ${_RPM_OSTREE} upgrade --preview
    fi
    if [ -x "${_DNF}" ]; then
        ${_DNF} --version
        ${_DNF} history
        ${_DNF} status
    fi
    if [ -x "${_APT}" ]; then
        ${_APT} list --installed
        ${_APT} list --installed | grep -v 'automatic\]$'
        cat /var/log/dpkg.log | grep -Pie '[\d-]+ [\d:]+ install'
    elif [ -x "${_DPKG}" ]; then
        ${_DPKG} --get-selections
        ${_DPKG} -l | cat
    fi
}

_pager() {
    (set -x; cat "${@}")
}

upgrade_linux__get_changelogs() {
    _setup_upgrade_linux
    if [ -x "${_RPM_OSTREE}" ]; then
        ${_RPM_OSTREE} db diff --changelogs
    fi
    if [ -x "${_APT_GET}" ]; then
        (PAGER="pager_print_filename.sh" \
        ${_APT_GET} changelog $(awk '$3~/^install$/ {print $4;}' /var/log/dpkg.log))
    fi
}

_main() {
    main status
    main upgrade_flatpak
    main upgrade_linux
}

requires_root() {
    if test "$(id -u)" -gt 0; then
        echo "This script must be be run as root; e.g. prefixed with 'sudo ':"
        echo "sudo ${__THIS}"
        exit 2
    fi
}

requires_interactive_shell() {
    # TODO
    return 1
}

main() {
    for arg in "${@}"; do
        case "${arg}" in
            -h|--help|help) print_usage; return;;
        esac
    done
    if [ -z "${*}" ]; then
        (set -x; _main)
    else
        if [ -n "${DO_PAGER}" ]; then
            (set -x; shift; _pager "${@}")
            return 0
        fi
        for arg in "${@}"; do
            case "${arg}" in
                -y|--yes)
                    declare -g Y_YES='-y'
                    ;;
            esac
        done
        for arg in "${@}"; do
            case "${arg}" in
                _pager)
                    (set -x; shift; _pager "${@}")
                    ;;
                upgrade_brew)
                    (set -x; upgrade_brew)
                    ;;
                upgrade_flatpak)
                    (set -x; upgrade_flatpak)
                    ;;
                upgrade_linux)
                    requires_root;
                    (set -x; upgrade_linux)
                    ;;
                status)
                    (set -x; upgrade_linux__get_status)
                    ;;
                changelog|changelogs)
                    (set -x; upgrade_linux__get_changelogs)
                    ;;
            esac
        done
    fi
}

main "${@}"
