#!/bin/sh
## 

function ssp() {
    (set -x; _ssp_ ${@}; return)
    return
}

function __set_facls () {
	(umask 0026; mkdir -p ${_VARLOG} || true)
	chmod go-rw ${_VARLOG}
	(umask 0026; mkdir -p ${_VARCACHE} || true)
	chmod go-rw ${_VARCACHE}
	(umask 0026; mkdir -p ${_VARCACHE_SSH} || true)
	chmod go-rw ${_VARCACHE_SSH}
}

function _setup_ssp () {

    _VARCACHE="${_VARCACHE}"
    _VARLOG="${_VARLOG}"
    _VARRUN="${_VARRUN}"

    _VARCACHE=${_VARCACHE:-${VIRTUAL_ENV:+"${VIRTUAL_ENV}/var/cache"}}
    _VARCACHE_SSH=${_VARCACHE}/ssh
    _VARLOG=${_VARLOG:-${VIRTUAL_ENV:+"${VIRTUAL_ENV}/var/log"}}

    _VARCACHE="${_VARCACHE:-"."}"
    _VARCACHE_SSH="${_VARCACHE_SSH:-"."}"
    _VARLOG="${_VARLOG:-"."}"

    _VARRUN="${_VARRUN:-'.'}" # XXX

    SSP_PID_FILE=${_VARCACHE_SSH}/.pid
}
## SSH 

function ssp_open () {

    #  $1 (str)     -- SSP_USERHOST
    #  $2 (str)     -- SSP_RPORT 
    #                   Default: 1080
    #  $3 (str)     -- SSP_LOCADDR (ip addr to bind server to)
    #                   Defaults:
    #                      Mac: 127.0.0.1
    #                      Linux: 10.10.10.10
    SSP_USERHOST=${1:-${SSP_USERHOST}}
    if [ -z "${SSP_USERHOST}" ]; then
        echo "Err: SSP_USERHOST unspecified"
        echo "SSP_USERHOST='user@host -p 22'"
    fi

    SSP_LOCPORT=${2:-${SSP_LOCPORT:-"1080"}}

    SSP_LOCADDR=${3:-${SSP_LOCADDR}}
    if [ -n "${__IS_LINUX}" ]; then
        SSP_LOCADDR=${3:-"10.10.10.10"}
        sudo ip addr | grep "${SSP_LOCADDR}"
        sudo ip addr add "${SSP_LOCADDR}" dev lo netmask 255.255.255.0
    else
        SSP_LOCADDR="127.0.0.1"
    fi

    SSP_LOCHOSTPORT="${SSP_LOCADDR}:${SSP_LOCPORT}"
    _setup_ssp
	test -n "${SSP_USERHOST}" || (echo "SSP_USERHOST=${SSP_USERHOST}" && exit 1)
	__set_facls
	date +'%F %T%z'
    if [ -n "${_VARLOG}" ]; then
        { set -m; \
            (ssh -v -N -D${SSP_LOCHOSTPORT} ${SSP_USERHOST} 2>&1 | \
                tee ${_VARLOG}/ssp.log) & \
            echo "${!}" > ${SSP_PID_FILE} ; \
            cat ${SSP_PID_FILE}; \
            fg; }
    else
        { set -m; \
            (ssh -v -N -D${SSP_LOCHOSTPORT} ${SSP_USERHOST}) & \
            echo "${!}" > ${SSP_PID_FILE} ; \
            cat ${SSP_PID_FILE}; \
            fg; }
    fi
}

# $(SSP_PID_FILE): open-ssh

function ssp_close () {
    _setup_ssp
	test -f ${SSP_PID_FILE}
	(umask 0026; mkdir -p ${_VARCACHE_SSH})
	kill -9 $(shell cat "${SSP_PID_FILE}") || true
	rm ${SSP_PID_FILE}
	__set_facls
}


function _ssp_ () {
    #  ssp()         -- Open a SOCKS SSH session
    #  $1 (str)     -- SSP_USERHOST
    #  $2 (str)     -- SSP_RPORT 
    SSP_USERHOST=${1:-${SSP_USERHOST}}
    SSP_LOCPORT=${2:-${SSP_LOCPORT:-"1080"}}

    SSP_LOCADDR=${3:-${SSP_LOCADDR}}
    if [ -n "${__IS_LINUX}" ]; then
        SSP_LOCADDR=${3:-"10.10.10.10"}
        sudo ip addr | grep "${SSP_LOCADDR}"
        sudo ip addr add "${SSP_LOCADDR}" dev lo netmask 255.255.255.0
    else
        SSP_LOCADDR="127.0.0.1"
    fi

    _VARLOG="${_VARLOG}"
    _VARRUN="${_VARRUN:-'.'}"
    SSP_LOCHOSTPORT="${SSP_LOCADDR}:${SSP_LOCPORT}"
    
    if [ -n "${_VARLOG}" ]; then
        ssh -ND ${SSP_LOCHOSTPORT} "${SSP_USERHOST}" | \
            tee ${_VARLOG}/ssp.log
    else
        ssh -ND ${SSP_LOCHOSTPORT} "${SSP_USERHOST}"
    fi

    _SSP_RETVAL=$?
    _SSP_PID=$!
    echo "_SSP_PID=${1}" | tee ${_VARRUN}/ssp.pid
    return $_SSP_RETVAL
}

function ssp_usage () {
    echo "# $0"
    echo "Usage: $(basename $0) [-o|-c] [-h]";
    echo ""
    echo "  -o  --  (o)pen the SOCKS tunnel"
    echo "  -c  --  (c)lose the SOCKS tunnel"
    echo ""
    echo "  -h  --  help"
    echo ""
}

function ssp_main () {

    while getopts "och" opt; do
        case "${opt}" in
            o|open|start)
                _ssp_opts_start=true
                ;;
            c|close|stop)
                _ssp_opts_stop=true
                ;;
            h)
                _ssp_opts_help=true
                ;;
        esac
    done

    haverunacmd=
    if [ -n "${_ssp_opts_start}" ]; then
        ssp_open
        haverunacmd=true
    fi
    if [ -n "${_ssp_opts_stop}" ]; then
        ssp_close
        haverunacmd=true
    fi
    if [ -n "${_ssp_opts_help}" ] || [ -z "${haverunacmd}" ]; then
        ssp_usage
    fi
}

if [ "${BASH_SOURCE}" == "${0}" ]; then
    ssp_main ${@}
    exit
fi
