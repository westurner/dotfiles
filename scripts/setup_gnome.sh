#!/bin/bash


__this=${0}
__file="$(basename "${0}")"

function setup_gnome_print_usage {

echo "${__file} [--bgcolor=] [--gtk-theme=] [--fractional-scaling[=1]] [...] [--all]
"

echo "
   --bgcolor=\#000000
      $ gsettings list-recusively org.gnome.desktop.background
   --gtk-theme=<dark|light|str|Adwaita-Dark|Adwaita:dark>
      $ gsettings get org.gnome.desktop.interface gtk-theme
   --gnome-color-scheme=<prefer-dark|dark|light|default|<str>>
      $ gsettings set org.gnome.desktop.interface color-scheme
   --gnome-accent-color=<default|blue|teal|green|yellow|orange|red|pink|purple|slate>
      $ gsettings set org.gnome.desktop.interface accent-color

   --fractional-scaling=<0|1>
      $ gsettings get org.gnome.mutter experimental-features

   --ungroup-alt-tab=1
      Change keybindings so that [Shift]<Alt><Tab> (default: 1: do not group windows)
      $ dconf write /org/gnome/desktop/wm/keybindings/switch-<applications,switch-windows>[-backward]

   --setup-touchpad
      $ ./setup_gnome_touchpad.sh

   --setup-darkmode
      $ ./setup_darkmode.sh -s true

   --list-keys|--listkeys|--list-keybindings
      List gnome keybindings
   --list-keys-alt-f|--list-keybindings-alt-f
      List gnome alt-f keybindings

   --unbind-alt-f-keys
      unbind gnome keybindings for <Alt>F5, <Alt>F6, <Alt>F7, <Alt>F8, <Alt>F10 
      setup_gnome_unbind_alt_keys
   --reset-alt-f-keys
      reset keybindings set by --unbind-alt-f-keys to gnome defaults
"
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


# TODO: has this changed from prior versions (<42?); how to make backwards compat
#GNOME_THEME_DARK="${GNOME_THEME_DARK:-"Adwaita-dark"}"
GNOME_THEME_DARK="${GNOME_THEME_DARK:-"Adwaita:dark"}"
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
            gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer', 'xwayland-native-scaling']"
            ;;
        0|off|false|False)
            gsettings reset org.gnome.mutter experimental-features
            gsettings get org.gnome.mutter experimental-features
            ;;
    esac
}


function setup_gnome_ungroup_alt_tab {
    dconf write /org/gnome/desktop/wm/keybindings/switch-applications "['<Super>Tab']"
    dconf write /org/gnome/desktop/wm/keybindings/switch-applications-backward "['<Shift><Super>Tab']"
    dconf write /org/gnome/desktop/wm/keybindings/switch-windows "['<Alt>Tab']"
    dconf write /org/gnome/desktop/wm/keybindings/switch-windows-backward "['<Shift><Alt>Tab']"
}

function setup_gnome_list_keybindings {
    local longest_name_len=$(gsettings list-recursively org.gnome.desktop.wm.keybindings \
        | pyline.py 'str(len(w[1]))' \
        | sort -n -r \
        | head -n 1)
    (set +x +v;
        gsettings list-recursively org.gnome.desktop.wm.keybindings \
        | pyline.py '[w[1].ljust('"$longest_name_len"'), *l.split("[",1)[-1].removesuffix("]\n").split(",")] if w[-1] != "[]" else None' -s 1)
}

function setup_gnome_list_keybindings_alt_f {
    setup_gnome_list_keybindings | grep '<Alt>F'
}

function setup_gnome_unbind_alt_keys {
    gsettings set org.gnome.desktop.wm.keybindings unmaximize "['<Super>Down']"  # <Super>Down, <Alt>F5
    gsettings set org.gnome.desktop.wm.keybindings cycle-group-backward "['']"  # <Shift><Alt>F6
    gsettings set org.gnome.desktop.wm.keybindings cycle-group "['']"   # <Alt>F6
    gsettings set org.gnome.desktop.wm.keybindings begin-move "['']"    # <Alt>F7
    gsettings set org.gnome.desktop.wm.keybindings begin-resize "['']"  # <Alt>F8
    gsettings set org.gnome.desktop.wm.keybindings toggle-maximized "['']"  # <Alt>F10

}

