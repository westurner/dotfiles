#!/bin/sh

#GNOME_DEFAULT_BACKGROUND_COLOR='rgb(0, 0, 0)'
GNOME_DEFAULT_BACKGROUND_COLOR='#000000'

function set_gnome_background_to_solid_color {
    _background_color="${1}"
    if [ -z "${_background_color}" ]; then
        echo "You must specify a background color as "'$1'
	exit 2
    fi
    gsettings set org.gnome.desktop.background picture-uri ''
    gsettings set org.gnome.desktop.background primary-color "${_background_color}"
    return
}

_THIS_FILE="${0}"
_THIS=$(basename "${0}")

function print_help {
    echo "Usage: ${_THIS}"' [rgb(0,0,0)|\#000000]"'
    echo 'Set the gnome background to a solid color'
    echo ""
    echo "Examples:"
    echo ""
    echo " $ ${_THIS} default      -- set the background to "'$GNOME_DEFAULT_BACKGROUND_COLOR'"=${GNOME_DEFAULT_BACKGROUND_COLOR}"
    echo " $ ${_THIS} black        -- set the background to black"
    echo " $ ${_THIS} \#000000     -- set the background to black"
    echo " $ ${_THIS} 'rgb(0,0,0)' -- set the background to black"
    echo ""
    return 0
}

function main {
    args="${@}"
    if [ -z "${args[*]}" ]; then
        print_help;
	return 1
    fi
    for arg in "${args[@]}"; do
        case "${arg}" in
            -h|--help)
		shift
	        print_help;
		exit;
		;;
	     black)
		set_gnome_background_color="#000000"
		;;
	     default)
		set_gnome_background_color="${GNOME_DEFAULT_BACKGROUND_COLOR}"
		;;
	esac
    done
    (set -x; set_gnome_background_to_solid_color "${1}")
    return
}

main "${@}"
