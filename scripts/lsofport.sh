#!/bin/sh

THIS=$0
function lsof_port_print_usage {
    this=$(basename "${THIS}")
    echo "${THIS} [-h] <port> [<ss|netstat>]"
    echo "## Usage:"
    echo "${this} 631"
    echo "${this} 631 netstat"
    echo "${this} 631 ss"
}

function lsof_port {
    #  lsof_port <listening_port> [
    local listening_port=$1
    local socketinfoprog=${2:-${LSOFPORT_PROG}}

    if [ ! -n "${socketinfoprog}" ]; then
        if [ -n "$(type -p ss)" ]; then
            socketinfoprog=ss
        elif [ -n "$(type -p netstat)" ]; then
            socketinfoprog=netstat
        else
            socketinfoprog="bash"
            echo 'ERROR: neither `ss` nor `netstat` are on $PATH'
        fi
    fi

    if [ "${socketinfoprog}" == "ss" ]; then
        ss -nplH -z -t "sport = :$((listening_port))" >&2
        ss -nplH -t "sport = :$((listening_port))" | awk '{ print $6 }' | cut -f2 -d',' | cut -f2 -d'='
    elif [ "${socketinfoprog}" == "netstat" ]; then
        netstat -nlp -t | grep ":${listening_port}"  # TODO
    elif [ "${socketinfoprog}" == "bash" ]; then
        find_processes_listening_on_port "${listening_port}"
    else
        (set -x; "${socketinfoprog}")
    fi
}

function _ls_proc_pids {
    find /proc -maxdepth 1 -regextype posix-extended -regex '.*[0-9]+' -readable
}

#function _ls_sockets {
#    cat /proc/self/net/tcp
#}

PS_COMMAND='ps -uZ -p'

function find_processes_listening_on_port {
    local port=$1
    local porthex=$(printf '%04X' "${port}")
    local portexpr="^\s*[0-9]+: [0-9A-F]{8}:${porthex} 00000000:0000"

    local socketid=$(grep -E "${portexpr}" /proc/self/net/tcp | awk '{ print $10 }')
    if [ ! -n "${socketid}" ]; then
        echo "ERROR: did not find any processes listening on port=${port}"
        return 2
    fi

    pids=$((set +x; ls -al /proc/*/fd/* 2>/dev/null) | grep "socket:\[${socketid}\]" | sed 's,.*/proc/\(.*\)/fd.*,\1,')
    for pid in "${pids}"; do
        echo "$pid"
        if [ -n "${PS_COMMAND}" ]; then
            ${PS_COMMAND} "${pid}"
        fi
    done
    return
}

function test_lsof_port {
    port=18088
    lsof_port "${port}" "bash"
    lsof_port "${port}" "ss"
    lsof_port "${port}" "netstat"
    lsof_port "${port}"
}

function lsof_port_main {
    if [ $# -eq 0 ]; then
        lsof_port_print_usage
        return
    fi
    for arg in "${@}"; do
        case "${arg}" in
            --test)
                (set -xe; test_lsof_port)
                return
                ;;
            -h|--help)
                lsof_port_print_usage
                return
                ;;
        esac
    done
    lsof_port "${@}"
}

lsof_port_main "${@}"
