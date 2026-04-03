#!/bin/sh
#
# Shell functions to control dark/light mode theme variables.
# This script is POSIX-ish but uses `local`, which is common in modern shells
# like bash, zsh, and dash.

# - 1/ https://g.co/gemini/share/a46a6b5b0799
#   - PROMPT: Generate a shell script with a `set_dark_mode [darkmode:bool=True] [theme_str:str]` function that exports env variables for setting dark mode to on or off with all versions of gtk and qt and idk e.g. pygments

# - 2/ gemini-cli
#   - Read @setup_darkmode.sh and add support for creating or updating gtkrc and gtk-3.0/settings.ini and gtk-4.0/settings.ini
#   - Add gtk-application-prefer-dark-theme=$value to each settings.ini
#   - Read @setup_darkmode.sh and Add gtk-application-prefer-dark-theme=$value to each settings.ini
#   - What is the simplest way to check whether dark mode configuration is working with maybe a framebuffer image analysis and gtk and qt?
#   - What is the simplest way to check whether dark mode configuration is working with a already-installed or commonly-already-installed app with maybe a framebuffer image analysis and gtk and qt?
#   - What would be simpler than `source setup_darkmode.sh && setup_darkmode true`?
#   - Add a main() function to parse "${@}" in a for loop with commands in a case statement that shift after processing an arg: -h|--help print_usage(), -s|--print-sh|--print-bash|--print-zsh to print the export statements to be eval'd, --check to check the status of all dark mode settings. Add functions for each option.
#   - Re-read @setup_darkmode.sh and update setup_darkmode_print_usage with help text for each cli flag


setup_darkmode_print_usage() {
    echo 'setup_darkmode.sh [-h][-v] [true|false|<command>] [arguments]
  Sets environment variables and desktop settings for dark or light mode.

  Commands:

    check, --check          Check the current dark mode settings (but do not overwrite anything)

    true  [theme_name]      Sets the theme. Defaults to `true` (dark mode) and "Adwaita".
    false [theme_name]      Sets the theme. Defaults to `true` (dark mode) and "Adwaita".
          <theme_name>      The name of the GTK theme (e.g., "Adwaita", "Yaru").
                            The script appends "-dark" or ":dark" for dark mode.

    -y, --write-all
    --write-gtkrc           Write .gtkrc-2.0, .config/gtkrc-3-0, .config/gtkrc-4-0 config files
                            (Note: --write-gtkrc is impled if the "true" or "false" commands are passed)
    --write-gsettings       Run `gsettings set` to set the theme (which writes to disk)
                            (Note: --write-gsettings is impled if the "true" or "false" commands are passed)

    -s, --print-sh, print   Print the export statements for the current shell.


    --install <pkg_type>,   Install packages to support dark mode
      install <pkg_type>    <pkg_type> can be: gtk, qt, dnf, flatpak-gtk

    -h, --help              Show this help message.
    -v, --verbose           Be verbose (set +x +v)


  Usage:
    setup_darkmode.sh [-h][-v] [command] [arguments]
    setup_darkmode.sh true
    setup_darkmode.sh false
    setup_darkmode.sh true Adwaita

    setup_darkmode.sh -y true
    setup_darkmode.sh --write-all true

    setup_darkmode.sh -s | tee example.sh && source example.sh

    eval "$(setup_darkmode.sh -s true)"
'
}

