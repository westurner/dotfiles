bash: no job control in this shell
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
if [ -z "$PS1" ]; then
    return
fi

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi


case "$TERM" in
    xterm-color)
        color_prompt=yes
        ;;
    *)
        if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
            # We have color support; assume it's compliant with Ecma-48
            # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
            # a case would tend to support setf rather than setaf.)
            color_prompt=yes
        else
            color_prompt=
        fi
        ;;
esac


# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
esac

#TODO: set this on load


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    source /etc/bash_completion
fi

#
### load the dotfiles
#  ln -s ${WORKON_HOME}/dotfiles/src/dotfiles ~/.dotfiles
__DOTFILES=${__DOTFILES:-"$HOME/.dotfiles"}
if [ -n $__DOTFILES ] && [ -d $__DOTFILES ]; then
    _dotfiles_bashrc="${__DOTFILES}/etc/bash/00-bashrc.before.sh"
    if [[ -f "${_dotfiles_bashrc}" ]]; then
        source "${_dotfiles_bashrc}"
    else
        echo "ERROR: _dotfiles_bashrc: ${_dotfiles_bashrc}"
    fi
fi
#!/bin/bash
## 00-bashrc.before.sh     -- bash dotfiles configuration root
#  source ${__DOTFILES}/etc/bash/00-bashrc.before.sh    -- dotfiles_reload()
#
dotfiles_reload() {
  #  dotfiles_reload()  -- (re)load the bash configuration
  #  $__DOTFILES (str): -- path to the dotfiles symlink (~/.dotfiles)

  echo "#"
  echo "# dotfiles_reload()"

  if [ -n $__DOTFILES ]; then
  export __DOTFILES=${__DOTFILES}
  else
  _dotfiles_src=${WORKON_HOME}/dotfiles/src/dotfiles
  _dotfiles_link=${HOME}/.dotfiles

  if [ -d $_dotfiles_link ]; then
  __DOTFILES=${_dotfiles_link}
  elif [ -d $_dotfiles_src ]; then
  __DOTFILES=${_dotfiles_src}
  fi
  export __DOTFILES=${__DOTFILES}
  fi

  conf=${__DOTFILES}/etc/bash

  #
  ## 01-bashrc.lib.sh           -- useful bash functions (paths)
  #  lspath()           -- list every file along $PATH
  #  realpath()         -- readlink -f (python os.path.realpath)
  #  walkpath()         -- list every directory along ${1:-"."}
  source ${conf}/01-bashrc.lib.sh

  #
  ## 02-bashrc.platform.sh      -- platform things
  source ${conf}/02-bashrc.platform.sh
  detect_platform
  #  detect_platform()  -- set $__IS_MAC or $__IS_LINUX 
  if [ -n "${__IS_MAC}" ]; then
      export PATH=$(echo ${PATH} | sed 's,/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin,/usr/sbin:/sbin:/bin:/usr/local/bin:/usr/bin,')
  fi

  #
  ## 03-bashrc.readline.sh      -- readline
  source ${conf}/03-bashrc.readline.sh

  #
  ## 04-bashrc.TERM.sh          -- set $TERM and $CLICOLOR
  source ${conf}/04-bashrc.TERM.sh

  #
  ## 05-bashrc.dotfiles.sh      -- dotfiles
  #  $__DOTFILES (str): -- path to the dotfiles symlink (~/.dotfiles)
  #  dotfiles_status()  -- print dotfiles variables
  #  ds()               -- print dotfiles variables
  source ${conf}/05-bashrc.dotfiles.sh
  dotfiles_add_path

  #
  ## 06-bashrc.completion.sh    -- configure bash completion
  source ${conf}/06-bashrc.completion.sh

  #
  #  python: pip, virtualenv, virtualenvwrapper
  #  $PROJECT_HOME (str): path to project directory (~/wrk)
  #  $WORKON_HOME  (str): path to virtualenvs directory (~/wrk/.ve)
  #  $VIRTUAL_ENV  (str): path to current $VIRTUAL_ENV

  #
  ## 07-bashrc.python.sh        -- python
  #  _setup_anaconda()  -- setup anaconda paths (manual)
  #  _setup_pyenv()     -- setup pyenv paths (manual)
  source ${conf}/07-bashrc.python.sh

  #
  ## 07-bashrc.virtualenvwrapper.sh -- virtualenvwrapper
  source ${conf}/07-bashrc.virtualenvwrapper.sh

  #
  ## 08-bashrc.gcloud.sh        -- gcloud: Google Cloud SDK
  #  _setup_google_cloud()  -- setup google cloud paths
  source ${conf}/08-bashrc.gcloud.sh

  #
  ## 10-bashrc.venv.sh          -- venv: virtualenvwrapper extensions
  #  $__PROJECTSRC     (str): script to source (${PROJECT_HOME}/.projectsrc.sh)
  #  $VIRTUAL_ENV_NAME (str): basename of current $VIRTUAL_ENV
  #  $_APP             (str): $VIRTUAL_ENV/src/${_APP}
  #  we() -- workon a new venv
  #     $1: VIRTUAL_ENV_NAME [$WORKON_HOME/${VIRTUAL_ENV_NAME}=$VIRTUAL_ENV]
  #     $2: _APP (optional; defaults to $VIRTUAL_ENV_NAME)
  #     we dotfiles
  #     we dotfiles etc/bash; cdw; ds; ls
  source ${conf}/10-bashrc.venv.sh
  #

  #
  ## 11-bashrc.venv.pyramid.sh  -- venv-pyramid: pyramid-specific config
  source ${conf}/11-bashrc.venv.pyramid.sh

  #
  ## 20-bashrc.editor.sh        -- $EDITOR configuration
  #  $_EDIT_ (str): cmdstring to open $@ (file list) in current editor
  #  $EDITOR (str): cmdstring to open $@ (file list) in current editor
  source ${conf}/20-bashrc.editor.sh
  ## 20-bashrc.vimpagers.sh     -- $PAGER configuration
  #  $PAGER (str): cmdstring to run pager (less/vim)
  source ${conf}/29-bashrc.vimpagers.sh

  #
  ## 30-bashrc.usrlog.sh        -- $_USRLOG configuration
  #  $_USRLOG (str): path to .usrlog command log
  #  stid       -- set $TERM_ID to a random string
  #  stid $name -- set $TERM_ID to string
  #  note       -- add a dated note to $_USRLOG [_usrlog_append]
  #  usrlogv    -- open usrlog with vim:   $VIMBIN + $_USRLOG
  #  usrlogg    -- open usrlog with gmvim: $GUIVIMBIN + $_USRLOG
  #  usrloge    -- open usrlog with editor:$EDITOR + $_USRLOG
  #  ut         -- tail $_USRLOG
  #  ug         -- egrep current usrlog: egrep $@ $_USRLOG
  #  ugall      -- egrep $@ $__USRLOG ${WORKON_HOME}/*/.usrlog
  #  ugrin      -- grin current usrlog: grin $@ $_USRLOG
  #  ugrinall   -- grin $@  $__USRLOG ${WORKON_HOME}/*/.usrlog
  #  lsusrlogs  -- ls -tr   $__USRLOG ${WORKON_HOME}/*/.usrlog
  source ${conf}/30-bashrc.usrlog.sh

  #
  ## 30-bashrc.xlck.sh          -- screensaver, (auto) lock, suspend
  source ${conf}/30-bashrc.xlck.sh

  #
  ## 40-bashrc.aliases.sh       -- aliases
  source ${conf}/40-bashrc.aliases.sh
  ## 42-bashrc.commands.sh      -- example commands
  source ${conf}/42-bashrc.commands.sh

  #
  ## 50-bashrc.bashmarks.sh     -- bashmarks: local bookmarks
  source ${conf}/50-bashrc.bashmarks.sh

  #
  ## 70-bashrc.repos.sh         -- repos: $__SRC repos, docs
  source ${conf}/70-bashrc.repos.sh

  #
  ## 99-bashrc.after.sh         -- after: cleanup
  source ${conf}/99-bashrc.after.sh
}

dr() {
    # dr()  -- dotfiles_reload
    dotfiles_reload $@
}
    # ds()  -- print dotfiles_status()

dotfiles_main() {
    dotfiles_reload
}

dotfiles_main
#
# dotfiles_reload()

### bashrc.lib.sh


## bash

#__THIS=$(readlink -e "$0")
#__THISDIR=$(dirname "${__THIS}")

echo_args() {
    # echo_args         -- echo $@ (for checking quoting)
    echo $@
}

function_exists() {
    # function_exists() -- check whether a bash function exists
    declare -f $1 > /dev/null
    return $?
}

add_to_path ()
{
    # add_to_path       -- prepend a directory to $PATH
    #http://superuser.com/questions/ \
    #\ 39751/add-directory-to-path-if-its-not-already-there/39840#39840

    #   instead of:
    #       export PATH=$dir:$PATH
    #       add_to_path $dir 

    if [[ "$PATH" =~ (^|:)"${1}"(:|$) ]]; then
        return 0
    fi
    export PATH=$1:$PATH
}


lightpath() {
    # lightpath()       -- display $PATH with newlines
    echo ''
    echo $PATH | tr ':' '\n'
}

