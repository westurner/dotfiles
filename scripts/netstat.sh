#!/bin/sh -e
## netstat.sh

function netstatsh() {
    (set -x; _netstatsh ${@}; return)
    return
}

function _netstatsh () {
    # netstatsh()        -- print networking information
    echo "# netstatsh:"  `date +'%FT%T%z'`
    echo "#####################################################"
    netstatpsutil="${__DOTFILES}/scripts/netstatpsutil.py"
    if [ -n "${__IS_LINUX}" ]; then
        sudo ip a 2>&1
        sudo ip r 2>&1
        sudo ifconfig -a 2>&1
        sudo route -n 2>&1
        sudo iptables -L -n 2>&1
        sudo netstat -ntaup 2>&1 | sort -n
    elif [ -n "${__IS_MAC}" ]; then
        sudo ifconfig -a
        sudo netstat -r -n
        sudo arp -a -n
    else
        sudo ifconfig -a
    fi
    if [ -x "${netstatpsutil}" ]; then
        sudo ${netstatpsutil}
    fi
    return
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    netstatsh ${@}
    exit
fi