setup_darkmode_update_gtk_config() {
    local gtk_theme_name="$1"
    local prefer_dark_theme="$2"
    local gtkrc_file="$HOME/.gtkrc-2.0"
    local gtk3_settings_file="$HOME/.config/gtk-3.0/settings.ini"
    local gtk4_settings_file="$HOME/.config/gtk-4.0/settings.ini"

    printf "\n#INFO: Updating GTK config files...\n"

    # GTK2
    if [ -f "$gtkrc_file" ]; then
        echo "#INFO: gtkrc: ${gtkrc_file}"
        # If the theme is already set, replace it. Otherwise, append it.
        if grep -q "^gtk-theme-name=" "$gtkrc_file"; then
            sed -i "s|^gtk-theme-name=.*|gtk-theme-name=\"$gtk_theme_name\"|" "$gtkrc_file"
        else
            echo "gtk-theme-name=\"$gtk_theme_name\"" >> "$gtkrc_file"
        fi
    else
        echo "gtk-theme-name=\"$gtk_theme_name\"" > "$gtkrc_file"
    fi

    # GTK3
    echo "#INFO: gtk3_settings: ${gtk3_settings_file}"
    mkdir -p "$(dirname "$gtk3_settings_file")"
    if ! grep -q '^\[Settings\]' "$gtk3_settings_file" 2>/dev/null; then
        echo '[Settings]' >> "$gtk3_settings_file"
    fi
    if grep -q '^gtk-theme-name=' "$gtk3_settings_file" 2>/dev/null; then
        sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$gtk_theme_name/" "$gtk3_settings_file"
    else
        sed -i "/\[Settings\]/a gtk-theme-name=$gtk_theme_name" "$gtk3_settings_file"
    fi
    if grep -q '^gtk-application-prefer-dark-theme=' "$gtk3_settings_file" 2>/dev/null; then
        sed -i "s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$prefer_dark_theme/" "$gtk3_settings_file"
    else
        sed -i "/\[Settings\]/a gtk-application-prefer-dark-theme=$prefer_dark_theme" "$gtk3_settings_file"
    fi

    # GTK4
    echo "#INFO: gtk4_settings: ${gtk4_settings_file}"
    mkdir -p "$(dirname "$gtk4_settings_file")"
    if ! grep -q '^\[Settings\]' "$gtk4_settings_file" 2>/dev/null; then
        echo '[Settings]' >> "$gtk4_settings_file"
    fi
    if grep -q '^gtk-theme-name=' "$gtk4_settings_file" 2>/dev/null; then
        sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$gtk_theme_name/" "$gtk4_settings_file"
    else
        sed -i "/\[Settings\]/a gtk-theme-name=$gtk_theme_name" "$gtk4_settings_file"
    fi
    if grep -q '^gtk-application-prefer-dark-theme=' "$gtk4_settings_file" 2>/dev/null; then
        sed -i "s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$prefer_dark_theme/" "$gtk4_settings_file"
    else
        sed -i "/\[Settings\]/a gtk-application-prefer-dark-theme=$prefer_dark_theme" "$gtk4_settings_file"
    fi

    (test -n "$__VERBOSE" && set -x && (
        cat "${gtk3_settings_file}" >&2;
        cat "${gtk4_settings_file}" >&2))
}

