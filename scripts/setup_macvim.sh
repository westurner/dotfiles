#!/bin/sh
# https://code.google.com/p/macvim/
# https://github.com/b4winckler/macvim/releases


SNAPSHOT="72"
FILENAME="MacVim-snapshot-${SNAPSHOT}-Mavericks.tbz"
URL="https://github.com/b4winckler/macvim/releases/download/snapshot-${SNAPSHOT}/${FILENAME}"
APPNAME="MacVim.app"
APPPATH="/Applications/${APPNAME}"
MNTPATH="MacVim-snapshot-${SNAPSHOT}"

if [ ! -f "${FILENAME}" ] || [ "${REINSTALL}" == "true" ]; then
    echo "Downloading: ${URL}"
    curl -SL "${URL}" > ${FILENAME}
fi

tar xjf "${FILENAME}" && \
    sudo cp -R "${MNTPATH}/${APPNAME}" "${APPPATH}.new" && \
    sudo rm -rf "${APPPATH}" && \
    sudo mv "${APPPATH}.new" "${APPPATH}" && \
    echo "Installed $FILENAME to $APPNAME" && \
    rm -rfv "${FILENAME}" "${MNTPATH}"
