#!/bin/sh

function pwd_serve_and_then_close_with_python {
    local directory="${__DOTFILES}/scripts"
    local port=18088
    local url="http://localhost:${port}/"
    local closeafter=30
    local openbrowser=1

    python -m http.server -d "${directory}" "${port}" &
    httpserverpid=$!

    if [ -n "$openbrowser" ]; then
        pwd_open &
    fi

    sleep "${closeafter}";
    kill "${httpserverpid}"
}

function pwd_open {
    xdg-open "${url}/pwd.html" &
}

thisfilepath=$0
thisfiledir=$(dirname "$0")

function pwd_serve_and_then_close_with_bash {
    local PORT="${1:-18080}"
    local FILE="${2:-"${thisfiledir}/pwd.html"}"
    local certfile=
    local keyfile=

    function send_response {
        local content_length=$(wc -c < "$FILE")
        local response="HTTP/1.0 200 OK\r\nContent-Type: text/html\r\nContent-Length: $content_length\r\nConnection: close\r\n\r\n$(cat "$FILE")"
        echo -ne "$response"
    }

    nc_cert_opts="-C '${certfile}' -K '${keyfile}'"
    nc_cert_opts=

    nc -v -kl "127.0.0.22:${PORT}" ${nc_cert_opts} | send_response &
    ncprocid=$!

    if [ -n "$openbrowser" ]; then
        pwd_open &
    fi

    sleep 30
    kill "${ncprocid}"

}

function pwd_usage {
    grep -E '^\s*-.*)$' "${thisfilepath}"
}

function pwd_main {

    if [ ! -n "${*}" ]; then
        pwd_main --python
        #pwd_main --bash
        return
    fi

    for arg in "${@}"; do
        case "${arg}" in
            -h|--help|help)
                pwd_usage
                return 0
                ;;
        esac
    done

    local open_browser_too=
    for arg in "${@}"; do
        case "${arg}" in
            py|--py|python|--python)
                (set -x; pwd_serve_and_then_close_with_python)
                open_browser_too=true
                ;;
            sh|--sh|bash|--bash)
                (set -x; pwd_serve_and_then_close_with_bash)
                open_browser_too=true
                ;;
            xdg|xdg-open)
                pwd_open
                ;;
            *)
                echo "ERROR: unrecognized argument: arg=${arg}"
        esac
    done
    if [ -n "${open_browser_too}" ]; then
        pwd_open
    fi
}

pwd_main "${@}"
