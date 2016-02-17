
### bashrc.gcloud.sh

function _setup_gcloudsdk {
    # _setup_gcloudsdk() -- configure gcloud $PATH and bash completions
    #   $1 (str): default:~/google-cloud-sdk (GCLOUDSDK_PREFIX)
    export GCLOUDSDK_PREFIX="${1:-"$(_get_GCLOUDSDK_PREFIX)"}"

    #The next line updates PATH for the Google Cloud SDK.
    source "${GCLOUDSDK_PREFIX}/path.bash.inc"

    #The next line enables bash completion for gcloud.
    source "${GCLOUDSDK_PREFIX}/completion.bash.inc"
}

function _unsetup_gcloudsdk {
    # _unsetup_gcloudsdk() -- unset GCLOUDSDK_PREFIX
    unset GCLOUDSDK_PREFIX
    # XXX: PATH_remove <...>
}

function _get_GCLOUDSDK_PREFIX {
    # _get_GCLOUDSDK_PREFIX     -- get GCLOUDSDK_PREFIX
    #   $1 (str): default:~/google-cloud-sdk (GCLOUDSDK_PREFIX)
    local _GCLOUDSDK_PREFIX="${GCLOUDSDK_PREFIX:-"${HOME}/google-cloud-sdk"}"
    echo "${_GCLOUDSDK_PREFIX}"
}

function _get_APPENGINESDK_PREFIX {
    # _get_APPENGINESDK_PREFIX -- get APPENGINESDK_PREFIX
    local _appenginesdk_prefix="${1:-"${APPENGINESDK_PREFIX}"}"
    local _APPENGINESDK_PREFIX=
    if [ -n "${_appenginesdk_prefix}" ]; then
        _APPENGINESDK_PREFIX="$(_get_APPENGINESDK_PREFIX)"
    else
        local _APPENGINESDK_BASEPATH=
        local _GCLOUDSDK_PREFIX="$(_get_GCLOUDSDK_PREFIX)"
        if [ -n "${_GCLOUDSDK_PREFIX}" ]; then
            _APPENGINESDK_BASEPATH="${_GCLOUDSDK_PREFIX}/platform"
        else
            _APPENGINESDK_BASEPATH="/usr/local"
        fi
        _APPENGINESDK_PREFIX="${_APPENGINESDK_BASEPATH}/google_appengine"
    fi
    echo "${_APPENGINESDK_PREFIX}"
}

function _setup_appenginesdk {
    # _setup_appenginesdk() -- config GCLOUDSDK*, APPENGINESDK_PREFIX, PATH
    #   $1 (str): default:~/google-cloud-sdk/platform/google_appengine
    #             default:/usr/local/google_appengine
    #             ${APPENGINESDK_PREFIX}

    local _GCLOUDSDK_PREFIX="$(_get_GCLOUDSDK_PREFIX)"
    if [ -d "${_GCLOUDSDK_PREFIX}" ]; then
        _setup_appenginesdk
    fi
    export APPENGINESDK_PREFIX="${1:-"$(_get_APPENGINESDK_PREFIX "${1}")"}"
    PATH_prepend "${APPENGINESDK_PREFIX}"
}

function _unsetup_appenginesdk {
    # _setup_gcloudsdk() -- PATH_remove ${APPENGINESDK_PREFIX}
    if [ -n "${APPENGINESDK_PREFIX}" ]; then
        PATH_remove "${APPENGINESDK_PREFIX}"
    fi
    unset APPENGINESDK_PREFIX
}
