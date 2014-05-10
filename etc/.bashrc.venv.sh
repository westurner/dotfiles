## .bashrc.venv.sh
# 
# sh configuration
# intended to be sourced from (after) ~/.bashrc
#
# 

reload() {
    source ~/.bashrc
    # * source .dotfiles/etc/.bashrc.venv.sh
    #   * source .dotfiles/etc/usrlog.sh
    #   * source .dotfiles/etc/xlck.sh
    #   * source .dotfiles/etc/bashmarks/bashmarks.sh
    #   * source .dotfiles/etc/.bashrc.aliases.sh
    #   * source .dotfiles/etc/.bashrc.repos.sh

}


export CLICOLOR=true

# see: add_to_path ${HOME}/.local/bin
# export PATH="${HOME}/.local/bin:${PATH}"


## Virtualenvwrapper
# sudo apt-get install virtualenvwrapper || easy_install virtualenvwrapper
export PROJECT_HOME="${HOME}/wrk"
declare -x WORKON_HOME="${PROJECT_HOME}/.ve"

## Venv

#  __DOTFILES -- local dotfiles repository clone
export __DOTFILES="${WORKON_HOME}/dotfiles/src/dotfiles"

#  __PROJECTS -- local project settings script
export __PROJECTS="${PROJECT_HOME}/.projectsrc.sh"

#  __SRC       -- (symlink to) local repositories
export __SRC="${HOME}/src"  # TODO: __SRC_HG, __SRC_GIT
[ ! -d $__SRC ] && mkdir -p $__SRC/hg $__SRC/git

export _DOCSHTML="${HOME}/docs"
[ ! -d $_DOCSHTML ] && mkdir -p $_DOCSHTML



## $PATH

add_to_path ()
{
    ## http://superuser.com/questions/ \
    ##   39751/add-directory-to-path-if-its-not-already-there/39840#39840
    if [[ "$PATH" =~ (^|:)"${1}"(:|$) ]]; then
        return 0
    fi
    export PATH=$1:$PATH
}

if [ -d "${__DOTFILES}" ]; then
    # Add dotfiles executable directories to $PATH
    add_to_path "${__DOTFILES}/bin"
    add_to_path "${__DOTFILES}/scripts"
fi


# Add ~/.local/bin to $PATH
add_to_path "${HOME}/.local/bin"


## usrlog   -- Userspace shell logging
#  stid -- set or regenerate shell session id
#  
source "${__DOTFILES}/etc/usrlog.sh"
_setup_usrlog

## xlck     -- screensaver
if [ ! -d '/Library' ]; then  # not on OSX
    source "${__DOTFILES}/etc/xlck.sh"
fi

## bashmarks
#  l    -- list bashmarks
#  s    -- save bashmarks as $1
#  g    -- goto bashmark $1
#  p    -- print bashmark $1
#  d    -- delete bashmark $1
source "${__DOTFILES}/etc/bashmarks/bashmarks.sh"
#  lsbashmarks -- list Bashmarks (e.g. for NERDTree)
lsbashmarks () {
    export | grep 'DIR_' | pyline "line[15:].replace('\"','').split('=',1)"
}


## Editor
#export USEGVIM=""
_setup_editor() {
    # Configure $EDITOR
    export VIMBIN="/usr/bin/vim"
    export GVIMBIN="/usr/bin/gvim"
    export MVIMBIN="/usr/local/bin/mvim"

    [ -f $GVIMBIN ] && export USEGVIM="true" || export USEGVIM=""

    export EDITOR="${VIMBIN}"
    export SUDO_EDITOR="${VIMBIN}"

    if [ -n "${USEGVIM}" ]; then
        VIMCONF='--servername '${VIRTUAL_ENV_NAME:-main}' --remote-tab-silent'
        SUDOCONF="--servername sudo.${VIRTUAL_ENV_NAME:-main} --remote-tab-wait-silent"
        if [ -x "${GVIMBIN}" ]; then
            export EDITOR="${GVIMBIN} ${VIMCONF}"
            export SUDO_EDITOR="${GVIMBIN} ${SUDOCONF}"
        elif [ -x "${MVIMBIN}" ]; then
            export GVIMBIN=$MVIMBIN
            export EDITOR="${MVIMBIN} ${VIMCONF}"
            export SUDO_EDITOR="${MVIMBIN} ${SUDOCONF} "
            alias vim='${EDITOR} -f'
            alias gvim='${EDITOR} -f'
        else
            unset -f $GVIMBIN
            unset -f $MVIMBIN
        fi
    else
        unset -f $GVIMBIN
        unset -f $MVIMBIN
        unset -f $USEGVIM
    fi

    export _EDIT_="${EDITOR}"

    ggvim() {
        $EDITOR $@ 2>&1 > /dev/null
    }

    alias _edit='$EDITOR'
    alias _editcfg='$EDITOR \"${_CFG}\"'
    alias _gvim='$EDITOR'
    alias e='$EDITOR'
    alias edit='$EDITOR'
    alias sudogvim='EDITOR="${SUDO_EDITOR}" sudo -e'
    alias sudovim='EDITOR="${SUDO_EDITOR}" sudo -e'
}
_setup_editor



