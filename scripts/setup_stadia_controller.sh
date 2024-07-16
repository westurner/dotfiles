#!/usr/bin/env bash

# References:
# - https://support.google.com/stadia/answer/13067284?visit_id=638096509631449334-3341588219&p=controllerconnect&rd=1#zippy=%2Cim-on-a-linux-based-computer-and-cant-update-my-stadia-controller-help

setup_udev() {
{ cat <<EOF
# SDP protocol
KERNEL=="hidraw*", ATTRS{idVendor}=="1fc9", MODE="0666"
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1fc9", MODE="0666"
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0d28", MODE="0666"
# Flashloader
KERNEL=="hidraw*", ATTRS{idVendor}=="15a2", MODE="0666"
# Controller
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="18d1", MODE="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="18d1", ATTRS{idProduct}=="9400", MODE="0660", TAG+="uaccess"
EOF
} | sudo tee /etc/udev/rules.d/70-stadiacontroller-flash.rules
}

restart_udev() {
    sudo udevadm control --reload-rules && sudo udevadm trigger
}


_udev_logs() {
  # TODO
  return
}

setup_udev_main() {
    (set -x;
        setup_udev
        restart_udev)
}

setup_udev_main
