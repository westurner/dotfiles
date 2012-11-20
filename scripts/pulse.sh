#!/bin/bash -x

export PULSE_SERVER=10.1.4.1
SOUNDCHECK="/usr/share/sounds/alsa/Front_Center.wav"


install_client() {
    apt-get install -y pulseaudio pulseaudio-utils paman paprefs pavucontrol
}

install_server() {
    apt-get install -y pulseaudio
    CONF="/etc/pulse/default.pa"
    DEFAULT="/etc/default/pulseaudio"
    sed -i 's/PULSEAUDIO_SYSTEM_START=0/PULSEAUDIO_SYSTEM_START=1/g' "$DEFAULT"
    sed -i 's/DISALLOW_MODULE_LOADING=0/DISALLOW_MODULE_LOADING=1/g' "$DEFAULT"
    sed -i 's/#load-module module-native-protocol-tcp/load-module module-native-protocol-tcp/g' "$CONF"
    sed -i 's/#load-module module-rtp-recv/load-module module-rtp-recv/g' "$CONF"
    /etc/init.d/pulseaudio restart
}


start() {
    pax11publish -e -r
    pulseaudio --start --log-target=syslog
    pacmd load-module module-native-protocol-tcp
    pacmd load-module module-device-manager
    pax11publish -e -S $PULSE_SERVER
    status
    pacat "$SOUNDCHECK"
    pavucontrol 2>&1 &
}

stop() {
    pax11publish -e -r
    sleep 1
    pulseaudio -k
    sleep 2
    status
}

status(){
    ps aufx | grep pulse
}

case "$1" in
    install_server) install_server ;;
    install) install_deb ;;
    start) start ;;
    status) status ;;
    stop) stop ;;
    *) echo "usage: $0 <install_server|install_client|start|status|stop>" ;;
esac

