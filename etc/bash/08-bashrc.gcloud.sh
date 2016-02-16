
### bashrc.gcloud.sh

function _setup_google_cloud {
    # _setup_google_cloud() -- configure gcloud $PATH and bash completions
    #   $1 (str): default:~/google-cloud-sdk (GCLOUD_BASEPATH)
    export GCLOUD_BASEPATH="${1:-"${HOME}/google-cloud-sdk"}"

    #The next line updates PATH for the Google Cloud SDK.
    source "${GCLOUD_BASEPATH}/path.bash.inc"

    #The next line enables bash completion for gcloud.
    source "${GCLOUD_BASEPATH}/completion.bash.inc"
}


function _get_APPENGINESDK_PATH {
    local _appenginesdk_path="${1}"
    local _APPENGINESDK_PATH=
    if [ -n "${_appenginesdk_path}" ]; then
        _APPENGINESDK_PATH="${1}"
    else
        local _APPENGINESDK_BASEPATH=
        if [ -n "${GCLOUD_BASEPATH}" ]; then
            _APPENGINESDK_BASEPATH="${GCLOUD_BASEPATH}/platform"
        else
            _APPENGINESDK_BASEPATH="/usr/local"
        fi
        _APPENGINESDK_PATH="${_APPENGINESDK_BASEPATH}/google_appengine"
    fi
    echo "${_APPENGINESDK_PATH}"
}

function _setup_google_appenginesdk {
    # _setup_google_cloud() -- configure gcloud $PATH and bash completions
    #   $1 (str): default:~/google-cloud-sdk (GCLOUD_BASEPATH)
    export APPENGINESDK_PATH="$(_get_APPENGINESDK_PATH "${1}")"
    PATH_prepend "${APPENGINESDK_PATH}"
}

function _unsetup_google_appenginesdk {
    # _setup_google_cloud() -- configure gcloud $PATH and bash completions
    if [ -n "${APPENGINESDK_PATH}" ]; then
        PATH_remove "${APPENGINESDK_PATH}"
    fi
    unset APPENGINESDK_PATH
}
