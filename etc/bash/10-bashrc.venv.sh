### bashrc.venv.sh
#   note: most of these aliases and functions are overwritten by `we` 
## Variables


function _setup_venv {
    # _setup_venv()    -- configure __PROJECTSRC, PATH, __VENV, _setup_venv_SRC()
    #  __PROJECTSRC (str): path to local project settings script to source
    export __PROJECTSRC="${__WRK}/.projectsrc.sh"
    [ -f $__PROJECTSRC ] && source $__PROJECTSRC

    # PATH="~/.local/bin:$PATH" (if not already there)
    PATH_prepend "${HOME}/.local/bin"

    # __VENV      -- path to local venv config script (executable)
    export __VENV="${__DOTFILES}/scripts/venv.py"

    # CdAlias functions and completions
    source "${__DOTFILES}/etc/venv/scripts/venv.sh"
    if [ "${VENVPREFIX}" == "/" ]; then
        source "${__DOTFILES}/etc/venv/scripts/venv_root_prefix.sh"
    fi

    _setup_venv_SRC
}


function _setup_venv_SRC {
    # _setup_venv_SRC() -- configure __SRCVENV and __SRC global virtualenv
    # __SRCVENV (str): global 'src' venv symlink (~/-wrk/src)
    #                  (e.g. ln -s ~/-wrk/-ve27/src ~/-wrk/src)
    export __SRCVENV="${__WRK}/src"
    # __SRC     (str): global 'src' venv ./src directory path (~/-wrk/src/src)
    export __SRC="${__SRCVENV}/src"

    if [ ! -e "${__SRCVENV}" ]; then
        if [ ! -d "${WORKON_HOME}/src" ]; then
            mkvirtualenv -p $(which python) -i pyrpo -i pyline -i pgs src
        fi
        ln -s "${WORKON_HOME}/src" "${__SRCVENV}"
    fi

    #               ($__SRC/git $__SRC/git)
    if [ ! -d $__SRC ]; then
        mkdir -p \
            ${__SRC}/git/github.com \
            ${__SRC}/git/bitbucket.org \
            ${__SRC}/hg/bitbucket.org
    fi
}

_setup_venv

## Functions

function venv {
    # venv $@   -- call $_VENV $@
    # venv -h   -- print venv --help
    # venv --print-bash   -- print bash configuration
    # venv --print-json   -- print IPython configuration as JSON
    (set -x; $__VENV $@)
}
function venvw {
    # venvw $@ -- venv -E $@ (for the current environment)
    (set -x; $__VENV -e $@)
}

function workon_venv {
    # workon_venv() -- workon a virtualenv and load venv (TAB-completion)
    #  param $1: $VIRTUAL_ENV_NAME ("dotfiles")
    #  param $2: $_APP ("dotfiles") [default: $1)
    #   ${WORKON_HOME}/${VIRTUAL_ENV_NAME}  # == $VIRTUAL_ENV
    #   ${VIRTUAL_ENV}/src                  # == $_SRC
    #   ${_SRC}/${VIRTUAL_ENV_NAME}         # == $_WRD
    #  examples:
    #   we dotfiles
    #   we dotfiles dotfiles

    if [ -n "${1}" ]; then
        if [ -d "${WORKON_HOME}/${1}" ]; then
           local _venvstr="${1}"
           local _workon_home="${WORKON_HOME}"
           shift
        elif [ -d "${1}" ]; then
           local _venvstr="$(basename "${1}")"
           local _workon_home="$(dirname "${1}")"
           shift
        else
           echo "err: venv not found: ${1}"
           return 1
        fi

        #append to shell history
        history -a

        workon "${_venvstr}" && \
            source <($__VENV \
                --wrk="$__WRK" \
                --wh="${_workon_home}" \
                --print-bash \
                ${_venvstr} $@ ) && \
            dotfiles_status && \
            declare -f '_setup_venv_prompt' 2>&1 > /dev/null \
            && _setup_venv_prompt "${_TERM_ID:-${_venvstr}}"
    else
        #if no arguments are specified, list virtual environments
        lsvirtualenvs
        return 1
    fi
}
function we {
    # we()          -- workon_venv
    workon_venv $@
}
complete -o default -o nospace -F _virtualenvs workon_venv
complete -o default -o nospace -F _virtualenvs we


