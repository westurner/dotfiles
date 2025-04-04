#!/bin/sh

function print_help() {
    echo "git-githubreleases.sh <org/repo>"
    echo "git githubreleases.sh <org/repo>"
}



function list_github_release_asset_download_urls() {
    local organdrepo=$1;
    local jsonpath="./$(echo "$organdrepo" | sed 's,/,__,g').data.json"
    test -n "${organdrepo}" || (echo "ERROR: specify an 'org/path'" >&2 && return)
    type -p jq || (echo "ERROR: jq must be installeed" >&2 && return)

    (set -x;
    test -f "${jsonpath}" || curl "https://api.github.com/repos/${organdrepo}/releases/latest" -o "${jsonpath}";
    jq "." "${jsonpath}";
    jq '.assets[] | pick(.size, .browser_download_url, .uploader.html_url, .created_at, .updated_at, .download_count)' "${jsonpath}"
    jq '.assets[].browser_download_url' "${jsonpath}")
}


function main() {
    if ! test -n "${*}"; then
        print_help
        return
    fi
    for arg in "${@}"; do
        case "${arg}" in
            -h|--help|help)
                print_help
                return;
        esac
    done
    list_github_release_asset_download_urls "${@}"
}

echo '$@='"${@}"
main "${@}"