setup_darkmode() {
    # Default to dark mode ('true') if the first argument is not provided.
    local use_dark_mode="${1:-"true"}"
    # Default to 'Adwaita' theme if the second argument is not provided.
    local theme_base="${2:-Adwaita}"

    if [ -z "${theme_base}" ]; then
        echo "INFO: theme_base was not specified, getting gtk-theme from gsettings..."
        local gtk_theme_name=$(gsettings get org.gnome.desktop.interface gtk-theme | sed "s/^'//;s/'$//")
        (set -x; true "${gtk_theme_name}")
        theme_base="${gtk_theme_name}"
        (set -x; true "${theme_base}")
        if [ -z "${theme_base}" ]; then
            echo "ERROR: theme_base was not specified and could not be determined. theme_base must be specified."
            return 2
        fi
    fi

    # Global args
    # DO_WRITE_GSETTINGS
    # DO_WRITE_GTK_SETTINGS
    # DO_EXPORT_VARS

    local gtk_theme
    local pygments_style
    local bat_theme
    local color_scheme_preference
    local fzf_opts
    local prefer_dark_theme_value

    # Check if the dark mode flag is explicitly set to false.
    if [ "$use_dark_mode" = "false" ] || [ "$use_dark_mode" = "0" ]; then
        # --- LIGHT MODE SETTINGS ---
        printf "#INFO: 🎨 Setting up LIGHT mode...\n" >&2
        gtk_theme="$theme_base"
        pygments_style="default"
        bat_theme="GitHub"
        color_scheme_preference="prefer-light"
        fzf_opts="--color=light"
        prefer_dark_theme_value=false
        theme_mode="light"
    else
        # --- DARK MODE SETTINGS ---
        printf "#INFO: 🌙 Setting up DARK mode...\n" >&2
        gtk_theme="${theme_base}:dark"
        pygments_style="monokai"
        bat_theme="gruvbox-dark"
        color_scheme_preference="prefer-dark"
        fzf_opts="--color=dark"
        prefer_dark_theme_value=true
        theme_mode="dark"
    fi

    # --- EXPORT ENVIRONMENT VARIABLES ---
    if [ -n "${DO_EXPORT_VARS}" ]; then
        export THEME_MODE="$theme_mode"

        # For GTK 2/3/4 applications
        export GTK_THEME="$gtk_theme"

        # TODO: fix this for KDE, where QT_QPA_PLATFORMTHEME probably shouldn't be 'gtk2' or 'gtk3'
        # For Qt 5/6 applications
        # Tells Qt to try and follow GTK's theme. May require platform plugins
        # like 'qt5-styleplugins' or 'qgnomeplatform' to be installed.
        #export QT_QPA_PLATFORMTHEME="gtk2"
        export QT_QPA_PLATFORMTHEME="gtk3"

        # TODO: noting these vars here for other reference
        #export QT_QPA_PLATFORM="wayland"
        #export QT_QPA_PLATFORM="xcb"
        #export QT_QPA_GENERIC_PLUGINS="qtvirtualkeyboard"

        # For Pygments (code syntax highlighter)
        export PYGMENTS_STYLE="$pygments_style"

        # For bat (a 'cat' clone)
        export BAT_THEME="$bat_theme"

        # For fzf (command-line fuzzy finder)
        export FZF_DEFAULT_OPTS="$fzf_opts"


        #export GTK2_RC_FILES=/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc
        export QT_STYLE_OVERRIDE=Adwaita-Dark
        # TODO: export QT_STYLE_OVERRIDE=Adwaita:Dark ?
    fi


    # For modern GNOME/libadwaita applications (GTK4)
    # Uses `gsettings` to set the desktop-wide color scheme preference.
    if [ -n "${DO_WRITE_GSETTINGS}" ]; then
        if command -v gsettings >/dev/null 2>&1; then
            printf "\n#INFO: Found 'gsettings', running 'gsettings set ...'\n"
            (test -n "$__VERBOSE" && set -x;
                gsettings set org.gnome.desktop.interface color-scheme "$color_scheme_preference"
                gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme")
        fi
    fi

    if [ -n "${DO_WRITE_GTK_SETTINGS}" ]; then
        (test -n "${__VERBOSE}" && set -x;
        setup_darkmode_update_gtk_config "$gtk_theme" "$prefer_dark_theme_value")
    fi

    printf "\n#INFO: Status of dark mode vars:\n" >&2
    setup_darkmode_print_status >&2

    # TODO: when setup_darkmode.sh is not sourced in, don't print this
    if [ -n "${IS_SOURCED_NOT_MAIN}" ]; then
       printf "\n#INFO: ✅ Theme variables exported. Restart applications to apply changes.\n"
    fi
}


setup_darkmode_print_status() {
    (set +x;
    printf "THEME_MODE=%s\n" "$THEME_MODE"
    printf "BAT_THEME=%s\n" "$BAT_THEME"
    printf "FZF_DEFAULT_OPTS=%s\n" "$FZF_DEFAULT_OPTS"
    printf "GTK2_RC_FILES=%s\n" "$GTK2_RC_FILES"
    printf "GTK_THEME=%s\n" "$GTK_THEME"
    printf "PYGMENTS_STYLE=%s\n" "$PYGMENTS_STYLE"
    printf "QT_QPA_PLATFORMTHEME=%s\n" "$QT_QPA_PLATFORMTHEME"
    printf "QT_STYLE_OVERRIDE=%s\n" "$QT_STYLE_OVERRIDE")
}

#
# Unsets all environment variables set by the set_dark_mode function.
#
_unsetup_darkmode_vars() {
    printf "#INFO: 🧹 Unsetting theme environment variables...\n"
    unset BAT_THEME
    unset FZF_DEFAULT_OPTS
    unset GTK2_RC_FILES
    unset GTK_THEME
    unset PYGMENTS_STYLE
    unset QT_QPA_PLATFORMTHEME
    unset QT_STYLE_OVERRIDE
    unset THEME_MODE
    printf "#INFO: ✅ Variables have been unset for the current shell session.\n"
}

setup_darkmode_install_packages() {
    if [ -z "${@}" ]; then
        echo "ERROR: specify 1 or more package types to install: all, gtk, qt, dnf, flatpak-gtk"
        return 1
    fi
    for arg in "${@}"; do
        case "${arg}" in
            gtk|gnome|all)
                sudo dnf install -y adw-gtk3-theme
                ;;
            qt|all)
                #sudo dnf install -y qgnomeplatform-qt5 qgnomeplatform-qt6
                #sudo dnf install -y qadwaitadecorations-qt5 qadwaitadecorations-qt6
                #sudo dnf install -y adwaita-gtk2-theme
                sudo dnf install -y adwaita-qt5 qadwaita-qt6 qadwaitadecorations-qt5 qadwaitadecorations-qt6 adwaita-gtk2-theme
                ;;
            dnf|all)
                sudo dnf install -y adwaita-themes qgnomeplatform-qt5 qgnomeplatform-qt6
                ;;
            flatpak-gtk|all)
                flatpak install flathub org.gtk.Gtk3theme.Adwaita-dark
                ;;
            *)
                echo "ERROR: install command not found: ${@}"
                return 2
                ;;
        esac
    done
}

