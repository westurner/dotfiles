#!/bin/bash

###   _ewrd.sh  -- convenient editor shortcuts
#     # setup edit[*] and e[*] symlinks:
#     $ ln -s ./_ewrd.sh _ewrd-setup.sh && ./_ewrd-setup.sh

##    editdotfiles, edotfiles -- cd $__DOTFILES and run edit w/ each arg
function editdotfiles {
    # editdotfiles() -- cd $__DOTFILES and run edit w/ each arg
    (cd "${__DOTFILES}";
    (for arg in ${@}; do echo "${arg}"; done) \
        | el --each -x 'e {0}'
    )
    return
}

function edotfiles {
    # edotfiles()    -- cd $__DOTFILES and run edit w/ each arg
    editdotfiles $@
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
    (cd "${__WRK}";
    (for arg in ${@}; do echo "${arg}"; done) \
        | el --each -x 'e {0}'
    )
    return
}

function ewrk {
    # ewrk()         -- cd $__WRK and run edit w/ each arg
    editwrk $@
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
    (cd "${WORKON_HOME}";
    (for arg in ${@}; do echo "${arg}"; done) \
        | el --each -x 'e {0}'
    )
    return
}

function eworkonhome {
    # eworkonhome()    -- cd $WORKON_HOME and run edit w/ each arg
    editworkonhome $@
    return
}

function ewh {
    # ewh()            -- cd $WORKON_HOME and run edit w/ each arg
    editworkonhome $@
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
    (cd "${VIRTUAL_ENV}";
    (for arg in ${@}; do echo "${arg}"; done) \
        | el --each -x 'e {0}'
    )
    return
}

function evirtualenv {
    # evirtualenv()    -- cd $VIRTUAL_ENV and run edit w/ each arg
    editvirtualenv $@
    return
}

function ev {
    # ev()             -- cd $VIRTUAL_ENV and run edit w/ each arg
    editvirtualenv $@
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
    (cd "${_SRC}";
    (for arg in ${@}; do echo "${arg}"; done) \
        | el --each -x 'e {0}'
    )
    return
}

function esrc {
    # esrc()    -- cd $_SRC and run edit w/ each arg
    editsrc $@
    return
}

function es {
    # es()      -- cd $_SRC and run edit w/ each arg
    editsrc $@
    return
}

function _esrc__complete {
    local cur=${2};
    COMPREPLY=($(cd "${_SRC}"; compgen -f -- ${cur}));
}
complete -o default -o nospace -F _esrc__complete editsrc
complete -o default -o nospace -F _esrc__complete esrc
complete -o default -o nospace -F _esrc__complete es


##    editwrd, ewrd, ew  --- cd $_WRD and run edit w/ each arg
function editwrd {
    # editwrd() -- cd $_WRD and run edit w/ each arg
    (cd "${_WRD}";
    (for arg in ${@}; do echo "${arg}"; done) \
        | el --each -x 'e {0}'
    )
    return
}

function ewrd {
    # ewrd()    -- cd $_WRD and run edit w/ each arg
    editwrd $@
    return
}

function ew {
    # ew()      -- cd $_WRD and run edit w/ each arg
    editwrd $@
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
    (cd "${_ETC}";
    (for arg in ${@}; do echo "${arg}"; done) \
        | el --each -x 'e {0}'
    )
    return
}

function eetc {
    # eetc()    -- cd $_ETC and run edit w/ each arg
    editetc $@
    return
}

function es {
    # es()      -- cd $_ETC and run edit w/ each arg
    editetc $@
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
    (cd "${_WWW}";
    (for arg in ${@}; do echo "${arg}"; done) \
        | el --each -x 'e {0}'
    )
    return
}

function ewww {
    # ewww()    -- cd $_WWW and run edit w/ each arg
    editwww $@
    return
}

function _ewww__complete {
    local cur=${2};
    COMPREPLY=($(cd "${_WWW}"; compgen -f -- ${cur}));
}
complete -o default -o nospace -F _ewww__complete editwww
complete -o default -o nospace -F _ewww__complete ewww



function _create_edit_symlinks {
    local scriptname='_ewrd.sh'
    local scriptnames=(
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
    for symlinkname in ${scriptnames[@]}; do
        test -L "${symlinkname}" && rm "${symlinkname}"
        ln -s "${scriptname}" "${symlinkname}"
    done
}

#_ewrd.sh main()
if [[ "${BASH_SOURCE}" == "${0}" ]]; then
    set -x
    declare -r progname="$(basename ${BASH_SOURCE})"
    case "${progname}" in
        editdotfiles|edotfiles)
            editdotfiles ${@}
            exit
            ;;

        editwrk|ewrk)
            editwrk ${@}
            exit
            ;;

        editworkonhome|eworkonhome|ewh)
            editworkonhome ${@}
            exit
            ;;

        editvirtualenv|evirtualenv|ev)
            editvirtualenv ${@}
            exit
            ;;
        editsrc|esrc|es)
            editsrc ${@}
            exit
            ;;
        editwrd|ewrd|ew)
            editwrd ${@}
            exit
            ;;
        editetc|eetc)
            editetc ${@}
            exit
            ;;
        editwww|ewww)
            editwww ${@}
            exit
            ;;

        _ewrd.sh|edithelp|ehelp)
            cat "${BASH_SOURCE}" | \
                pyline.py -r '^\s*#+\s+.*' 'rgx and l';
            exit
            ;;

        _ewrd-setup.sh)
            _create_edit_symlinks
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

