## .bashrc.venv.sh
# 
# sh configuration
# intended to be sourced from (after) ~/.bashrc
#

export CLICOLOR=true

#  __PROJECTS -- local project settings script
export __PROJECTS="${PROJECT_HOME}/.projectsrc.sh"

### source $__PROJECTS script, if it exists
[ -f $__PROJECTS ] && source $__PROJECTS

#  __SRC       -- (symlink to) local repositories
export __SRC="${HOME}/src"  # TODO: __SRC_HG, __SRC_GIT
[ ! -d $__SRC ] && mkdir -p $__SRC/hg $__SRC/git


# Add ~/.local/bin to $PATH
add_to_path "${HOME}/.local/bin"

# #TODO: Link to the venv configuration script ?
export _VENV="${__DOTFILES}/etc/ipython/ipython_config.py"

venv() {
    $_VENV  $@
}

_venv() {
    venv -E $@
}

we () {
    workon $1 && source <($_VENV --bash $@)
}


## CD shortcuts

cdb () {
    cd "${_BIN}"/$@
}
cde () {
    cd "${_ETC}"/$@
}
cdv () {
    cd "${VIRTUAL_ENV}"/$@
}
cdve () {
    cd "${WORKON_HOME}"/$@
}
cdvar () {
    cd "${_VAR}"/$@
}
cdlog () {
    cd "${_LOG}"/$@
}
cdww () {
    cd "${_WWW}"/$@
}
cdl () {
    cd "${_LIB}"/$@
}
cdpylib () {
    cd "${_PYLIB}"/$@
}
cdpysite () {
    cd "${_PYSITE}"/$@
}
cds () {
    cd "${_SRC}"/$@
}

cdw () {
    cd "${_WRD}"/$@
}

## Grin search
# virtualenv / virtualenvwrapper
grinv() {
    grin --follow $@ "${VIRTUAL_ENV}"
}
grindv() {
    grind --follow $@ --dirs "${VIRTUAL_ENV}"
}

# venv
grins() {
    grin --follow $@ "${_SRC}"
}
grinds() {
    grind --follow $@ --dirs "${_SRC}"
}
grinw() {
    grin --follow $@ "${_WRD}"
}
grindw() {
    grind --follow $@ --dirs "${_WRD}"
}

grindctags() {
    args="$@"
    if [ -z $args ]; then
        args='*.py'
    fi
    grind --follow "$args" | ctags -L -
}


_loadaliases() {

    # some more ls aliases
    alias ll='ls -alF'
    alias la='ls -A'
    alias lt='ls -altr'

    alias _glog='hgtk -R "${_WRD}" log'
    alias _log='hg -R "${_WRD}" log'
    alias _make='cd "${_WRD}" && make'
    alias _serve='${_SERVE_}'
    alias _shell='${_SHELL_}'
    alias _test='python "${_WRD_SETUPY}" test'
    alias chmodr='chmod -R'
    alias chownr='chown -R'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias fumnt='fusermount -u'
    alias gitdiffstat='git diff -p --stat'
    alias gitlog='git log --pretty=format:"%h : %an : %s" --topo-order --graph'
    alias grep='grep --color=auto'
    alias grindp='grind --sys.path'
    alias grinp='grin --sys-path'
    alias hgl='hg log -l10'
    alias hgs='hg status'
    alias hgd='hg diff'
    alias hgdl='hg diff --color=always | less -R'
    alias ifc='ifconfig'
    alias ish='ipython -p shell'
    alias la='ls -A --color=auto'
    alias ll='ls -alF --color=auto'
    alias ls='ls --color=auto'
    alias lt='ls -altr --color=auto'
    alias man_='/usr/bin/man'
    alias pfx='ps aufxw'
    alias pfxs='ps aufxw --sort=tty,ppid,pid'
    alias pyclean='find . -type f -name "*.py[co]" -exec rm -f \{\} \;'
    alias ssv='supervisord -c "${_SVCFG}"'
    alias sv='supervisorctl -c "${_SVCFG}"'
    alias svd='supervisorctl -c "${_SVCFG}" restart dev && supervisorctl -c "${_SVCFG}" tail -f dev'
    alias svt='sv tail -f'
    alias t='tail'
    alias xclip='xclip -selection c'

    if [ -n "$__IS_MAC" ]; then
        alias la='ls -A -G'
        alias ll='ls -alF -G'
        alias ls='ls -G'
        alias lt='ls -altr -G'
    fi
}
_loadaliases


_set_prompt() {
    if [ -n "$VIRTUAL_ENV_NAME" ]; then
        if [ -n "$VIRTUAL_ENV" ]; then
            export VIRTUAL_ENV_NAME="$(basename $VIRTUAL_ENV)" # TODO
        else
            unset -v VIRTUAL_ENV_NAME
        fi
    fi

    if [ -n "$BASH_VERSION" ]; then
        if [ "$color_prompt" = yes ]; then
            PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ '
        else
            PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\n\$ '
            unset color_prompt
        fi
    fi
}
_set_prompt

