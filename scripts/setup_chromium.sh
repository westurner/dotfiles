#!/bin/sh

if [ -d '/etc/apt' ]; then
    sudo apt-get-install chromium-codecs-ffmpeg-extra
fi
if [ -d '/Applications' ]; then
    ZIP="chromium.zip"
    URL="https://download-chromium.appspot.com/dl/Mac"
    APPFOLDER="chrome-mac"

    if [ ! -f "${ZIP}" ] || [ "${REINSTALL}" == "true" ]; then
        echo "Downloading: ${URL}"
        curl -SL "${URL}" > $ZIP
    fi

    unzip $ZIP

    # TODO
fi