function setup_gnome_reset_alt_keys {
    gsettings reset org.gnome.desktop.wm.keybindings unmaximize  #  "['<Super>Down', '<Alt>F5']"
    gsettings reset org.gnome.desktop.wm.keybindings cycle-group    # <Alt>F6
    gsettings reset org.gnome.desktop.wm.keybindings begin-move     # <Alt>F7
    gsettings reset org.gnome.desktop.wm.keybindings begin-resize   # <Alt>F8
    gsettings reset org.gnome.desktop.wm.keybindings cycle-group-backward  # <Shift><Alt>F6
    gsettings reset org.gnome.desktop.wm.keybindings toggle-maximized      # <Alt>F10
}

function setup_gnome_list__TODO {
   gsettings list-recursively | grep color
   gsettings list-recursively | grep ColorChooser
   gsettings list-recursively org.gnome.gnome-system-monitor
   gsettings list-recursively org.gnome.desktop.screensaver
   gsettings list-recursively org.gnome.settings-daemon.plugins.color
}

function setup_gnome_accent_color {
   local _color=$1
   local _recognized_color=0
   case "$_color" in
      default)
         _color=blue;
         _recognized_color=1;
         ;;
      blue|teal|green|yellow|orange|red|pink|purple|slate)
         _recognized_color=1;
         ;;
   esac
   if [ ${_recognized_color} -gt 0 ]; then
      color=$_color
   else
      echo "INFO: unrecognized accent-color: $_color"
      color=$_color
   fi
   (set -x; gsettings set org.gnome.desktop.interface accent-color "${color}")

   #gsettings set org.gnome.desktop.interface accent-color 'blue' # default

   # also, this setting is nearly deprecated fwiu:
   #gsettings set org.gnome.desktop.interface gtk-color-scheme ''
}

function setup_gnome_gtk_color_palette {
gsettings set org.gnome.desktop.interface gtk-color-palette 'black:white:gray50:red:purple:blue:light blue:green:yellow:orange:lavender:brown:goldenrod4:dodger blue:pink:light green:gray10:gray30:gray75:gray90'
}
function _TODO_ {
org.gnome.desktop.screensaver color-shading-type 'solid'
org.gnome.desktop.screensaver primary-color '#3071AE'
org.gnome.desktop.screensaver secondary-color '#000000'
org.gnome.gnome-system-monitor cpu-colors "[(uint32 0, '#e6194B'), (1, '#f58231'), (2, '#ffe119'), (3, '#bfef45'), (4, '#3cb44b'), (5, '#42d4f4'), (6, '#4363d8'), (7, '#911eb4'), (8, '#f032e6'), (9, '#fabebe'), (10, '#ffd8b1'), (11, '#fffac8'), (12, '#aaffc3'), (13, '#469990'), (14, '#000075'), (15, '#e6beff'), (16, '#7999f332bdfd'), (17, '#f3329a827999'), (18, '#79997c2bf332'), (19, '#9fa6f3327999')]"
org.gnome.gnome-system-monitor disk-read-color '#3584e4'
org.gnome.gnome-system-monitor disk-write-color '#e66100'
org.gnome.gnome-system-monitor mem-color '#e01b24'
org.gnome.gnome-system-monitor net-in-color '#3584e4'
org.gnome.gnome-system-monitor net-out-color '#e66100'
org.gnome.gnome-system-monitor swap-color '#33d17a'
org.gnome.settings-daemon.plugins.color night-light-enabled true
org.gnome.settings-daemon.plugins.color night-light-last-coordinates '(91.0, 181.0)'
org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false
org.gnome.settings-daemon.plugins.color night-light-schedule-from 17.0
org.gnome.settings-daemon.plugins.color night-light-schedule-to 6.0
org.gnome.settings-daemon.plugins.color night-light-temperature uint32 2763
org.gnome.settings-daemon.plugins.color recalibrate-display-threshold uint32 0
org.gnome.settings-daemon.plugins.color recalibrate-printer-threshold uint32 0
org.gnome.shell enabled-extensions ['background-logo@fedorahosted.org', 'system-monitor@paradoxxx.zero.gmail.com', 'transparent-gnome-panel@ttomovcik.com', 'just-perfection-desktop@just-perfection', 'clipboard-history@alexsaveau.dev', 'gtk3-theme-switcher@charlieqle', 'launch-new-instance@gnome-shell-extensions.gcampax.github.com', 'true-color-window-invert@frobware.github.com', 'freon@UshakovVasilii_Github.yahoo.com']
org.gtk.Settings.ColorChooser custom-colors "[(0.0069000000000000068, 0.18455370370370361, 0.23000000000000001, 1.0), (0.0, 0.16862745098039217, 0.21176470588235294, 1.0), (0.09763333333333335, 0.25087457627118642, 0.29000000000000004, 1.0), (0.027450980392156862, 0.21176470588235294, 0.25882352941176473, 1.0), (0.49803921580314636, 0.0, 1.0, 1.0), (0.76470588235294112, 0.41568627450980394, 0.59215686274509793, 1.0), (0.66666666666666674, 0.020000000000000021, 0.34696629213483476, 1.0), (0.81666666666666676, 0.80033333333333345, 0.80859176029962565, 1.0)]"
org.gtk.Settings.ColorChooser selected-color "(true, 0.0069000000000000068, 0.18455370370370361, 0.23000000000000001, 1.0)"
org.gtk.gtk4.Settings.ColorChooser custom-colors "[(0.0, 0.40333333611488342, 0.072600029408931732, 1.0), (0.0, 1.0, 0.50980395078659058, 1.0), (0.084066659212112427, 0.25999999046325684, 0.2388879656791687, 1.0), (0.0, 0.70196080207824707, 0.35686275362968445, 1.0), (0.28333333134651184, 0.0, 0.0, 1.0), (0.94901961088180542, 0.0, 0.18039216101169586, 1.0)]"
org.gtk.gtk4.Settings.ColorChooser selected-color "(true, 0.0, 0.40333333611488342, 0.072600029408931732, 1.0)"

}