lspath() {
    # lspath()          -- list files in each directory in $PATH
    echo "# PATH=$PATH"
    lightpath | sed 's/\(.*\)/# \1/g'
    echo '#'
    cmd=${1:-'ls -ald'}
    for f in $(lightpath); do
        echo "# $f";
        ${cmd} $f/*;
        echo '#'
    done
}

lspath-less() {
    # lspath_less()     -- lspath with less (color)
    if [ -n "${__IS_MAC}" ]; then
        cmd=${1:-'ls -ald -G'}
    else
        cmd=${1:-'ls -ald --color=always'}
    fi
    lspath "${cmd}" | less -R
}

## file paths

realpath () {
    # realpath()        -- print absolute path (os.path.realpath) to $1
    #                      note: OSX does not have readlink -f
    python -c "import os,sys; print(os.path.realpath(os.path.expanduser(sys.argv[1])))" "${1}"
    return
}
path () {
    # path()            -- realpath()
    realpath ${1}
}


walkpath () {
    # walkpath()        -- walk down path $1 and $cmd each component
    #   $1: path (optional; default: pwd)
    #   $2: cmd  (optional; default: 'ls -ald --color=auto')
    #http://superuser.com/a/65076 
    dir=${1:-$(pwd)}
    if [ -n "${__IS_MAC}" ]; then
        cmd=${2:-"ls -ldaG"}
    else
        cmd=${2:-"ls -lda --color=auto"}
    fi
    dir=$(realpath ${dir})
    parts=$(echo ${dir} \
        | awk 'BEGIN{FS="/"}{for (i=1; i < NF+2; i++) print $i}')
    paths=('/')
    unset path
    for part in $parts; do
        path="$path/$part"
        paths=("${paths[@]}" $path)
    done
    ${cmd} ${paths[@]}
}


ensure_symlink() {
    # ensure_symlink    -- create or update a symlink to $2 from $1
    #                      if $2 exists, backup with suffix $3
    _from=$1
    _to=$2
    _date=${3:-$(date +%FT%T%z)}  #  ISO8601 w/ tz
    if [ -s $_from ]; then
        _to_path=(realpath $_to)
        _from_path=(realpath $_from)
        if [ $_to_path == $_from_path ]; then
            printf "%s already points to %s" "$_from" "$_to"
        else
            printf "%s points to %s" "$_from" "$_to"
            mv -v ${_from} "${_from}.bkp.${_date}"
            ln -v -s ${_to} ${_from}
        fi
    else
        if [ -e ${_from} ]; then
            printf "%s exists" "${_from}"
            mv -v ${_from} "${_from}.bkp.${_date}"
            ln -v -s ${_to} ${_from}
        else
            ln -v -s $_to $_from
        fi
    fi
}

ensure_mkdir() {
    # ensure_mkdir      -- create directory $1 if it does not yet exist
    path=$1
    test -d ${path} || mkdir -p ${path}
}

### bashrc.platform.sh

detect_platform() {
    # detect_platform() -- set $__IS_MAC or $__IS_LINUX according to $(uname)
    UNAME=$(uname)
    if [ ${UNAME} == "Darwin" ]; then
        export __IS_MAC='true'
    elif [ ${UNAME} == "Linux" ]; then
        export __IS_LINUX='true'
    fi
}
uname
echo ${PATH} | sed 's,/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin,/usr/sbin:/sbin:/bin:/usr/local/bin:/usr/bin,'
### bashrc.readline.sh

    # set -o vi -- vi-mode: vi keyboard shortcuts
set -o vi

if [ -n "$BASH_VERSION" ]; then
    # .         -- insert last argument (command mode)
    bind -m vi-command ".":insert-last-argument

    # emulate default bash:
    # <ctrl> l  -- clear screen
    bind -m vi-insert "\C-l.":clear-screen
    # <ctrl> a  -- move to beginning of line (^)
    bind -m vi-insert "\C-a.":beginning-of-line
    # <ctrl> e  -- move to end of line ($)
    bind -m vi-insert "\C-e.":end-of-line
    # <ctrl> w  -- delete last word
    bind -m vi-insert "\C-w.":backward-kill-word
fi
[?1034h
### bashrc.TERM.sh

configure_TERM() {
    # configure_TERM            -- configure the $TERM variable (man terminfo)
    #   $1: (optional; autodetects if -z)
    term=$1
    if [ -n "${TERM}" ]; then
        __term=${TERM}
    fi
    if [ -n "${term}" ]; then
        export TERM="${term}"
    else
        if [ -n "${TMUX}" ] ; then
            #tmux
            export TERM="screen"
            configure_TERM_CLICOLOR
        elif [ -n "$(echo $TERMCAP | grep -q screen)" ]; then
            #screen
            export TERM="screen"
            configure_TERM_CLICOLOR
        elif [ -n "${ZSH_TMUX_TERM}" ]; then
            #zsh+tmux: oh-my-zsh/plugins/tmux/tmux.plugin.zsh
            export TERM="${ZSH_TMUX_TERM}"
            configure_TERM_CLICOLOR
        fi
    fi
    if [ "${TERM}" != "${__term}" ]; then
        echo "# TERM='${__term}'"
        echo "TERM='${TERM}'"
    fi
}

configure_TERM_CLICOLOR() {
    # configure_TERM_CLICOLOR   -- configure $CLICOLOR and $CLICOLOR_256
    #   CLICOLOR=1
    export CLICOLOR=1

    #todo
    #CLICOLOR_256=1
    #export CLICOLOR_256=$CLICOLOR

    if [ -n "${CLICOLOR_256}" ]; then
        (echo $TERM | grep -v -q 256color) && \
            export TERM="${TERM}-256color"
    fi
}

    # configure_TERM when sourced
configure_TERM
echo $TERMCAP | grep -q screen

### bashrc.dotfiles.sh


dotfiles_add_path() {
    # dotfiles_add_path()       -- add ${__DOTFILES}/scripts to $PATH
    if [ -d "${__DOTFILES}" ]; then
        #add_to_path "${__DOTFILES}/bin"  # [01-bashrc.lib.sh]
        add_to_path "${__DOTFILES}/scripts"
    fi
}

dotfiles_status() {
    # dotfiles_status()         -- print dotfiles_status
    echo "# dotfiles_status()"
    echo "HOSTNAME='${HOSTNAME}'"
    echo "USER='${USER}'"
    echo "PROJECT_HOME='${PROJECT_HOME}'"
    echo "WORKON_HOME='${WORKON_HOME}'"
    echo "VIRTUAL_ENV_NAME='${VIRTUAL_ENV_NAME}'"
    echo "VIRTUAL_ENV='${VIRTUAL_ENV}'"
    echo "_USRLOG='${_USRLOG}'"
    echo "_TERM_ID='${_TERM_ID}'"
    echo "_SRC='${_SRC}'"
    echo "_APP='${_APP}'"
    echo "_WRD='${_WRD}'"
    #echo "__DOCSWWW='${_DOCS}'"
    #echo "__SRC='${__SRC}'"
    #echo "__PROJECTSRC='${__PROJECTSRC}'"
    echo "PATH='${PATH}'"
    echo "__DOTFILES='${__DOTFILES}'"
    #echo $PATH | tr ':' '\n' | sed 's/\(.*\)/#     \1/g'
    echo "#"
}
ds() {
    # ds()                      -- print dotfiles_status
    dotfiles_status $@
}

#dotfiles_term_uri() {
    ##dotfiles_term_uri()        -- print a URI for the current _TERM_ID
    #term_path="${HOSTNAME}/usrlog/${USER}"
    #term_key=${_APP}/${_TERM_ID}
    #TERM_URI="${term_path}/${term_key}"
    #echo "TERM_URI='${TERM_URL}'"
#}

log_dotfiles_state() {
    # log_dotfiles_state()      -- save current environment to logfiles
    _log=${_LOG:-"${HOME}/var/log"}
    logkey=${1:-'99'}
    logdir=${_log:-"var/log"}/venv.${logkey}/
    exportslogfile=${logdir}/exports.log
    envlogfile=${logdir}/exports_env.log
    test -n $logdir && test -d $logdir || mkdir -p $logdir
    export > $exportslogfile
    set > $envlogfile
}


dotfiles_initialize() {
    # dotfiles_initialize()     -- virtualenvwrapper initialize
    log_dotfiles_state 'initialize'
}

dotfiles_postmkvirtualenv() {
    # dotfiles_postmkvirtualenv -- virtualenvwrapper postmkvirtualenv
    log_dotfiles_state 'postmkvirtualenv'
    declare -f 'mkdirs_venv' 2>&1 >/dev/null && mkdirs_venv
    test -d ${VIRTUAL_ENV}/var/log || mkdir -p ${VIRTUAL_ENV}/var/log
    echo ""
    pip_freeze="${VIRTUAL_ENV}/var/log/pip.freeze.postmkvirtualenv.txt"
    echo "pip_freeze='${pip_freeze}'"
    pip freeze | tee ${pip_freeze}
    echo ""
    pip_list="${VIRTUAL_ENV}/var/log/pip.freeze.postmkvirtualenv.txt"
    echo "pip_list='${pip_list}'"
    pip list | tee ${pip_list}
}

dotfiles_preactivate() {
    # dotfiles_preactivate()    -- virtualenvwrapper preactivate
    log_dotfiles_state 'preactivate'
}

dotfiles_postactivate() {
    # dotfiles_postactivate()   -- virtualenvwrapper postactivate
    log_dotfiles_state 'postactivate'

    test -n $_VENV \
        && source <(python $_VENV -E --bash)

    declare -f '_usrlog_setup' 2>&1 > /dev/null \
        && _usrlog_setup
   
    declare -f '_venv_set_prompt' 2>&1 > /dev/null \
        && _venv_set_prompt

}

dotfiles_predeactivate() {
    # dotfiles_predeactivate()  -- virtualenvwrapper predeactivate
    log_dotfiles_state 'predeactivate'
}

dotfiles_postdeactivate() {
    # dotfiles_postdeactivate() -- virtualenvwrapper postdeactivate
    log_dotfiles_state 'postdeactivate'
    unset VIRTUAL_ENV_NAME
    unset _APP
    unset _BIN
    unset _CFG
    unset _EDITCFG_
    unset _EDITOR
    unset _EDIT_
    unset _ETC
    unset _ETCOPT
    unset _HOME
    unset _IPQTLOG
    unset _IPSESSKEY
    unset _LIB
    unset _LOG
    unset _MEDIA
    unset _MNT
    unset _NOTEBOOKS
    unset _OPT
    unset _PYLIB
    unset _PYSITE
    unset _ROOT
    unset _SBIN
    unset _SERVE_
    unset _SHELL_
    unset _SRC
    unset _SRV
    unset _SVCFG
    unset _SVCFG_
    unset _TEST_
    unset _TMP
    unset _USR
    unset _USRBIN
    unset _USRINCLUDE
    unset _USRLIB
    unset _USRLOCAL
    unset _USRLOG
    unset _USRSBIN
    unset _USRSHARE
    unset _USRSRC
    unset _VAR
    unset _VARCACHE
    unset _VARLIB
    unset _VARLOCK
    unset _VARMAIL
    unset _VAROPT
    unset _VARRUN
    unset _VARSPOOL
    unset _VARTMP
    unset _VENV
    unset _WRD
    unset _WRD_SETUPY
    unset _WWW

    dotfiles_reload
}

### bashrc.completion.sh

_configure_bash_completion() {
    # _configure_bash_completion()  -- configure bash completion
    #                               note: `complete -p` lists completions

    if [ -n "$__IS_MAC" ]; then
        #configure brew (brew install bash-completion)
        BREW=$(which brew 2>/dev/null || false)
        if [ -n "${BREW}" ]; then
            brew_prefix=$(brew --prefix)
            if [ -f ${brew_prefix}/etc/bash_completion ]; then
                source ${brew_prefix}/etc/bash_completion
            fi
        fi
    else
        if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
            source /etc/bash_completion
        fi
    fi
}
_configure_bash_completion
which brew 2>/dev/null || false
brew --prefix
#
#   bash_completion - programmable completion functions for bash 3.2+
#
#   Copyright © 2006-2008, Ian Macdonald <ian@caliban.org>
#             © 2009-2011, Bash Completion Maintainers
#                     <bash-completion-devel@lists.alioth.debian.org>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2, or (at your option)
#   any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software Foundation,
#   Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
#   The latest version of this software can be obtained here:
#
#   http://bash-completion.alioth.debian.org/
#
#   RELEASE: 1.3

if [[ $- == *v* ]]; then
    BASH_COMPLETION_ORIGINAL_V_VALUE="-v"
else
    BASH_COMPLETION_ORIGINAL_V_VALUE="+v"
fi

if [[ -n $BASH_COMPLETION_DEBUG ]]; then
    set -v
else
    set +v
fi
unset BASH_COMPLETION_ORIGINAL_V_VALUE

# Local variables:
# mode: shell-script
# sh-basic-offset: 4
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: ts=4 sw=4 et filetype=sh

### bashrc.python.sh

pypath() {
    # pypath()              -- print python sys.path and site config
    /usr/bin/env python -m site
}


_setup_python () {
    # _setup_python()       -- configure $PYTHONSTARTUP
    export PYTHONSTARTUP="${HOME}/.pythonrc"
    #export
}
_setup_python

_setup_pip () {
    # _setup_pip()          -- set $PIP_REQUIRE_VIRTUALENV=false
    export PIP_REQUIRE_VIRTUALENV=false
}
_setup_pip


## Pyenv

_setup_pyenv() {
    # _setup_pyvenv()       -- set $PYENV_ROOT, add_to_path, and pyenv venvw
    export PYENV_ROOT="${HOME}/.pyenv"
    add_to_path "${PYENV_ROOT}/bin"
    eval "$(pyenv init -)"
    pyenv virtualenvwrapper
}

## Conda / Anaconda

_setup_anaconda() {
    # _setup_anaconda()     -- set $ANACONDA_ROOT, add_to_path
    export _ANACONDA_ROOT="/opt/anaconda"
    add_to_path "${_ANACONDA_ROOT}/bin"
}

workon_conda() {
    # workon_conda()        -- workon a conda + venv project
    _conda_envname=${1}
    _app=${2}
    we ${_conda_envname} ${_app}
    _setup_anaconda && \
        source activate ${WORKON_HOME}/.conda/${_conda_envname}
}
complete -o default -o nospace -F _virtualenvs workon_conda

wec() {
    # wec()                 -- workon a conda + venv project
    #                       note: tab-completion only shows regular virtualenvs
    workon_conda $@
}
complete -o default -o nospace -F _virtualenvs wec

mkvirtualenv_conda() {
    # mkvirtualenv_conda()  -- mkvirtualenv and conda create
    mkvirtualenv $@
    _conda_envname=${1}
    conda create --mkdir --prefix ${WORKON_HOME}/.conda/${_conda_envname} \
        readline
    workon_conda ${_conda_envname}
}

rmvirtualenv_conda() {
    # rmvirtualenv_conda()  -- rmvirtualenv conda
    rmvirtualenv $@
    _conda_envname=${1}
    #   TODO
}


mkvirtualenv_conda_if_available() {
    # mkvirtualenv_conda_if_available() -- mkvirtualenv_conda OR mkvirtualenv
    (declare -f 'mkvirtualenv_conda' 2>&1 > /dev/null \
        && mkvirtualenv_conda $@) \
    || \
    (declare -f 'mkvirtualenv' 2>&1 > /dev/null \
        && mkvirtualenv $@)
}

workon_conda_if_available() {
    # workon_conda_if_available()       -- workon_conda OR we OR workon
    (declare -f 'workon_conda' 2>&1 > /dev/null \
        && workon_conda $@) \
    || \
    (declare -f 'we' 2>&1 > /dev/null \
        && we $@) \
    || \
    (declare -f 'workon' 2>&1 > /dev/null \
        && workon $@)
}
### bashrc.virtualenvwrapper.sh

# sudo apt-get install virtualenvwrapper || sudo pip install virtualenvwrapper
export PROJECT_HOME="${HOME}/wrk"
export WORKON_HOME="${PROJECT_HOME}/.ve"

_setup_virtualenvwrapper () {
    # _setup_virtualenvwrapper()    -- configure $VIRTUALENVWRAPPER_*
    #export VIRTUALENVWRAPPER_SCRIPT="/usr/local/bin/virtualenvwrapper.sh"
    #export VIRTUALENVWRAPPER_SCRIPT="${HOME}/.local/bin/virtualenvwrapper.sh"
    export VIRTUALENVWRAPPER_SCRIPT=$(which virtualenvwrapper.sh)
    export VIRTUALENVWRAPPER_HOOK_DIR="${__DOTFILES}/etc/virtualenvwrapper"
    export VIRTUALENVWRAPPER_LOG_DIR="${PROJECT_HOME}/.virtualenvlogs"
    if [ -n "${__IS_MAC}" ]; then
        export VIRTUALENVWRAPPER_PYTHON="/usr/local/bin/python"
    else
        export VIRTUALENVWRAPPER_PYTHON=$(which python)
    fi
    unset VIRTUALENV_DISTRIBUTE
    source "${VIRTUALENVWRAPPER_SCRIPT}"
}
_setup_virtualenvwrapper
which virtualenvwrapper.sh
# -*- mode: shell-script -*-
#
# Shell functions to act as wrapper for Ian Bicking's virtualenv
# (http://pypi.python.org/pypi/virtualenv)
#
#
# Copyright Doug Hellmann, All Rights Reserved
#
# Permission to use, copy, modify, and distribute this software and its
# documentation for any purpose and without fee is hereby granted,
# provided that the above copyright notice appear in all copies and that
# both that copyright notice and this permission notice appear in
# supporting documentation, and that the name of Doug Hellmann not be used
# in advertising or publicity pertaining to distribution of the software
# without specific, written prior permission.
#
# DOUG HELLMANN DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
# INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
# EVENT SHALL DOUG HELLMANN BE LIABLE FOR ANY SPECIAL, INDIRECT OR
# CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
# USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#
#
# Project home page: http://www.doughellmann.com/projects/virtualenvwrapper/
#
#
# Setup:
#
#  1. Create a directory to hold the virtual environments.
#     (mkdir $HOME/.virtualenvs).
#  2. Add a line like "export WORKON_HOME=$HOME/.virtualenvs"
#     to your .bashrc.
#  3. Add a line like "source /path/to/this/file/virtualenvwrapper.sh"
#     to your .bashrc.
#  4. Run: source ~/.bashrc
#  5. Run: workon
#  6. A list of environments, empty, is printed.
#  7. Run: mkvirtualenv temp
#  8. Run: workon
#  9. This time, the "temp" environment is included.
# 10. Run: workon temp
# 11. The virtual environment is activated.
#

# Locate the global Python where virtualenvwrapper is installed.
if [ "$VIRTUALENVWRAPPER_PYTHON" = "" ]
then
    VIRTUALENVWRAPPER_PYTHON="$(command \which python)"
fi

# Set the name of the virtualenv app to use.
if [ "$VIRTUALENVWRAPPER_VIRTUALENV" = "" ]
then
    VIRTUALENVWRAPPER_VIRTUALENV="virtualenv"
fi

# Set the name of the virtualenv-clone app to use.
if [ "$VIRTUALENVWRAPPER_VIRTUALENV_CLONE" = "" ]
then
    VIRTUALENVWRAPPER_VIRTUALENV_CLONE="virtualenv-clone"
fi

# Define script folder depending on the platorm (Win32/Unix)
VIRTUALENVWRAPPER_ENV_BIN_DIR="bin"
if [ "$OS" = "Windows_NT" ] && [ "$MSYSTEM" = "MINGW32" ]
then
    # Only assign this for msys, cygwin use standard Unix paths
    # and its own python installation
    VIRTUALENVWRAPPER_ENV_BIN_DIR="Scripts"
fi

# Let the user override the name of the file that holds the project
# directory name.
if [ "$VIRTUALENVWRAPPER_PROJECT_FILENAME" = "" ]
then
    export VIRTUALENVWRAPPER_PROJECT_FILENAME=".project"
fi

# Remember where we are running from.
if [ -z "$VIRTUALENVWRAPPER_SCRIPT" ]
then
    if [ -n "$BASH" ]
    then
        export VIRTUALENVWRAPPER_SCRIPT="$BASH_SOURCE"
    elif [ -n "$ZSH_VERSION" ]
    then
        export VIRTUALENVWRAPPER_SCRIPT="$0"
    else
        export VIRTUALENVWRAPPER_SCRIPT="${.sh.file}"
    fi
fi

# Portable shell scripting is hard, let's go shopping.
#
# People insist on aliasing commands like 'cd', either with a real
# alias or even a shell function. Under bash and zsh, "builtin" forces
# the use of a command that is part of the shell itself instead of an
# alias, function, or external command, while "command" does something
# similar but allows external commands. Under ksh "builtin" registers
# a new command from a shared library, but "command" will pick up
# existing builtin commands. We need to use a builtin for cd because
# we are trying to change the state of the current shell, so we use
# "builtin" for bash and zsh but "command" under ksh.
function virtualenvwrapper_cd {
    if [ -n "$BASH" ]
    then
        builtin \cd "$@"
    elif [ -n "$ZSH_VERSION" ]
    then
        builtin \cd "$@"
    else
        command \cd "$@"
    fi
}

function virtualenvwrapper_expandpath {
    if [ "$1" = "" ]; then
        return 1
    else
        "$VIRTUALENVWRAPPER_PYTHON" -c "import os,sys; sys.stdout.write(os.path.normpath(os.path.expanduser(os.path.expandvars(\"$1\")))+'\n')"
        return 0
    fi
}

function virtualenvwrapper_absolutepath {
    if [ "$1" = "" ]; then
        return 1
    else
        "$VIRTUALENVWRAPPER_PYTHON" -c "import os,sys; sys.stdout.write(os.path.abspath(\"$1\")+'\n')"
        return 0
    fi
}

function virtualenvwrapper_derive_workon_home {
    typeset workon_home_dir="$WORKON_HOME"

    # Make sure there is a default value for WORKON_HOME.
    # You can override this setting in your .bashrc.
    if [ "$workon_home_dir" = "" ]
    then
        workon_home_dir="$HOME/.virtualenvs"
    fi

    # If the path is relative, prefix it with $HOME
    # (note: for compatibility)
    if echo "$workon_home_dir" | (unset GREP_OPTIONS; command \grep '^[^/~]' > /dev/null)
    then
        workon_home_dir="$HOME/$WORKON_HOME"
    fi

    # Only call on Python to fix the path if it looks like the
    # path might contain stuff to expand.
    # (it might be possible to do this in shell, but I don't know a
    # cross-shell-safe way of doing it -wolever)
    if echo "$workon_home_dir" | (unset GREP_OPTIONS; command \egrep '([\$~]|//)' >/dev/null)
    then
        # This will normalize the path by:
        # - Removing extra slashes (e.g., when TMPDIR ends in a slash)
        # - Expanding variables (e.g., $foo)
        # - Converting ~s to complete paths (e.g., ~/ to /home/brian/ and ~arthur to /home/arthur)
        workon_home_dir="$(virtualenvwrapper_expandpath "$workon_home_dir")"
    fi

    echo "$workon_home_dir"
    return 0
}

# Check if the WORKON_HOME directory exists,
# create it if it does not
# seperate from creating the files in it because this used to just error
# and maybe other things rely on the dir existing before that happens.
function virtualenvwrapper_verify_workon_home {
    RC=0
    if [ ! -d "$WORKON_HOME/" ]
    then
        if [ "$1" != "-q" ]
        then
            echo "NOTE: Virtual environments directory $WORKON_HOME does not exist. Creating..." 1>&2
        fi
        mkdir -p "$WORKON_HOME"
        RC=$?
    fi
    return $RC
}

#HOOK_VERBOSE_OPTION="-q"

# Function to wrap mktemp so tests can replace it for error condition
# testing.
function virtualenvwrapper_mktemp {
    command \mktemp "$@"
}

# Expects 1 argument, the suffix for the new file.
function virtualenvwrapper_tempfile {
    # Note: the 'X's must come last
    typeset suffix=${1:-hook}
    typeset file

    file="$(virtualenvwrapper_mktemp -t virtualenvwrapper-$suffix-XXXXXXXXXX)"
    if [ $? -ne 0 ] || [ -z "$file" ] || [ ! -f "$file" ]
    then
        echo "ERROR: virtualenvwrapper could not create a temporary file name." 1>&2
        return 1
    fi
    echo $file
    return 0
}

# Run the hooks
function virtualenvwrapper_run_hook {
    typeset hook_script
    typeset result

    hook_script="$(virtualenvwrapper_tempfile ${1}-hook)" || return 1

    # Use a subshell to run the python interpreter with hook_loader so
    # we can change the working directory. This avoids having the
    # Python 3 interpreter decide that its "prefix" is the virtualenv
    # if we happen to be inside the virtualenv when we start.
    ( \
        virtualenvwrapper_cd "$WORKON_HOME" &&
        "$VIRTUALENVWRAPPER_PYTHON" -m 'virtualenvwrapper.hook_loader' \
            $HOOK_VERBOSE_OPTION --script "$hook_script" "$@" \
    )
    result=$?

    if [ $result -eq 0 ]
    then
        if [ ! -f "$hook_script" ]
        then
            echo "ERROR: virtualenvwrapper_run_hook could not find temporary file $hook_script" 1>&2
            command \rm -f "$hook_script"
            return 2
        fi
        # cat "$hook_script"
        source "$hook_script"
    elif [ "${1}" = "initialize" ]
    then
        cat - 1>&2 <<EOF 
virtualenvwrapper.sh: There was a problem running the initialization hooks. 

If Python could not import the module virtualenvwrapper.hook_loader,
check that virtualenvwrapper has been installed for
VIRTUALENVWRAPPER_PYTHON=$VIRTUALENVWRAPPER_PYTHON and that PATH is
set properly.
EOF
    fi
    command \rm -f "$hook_script"
    return $result
}

# Set up tab completion.  (Adapted from Arthur Koziel's version at
# http://arthurkoziel.com/2008/10/11/virtualenvwrapper-bash-completion/)
function virtualenvwrapper_setup_tab_completion {
    if [ -n "$BASH" ] ; then
        _virtualenvs () {
            local cur="${COMP_WORDS[COMP_CWORD]}"
            COMPREPLY=( $(compgen -W "`virtualenvwrapper_show_workon_options`" -- ${cur}) )
        }
        _cdvirtualenv_complete () {
            local cur="$2"
            COMPREPLY=( $(cdvirtualenv && compgen -d -- "${cur}" ) )
        }
        _cdsitepackages_complete () {
            local cur="$2"
            COMPREPLY=( $(cdsitepackages && compgen -d -- "${cur}" ) )
        }
        complete -o nospace -F _cdvirtualenv_complete -S/ cdvirtualenv
        complete -o nospace -F _cdsitepackages_complete -S/ cdsitepackages
        complete -o default -o nospace -F _virtualenvs workon
        complete -o default -o nospace -F _virtualenvs rmvirtualenv
        complete -o default -o nospace -F _virtualenvs cpvirtualenv
        complete -o default -o nospace -F _virtualenvs showvirtualenv
    elif [ -n "$ZSH_VERSION" ] ; then
        _virtualenvs () {
            reply=( $(virtualenvwrapper_show_workon_options) )
        }
        _cdvirtualenv_complete () {
            reply=( $(cdvirtualenv && ls -d ${1}*) )
        }
        _cdsitepackages_complete () {
            reply=( $(cdsitepackages && ls -d ${1}*) )
        }
        compctl -K _virtualenvs workon rmvirtualenv cpvirtualenv showvirtualenv
        compctl -K _cdvirtualenv_complete cdvirtualenv
        compctl -K _cdsitepackages_complete cdsitepackages
    fi
}

# Set up virtualenvwrapper properly
function virtualenvwrapper_initialize {
    export WORKON_HOME="$(virtualenvwrapper_derive_workon_home)"

    virtualenvwrapper_verify_workon_home -q || return 1

    # Set the location of the hook scripts
    if [ "$VIRTUALENVWRAPPER_HOOK_DIR" = "" ]
    then
        export VIRTUALENVWRAPPER_HOOK_DIR="$WORKON_HOME"
    fi

    mkdir -p "$VIRTUALENVWRAPPER_HOOK_DIR"

    virtualenvwrapper_run_hook "initialize"

    virtualenvwrapper_setup_tab_completion

    return 0
}

# Verify that the passed resource is in path and exists
function virtualenvwrapper_verify_resource {
    typeset exe_path="$(command \which "$1" | (unset GREP_OPTIONS; command \grep -v "not found"))"
    if [ "$exe_path" = "" ]
    then
        echo "ERROR: virtualenvwrapper could not find $1 in your path" >&2
        return 1
    fi
    if [ ! -e "$exe_path" ]
    then
        echo "ERROR: Found $1 in path as \"$exe_path\" but that does not exist" >&2
        return 1
    fi
    return 0
}


# Verify that virtualenv is installed and visible
function virtualenvwrapper_verify_virtualenv {
    virtualenvwrapper_verify_resource $VIRTUALENVWRAPPER_VIRTUALENV
}


function virtualenvwrapper_verify_virtualenv_clone {
    virtualenvwrapper_verify_resource $VIRTUALENVWRAPPER_VIRTUALENV_CLONE
}


# Verify that the requested environment exists
function virtualenvwrapper_verify_workon_environment {
    typeset env_name="$1"
    if [ ! -d "$WORKON_HOME/$env_name" ]
    then
       echo "ERROR: Environment '$env_name' does not exist. Create it with 'mkvirtualenv $env_name'." >&2
       return 1
    fi
    return 0
}

# Verify that the active environment exists
function virtualenvwrapper_verify_active_environment {
    if [ ! -n "${VIRTUAL_ENV}" ] || [ ! -d "${VIRTUAL_ENV}" ]
    then
        echo "ERROR: no virtualenv active, or active virtualenv is missing" >&2
        return 1
    fi
    return 0
}

# Help text for mkvirtualenv
function virtualenvwrapper_mkvirtualenv_help {
    echo "Usage: mkvirtualenv [-a project_path] [-i package] [-r requirements_file] [virtualenv options] env_name"
    echo
    echo " -a project_path"
    echo
    echo "    Provide a full path to a project directory to associate with"
    echo "    the new environment."
    echo
    echo " -i package"
    echo
    echo "    Install a package after the environment is created."
    echo "    This option may be repeated."
    echo
    echo " -r requirements_file"
    echo
    echo "    Provide a pip requirements file to install a base set of packages"
    echo "    into the new environment."
    echo;
    echo 'virtualenv help:';
    echo;
    "$VIRTUALENVWRAPPER_VIRTUALENV" $@;
}

# Create a new environment, in the WORKON_HOME.
#
# Usage: mkvirtualenv [options] ENVNAME
# (where the options are passed directly to virtualenv)
#
#:help:mkvirtualenv: Create a new virtualenv in $WORKON_HOME
function mkvirtualenv {
    typeset -a in_args
    typeset -a out_args
    typeset -i i
    typeset tst
    typeset a
    typeset envname
    typeset requirements
    typeset packages
    typeset interpreter
    typeset project

    in_args=( "$@" )

    if [ -n "$ZSH_VERSION" ]
    then
        i=1
        tst="-le"
    else
        i=0
        tst="-lt"
    fi
    while [ $i $tst $# ]
    do
        a="${in_args[$i]}"
        # echo "arg $i : $a"
        case "$a" in
            -a)
                i=$(( $i + 1 ))
                project="${in_args[$i]}"
                if [ ! -d "$project" ]
                then
                    echo "Cannot associate project with $project, it is not a directory" 1>&2
                    return 1
                fi
                project="$(virtualenvwrapper_absolutepath ${project})";;
            -h|--help)
                virtualenvwrapper_mkvirtualenv_help $a;
                return;;
            -i)
                i=$(( $i + 1 ));
                packages="$packages ${in_args[$i]}";;
            -p|--python*)
                if echo "$a" | grep -q "="
                then
                    interpreter="$(echo "$a" | cut -f2 -d=)"
                else
                    i=$(( $i + 1 ))
                    interpreter="${in_args[$i]}"
                fi;
                interpreter="$(virtualenvwrapper_absolutepath "$interpreter")";;
            -r)
                i=$(( $i + 1 ));
                requirements="${in_args[$i]}";
                requirements="$(virtualenvwrapper_expandpath "$requirements")";;
            *)
                if [ ${#out_args} -gt 0 ]
                then
                    out_args=( "${out_args[@]-}" "$a" )
                else
                    out_args=( "$a" )
                fi;;
        esac
        i=$(( $i + 1 ))
    done

    if [ ! -z $interpreter ]
    then
        out_args=( "--python=$interpreter" ${out_args[@]} )
    fi;

    set -- "${out_args[@]}"

    eval "envname=\$$#"
    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_virtualenv || return 1
    (
        [ -n "$ZSH_VERSION" ] && setopt SH_WORD_SPLIT
        virtualenvwrapper_cd "$WORKON_HOME" &&
        "$VIRTUALENVWRAPPER_VIRTUALENV" $VIRTUALENVWRAPPER_VIRTUALENV_ARGS "$@" &&
        [ -d "$WORKON_HOME/$envname" ] && \
            virtualenvwrapper_run_hook "pre_mkvirtualenv" "$envname"
    )
    typeset RC=$?
    [ $RC -ne 0 ] && return $RC

    # If they passed a help option or got an error from virtualenv,
    # the environment won't exist.  Use that to tell whether
    # we should switch to the environment and run the hook.
    [ ! -d "$WORKON_HOME/$envname" ] && return 0

    # If they gave us a project directory, set it up now
    # so the activate hooks can find it.
    if [ ! -z "$project" ]
    then
        setvirtualenvproject "$WORKON_HOME/$envname" "$project"
        RC=$?
        [ $RC -ne 0 ] && return $RC
    fi

    # Now activate the new environment
    workon "$envname"

    if [ ! -z "$requirements" ]
    then
        pip install -r "$requirements"
    fi

    for a in $packages
    do
        pip install $a
    done

    virtualenvwrapper_run_hook "post_mkvirtualenv"
}

#:help:rmvirtualenv: Remove a virtualenv
function rmvirtualenv {
    virtualenvwrapper_verify_workon_home || return 1
    if [ ${#@} = 0 ]
    then
        echo "Please specify an enviroment." >&2
        return 1
    fi

    # support to remove several environments
    typeset env_name
    for env_name in $@
    do
        echo "Removing $env_name..."
        typeset env_dir="$WORKON_HOME/$env_name"
        if [ "$VIRTUAL_ENV" = "$env_dir" ]
        then
            echo "ERROR: You cannot remove the active environment ('$env_name')." >&2
            echo "Either switch to another environment, or run 'deactivate'." >&2
            return 1
        fi

        if [ ! -d "$env_dir" ]; then
            echo "Did not find environment $env_dir to remove." >&2
        fi

        # Move out of the current directory to one known to be
        # safe, in case we are inside the environment somewhere.
        typeset prior_dir="$(pwd)"
        virtualenvwrapper_cd "$WORKON_HOME"

        virtualenvwrapper_run_hook "pre_rmvirtualenv" "$env_name"
        command \rm -rf "$env_dir"
        virtualenvwrapper_run_hook "post_rmvirtualenv" "$env_name"

        # If the directory we used to be in still exists, move back to it.
        if [ -d "$prior_dir" ]
        then
            virtualenvwrapper_cd "$prior_dir"
        fi
    done
}

# List the available environments.
function virtualenvwrapper_show_workon_options {
    virtualenvwrapper_verify_workon_home || return 1
    # NOTE: DO NOT use ls or cd here because colorized versions spew control 
    #       characters into the output list.
    # echo seems a little faster than find, even with -depth 3.
    #
    # 1. Look for environments by finding the activate scripts.
    #    Use a subshell so we can suppress the message printed
    #    by zsh if the glob pattern fails to match any files.
    # 2. Strip the WORKON_HOME prefix from each name.
    # 3. Strip the bindir/activate script suffix.
    # 4. Format the output to show one name on a line.
    # 5. Eliminate any lines with * on them because that means there 
    #    were no envs.
    (virtualenvwrapper_cd "$WORKON_HOME" && echo */$VIRTUALENVWRAPPER_ENV_BIN_DIR/activate) 2>/dev/null \
        | command \sed "s|/$VIRTUALENVWRAPPER_ENV_BIN_DIR/activate||g" \
        | command \fmt -w 1 \
        | (unset GREP_OPTIONS; command \egrep -v '^\*$') 2>/dev/null
}

