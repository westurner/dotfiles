#!/bin/sh

# querydns.sh
#
# Author: @westurner
#
# Usage:
# $ querydns.sh <domain> [<output.txt>]
# $ querydns.sh -h
# $ DNS_SERVER="1.1.1.1" querydns.sh <domain> [<output.txt>]
# $ WHOIS_SERVER="whois" querydns.sh <domain> [<output.txt>]

THISFILE=${0}
THISDIR=$(dirname "${THISFILE}")

DNS_SERVER="${DNS_SERVER:-"8.8.8.8"}"
# WHOIS_SERVER=$WHOIS_SERVER
whois_opts=${WHOIS_SERVER:+"-h ${WHOIS_SERVER}"}

function _query_dns {
    local domain=$1
    if [ -z "${domain}" ]; then
        echo 'Error: domain must be specified ($1)'
        return 2
    fi
    whois ${whois_opts} "${domain}"
    domains=("$domain" "www.${domain}")
    for domain in ${domains[*]}; do
        dig @"${DNS_SERVER}" -t any "${domain}"
    done
    for domain in ${domains[*]}; do
        delv @"${DNS_SERVER}" -t any "${domain}"
    done
}

function _query_dns_usage {
    echo "${0} <domain> [<output.txt>]"
    echo ""
    echo "Query DNS information with whois, dig, delv"
    echo ""
    echo "  <domain>  DNS domain (. and www. will be prepended)"
    echo "  <output>  File to write output to"
    echo '            (default: dirname($0)/southernavs.dns.backup.$(date -Is).txt)'
    echo ''
    echo '  $DNS_SERVER    This server will be used for DNS queries (dig, delv)'
    echo "                 (default: 8.8.8.8 (Google DNS))"
    echo "                 - 8.8.8.8 / 8.8.4.4 (Google DNS)"
    echo "                 - 1.1.1.1 / 1.0.0.1 (CloudFlare)"
    echo "                 - 9.9.9.9 / 9.9.9.10 (Quad9)"
    echo ""
    echo '  $WHOIS_SERVER  This server will be used for whois queries (whois)'
    echo "                 (default: unset)"
}

function query_dns {
    for arg in "${@}"; do
        case $arg in
            -h|--help)
                _query_dns_usage;
                return 0
                ;;
        esac
    done
    local domain="${1}"
    local dest="${2}"
    if [ -z "${domain}" ]; then
        echo 'Error: domain must be specified ($1)'
        return 2
    fi
    if [ -z "${dest}" ]; then
        dest="${THISDIR}/${domain}.dnsbackup.$(date -Is).txt"
    fi
    (set -x; _query_dns "${domain}" 2>&1 | tee "${dest}")
}

function main {
    query_dns "${@}"
}

main "${@}"