function main {
    # (set -x; setup_gnome_mutter_fractional_scaling)

    local _cfg_bgcolor=
    local _cfg_gtk_theme=
    local _cfg_fractional_scaling=

    if [ ! -n "${*}" ]; then
        setup_gnome_print_usage
        return 0
    fi

    for arg in "${@}"; do
        case "$arg" in
            -h|--help|help|h) setup_gnome_print_usage; return 0;;
            -v|--verbose) _cfg_verbose=1; set -x -v ;;
        esac
    done
    for arg in "${@}"; do
        case "$arg" in
            --bgcolor) shift; _cfg_bgcolor=$1; shift; ;;

            --gtk-theme) shift; _cfg_gtk_theme=$1; shift; ;;

            --gnome-color-scheme) shift; _cfg_gnome_color_scheme=$1; shift ;;

            --gnome-accent-color) shift; _cfg_gnome_accent_color=$1; shift ;;

            --fractional-scaling) shift; _cfg_fractional_scaling=1 ;;
            --no-fractional-scaling) shift; _cfg_fractional_scaling=0 ;;

            --ungroup-alt-tab) shift; _cfg_ungroup_alt_tab=1 ;;

            --list-keys|--listkeys|--list-keybindings) shift; _cfg_list_keybindings=1 ;;
            --list-keys-alt-f|--list-keybindings-alt-f) shift; _cfg_list_keybindings_alt_f=1 ;;
            --unbind-alt-f-keys) shift; _cfg_unbind_alt_keys=1 ;;
            --reset-alt-f-keys) shift; _cfg_reset_alt_keys=1 ;;

            --setup-touchpad) shift; ./setup_gnome_touchpad.sh "${@}";;
            --setup-darkmode) shift; ./setup_darkmode.sh -s true "${@}";;

            --all) shift;
               _cfg_bgcolor=\#000000;
               _cfg_gtk_theme=dark;
               _cfg_gnome_color_scheme=prefer-dark;
               _cfg_fractional_scaling=1;
               _cfg_ungroup_alt_tab=1;

               #_cfg_list_keybindings=1;
               #_cfg_list_keybindings_alt_f=1;
               _cfg_unbind_alt_keys=1;
               #_cfg_reset_alt_keys=1;
               ;;
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


    if [ -n "${_cfg_list_keybindings}" ]; then
        (set -x; setup_gnome_list_keybindings)
    fi

    if [ -n "${_cfg_list_keybindings_alt_f}" ]; then
        (set -x; setup_gnome_list_keybindings_alt_f)
    fi


    if [ -n "${_cfg_unbind_alt_keys}" ]; then
        (set -x; setup_gnome_unbind_alt_keys)
    fi

    if [ -n "${_cfg_reset_alt_keys}" ]; then
        (set -x; setup_gnome_reset_alt_keys)
    fi

    if [ -n "${_cfg_gnome_accent_color}" ]; then
       (set -x; setup_gnome_accent_color "${_cfg_gnome_accent_color}")
    fi
}

if [ "${BASH_SOURCE}" == "${0}" ]; then
    main "${@}"
fi
