_setup_google_cloud() {
    _GCLOUD_PREFIX="/srv/wrk/google-cloud-sdk"
    #  _setup_google_cloud  -- configure PATH and bash completions for
    #   Google Cloud"

    # The next line updates PATH for the Google Cloud SDK.
    source "${_GCLOUD_PREFIX}/path.bash.inc"

    # The next line enables bash completion for gcloud.
    source "${_GCLOUD_PREFIX}/completion.bash.inc"
}
