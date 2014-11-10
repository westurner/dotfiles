### venv -- builds upon virtualenv and virtualenvwrapper
#   note: most of these aliases and functions are overwritten by `we` 
## Variables

    # __PROJECTSRC -- path to local project settings script
export __PROJECTSRC="${PROJECT_HOME}/.projectsrc.sh"
[ -f $__PROJECTSRC ] && source $__PROJECTSRC

    # __SRC        -- path/symlink to local repository ($__SRC/hg $__SRC/git)
export __SRC="${HOME}/src"
[ ! -d $__SRC ] && mkdir -p $__SRC/hg $__SRC/git


    # PATH="~/.local/bin:$PATH" (if not already there)
add_to_path "${HOME}/.local/bin"

    # _VENV       -- path to local venv config script (executable)
export _VENV="${__DOTFILES}/etc/ipython/ipython_config.py"

## Functions


venv() {
    # venv $@   -- call $_VENV $@
    # venv -h   -- print venv --help
    # venv -b   -- print bash configuration
    # venv -p   -- print IPython configuration as JSON
    $_VENV $@
}

venv-() {
    # _venv <args> -- call $_VENV -E $@ (for the current environment)
    venv -E $@
}

we() {   
    # we()         -- workon a virtualenv and load venv (TAB-completion)
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
    # grinv     -- grin $VIRTUAL_ENV
    grin --follow $@ "${VIRTUAL_ENV}"
}
grindv() {
    # grindv    -- grind $VIRTUAL_ENV
    grind --follow $@ --dirs "${VIRTUAL_ENV}"
}

# venv
grins() {
    # grins     -- grin $_SRC
    grin --follow $@ "${_SRC}"
}
grinds() {
    # grinds    -- grind $_SRC
    grind --follow $@ --dirs "${_SRC}"
}
grinw() {
    # grinw     -- grin $_WRD
    grin --follow $@ "${_WRD}"
}
grin-() {
    # grin-     -- grin _WRD
    grinw $@
}
grindw() {
    # grindw    -- grind $_WRD
    grind --follow $@ --dirs "${_WRD}"
}
grind-() {
    # grind-    -- grind $_WRD
    grindw $@
}

grindctags() {
    # grindctags    -- generate ctags from grind expression (*.py by default)
    args="$@"
    if [ -z $args ]; then
        args='*.py'
    fi
    grind --follow "$args" | ctags -L -
}

_load_venv_aliases() {
    # _load_venv_aliases -- load venv aliases
    #   (note: these are overwritten by `we` [`source <(venv -b)`])

    alias ssv='supervisord -c "${_SVCFG}"'
    alias sv='supervisorctl -c "${_SVCFG}"'
    alias svd='supervisorctl -c "${_SVCFG}" restart dev && supervisorctl -c "${_SVCFG}" tail -f dev'
    alias svt='sv tail -f'

    alias hgv-='hg view -R "${_WRD}"'
    alias hgl-='hg -R "${_WRD}" log'

    alias serve-='${_SERVE_}'
    alias shell-='${_SHELL_}'
    alias test-='(cd ${_WRD} && python "${_WRD_SETUPY}" test)'
    alias testr-='(reset; cd ${_WRD} && python "${_WRD_SETUPY}" test)'

}
_load_venv_aliases

makew() {
    # makew     -- cd $_WRD && make $@
    (cd "${_WRD}" && make $@)
}
make-() {
    # make-     -- cd $_WRD && make $@
    makew $@
}
mw() {
    # mw        -- cd $_WRD && make $@
    makew $@
}

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

