#!/bin/sh

## from: cat /etc/xdg/autostart/*.desktop | grep ^Exec | pyline 'l[5:] + " &"'
## See also: gnome-session

abrt-applet &
/usr/libexec/at-spi-bus-launcher --launch-immediately &
/usr/libexec/caribou &
/usr/libexec/evolution/evolution-alarm-notify &
/usr/libexec/gnome-initial-setup-copy-worker &
/usr/libexec/gnome-initial-setup --existing-user &
/usr/bin/gnome-keyring-daemon --start --components=gpg &
/usr/bin/gnome-keyring-daemon --start --components=pkcs11 &
/usr/bin/gnome-keyring-daemon --start --components=secrets &
/usr/bin/gnome-keyring-daemon --start --components=ssh &
gnome-screensaver &
/usr/libexec/gnome-settings-daemon-localeexec &
/usr/bin/gnome-software --gapplication-service &
/usr/libexec/gnome-user-share-obexpush &
/usr/libexec/gnome-welcome-tour &
gsettings-data-convert &
nautilus -n &
nvidia-settings -l &
orca &
start-pulseaudio-x11 &
/usr/bin/seapplet &
/usr/bin/spice-vdagent &
/usr/libexec/tracker-extract &
/usr/libexec/tracker-miner-apps &
/usr/libexec/tracker-miner-fs &
/usr/libexec/tracker-miner-user-guides &
gdbus call -e -d org.freedesktop.DBus -o /org/freedesktop/DBus -m org.freedesktop.DBus.StartServiceByName org.freedesktop.Tracker1 0 &
xdg-user-dirs-gtk-update &
/usr/bin/vmware-user-suid-wrapper &
abrt-apple
