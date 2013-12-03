#!/bin/sh

# https://www.piriform.com/ccleaner/download

VERSION="107"
DMG="CCMacSetup${VERSION}.dmg"
MNTPATH="./${DMG}.mount"
APPNAME="CCleaner.app"
APPPATH="/Applications/${APPNAME}"
URL="http://download.piriform.com/mac/${DMG}"

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

