#!/bin/sh

print_help() {
    echo "git-githubreleases.sh <org/repo>"
    echo "git githubreleases.sh <org/repo>"
}



list_github_release_asset_download_urls() {
    _organdrepo=$1
    _jsonpath=
    _jsonpath="./$(echo "$_organdrepo" | sed 's,/,__,g').data.json"

    test -n "${_organdrepo}" || (echo "ERROR: specify an 'org/path'" >&2 && return)
    command -v jq >/dev/null 2>&1 || (echo "ERROR: jq must be installed" >&2 && return)

    (set -x;
    test -f "${_jsonpath}" || curl "https://api.github.com/repos/${_organdrepo}/releases/latest" -o "${_jsonpath}";
    jq "." "${_jsonpath}";
    jq '.assets[] | pick(.size, .browser_download_url, .uploader.html_url, .created_at, .updated_at, .download_count)' "${_jsonpath}"
    jq '.assets[].browser_download_url' "${_jsonpath}")
}


main() {
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
