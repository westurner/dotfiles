#!/usr/bin/env bash

###   _ewrd.sh  -- convenient editor shortcuts
#     # setup edit[*] and e[*] symlinks:
#     $ ln -s ./_ewrd.sh _ewrd-setup.sh && ./_ewrd-setup.sh

##    e, edit         -- edit a file, list editors, or set editor
function e {
    # e() -- Default editor wrapper with support for listing and setting editors.
    # e <file>             -- Edit file with $EDITOR (default: vim)
    # e -- <file>          -- Edit a file (use -- to edit files named -l, set, etc.)
    #
    # e -l/--list          -- List available editors and current settings
    # e -s/--set <name>       -- Print shell export command for setting $EDITOR
    #
    # e -h/--help          -- Show this help and editor's help
  
    POSSIBLE_EDITORS="code.sh code gvim nvim mvim vim nano vi emacs gedit kate spyder flatpak gvim-venv nvim-venv"

    if [[ "$1" == "-l" || "$1" == "--list" ]]; then
        echo "## Current settings:"
        echo "  EDITOR=${EDITOR}"
        echo "  EDITOR_=${EDITOR_}"
        echo ""
        echo "  VIMCONF=${VIMCONF}"
        echo "  GUIVIMBIN=${GUIVIMBIN}"
        echo "  GVIMBIN=${GVIMBIN}"
        echo "  MVIMBIN=${MVIMBIN}"
        echo ""
        echo "## Available editors:"
        echo ""
        for ed in ${POSSIBLE_EDITORS}; do
            if type "$ed" >/dev/null 2>&1; then
                (set -x; type -a "$ed")
            else
                echo "+ type -a ${ed}"
            fi
            echo ""
        done
        echo "## Current settings:"
        echo "  EDITOR=${EDITOR}"
        echo "  EDITOR_=${EDITOR_}"
        return 0
    elif [[ "$1" == "-s" ]] || [[ "$1" == "--set" ]]; then
        local editor_choice="$2"
        echo "#xport EDITOR=\"$EDITOR\"" >&2  # current value of EDITOR"
        case "$editor_choice" in
            nano) _editor="nano" ;;

            vi)   _editor="vi" ;;
            vim)  _editor="vim" ;;
            gvim) _editor="gvim" ;;
            gvim-venv) _editor="gvim \${VIMCONF}" ;;
            mvim) _editor="mvim" ;;
            nvim) _editor="nvim" ;;
            nvim-venv) _editor="nvim \${VIMCONF/--servername/--server}" ;;

            gedit) _editor="gedit" ;;
            kate) _editor="kate" ;;

            spyder) _editor="spyder" ;;

            code) _editor="code" ;;
            code.sh) _editor="code.sh" ;;
            com.visualstudio.code) _editor="flatpak run com.visualstudio.code" ;;
            
            org.gnome.TextEditor|TextEditor) _editor="flatpak run org.gnome.TextEditor" ;;


            "")   echo "Error: Must specify editor name (e.g., code, vim)" >&2; return 1 ;;
            *)    _editor="$editor_choice" ;;
        esac
        echo "export EDITOR=\"${_editor}\""
        export EDITOR="${_editor}"
        return 0
    elif [[ "$1" == "-h" || "$1" == "--help" ]]; then
        # print function docstring
        grep -E '^    # e' "${BASH_SOURCE[0]:-${__DOTFILES}/scripts/_ewrd.sh}" || true
        echo ""
        local _editor="${EDITOR:-vim}"
        echo "Help for configured editor: $_editor"
        (set -x; $_editor "$1")
        return 0

    # Otherwise, pass through to the editor
    # else  
    #     echo "ERR: Unknown argument '$1'"

    fi

    local _editor="${EDITOR:-vim}"
    
    if [[ "$1" == "--" ]]; then
        shift
    fi

    # Expand default aliases if necessary, otherwise just run directly
    $_editor "${@}"
}

function _e__complete {
    local cur=${2}
    local prev=${3}
    if [[ "$prev" == "set" ]] || [[ "$prev" == "-s" ]]; then
        COMPREPLY=( $(compgen -W "code.sh code com.visualstudio.code vim gvim gvim-venv nvim nvim-venv mvim vi nano gedit kate spyder org.gnome.TextEditor TextEditor" -- "$cur") )
    else
        COMPREPLY=( $(compgen -W "-l --list set -h --help --" -- "$cur") )
        # Also include files/directories as fallback
        COMPREPLY+=( $(compgen -f -- "$cur") )
    fi
}
complete -o bashdefault -o default -o nospace -F _e__complete e
complete -o bashdefault -o default -o nospace -F _e__complete edit