function _setup_venv_aliases {
    # _setup_venv_aliases()  -- load venv aliases
    #   note: these are overwritten by `we` [`source <(venv -b)`]

    source "${__DOTFILES}/scripts/_ewrd.sh"

    source "${__DOTFILES}/scripts/_grinwrd.sh"

    # makew     -- make -C "${WRD}" ${@}    [scripts/makew <TAB>]
    source "${__DOTFILES}/scripts/makew"

    source "${__DOTFILES}/scripts/ssv"
    _setup_supervisord

    # hgw       -- hg -R  ${_WRD}   [scripts/hgw <TAB>]
    source "${__DOTFILES}/scripts/hgw"

    # gitw      -- git -C ${_WRD}   [scripts/gitw <TAB>]
    source "${__DOTFILES}/scripts/gitw"

    # serve-()  -- ${_SERVE_}
    # alias serve-='${_SERVE_}'
    # shell-()  -- ${_SHELL_}
    # alias shell-='${_SHELL_}'
    # test-()   -- cd ${_WRD} && python setup.py test
    alias testpyw='(cd ${_WRD} && python "${_WRD_SETUPY}" test)'
    # testr-()  -- reset; cd ${_WRD} && python setup.py test
    alias testpywr='(reset; cd ${_WRD} && python "${_WRD_SETUPY}" test)'

}
_setup_venv_aliases


function _setup_venv_prompt {
    # _setup_venv_prompt()    -- set PS1 with $WINDOW_TITLE, $VIRTUAL_ENV_NAME,
    #                          and ${debian_chroot}
    #           "WINDOW_TITLE (venvprompt) [debian_chroot]"
    # try: _APP, VIRTUAL_ENV_NAME, $(basename VIRTUAL_ENV)
    local venvprompt=""
    venvprompt=${_APP:-${VIRTUAL_ENV_NAME:-${VIRTUAL_ENV:+"$(basename $VIRTUAL_ENV)"}}}
    # TODO: CONDA
    export VENVPROMPT="${venvprompt:+"($venvprompt) "}${debian_chroot:+"[$debian_chroot] "}${WINDOW_TITLE:+"$WINDOW_TITLE "}"
    if [ -n "$BASH_VERSION" ]; then
        if [ "$color_prompt" == yes ]; then
            PS1='${VENVPROMPT}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ '
        else
            PS1='${VENVPROMPT}\u@\h:\w\n\$ '
            unset color_prompt
        fi
    fi
}
_setup_venv_prompt



function venv_ls {
    # venv_ls()     -- list virtualenv directories
    prefix=${1:-${VIRTUAL_ENV}}
    if [ -z "${prefix}" ]; then
        return
    fi
    #ls -ld ${prefix}/**
    ls -ld $(find ${prefix} ${prefix}/lib -maxdepth 2 -type d)
}
function lsvenv {
    # lsvenv()      -- venv_ls()
    venv_ls $@
}

function venv_mkdirs {
    # venv_mkdirs()  -- create FSH paths in ${1} or ${VIRTUAL_ENV} 
    prefix=${1:-${VIRTUAL_ENV}}
    if [ -z "${prefix}" ]; then
        return
    fi
    ensure_mkdir "${prefix}"
    ensure_mkdir "${prefix}/bin"
    ensure_mkdir "${prefix}/etc"
    #ensure_mkdir  "${prefix}/home"
    ensure_mkdir "${prefix}/lib"
    #ensure_mkdir  "${prefix}/opt"
    #ensure_mkdir  "${prefix}/sbin"
    #ensure_mkdir  "${prefix}/share/doc"
    ensure_mkdir "${prefix}/src"
    #ensure_mkdir  "${prefix}/srv"
    ensure_mkdir "${prefix}/tmp"
    ensure_mkdir "${prefix}/usr/share/doc"
    ensure_mkdir "${prefix}/var/cache"
    ensure_mkdir "${prefix}/var/log"
    ensure_mkdir "${prefix}/var/run"
    ensure_mkdir "${prefix}/var/www"

    venv_ls "${prefix}"
}

