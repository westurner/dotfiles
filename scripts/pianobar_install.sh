#!/bin/sh
###
# Install Pianobar

# Deps
apt-get install libao-dev libmad0-dev libgnutls-dev libfaad-dev

# ... Configure libao to work with pulseaudio
[ -d '/etc/pulse' ] && pulse_installed=1
[ -d '~/.pulse' ] && pulse_installed=1
if [ "$pulse_installed" -eq "1" ]; then
    sed -i 's/default_driver=alsa/default_driver=pulse/g' /etc/libao.conf
fi

# Fetch and build pianobar
git clone https://github.com/PromyLOPh/pianobar.git
cd pianobar
make && ./pianobar
