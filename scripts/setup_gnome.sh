#!/bin/bash


__this=${0}
__file="$(basename "${0}")"

function setup_gnome_print_usage {

echo "${__file} [--bgcolor=] [--gtk-theme=] [--fractional-scaling[=1]] [--all]"

echo "   --bgcolor=\#000000
              $ gsettings list-recusively org.gnome.desktop.background"
echo "   --gtk-theme=dark|light|str|Adwaita-Dark
              $ gsettings get org.gnome.desktop.interface gtk-theme"
echo "   --fractional-scaling=0|1
              $ gsettings get org.gnome.mutter experimental-features"
echo "   --ungroup-alt-tab=1"
echo '
## Shell Functions

setup_gnome_background_color
setup_gnome_gtk_theme <dark|light|<str>|Adwaita-dark>
setup_gnome_mutter_fractional_scaling

setup_gnome_ungroup_alt_tab
'
}

GNOME_SOLID_COLOR_BACKGROUND_PATH_PREFIX=$HOME/Pictures/_background

function write_svg_bgcolor {
  local _bgcolor=$1  # NOTE: XSS risk
  local _bgpath=${2:-"${GNOME_SOLID_COLOR_BACKGROUND_PATH_PREFIX}.${_bgcolor}.svg"}
  local _width=100
  local _height=100
  echo '<?xml version="1.0" encoding="UTF-8"?><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 '"${_width} ${_height}"'"><rect x="0" y="0" width="'"${_width}"'" height="'"${_height}"'" fill="'"${_bgcolor}"'"/></svg>' > "${_bgpath}"
}

function setup_gnome_background_color {
  local _bgcolor="${1:-"#1F2325"}"
  local _bgpath="${GNOME_SOLID_COLOR_BACKGROUND_PATH_PREFIX}.${_bgcolor}.svg"
  write_svg_bgcolor "${_bgcolor}" "${_bgpath}"
  gsettings set org.gnome.desktop.background picture-uri "file://${_bgpath}"
  gsettings set org.gnome.desktop.background picture-uri-dark "file://${_bgpath}"
  gsettings set org.gnome.desktop.background picture-options "scaled"
  gsettings set org.gnome.desktop.background primary-color "${_bgcolor}"
  gsettings set org.gnome.desktop.background secondary-color "${_bgcolor}"
  gsettings set org.gnome.desktop.background color-shading-type "solid"

  # system-wide gnome background
  # https://help.gnome.org/admin/system-admin-guide/stable/desktop-background.html.en
}


GNOME_THEME_DARK="${GNOME_THEME_DARK:-"Adwaita-dark"}"
GNOME_THEME_LIGHT="${GNOME_THEME_LIGHT:-"Adwaita"}"
function setup_gnome_gtk_theme {
    #  setup_gnome_gtk_theme <dark|light|<str>|Adwaita-dark>
    local theme=$1
    case "$theme" in
        dark)
            theme="${GNOME_THEME_DARK}";;
        light)
            theme="${GNOME_THEME_LIGHT}"
    esac
    (set -x;
    gsettings set org.gnome.desktop.interface gtk-theme "${theme}")
}

GNOME_COLOR_SCHEME_DARK="${GNOME_COLOR_SCHEME_DARK:-"prefer-dark"}"
GNOME_COLOR_SCHEME_LIGHT="${GNOME_COLOR_SCHEME_LIGHT:-"default"}"
function setup_gnome_color_scheme {
    #  setup_gnome_color_scheme <dark|light|<str>|prefer-dark|default>
    local theme=$1
    case "$theme" in
        dark)
            theme="${GNOME_COLOR_SCHEME_DARK}";;
        light)
            theme="${GNOME_COLOR_SCHEME_LIGHT}";;
    esac
    (set -x;
    gsettings set org.gnome.desktop.interface color-scheme "${theme}")
}

function setup_gnome_mutter_fractional_scaling {
    #  setup_gnome_mutter_fractional_scaling <1|0>
    # See also: `dnf install -y gnome-tweaks` for fractional font scaling
    # https://gitlab.gnome.org/GNOME/gnome-control-center/-/issues/1351
    #
    local overwrite_gsettings_mutter_experimental_features=${1:-"1"}

    case "${overwrite_gsettings_mutter_experimental_features}" in
        1|on|true|True)
            gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
            ;;
        0|off|false|False)
            gsettings get org.gnome.mutter experimental-features
            gsettings set org.gnome.mutter experimental-features "[]" # TODO: -= "['scale-monitor-framebuffer']"
            ;;
    esac
}


function setup_gnome_ungroup_alt_tab {
    dconf write /org/gnome/desktop/wm/keybindings/switch-applications "['<Super>Tab']"
    dconf write /org/gnome/desktop/wm/keybindings/switch-applications-backward "['<Shift><Super>Tab']"
    dconf write /org/gnome/desktop/wm/keybindings/switch-windows "['<Alt>Tab']"
    dconf write /org/gnome/desktop/wm/keybindings/switch-windows-backward "['<Shift><Alt>Tab']"
}


function main {
    # (set -x; setup_gnome_mutter_fractional_scaling)

    local _cfg_bgcolor=
    local _cfg_gtk_theme=
    local _cfg_fractional_scaling=

    for arg in "${@}"; do
        case "$arg" in
            -h|--help) setup_gnome_print_usage; return 0;;
            -v|--verbose) _cfg_verbose=1; set -x -v ;;
        esac
    done
    for arg in "${@}"; do
        case "$arg" in
            --bgcolor) shift; _cfg_bgcolor=$1 ;;
            --gtk-theme) shift; _cfg_gtk_theme=$1 ;;
            --gnome-color-scheme) shift; _cfg_gnome_color_scheme=$1 ;;
            --fractional-scaling) shift; _cfg_fractional_scaling=1 ;;
            --no-fractional-scaling) shift; _cfg_fractional_scaling=0 ;;
            --ungroup-alt-tab) shift; _cfg_ungroup_alt_tab=1 ;;
        esac
    done

    for arg in "${@}"; do
        case "$arg" in
            --dark)
                _cfg_bgcolor="${_cfg_bgcolor:-"\#000000"}";
                _cfg_gtk_theme="${_cfg_gtk_theme:-"dark"}";
                _cfg_gnome_color_scheme="${_cfg_gnome_color_scheme:-"prefer-dark"}";
                ;;
            --light)
                _cfg_bgcolor="${_cfg_bgcolor:-"\#422222"}";
                _cfg_gtk_theme="${_cfg_gtk_theme:-"light"}";
                _cfg_gnome_color_scheme="${_cfg_gnome_color_scheme:-"default"}";
                ;;
        esac
    done

    if [ -n "${_cfg_gtk_theme}" ]; then
        setup_gnome_gtk_theme "${_cfg_gtk_theme}"
    fi
    if [ -n "${_cfg_bgcolor}" ]; then
        setup_gnome_background_color "${_cfg_bgcolor}";
    fi
    if [ -n "${_cfg_gnome_color_scheme}" ]; then
        setup_gnome_color_scheme "${_cfg_gnome_color_scheme}";
    fi

    if [ -n "${_cfg_fractional_scaling}" ]; then
        setup_gnome_mutter_fractional_scaling "${_cfg_fractional_scaling}";
    fi

    if [ -n "${_cfg_ungroup_alt_tab}" ]; then
        (set -x; setup_gnome_ungroup_alt_tab)
    fi
}

if [ "${BASH_SOURCE}" == "${0}" ]; then
    main "${@}"
fi
