#!/bin/bash
set -ex
# https://www.wireguard.com/netns/

ifwg0="${ifwg0:-"wgvpn0"}"
ifeth0="${ifeth0:-"ifeth0"}"
ifwlan0="${ifwlan0:-"wlan0"}"
ifphy0="${ifphy0:-"phy0"}"

ifwg0_ip0="${ifwg0_ip0:-"192.168.4.33/32"}"

[[ $UID != 0 ]] && exec sudo -E "$(readlink -f "$0")" "$@"

function up {
    killall wpa_supplicant dhcpcd || true
    ip netns add physical
    ip -n physical link add "${ifwg0}" type wireguard
    ip -n physical link set "${ifwg0}" netns 1
    wg setconf "${ifwg0}" /etc/wireguard/"${ifwg0}".conf
    ip addr add "${ifwg0_ip0}" dev "${ifwg0}"
    ip link set "${ifeth0}" down
    ip link set "${wlan0}" down
    ip link set "${ifeth0}" netns physical
    iw phy "${phy0}" set netns name physical
    ip netns exec physical dhcpcd -b "${ifeth0}"
    ip netns exec physical dhcpcd -b "${wlan0}"
    ip netns exec physical wpa_supplicant -B -c/etc/wpa_supplicant/wpa_supplicant-"${wlan0}".conf -i"${wlan0}"
    ip link set "${ifwg0}" up
    ip route add default dev "${ifwg0}"
}

function down {
    killall wpa_supplicant dhcpcd || true
    ip -n physical link set "${ifeth0}" down
    ip -n physical link set "${wlan0}" down
    ip -n physical link set "${ifeth0}" netns 1
    ip netns exec physical iw phy "${phy0}" set netns 1
    ip link del "${ifwg0}"
    ip netns del physical
    dhcpcd -b "${ifeth0}"
    dhcpcd -b "${wlan0}"
    wpa_supplicant -B -c/etc/wpa_supplicant/wpa_supplicant-"${wlan0}".conf -i"${wlan0}"
}

function physexec {
    exec ip netns exec physical sudo -E -u \#${SUDO_UID:-$(id -u)} -g \#${SUDO_GID:-$(id -g)} -- "$@"
}


function main {
    command="$1"
    shift

    case "$command" in
        up) up "$@" ;;
        down) down "$@" ;;
        exec|physexec) physexec "$@" ;;
        *) echo "Usage: $0 up|down|exec" >&2; exit 1 ;;
    esac
}

#if [ "${0}" == "${BASH_SOURCE}" ]; then
    main "${@}"
#fi