##    editdotfiles, edotfiles -- cd $__DOTFILES and run edit w/ each arg
function editdotfiles {
    # editdotfiles() -- cd $__DOTFILES and run edit w/ each arg
    (cd "${__DOTFILES}"; e "${@}")
    return
}

function edotfiles {
    # edotfiles()    -- cd $__DOTFILES and run edit w/ each arg
    editdotfiles "${@}"
    return
}

function _edotfiles__complete {
    local cur=${2};
    COMPREPLY=($(cd "${__DOTFILES}"; compgen -f -- ${cur}));
}
complete -o default -o nospace -F _edotfiles__complete editdotfiles
complete -o default -o nospace -F _edotfiles__complete edotfiles


##    editwrk, ewrk   --- cd $__WRK and run edit w/ each arg
function editwrk {
    # editwrk()      -- cd $__WRK and run edit w/ each arg
    (cd "${__WRK}"; e "${@}")
    return
}

function ewrk {
    # ewrk()         -- cd $__WRK and run edit w/ each arg
    editwrk "${@}"
    return
}

function _ewrk__complete {
    local cur=${2};
    COMPREPLY=($(cd "${__WRK}"; compgen -f -- ${cur}));
}
complete -o default -o nospace -F _ewrk__complete editwrk
complete -o default -o nospace -F _ewrk__complete ewrk


##    editworkonhome, eworkonhome --- cd $WORKON_HOME and run edit w/ each arg
function editworkonhome {
    # editworkonhome() -- cd $WORKON_HOME and run edit w/ each arg
    (cd "${WORKON_HOME}"; e "${@}")
    return
}

function eworkonhome {
    # eworkonhome()    -- cd $WORKON_HOME and run edit w/ each arg
    editworkonhome "${@}"
    return
}

function ewh {
    # ewh()            -- cd $WORKON_HOME and run edit w/ each arg
    editworkonhome "${@}"
    return
}

function _eworkonhome__complete {
    local cur=${2};
    COMPREPLY=($(cd "${WORKON_HOME}"; compgen -f -- ${cur}));
}
complete -o default -o nospace -F _eworkonhome__complete editworkonhome
complete -o default -o nospace -F _eworkonhome__complete eworkonhome
complete -o default -o nospace -F _eworkonhome__complete ewh



##    editvirtualenv, evirtualenv, ev  --- cd $VIRTUAL_ENV and run edit w/ each arg
function editvirtualenv {
    # editvirtualenv() -- cd $VIRTUAL_ENV and run edit w/ each arg
    (cd "${VIRTUAL_ENV}"; e "${@}")
    return
}

function evirtualenv {
    # evirtualenv()    -- cd $VIRTUAL_ENV and run edit w/ each arg
    editvirtualenv "${@}"
    return
}

function ev {
    # ev()             -- cd $VIRTUAL_ENV and run edit w/ each arg
    editvirtualenv "${@}"
    return
}

function _evirtualenv__complete {
    local cur=${2};
    COMPREPLY=($(cd "${VIRTUAL_ENV}"; compgen -f -- ${cur}));
}
complete -o default -o nospace -F _evirtualenv__complete editvirtualenv
complete -o default -o nospace -F _evirtualenv__complete evirtualenv
complete -o default -o nospace -F _evirtualenv__complete ev


##    editsrc, esrc, es  --- cd $_SRC and run edit w/ each arg
function editsrc {
    # editsrc() -- cd $_SRC and run edit w/ each arg
    (cd "${_SRC}"; e "${@}")
    return
}

function esrc {
    # esrc()    -- cd $_SRC and run edit w/ each arg
    editsrc "${@}"
    return
}

function es {
    # es()      -- cd $_SRC and run edit w/ each arg
    editsrc "${@}"
    return
}

function _esrc__complete {
    local cur=${2};
    COMPREPLY=($(cd "${_SRC}" || return; compgen -f -- ${cur}));
    #COMPREPLY=("$(cd "${_SRC}" || return; compgen -f -- "${cur}")");
}
complete -o default -o nospace -F _esrc__complete editsrc
complete -o default -o nospace -F _esrc__complete esrc
complete -o default -o nospace -F _esrc__complete es


