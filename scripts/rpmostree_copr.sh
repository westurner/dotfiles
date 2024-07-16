#!/bin/sh

setup_yabridge_copr_repos() {
    _enable patrickl/wine-tkg
    _enable patrickl/wine-mono
    _enable patrickl/mingw-wine-gecko
    _enable patrickl/vkd3d
    _enable patrickl/wine-dxvk
    _enable patrickl/winetricks
    _enable patrickl/yabridge
    _enable patrickl/libcurl-gnutls  
}

DEFAULT_FEDORA_VERSION="40"

download_copr_repo_file() {
    url="${1}"
    userrepo="${1}"
    fcver="${2:-"${DEFAULT_FEDORA_VERSION}"}"
    if [ -z "${url}" ] || [ -z "${userrepo}" ]; then
        echo "ERROR: user/repo must be specified"
        return 2
    fi
    # TODO url.startswith("https://") or "http://"
    if (echo "${url}" | grep -E '^https?://'); then
        echo "ERROR: TODO: parse the URL automatically. Try this form: 'username/reponame'"
        return 3
    fi
    
    #https://copr.fedorainfracloud.org/coprs/patrickl/yabridge/repo/fedora-40/patrickl-yabridge-fedora-40.repo
    repofilestr=$(echo "${userrepo}" | sed 's/\//-/g')
    repofilename="${repofilestr}-fedora-${fcver}.repo"
    repourl="https://copr.fedorainfracloud.org/coprs/${userrepo}/repo/fedora-${fcver}/${repofilename}"
    echo "repourl='$repourl'"
    echo "wget '$repourl' -O '${repofilename}"
    echo "sudo cp -v '${repofilename}' /etc/yum/yum.repos.d/"
}

_enable() {
    download_copr_repo_file "${@}"
}

main() {
    for arg in "${@}"; do
        case "$arg" in
            -h|--help|help)
                _print_ussage
                ;;
            -v|--verbose)
                set -x -v
                ;;
        esac
    done
    for arg in "${@}"; do
        case "$arg" in
            enable)
                shift;
                _enable "${@}"
                ;;
            todo|TODO)
                setup_yabridge_copr_repos "${@}"
                ;;
        esac    
    done
}

#main
test_main__setup_yabridge() {
    echo "1"
    main enable 
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "$0" ]; then
    main "${@}"
fi

