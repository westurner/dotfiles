#!/bin/sh

if [ -d '/etc/apt' ]; then
    sudo add-apt-repository ppa:kilian/f.lux
    sudo apt-get update
    sudo apt-get install fluxgui
fi
if [ -d '/Applications' ]; then
    # http://justgetflux.com/dlmac.html
    URL='https://justgetflux.com/mac/Flux.zip'
    curl -fsSL "${URL}" > Flux.zip && \
    unzip Flux.zip && \
    sudo cp -Rf Flux.app /Applications/ && \
    rm -rf Flux.app Flux.zip
fi