setup_darkmode_print_shell() {
    (set +x;
    printf "\n#INFO: Dark mode environment variables to set:\n" >&2;
    printf "export THEME_MODE=%s\n" "$THEME_MODE"
    printf "export BAT_THEME=%s\n" "$BAT_THEME"
    printf "export FZF_DEFAULT_OPTS=%s\n" "$FZF_DEFAULT_OPTS"
    printf "export GTK2_RC_FILES=%s\n" "$GTK2_RC_FILES"
    printf "export GTK_THEME=%s\n" "$GTK_THEME"
    printf "export PYGMENTS_STYLE=%s\n" "$PYGMENTS_STYLE"
    printf "export QT_QPA_PLATFORMTHEME=%s\n" "$QT_QPA_PLATFORMTHEME"
    printf "export QT_STYLE_OVERRIDE=%s\n" "$QT_STYLE_OVERRIDE")
}

setup_darkmode_check_status() {
    printf "#INFO: Checking status of dark mode parameters...\n\n"
    printf "#INFO: gsettings color-scheme, gtk-theme...\n"
    printf "gsettings color-scheme: %s\n" "$(gsettings get org.gnome.desktop.interface color-scheme)"
    printf "gsettings gtk-theme: %s\n" "$(gsettings get org.gnome.desktop.interface gtk-theme)"
    _gtk2_settings="$HOME/.gtkrc-2.0"
    _gtk3_settings="$HOME/.config/gtk-3.0/settings.ini"
    _gtk4_settings="$HOME/.config/gtk-4.0/settings.ini"
    printf "\n#INFO: GTK3 settings: ${_gtk3_settings}\n"
    cat "${_gtk3_settings}"
    printf "\n#INFO: GTK4 settings: ${_gtk4_settings}\n"
    cat "${_gtk4_settings}"
    printf "\n#INFO: Environment variables:\n"
    (setup_darkmode_print_status) >&2
}

setup_darkmode_main() {

    if [ "$#" -eq 0 ]; then
        setup_darkmode_print_usage
        return 0
    fi

    test -n "${__VERBOSE}" && \
        (echo '+$0: '"$0" && \
        echo '+$@: '"${@}") >&2

    for arg in "${@}"; do
        case "$arg" in
            -h|--help)
                setup_darkmode_print_usage
                return
                ;;
            -v|--verbose)
                shift
                export __VERBOSE=1
                ;;
        esac
    done

    test -n "${__VERBOSE}" && \
        echo '+$@: '"${@}" >&2

    for arg in "${@}"; do
        case "$arg" in
            -v|--verbose)
                shift
                export __VERBOSE=1
                ;;


            check|--check)
                shift
                export DO_CHECK=1
                ;;

            install|--install)
                shift
                export DO_INSTALL=1
                ;;


            print|-s|--print-sh|--print-bash|--print-zsh)
                shift
                export DO_PRINT_SHELL=1
                ;;
            --write-gtkrc)
                shift
                export DO_WRITE_GTK_SETTINGS=1
                ;;
            --write-gsettings)
                shift
                export DO_WRITE_GSETTINGS=1
                ;;
            --write-all|-y)
                shift
                export DO_WRITE_ALL=1
                export DO_WRITE_GTK_SETTINGS=1
                export DO_WRITE_GSETTINGS=1
                export DO_EXPORT_VARS=1
                ;;

            true|false|0)
                export DO_WRITE_GTK_SETTINGS=1
                export DO_WRITE_GSETTINGS=1
                ;;
            Adwaita|TODO)  # TODO: add names of working themes here
                ;;

            *)
                echo "DEBUG: Unknown arg: $1" >&2
                ;;
        esac
    done

    if [ -n "${DO_INSTALL}" ]; then
        setup_darkmode_install_packages "${@}"
        return
    fi


    if [ -n "${DO_CHECK}" ]; then
        setup_darkmode_check_status
        returncode=$?
        if [ $# -eq 0 ]; then
            return $returncode
        fi
    fi

    # setup_darkmode reads $DO_WRITE_GTK_SETTINGS
    #if [ -n "${DO_WRITE_GTK_SETTINGS}" ]; then
    #    setup_darkmode_check_status
    #fi

    if [ -n "${DO_PRINT_SHELL}" ]; then
        test -n "${__VERBOSE}" && echo '+$@: '"${@}"" before setup_darkmode()" >&2
        DO_EXPORT_VARS=1 setup_darkmode "${@}" >&2
        setup_darkmode_print_shell "${@}"
    fi

}

if [ -z "${__SKIP_MAIN}" ]; then
    setup_darkmode_main "${@}"
fi