function _lsvirtualenv_usage {
    echo "lsvirtualenv [-blh]"
    echo "  -b -- brief mode"
    echo "  -l -- long mode"
    echo "  -h -- this help message"
}

#:help:lsvirtualenv: list virtualenvs
function lsvirtualenv {

    typeset long_mode=true
    if command -v "getopts" &> /dev/null
    then
        # Use getopts when possible
        OPTIND=1
        while getopts ":blh" opt "$@"
        do
            case "$opt" in
                l) long_mode=true;;
                b) long_mode=false;;
                h)  _lsvirtualenv_usage;
                    return 1;;
                ?) echo "Invalid option: -$OPTARG" >&2;
                    _lsvirtualenv_usage;
                    return 1;;
            esac
        done
    else
        # fallback on getopt for other shell
        typeset -a args
        args=($(getopt blh "$@"))
        if [ $? != 0 ]
        then
            _lsvirtualenv_usage
            return 1
        fi
        for opt in $args
        do
            case "$opt" in
                -l) long_mode=true;;
                -b) long_mode=false;;
                -h) _lsvirtualenv_usage;
                    return 1;;
            esac
        done
    fi

    if $long_mode
    then
        allvirtualenv showvirtualenv "$env_name"
    else
        virtualenvwrapper_show_workon_options
    fi
}

