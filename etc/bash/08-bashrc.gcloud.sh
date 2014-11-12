
### bashrc.gcloud.sh

_setup_google_cloud() {
    # _setup_google_cloud() -- configure gcloud $PATH and bash completions
    export _GCLOUD_PREFIX="/srv/wrk/google-cloud-sdk"

    #The next line updates PATH for the Google Cloud SDK.
    source "${_GCLOUD_PREFIX}/path.bash.inc"

    #The next line enables bash completion for gcloud.
    source "${_GCLOUD_PREFIX}/completion.bash.inc"
}
