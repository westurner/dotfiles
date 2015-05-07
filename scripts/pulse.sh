#!/bin/bash -x

## pulse.sh -- PulseAudio RTP server/client setup / configuration

export PULSE_SERVER=${PULSE_SERVER:-"10.2.2.2"}
SOUNDCHECK="/usr/share/sounds/alsa/Front_Center.wav"


function pulse_install_client() {
    apt-get install -y pulseaudio pulseaudio-utils paman paprefs pavucontrol
    return
}

function pulse_install_server() {
    apt-get install -y pulseaudio
    CONF="/etc/pulse/default.pa"
    DEFAULT="/etc/default/pulseaudio"
    sed -i 's/PULSEAUDIO_SYSTEM_START=0/PULSEAUDIO_SYSTEM_START=1/g' "$DEFAULT"
    sed -i 's/DISALLOW_MODULE_LOADING=0/DISALLOW_MODULE_LOADING=1/g' "$DEFAULT"
    sed -i 's/#load-module module-native-protocol-tcp/load-module module-native-protocol-tcp/g' "$CONF"
    sed -i 's/#load-module module-rtp-recv/load-module module-rtp-recv/g' "$CONF"
    /etc/init.d/pulseaudio restart
    return
}


function pulse_start() {
    pax11publish -e -r
    pulseaudio --start --log-target=syslog
    pacmd load-module module-native-protocol-tcp
    pacmd load-module module-device-manager
    pax11publish -e -S $PULSE_SERVER
    pulse_status
    pacat "$SOUNDCHECK"
    pavucontrol 2>&1 &
    return
}

function pulse_stop() {
    pax11publish -e -r
    sleep 1
    pulseaudio -k
    sleep 2
    pulse_status
    return
}

function pulse_status(){
    ps aufx | grep pulse
    return
}

function pulse_help() {
    echo "usage: $0 <install_server|install_client|start|status|stop|restart>"

}

function pulse_main() {
    case "$1" in
        install_server)
            pulse_opts_install_server=true;
            ;;
        install)
            pulse_opts_install_deb=true;
            ;;
        start)
            pulse_opts_start=true;
            ;;
        status)
            pulse_opts_status=true;
            ;;
        stop)
            pulse_opts_stop=true;
            ;;
        restart)
            pulse_opts_restart=true;
            ;;
        *)
            pulse_opts_help=true;
            ;;
    esac
    if [ -n "${pulse_opts_help}" ]; then
        pulse_help
        return
    fi
    if [ -n "${pulse_opts_install_server}" ]; then
        pulse_install_server
        return
    fi
    if [ -n "${pulse_opts_install_deb}" ]; then
        pulse_install_deb
        return
    fi
    if [ -n "${pulse_opts_start}" ]; then
        pulse_start
        return
    fi
    if [ -n "${pulse_opts_status}" ]; then
        pulse_status
        return
    fi
    if [ -n "${pulse_opts_stop}" ]; then
        pulse_stop
        return
    fi
    if [ -n "${pulse_opts_restart}" ]; then
        pulse_stop
        sleep 1
        pulse_start
        return
    fi
    return
}

if [ "${BASH_SOURCE}" == "${0}" ]; then
    pulse_main ${@}
    exit
fi
