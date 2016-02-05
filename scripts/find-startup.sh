#!/bin/sh
## find-startup.sh

function find_startup () {
    (set -x; _find_startup ${@}; return)
    return
}

function _find_startup () {
    # find-startup()    -- find common startup files in common locations
    cmd=${@:-"ls"}
    paths='/etc/rc?.d /etc/init.d /etc/init /etc/xdg/autostart /etc/dbus-1'
    paths="$paths ~/.config/autostart /usr/share/gnome/autostart"
    for p in $paths; do
        if [ -d $p ]; then
            find $p -type f | xargs $cmd
        fi
    done
    return
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    find_startup ${@}
    exit
fi
