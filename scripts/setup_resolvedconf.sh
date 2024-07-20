#!/bin/sh

_THIS=$0

_setup_resolvedconf_usage() {
    echo "${_THIS} -- setup dns with systemd-resolved"
    cat <<EOF

  -c|--connection|--nm-connection  -- nm connection name|uuid from $ nmcli c s
  -i|--interface |--nm-device      -- nm device name|uuid from $ nmcli d s

  --status|--dnsstatus -- $ nmcli_status (may be specified more than once)

  --commit             -- Commit any changes by running $ nmcli d reapply

  --noauto             -- Don't use DNS from DHCP for the -c|--connection
  --auto               -- Do (also) use DNS from DHCP for the -c|--connection

  --tls=on|--tls       -- Do use DNS-over-TLS for the --connection
  --tls=off|--notls    -- Do not use DNS-over-TLS for the --connection


  --cbs|--cleanbrowsing-security  -- Set DNS to security.cleanbrowsing.org
  --cbf|--cleanbrowsing-family    -- Set DNS to family.cleanbrowsing.org
  --cba|--cleanbrowsing-adult     -- Set DNS to adult.cleanbrowsing.org

  --cf|--cloudflare               -- Set DNS to cloudflare-dns.com
                                     1.1.1.1, 1.0.0.1
  --cff|--cloudflare-family       -- Set DNS to family.cloudflare-dns.com
                                     1.1.1.3, 1.0.0.3
                                     blocking: Malware, Adlt Content
  --cfs|--cloudflare-security     -- Set DNS to security.cloudflare-dns.com
                                     1.1.1.2, 1.0.0.2
                                     blocking: Malware

  --gg|--google                   -- Set DNS to dns.google (8.8.8.8, 8.8.8.4)
  --q9|--quad9                    -- Set DNS to dns.quad9.net (9.9.9.9)

  --od|--opendns                  -- Set DNS to doh.opendns.org
  --odf|--opendns-familyshield    -- Set DNS to doh.family.opendns.org


  --commit             -- Commit any changes by running $ nmcli d reapply

  --test       -- Run Tests of this script
  -h / --help  -- Print help
EOF
}

_test_setup_resolvedconf() {
    set -e -x -v
    # TODO: $PS4
    (setup_resolvedconf_main)
    (setup_resolvedconf_main -h)
    (setup_resolvedconf_main --help)
}

_setup_resolvedconf_config() {
    export DNS_CLEANBROWSING_ADULT_IPV4="185.228.168.10#adult-filter-dns.cleanbrowsing.org 185.228.169.11#adult-filter-dns.cleanbrowsing.org"
    export DNS_CLEANBROWSING_ADULT_IPV6="2a0d:2a00:1::1#adult-filter-dns.cleanbrowsing.org 2a0d:2a00:2::1#adult-filter-dns.cleanbrowsing.org"
    export DNS_CLEANBROWSING_FAMILY_IPV4="185.228.168.168#family-filter-dns.cleanbrowsing.org 185.228.169.168#family-filter-dns.cleanbrowsing.org"
    export DNS_CLEANBROWSING_FAMILY_IPV6="2a0d:2a00:1::#family-filter-dns.cleanbrowsing.org 2a0d:2a00:2::#family-filter-dns.cleanbrowsing.org"
    export DNS_CLEANBROWSING_SECURITY_IPV4="185.228.168.9#security-filter-dns.cleanbrowsing.org 185.228.169.9#security-filter-dns.cleanbrowsing.org"
    export DNS_CLEANBROWSING_SECURITY_IPV6="2a0d:2a00:1::2#security-filter-dns.cleanbrowsing.org 2a0d:2a00:2::2#security-filter-dns.cleanbrowsing.org"
    export DNS_CLOUDFLARE_IPV4="1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com"
    export DNS_CLOUDFLARE_IPV6="2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com"
    export DNS_CLOUDFLARE_FAMILY_IPV4="1.1.1.3#family.cloudflare-dns.com 1.0.0.3#family.cloudflare-dns.com"
    export DNS_CLOUDFLARE_FAMILY_IPV6="2606:4700:4700::1113#family.cloudflare-dns.com 2606:4700:4700::1003::1001#family.cloudflare-dns.com"
    export DNS_CLOUDFLARE_SECURITY_IPV4="1.1.1.2#security.cloudflare-dns.com 1.0.0.2#security.cloudflare-dns.com"
    export DNS_CLOUDFLARE_SECURITY_IPV6="2606:4700:4700::1112#security.cloudflare-dns.com 2606:4700:4700::1002#security.cloudflare-dns.com"
    export DNS_GOOGLE_IPV4="8.8.8.8#dns.google 8.8.4.4#dns.google"
    export DNS_GOOGLE_IPV6="2001:4860:4860::8888#dns.google 2001:4860:4860::8844#dns.google"
    export DNS_OPENDNS_IPV4="208.67.222.222#doh.opendns.com 208.67.220.220#doh.opendns.com"
    export DNS_OPENDNS_IPV6="2620:119:35::35#doh.opendns.com 2620:119:53::53#doh.opendns.com"
    export DNS_OPENDNS_FAMILYSHIELD_IPV4="208.67.222.123#doh.familyshield.opendns.com 208.67.220.123#doh.familyshield.opendns.com"
    export DNS_OPENDNS_FAMILYSHIELD_IPV6="2620:119:35::123#doh.familyshield.opendns.com 2620:119:53::123#doh.familyshield.opendns.com"
    export DNS_QUAD9_IPV4="9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net"
    export DNS_QUAD9_IPV6="2620:fe::fe#dns.quad9.net 2620:fe::9#dns.quad9.net"
    # - https://cleanbrowsing.org/filters
    # - https://developers.cloudflare.com/1.1.1.1/setup/
    # - https://developers.google.com/speed/public-dns/docs/dns-over-tls
    # - https://dns.google/
    # - https://support.opendns.com/hc/en-us/articles/360038086532-Using-DNS-over-HTTPS-DoH-with-OpenDNS
    # - https://www.quad9.net/service/service-addresses-and-features
}

