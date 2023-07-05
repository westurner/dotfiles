#!/bin/sh
## setup_gnome_steam_timeout.sh

#
set_default() {
	gsettings set org.gnome.mutter check-alive-timeout 60000
}

set_60() {
	gsettings set org.gnome.mutter check-alive-timeout 60000
}

set_0_no_timeout() {
	gsettings set org.gnome.mutter check-alive-timeout 0
}

SCRIPTNAME=$0
print_help() {
	echo "${SCRIPTNAME} [-h] <60|60forsteam || 0|off || default|on>"
   echo ""
   echo "Set gsettings://org.gnome.mutter/check-alive-timeout = 0 to prevent"
   echo "Gnome from prompting when Steam (and all other apps) are not responding"
   echo ""
}

main() {
	for arg in "${@}"; do
		case "${arg}" in
			-h|--help) print_help; shift;;
		esac
	done
	for arg in "${@}"; do
		case "${arg}" in
			default|on) (set -x; set_default);;
			60|60forsteam) (set -x; set_60);;
			0|off) (set -x; set_0_no_timeout);;
		esac
	done
}

main "${@}"
