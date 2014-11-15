### bashrc.venv.sh
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

    #append to shell history
    history -a

    if [ -n "$1" ]; then
        workon $1 && source <(venv --bash $@) && dotfiles_status
    else
        #if no arguments are specified, list virtual environments
        lsvirtualenv
    fi
}
complete -o default -o nospace -F _virtualenvs we


## cd functions
cdb () {
    # cdb()     -- cd $_BIN
    cd "${_BIN}"/$@
}
cde () {
    # cde()     -- cd $_ETC
    cd "${_ETC}"/$@
}
cdh () {
    # cdh()     -- cd $HOME
    cd "${HOME}"/$@
}
cdl () {
    # cdl()     -- cd $_LIB
    cd "${_LIB}"/$@
}
cdlog () {
    # cdlog()   -- cd $_LOG
    cd "${_LOG}"/$@
}
cdp () {
    # cdp()     -- cd $PROJECT_HOME
    cd "${PROJECT_HOME}"/$@
}
cdph () {
    # cdph()    -- cd $PROJECT_HOME
    cd "${PROJECT_HOME}"/$@
}
cdpylib () {
    # cdpylib() -- cd $_PYLIB
    cd "${_PYLIB}"/$@
}
cdpysite () {
    # cdpysite()-- cd $_PYSITE
    cd "${_PYSITE}"/$@
}
cds () {
    # cds()     -- cd $_SRC
    cd "${_SRC}"/$@
}
cdv () {
    # cdv()     -- cd $VIRTUAL_ENV
    cd "${VIRTUAL_ENV}"/$@
}
cdve () {
    # cdve()    -- cd $WORKON_HOME
    cd "${WORKON_HOME}"/$@
}
cdvar () {
    # cdvar()   -- cd $_VAR
    cd "${_VAR}"/$@
}
cdw () {
    # cdw()     -- cd $_WRD
    cd "${_WRD}"/$@
}
cdwrd () {
    # cdwrd     -- cd $_WRD
    cd "${_WRD}"/$@
}
cdwh () {
    # cdwh      -- cd $WORKON_HOME
    cd "${WORKON_HOME}"/$@
}
cdwrk () {
    # cdwrk()   -- cd $PROJECT_HOME
    cd "${PROJECT_HOME}/$@"
}
cdww () {
    # cdww()    -- cd $_WWW
    cd "${_WWW}"/$@
}
cdwww () {
    # cdwww()   -- cd $_WWW
    cd "${_WWW}"/$@
}

## Grin search
# virtualenv / virtualenvwrapper
grinv() {
    # grinv()   -- grin $VIRTUAL_ENV
    grin --follow $@ "${VIRTUAL_ENV}"
}
grindv() {
    # grindv()  -- grind $VIRTUAL_ENV
    grind --follow $@ --dirs "${VIRTUAL_ENV}"
}

# venv
grins() {
    # grins()   -- grin $_SRC
    grin --follow $@ "${_SRC}"
}
grinds() {
    # grinds()  -- grind $_SRC
    grind --follow $@ --dirs "${_SRC}"
}
grinw() {
    # grinw()   -- grin $_WRD
    grin --follow $@ "${_WRD}"
}
grin-() {
    # grin-()   -- grin _WRD
    grinw $@
}
grindw() {
    # grindw()  -- grind $_WRD
    grind --follow $@ --dirs "${_WRD}"
}
grind-() {
    # grind-()  -- grind $_WRD
    grindw $@
}

edit_grin_w() {
    # edit_grin_w() -- edit $(grinw -l $@)
    edit $(grin w -l $@)
}

egw() {
    # egw           -- edit $(grinw -l $@)
    edit_grin_w $@
}

grindctags() {
    # grindctags()      -- generate ctags from grind (in ./tags)
    if [ -n "${__IS_MAC}" ]; then
        if [ -x "/usr/local/bin/ctags" ]; then
            ctagsbin="/usr/local/bin/ctags"
        fi
    else
        ctagsbin=$(which ctags)
    fi
    (set -x;
    path=${1:-'.'}
    grindargs=${2}
    cd ${path}; grind --follow ${grindargs} \
        | grep -v 'min.js$' \
        | ${ctagsbin} -L - 2>tags.err && \
    wc -l ${path}/tags.err;
    ls -alh ${path}/tags;)
}
grindctagssys() {
    # grindctagssys()   -- generate ctags from grind --sys-path ($_WRD/tags)
    grindctags "${_WRD}" "--sys-path"
}
grindctagsw() {
    # grindctagsw()     -- generate ctags from (cd $_WRD; grind) ($_WRD/tags)
    grindctags "${_WRD}"
}
grindctagss() {
    # grindctagss()     -- generate ctags from (cd $_SRC; grind) ($_SRC/tags)
    grindctags "${_SRC}"
}