##    editwrd, ewrd, ew  --- cd $_WRD and run edit w/ each arg
function editwrd {
    # editwrd() -- cd $_WRD and run edit w/ each arg
    (cd "${_WRD}"; e "${@}")
    return
}

function ewrd {
    # ewrd()    -- cd $_WRD and run edit w/ each arg
    editwrd "${@}"
    return
}

function ew {
    # ew()      -- cd $_WRD and run edit w/ each arg
    editwrd "${@}"
    return
}

function _ewrd__complete {
    local cur=${2};
    COMPREPLY=($(cd "${_WRD}"; compgen -f -- ${cur}));
}
complete -o default -o nospace -F _ewrd__complete editwrd
complete -o default -o nospace -F _ewrd__complete ewrd
complete -o default -o nospace -F _ewrd__complete ew


##    editetc, eetc      --- cd $_ETC and run edit w/ each arg
function editetc {
    # editetc() -- cd $_ETC and run edit w/ each arg
    (cd "${_ETC}"; e "${@}")
    return
}

function eetc {
    # eetc()    -- cd $_ETC and run edit w/ each arg
    editetc "${@}"
    return
}

function _eetc__complete {
    local cur=${2};
    COMPREPLY=($(cd "${_ETC}"; compgen -f -- ${cur}));
}
complete -o default -o nospace -F _eetc__complete editetc
complete -o default -o nospace -F _eetc__complete eetc


##    editwww, ewww      --- cd $_WWW and run edit w/ each arg
function editwww {
    # editwww() -- cd $_WWW and run edit w/ each arg
    (cd "${_WWW}"; e "${@}")
    return
}

function ewww {
    # ewww()    -- cd $_WWW and run edit w/ each arg
    editwww "${@}"
    return
}

function _ewww__complete {
    local cur=${2};
    COMPREPLY=($(cd "${_WWW}"; compgen -f -- ${cur}));
}
complete -o default -o nospace -F _ewww__complete editwww
complete -o default -o nospace -F _ewww__complete ewww



function _create_ewrd_symlinks {
    local scriptname='_ewrd.sh'
    local scriptnames=(
        "e"
        "edit"

        "editdotfiles"
        "edotfiles"

        "editwrk"
        "ewrk"

        "editworkonhome"
        "eworkonhome"
        "ewh"

        "editvirtualenv"
        "evirtualenv"
        "ev"

        "editsrc"
        "esrc"
        "es"

        "editwrd"
        "ewrd"
        "ew"

        "editetc"
        "eetc"

        "editwww"
        "ewww"
    )
    for symlinkname in "${scriptnames[@]}"; do
        test -L "${symlinkname}" && rm "${symlinkname}"
        ln -s "${scriptname}" "${symlinkname}"
    done
}

#_ewrd.sh main()
if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    set -x
    declare -r progname="$(basename "${BASH_SOURCE}")"
    case "${progname}" in
        e|edit)
            e "${@}"
            exit
            ;;

        editdotfiles|edotfiles)
            editdotfiles "${@}"
            exit
            ;;

        editwrk|ewrk)
            editwrk "${@}"
            exit
            ;;

        editworkonhome|eworkonhome|ewh)
            editworkonhome "${@}"
            exit
            ;;

        editvirtualenv|evirtualenv|ev)
            editvirtualenv "${@}"
            exit
            ;;
        editsrc|esrc|es)
            editsrc "${@}"
            exit
            ;;
        editwrd|ewrd|ew)
            editwrd "${@}"
            exit
            ;;
        editetc|eetc)
            editetc "${@}"
            exit
            ;;
        editwww|ewww)
            editwww "${@}"
            exit
            ;;

        _ewrd.sh|edithelp|ehelp)
            #cat "${BASH_SOURCE}" | \
            #    pyline.py -r '^\s*#+\s+.*' 'rgx and l';
            cat "${BASH_SOURCE}" | \
                grep -E '^\s*#+\s+.*'
            exit
            ;;

        _ewrd-setup.sh)
            _create_ewrd_symlinks
            exit
            ;;
        *)
            echo "Err"
            echo '${BASH_SOURCE}: '"'${BASH_SOURCE}'"
            echo '${progname}: '"'${BASH_SOURCE}'"
            exit 2
            ;;
    esac
    exit
fi
#

## seeAlso ##
# * https://westurner.org/dotfiles/venv
#
# .. code:: bash
#
#    type cdhelp; cdhelp 
#    less scripts/venv_cdaliases.sh
#    venv.py --prefix=/ --print-bash-cdaliases