#:help:showvirtualenv: show details of a single virtualenv
function showvirtualenv {
    typeset env_name="$1"
    if [ -z "$env_name" ]
    then
        if [ -z "$VIRTUAL_ENV" ]
        then
            echo "showvirtualenv [env]"
            return 1
        fi
        env_name=$(basename "$VIRTUAL_ENV")
    fi

    virtualenvwrapper_run_hook "get_env_details" "$env_name"
    echo
}

# Show help for workon
function virtualenvwrapper_workon_help {
    echo "Usage: workon env_name"
    echo ""
    echo "           Deactivate any currently activated virtualenv"
    echo "           and activate the named environment, triggering"
    echo "           any hooks in the process."
    echo ""
    echo "       workon"
    echo ""
    echo "           Print a list of available environments."
    echo "           (See also lsvirtualenv -b)"
    echo ""
    echo "       workon (-h|--help)"
    echo ""
    echo "           Show this help message."
    echo ""
}

#:help:workon: list or change working virtualenvs
function workon {
    in_args=( "$@" )

    if [ -n "$ZSH_VERSION" ]
    then
        i=1
        tst="-le"
    else
        i=0
        tst="-lt"
    fi
    while [ $i $tst $# ]
    do
        a="${in_args[$i]}"
        case "$a" in
            -h|--help)
                virtualenvwrapper_workon_help;
                return 0;;
        esac
        i=$(( $i + 1 ))
    done

    typeset env_name="$1"
    if [ "$env_name" = "" ]
    then
        lsvirtualenv -b
        return 1
    fi

    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_workon_environment $env_name || return 1

    activate="$WORKON_HOME/$env_name/$VIRTUALENVWRAPPER_ENV_BIN_DIR/activate"
    if [ ! -f "$activate" ]
    then
        echo "ERROR: Environment '$WORKON_HOME/$env_name' does not contain an activate script." >&2
        return 1
    fi

    # Deactivate any current environment "destructively"
    # before switching so we use our override function,
    # if it exists.
    type deactivate >/dev/null 2>&1
    if [ $? -eq 0 ]
    then
        deactivate
        unset -f deactivate >/dev/null 2>&1
    fi

    virtualenvwrapper_run_hook "pre_activate" "$env_name"

    source "$activate"

    # Save the deactivate function from virtualenv under a different name
    virtualenvwrapper_original_deactivate=`typeset -f deactivate | sed 's/deactivate/virtualenv_deactivate/g'`
    eval "$virtualenvwrapper_original_deactivate"
    unset -f deactivate >/dev/null 2>&1

    # Replace the deactivate() function with a wrapper.
    eval 'deactivate () {
        typeset env_postdeactivate_hook
        typeset old_env

        # Call the local hook before the global so we can undo
        # any settings made by the local postactivate first.
        virtualenvwrapper_run_hook "pre_deactivate"

        env_postdeactivate_hook="$VIRTUAL_ENV/$VIRTUALENVWRAPPER_ENV_BIN_DIR/postdeactivate"
        old_env=$(basename "$VIRTUAL_ENV")

        # Call the original function.
        virtualenv_deactivate $1

        virtualenvwrapper_run_hook "post_deactivate" "$old_env"

        if [ ! "$1" = "nondestructive" ]
        then
            # Remove this function
            unset -f virtualenv_deactivate >/dev/null 2>&1
            unset -f deactivate >/dev/null 2>&1
        fi

    }'

    virtualenvwrapper_run_hook "post_activate"

    return 0
}


# Prints the Python version string for the current interpreter.
function virtualenvwrapper_get_python_version {
    # Uses the Python from the virtualenv rather than
    # VIRTUALENVWRAPPER_PYTHON because we're trying to determine the
    # version installed there so we can build up the path to the
    # site-packages directory.
    "$VIRTUAL_ENV/$VIRTUALENVWRAPPER_ENV_BIN_DIR/python" -V 2>&1 | cut -f2 -d' ' | cut -f-2 -d.
}

# Prints the path to the site-packages directory for the current environment.
function virtualenvwrapper_get_site_packages_dir {
    "$VIRTUAL_ENV/$VIRTUALENVWRAPPER_ENV_BIN_DIR/python" -c "import distutils; print(distutils.sysconfig.get_python_lib())"
}

# Path management for packages outside of the virtual env.
# Based on a contribution from James Bennett and Jannis Leidel.
#
# add2virtualenv directory1 directory2 ...
#
# Adds the specified directories to the Python path for the
# currently-active virtualenv. This will be done by placing the
# directory names in a path file named
# "virtualenv_path_extensions.pth" inside the virtualenv's
# site-packages directory; if this file does not exist, it will be
# created first.
#
#:help:add2virtualenv: add directory to the import path
function add2virtualenv {
    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_active_environment || return 1

    site_packages="`virtualenvwrapper_get_site_packages_dir`"

    if [ ! -d "${site_packages}" ]
    then
        echo "ERROR: currently-active virtualenv does not appear to have a site-packages directory" >&2
        return 1
    fi

    # Prefix with _ to ensure we are loaded as early as possible,
    # and at least before easy_install.pth.
    path_file="$site_packages/_virtualenv_path_extensions.pth"

    if [ "$*" = "" ]
    then
        echo "Usage: add2virtualenv dir [dir ...]"
        if [ -f "$path_file" ]
        then
            echo
            echo "Existing paths:"
            cat "$path_file" | grep -v "^import"
        fi
        return 1
    fi

    remove=0
    if [ "$1" = "-d" ]
    then
        remove=1
        shift
    fi

    if [ ! -f "$path_file" ]
    then
        echo "import sys; sys.__plen = len(sys.path)" > "$path_file" || return 1
        echo "import sys; new=sys.path[sys.__plen:]; del sys.path[sys.__plen:]; p=getattr(sys,'__egginsert',0); sys.path[p:p]=new; sys.__egginsert = p+len(new)" >> "$path_file" || return 1
    fi

    for pydir in "$@"
    do
        absolute_path="$(virtualenvwrapper_absolutepath "$pydir")"
        if [ "$absolute_path" != "$pydir" ]
        then
            echo "Warning: Converting \"$pydir\" to \"$absolute_path\"" 1>&2
        fi

        if [ $remove -eq 1 ]
        then
            sed -i.tmp "\:^$absolute_path$: d" "$path_file"
        else
            sed -i.tmp '1 a\
'"$absolute_path"'
' "$path_file"
        fi
        rm -f "${path_file}.tmp"
    done
    return 0
}

# Does a ``cd`` to the site-packages directory of the currently-active
# virtualenv.
#:help:cdsitepackages: change to the site-packages directory
function cdsitepackages {
    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_active_environment || return 1
    typeset site_packages="`virtualenvwrapper_get_site_packages_dir`"
    virtualenvwrapper_cd "$site_packages"/$1
}

# Does a ``cd`` to the root of the currently-active virtualenv.
#:help:cdvirtualenv: change to the $VIRTUAL_ENV directory
function cdvirtualenv {
    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_active_environment || return 1
    virtualenvwrapper_cd $VIRTUAL_ENV/$1
}

# Shows the content of the site-packages directory of the currently-active
# virtualenv
#:help:lssitepackages: list contents of the site-packages directory
function lssitepackages {
    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_active_environment || return 1
    typeset site_packages="`virtualenvwrapper_get_site_packages_dir`"
    ls $@ "$site_packages"

    path_file="$site_packages/_virtualenv_path_extensions.pth"
    if [ -f "$path_file" ]
    then
        echo
        echo "_virtualenv_path_extensions.pth:"
        cat "$path_file"
    fi
}

# Toggles the currently-active virtualenv between having and not having
# access to the global site-packages.
#:help:toggleglobalsitepackages: turn access to global site-packages on/off
function toggleglobalsitepackages {
    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_active_environment || return 1
    typeset no_global_site_packages_file="`virtualenvwrapper_get_site_packages_dir`/../no-global-site-packages.txt"
    if [ -f $no_global_site_packages_file ]; then
        rm $no_global_site_packages_file
        [ "$1" = "-q" ] || echo "Enabled global site-packages"
    else
        touch $no_global_site_packages_file
        [ "$1" = "-q" ] || echo "Disabled global site-packages"
    fi
}