### Python/Virtualenv[wrapper] setup

_setup_python () {
    # Python
    export PYTHONSTARTUP="${HOME}/.pythonrc"
    #export PIP_REQUIRE_VIRTUALENV=true
    export PIP_REQUIRE_VIRTUALENV=false
    #alias ipython="python -c 'import IPython;IPython.Shell.IPShell().mainloop()'"

}
_setup_python


## pyvenv
setup_pyenv() {
    export PYENV_ROOT="${HOME}/.pyenv"
    add_to_path "${PYENV_ROOT}/bin"
    eval "$(pyenv init -)"
    pyenv virtualenvwrapper
}

setup_anaconda() {
    export _ANACONDA_ROOT="/opt/anaconda"
    add_to_path "${_ANACONDA_ROOT}/bin"
}

_setup_virtualenvwrapper () {
    #export VIRTUALENVWRAPPER_SCRIPT="/usr/local/bin/virtualenvwrapper.sh"
    export VIRTUALENVWRAPPER_SCRIPT="${HOME}/.local/bin/virtualenvwrapper.sh"
    export VIRTUALENVWRAPPER_HOOK_DIR="${__DOTFILES}/etc/virtualenvwrapper" # TODO: FIXME
    export VIRTUALENVWRAPPER_LOG_DIR="${PROJECT_HOME}/.virtualenvlogs"
    export VIRTUALENVWRAPPER_PYTHON='/usr/bin/python' # TODO
    export VIRTUALENV_DISTRIBUTE='true'
    source "${VIRTUALENVWRAPPER_SCRIPT}"

    #alias cdv='cdvirtualenv'
    #alias cds='cdvirtualenv src'
    #alias cde='cdvirtualenv etc'
    #alias cdl='cdvirtualenv lib'
    #alias cde='cdvirtualenv src/$_VENVNAME'

}
_setup_virtualenvwrapper

lsvirtualenv() {
    cmd=${1:-"echo"}
    for venv in $(ls -adtr "${WORKON_HOME}"/**/lib/python?.? | \
        sed "s:$WORKON_HOME/\(.*\)/lib/python[0-9]\.[0-9]:\1:g"); do
        $cmd $venv/
    done
}
lsve() {
    lsvirtualenv $@
}

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
grinv() {
    grin --follow $@ "${VIRTUAL_ENV}"
}
grindv() {
    grind --follow $@ --dirs "${VIRTUAL_ENV}"
}
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
    alias gvim='gvim'
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
    alias pyclean='find . -type f -name "*.py[co]" -exec rm -f \{\} \;'
    alias ssv='supervisord -c "${_SVCFG}"'
    alias sv='supervisorctl -c "${_SVCFG}"'
    alias svd='supervisorctl -c "${_SVCFG}" restart dev && supervisorctl -c "${_SVCFG}" tail -f dev'
    alias svt='sv tail -f'
    alias t='tail'
    alias xclip='xclip -selection c'

    if [ -x "$MVIMBIN" ]; then
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

    if [ "$color_prompt" = yes ]; then
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ '
    else
        PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\n\$ '
        unset color_prompt
    fi
}
_set_prompt


source $__DOTFILES/etc/.bashrc.vim.sh

source $__DOTFILES/etc/.bashrc.aliases.sh

source $__DOTFILES/etc/.bashrc.repos.sh

### source $__PROJECTS script, if it exists
[ -f $__PROJECTS ] && source $__PROJECTS
