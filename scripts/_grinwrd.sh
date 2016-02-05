#!/usr/bin/env bash

### _grinwrd.sh --- Grin search functions

# TODO:
#  - [ ] TST: *
#  - [ ] Normalize pass-through argument handling (e.g. ``grin -C 10``)

## seeAlso ##
#* https://westurner.org/dotfiles/venv

# virtualenv & virtualenvwrapper
function grinv {
    # grinv()   -- grin $VIRTUAL_ENV
    grin --follow $@ "${VIRTUAL_ENV}"
}

function grindv {
    # grindv()  -- grind $VIRTUAL_ENV
    grind --follow $@ --dirs "${VIRTUAL_ENV}"
}

# venv
function grins {
    # grins()   -- grin $_SRC
    grin --follow $@ "${_SRC}"
}

function grinds {
    # grinds()  -- grind $_SRC
    grind --follow $@ --dirs "${_SRC}"
}

function grinw {
    # grinw()   -- grin $_WRD
    grin --follow $@ "${_WRD}"
}

function grindw {
    # grindw()  -- grind $_WRD
    grind --follow $@ --dirs "${_WRD}"
}

function edit_grin_w {
    # edit_grin_w() -- edit $(grinw -l $@)
    edit $(grinw -l $@)
}

function egw {
    # egw           -- edit $(grinw -l $@)
    edit_grin_w $@
}

function edit_grind_wrd {
    (IFS='\n' edit $(grind ${@} --follow --dirs "${_WRD}"))
    grindw ${@} | el -v -e
}

## ctags (exuberant ctags)
# brew install ctags
# apt-get install exuberant-ctags
# dnf install ctags ctags-etags
function grindctags {
    # grindctags()      -- generate ctags from grind (in ./tags)
    local ctagsbin=
    local path=${1:-'.'}
    local grindargs=${2}
    if [ -n "${__IS_MAC}" ]; then
        if [ -x "/usr/local/bin/ctags" ]; then
            # brew install ctags
            ctagsbin="/usr/local/bin/ctags"
        else
            ctagsbin=$(which ctags)
        fi
    else
        ctagsbin=$(which ctags)
    fi
    (set -x -v;
    cd "${path}";
    grind --follow ${grindargs} --dirs "${path}" \
        | grep -v 'min.js$' \
        | ${ctagsbin} -L - 2>"${path}/tags.err" \
        && wc -l "${path}/tags.err";
    ls -alhtr "${path}/tags"* ;)
}

function grindctagssys {
    # grindctagssys()   -- generate ctags from grind --sys-path ($_WRD/tags)
    grindctags "${_WRD}" "--sys-path"
}

function grindctagswrd {
    # grindctagswrd()   -- generate ctags from (cd $_WRD; grind) ($_WRD/tags)
    grindctags "${_WRD}"
}

function grindctagsssrc {
    # grindctagssrc()   -- generate ctags from (cd $_SRC; grind) ($_SRC/tags)
    grindctags "${_SRC}"
}


function _create_grinwrd_symlinks {
    local scriptname='_grinwrd.sh'
    local scriptnames=(
        "grinvirtualenv"
        "grinv"
        "grindvirtualenv"
        "grindv"

        "grinsrc"
        "grins"
        "grindsrc"
        "grinds"

        "grinwrd"
        "grinw"
        "grindwrd"
        "grindw"

        "editgrinw"
        "egrinw"
        "egw"

        "editgrindw"
        "egrindw"

        "grindctags"

        "grindctagssys"

        "grindctagswrd"
        "grindctagsw"

        "grindctagssrc"
        "grindctagss"

        "grinwrdhelp"
        "grindwrdhelp"
    )
    for symlinkname in ${scriptnames[@]}; do
        test -L "${symlinkname}" && rm "${symlinkname}"
        ln -s "${scriptname}" "${symlinkname}"
    done
}

#_grinwrd.sh main()
if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    set -x
    declare -r progname="$(basename ${BASH_SOURCE})"
    case "${progname}" in
        grinvirtualenv|grinv)
            grinv ${@}
            exit
            ;;
        grindvirtualenv|grindv)
            grindv ${@}
            exit
            ;;

        grinsrc|grins)
            grinv ${@}
            exit
            ;;
        grindsrc|grinds)
            grinds ${@}
            exit
            ;;

        grinwrd|grinw)
            grinw ${@}
            exit
            ;;
        grindwrd|grindw)
            grindw ${@}
            exit
            ;;

        editgrinw|egrinw|egw)
            edit_grin_w ${@}
            exit
            ;;

        editgrindw|egrindw)
            edit_grind_w ${@}
            exit
            ;;

        grindctags)
            grindctags ${@}
            exit
            ;;

        grindctagssys)
            grindctagssys ${@}
            exit
            ;;

        grindctagssrc|grindctagss)
            grindctagssrc ${@}
            exit
            ;;

        grindctagswrd|grindctagsw)
            grindctagswrd ${@}
            exit
            ;;

        _grinwrd.sh|grinwrdhelp|grindwrdhelp)
            cat "${BASH_SOURCE}" | \
                pyline.py -r '^\s*#+\s+.*' 'rgx and l';
            exit
            ;;

        _grinwrd-setup.sh)
            _create_grinwrd_symlinks
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
# * _ewrd.sh
