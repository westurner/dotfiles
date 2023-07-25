#!/bin/sh
## setup_steam.sh

_setup_steam() {
	install_steam
	set_uinput_permissions
}

get_uinput_permissions() {
	(set -x; ls -al /dev/uinput; getfacl /dev/uinput)
}

set_uinput_permissions() {
	user=${1:$USER}
	sudo setfacl -m "u:${user}:rw" /dev/uinput 
}

install_steam() {
	sudo dnf install -y steam-devices flatpak
	# flatpak add flathub
	sudo flatpak install -y com.valvesoftware.Steam
}

SCRIPTNAME=$0
print_help() {
	echo "${0} [-h] <install | getperms | setperms | run>"
   echo ""
   echo "Install steam with flatpak (with Fedora / dnf)"
   echo ""
   echo '  install -- `dnf install -y steam-devices flatpak; flatpak install -y com.valvesoftware.Steam`'
   echo "  getperms            -- get the permissions on /dev/uinput"
   echo "  setperms [-u $USER] -- set rw permissions on /dev/uinput for the current user"
   echo '  run -- launch Steam; `flatpak run com.valvesoftware.Steam`'
   echo ""
   echo "Usage:"
   echo ""
   echo "${0} install setperms  # Install steam and set permissions for the current user"
   echo "${0} setperms          "'# Set permissions for $1 or $USER with access to the sudo-installed flatpak'
   echo "${0} run               # Run steam"
   echo ""
}

main() {
	for arg in "${@}"; do
		case "${arg}" in
			-h|--help) print_help; shift; return 0;;
		esac
	done
	for arg in "${@}"; do
		case "${arg}" in
			-u|--user)
				shift
				_user=$1
				shift
				echo '$_user='"$_user"
				;;
		esac
	done
	if [ -z "${*}" ]; then
		print_help
		return 0
	fi
	for arg in "${@}"; do
		case "${arg}" in
			install) _setup_steam;;
			getperms|getperm) get_uinput_permissions;;
			setperms|setperm)
				get_uinput_permissions;
				set_uinput_permissions "${_user:-${USER}}";
				get_uinput_permissions;
				;;
			run|runflatpak)
				flatpak run com.valvesoftware.Steam;
				;;
			*) echo "ERROR: Unknown option: '${arg}'"; print_help; return 1;;
		esac
	done
}

test_main() {
	main -h
	main install
	main getperms
	main setperms
}

#if [ -z "${BASH_SOURCE}" ]; then
main "${@}"
#fi
