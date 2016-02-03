
### bashrc.gcloud.sh

_setup_google_cloud() {
    # _setup_google_cloud() -- configure gcloud $PATH and bash completions
    export GCLOUD_BASEPATH="${HOME}/google-cloud-sdk"
    #export GCLOUD_BASEPATH="/srv/wrk/google-cloud-sdk"

    #The next line updates PATH for the Google Cloud SDK.
    source "${GCLOUD_BASEPATH}/path.bash.inc"

    #The next line enables bash completion for gcloud.
    source "${GCLOUD_BASEPATH}/completion.bash.inc"
}
