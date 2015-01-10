#!/bin/sh

dbus-send --system --type=method_call --dest=org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.DBus.Properties.Set string:org.freedesktop.NetworkManager string:WirelessEnabled variant:boolean:false