_setup_resolvedconf_print_dns_config() {
    export | grep  '^export DNS_'
}

setup_resolvedconf_main() {
    if [ -z "${*}" ]; then
        (set +x +v; _setup_resolvedconf_usage)
        echo -e "\nNo arguments specified. Exiting with retcode 0."
        exit 0
    fi
    _setup_resolvedconf_config

    for arg in "${@}"; do
        if [ -n "${nextargis_connection}" ]; then
            NM_CONNECTION="${arg}"
            nextargis_connection=
            continue
        fi
        if [ -n "${nextargis_interface}" ]; then
            NM_DEVICE="${arg}"
            nextargis_interface=
            continue
        fi
        case "${arg}" in
            -c|--connection)
                nextargis_connection=1;
                ;;
            -i|--interface|--nm-device)
                nextargis_interface=1;
                ;;
            -h|--help)
                (set +x +v; _setup_resolvedconf_usage)
                exit 0
                ;;
            -v|--verbose)
                VERBOSITY=1
                ;;
            --test)
                set -x;
                echo "## <tests>"
                _test_setup_resolvedconf "${@}"
                echo "## </tests>"
                ;;
            --list-all)
                echo "LISTING ALL"
                (set -x; _setup_resolvedconf_print_dns_config)
                # export | grep -E '^DNS_'
                ;;
            --resetdns-to-defaults)
                echo "TODO"
                ;;
            --append)
                echo "TODO append DNS entries instead of modifying to them only"
                ;;
            --commit)
                do_commit=1
                ;;
        esac
    done

    for arg in "${@}"; do
        case "${arg}" in
            -s|--status|s|status)
                has_a_call_to_status=1
                ;;
        esac
    done

    fail_because_args=
    if [ -n "${VERBOSITY}" ]; then
        set -x;
    fi
    if [ -z "${NM_CONNECTION}" ]; then
        echo 'ERROR: You must specify -c|--connection or $NM_CONNECTION. See: $ nmcli c s'
        fail_because_args=1
    fi
    if [ -z "${NM_DEVICE}" ]; then
        echo 'ERROR: You must specify -i|--device or $NM_DEVICE.         See: $ nmcli d s'
        fail_because_args=1
    fi

    nmcli_status() {
        $NM_DEVICE=$NM_DEVICE
        $NM_CONNECTION=$NM_CONNECTION
        nmcli -f name,uuid,type,device c show --active
        nmcli c show "${NM_CONNECTION}"
        nmcli d show "${NM_DEVICE}"
    }

    if [ -n "${fail_because_args}" ]; then
        echo ""
        _setup_resolvedconf_usage
        echo ""
        if [ -n "${has_a_call_to_status}" ] ; then
            nmcli_status
        fi
        #return "${fail_because_args}"
    fi

    for arg in "${@}"; do
        case "${arg}" in
            -s|--status|s|status)
                # nmcli connection show "${NM_CONNECTION}"
                nmcli_status
                ;;
            --status|--dnsstatus)
                nmcli connection show "${NM_CONNECTION}" | grep -i dns
                ;;
            --noauto)
                nmcli connection modify "${NM_CONNECTION}" ipv4.ignore-auto-dns yes
                nmcli connection modify "${NM_CONNECTION}" ipv6.ignore-auto-dns yes
                ;;
            --auto)
                nmcli connection modify "${NM_CONNECTION}" ipv4.ignore-auto-dns no
                nmcli connection modify "${NM_CONNECTION}" ipv6.ignore-auto-dns no
                ;;
            --tls|--tls=on)
                nmcli connection modify "${NM_CONNECTION}" connection.dns-over-tls 1
                ;;
            --tls=off)
                nmcli connection modify "${NM_CONNECTION}" connection.dns-over-tls 0
                ;;

            --cbs|--cleanbrowsing-security)
                nmcli connection modify "${NM_CONNECTION}" ipv4.dns "${DNS_CLEANBROWSING_SECURITY_IPV4}"
                nmcli connection modify "${NM_CONNECTION}" ipv6.dns "${DNS_CLEANBROWSING_SECURITY_IPV6}"
                ;;
            --cbf|--cleanbrowsing-family)
                nmcli connection modify "${NM_CONNECTION}" ipv4.dns "${DNS_CLEANBROWSING_FAMILY_IPV4}"
                nmcli connection modify "${NM_CONNECTION}" ipv6.dns "${DNS_CLEANBROWSING_FAMILY_IPV6}"
                ;;
            --cba|--cleanbrowsing-adult)
                nmcli connection modify "${NM_CONNECTION}" ipv4.dns "${DNS_CLEANBROWSING_ADULT_IPV4}"
                nmcli connection modify "${NM_CONNECTION}" ipv6.dns "${DNS_CLEANBROWSING_ADULT_IPV6}"
                ;;

            --cf|--cloudflare)
                nmcli connection modify "${NM_CONNECTION}" ipv4.dns "${DNS_CLOUDFLARE_IPV4}"
                nmcli connection modify "${NM_CONNECTION}" ipv6.dns "${DNS_CLOUDFLARE_IPV6}"
                ;;
            --cff|--cloudflare-family)
                nmcli connection modify "${NM_CONNECTION}" ipv4.dns "${DNS_CLOUDFLARE_FAMILY_IPV4}"
                nmcli connection modify "${NM_CONNECTION}" ipv6.dns "${DNS_CLOUDFLARE_FAMILY_IPV6}"
                ;;
            --cfs|--cloudflare-security)
                nmcli connection modify "${NM_CONNECTION}" ipv4.dns "${DNS_CLOUDFLARE_SECURITY_IPV4}"
                nmcli connection modify "${NM_CONNECTION}" ipv6.dns "${DNS_CLOUDFLARE_SECURITY_IPV6}"
                ;;

            --gg|--google)
                nmcli connection modify "${NM_CONNECTION}" ipv4.dns "${DNS_GOOGLE_IPV4}"
                nmcli connection modify "${NM_CONNECTION}" ipv6.dns "${DNS_GOOGLE_IPV6}"
                ;;

            --od|--opendns)
                nmcli connection modify "${NM_CONNECTION}" ipv4.dns "${DNS_OPENDNS_IPV4}"
                nmcli connection modify "${NM_CONNECTION}" ipv6.dns "${DNS_OPENDNS_IPV6}"
                ;;
            --odf|--opendns-familyshield)
                nmcli connection modify "${NM_CONNECTION}" ipv4.dns "${DNS_OPENDNS_FAMILYSHIELD_IPV4}"
                nmcli connection modify "${NM_CONNECTION}" ipv6.dns "${DNS_OPENDNS_FAMILYSHIELD_IPV6}"
                ;;


            --q9|--quad9)
                nmcli connection modify "${NM_CONNECTION}" ipv4.dns "${DNS_QUAD9_IPV4}"
                nmcli connection modify "${NM_CONNECTION}" ipv6.dns "${DNS_QUAD9_IPV6}"
                ;;

            --check)
                nslookup malware.testcategory.com
                nslookup "n"udity.testcategory.com
                nslookup reddit.com
                nslookup wikipedia.org
                nslookup google.com
                nslookup forcesafesearch.google.com
                ;;


        esac
    done

    if [ -n "${do_commit}" ]; then
        (set -x; nmcli dev reapply "${NM_DEVICE}")
    else
        set +x
        echo "NOTE: Because --commit was not passed, you need to run:"
        #echo "$ #nmcli m & nmcli c down && nmcli c s && nmcli c up"
        echo "$ nmcli dev reapply '${NM_DEVICE}'"
    fi

}

setup_resolvedconf_main "${@}"
