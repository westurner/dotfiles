#!/bin/sh

VERSION="25.0.1"

DMG="Firefox ${VERSION}.dmg"
MNTPATH="./${DMG}.mount"
APPNAME="Firefox.app"
APPPATH="/Applications/${APPNAME}"
URL="https://download.mozilla.org/?product=firefox-${VERSION}&os=osx&lang=en-US"


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