#:help:cpvirtualenv: duplicate the named virtualenv to make a new one
function cpvirtualenv {
    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_virtualenv_clone || return 1

    typeset src_name="$1"
    typeset trg_name="$2"
    typeset src
    typeset trg 

    # without a source there is nothing to do
    if [ "$src_name" = "" ]; then
        echo "Please provide a valid virtualenv to copy."
        return 1
    else
        # see if its already in workon
        if [ ! -e "$WORKON_HOME/$src_name" ]; then
            # so its a virtualenv we are importing
            # make sure we have a full path
            # and get the name
            src="$(virtualenvwrapper_expandpath "$src_name")"
            # final verification
            if [ ! -e "$src" ]; then
                echo "Please provide a valid virtualenv to copy."
                return 1
            fi
            src_name="$(basename "$src")"
        else
           src="$WORKON_HOME/$src_name"
        fi
    fi

    if [ "$trg_name" = "" ]; then
        # target not given, assume
        # same as source
        trg="$WORKON_HOME/$src_name"
        trg_name="$src_name"
    else
        trg="$WORKON_HOME/$trg_name"
    fi
    trg="$(virtualenvwrapper_expandpath "$trg")"

    # validate trg does not already exist
    # catch copying virtualenv in workon home
    # to workon home
    if [ -e "$trg" ]; then
        echo "$trg_name virtualenv already exists."
        return 1
    fi

    echo "Copying $src_name as $trg_name..."
    (
        [ -n "$ZSH_VERSION" ] && setopt SH_WORD_SPLIT 
        virtualenvwrapper_cd "$WORKON_HOME" &&
        "$VIRTUALENVWRAPPER_VIRTUALENV_CLONE" "$src" "$trg" 
        [ -d "$trg" ] && 
            virtualenvwrapper_run_hook "pre_cpvirtualenv" "$src" "$trg_name" &&
            virtualenvwrapper_run_hook "pre_mkvirtualenv" "$trg_name"
    )
    typeset RC=$?
    [ $RC -ne 0 ] && return $RC

    [ ! -d "$WORKON_HOME/$trg_name" ] && return 1

    # Now activate the new environment
    workon "$trg_name"

    virtualenvwrapper_run_hook "post_mkvirtualenv"
    virtualenvwrapper_run_hook "post_cpvirtualenv"
}

#
# virtualenvwrapper project functions
#

# Verify that the PROJECT_HOME directory exists
function virtualenvwrapper_verify_project_home {
    if [ -z "$PROJECT_HOME" ]
    then
        echo "ERROR: Set the PROJECT_HOME shell variable to the name of the directory where projects should be created." >&2
        return 1
    fi
    if [ ! -d "$PROJECT_HOME" ]
    then
        [ "$1" != "-q" ] && echo "ERROR: Project directory '$PROJECT_HOME' does not exist.  Create it or set PROJECT_HOME to an existing directory." >&2
        return 1
    fi
    return 0
}

# Given a virtualenv directory and a project directory,
# set the virtualenv up to be associated with the
# project
#:help:setvirtualenvproject: associate a project directory with a virtualenv
function setvirtualenvproject {
    typeset venv="$1"
    typeset prj="$2"
    if [ -z "$venv" ]
    then
        venv="$VIRTUAL_ENV"
    fi
    if [ -z "$prj" ]
    then
        prj="$(pwd)"
    else
        prj=$(virtualenvwrapper_absolutepath "${prj}")
    fi

    # If what we were given isn't a directory, see if it is under
    # $WORKON_HOME.
    if [ ! -d "$venv" ]
    then
        venv="$WORKON_HOME/$venv"
    fi
    if [ ! -d "$venv" ]
    then
        echo "No virtualenv $(basename $venv)" 1>&2
        return 1
    fi

    # Make sure we have a valid project setting
    if [ ! -d "$prj" ]
    then
        echo "Cannot associate virtualenv with \"$prj\", it is not a directory" 1>&2
        return 1
    fi

    echo "Setting project for $(basename $venv) to $prj"
    echo "$prj" > "$venv/$VIRTUALENVWRAPPER_PROJECT_FILENAME"
}

# Show help for mkproject
function virtualenvwrapper_mkproject_help {
    echo "Usage: mkproject [-f|--force] [-t template] [virtualenv options] project_name"
    echo
    echo "-f, --force    Create the virtualenv even if the project directory"
    echo "               already exists"
    echo
    echo "Multiple templates may be selected.  They are applied in the order"
    echo "specified on the command line."
    echo
    echo "mkvirtualenv help:"
    echo
    mkvirtualenv -h
    echo
    echo "Available project templates:"
    echo
    "$VIRTUALENVWRAPPER_PYTHON" -c 'from virtualenvwrapper.hook_loader import main; main()' -l project.template
}

