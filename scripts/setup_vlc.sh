#!/bin/sh

VERSION="2.1.1"
DMG="vlc-${VERSION}.dmg"
MNTPATH="./${DMG}.mount"
APPNAME="VLC.app"
APPPATH="/Applications/${APPNAME}"
URL="https://get.videolan.org/vlc/${VERSION}/macosx/${DMG}"

if [ ! -f "${DMG}" ] || [ "${REINSTALL}" == "true" ]; then
    echo "Downloading: ${URL}"
    curl -SL "${URL}" > $DMG
fi

mkdir -p $MNTPATH

hdiutil attach \
    -mountpoint "${MNTPATH}" \
    -verify \
    -autofsck \
    -noautoopen \
    "${DMG}"


sudo cp -R "${MNTPATH}/${APPNAME}" "${APPPATH}.new" && \
    sudo rm -rf "${APPPATH}" && \
    sudo mv "${APPPATH}.new" "${APPPATH}" && \
    echo "Installed $DMG to $APPNAME" && \
    rm -fv "${DMG}"

hdiutil unmount "${MNTPATH}" \
    && rm -rfv "${MNTPATH}"

