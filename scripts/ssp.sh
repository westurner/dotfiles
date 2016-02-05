#!/bin/sh
## 

function ssp() {
    (set -x; _ssp_ ${@}; return)
    return
}

function ssp_set_facls () {
	(umask 0026; mkdir -p ${_VARLOG} || true)
	chmod go-rw ${_VARLOG}
	(umask 0026; mkdir -p ${_VARCACHE} || true)
	chmod go-rw ${_VARCACHE}
	(umask 0026; mkdir -p ${_VARCACHE_SSP} || true)
	chmod go-rw ${_VARCACHE_SSP}
}

function _setup_ssp () {

    _VARCACHE="${_VARCACHE}"
    _VARLOG="${_VARLOG}"
    _VARRUN="${_VARRUN}"

    _VARCACHE=${_VARCACHE:-${VIRTUAL_ENV:+"${VIRTUAL_ENV}/var/cache"}}
    _VARCACHE_SSP=${_VARCACHE}/ssp
    _VARLOG=${_VARLOG:-${VIRTUAL_ENV:+"${VIRTUAL_ENV}/var/log"}}

    _VARCACHE="${_VARCACHE:-"."}"
    _VARCACHE_SSP="${_VARCACHE_SSP:-"."}"
    _VARLOG="${_VARLOG:-"."}"

    _VARRUN="${_VARRUN:-'.'}" # XXX

    SSP_PID_FILE=${SSP_PID_FILE:-"${_VARCACHE_SSP}/ssp.pid"}
}
## SSH 

function _comment_prefix() {
    (set +x; sed 's/^\(.*\)$/# \1/g')
    return
}

function ssp_status () {
    _setup_ssp
    if [ -f "${SSP_PID_FILE}" ]; then
        SSP_PID=$(cat "${SSP_PID_FILE}")
    fi
    printf "SSP_PROXY_PORT=%d\n" "${SSP_PROXY_PORT}" 
    printf "SSP_PID=%d\n" "${SSP_PID}"
    if [ -n "${SSP_PID}" ]; then
        echo "# {"
        (set -x; ps -p "${SSP_PID}" 2>&1 | _comment_prefix)
        echo "# }"
    fi
}

function ssp_check() {
    (set -x;
    which ssh;
    ssh -V 2>&1;
    ) | _comment_prefix
    echo SSP_USERHOST="${SSP_USERHOST}";
    ssp_status
}

function ssp_start () {

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
        return 1
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
    SSP_LOCHOSTPORT="${SSP_LOCADDR:+"${SSP_LOCADDR}:"}${SSP_LOCPORT}"
    _setup_ssp
	test -n "${SSP_USERHOST}" || (echo "SSP_USERHOST=${SSP_USERHOST}" && exit 1)
	ssp_set_facls
	date +'%F %T%z'
    SSP_SSH_OPTS="${SSP_SSH_OPTS:-""}"  # SSP_SSH_OPTS="-v"
    if [ -n "${_VARLOG}" ]; then
        { 
            (
                (
                    ssh ${SSP_SSH_OPTS} \
                        -N -D${SSP_LOCHOSTPORT} ${SSP_USERHOST} 2>&1 &
                    echo "${!}" > ${SSP_PID_FILE} ;
                ) | tee "${_VARLOG}/ssp.log" ;
            ) &
            cat ${SSP_PID_FILE};
        }
    else
        {
            (
                ssh ${SSP_SSH_OPTS} \
                    -N -D${SSP_LOCHOSTPORT} ${SSP_USERHOST}
            ) &
            echo "${!}" > ${SSP_PID_FILE} ;
            cat ${SSP_PID_FILE} ;
        }
    fi
    ssp_status
    if [ -n "${_ssp_opts_foreground}" ]; then
        fg
    fi
}

# $(SSP_PID_FILE): open-ssh

function ssp_stop () {
    _setup_ssp
    if [ -f "${SSP_PID_FILE}" ]; then
        kill -9 $(cat "${SSP_PID_FILE}") || true
        rm ${SSP_PID_FILE}
    fi
	ssp_set_facls
    ssp_status
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
    local cmdname=$(basename ${0})
    echo "Usage: ${cmdname} [start|stop|check|status] [-h]"
    echo ""
    echo '    SSP_USERHOST="user@hostorip -p 22"'" ${cmdname} start"
    echo "    ${cmdname} status"
    echo "    ${cmdname} stop"
    echo "    ${cmdname} check"
    echo ""
    echo "  -s,start   --  start the SOCKS tunnel process"
    echo "  -p,stop    --  stop the SOCKS tunnel process"
    echo "  -c,check   --  check the SOCKS tunnel process"
    echo "  -u,status  --  check the SOCKS tunnel process"
    echo ""
    echo "  -h  --  help"
    echo ""
}

function ssp_parse_opts () {
    case "${1}" in
        s|S|start|open)
            _ssp_opts_start=true
            ;;
        f|F|foreground)
            _ssp_opts_start=true
            _ssp_opts_foreground=true
            ;;
        p|P|stop|close)
            _ssp_opts_stop=true
            ;;
        c|C|check)
            _ssp_opts_check=true
            ;;
        u|U|status)
            _ssp_opts_status=true
            ;;
        h|H|help)
            _ssp_opts_help=true
            ;;
    esac
}

function ssp_main () {

    while getopts "osScpPChH" opt; do
        ssp_parse_opts "${opt}"
    done

    for arg in "${@}"; do
        ssp_parse_opts "${arg}"
    done

    haverunacmd=
    if [ -n "${_ssp_opts_start}" ]; then
        ssp_start
        haverunacmd=true
    fi
    if [ -n "${_ssp_opts_stop}" ]; then
        ssp_stop
        haverunacmd=true
    fi
    if [ -n "${_ssp_opts_check}" ]; then
        ssp_check
        haverunacmd=true
    fi
    if [ -n "${_ssp_opts_status}" ]; then
        ssp_status
        haverunacmd=true
    fi
    if [ -n "${_ssp_opts_help}" ] || [ -z "${haverunacmd}" ]; then
        ssp_usage
    fi
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    ssp_main ${@}
    exit
fi