#:help:mkproject: create a new project directory and its associated virtualenv
function mkproject {
    typeset -a in_args
    typeset -a out_args
    typeset -i i
    typeset tst
    typeset a
    typeset t
    typeset force
    typeset templates

    in_args=( "$@" )
    force=0

    if [ -n "$ZSH_VERSION" ]
    then
        i=1
        tst="-le"
    else
        i=0
        tst="-lt"
    fi
    while [ $i $tst $# ]
    do
        a="${in_args[$i]}"
        case "$a" in
            -h|--help)
                virtualenvwrapper_mkproject_help;
                return;;
            -f|--force)
                force=1;;
            -t)
                i=$(( $i + 1 ));
                templates="$templates ${in_args[$i]}";;
            *)
                if [ ${#out_args} -gt 0 ]
                then
                    out_args=( "${out_args[@]-}" "$a" )
                else
                    out_args=( "$a" )
                fi;;
        esac
        i=$(( $i + 1 ))
    done

    set -- "${out_args[@]}"

    # echo "templates $templates"
    # echo "remainder $@"
    # return 0

    eval "typeset envname=\$$#"
    virtualenvwrapper_verify_project_home || return 1

    if [ -d "$PROJECT_HOME/$envname" -a $force -eq 0 ]
    then
        echo "Project $envname already exists." >&2
        return 1
    fi

    mkvirtualenv "$@" || return 1

    virtualenvwrapper_cd "$PROJECT_HOME"

    virtualenvwrapper_run_hook "project.pre_mkproject" $envname

    echo "Creating $PROJECT_HOME/$envname"
    mkdir -p "$PROJECT_HOME/$envname"
    setvirtualenvproject "$VIRTUAL_ENV" "$PROJECT_HOME/$envname"

    virtualenvwrapper_cd "$PROJECT_HOME/$envname"

    for t in $templates
    do
        echo
        echo "Applying template $t"
        # For some reason zsh insists on prefixing the template
        # names with a space, so strip them out before passing
        # the value to the hook loader.
        virtualenvwrapper_run_hook --name $(echo $t | sed 's/^ //') "project.template" "$envname" "$PROJECT_HOME/$envname"
    done

    virtualenvwrapper_run_hook "project.post_mkproject"
}

#:help:cdproject: change directory to the active project
function cdproject {
    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_active_environment || return 1
    if [ -f "$VIRTUAL_ENV/$VIRTUALENVWRAPPER_PROJECT_FILENAME" ]
    then
        typeset project_dir="$(cat "$VIRTUAL_ENV/$VIRTUALENVWRAPPER_PROJECT_FILENAME")"
        if [ ! -z "$project_dir" ]
        then
            virtualenvwrapper_cd "$project_dir"
        else
            echo "Project directory $project_dir does not exist" 1>&2
            return 1
        fi
    else
        echo "No project set in $VIRTUAL_ENV/$VIRTUALENVWRAPPER_PROJECT_FILENAME" 1>&2
        return 1
    fi
    return 0
}

#
# Temporary virtualenv
#
# Originally part of virtualenvwrapper.tmpenv plugin
#
#:help:mktmpenv: create a temporary virtualenv
function mktmpenv {
    typeset tmpenvname
    typeset RC

    # Generate a unique temporary name
    tmpenvname=$("$VIRTUALENVWRAPPER_PYTHON" -c 'import uuid,sys; sys.stdout.write(uuid.uuid4()+"\n")' 2>/dev/null)
    if [ -z "$tmpenvname" ]
    then
        # This python does not support uuid
        tmpenvname=$("$VIRTUALENVWRAPPER_PYTHON" -c 'import random,sys; sys.stdout.write(hex(random.getrandbits(64))[2:-1]+"\n")' 2>/dev/null)
    fi
    tmpenvname="tmp-$tmpenvname"

    # Create the environment
    mkvirtualenv "$@" "$tmpenvname"
    RC=$?
    if [ $RC -ne 0 ]
    then
        return $RC
    fi

    # Change working directory
    cdvirtualenv

    # Create the tmpenv marker file
    echo "This is a temporary environment. It will be deleted when you run 'deactivate'." | tee "$VIRTUAL_ENV/README.tmpenv"

    # Update the postdeactivate script
    cat - >> "$VIRTUAL_ENV/$VIRTUALENVWRAPPER_ENV_BIN_DIR/postdeactivate" <<EOF
if [ -f "$VIRTUAL_ENV/README.tmpenv" ]
then
    echo "Removing temporary environment:" $(basename "$VIRTUAL_ENV")
    rmvirtualenv $(basename "$VIRTUAL_ENV")
fi
EOF
}

#
# Remove all installed packages from the env
#
#:help:wipeenv: remove all packages installed in the current virtualenv
function wipeenv {
    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_active_environment || return 1

    typeset req_file="$(virtualenvwrapper_tempfile "requirements.txt")"
    pip freeze | egrep -v '(distribute|wsgiref)' > "$req_file"
    if [ -n "$(cat "$req_file")" ]
    then
        echo "Uninstalling packages:"
        cat "$req_file"
        echo
        pip uninstall -y $(cat "$req_file" | sed 's/>/=/g' | cut -f1 -d=)
    else
        echo "Nothing to remove."
    fi
    rm -f "$req_file"
}

#
# Run a command in each virtualenv
#
#:help:allvirtualenv: run a command in all virtualenvs
function allvirtualenv {
    virtualenvwrapper_verify_workon_home || return 1
    typeset d

    virtualenvwrapper_show_workon_options | while read d
    do
        [ ! -d "$WORKON_HOME/$d" ] && continue
        echo "$d"
        echo "$d" | sed 's/./=/g'
        # Activate the environment, but not with workon
        # because we don't want to trigger any hooks.
        (source "$WORKON_HOME/$d/$VIRTUALENVWRAPPER_ENV_BIN_DIR/activate";
            virtualenvwrapper_cd "$VIRTUAL_ENV";
            "$@")
        echo
    done
}

#:help:virtualenvwrapper: show this help message
function virtualenvwrapper {
	cat <<EOF

virtualenvwrapper is a set of extensions to Ian Bicking's virtualenv
tool.  The extensions include wrappers for creating and deleting
virtual environments and otherwise managing your development workflow,
making it easier to work on more than one project at a time without
introducing conflicts in their dependencies.

For more information please refer to the documentation:

    http://virtualenvwrapper.readthedocs.org/en/latest/command_ref.html

Commands available:

EOF

    typeset helpmarker="#:help:"
    cat  "$VIRTUALENVWRAPPER_SCRIPT" \
        | grep "^$helpmarker" \
        | sed -e "s/^$helpmarker/  /g" \
        | sort \
        | sed -e 's/$/\'$'\n/g'
}

#
# Invoke the initialization functions
#
virtualenvwrapper_initialize
virtualenvwrapper_derive_workon_home
virtualenvwrapper_tempfile ${1}-hook
virtualenvwrapper_mktemp -t virtualenvwrapper-$suffix-XXXXXXXXXX
# initialize
# user_scripts
#
# Run user-provided scripts
#
[ -f "$VIRTUALENVWRAPPER_HOOK_DIR/initialize" ] &&     source "$VIRTUALENVWRAPPER_HOOK_DIR/initialize"
#!/bin/bash
## virtualenvwrapper/initialize
# This hook is run during the startup phase when loading virtualenvwrapper.sh.

function_exists() {
    ## function_exists()    -- check whether function 'name' exists
    declare -f $1 2>&1 > /dev/null
    return $?
}

## source the dotfiles_ functions if $__DOTFILES is set
declare -f 'dotfiles_initialize' 2>&1 > /dev/null \
    && dotfiles_initialize

lsvirtualenvs() {
    # lsvirtualenvs()       -- list virtualenvs in $WORKON_HOME
    cmd=${@:-""}
    (cd ${WORKON_HOME} &&
    for venv in $(ls -adtr ${WORKON_HOME}/**/lib/python?.? | \
        sed "s:$WORKON_HOME/\(.*\)/lib/python[0-9]\.[0-9]:\1:g"); do
        if [ -n "${cmd}" ]; then
            $cmd $venv ;
        else
            echo "${venv}" ;
        fi
    done)
}
lsve() {
    # lsve()                -- list virtualenvs in $WORKON_HOME
    lsvirtualenvs $@
}

backup_virtualenv() {
    # backup_virtualenv()   -- backup VIRTUAL_ENV_NAME $1 to [$2]
    venv=${1}
    _date=$(date +'%FT%T%z')
    bkpdir=${2:-"${WORKON_HOME}/_venvbkps/${_date}"}
    test -d ${bkpdir} || mkdir -p ${bkpdir}
    archivename="venvbkp.${venv}.${_date}.tar.gz"
    archivepath="${bkpdir}/${archivename}"
    (cd ${WORKON_HOME}; \
    tar czf ${archivepath} ${venv} \
        && echo "${archivename}" \
        || (echo "err: ${venv} (${archivename})" 1>&2))
}

backup_virtualenvs() {
    # backup_virtualenvs()  -- backup all virtualenvs in $WORKON_HOME to [$1]
    date=$(date +'%FT%T%z')
    bkpdir=${1:-"${WORKON_HOME}/_venvbkps/${date}"}
    echo BKPDIR="${bkpdir}"
    test -d ${bkpdir} || mkdir -p ${bkpdir}
    lsvirtualenvs
    venvs=$(lsvirtualenvs)
    (cd ${WORKON_HOME}; \
    for venv in ${venvs}; do
        backup_virtualenv ${venv} ${bkpdir} \
        2>> ${bkpdir}/venvbkps.err \
        | tee -a ${bkpdir}/venvbkps.list
    done)
    cat ${bkpdir}/venvbkps.err
    echo BKPDIR="${bkpdir}"
}

rebuild_virtualenv() {
    # rebuild_virtualenv()      -- rebuild a virtualenv, leaving pkgs in place
    echo "rebuild_virtualenv()"
    set -x
    venvname="${1}"
    virtual_env=${2:-"${WORKON_HOME}/${venvname}"}
    set +x
    bin="${virtual_env}/bin"
    rm -fv ${bin}/python ${bin}/python2 ${bin}/python2.7 \
        ${bin}/pip ${bin}/pip-2.7 \
        ${bin}/easy_install ${bin}/easy_install-2.7 \
        ${bin}/activate*
    pyver=$(python -c "import sys; print('{}.{}'.format(*sys.version_info[:2]))")
    find -E "${virtual_env}/lib/python${pyver}/site-packages" \
        -iname 'pip*' -delete
    find -E "${virtual_env}/lib/python${pyver}/site-packages" \
        -iname 'setuptools*' -delete
    find -E "${virtual_env}/lib/python${pyver}/site-packages" \
        -iname 'distribute*' -delete
    deactivate
    mkvirtualenv ${venvname}
    #${bin}/pip install -v -v -r <(${bin}/pip freeze)
    #${bin}/pip install -r ${_WRD}/requirements.txt
}

rebuild_virtualenvs() {
    # rebuild_virtualenvs()     -- rebuild all virtualenvs in $WORKON_HOME
    lsve rebuild_virtualenv
}

### bashrc.gcloud.sh

_setup_google_cloud() {
    # _setup_google_cloud() -- configure gcloud $PATH and bash completions
    export _GCLOUD_PREFIX="/srv/wrk/google-cloud-sdk"

    #The next line updates PATH for the Google Cloud SDK.
    source "${_GCLOUD_PREFIX}/path.bash.inc"

    #The next line enables bash completion for gcloud.
    source "${_GCLOUD_PREFIX}/completion.bash.inc"
}
### bashrc.venv.sh
#   note: most of these aliases and functions are overwritten by `we` 
## Variables

    # __PROJECTSRC -- path to local project settings script
export __PROJECTSRC="${PROJECT_HOME}/.projectsrc.sh"
[ -f $__PROJECTSRC ] && source $__PROJECTSRC

__setup_dotfiles() {
    # __DOTFILES="${WORKON_HOME}/dotfiles/src/dotfiles"
    we dotfiles
    cdw
    e $_USRLOG && editp
}


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
cdlog () {
    # cdlog()   -- cd $_LOG
    cd "${_LOG}"/$@
}
cdww () {
    # cdww()    -- cd $_WWW
    cd "${_WWW}"/$@
}
cdl () {
    # cdl()     -- cd $_LIB
    cd "${_LIB}"/$@
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
cdw () {
    # cdw()     -- cd $_WRD
    cd "${_WRD}"/$@
}

cdwrk () {
    # cdwrk()   -- cd $WORKON_HOME
    cd "${WORKON_HOME}/$@"
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

    # ssv   -- supervisord   -c ${_SVCFG}
    alias ssv='supervisord -c "${_SVCFG}"'
    # sv    -- supervisorctl -c ${_SVCFG}
    alias sv='supervisorctl -c "${_SVCFG}"'
    # svd   -- supervisorctl -c ${_SVCFG} restart && sv tail -f dev
    alias svd='supervisorctl -c "${_SVCFG}" restart dev && supervisorctl -c "${_SVCFG}" tail -f dev'
    # svt   -- supervisorctl -c "${_SVCFG}" tail -f
    alias svt='sv tail -f'

    # hgw   -- hg -R  ${_WRD}
    alias hgw='hg -R "${_WRD}"'
    # hg-   -- hg -R  ${_WRD}
    alias hg-='hg -R "${_WRD}"'

    # gitw  -- git -C ${_WRD}
    alias gitw='git -C "${_WRD}"'
    # git-  -- git -C ${_WRD}
    alias git-='git -C "${_WRD}"'

    # serve-    -- ${_SERVE_}
    alias serve-='${_SERVE_}'
    # shell-    -- ${_SHELL_}
    alias shell-='${_SHELL_}'
    # test-     -- cd ${_WRD} && python setup.py test
    alias test-='(cd ${_WRD} && python "${_WRD_SETUPY}" test)'
    # testr-    -- reset; cd ${_WRD} && python setup.py test
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
basename $VIRTUAL_ENV


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


### bashrc.venv.pyramid.sh

workon_pyramid_app() {
    # workon_pyramid_app()  -- $VIRTUAL_ENV_NAME [$_APP] [open_terminals]
    _VENVNAME=$1
    _APP=$2

    _OPEN_TERMS=${3:-""}

    _VENVCMD="workon ${_VENVNAME}"
    we "${_VENVNAME}" "${_APP}"

    export _EGGSETUPPY="${_WRD}/setup.py"
    export _EGGCFG="${_WRD}/development.ini"

    _EDITCFGCMD="${_EDITCMD} ${_EGGCFG}"
    _SHELLCMD="${_BIN}/pshell ${_EGGCFG}"
    _SERVECMD="${_BIN}/pserve --reload --monitor-restart ${_EGGCFG}"
    _TESTCMD="python ${_EGGSETUPPY} nosetests"

    alias _serve="${_SERVECMD}"
    alias _shell="${_SHELLCMD}"
    alias _test="${_TESTCMD}"
    alias _editcfg="${_EDITCFGCMD}"
    alias _glog="hgtk -R "${_WRD}" log"
    alias _log="hg -R "${_WRD}" log"

    if [ -n "${_OPEN_TERMS}" ]; then
        ${EDITOR} "${_WRD}" &
        #open tabs
        #gnome-terminal \
        #--working-directory="${_WRD}" \
        #--tab -t "${_APP} serve" -e "bash -c \"${_SERVECMD}; bash -c \"workon_pyramid_app $VIRTUAL_ENV_NAME $_APP 1\"\"" \
        #--tab -t "${_APP} shell" -e "bash -c \"${_SHELLCMD}; bash\"" \
        #--tab -t "${_APP} bash" -e "bash"
    fi
}



### bashrc.editor.sh

_setup_editor() {
    # setup_editor()    -- configure ${EDITOR}
    #   VIMBIN  (str):   /usr/bin/vim
    #   GVIMBIN (str):   /usr/bin/gvim
    #   MVIMBIN (str):   /usr/local/bin/mvim
    #   GUIVIMBIN (str): $GVIMBIN || $MVIMBIN || ""
    #   EDITOR  (str):   $VIMBIN -f || $GUIVIMBIN -f
    #   EDITOR_ (str):   $EDITOR || $GUIVIMBIN $VIMCONF --remote-tab-silent
    #   VIMCONF (str):   --servername ${VIRTUAL_ENV_NAME:-'EDITOR'}
    #   SUDO_EDITOR (str): $EDITOR
    export VIMBIN="/usr/bin/vim"
    export GVIMBIN="/usr/bin/gvim"
    export MVIMBIN="/usr/local/bin/mvim"
    export GUIVIMBIN=""
    if [ -x ${GVIMBIN} ]; then
        export GUIVIMBIN=$GVIMBIN
    elif [ -x ${MVIMBIN} ]; then
        export GUIVIMBIN=$MVIMBIN
    fi

    export EDITOR="${VIMBIN} -f"
    export EDITOR_="${EDITOR}"
    export SUDO_EDITOR="${VIMBIN} -f"

    if [ -n "${GUIVIMBIN}" ]; then
        export VIMCONF="--servername ${VIRTUAL_ENV_NAME:-'EDITOR'}"
        export EDITOR="${GUIVIMBIN} -f"
        export EDITOR_="${GUIVIMBIN} ${VIMCONF} --remote-tab-silent"
        export SUDO_EDITOR="${GUIVIMBIN} -f"
        alias gvim="${GUIVIMBIN}"
    else
        unset -f $GVIMBIN
        unset -f $MVIMBIN
        unset -f $USEGVIM
    fi

    export _EDITOR="${EDITOR}"
}
_setup_editor


ggvim() {
    # ggvim()   -- ${EDITOR} $@ 2>&1 >/dev/null
    ${EDITOR} $@ 2>&1 > /dev/null
}


e() {
    # e()       -- ${EDITOR_} $@      [ --servername $VIRTUAL_ENV_NAME ]
    ${EDITOR_} $@
}

edit() {
    # edit()    -- ${EDITOR_} $@      [ --servername $VIRTUAL_ENV_NAME ]
    ${EDITOR_} $@
}

editcfg() {
    # editcfg() -- ${EDITOR_} ${_CFG} [ --servername $VIRTUAL_ENV_NAME ]
    ${EDITOR_} ${_CFG}
}

sudoe() {
    # sudoe()   -- EDITOR=${SUDO_EDITOR} sudo -e
    EDITOR=${SUDO_EDITOR} sudo -e $@
}
sudovim() {
    # sudoe()   -- EDITOR=${SUDO_EDITOR} sudo -e
    sudoe $@
}

### bashrc.vimpagers.sh

_configure_lesspipe() {
    # _configure_lesspipe() -- (less <file.zip> | lessv)
    lesspipe=$(which lesspipe.sh 2>/dev/null || false)
    if [ -n "${lesspipe}" ]; then
        eval "$(${lesspipe})"
    fi
}
_configure_lesspipe
which lesspipe.sh 2>/dev/null || false
${lesspipe}
LESSOPEN="|/usr/local/bin/lesspipe.sh %s"
export LESSOPEN


vimpager() {
    # vimpager() -- call vimpager
    _PAGER=$(which vimpager)
    if [ -x "${_PAGER}" ]; then
        ${_PAGER} $@
    else
        echo "error: vimpager not found. (see lessv: 'lessv $@')"
    fi
}


lessv () {
    # lessv()    -- less with less.vim and vim (g:tinyvim=1)
    if [ -t 1 ]; then
        if [ $# -eq 0 ]; then
            #read stdin
            ${VIMBIN} --cmd "let g:tinyvim=1" \
                --cmd "runtime! macros/less.vim" \
                --cmd "set nomod" \
                --cmd "set noswf" \
                -c "set colorcolumn=0" \
                -c "map <C-End> <Esc>G" \
                -
        else
            ${VIMBIN} \
                --cmd "let g:tinyvim=1" \
                --cmd "runtime! macros/less.vim" \
                --cmd "set nomod" \
                --cmd "set noswf" \
                -c "set colorcolumn=0" \
                -c "map <C-End> <Esc>G" \
                $@
        fi
    else
        #Output is not a terminal, cat arguments or stdin
        if [ $# -eq 0 ]; then
            less
        else
            less "$@"
        fi
    fi
}

lessg() {
    # lessg()  -- less with less.vim and gvim / mvim
    VIMBIN=${GUIVIMBIN} lessv $@
}

lesse() {
    # lesse()  -- less with current venv's vim server
    ${EDITOR} $@
}

manv() {
    # manv()   -- view manpages in vim
    alias man_="/usr/bin/man"
    if [ $# -eq 0 ]; then
        /usr/bin/man
    else
        #/usr/bin/whatis "$@" >/dev/null
        $(which vim) \
            --noplugin \
            -c "runtime ftplugin/man.vim" \
            -c "Man $*" \
            -c 'silent! only' \
            -c 'nmap q :q<CR>' \
            -c 'set nomodifiable' \
            -c 'set colorcolumn=0'
    fi
}

mang() {
    # mang()   -- view manpages in gvim / mvim
    if [ $# -eq 0 ]; then
        /usr/bin/man
    else
        $GUIVIMBIN \
            --noplugin \
            -c "runtime ftplugin/man.vim" \
            -c "Man $*" \
            -c 'silent! only' \
            -c 'nmap q :q<CR>' \
            -c 'set nomodifiable' \
            -c 'set colorcolumn=0'
    fi
}

mane() {
    # mane()   -- open manpage with venv's vim server
    $GUIVIMBIN ${VIMCONF} --remote-send "<ESC>:Man $@<CR>"
}

### bashrc.usrlog.sh
    # _USRLOG (str): path to .usrlog userspace shell command log
    # stid()     -- set $TERM_ID to a random string
    # stid $name -- set $TERM_ID to string
    # note()     -- add a dated note to $_USRLOG [_usrlog_append]
    # usrlogv()  -- open usrlog with vim:   $VIMBIN + $_USRLOG
    # usrlogg()  -- open usrlog with gmvim: $GUIVIMBIN + $_USRLOG
    # usrloge()  -- open usrlog with editor:$EDITOR + $_USRLOG
    # ut()       -- tail $_USRLOG
    # ug()       -- egrep current usrlog: egrep $@ $_USRLOG
    # ugall()    -- egrep $@ $__USRLOG ${WORKON_HOME}/*/.usrlog
    # ugrin()    -- grin current usrlog: grin $@ $_USRLOG
    # ugrinall() -- grin $@  $__USRLOG ${WORKON_HOME}/*/.usrlog
    # lsusrlogs()-- ls -tr   $__USRLOG ${WORKON_HOME}/*/.usrlog

#TODO
eval "${__DOTFILES}/etc/usrlog.sh"
/Users/W/.dotfiles/etc/usrlog.sh
bash: /Users/W/.dotfiles/etc/usrlog.sh: Permission denied
_usrlog_setup
bash: _usrlog_setup: command not found

usrlogv() {
    # usrlogv() -- open $_USRLOG w/ $VIMBIN (and skip to end)
    file=${1:-$_USRLOG}
    lessv + ${file}
}

usrlogg() {
    # usrlogg() -- open $_USRLOG w/ $GUIVIMBIN (and skip to end)
    file=${1:-$_USRLOG}
    lessg + ${file}
}

usrloge() {
    # usrloge() -- open $_USRLOG w/ $EDITOR_ [ --servername $VIRTUAL_ENV_NAME ]
    file=${1:-$_USRLOG}
    lesse "+ ${file}"
}


## xlck     -- screensaver
if [ ! -d '/Library' ]; then  # not on OSX
    source "${__DOTFILES}/etc/xlck.sh"
fi

### bashrc.aliases.sh

_loadaliases () {
    #  _load_aliases()  -- load aliases
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

    if [ -n "${__IS_MAC}" ]; then
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
    
    alias shtop='sudo htop'
    alias t='tail'
    alias tf='tail -f'
    alias xclipc='xclip -selection c'
}
_loadaliases



### bashrc.commands.sh
# usage: bash -c 'source bashrc.commands.sh; funcname <args>'

chown-me () {
    # chown-me          -- chown -Rv user
    (set -x; \
    chown -Rv $(id -un) $@ )
}

chown-me-mine () {
    # chown-me-mine     -- chown -Rv user:user && chmod -Rv go-rwx
    (set -x; \
    chown -Rv $(id -un):$(id -un) $@ ; \
    chmod -Rv go-rwx $@ )
}

chown-sme () {
    # chown-sme         -- sudo chown -Rv user
    (set -x; \
    sudo chown -Rv $(id -un) $@ )
}

chown-sme-mine () {
    # chown-sme-mine    -- sudo chown -Rv user:user && chmod -Rv go-rwx
    (set -x; \
    sudo chown -Rv $(id -un):$(id -un) $@ ; \
    sudo chmod -Rv go-rwx $@ )
}

chmod-unumask () {
    # chmod-unumask()   -- recursively add other+r (files) and other+rx (dirs)
    path=$1
    sudo find "${path}" -type f -exec chmod -v o+r {} \;
    sudo find "${path}" -type d -exec chmod -v o+rx {} \;
}


new-sh () {
    # new-sh()          -- create and open a new shell script at $1
    file=$1
    if [ -e $1 ]; then
        echo "$1 exists"
    else
        touch $1
        echo "#!/bin/sh" >> $1
        echo "## " >> $1
        chmod 700 $1
        ${EDITOR_} +2 $1
    fi
}

diff-dirs () {
    # diff-dirs()       -- list differences between directories
    F1=$1
    F2=$2
    #FIND="find . -printf '%T@\t%s\t%u\t%Y\t%p\n'"
    diff -Naur \
        <(cd $F1; find . | sort ) \
        <(cd $F2; find . | sort )
}

diff-stdin () {
    # diff-stdin()     -- diff the output of two commands
    DIFFBIN='diff'
    $DIFFBIN -u <($1) <($2)
}

wopen () {
    # wopen()   -- open path/URI/URL $1 in a new browser tab
    #              see: scripts/x-www-browser
    if [ -n "${__IS_MAC}" ]; then
        open $@
    elif [ -n "${__IS_LINUX}" ]; then
        x-www-browser $@
    else
        python -m webbrowser -t $@
    fi
}

find-largefiles () {
    # find-largefiles   -- find files larger than size (default: +10M)
    SIZE=${1:-"+10M"}
    find . -xdev -type f -size "${SIZE}" -exec ls -alh {} \;
}

find-pdf () {
    # find-pdf          -- find pdfs and print info with pdfinfo
    SPATH='.'
    files=$(find "$SPATH" -type f -iname '*.pdf' -printf "%T+||%p\n" | sort -n)
    for f in $files; do
        echo '\n==============='$f;
        fname="$(echo "$f" | pycut -d'||' -f1)";
        echo "FNAME" $fname
        ls -l "$fname"
        pdfinfo "$fname" | egrep --color=none 'Title|Keywords|Author';
    done
}

find-lately () {
    # find-lately()     -- list and sort files in paths $@ by mtime
    set -x
    paths=${@:-"/"}
    lately="lately.$(date +'%Y%m%d%H%M%S')"
    find $paths -exec \
        stat -f '%Sc%t%N%t%z%t%Su%t%Sg%t%Sp%t%T' -t '%F %T%z' {} \; \
        > ${lately} 2> ${lately}.errors
    sort ${lately} > ${lately}.sorted
    set +x
}

find-setuid () {
    # find-setuid()     -- find all setuid and setgid files
    #                      stderr > find-setuid.errors
    #                      stdout > find-setuid.files
    sudo \
        find /  -type f \( -perm -4000 -o -perm -2000 \) -exec ls -ld '{}' \; \
        2> find-setuid.errors \
        > find-setuid.files
}

find-startup () {
    # find-startup()    -- find common startup files in common locations
    cmd=${@:-"ls"}
    paths='/etc/rc?.d /etc/init.d /etc/init /etc/xdg/autostart /etc/dbus-1'
    paths="$paths ~/.config/autostart /usr/share/gnome/autostart"
    for p in $paths; do
        if [ -d $p ]; then
            find $p -type f | xargs $cmd
        fi
    done
}

find-ssl() {
    # find-ssl()        -- find .pem and .db files and print their metadata
    #apt-get install libnss3-tools
    _runcmd(){
        cmd="${1}"
        desc="${2}"
        echo "#######"
        echo "'${cmd}' : ${desc}"
        echo "#------"
        echo -e "$($cmd)"
        echo -e "\n#."
    }

    for cert in $(locate *.pem); do
        echo "-- $cert --"
        openssl x509 -in $cert -text
    done
    for d in $(locate '*.db' | egrep 'key[[:digit:]].db'); do  
        kpath=$(dirname $d) 
        _runcmd "certutil  -L -d sql:${kpath}"  "${kpath}"
    done
}

find-dpkgfile () {
    # find-dpkgfile()   -- search dpkgs with apt-file
    apt-file search $@
}

find-dpkgfiles () {
    # find-dpkgfiles()  -- sort dpkg /var/lib/dpkg/info/<name>.list
    cat /var/lib/dpkg/info/${1}.list | sort
}

deb-chksums () {
    # checks filesystem against dpkg's md5sums 
    #
    # Author: Filippo Giunchedi <filippo@esaurito.net>
    # Version: 0.1
    #
    # this file is public domain 

    exclude="usr/share/locale/"
    include="bin/"

    pushd .
    cd /

    for f in /var/lib/dpkg/info/*.md5sums; do
        package=$( basename "$f" | cut -d. -f1 )
        tmpfile=$( mktemp /tmp/dpkgcheck.XXXXXX )
        egrep "$include" "$f" | egrep -v "$exclude" > $tmpfile
        if [ -z "$(head $tmpfile)" ]; then continue; fi
        md5sum -c "$tmpfile"
        if [ $? -gt 0 ]; then
            echo "md5sum for $package has failed!"
            rm "$tmpfile"
            break
        fi
        rm "$tmpfile"
    done

    popd
}

deb-mkrepo () {
    # deb-mkrepo    -- create dpkg Packages.gz and Sources.gz from dir ${1}
    REPODIR=${1:-"/var/www/nginx-default/"}
    cd $REPODIR
    dpkg-scanpackages . /dev/null | gzip -9c > $REPODIR/Packages.gz
    dpkg-scansources . /dev/null | gzip -9c > $REPODIR/Sources.gz
}

mnt-chroot-bind () {
    # mnt-chroot-bind()    -- bind mount linux chroot directories
    DEST=$1
    sudo mount proc -t proc ${DEST}/proc
    sudo mount -o bind /dev ${DEST}/dev
    sudo mount sysfs -t sysfs ${DEST}/sys
    sudo mount -o bind,ro /boot {DEST}/boot
}
mnt-cifs () {
    # mnt-cifs()    -- mount a CIFS mount
    URI="$1" # //host/share
    MNTPT="$2"
    OPTIONS="-o user=$3,password=$4"
    mount -t cifs $OPTIONS $URI $MNTPT
}
mnt-davfs () {
    # mnt-davfs()   -- mount a WebDAV mount
    URL="$1"
    MNTPT="$2"
    OPTIONS="-o rw,user,noauto"
    mount -t davfs $OPTIONS $URL $MNTPT
}

lsof-sh () {
    # lsof-sh()     -- something like lsof
    processes=$(find /proc -regextype egrep -maxdepth 1 -type d -readable -regex '.*[[:digit:]]+')
    for p in $processes; do
        cmdline=$(cat $p/cmdline)
        cmd=$(echo $cmdline | sed 's/\(.*\)\s.*/\1/g' | sed 's/\//\\\//g')
        pid=$(echo $p | sed 's/\/proc\/\([0-9]*\)/\1/')
        echo $pid $cmdline 
        #maps=$(cat $p/maps )
        sed_pattern="s/\(.*\)/$pid \1\t$cmd/g"
        cat $p/maps | sed "$sed_pattern"
    done
    #~ lsof_ | grep 'fb' | pycut -f 6,5,0,2,1,7 -O '%s' | sort -n 
}


lsof-net () {
    # lsof-net()    -- lsof the network things
    ARGS=${@:-''}
    for pid in `lsof -n -t -U -i4 2>/dev/null`; do
        echo "-----------";
        ps $pid;
        lsof -n -a $ARGS -p $pid 2>/dev/null;
    done
}


net-stat () {
    # net-stat()    -- print networking information
    echo "# net_stat:"  `date`
    echo "#####################################################"
    set -x
    sudo ip a 2>&1
    sudo ip r 2>&1
    sudo ifconfig -a 2>&1
    sudo route -n 2>&1
    sudo iptables -L -n 2>&1
    sudo netstat -ntaup 2>&1 | sort -n
    set +x
}


ssh-prx () {
    # ssh-prx()     -- SSH SOCKS
    RUSERHOST=$1
    RPORT=$2

    LOCADDR=${3:-"10.10.10.10"}
    PRXADDR="$LOCADDR:1080"
    sudo ip addr add $LOCADDR dev lo netmask 255.255.255.0
    ssh -ND $PRXADDR $RUSERHOST -p $RPORT

    echo "$PRXADDR"
}

strace- () {
    # strace-()         -- strace with helpful options
    strace -ttt -f -F $@ 2>&1
}

strace-f () {
    # strace-f()        -- strace -e trace=file + helpful options
    strace_ -e trace=file $@
}

strace-f-noeno () {
    # strace-f-noeno    -- strace -e trace=file | grep -v ENOENT
    strace_ -e trace=file $@ 2>&1 \
        | grep -v '-1 ENOENT (No such file or directory)$' 
}

hgst() {
    # hgst()    -- hg diff --stat, hg status, hg diff
    repo=${1:-"$(pwd)"}
    shift

    hgopts="-R ${repo} --pager=no"

    if [ -n "$(echo "$@" | grep "color")" ]; then
        hgopts="${hgopts} --color=always"
    fi
    echo "###"
    echo "## ${repo}"
    echo '###'
    hg ${hgopts} diff --stat | sed 's/^/## /'
    echo '###'
    hg ${hgopts} status | sed 's/^/## /'
    echo '###'
    hg ${hgopts} diff
    echo '###'
}


## bashmarks
#  l    -- list bashmarks
#  s    -- save bashmarks as $1
#  g    -- goto bashmark $1
#  p    -- print bashmark $1
#  d    -- delete bashmark $1
source "${__DOTFILES}/etc/bashmarks/bashmarks.sh"
# Copyright (c) 2010, Huy Nguyen, http://www.huyng.com
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted provided 
# that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice, this list of conditions 
#       and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
#       following disclaimer in the documentation and/or other materials provided with the distribution.
#     * Neither the name of Huy Nguyen nor the names of contributors
#       may be used to endorse or promote products derived from this software without 
#       specific prior written permission.
#       
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED 
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR 
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.


# USAGE: 
# s bookmarkname - saves the curr dir as bookmarkname
# g bookmarkname - jumps to the that bookmark
# g b[TAB] - tab completion is available
# p bookmarkname - prints the bookmark
# p b[TAB] - tab completion is available
# d bookmarkname - deletes the bookmark
# d [TAB] - tab completion is available
# l - list all bookmarks

# setup file to store bookmarks
if [ ! -n "$SDIRS" ]; then
    SDIRS=~/.sdirs
fi
touch $SDIRS

RED="0;31m"
GREEN="0;33m"

# save current directory to bookmarks
function s {
    check_help $1
    _bookmark_name_valid "$@"
    if [ -z "$exit_message" ]; then
        _purge_line "$SDIRS" "export DIR_$1="
        CURDIR=$(echo $PWD| sed "s#^$HOME#\$HOME#g")
        echo "export DIR_$1=\"$CURDIR\"" >> $SDIRS
    fi
}

# jump to bookmark
function g {
    check_help $1
    source $SDIRS
    target="$(eval $(echo echo $(echo \$DIR_$1)))"
    if [ -d "$target" ]; then
        cd "$target"
    elif [ ! -n "$target" ]; then
        echo -e "\033[${RED}WARNING: '${1}' bashmark does not exist\033[00m"
    else
        echo -e "\033[${RED}WARNING: '${target}' does not exist\033[00m"
    fi
}

# print bookmark
function p {
    check_help $1
    source $SDIRS
    echo "$(eval $(echo echo $(echo \$DIR_$1)))"
}

# delete bookmark
function d {
    check_help $1
    _bookmark_name_valid "$@"
    if [ -z "$exit_message" ]; then
        _purge_line "$SDIRS" "export DIR_$1="
        unset "DIR_$1"
    fi
}

# print out help for the forgetful
function check_help {
    if [ "$1" = "-h" ] || [ "$1" = "-help" ] || [ "$1" = "--help" ] ; then
        echo ''
        echo 's <bookmark_name> - Saves the current directory as "bookmark_name"'
        echo 'g <bookmark_name> - Goes (cd) to the directory associated with "bookmark_name"'
        echo 'p <bookmark_name> - Prints the directory associated with "bookmark_name"'
        echo 'd <bookmark_name> - Deletes the bookmark'
        echo 'l                 - Lists all available bookmarks'
        kill -SIGINT $$
    fi
}

# list bookmarks with dirnam
function l {
    check_help $1
    source $SDIRS
        
    # if color output is not working for you, comment out the line below '\033[1;32m' == "red"
    env | sort | awk '/DIR_.+/{split(substr($0,5),parts,"="); printf("\033[0;33m%-20s\033[0m %s\n", parts[1], parts[2]);}'
    
    # uncomment this line if color output is not working with the line above
    # env | grep "^DIR_" | cut -c5- | sort |grep "^.*=" 
}
# list bookmarks without dirname
function _l {
    source $SDIRS
    env | grep "^DIR_" | cut -c5- | sort | grep "^.*=" | cut -f1 -d "=" 
}

# validate bookmark name
function _bookmark_name_valid {
    exit_message=""
    if [ -z $1 ]; then
        exit_message="bookmark name required"
        echo $exit_message
    elif [ "$1" != "$(echo $1 | sed 's/[^A-Za-z0-9_]//g')" ]; then
        exit_message="bookmark name is not valid"
        echo $exit_message
    fi
}

# completion command
function _comp {
    local curw
    COMPREPLY=()
    curw=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W '`_l`' -- $curw))
    return 0
}

# ZSH completion command
function _compzsh {
    reply=($(_l))
}

# safe delete line from sdirs
function _purge_line {
    if [ -s "$1" ]; then
        # safely create a temp file
        t=$(mktemp -t bashmarks.XXXXXX) || exit 1
        trap "rm -f -- '$t'" EXIT

        # purge line
        sed "/$2/d" "$1" > "$t"
        mv "$t" "$1"

        # cleanup temp file
        rm -f -- "$t"
        trap - EXIT
    fi
}

# bind completion command for g,p,d to _comp
if [ $ZSH_VERSION ]; then
    compctl -K _compzsh g
    compctl -K _compzsh p
    compctl -K _compzsh d
else
    shopt -s progcomp
    complete -F _comp g
    complete -F _comp p
    complete -F _comp d
fi
#  lsbashmarks -- list Bashmarks (e.g. for NERDTree)
lsbashmarks () {
    export | grep 'DIR_' | pyline "line[15:].replace('\"','').split('=',1)"
}

# ~/.dotfiles/bin/nerdtree_to_bashmarks.py



### 70-bashrc.repos.sh

#objectives:
#* [ ] create a dotfiles venv (should already be created by dotfiles install)
#* [ ] create a src venv (for managing a local set of repositories)
#
#* [x] create Hg_ methods for working with a local repo set
#* [ ] create Git_ methods for working with a local repo set
#
#* [-] host docs locally with a one-shot command (host_docs)
#
# Use Cases
# * Original: a bunch of commands that i was running frequently
#   before readthedocs (and hostthedocs)
# * local mirrors (manual, daily?)
#   * no internet, outages
#   * push -f
#   * (~offline) Puppet/Salt source installs
#     * bandwidth: testing a recipe that pulls a whole repositor(ies)
# * what's changed in <project>'s source dependencies, since i looked last
#
# Justification
# * very real risks for all development projects
#   * we just assume that GitHub etc. are immutable and forever
#
# Features (TODO) [see: pyrpo]
# * Hg <subcommands>
# * Git <subcommands>
# * Bzr <subcommands>
# * periodic backups / mirroring
# * gitweb / hgweb
# * mirror_and_backup <URL>
# * all changes since <date> for <set_of_hg-git-bzr-svn_repositories>
# * ideally: transparent proxy
#   * +1: easiest
#   * -1: pushing upstream
#
# Caveats
# * pasting / referencing links which are local paths
# * synchronization lag
# * duplication: $__SRC/hg/<pkg> AND $VIRTUAL_ENV/src/<pkg>
#

setup_dotfiles_docs_venv() {
    #  setup_dotfiles_docs_venv -- create default 'docs' venv
    deactivate

    __DOCSENV="docs"
    export __DOCS="${WORKON_HOME}/${__DOCSENV}"
    export __DOCSWWW="${__DOCS}/var/www"
    mkvirtualenv_conda_if_available $__DOCSENV
    workon_conda_if_available $__DOCS
    _venv_ensure_paths $__DOCS
}

setup_dotfiles_src_venv() {
    #  setup_dotfiles_src_venv -- create default 'src' venv
    #
    #   __SRC_HG=${WORKON_HOME}/src/src/hg
    #   __SRC_GIT=${WORKON_HOME}/src/src/git
    #
    #  Hg runs hg commands as user hg
    #  Git runs git commands as user git
    #
    #  Hgclone will mirror to $__SRC_HG
    #  Gitclone will mirror to $__SRC_GIT
    #
    #
    deactivate
    __SRCENV="src"
    export __SRC=${WORKON_HOME}/${__SRCENV}/src
    export __SRC_HG=${__SRC}/hg
    export __SRC_GIT=${__SRC_GIT}/git
    mkvirtualenv_conda_if_available $__SRCENV
    workon_conda_if_available $__SRCENV

    _venv_ensure_paths ${WORKON_HOME}/${__SRCENV}
    ensure_mkdir $__SRC
    ensure_mkdir $__SRC/git
    ensure_mkdir $__SRC/hg
    ensure_mkdir ${prefix}/var/www
}


fixperms () {
    #fix permissions for hgweb? TODO
    __PATH=$1
    sudo chown -R hg:hgweb "$__PATH"
    sudo chmod -R g+rw "$__PATH"
}

# __SRC_GIT_REMOTE_URI_PREFIX   -- default git remote uri prefix
__SRC_GIT_REMOTE_URI_PREFIX="ssh://git@git.create.wrd.nu"
# __SRC_GIT_REMOTE_NAME         -- name for git remote v
__SRC_GIT_REMOTE_NAME="create"
# __SRC_HG_REMOTE_URI_PREFIX    -- default hg remote uri prefix
__SRC_HG_REMOTE_URI_PREFIX="ssh://hg@hg.create.wrd.nu"
# __SRC_HG_REMOTE_NAME          -- name for hg paths
__SRC_HG_REMOTE_NAME="create"

__SRC_GIT_GITOLITE_ADMIN=$HOME/gitolite-admin

Git_create_new_repo(){
    ## Create a new hosted repository with gitolite-admin
    #  $1   -- repo [user/]name (e.g. westurner/dotfiles)
    reponame=$1  # (e.g. westurner/dotfiles)
    cd $__SRC_GIT_GITOLITE_ADMIN_REPO && \
    ./add_repo.sh "$reponame" 
}

Git_pushtocreate() {
    ## push a git repository to local git storage
    #  $1   -- repo [user/]name (e.g. westurner/dotfiles) 
    reponame=$1
    repo_uri="${__SRC_GIT_URI}/${reponame}"
    here=$(pwd)
    #  $2   -- path of local repo (e.g. ~/wrk/.ve/dotfiles/src/dotfiles)
    repo_local_path=$2
    remote_name=${__SRC_GIT_REMOTE_NAME}

    Git_create_new_repo $reponame
    (cd $repo_local_path;  \
        git remote add $remote_name $repo_uri  \
            "${__SRC_GIT_URI}/${username}/${reponame}" && \
        git push --all $remote_name && \
        cd $here)
}

Hg_create_new_repo() {
    ## Create a new hosted repository with mercurial-ssh
    reponame=$1
    cd $__SRC_HG_SERVER_REMOTE_ADMIN && \
        ./add_repo.sh "$reponame"  # TODO: create add_repo.sh
}

Hg_pushtocreate() {
    ## push a hg repository to local git storage
    #  $1   -- repo [user/]name (e.g. westurner/dotfiles)
    reponame=$1
    repo_uri="${__SRC_HG_URI}/${reponame}"
    here=$(pwd)
    #  $2   -- path of local repo (e.g. ~/wrk/.ve/dotfiles/src/dotfiles)
    repo_local_path=$2
    remote_name=${__SRC_HG_REMOTE_NAME}    
}


Hgclone () {
    url=$1
    shift
    path="${__SRC}/hg/$1"
    if [ -d $path ]; then
        echo "$path existing. Exiting." >&2
        echo "see: update_repo $1"
        return 0
    fi
    sudo -u hg -i /usr/bin/hg clone $url $path
    fixperms $path
}

Hg() {
    path="${__SRC}/hg/$1"
    path=${path:-'.'}
    shift
    cmd=$@
    sudo -H -u hg -i /usr/bin/hg -R "${path}" $cmd

    #if [ $? -eq 0 ]; then
    #    fixperms ${path}
    #fi
}

Hgcheck() {
    path="${__SRC}/$1"
    path=${path:-'.'}
    shift
    Hg $path tags
    Hg $path id -n
    Hg $path id
    Hg $path branch

    #TODO: last pulled time
}

Hgupdate() {
    path=$1
    shift
    Hg $path update $@
}

Hgstatus() {
    path=$1
    shift
    Hg $path update $@
}

Hgpull() {
    path=$1
    shift
    Hg $path pull $@
    Hgcheck $path
}

Hglog() {
    path=$1
    shift
    Hg -R $path log $@
}

Hgcompare () {
    one=$1
    two=$2
    diff -Naur \
        <(hg -R "${one}" log) \
        <(hg -R "${two}" log)
}

host_docs () {
    #  host_docs    -- build and host documentation in a local directory
    #   param $1: <project_name>
    #   param $2: [<path>]
    #   param $3: [<docs/Makefile>]
    #   param $4: [<docs/conf.py>]
    # * log documentation builds
    # * build a sphinx documentation set with a Makefile and a conf.py
    # * rsync to docs webserver
    # * set permissions

    # this is not readthedocs.org

    # note: you must manually install packages into the
    # local 'docs' virtualenv'
    set -x
    pushd .
    #workon docs
    name=${1}

    if [ -z "${name}" ]; then
        echo "must specify an application name"
        return 1
    fi

    path=${2:-"${__SRC}/${name}"}
    _makefile=${3}
    _confpy=${4}
    _default_makefile="${path}/docs/Makefile"
    _default_confpy="${path}/docs/conf.py"

    _default_builddir="${path}/_build"

    dest="${__DOCSWWW}/${name}"
    group="www-data"

    if [ -z "${_makefile}" ]; then
        if [ -f $_default_makefile ]; then
            _makefile=$_default_makefile;
        else
            echo "404: default_makefile: $_default_makefile" >&2
            __makefiles=$(find "${path}" -maxdepth 2 -type f -name Makefile)
            for __makefile in ${__makefiles[@]}; do
                if [ -n "${__makefile}" ]; then
                    grep -n -H 'sphinx-build' ${__makefile} \
                        && grep -n -H '^html:' ${__makefile}
                    if [ $? -eq 0 ]; then
                        echo 'Found sphinx-build Makefile: $__makefile'
                        # TODO: prompt?
                        _makefile=$__makefile
                    fi
                fi
            done
        fi

        if [ -f "${_makefile}" ]; then
            _builddir=$(dirname $_makefile)
        fi
    fi

    if [ -z "${_confpy}" ]; then
        if [ -f $_default_confpy ]; then
            _confpy=$_default_confpy;
        else
            echo "404: default_confpy: $_default_confpy" >&2
            confpys=$(find "${path}" -maxdepth 2 -type f -name conf.py)
            for __confpy in ${confpys[@]}; do
                grep -n -H 'sphinx-build' ${__confpy}
                if [ $? -eq 0 ]; then
                    echo 'found conf.py: $__confpy'
                    #TODO: prompt?
                    _confpy=$__confpy
                fi
            done
        fi

        if [ ! -f $_makefile ]; then
            _builddir=$(dirname $__confpy)
        fi

    fi

    _builddir=${_builddir:-${_default_builddir}}
    _buildlog="${_builddir}/build.log"
    _currentbuildlog="${_builddir}/build.current.log"


    cd $path
    rm -f $_currentbuildlog
    html_path=""
    echo '#' $(date) | tee -a $_buildlog | tee $_currentbuildlog

    if [ -n "$_makefile" ]; then
        #TODO
        #>> 'SPHINX_BUILD =    sphinx-build -Dhtml_theme=default -Dother '
        #<< 'SPHINX_BUILD =    sphinx-build -Dhtml_theme=default'
        #sed -i -r 's/(^SPHINXBUILD)( *= *)(sphinx-build)(.*)/\1\2\3 -Dhtml_theme="default"/g' $_makefile

        cd $(dirname $_makefile)
        make \
            SPHINXBUILD="sphinx-build -Dhtml_theme=\"default\"" \
            html | \
            tee -a $_buildlog | tee $_currentbuildlog
        html_path=$(tail -n 1 $_currentbuildlog | \
            sed -r 's/(.*)The HTML pages are in (.*).$/\2/g')
        echo $html_path

    elif [ -n "$_confpy" ]; then
        # >> 'html_theme = "_-_"
        # << 'html_theme = 'default'
        sed -i.bak -r 's/(^ *html_theme)( *= *)(.*)/\1\2"default"' $_confpy
        sourcedir=$(dirname $_confpy)
        html_path="${sourcedir}/_build/html"
        mkdir -p $html_path
        SPHINXBUILD="sphinx-build -Dhtml_theme=\"default\"" \
            sphinx-build \
                -b html \
                -D html_theme="default" \
                -c "${_confpy}" \
                $sourcedir \
                $html_path
    fi

    if [ -n "${html_path}" ]; then
        echo "html-path:" ${html_path}
        echo "dest:" ${dest}
        set -x
        rsync -avr "${html_path}/" "${dest}/" \
            | tee -a $_buildlog \
            | tee $_currentbuildlog
        set +x
        sudo chgrp -R $group "${dest}" \
            | tee -a $_buildlog \
            | tee $_currentbuildlog
    else
        echo "### ${_currentbuildlog}"
        cat $_currentbuildlog
    fi

    popd

    set +x
    deactivate
}



dotfiles_status
# dotfiles_status()
HOSTNAME='nb-mb1'
USER='W'
PROJECT_HOME='/Users/W/wrk'
WORKON_HOME='/Users/W/wrk/.ve'
VIRTUAL_ENV_NAME='dotfiles'
VIRTUAL_ENV='/Users/W/wrk/.ve/dotfiles'
_USRLOG='/Users/W/wrk/.ve/dotfiles/.usrlog'
_TERM_ID='#testing'
_SRC='/Users/W/wrk/.ve/dotfiles/src'
_APP='dotfiles'
_WRD='/Users/W/wrk/.ve/dotfiles/src/dotfiles'
PATH='/Users/W/Workspace/.virtualenvs/dotfiles/bin:/Users/W/.local/bin:/Users/W/.dotfiles/scripts:/usr/sbin:/sbin:/bin:/usr/local/bin:/usr/bin:/opt/X11/bin:/usr/local/git/bin'
__DOTFILES='/Users/W/.dotfiles'
#
exit
exit
