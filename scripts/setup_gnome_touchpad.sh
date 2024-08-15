#!/usr/bin/env bash
## setup_touchpad.sh


_THIS=$0
setup_touchpad__print_usage() {
    echo "${0} [-h][-v] [<--disable|--enable>] [--install]"
    echo ""
    echo " --enable / --enable-touchpad-when-typing"
    echo " --disable / --disable-touchpad-when-typing"
    echo ""
    echo " --install / --install-dconf-editor"
    echo ""
    echo "  -h/--help"
    echo "  -v/--verbose"
    echo ""
}

setup_touchpad__dnf_install() {
    sudo dnf install -y dconf-editor
}

setup_touchpad__rpmostree_install() {
    sudo rpm-ostree install -y dconf-editor
}

setup_touchpad__dconf_write_disable_while_typing() {
    value="${1:-"true"}"
    dconf write /org/gnome/desktop/peripherals/touchpad/disable-while-typing "${value}"
}

setup_touchpad__main() {
    for arg in "${@}"; do
        case "${arg}" in
            -h|--help)
                (set +x; setup_touchpad__print_usage)
                ;;
            -v|--verbose)
                set -x;
                echo 'args='"${@}"
                ;;
        esac
    done
    for arg in "${@}"; do
        case "${arg}" in
            --disable|--disable-touchpad-when-typing)
                (set -x; setup_touchpad__dconf_write_disable_while_typing true)
                ;;

            --enable|--enable-touchpad-when-typing)
                (set -x; setup_touchpad__dconf_write_disable_while_typing false)
                ;;

            --install|--install-conf)
                set -x
                if [ -e /usr/bin/rpm-ostree ]; then
                    setup_touchpad__rpmostree_install
                else
                    setup_touchpad__dnf_install
                fi
                ;;
        esac
    done
    # setup_touchpad__dconf_write_disable_while_typing true
}

(set -e; setup_touchpad__main "${@}")
