## .bashrc.venv.sh
#
# sh configuration
# intended to be sourced from (after) ~/.bashrc
## Variables

    # __PROJECTSRC -- path to local project settings script
export __PROJECTSRC="${PROJECT_HOME}/.projectsrc.sh"
[ -f $__PROJECTSRC ] && source $__PROJECTSRC

    # __SRC        -- path/symlink to local repository ($__SRC/hg $__SRC/git)
export __SRC="${HOME}/src"  # TODO: __SRC_HG, __SRC_GIT
[ ! -d $__SRC ] && mkdir -p $__SRC/hg $__SRC/git


    # PATH="~/.local/bin:$PATH" (if not already there)
add_to_path "${HOME}/.local/bin"

    # _VENV       -- path to local venv config script (executable)
export _VENV="${__DOTFILES}/etc/ipython/ipython_config.py"

## Functions

venv() {
    # venv <args>  -- call $_VENV $@
    $_VENV  $@
}

_venv() {
    # _venv <args> -- call $_VENV -E $@
    venv -E $@
}

we() {   
    # we()         -- workon a virtualenv and load venv
    #  param $1: $VIRTUAL_ENV_NAME ("dotfiles")
    #  param $2: $_APP ("dotfiles") [default: $1)
    #   ${WORKON_HOME}/${VIRTUAL_ENV_NAME}  # == $VIRTUAL_ENV
    #   ${VIRTUAL_ENV}/src                  # == $_SRC
    #   ${_SRC}/${VIRTUAL_ENV_NAME}         # == $_WRD
    #  examples:
    #   we dotfiles
    #   we dotfiles dotfiles

    # append to shell history
    history -a

    if [ -n "$1" ]; then
        workon $1 && source <(venv --bash $@) && dotfiles_status
    else
        # if no arguments are specified, list virtual environments
        lsvirtualenv
    fi
}

## Completion
complete -o default -o nospace -F _virtualenvs we

## CD shortcuts

cdb () {
    # cdb      -- cd $_BIN
    cd "${_BIN}"/$@
}
cde () {
    # cde      -- cd $_ETC
    cd "${_ETC}"/$@
}
cdv () {
    # cdv      -- cd $VIRTUAL_ENV
    cd "${VIRTUAL_ENV}"/$@
}
cdve () {
    # cdve     -- cd $WORKON_HOME
    cd "${WORKON_HOME}"/$@
}
cdvar () {
    # cdvar    -- cd $_VAR
    cd "${_VAR}"/$@
}
cdlog () {
    # cdlog    -- cd $_LOG
    cd "${_LOG}"/$@
}
cdww () {
    # cdww     -- cd $_WWW
    cd "${_WWW}"/$@
}
cdl () {
    # cdl      -- cd $_LIB
    cd "${_LIB}"/$@
}
cdpylib () {
    # cdpylib  -- cd $_PYLIB
    cd "${_PYLIB}"/$@
}
cdpysite () {
    # cdpysite -- cd $_PYSITE
    cd "${_PYSITE}"/$@
}
cds () {
    # cds      -- cd $_SRC
    cd "${_SRC}"/$@
}
cdw () {
    # cdw      -- cd $_WRD
    cd "${_WRD}"/$@
}

cdwrk () {
    # cdwrk     -- cd $WORKON_HOME
    cd "${WORKON_HOME}/$@"
}

## Grin search
# virtualenv / virtualenvwrapper
grinv() {
    # grinv    -- grin $VIRTUAL_ENV
    grin --follow $@ "${VIRTUAL_ENV}"
}
grindv() {
    # grindv   -- grind $VIRTUAL_ENV
    grind --follow $@ --dirs "${VIRTUAL_ENV}"
}

# venv
grins() {
    # grins    -- grin $_SRC
    grin --follow $@ "${_SRC}"
}
grinds() {
    # grinds   -- grind $_SRC
    grind --follow $@ --dirs "${_SRC}"
}
grinw() {
    # grinw    -- grin $_WRD
    grin --follow $@ "${_WRD}"
}
grindw() {
    # grindw   -- grind $_WRD
    grind --follow $@ --dirs "${_WRD}"
}

grindctags() {
    # grindctags   -- generate ctags from grind expression (*.py by default)
    args="$@"
    if [ -z $args ]; then
        args='*.py'
    fi
    grind --follow "$args" | ctags -L -
}

_load_venv_aliases() {
    # _load_venv_aliases -- load venv aliases

    alias ssv='supervisord -c "${_SVCFG}"'
    alias sv='supervisorctl -c "${_SVCFG}"'
    alias svd='supervisorctl -c "${_SVCFG}" restart dev && supervisorctl -c "${_SVCFG}" tail -f dev'
    alias svt='sv tail -f'

    alias _glog='hgtk -R "${_WRD}" log'
    alias _log='hg -R "${_WRD}" log'
    alias _make='cd "${_WRD}" && make'
    alias _serve='${_SERVE_}'
    alias _shell='${_SHELL_}'
    alias _test='python "${_WRD_SETUPY}" test'

}
_load_venv_aliases

_venv_set_prompt() {
    if [ -n "$VIRTUAL_ENV_NAME" ]; then
        if [ -n "$VIRTUAL_ENV" ]; then
            export VIRTUAL_ENV_NAME="$(basename $VIRTUAL_ENV)" # TODO
        else
            unset -v VIRTUAL_ENV_NAME
        fi
    fi
    venv_prompt_prefix="${WINDOW_TITLE:+"$WINDOW_TITLE "}${VIRTUAL_ENV_NAME:+"($VIRTUAL_ENV_NAME) "}${debian_chroot:+"[$debian_chroot] "}"
    if [ -n "$BASH_VERSION" ]; then
        if [ "$color_prompt" == yes ]; then
            PS1='${venv_prompt_prefix}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ '
        else
            PS1='${venv_prompt_prefix}\u@\h:\w\n\$ '
            unset color_prompt
        fi
    fi
}
_venv_set_prompt