_load_venv_aliases() {
    # _load_venv_aliases()  -- load venv aliases
    #   note: these are overwritten by `we` [`source <(venv -b)`]

    # ssv()     -- supervisord   -c ${_SVCFG}
    alias ssv='supervisord -c "${_SVCFG}"'
    # sv()      -- supervisorctl -c ${_SVCFG}
    alias sv='supervisorctl -c "${_SVCFG}"'
    # svd()     -- supervisorctl -c ${_SVCFG} restart && sv tail -f dev
    alias svd='supervisorctl -c "${_SVCFG}" restart dev && supervisorctl -c "${_SVCFG}" tail -f dev'
    # svt()     -- supervisorctl -c "${_SVCFG}" tail -f
    alias svt='sv tail -f'

    # hgw()     -- hg -R  ${_WRD}
    alias hgw='hg -R "${_WRD}"'
    # hg-()     -- hg -R  ${_WRD}
    alias hg-='hg -R "${_WRD}"'

    # gitw()    -- git -C ${_WRD}
    alias gitw='git -C "${_WRD}"'
    # git-()    -- git -C ${_WRD}
    alias git-='git -C "${_WRD}"'

    # serve-()  -- ${_SERVE_}
    alias serve-='${_SERVE_}'
    # shell-()  -- ${_SHELL_}
    alias shell-='${_SHELL_}'
    # test-()   -- cd ${_WRD} && python setup.py test
    alias test-='(cd ${_WRD} && python "${_WRD_SETUPY}" test)'
    # testr-()  -- reset; cd ${_WRD} && python setup.py test
    alias testr-='(reset; cd ${_WRD} && python "${_WRD_SETUPY}" test)'

}
_load_venv_aliases

makew() {
    # makew()   -- cd $_WRD && make $@
    (cd "${_WRD}" && make $@)
}
make-() {
    # make-()   -- cd $_WRD && make $@
    makew $@
}
mw() {
    # mw()      -- cd $_WRD && make $@
    makew $@
}

_venv_set_prompt() {
    # _venv_set_prompt()    -- set PS1 with $WINDOW_TITLE, $VIRTUAL_ENV_NAME,
    #                          and ${debian_chroot}
    if [ -n "$VIRTUAL_ENV_NAME" ]; then
        if [ -n "$VIRTUAL_ENV" ]; then
            export VIRTUAL_ENV_NAME="$(basename $VIRTUAL_ENV)"
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


mkdirs_venv() {
    # _venv_ensure_paths()  -- create FSH paths in ${1} or ${VIRTUAL_ENV} 
    prefix=${1}
    if [ -z "${prefix}" ]; then
        if [ -n "${VIRTUAL_ENV}" ]; then
            prefix=${VIRTUAL_ENV}
        else
            return
        fi
    fi
    ensure_mkdir ${prefix}
    ensure_mkdir ${prefix}/bin
    ensure_mkdir ${prefix}/etc
    #ensure_mkdir ${prefix}/home
    ensure_mkdir ${prefix}/lib
    #ensure_mkdir ${prefix}/opt
    #ensure_mkdir ${prefix}/sbin
    #ensure_mkdir ${prefix}/share/doc
    ensure_mkdir ${prefix}/src
    #ensure_mkdir ${prefix}/srv
    ensure_mkdir ${prefix}/tmp
    ensure_mkdir ${prefix}/usr/share/doc
    ensure_mkdir ${prefix}/var/cache
    ensure_mkdir ${prefix}/var/log
    ensure_mkdir ${prefix}/var/run
    ensure_mkdir ${prefix}/var/www

    #ls -ld ${prefix}/**
    ls -ld $(find ${prefix} ${prefix}/lib -type d -maxdepth 2)
}

