#!/bin/sh

# http://get.adobe.com/reader/direct/

DMG="AdbeRdr11004_en_US.dmg"
MNTPATH="./${DMG}.mount"
APPNAME="Adobe Reader.app"
APPPATH="/Applications/${APPNAME}"
URL="http://ardownload.adobe.com/pub/adobe/reader/mac/11.x/11.0.04/en_US/${DMG}"

if [ ! -f "${DMG}" ] || [ "${REINSTALL}" == "true" ]; then
    echo "Downloading: ${URL}"
    curl -SL  --insecure  "${URL}" > $DMG
fi

hdiutil attach \
    -mountpoint "${MNTPATH}" \
    -verify \
    -autofsck \
    -noautoopen \
    "${DMG}"

open "${MNTPATH}/Adobe Reader XI Installer.pkg" && \
    echo "Installed $DMG to $APPNAME"

hdiutil unmount "${MNTPATH}" && \
    rm -fv "${DMG}" 


