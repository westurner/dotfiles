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


_loadaliases() {
    # _loadaliases -- load shell aliases
    alias chmodr='chmod -R'
    alias chownr='chown -R'

    alias grep='grep --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'

    alias grindp='grind --sys.path'
    alias grinp='grin --sys-path'

    alias fumnt='fusermount -u'

    alias ga='git add'
    alias gl='git log --pretty=format:"%h : %an : %s" --topo-order --graph'
    alias gs='git status'
    alias gd='git diff'
    alias gds='git diff -p --stat'
    alias gc='git commit'
    alias gco='git checkout'
    alias gdc='git diff --cached'
    alias gsl='git stash list'
    alias gsn='git stash save'
    alias gss='git stash save'
    alias gitr='git remote -v'


    alias hgl='hg glog --pager=yes'
    alias hgs='hg status'
    alias hgd='hg diff'
    alias hgds='hg diff --stat'
    alias hgdl='hg diff --color=always | less -R'
    alias hgc='hg commit'
    alias hgu='hg update'
    alias hgq='hg qseries'
    alias hgqd='hg qdiff'
    alias hgqs='hg qseries'
    alias hgqn='hg qnew'
    alias hgr='hg paths'

    if [ -n "$__IS_MAC" ]; then
        alias la='ls -A -G'
        alias ll='ls -alF -G'
        alias ls='ls -G'
        alias lt='ls -altr -G'
    else
        alias la='ls -A --color=auto'
        alias ll='ls -alF --color=auto'
        alias ls='ls --color=auto'
        alias lt='ls -altr --color=auto'
    fi

    alias man_='/usr/bin/man'

    if [ -n "${__IS_LINUX}" ]; then
        alias psx='ps uxaw'
        alias psf='ps uxawf'
        alias psxs='ps uxawf --sort=tty,ppid,pid'
        alias psxh='ps uxawf --sort=tty,ppid,pid | head'

        alias psh='ps uxaw | head'

        alias psc='ps uxaw --sort=-pcpu'
        alias psch='ps uxaw --sort=-pcpu | head'

        alias psm='ps uxaw --sort=-pmem'
        alias psmh='ps uxaw --sort=-pmem | head'
    elif [ -n "${__IS_MAC}" ]; then
        alias psx='ps uxaw'
        alias psf='ps uxaw' # no -f

        alias psh='ps uxaw | head'

        alias psc='ps uxaw -c'
        alias psch='ps uxaw -c | head'

        alias psm='ps uxaw -m'
        alias psmh='ps uxaw -m | head'
    fi

    alias t='tail'
    alias xclip='xclip -selection c'

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
_loadaliases

hgst() {
    repo=${1:-"$(pwd)"}
    shift

    hgopts="-R '${repo}' --pager=no"

    if [ -n "$(echo "$@" | grep "color")" ]; then
        hgopts="${hgopts} --color=always"
    fi
    echo "###"
    echo "## $(pwd)"
    echo '###'
    hg ${hgopts} diff --stat | sed 's/^/## /' -
    echo '###'
    hg ${hgopts} status | sed 's/^/## /' -
    echo '###'
    hg ${hgopts} diff
    echo '###'
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

