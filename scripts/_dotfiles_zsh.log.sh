# /etc/zsh/zshenv: system-wide .zshenv file for zsh(1).
#
# This file is sourced on all invocations of the shell.
# If the -f flag is present or if the NO_RCS option is
# set within this file, all other initialization files
# are skipped.
#
# This file should contain commands to set the command
# search path, plus other important environment variables.
# This file should not contain commands that produce
# output or assume the shell is attached to a tty.
#
# Global Order: zshenv, zprofile, zshrc, zlogin

#
# /etc/zshrc is sourced in interactive shells.  It
# should contain commands to set up aliases, functions,
# options, key bindings, etc.
#

## shell functions
#setenv() { export $1=$2 }  # csh compatibility

# Set prompts
PROMPT='[%n@%m]%~%# '    # default prompt
#RPROMPT=' %~'     # prompt for right side of screen

# bindkey -v             # vi key bindings
# bindkey -e             # emacs key bindings
bindkey ' ' magic-space  # also do history expansion on space

# Provide pathmunge for /etc/profile.d scripts
pathmunge()
{
    if ! echo $PATH | /bin/grep -qE "(^|:)$1($|:)" ; then
        if [ "$2" = "after" ] ; then
            PATH=$PATH:$1
        else
            PATH=$1:$PATH
        fi
    fi
}

_src_etc_profile_d()
{
    #  Make the *.sh things happier, and have possible ~/.zshenv options like
    # NOMATCH ignored.
    emulate -L ksh


    # from bashrc, with zsh fixes
    if [[ ! -o login ]]; then # We're not a login shell
        for i in /etc/profile.d/*.sh; do
	    if [ -r "$i" ]; then
	        . $i
	    fi
        done
        unset i
    fi
}
_src_etc_profile_d
# Enable 256 color capabilities for appropriate terminals

# Set this variable in your local shell config (such as ~/.bashrc)
# if you want remote xterms connecting to this system, to be sent 256 colors.
# This must be set before reading global initialization such as /etc/bashrc.
#   SEND_256_COLORS_TO_REMOTE=1

# Terminals with any of the following set, support 256 colors (and are local)
local256="$COLORTERM$XTERM_VERSION$ROXTERM_ID$KONSOLE_DBUS_SESSION"

if [ -n "$local256" ] || [ -n "$SEND_256_COLORS_TO_REMOTE" ]; then

  case "$TERM" in
    'xterm') TERM=xterm-256color;;
    'screen') TERM=screen-256color;;
    'Eterm') TERM=Eterm-256color;;
  esac
  export TERM

  if [ -n "$TERMCAP" ] && [ "$TERM" = "screen-256color" ]; then
    TERMCAP=$(echo "$TERMCAP" | sed -e 's/Co#8/Co#256/g')
    export TERMCAP
  fi
fi

unset local256
# Check for interactive bash and that we haven't already been sourced.
if [ -n "${BASH_VERSION-}" -a -n "${PS1-}" -a -z "${BASH_COMPLETION_COMPAT_DIR-}" ]; then

    # Check for recent enough version of bash.
    if [ ${BASH_VERSINFO[0]} -gt 4 ] || \
       [ ${BASH_VERSINFO[0]} -eq 4 -a ${BASH_VERSINFO[1]} -ge 1 ]; then
        [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/bash_completion" ] && \
            . "${XDG_CONFIG_HOME:-$HOME/.config}/bash_completion"
        if shopt -q progcomp && [ -r /usr/share/bash-completion/bash_completion ]; then
            # Source completion code.
            . /usr/share/bash-completion/bash_completion
        fi
    fi

fi
# color-grep initialization

/usr/libexec/grepconf.sh -c || return

alias grep='grep --color=auto' 2>/dev/null
alias egrep='egrep --color=auto' 2>/dev/null
alias fgrep='fgrep --color=auto' 2>/dev/null
# color-ls initialization

# Skip all for noninteractive shells.
[ -z "$PS1" ] && return

#when USER_LS_COLORS defined do not override user LS_COLORS, but use them.
if [ -z "$USER_LS_COLORS" ]; then

  alias ll='ls -l' 2>/dev/null
  alias l.='ls -d .*' 2>/dev/null

  INCLUDE=
  COLORS=

  for colors in "$HOME/.dir_colors.$TERM" "$HOME/.dircolors.$TERM" \
      "$HOME/.dir_colors" "$HOME/.dircolors"; do
    [ -e "$colors" ] && COLORS="$colors" && \
    INCLUDE="`cat "$COLORS" | grep '^INCLUDE' | cut -d ' ' -f2-`" && \
    break
  done

  [ -z "$COLORS" ] && [ -e "/etc/DIR_COLORS.$TERM" ] && \
  COLORS="/etc/DIR_COLORS.$TERM"

  [ -z "$COLORS" ] && [ -e "/etc/DIR_COLORS.256color" ] && \
  [ "x`tty -s && tput colors 2>/dev/null`" = "x256" ] && \
  COLORS="/etc/DIR_COLORS.256color"

  [ -z "$COLORS" ] && [ -e "/etc/DIR_COLORS" ] && \
  COLORS="/etc/DIR_COLORS"

  # Existence of $COLORS already checked above.
  [ -n "$COLORS" ] || return

  if [ -e "$INCLUDE" ];
  then
    TMP="`mktemp .colorlsXXX -q --tmpdir=/tmp`"
    [ -z "$TMP" ] && return

    cat "$INCLUDE" >> $TMP
    grep -v '^INCLUDE' "$COLORS" >> $TMP

    eval "`dircolors --sh $TMP 2>/dev/null`"
    rm -f $TMP
  else
    eval "`dircolors --sh $COLORS 2>/dev/null`"
  fi

  [ -z "$LS_COLORS" ] && return
  grep -qi "^COLOR.*none" $COLORS >/dev/null 2>/dev/null && return
fi

unset TMP COLORS INCLUDE

alias ll='ls -l --color=auto' 2>/dev/null
alias l.='ls -d .* --color=auto' 2>/dev/null
alias ls='ls --color=auto' 2>/dev/null
/usr/libexec/grepconf.sh -c || return
alias xzgrep='xzgrep --color=auto' 2>/dev/null
alias xzegrep='xzegrep --color=auto' 2>/dev/null
alias xzfgrep='xzfgrep --color=auto' 2>/dev/null
[ -f /usr/libexec/grepconf.sh ] || return

/usr/libexec/grepconf.sh -c || return
alias zgrep='zgrep --color=auto' 2>/dev/null
alias zfgrep='zfgrep --color=auto' 2>/dev/null
alias zegrep='zegrep --color=auto' 2>/dev/null
SSH_ASKPASS=/usr/libexec/openssh/gnome-ssh-askpass
export SSH_ASKPASS
# /etc/profile.d/lang.sh - set i18n stuff

sourced=0

if [ -n "$LANG" ]; then
    saved_lang="$LANG"
    [ -f "$HOME/.i18n" ] && . "$HOME/.i18n" && sourced=1
    LANG="$saved_lang"
    unset saved_lang
else
    for langfile in /etc/locale.conf "$HOME/.i18n" ; do
        [ -f $langfile ] && . $langfile && sourced=1
    done
fi

if [ "$sourced" = 1 ]; then
    [ -n "$LANG" ] && export LANG || unset LANG
    [ -n "$LC_ADDRESS" ] && export LC_ADDRESS || unset LC_ADDRESS
    [ -n "$LC_CTYPE" ] && export LC_CTYPE || unset LC_CTYPE
    [ -n "$LC_COLLATE" ] && export LC_COLLATE || unset LC_COLLATE
    [ -n "$LC_IDENTIFICATION" ] && export LC_IDENTIFICATION || unset LC_IDENTIFICATION
    [ -n "$LC_MEASUREMENT" ] && export LC_MEASUREMENT || unset LC_MEASUREMENT
    [ -n "$LC_MESSAGES" ] && export LC_MESSAGES || unset LC_MESSAGES
    [ -n "$LC_MONETARY" ] && export LC_MONETARY || unset LC_MONETARY
    [ -n "$LC_NAME" ] && export LC_NAME || unset LC_NAME
    [ -n "$LC_NUMERIC" ] && export LC_NUMERIC || unset LC_NUMERIC
    [ -n "$LC_PAPER" ] && export LC_PAPER || unset LC_PAPER
    [ -n "$LC_TELEPHONE" ] && export LC_TELEPHONE || unset LC_TELEPHONE
    [ -n "$LC_TIME" ] && export LC_TIME || unset LC_TIME
    if [ -n "$LC_ALL" ]; then
       if [ "$LC_ALL" != "$LANG" ]; then
         export LC_ALL
       else
         unset LC_ALL
       fi
    else
       unset LC_ALL
    fi
    [ -n "$LANGUAGE" ] && export LANGUAGE || unset LANGUAGE
    [ -n "$LINGUAS" ] && export LINGUAS || unset LINGUAS
    [ -n "$_XKB_CHARSET" ] && export _XKB_CHARSET || unset _XKB_CHARSET
    
    consoletype=$CONSOLETYPE
    if [ -z "$consoletype" ]; then
      consoletype=$(/sbin/consoletype stdout)
    fi

    if [ -n "$LANG" ]; then
      case $LANG in
    	*.utf8*|*.UTF-8*)
    	if [ "$TERM" = "linux" ]; then
    	    if [ "$consoletype" = "vt" ]; then
    	    	case $LANG in 
    	    		ja*) LANG=en_US.UTF-8 ;;
    	    		ko*) LANG=en_US.UTF-8 ;;
			si*) LANG=en_US.UTF-8 ;;
    	    		zh*) LANG=en_US.UTF-8 ;;
    	    		ar*) LANG=en_US.UTF-8 ;;
    	    		fa*) LANG=en_US.UTF-8 ;;
    	    		he*) LANG=en_US.UTF-8 ;;
    	    		en_IN*) ;;
    	    		*_IN*) LANG=en_US.UTF-8 ;;
    	    	esac
            fi
        fi
	;;
	*)
	if [ "$TERM" = "linux" ]; then
	    if [ "$consoletype" = "vt" ]; then
    	    	case $LANG in 
    	    		ja*) LANG=en_US ;;
    	    		ko*) LANG=en_US ;;
			si*) LANG=en_US ;;
    	    		zh*) LANG=en_US ;;
    	    		ar*) LANG=en_US ;;
    	    		fa*) LANG=en_US ;;
    	    		he*) LANG=en_US ;;
    	    		en_IN*) ;;
    	    		*_IN*) LANG=en_US ;;
    	    	esac
	    fi
	fi
	;;
      esac
    fi

    unset SYSFONTACM SYSFONT consoletype
fi
unset sourced
unset langfile
# less initialization script (sh)
[ -x /usr/bin/lesspipe.sh ] && export LESSOPEN="${LESSOPEN-||/usr/bin/lesspipe.sh %s}"
shell=`/bin/basename \`/bin/ps -p $$ -ocomm=\``
if [ -f /usr/share/Modules/init/$shell ]
then
  . /usr/share/Modules/init/$shell
else
  . /usr/share/Modules/init/sh
fi

module() { eval `/usr/bin/modulecmd zsh $*`; }

MODULESHOME=/usr/share/Modules
export MODULESHOME

if [ "${LOADEDMODULES:-}" = "" ]; then
  LOADEDMODULES=
  export LOADEDMODULES
fi

if [ "${MODULEPATH:-}" = "" ]; then
  MODULEPATH=`sed -n 's/[ 	#].*$//; /./H; $ { x; s/^\n//; s/\n/:/g; p; }' ${MODULESHOME}/init/.modulespath`
  export MODULEPATH
fi
# Copyright (C) 2008 Richard Hughes <richard@hughsie.com>
#
# Licensed under the GNU General Public License Version 2
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

command_not_found_handle () {
	local runcnf=1
	local retval=127

	# only search for the command if we're interactive
	[[ $- =~ i ]] || runcnf=0

	# don't run if DBus isn't running
	[ ! -S /var/run/dbus/system_bus_socket ] && runcnf=0

	# don't run if packagekitd doesn't exist in the _system_ root
	[ ! -x /usr/libexec/packagekitd ] && runcnf=0

	# run the command, or just print a warning
	if [ $runcnf -eq 1 ]; then
		/usr/libexec/pk-command-not-found "$@"
		retval=$?
	else
		echo "bash: $1: command not found"
	fi

	# return success or failure
	return $retval
}


if [ -z "${QT_GRAPHICSSYSTEM_CHECKED}" -a -z "${QT_GRAPHICSSYSTEM}" ] ; then
  QT_GRAPHICSSYSTEM_CHECKED=1
  export QT_GRAPHICSSYSTEM_CHECKED

  # workarond cirrus/qt bug, http://bugzilla.redhat.com/810161
  if ( /usr/sbin/lspci 2>/dev/null | grep -qi "VGA compatible controller: Cirrus Logic GD 5446" ) ; then
    QT_GRAPHICSSYSTEM=native
    export QT_GRAPHICSSYSTEM
  fi
fi

function scl()
{
local CMD=$1
if [ "$CMD" = "load" -o "$CMD" = "unload" ]; then
# It is possible that function module is not declared in time of this
# declaration so eval is used instead of direct calling of function module
    eval "module $@"
else
   /usr/bin/scl "$@"
fi
}

shell=`/bin/basename \`/bin/ps -p $$ -ocomm=\``
[ "$shell" = "bash" ] && export -f scl # export -f works only in bash

MODULESHOME=/usr/share/Modules
export MODULESHOME

if [ "${MODULEPATH:-}" = "" ]; then
   MODULEPATH=`sed -n 's/[   #].*$//; /./H; $ { x; s/^\n//; s/\n/:/g; p; }' ${MODULESHOME}/init/.modulespath`
fi

MODULEPATH=/etc/scl/modulefiles:$MODULEPATH

export MODULEPATH


if [ -n "$BASH_VERSION" -o -n "$KSH_VERSION" -o -n "$ZSH_VERSION" ]; then
  [ -x /usr/bin/id ] || return
  ID=`/usr/bin/id -u`
  [ -n "$ID" -a "$ID" -le 200 ] && return
  # for bash and zsh, only if no alias is already set
  alias vi >/dev/null 2>&1 || alias vi=vim
fi
# Copyright © 2006 Shaun McCance <shaunm@gnome.org>
# Copyright © 2013 Peter De Wachter <pdewacht@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Not bash or zsh?
[ -n "$BASH_VERSION" -o -n "$ZSH_VERSION" ] || return 0

# Not an interactive shell?
[[ $- == *i* ]] || return 0

# Not running under vte?
[ "${VTE_VERSION:-0}" -ge 3405 ] || return 0

__vte_urlencode() (
  # This is important to make sure string manipulation is handled
  # byte-by-byte.
  LC_ALL=C
  str="$1"
  while [ -n "$str" ]; do
    safe="${str%%[!a-zA-Z0-9/:_\.\-\!\'\(\)~]*}"
    printf "%s" "$safe"
    str="${str#"$safe"}"
    if [ -n "$str" ]; then
      printf "%%%02X" "'$str"
      str="${str#?}"
    fi
  done
)

# Print a warning so that anyone who's added this manually to his PS1 can adapt.
# The function will be removed in a later version.
__vte_ps1() {
  echo -n "(__vte_ps1 is obsolete)"
}

__vte_osc7 () {
  printf "\033]7;file://%s%s\007" "${HOSTNAME:-}" "$(__vte_urlencode "${PWD}")"
}

__vte_prompt_command() {
  local command=$(HISTTIMEFORMAT= history 1 | sed 's/^ *[0-9]\+ *//')
  command="${command//;/ }"
  local pwd='~'
  [ "$PWD" != "$HOME" ] && pwd=${PWD/#$HOME\//\~\/}
  printf "\033]777;notify;Command completed;%s\007\033]0;%s@%s:%s\007%s" "${command}" "${USER}" "${HOSTNAME%%.*}" "${pwd}" "$(__vte_osc7)"
}

case "$TERM" in
  xterm*|vte*)
    [ -n "$BASH_VERSION" ] && PROMPT_COMMAND="__vte_prompt_command"
    [ -n "$ZSH_VERSION"  ] && precmd_functions+=(__vte_osc7)
    ;;
esac

true
# Initialization script for bash and sh

# export AFS if you are in AFS environment
alias which='(alias; declare -f) | /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot'

unset -f pathmunge _src_etc_profile_d

# Path to your oh-my-zsh installation.
export ZSH=$__DOTFILES/etc/zsh/oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="robbyrussell"
#ZSH_THEME="amuse"
#ZSH_THEME="ys"
#ZSH_THEME="avit"
#ZSH_THEME="clean"
#ZSH_THEME="kphoen"
#ZSH_THEME="gentoo"
ZSH_THEME="gentoo-westurner"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to disable command auto-correction.
# DISABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=( \
    common-aliases \
    dirhistory \
    history-substring-search \
    wd \
    sudo \
    rsync \
    safe-paste \
    jsontools \
    github \
    vi-mode vim-interaction vundle \
    git git-extras git-prompt git-flow git-hubflow \
    mercurial \
    supervisord \
    systemd \
    gpg-agent \
    ssh-agent \
    fbterm \
    debian \
    yum \
    python pip virtualenv virtualenvwrapper pep8 pylint \
    colorize \
    ruby gem rvm bundler rake rake-fast \
    ant mvn \
    bower \
    screen \
    tmux \
    taskwarrior \
    extract \
    osx \
    compleat)

source $ZSH/oh-my-zsh.sh
# Check for updates on initial load...
if [ "$DISABLE_AUTO_UPDATE" != "true" ]; then
  /usr/bin/env ZSH=$ZSH DISABLE_UPDATE_PROMPT=$DISABLE_UPDATE_PROMPT zsh -f $ZSH/tools/check_for_upgrade.sh
fi

# Initializes Oh My Zsh

# add a function path
fpath=($ZSH/functions $ZSH/completions $fpath)

# Load all of the config files in ~/oh-my-zsh that end in .zsh
# TIP: Add files you don't want in git to .gitignore
for config_file ($ZSH/lib/*.zsh); do
  source $config_file
done
# Push and pop directories on directory stack
alias pu='pushd'
alias po='popd'

# Basic directory operations
alias ...='cd ../..'
alias -- -='cd -'

# Super user
alias _='sudo'
alias please='sudo'

#alias g='grep -in'

# Show history
if [ "$HIST_STAMPS" = "mm/dd/yyyy" ]
then
    alias history='fc -fl 1'
elif [ "$HIST_STAMPS" = "dd.mm.yyyy" ]
then
    alias history='fc -El 1'
elif [ "$HIST_STAMPS" = "yyyy-mm-dd" ]
then
    alias history='fc -il 1'
else
    alias history='fc -l 1'
fi
# List direcory contents
alias lsa='ls -lah'
alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'
alias sl=ls # often screw this up

alias afind='ack-grep -il'

## Bazaar integration
## Just works with the GIT integration just add $(bzr_prompt_info) to the PROMPT
function bzr_prompt_info() {
	BZR_CB=`bzr nick 2> /dev/null | grep -v "ERROR" | cut -d ":" -f2 | awk -F / '{print "bzr::"$1}'`
	if [ -n "$BZR_CB" ]; then
		BZR_DIRTY=""
		[[ -n `bzr status` ]] && BZR_DIRTY=" %{$fg[red]%} * %{$fg[green]%}"
		echo "$ZSH_THEME_SCM_PROMPT_PREFIX$BZR_CB$BZR_DIRTY$ZSH_THEME_GIT_PROMPT_SUFFIX"
	fi
}# fixme - the load process here seems a bit bizarre

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on succesive tab press
setopt complete_in_word
setopt always_to_end

WORDCHARS=''

zmodload -i zsh/complist

## case-insensitive (all),partial-word and then substring completion
if [ "x$CASE_SENSITIVE" = "xtrue" ]; then
  zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
  unset CASE_SENSITIVE
else
  zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
fi

zstyle ':completion:*' list-colors ''

# should this be in keybindings?
bindkey -M menuselect '^o' accept-and-infer-next-history

zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u `whoami` -o pid,user,comm -w -w"

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
cdpath=(.)

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $ZSH/cache/

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs

# ... unless we really want to.
zstyle '*' single-ignored show

if [ "x$COMPLETION_WAITING_DOTS" = "xtrue" ]; then
  expand-or-complete-with-dots() {
    echo -n "\e[31m......\e[0m"
    zle expand-or-complete
    zle redisplay
  }
  zle -N expand-or-complete-with-dots
  bindkey "^I" expand-or-complete-with-dots
fi
alias man='nocorrect man'
alias mv='nocorrect mv'
alias mysql='nocorrect mysql'
alias mkdir='nocorrect mkdir'
alias gist='nocorrect gist'
alias heroku='nocorrect heroku'
alias ebuild='nocorrect ebuild'
alias hpodder='nocorrect hpodder'
alias sudo='nocorrect sudo'

if [[ "$ENABLE_CORRECTION" == "true" ]]; then
  setopt correct_all
fi
# Changing/making/removing directory
setopt auto_name_dirs
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

alias ..='cd ..'
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'
alias cd.....='cd ../../../..'
alias cd/='cd /'

alias 1='cd -'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

cd () {
  if   [[ "x$*" == "x..." ]]; then
    cd ../..
  elif [[ "x$*" == "x...." ]]; then
    cd ../../..
  elif [[ "x$*" == "x....." ]]; then
    cd ../../../..
  elif [[ "x$*" == "x......" ]]; then
    cd ../../../../..
  elif [ -d ~/.autoenv ]; then
    source ~/.autoenv/activate.sh
    autoenv_cd "$@"
  else
    builtin cd "$@"
  fi
}

alias md='mkdir -p'
alias rd=rmdir
alias d='dirs -v | head -10'
function zsh_stats() {
  fc -l 1 | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n20
}

function uninstall_oh_my_zsh() {
  /usr/bin/env ZSH=$ZSH /bin/sh $ZSH/tools/uninstall.sh
}

function upgrade_oh_my_zsh() {
  /usr/bin/env ZSH=$ZSH /bin/sh $ZSH/tools/upgrade.sh
}

function take() {
  mkdir -p $1
  cd $1
}

#
# Get the value of an alias.
#
# Arguments:
#    1. alias - The alias to get its value from
# STDOUT:
#    The value of alias $1 (if it has one).
# Return value:
#    0 if the alias was found,
#    1 if it does not exist
#
function alias_value() {
    alias "$1" | sed "s/^$1='\(.*\)'$/\1/"
    test $(alias "$1")
}

#
# Try to get the value of an alias,
# otherwise return the input.
#
# Arguments:
#    1. alias - The alias to get its value from
# STDOUT:
#    The value of alias $1, or $1 if there is no alias $1.
# Return value:
#    Always 0
#
function try_alias_value() {
    alias_value "$1" || echo "$1"
}

#
# Set variable "$1" to default value "$2" if "$1" is not yet defined.
#
# Arguments:
#    1. name - The variable to set
#    2. val  - The default value 
# Return value:
#    0 if the variable exists, 3 if it was set
#
function default() {
    test `typeset +m "$1"` && return 0
    typeset -g "$1"="$2"   && return 3
}

#
# Set enviroment variable "$1" to default value "$2" if "$1" is not yet defined.
#
# Arguments:
#    1. name - The env variable to set
#    2. val  - The default value 
# Return value:
#    0 if the env variable exists, 3 if it was set
#
function env_default() {
    env | grep -q "^$1=" && return 0 
    export "$1=$2"       && return 3
}
# get the name of the branch we are on
function git_prompt_info() {
  if [[ "$(git config --get oh-my-zsh.hide-status)" != "1" ]]; then
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}


# Checks if working tree is dirty
parse_git_dirty() {
  local SUBMODULE_SYNTAX=''
  local GIT_STATUS=''
  local CLEAN_MESSAGE='nothing to commit (working directory clean)'
  if [[ "$(command git config --get oh-my-zsh.hide-status)" != "1" ]]; then
    if [[ $POST_1_7_2_GIT -gt 0 ]]; then
          SUBMODULE_SYNTAX="--ignore-submodules=dirty"
    fi
    if [[ "$DISABLE_UNTRACKED_FILES_DIRTY" == "true" ]]; then
        GIT_STATUS=$(command git status -s ${SUBMODULE_SYNTAX} -uno 2> /dev/null | tail -n1)
    else
        GIT_STATUS=$(command git status -s ${SUBMODULE_SYNTAX} 2> /dev/null | tail -n1)
    fi
    if [[ -n $GIT_STATUS ]]; then
      echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
    else
      echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
    fi
  else
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi
}

# get the difference between the local and remote branches
git_remote_status() {
    remote=${$(command git rev-parse --verify ${hook_com[branch]}@{upstream} --symbolic-full-name 2>/dev/null)/refs\/remotes\/}
    if [[ -n ${remote} ]] ; then
        ahead=$(command git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
        behind=$(command git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)

        if [ $ahead -eq 0 ] && [ $behind -gt 0 ]
        then
            echo "$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE"
        elif [ $ahead -gt 0 ] && [ $behind -eq 0 ]
        then
            echo "$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE"
        elif [ $ahead -gt 0 ] && [ $behind -gt 0 ]
        then
            echo "$ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE"
        fi
    fi
}

# Checks if there are commits ahead from remote
function git_prompt_ahead() {
  if $(echo "$(command git log origin/$(current_branch)..HEAD 2> /dev/null)" | grep '^commit' &> /dev/null); then
    echo "$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi
}

# Formats prompt string for current git commit short SHA
function git_prompt_short_sha() {
  SHA=$(command git rev-parse --short HEAD 2> /dev/null) && echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}

# Formats prompt string for current git commit long SHA
function git_prompt_long_sha() {
  SHA=$(command git rev-parse HEAD 2> /dev/null) && echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}

# Get the status of the working tree
git_prompt_status() {
  INDEX=$(command git status --porcelain -b 2> /dev/null)
  STATUS=""
  if $(echo "$INDEX" | grep -E '^\?\? ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNTRACKED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^A  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  elif $(echo "$INDEX" | grep '^M  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^ M ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^AM ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^ T ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^R  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_RENAMED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^ D ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  elif $(echo "$INDEX" | grep '^D  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  elif $(echo "$INDEX" | grep '^AD ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  fi
  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    STATUS="$ZSH_THEME_GIT_PROMPT_STASHED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^UU ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNMERGED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^## .*ahead' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_AHEAD$STATUS"
  fi
  if $(echo "$INDEX" | grep '^## .*behind' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_BEHIND$STATUS"
  fi
  if $(echo "$INDEX" | grep '^## .*diverged' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DIVERGED$STATUS"
  fi
  echo $STATUS
}

#compare the provided version of git to the version installed and on path
#prints 1 if input version <= installed version
#prints -1 otherwise
function git_compare_version() {
  local INPUT_GIT_VERSION=$1;
  local INSTALLED_GIT_VERSION
  INPUT_GIT_VERSION=(${(s/./)INPUT_GIT_VERSION});
  INSTALLED_GIT_VERSION=($(command git --version 2>/dev/null));
  INSTALLED_GIT_VERSION=(${(s/./)INSTALLED_GIT_VERSION[3]});

  for i in {1..3}; do
    if [[ $INSTALLED_GIT_VERSION[$i] -lt $INPUT_GIT_VERSION[$i] ]]; then
      echo -1
      return 0
    fi
  done
  echo 1
}

#this is unlikely to change so make it all statically assigned
POST_1_7_2_GIT=$(git_compare_version "1.7.2")
#clean up the namespace slightly by removing the checker function
unset -f git_compare_version


#
# Color grep results
# Examples: http://rubyurl.com/ZXv
#

GREP_OPTIONS="--color=auto"

# avoid VCS folders (if the necessary grep flags are available)
grep-flag-available() {
    echo | grep $1 "" >/dev/null 2>&1
}
if grep-flag-available --exclude-dir=.cvs; then
    for PATTERN in .cvs .git .hg .svn; do
        GREP_OPTIONS+=" --exclude-dir=$PATTERN"
    done
elif grep-flag-available --exclude=.cvs; then
    for PATTERN in .cvs .git .hg .svn; do
        GREP_OPTIONS+=" --exclude=$PATTERN"
    done
fi
unfunction grep-flag-available

export GREP_OPTIONS="$GREP_OPTIONS"
export GREP_COLOR='1;32'
## Command history configuration
if [ -z $HISTFILE ]; then
    HISTFILE=$HOME/.zsh_history
fi
HISTSIZE=10000
SAVEHIST=10000

setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups # ignore duplication command history list
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history # share command history data
# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html
# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Builtins
# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Standard-Widgets

# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }
  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

bindkey -e                                            # Use emacs key bindings

bindkey '\ew' kill-region                             # [Esc-w] - Kill from the cursor to the mark
bindkey -s '\el' 'ls\n'                               # [Esc-l] - run command: ls
bindkey '^r' history-incremental-search-backward      # [Ctrl-r] - Search backward incrementally for a specified string. The string may begin with ^ to anchor the search to the beginning of the line.
if [[ "${terminfo[kpp]}" != "" ]]; then
  bindkey "${terminfo[kpp]}" up-line-or-history       # [PageUp] - Up a line of history
fi
if [[ "${terminfo[knp]}" != "" ]]; then
  bindkey "${terminfo[knp]}" down-line-or-history     # [PageDown] - Down a line of history
fi

if [[ "${terminfo[kcuu1]}" != "" ]]; then
  bindkey "${terminfo[kcuu1]}" up-line-or-search      # start typing + [Up-Arrow] - fuzzy find history forward
fi
if [[ "${terminfo[kcud1]}" != "" ]]; then
  bindkey "${terminfo[kcud1]}" down-line-or-search    # start typing + [Down-Arrow] - fuzzy find history backward
fi

if [[ "${terminfo[khome]}" != "" ]]; then
  bindkey "${terminfo[khome]}" beginning-of-line      # [Home] - Go to beginning of line
fi
if [[ "${terminfo[kend]}" != "" ]]; then
  bindkey "${terminfo[kend]}"  end-of-line            # [End] - Go to end of line
fi

bindkey ' ' magic-space                               # [Space] - do history expansion

bindkey '^[[1;5C' forward-word                        # [Ctrl-RightArrow] - move forward one word
bindkey '^[[1;5D' backward-word                       # [Ctrl-LeftArrow] - move backward one word

if [[ "${terminfo[kcbt]}" != "" ]]; then
  bindkey "${terminfo[kcbt]}" reverse-menu-complete   # [Shift-Tab] - move through the completion menu backwards
fi

bindkey '^?' backward-delete-char                     # [Backspace] - delete backward
if [[ "${terminfo[kdch1]}" != "" ]]; then
  bindkey "${terminfo[kdch1]}" delete-char            # [Delete] - delete forward
else
  bindkey "^[[3~" delete-char
  bindkey "^[3;5~" delete-char
  bindkey "\e[3~" delete-char
fi

# Edit the current command line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# consider emacs keybindings:

#bindkey -e  ## emacs key bindings
#
#bindkey '^[[A' up-line-or-search
#bindkey '^[[B' down-line-or-search
#bindkey '^[^[[C' emacs-forward-word
#bindkey '^[^[[D' emacs-backward-word
#
#bindkey -s '^X^Z' '%-^M'
#bindkey '^[e' expand-cmd-path
#bindkey '^[^I' reverse-menu-complete
#bindkey '^X^N' accept-and-infer-next-history
#bindkey '^W' kill-region
#bindkey '^I' complete-word
## Fix weird sequence that rxvt produces
#bindkey -s '^[[Z' '\t'
#
## smart urls
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

## file rename magick
bindkey "^[m" copy-prev-shell-word

## jobs
setopt long_list_jobs

## pager
export PAGER="less"
export LESS="-R"

export LC_CTYPE=$LANG
# get the node.js version
function nvm_prompt_info() {
  [ -f $HOME/.nvm/nvm.sh ] || return
  local nvm_prompt
  nvm_prompt=$(node -v 2>/dev/null)
  [[ "${nvm_prompt}x" == "x" ]] && return
  nvm_prompt=${nvm_prompt:1}
  echo "${ZSH_THEME_NVM_PROMPT_PREFIX}${nvm_prompt}${ZSH_THEME_NVM_PROMPT_SUFFIX}"
}
# *_prompt_info functions for usage in your prompt
#
# Plugin creators, please add your *_prompt_info function to the list
# of dummy implementations to help theme creators not receiving errors
# without the need of implementing conditional clauses.
#
# See also lib/bzr.zsh, lib/git.zsh and lib/nvm.zsh for
# git_prompt_info, bzr_prompt_info and nvm_prompt_info

# Dummy implementations that return false to prevent command_not_found
# errors with themes, that implement these functions
# Real implementations will be used when the respective plugins are loaded
function chruby_prompt_info hg_prompt_info pyenv_prompt_info \
  rbenv_prompt_info svn_prompt_info vi_mode_prompt_info \
  virtualenv_prompt_info {
  return 1
}

# oh-my-zsh supports an rvm prompt by default
# get the name of the rvm ruby version
function rvm_prompt_info() {
  [ -f $HOME/.rvm/bin/rvm-prompt ] || return 1
  local rvm_prompt
  rvm_prompt=$($HOME/.rvm/bin/rvm-prompt ${=ZSH_THEME_RVM_PROMPT_OPTIONS} 2>/dev/null)
  [[ "${rvm_prompt}x" == "x" ]] && return 1
  echo "${ZSH_THEME_RVM_PROMPT_PREFIX:=(}${rvm_prompt}${ZSH_THEME_RVM_PROMPT_SUFFIX:=)}"
}

# use this to enable users to see their ruby version, no matter which
# version management system they use
function ruby_prompt_info() {
  echo $(rvm_prompt_info || rbenv_prompt_info || chruby_prompt_info)
}
#! /bin/zsh
# A script to make using 256 colors in zsh less painful.
# P.C. Shyamshankar <sykora@lucentbeing.com>
# Copied from http://github.com/sykora/etc/blob/master/zsh/functions/spectrum/

typeset -Ag FX FG BG

FX=(
    reset     "%{[00m%}"
    bold      "%{[01m%}" no-bold      "%{[22m%}"
    italic    "%{[03m%}" no-italic    "%{[23m%}"
    underline "%{[04m%}" no-underline "%{[24m%}"
    blink     "%{[05m%}" no-blink     "%{[25m%}"
    reverse   "%{[07m%}" no-reverse   "%{[27m%}"
)

for color in {000..255}; do
    FG[$color]="%{[38;5;${color}m%}"
    BG[$color]="%{[48;5;${color}m%}"
done


ZSH_SPECTRUM_TEXT=${ZSH_SPECTRUM_TEXT:-Arma virumque cano Troiae qui primus ab oris}

# Show all 256 colors with color number
function spectrum_ls() {
  for code in {000..255}; do
    print -P -- "$code: %F{$code}$ZSH_SPECTRUM_TEXT%f"
  done
}

# Show all 256 colors where the background is set to specific color
function spectrum_bls() {
  for code in {000..255}; do
    print -P -- "$BG[$code]$code: $ZSH_SPECTRUM_TEXT %{$reset_color%}"
  done
}
#usage: title short_tab_title looooooooooooooooooooooggggggg_windows_title
#http://www.faqs.org/docs/Linux-mini/Xterm-Title.html#ss3.1
#Fully support screen, iterm, and probably most modern xterm and rxvt
#Limited support for Apple Terminal (Terminal can't set window or tab separately)
function title {
  if [[ "$DISABLE_AUTO_TITLE" == "true" ]] || [[ "$EMACS" == *term* ]]; then
    return
  fi
  if [[ "$TERM" == screen* ]]; then
    print -Pn "\ek$1:q\e\\" #set screen hardstatus, usually truncated at 20 chars
  elif [[ "$TERM" == xterm* ]] || [[ $TERM == rxvt* ]] || [[ $TERM == ansi ]] || [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    print -Pn "\e]2;$2:q\a" #set window name
    print -Pn "\e]1;$1:q\a" #set icon (=tab) name (will override window name on broken terminal)
  fi
}

ZSH_THEME_TERM_TAB_TITLE_IDLE="%15<..<%~%<<" #15 char left truncated PWD
ZSH_THEME_TERM_TITLE_IDLE="%n@%m: %~"

#Appears when you have the prompt
function omz_termsupport_precmd {
  title $ZSH_THEME_TERM_TAB_TITLE_IDLE $ZSH_THEME_TERM_TITLE_IDLE
}

#Appears at the beginning of (and during) of command execution
function omz_termsupport_preexec {
  emulate -L zsh
  setopt extended_glob

  # cmd name only, or if this is sudo or ssh, the next cmd
  local CMD=${1[(wr)^(*=*|sudo|ssh|rake|-*)]:gs/%/%%}
  local LINE="${2:gs/%/%%}"

  title '$CMD' '%100>...>$LINE%<<'
}

autoload -U add-zsh-hook
add-zsh-hook precmd  omz_termsupport_precmd
add-zsh-hook preexec omz_termsupport_preexec
# ls colors
autoload colors; colors;
export LSCOLORS="Gxfxcxdxbxegedabagacad"
#export LS_COLORS

# Enable ls colors
if [ "$DISABLE_LS_COLORS" != "true" ]
then
  # Find the option for using colors in ls, depending on the version: Linux or BSD
  if [[ "$(uname -s)" == "NetBSD" ]]; then
    # On NetBSD, test if "gls" (GNU ls) is installed (this one supports colors); 
    # otherwise, leave ls as is, because NetBSD's ls doesn't support -G
    gls --color -d . &>/dev/null 2>&1 && alias ls='gls --color=tty'
  elif [[ "$(uname -s)" == "OpenBSD" ]]; then
    # On OpenBSD, test if "colorls" is installed (this one supports colors);
    # otherwise, leave ls as is, because OpenBSD's ls doesn't support -G
    colorls -G -d . &>/dev/null 2>&1 && alias ls='colorls -G'
  else
    ls --color -d . &>/dev/null 2>&1 && alias ls='ls --color=tty' || alias ls='ls -G'
  fi
fi

#setopt no_beep
setopt auto_cd
setopt multios
setopt cdablevarS

if [[ x$WINDOW != x ]]
then
    SCREEN_NO="%B$WINDOW%b "
else
    SCREEN_NO=""
fi

# Apply theming defaults
PS1="%n@%m:%~%# "

# git theming default: Variables for theming the git info prompt
ZSH_THEME_GIT_PROMPT_PREFIX="git:("         # Prefix at the very beginning of the prompt, before the branch name
ZSH_THEME_GIT_PROMPT_SUFFIX=")"             # At the very end of the prompt
ZSH_THEME_GIT_PROMPT_DIRTY="*"              # Text to display if the branch is dirty
ZSH_THEME_GIT_PROMPT_CLEAN=""               # Text to display if the branch is clean

# Setup the prompt with pretty colors
setopt prompt_subst


# Set ZSH_CUSTOM to the path where your custom config files
# and plugins exists, or else we will use the default custom/
if [[ -z "$ZSH_CUSTOM" ]]; then
    ZSH_CUSTOM="$ZSH/custom"
fi


is_plugin() {
  local base_dir=$1
  local name=$2
  test -f $base_dir/plugins/$name/$name.plugin.zsh \
    || test -f $base_dir/plugins/$name/_$name
}
# Add all defined plugins to fpath. This must be done
# before running compinit.
for plugin ($plugins); do
  if is_plugin $ZSH_CUSTOM $plugin; then
    fpath=($ZSH_CUSTOM/plugins/$plugin $fpath)
  elif is_plugin $ZSH $plugin; then
    fpath=($ZSH/plugins/$plugin $fpath)
  fi
done

# Figure out the SHORT hostname
if [ -n "$commands[scutil]" ]; then
  # OS X
  SHORT_HOST=$(scutil --get ComputerName)
else
  SHORT_HOST=${HOST/.*/}
fi

# Save the location of the current completion dump file.
ZSH_COMPDUMP="${ZDOTDIR:-${HOME}}/.zcompdump-${SHORT_HOST}-${ZSH_VERSION}"

# Load and run compinit
autoload -U compinit
compinit -i -d "${ZSH_COMPDUMP}"

# Load all of the plugins that were defined in ~/.zshrc
for plugin ($plugins); do
  if [ -f $ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh ]; then
    source $ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh
  elif [ -f $ZSH/plugins/$plugin/$plugin.plugin.zsh ]; then
    source $ZSH/plugins/$plugin/$plugin.plugin.zsh
  fi
done
# Advanced Aliases.
# Use with caution
#

# ls, the common ones I use a lot shortened for rapid fire usage
alias ls='ls --color' #I like color
alias l='ls -lFh'     #size,show type,human readable
alias la='ls -lAFh'   #long list,show almost all,show type,human readable
alias lr='ls -tRFh'   #sorted by date,recursive,show type,human readable
alias lt='ls -ltFh'   #long list,sorted by date,show type,human readable
alias ll='ls -l'      #long list
alias ldot='ls -ld .*'
alias lS='ls -1FSsh'
alias lart='ls -1Fcart'
alias lrt='ls -1Fcrt'

alias zshrc='vim ~/.zshrc' # Quick access to the ~/.zshrc file

alias grep='grep --color'
alias sgrep='grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS} '

alias t='tail -f'

# because typing 'cd' is A LOT of work!!
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'

# Command line head / tail shortcuts
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g L="| less"
alias -g M="| most"
alias -g LL="2>&1 | less"
alias -g CA="2>&1 | cat -A"
alias -g NE="2> /dev/null"
alias -g NUL="> /dev/null 2>&1"
alias -g P="2>&1| pygmentize -l pytb"

alias dud='du --max-depth=1 -h'
alias duf='du -sh *'
alias fd='find . -type d -name'
alias ff='find . -type f -name'

alias h='history'
alias hgrep="fc -El 0 | grep"
alias help='man'
alias j='jobs'
alias p='ps -f'
alias sortnr='sort -n -r'
alias unexport='unset'

alias whereami=display_info

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# zsh is able to auto-do some kungfoo
# depends on the SUFFIX :)
if [ ${ZSH_VERSION//\./} -ge 420 ]; then
  # open browser on urls
  _browser_fts=(htm html de org net com at cx nl se dk dk php)
  for ft in $_browser_fts ; do alias -s $ft=$BROWSER ; done

  _editor_fts=(cpp cxx cc c hh h inl asc txt TXT tex)
  for ft in $_editor_fts ; do alias -s $ft=$EDITOR ; done

  _image_fts=(jpg jpeg png gif mng tiff tif xpm)
  for ft in $_image_fts ; do alias -s $ft=$XIVIEWER; done

  _media_fts=(ape avi flv mkv mov mp3 mpeg mpg ogg ogm rm wav webm)
  for ft in $_media_fts ; do alias -s $ft=mplayer ; done

  #read documents
  alias -s pdf=acroread
  alias -s ps=gv
  alias -s dvi=xdvi
  alias -s chm=xchm
  alias -s djvu=djview

  #list whats inside packed file
  alias -s zip="unzip -l"
  alias -s rar="unrar l"
  alias -s tar="tar tf"
  alias -s tar.gz="echo "
  alias -s ace="unace l"
fi

# Make zsh know about hosts already accessed by SSH
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

## 
#   Navigate directory history using ALT-LEFT and ALT-RIGHT. ALT-LEFT moves back to directories 
#   that the user has changed to in the past, and ALT-RIGHT undoes ALT-LEFT.
# 

dirhistory_past=(`pwd`)
dirhistory_future=()
export dirhistory_past
export dirhistory_future

export DIRHISTORY_SIZE=30

# Pop the last element of dirhistory_past. 
# Pass the name of the variable to return the result in. 
# Returns the element if the array was not empty,
# otherwise returns empty string.
function pop_past() {
  eval "$1='$dirhistory_past[$#dirhistory_past]'"
  if [[ $#dirhistory_past -gt 0 ]]; then
    dirhistory_past[$#dirhistory_past]=()
  fi
}

function pop_future() {
  eval "$1='$dirhistory_future[$#dirhistory_future]'"
  if [[ $#dirhistory_future -gt 0 ]]; then
    dirhistory_future[$#dirhistory_future]=()
  fi
}

# Push a new element onto the end of dirhistory_past. If the size of the array 
# is >= DIRHISTORY_SIZE, the array is shifted
function push_past() {
  if [[ $#dirhistory_past -ge $DIRHISTORY_SIZE ]]; then
    shift dirhistory_past
  fi
  if [[ $#dirhistory_past -eq 0 || $dirhistory_past[$#dirhistory_past] != "$1" ]]; then
    dirhistory_past+=($1)
  fi
}

function push_future() {
  if [[ $#dirhistory_future -ge $DIRHISTORY_SIZE ]]; then
    shift dirhistory_future
  fi
  if [[ $#dirhistory_future -eq 0 || $dirhistory_futuret[$#dirhistory_future] != "$1" ]]; then
    dirhistory_future+=($1)
  fi
}

# Called by zsh when directory changes
function chpwd() {
  push_past `pwd`
  # If DIRHISTORY_CD is not set...
  if [[ -z "${DIRHISTORY_CD+x}" ]]; then
    # ... clear future.
    dirhistory_future=()
  fi
}

function dirhistory_cd(){
  DIRHISTORY_CD="1"
  cd $1
  unset DIRHISTORY_CD
}

# Move backward in directory history
function dirhistory_back() {
  local cw=""
  local d=""
  # Last element in dirhistory_past is the cwd.

  pop_past cw 
  if [[ "" == "$cw" ]]; then
    # Someone overwrote our variable. Recover it.
    dirhistory_past=(`pwd`)
    return
  fi

  pop_past d
  if [[ "" != "$d" ]]; then
    dirhistory_cd $d
    push_future $cw
  else
    push_past $cw
  fi
}


# Move forward in directory history
function dirhistory_forward() {
  local d=""

  pop_future d
  if [[ "" != "$d" ]]; then
    dirhistory_cd $d
    push_past $d
  fi
}


# Bind keys to history navigation
function dirhistory_zle_dirhistory_back() {
  # Erase current line in buffer
  zle kill-buffer
  dirhistory_back 
  zle accept-line
}

function dirhistory_zle_dirhistory_future() {
  # Erase current line in buffer
  zle kill-buffer
  dirhistory_forward
  zle accept-line
}

zle -N dirhistory_zle_dirhistory_back
# xterm in normal mode
bindkey "\e[3D" dirhistory_zle_dirhistory_back
bindkey "\e[1;3D" dirhistory_zle_dirhistory_back
# Putty:
bindkey "\e\e[D" dirhistory_zle_dirhistory_back
# GNU screen:
bindkey "\eO3D" dirhistory_zle_dirhistory_back

zle -N dirhistory_zle_dirhistory_future
bindkey "\e[3C" dirhistory_zle_dirhistory_future
bindkey "\e[1;3C" dirhistory_zle_dirhistory_future
bindkey "\e\e[C" dirhistory_zle_dirhistory_future
bindkey "\eO3C" dirhistory_zle_dirhistory_future


# This file integrates the history-substring-search script into oh-my-zsh.

source "$ZSH/plugins/history-substring-search/history-substring-search.zsh"
#!/usr/bin/env zsh
#
# This is a clean-room implementation of the Fish[1] shell's history search
# feature, where you can type in any part of any previously entered command
# and press the UP and DOWN arrow keys to cycle through the matching commands.
#
#-----------------------------------------------------------------------------
# Usage
#-----------------------------------------------------------------------------
#
# 1. Load this script into your interactive ZSH session:
#
#       % source history-substring-search.zsh
#
#    If you want to use the zsh-syntax-highlighting[6] script along with this
#    script, then make sure that you load it *before* you load this script:
#
#       % source zsh-syntax-highlighting.zsh
#       % source history-substring-search.zsh
#
# 2. Type any part of any previous command and then:
#
#     * Press the UP arrow key to select the nearest command that (1) contains
#       your query and (2) is older than the current command in the command
#       history.
#
#     * Press the DOWN arrow key to select the nearest command that (1)
#       contains your query and (2) is newer than the current command in the
#       command history.
#
#     * Press ^U (the Control and U keys simultaneously) to abort the search.
#
# 3. If a matching command spans more than one line of text, press the LEFT
#    arrow key to move the cursor away from the end of the command, and then:
#
#     * Press the UP arrow key to move the cursor to the line above.  When the
#       cursor reaches the first line of the command, pressing the UP arrow
#       key again will cause this script to perform another search.
#
#     * Press the DOWN arrow key to move the cursor to the line below.  When
#       the cursor reaches the last line of the command, pressing the DOWN
#       arrow key again will cause this script to perform another search.
#
#-----------------------------------------------------------------------------
# Configuration
#-----------------------------------------------------------------------------
#
# This script defines the following global variables. You may override their
# default values only after having loaded this script into your ZSH session.
#
# * HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND is a global variable that defines
#   how the query should be highlighted inside a matching command. Its default
#   value causes this script to highlight using bold, white text on a magenta
#   background. See the "Character Highlighting" section in the zshzle(1) man
#   page to learn about the kinds of values you may assign to this variable.
#
# * HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND is a global variable that
#   defines how the query should be highlighted when no commands in the
#   history match it. Its default value causes this script to highlight using
#   bold, white text on a red background. See the "Character Highlighting"
#   section in the zshzle(1) man page to learn about the kinds of values you
#   may assign to this variable.
#
# * HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS is a global variable that defines
#   how the command history will be searched for your query. Its default value
#   causes this script to perform a case-insensitive search. See the "Globbing
#   Flags" section in the zshexpn(1) man page to learn about the kinds of
#   values you may assign to this variable.
#
#-----------------------------------------------------------------------------
# History
#-----------------------------------------------------------------------------
#
# This script was originally written by Peter Stephenson[2], who published it
# to the ZSH users mailing list (thereby making it public domain) in September
# 2009. It was later revised by Guido van Steen and released under the BSD
# license (see below) as part of the fizsh[3] project in January 2011.
#
# It was later extracted from fizsh[3] release 1.0.1, refactored heavily, and
# repackaged as both an oh-my-zsh plugin[4] and as an independently loadable
# ZSH script[5] by Suraj N. Kurapati in 2011.
#
# It was further developed[4] by Guido van Steen, Suraj N. Kurapati, Sorin
# Ionescu, and Vincent Guerci in 2011.
#
# [1]: http://fishshell.com
# [2]: http://www.zsh.org/mla/users/2009/msg00818.html
# [3]: http://sourceforge.net/projects/fizsh/
# [4]: https://github.com/robbyrussell/oh-my-zsh/pull/215
# [5]: https://github.com/sunaku/zsh-history-substring-search
# [6]: https://github.com/nicoulaj/zsh-syntax-highlighting
#
##############################################################################
#
# Copyright (c) 2009 Peter Stephenson
# Copyright (c) 2011 Guido van Steen
# Copyright (c) 2011 Suraj N. Kurapati
# Copyright (c) 2011 Sorin Ionescu
# Copyright (c) 2011 Vincent Guerci
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  * Redistributions in binary form must reproduce the above
#    copyright notice, this list of conditions and the following
#    disclaimer in the documentation and/or other materials provided
#    with the distribution.
#
#  * Neither the name of the FIZSH nor the names of its contributors
#    may be used to endorse or promote products derived from this
#    software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
##############################################################################

#-----------------------------------------------------------------------------
# configuration variables
#-----------------------------------------------------------------------------

HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=magenta,fg=white,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'
HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS='i'

#-----------------------------------------------------------------------------
# the main ZLE widgets
#-----------------------------------------------------------------------------

function history-substring-search-up() {
  _history-substring-search-begin

  _history-substring-search-up-history ||
  _history-substring-search-up-buffer ||
  _history-substring-search-up-search

  _history-substring-search-end
}

function history-substring-search-down() {
  _history-substring-search-begin

  _history-substring-search-down-history ||
  _history-substring-search-down-buffer ||
  _history-substring-search-down-search

  _history-substring-search-end
}

zle -N history-substring-search-up
zle -N history-substring-search-down

zmodload zsh/terminfo
if [[ -n "$terminfo[kcuu1]" ]]; then
  bindkey "$terminfo[kcuu1]" history-substring-search-up
fi
if [[ -n "$terminfo[kcud1]" ]]; then
  bindkey "$terminfo[kcud1]" history-substring-search-down
fi

#-----------------------------------------------------------------------------
# implementation details
#-----------------------------------------------------------------------------

setopt extendedglob
zmodload -F zsh/parameter

#
# We have to "override" some keys and widgets if the
# zsh-syntax-highlighting plugin has not been loaded:
#
# https://github.com/nicoulaj/zsh-syntax-highlighting
#
if [[ $+functions[_zsh_highlight] -eq 0 ]]; then
  #
  # Dummy implementation of _zsh_highlight()
  # that simply removes existing highlights
  #
  function _zsh_highlight() {
    region_highlight=()
  }

  #
  # Remove existing highlights when the user
  # inserts printable characters into $BUFFER
  #
  function ordinary-key-press() {
    if [[ $KEYS == [[:print:]] ]]; then
      region_highlight=()
    fi
    zle .self-insert
  }
  zle -N self-insert ordinary-key-press

  #
  # Override ZLE widgets to invoke _zsh_highlight()
  #
  # https://github.com/nicoulaj/zsh-syntax-highlighting/blob/
  # bb7fcb79fad797a40077bebaf6f4e4a93c9d8163/zsh-syntax-highlighting.zsh#L121
  #
  #--------------8<-------------------8<-------------------8<-----------------
  #
  # Copyright (c) 2010-2011 zsh-syntax-highlighting contributors
  # All rights reserved.
  #
  # Redistribution and use in source and binary forms, with or without
  # modification, are permitted provided that the following conditions are
  # met:
  #
  #  * Redistributions of source code must retain the above copyright
  #    notice, this list of conditions and the following disclaimer.
  #
  #  * Redistributions in binary form must reproduce the above copyright
  #    notice, this list of conditions and the following disclaimer in the
  #    documentation and/or other materials provided with the distribution.
  #
  #  * Neither the name of the zsh-syntax-highlighting contributors nor the
  #    names of its contributors may be used to endorse or promote products
  #    derived from this software without specific prior written permission.
  #
  # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
  # IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  # THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  # PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
  # CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  # EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  # PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  # PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  # LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  # NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  # SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

  # Load ZSH module zsh/zleparameter, needed to override user defined widgets.
  zmodload zsh/zleparameter 2>/dev/null || {
    echo 'zsh-syntax-highlighting: failed loading zsh/zleparameter, exiting.' >&2
    return -1
  }

  # Override ZLE widgets to make them invoke _zsh_highlight.
  for event in ${${(f)"$(zle -la)"}:#(_*|orig-*|.run-help|.which-command)}; do
    if [[ "$widgets[$event]" == completion:* ]]; then
      eval "zle -C orig-$event ${${${widgets[$event]}#*:}/:/ } ; $event() { builtin zle orig-$event && _zsh_highlight } ; zle -N $event"
    else
      case $event in
        accept-and-menu-complete)
          eval "$event() { builtin zle .$event && _zsh_highlight } ; zle -N $event"
          ;;

        # The following widgets should NOT remove any previously
        # applied highlighting. Therefore we do not remap them.
        .forward-char|.backward-char|.up-line-or-history|.down-line-or-history)
          ;;

        .*)
          clean_event=$event[2,${#event}] # Remove the leading dot in the event name
          case ${widgets[$clean_event]-} in
            (completion|user):*)
              ;;
            *)
              eval "$clean_event() { builtin zle $event && _zsh_highlight } ; zle -N $clean_event"
              ;;
          esac
          ;;
        *)
          ;;
      esac
    fi
  done
  unset event clean_event
  #-------------->8------------------->8------------------->8-----------------
fi

function _history-substring-search-begin() {
  _history_substring_search_move_cursor_eol=false
  _history_substring_search_query_highlight=

  #
  # Continue using the previous $_history_substring_search_result by default,
  # unless the current query was cleared or a new/different query was entered.
  #
  if [[ -z $BUFFER || $BUFFER != $_history_substring_search_result ]]; then
    #
    # For the purpose of highlighting we will also keep
    # a version without doubly-escaped meta characters.
    #
    _history_substring_search_query=$BUFFER

    #
    # $BUFFER contains the text that is in the command-line currently.
    # we put an extra "\\" before meta characters such as "\(" and "\)",
    # so that they become "\\\(" and "\\\)".
    #
    _history_substring_search_query_escaped=${BUFFER//(#m)[\][()|\\*?#<>~^]/\\$MATCH}

    #
    # Find all occurrences of the search query in the history file.
    #
    # (k) turns it an array of line numbers.
    #
    # (on) seems to remove duplicates, which are default
    #      options. They can be turned off by (ON).
    #
    _history_substring_search_matches=(${(kon)history[(R)(#$HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS)*${_history_substring_search_query_escaped}*]})

    #
    # Define the range of values that $_history_substring_search_match_index
    # can take: [0, $_history_substring_search_matches_count_plus].
    #
    _history_substring_search_matches_count=$#_history_substring_search_matches
    _history_substring_search_matches_count_plus=$(( _history_substring_search_matches_count + 1 ))
    _history_substring_search_matches_count_sans=$(( _history_substring_search_matches_count - 1 ))

    #
    # If $_history_substring_search_match_index is equal to
    # $_history_substring_search_matches_count_plus, this indicates that we
    # are beyond the beginning of $_history_substring_search_matches.
    #
    # If $_history_substring_search_match_index is equal to 0, this indicates
    # that we are beyond the end of $_history_substring_search_matches.
    #
    # If we have initially pressed "up" we have to initialize
    # $_history_substring_search_match_index to
    # $_history_substring_search_matches_count_plus so that it will be
    # decreased to $_history_substring_search_matches_count.
    #
    # If we have initially pressed "down" we have to initialize
    # $_history_substring_search_match_index to
    # $_history_substring_search_matches_count so that it will be increased to
    # $_history_substring_search_matches_count_plus.
    #
    if [[ $WIDGET == history-substring-search-down ]]; then
       _history_substring_search_match_index=$_history_substring_search_matches_count
    else
      _history_substring_search_match_index=$_history_substring_search_matches_count_plus
    fi
  fi
}

function _history-substring-search-end() {
  _history_substring_search_result=$BUFFER

  # move the cursor to the end of the command line
  if [[ $_history_substring_search_move_cursor_eol == true ]]; then
    CURSOR=${#BUFFER}
  fi

  # highlight command line using zsh-syntax-highlighting
  _zsh_highlight

  # highlight the search query inside the command line
  if [[ -n $_history_substring_search_query_highlight && -n $_history_substring_search_query ]]; then
    #
    # The following expression yields a variable $MBEGIN, which
    # indicates the begin position + 1 of the first occurrence
    # of _history_substring_search_query_escaped in $BUFFER.
    #
    : ${(S)BUFFER##(#m$HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS)($_history_substring_search_query##)}
    local begin=$(( MBEGIN - 1 ))
    local end=$(( begin + $#_history_substring_search_query ))
    region_highlight+=("$begin $end $_history_substring_search_query_highlight")
  fi

  # For debugging purposes:
  # zle -R "mn: "$_history_substring_search_match_index" m#: "${#_history_substring_search_matches}
  # read -k -t 200 && zle -U $REPLY

  # Exit successfully from the history-substring-search-* widgets.
  true
}

function _history-substring-search-up-buffer() {
  #
  # Check if the UP arrow was pressed to move the cursor within a multi-line
  # buffer. This amounts to three tests:
  #
  # 1. $#buflines -gt 1.
  #
  # 2. $CURSOR -ne $#BUFFER.
  #
  # 3. Check if we are on the first line of the current multi-line buffer.
  #    If so, pressing UP would amount to leaving the multi-line buffer.
  #
  #    We check this by adding an extra "x" to $LBUFFER, which makes
  #    sure that xlbuflines is always equal to the number of lines
  #    until $CURSOR (including the line with the cursor on it).
  #
  local buflines XLBUFFER xlbuflines
  buflines=(${(f)BUFFER})
  XLBUFFER=$LBUFFER"x"
  xlbuflines=(${(f)XLBUFFER})

  if [[ $#buflines -gt 1 && $CURSOR -ne $#BUFFER && $#xlbuflines -ne 1 ]]; then
    zle up-line-or-history
    return true
  fi

  false
}

function _history-substring-search-down-buffer() {
  #
  # Check if the DOWN arrow was pressed to move the cursor within a multi-line
  # buffer. This amounts to three tests:
  #
  # 1. $#buflines -gt 1.
  #
  # 2. $CURSOR -ne $#BUFFER.
  #
  # 3. Check if we are on the last line of the current multi-line buffer.
  #    If so, pressing DOWN would amount to leaving the multi-line buffer.
  #
  #    We check this by adding an extra "x" to $RBUFFER, which makes
  #    sure that xrbuflines is always equal to the number of lines
  #    from $CURSOR (including the line with the cursor on it).
  #
  local buflines XRBUFFER xrbuflines
  buflines=(${(f)BUFFER})
  XRBUFFER="x"$RBUFFER
  xrbuflines=(${(f)XRBUFFER})

  if [[ $#buflines -gt 1 && $CURSOR -ne $#BUFFER && $#xrbuflines -ne 1 ]]; then
    zle down-line-or-history
    return true
  fi

  false
}

function _history-substring-search-up-history() {
  #
  # Behave like up in ZSH, except clear the $BUFFER
  # when beginning of history is reached like in Fish.
  #
  if [[ -z $_history_substring_search_query ]]; then

    # we have reached the absolute top of history
    if [[ $HISTNO -eq 1 ]]; then
      BUFFER=

    # going up from somewhere below the top of history
    else
      zle up-history
    fi

    return true
  fi

  false
}

function _history-substring-search-down-history() {
  #
  # Behave like down-history in ZSH, except clear the
  # $BUFFER when end of history is reached like in Fish.
  #
  if [[ -z $_history_substring_search_query ]]; then

    # going down from the absolute top of history
    if [[ $HISTNO -eq 1 && -z $BUFFER ]]; then
      BUFFER=${history[1]}
      _history_substring_search_move_cursor_eol=true

    # going down from somewhere above the bottom of history
    else
      zle down-history
    fi

    return true
  fi

  false
}

function _history-substring-search-up-search() {
  _history_substring_search_move_cursor_eol=true

  #
  # Highlight matches during history-substring-up-search:
  #
  # The following constants have been initialized in
  # _history-substring-search-up/down-search():
  #
  # $_history_substring_search_matches is the current list of matches
  # $_history_substring_search_matches_count is the current number of matches
  # $_history_substring_search_matches_count_plus is the current number of matches + 1
  # $_history_substring_search_matches_count_sans is the current number of matches - 1
  # $_history_substring_search_match_index is the index of the current match
  #
  # The range of values that $_history_substring_search_match_index can take
  # is: [0, $_history_substring_search_matches_count_plus].  A value of 0
  # indicates that we are beyond the end of
  # $_history_substring_search_matches. A value of
  # $_history_substring_search_matches_count_plus indicates that we are beyond
  # the beginning of $_history_substring_search_matches.
  #
  # In _history-substring-search-up-search() the initial value of
  # $_history_substring_search_match_index is
  # $_history_substring_search_matches_count_plus.  This value is set in
  # _history-substring-search-begin().  _history-substring-search-up-search()
  # will initially decrease it to $_history_substring_search_matches_count.
  #
  if [[ $_history_substring_search_match_index -ge 2 ]]; then
    #
    # Highlight the next match:
    #
    # 1. Decrease the value of $_history_substring_search_match_index.
    #
    # 2. Use $HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND
    #    to highlight the current buffer.
    #
    (( _history_substring_search_match_index-- ))
    BUFFER=$history[$_history_substring_search_matches[$_history_substring_search_match_index]]
    _history_substring_search_query_highlight=$HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND

  elif [[ $_history_substring_search_match_index -eq 1 ]]; then
    #
    # We will move beyond the end of $_history_substring_search_matches:
    #
    # 1. Decrease the value of $_history_substring_search_match_index.
    #
    # 2. Save the current buffer in $_history_substring_search_old_buffer,
    #    so that it can be retrieved by
    #    _history-substring-search-down-search() later.
    #
    # 3. Make $BUFFER equal to $_history_substring_search_query.
    #
    # 4. Use $HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND
    #    to highlight the current buffer.
    #
    (( _history_substring_search_match_index-- ))
    _history_substring_search_old_buffer=$BUFFER
    BUFFER=$_history_substring_search_query
    _history_substring_search_query_highlight=$HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND

  elif [[ $_history_substring_search_match_index -eq $_history_substring_search_matches_count_plus ]]; then
    #
    # We were beyond the beginning of $_history_substring_search_matches but
    # UP makes us move back to $_history_substring_search_matches:
    #
    # 1. Decrease the value of $_history_substring_search_match_index.
    #
    # 2. Restore $BUFFER from $_history_substring_search_old_buffer.
    #
    # 3. Use $HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND
    #    to highlight the current buffer.
    #
    (( _history_substring_search_match_index-- ))
    BUFFER=$_history_substring_search_old_buffer
    _history_substring_search_query_highlight=$HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND
  fi
}

function _history-substring-search-down-search() {
  _history_substring_search_move_cursor_eol=true

  #
  # Highlight matches during history-substring-up-search:
  #
  # The following constants have been initialized in
  # _history-substring-search-up/down-search():
  #
  # $_history_substring_search_matches is the current list of matches
  # $_history_substring_search_matches_count is the current number of matches
  # $_history_substring_search_matches_count_plus is the current number of matches + 1
  # $_history_substring_search_matches_count_sans is the current number of matches - 1
  # $_history_substring_search_match_index is the index of the current match
  #
  # The range of values that $_history_substring_search_match_index can take
  # is: [0, $_history_substring_search_matches_count_plus].  A value of 0
  # indicates that we are beyond the end of
  # $_history_substring_search_matches. A value of
  # $_history_substring_search_matches_count_plus indicates that we are beyond
  # the beginning of $_history_substring_search_matches.
  #
  # In _history-substring-search-down-search() the initial value of
  # $_history_substring_search_match_index is
  # $_history_substring_search_matches_count.  This value is set in
  # _history-substring-search-begin().
  # _history-substring-search-down-search() will initially increase it to
  # $_history_substring_search_matches_count_plus.
  #
  if [[ $_history_substring_search_match_index -le $_history_substring_search_matches_count_sans ]]; then
    #
    # Highlight the next match:
    #
    # 1. Increase $_history_substring_search_match_index by 1.
    #
    # 2. Use $HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND
    #    to highlight the current buffer.
    #
    (( _history_substring_search_match_index++ ))
    BUFFER=$history[$_history_substring_search_matches[$_history_substring_search_match_index]]
    _history_substring_search_query_highlight=$HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND

  elif [[ $_history_substring_search_match_index -eq $_history_substring_search_matches_count ]]; then
    #
    # We will move beyond the beginning of $_history_substring_search_matches:
    #
    # 1. Increase $_history_substring_search_match_index by 1.
    #
    # 2. Save the current buffer in $_history_substring_search_old_buffer, so
    #    that it can be retrieved by _history-substring-search-up-search()
    #    later.
    #
    # 3. Make $BUFFER equal to $_history_substring_search_query.
    #
    # 4. Use $HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND
    #    to highlight the current buffer.
    #
    (( _history_substring_search_match_index++ ))
    _history_substring_search_old_buffer=$BUFFER
    BUFFER=$_history_substring_search_query
    _history_substring_search_query_highlight=$HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND

  elif [[ $_history_substring_search_match_index -eq 0 ]]; then
    #
    # We were beyond the end of $_history_substring_search_matches but DOWN
    # makes us move back to the $_history_substring_search_matches:
    #
    # 1. Increase $_history_substring_search_match_index by 1.
    #
    # 2. Restore $BUFFER from $_history_substring_search_old_buffer.
    #
    # 3. Use $HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND
    #    to highlight the current buffer.
    #
    (( _history_substring_search_match_index++ ))
    BUFFER=$_history_substring_search_old_buffer
    _history_substring_search_query_highlight=$HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND
  fi
}

# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et

if test "$CASE_SENSITIVE" = true; then
  unset HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS
fi

if test "$DISABLE_COLOR" = true; then
  unset HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND
  unset HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND
fi
#!/bin/zsh

# WARP
# ====
# oh-my-zsh plugin
#
# @github.com/mfaerevaag/wd

wd() {
    . $ZSH/plugins/wd/wd.sh
}
# ------------------------------------------------------------------------------
# Description
# -----------
#
# sudo will be inserted before the command
#
# ------------------------------------------------------------------------------
# Authors
# -------
#
# * Dongweiming <ciici123@gmail.com>
#
# ------------------------------------------------------------------------------

sudo-command-line() {
[[ -z $BUFFER ]] && zle up-history
[[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
zle end-of-line 
}
zle -N sudo-command-line
# Defined shortcut keys: [Esc] [Esc]
bindkey "\e\e" sudo-command-line
alias rsync-copy="rsync -av --progress -h"
alias rsync-move="rsync -av --progress -h --remove-source-files"
alias rsync-update="rsync -avu --progress -h"
alias rsync-synchronize="rsync -avu --delete --progress -h"
# Code from Mikael Magnusson: http://www.zsh.org/mla/users/2011/msg00367.html
#
# Requires xterm, urxvt, iTerm2 or any other terminal that supports bracketed
# paste mode as documented: http://www.xfree86.org/current/ctlseqs.html

# create a new keymap to use while pasting
bindkey -N paste
# make everything in this keymap call our custom widget
bindkey -R -M paste "^@"-"\M-^?" paste-insert
# these are the codes sent around the pasted text in bracketed
# paste mode.
# do the first one with both -M viins and -M vicmd in vi mode
bindkey '^[[200~' _start_paste
bindkey -M paste '^[[201~' _end_paste
# insert newlines rather than carriage returns when pasting newlines
bindkey -M paste -s '^M' '^J'

zle -N _start_paste
zle -N _end_paste
zle -N zle-line-init _zle_line_init
zle -N zle-line-finish _zle_line_finish
zle -N paste-insert _paste_insert

# switch the active keymap to paste mode
function _start_paste() {
  bindkey -A paste main
}

# go back to our normal keymap, and insert all the pasted text in the
# command line. this has the nice effect of making the whole paste be
# a single undo/redo event.
function _end_paste() {
#use bindkey -v here with vi mode probably. maybe you want to track
#if you were in ins or cmd mode and restore the right one.
  bindkey -e
  LBUFFER+=$_paste_content
  unset _paste_content
}

function _paste_insert() {
  _paste_content+=$KEYS
}

function _zle_line_init() {
  # Tell terminal to send escape codes around pastes.
  [[ $TERM == rxvt-unicode || $TERM == xterm || $TERM = xterm-256color || $TERM = screen || $TERM = screen-256color ]] && printf '\e[?2004h'
}

function _zle_line_finish() {
  # Tell it to stop when we leave zle, so pasting in other programs
  # doesn't get the ^[[200~ codes around the pasted text.
  [[ $TERM == rxvt-unicode || $TERM == xterm || $TERM = xterm-256color || $TERM = screen || $TERM = screen-256color ]] && printf '\e[?2004l'
}

# JSON Tools
# Adds command line aliases useful for dealing with JSON

if [[ $(whence $JSONTOOLS_METHOD) = "" ]]; then
	JSONTOOLS_METHOD=""
fi

if [[ $(whence node) != "" && ( "x$JSONTOOLS_METHOD" = "x"  || "x$JSONTOOLS_METHOD" = "xnode" ) ]]; then
	alias pp_json='xargs -0 node -e "console.log(JSON.stringify(JSON.parse(process.argv[1]), null, 4));"'
	alias is_json='xargs -0 node -e "try {json = JSON.parse(process.argv[1]);} catch (e) { console.log(false); json = null; } if(json) { console.log(true); }"'
	alias urlencode_json='xargs -0 node -e "console.log(encodeURIComponent(process.argv[1]))"'
	alias urldecode_json='xargs -0 node -e "console.log(decodeURIComponent(process.argv[1]))"'
elif [[ $(whence python) != "" && ( "x$JSONTOOLS_METHOD" = "x" || "x$JSONTOOLS_METHOD" = "xpython" ) ]]; then
	alias pp_json='python -mjson.tool'
	alias is_json='python -c "
import json, sys;
try: 
	json.loads(sys.stdin.read())
except ValueError, e: 
	print False
else:
	print True
sys.exit(0)"'
	alias urlencode_json='python -c "
import urllib, json, sys;
print urllib.quote_plus(sys.stdin.read())
sys.exit(0)"'
	alias urldecode_json='python -c "
import urllib, json, sys;
print urllib.unquote_plus(sys.stdin.read())
sys.exit(0)"'
elif [[ $(whence ruby) != "" && ( "x$JSONTOOLS_METHOD" = "x" || "x$JSONTOOLS_METHOD" = "xruby" ) ]]; then
	alias pp_json='ruby -e "require \"json\"; require \"yaml\"; puts JSON.parse(STDIN.read).to_yaml"'
	alias is_json='ruby -e "require \"json\"; begin; JSON.parse(STDIN.read); puts true; rescue Exception => e; puts false; end"'
	alias urlencode_json='ruby -e "require \"uri\"; puts URI.escape(STDIN.read)"'
	alias urldecode_json='ruby -e "require \"uri\"; puts URI.unescape(STDIN.read)"'
fi

unset JSONTOOLS_METHOD# Setup hub function for git, if it is available; http://github.com/defunkt/hub
if [ "$commands[(I)hub]" ] && [ "$commands[(I)ruby]" ]; then
    # Autoload _git completion functions
    if declare -f _git > /dev/null; then
      _git
    fi
    
    if declare -f _git_commands > /dev/null; then
        _hub_commands=(
            'alias:show shell instructions for wrapping git'
            'pull-request:open a pull request on GitHub'
            'fork:fork origin repo on GitHub'
            'create:create new repo on GitHub for the current project'
            'browse:browse the project on GitHub'
            'compare:open GitHub compare view'
        )
        # Extend the '_git_commands' function with hub commands
        eval "$(declare -f _git_commands | sed -e 's/base_commands=(/base_commands=(${_hub_commands} /')"
    fi
    # eval `hub alias -s zsh`
    function git(){
        if ! (( $+_has_working_hub  )); then
            hub --version &> /dev/null
            _has_working_hub=$(($? == 0))
        fi
        if (( $_has_working_hub )) ; then
            hub "$@"
        else
            command git "$@"
        fi
    }
fi

# Functions #################################################################

# https://github.com/dbb 


# empty_gh [NAME_OF_REPO]
#
# Use this when creating a new repo from scratch.
empty_gh() { # [NAME_OF_REPO]
    repo = $1
    ghuser=$(  git config github.user )

    mkdir "$repo"
    cd "$repo"
    git init
    touch README
    git add README
    git commit -m 'Initial commit.'
    git remote add origin git@github.com:${ghuser}/${repo}.git
    git push -u origin master
}

# new_gh [DIRECTORY]
#
# Use this when you have a directory that is not yet set up for git.
# This function will add all non-hidden files to git.
new_gh() { # [DIRECTORY]
    cd "$1"
    ghuser=$( git config github.user )

    git init
    # add all non-dot files
    print '.*'"\n"'*~' >> .gitignore
    git add ^.*
    git commit -m 'Initial commit.'
    git remote add origin git@github.com:${ghuser}/${repo}.git
    git push -u origin master
}

# exist_gh [DIRECTORY]
#
# Use this when you have a git repo that's ready to go and you want to add it
# to your GitHub.
exist_gh() { # [DIRECTORY]
    cd "$1"
    name=$( git config user.name )
    ghuser=$( git config github.user )
    repo=$1

    git remote add origin git@github.com:${ghuser}/${repo}.git
    git push -u origin master
}

# git.io "GitHub URL"
#
# Shorten GitHub url, example:
#   https://github.com/nvogel/dotzsh    >   http://git.io/8nU25w  
# source: https://github.com/nvogel/dotzsh
# documentation: https://github.com/blog/985-git-io-github-url-shortener
#
git.io() {curl -i -s http://git.io -F "url=$1" | grep "Location" | cut -f 2 -d " "}

# End Functions #############################################################

# Ensures that $terminfo values are valid and updates editor information when
# the keymap changes.
function zle-keymap-select zle-line-init zle-line-finish {
  # The terminal must be in application mode when ZLE is active for $terminfo
  # values to be valid.
  if (( ${+terminfo[smkx]} )); then
    printf '%s' ${terminfo[smkx]}
  fi
  if (( ${+terminfo[rmkx]} )); then
    printf '%s' ${terminfo[rmkx]}
  fi

  zle reset-prompt
  zle -R
}

zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select
zle -N edit-command-line


bindkey -v

# allow v to edit the command line (standard behaviour)
autoload -Uz edit-command-line
bindkey -M vicmd 'v' edit-command-line

# if mode indicator wasn't setup by theme, define default
if [[ "$MODE_INDICATOR" == "" ]]; then
  MODE_INDICATOR="%{$fg_bold[red]%}<%{$fg[red]%}<<%{$reset_color%}"
fi

function vi_mode_prompt_info() {
  echo "${${KEYMAP/vicmd/$MODE_INDICATOR}/(main|viins)/}"
}

# define right prompt, if it wasn't defined by a theme
if [[ "$RPS1" == "" && "$RPROMPT" == "" ]]; then
  RPS1='$(vi_mode_prompt_info)'
fi
#
# See README.md
#
# Derek Wyatt (derek@{myfirstnamemylastname}.org
# 

function resolveFile
{
  if [ -f "$1" ]; then
    echo $(readlink -f "$1")
  elif [[ "${1#/}" == "$1" ]]; then
    echo "$(pwd)/$1"
  else
    echo $1
  fi
}

function callvim
{
  if [[ $# == 0 ]]; then
    cat <<EOH
usage: callvim [-b cmd] [-a cmd] [file ... fileN]

  -b cmd     Run this command in GVIM before editing the first file
  -a cmd     Run this command in GVIM after editing the first file
  file       The file to edit
  ... fileN  The other files to add to the argslist
EOH
    return 0
  fi

  local cmd=""
  local before="<esc>"
  local after=""
  while getopts ":b:a:" option
  do
    case $option in
      a) after="$OPTARG"
         ;;
      b) before="$OPTARG"
         ;;
    esac
  done
  shift $((OPTIND-1))
  if [[ ${after#:} != $after && ${after%<cr>} == $after ]]; then
    after="$after<cr>"
  fi
  if [[ ${before#:} != $before && ${before%<cr>} == $before ]]; then
    before="$before<cr>"
  fi
  local files=""
  for f in $@
  do
    files="$files $(resolveFile $f)"
  done
  if [[ -n $files ]]; then
    files=':args! '"$files<cr>"
  fi
  cmd="$before$files$after"
  gvim --remote-send "$cmd"
  if typeset -f postCallVim > /dev/null; then
    postCallVim
  fi
}

alias v=callvim
alias vvsp="callvim -b':vsp'"
alias vhsp="callvim -b':sp'"
alias vk="callvim -b':wincmd k'"
alias vj="callvim -b':wincmd j'"
alias vl="callvim -b':wincmd l'"
alias vh="callvim -b':wincmd h'"
function vundle-init () {
  if [ ! -d ~/.vim/bundle/vundle/ ]
  then
    mkdir -p ~/.vim/bundle/vundle/
  fi

  if [ ! -d ~/.vim/bundle/vundle/.git/ ]
  then
    git clone http://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
    echo "\n\tRead about vim configuration for vundle at https://github.com/gmarik/vundle\n"
  fi
}

function vundle () {
  vundle-init
  vim -c "execute \"BundleInstall\" | q | q"
}

function vundle-update () {
  vundle-init
  vim -c "execute \"BundleInstall!\" | q | q"
}

function vundle-clean () {
  vundle-init
  vim -c "execute \"BundleClean!\" | q | q"
}
# Aliases
alias g='git'
compdef g=git
alias gst='git status'
compdef _git gst=git-status
alias gd='git diff'
compdef _git gd=git-diff
alias gdc='git diff --cached'
compdef _git gdc=git-diff
alias gl='git pull'
compdef _git gl=git-pull
alias gup='git pull --rebase'
compdef _git gup=git-fetch
alias gp='git push'
compdef _git gp=git-push
alias gd='git diff'
gdv() { git diff -w "$@" | view - }
compdef _git gdv=git-diff
alias gc='git commit -v'
compdef _git gc=git-commit
alias gc!='git commit -v --amend'
compdef _git gc!=git-commit
alias gca='git commit -v -a'
compdef _git gc=git-commit
alias gca!='git commit -v -a --amend'
compdef _git gca!=git-commit
alias gcmsg='git commit -m'
compdef _git gcmsg=git-commit
alias gco='git checkout'
compdef _git gco=git-checkout
alias gcm='git checkout master'
alias gr='git remote'
compdef _git gr=git-remote
alias grv='git remote -v'
compdef _git grv=git-remote
alias grmv='git remote rename'
compdef _git grmv=git-remote
alias grrm='git remote remove'
compdef _git grrm=git-remote
alias grset='git remote set-url'
compdef _git grset=git-remote
alias grup='git remote update'
compdef _git grset=git-remote
alias grbi='git rebase -i'
compdef _git grbi=git-rebase
alias grbc='git rebase --continue'
compdef _git grbc=git-rebase
alias grba='git rebase --abort'
compdef _git grba=git-rebase
alias gb='git branch'
compdef _git gb=git-branch
alias gba='git branch -a'
compdef _git gba=git-branch
alias gcount='git shortlog -sn'
compdef gcount=git
alias gcl='git config --list'
alias gcp='git cherry-pick'
compdef _git gcp=git-cherry-pick
alias glg='git log --stat --max-count=10'
compdef _git glg=git-log
alias glgg='git log --graph --max-count=10'
compdef _git glgg=git-log
alias glgga='git log --graph --decorate --all'
compdef _git glgga=git-log
alias glo='git log --oneline --decorate --color'
compdef _git glo=git-log
alias glog='git log --oneline --decorate --color --graph'
compdef _git glog=git-log
alias gss='git status -s'
compdef _git gss=git-status
alias ga='git add'
compdef _git ga=git-add
alias gm='git merge'
compdef _git gm=git-merge
alias grh='git reset HEAD'
alias grhh='git reset HEAD --hard'
alias gclean='git reset --hard && git clean -dfx'
alias gwc='git whatchanged -p --abbrev-commit --pretty=medium'

#remove the gf alias
#alias gf='git ls-files | grep'

alias gpoat='git push origin --all && git push origin --tags'
alias gmt='git mergetool --no-prompt'
compdef _git gm=git-mergetool

alias gg='git gui citool'
alias gga='git gui citool --amend'
alias gk='gitk --all --branches'

alias gsts='git stash show --text'
alias gsta='git stash'
alias gstp='git stash pop'
alias gstd='git stash drop'

# Will cd into the top of the current repository
# or submodule.
alias grt='cd $(git rev-parse --show-toplevel || echo ".")'

# Git and svn mix
alias git-svn-dcommit-push='git svn dcommit && git push github master:svntrunk'
compdef git-svn-dcommit-push=git

alias gsr='git svn rebase'
alias gsd='git svn dcommit'
#
# Will return the current branch name
# Usage example: git pull origin $(current_branch)
#
function current_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo ${ref#refs/heads/}
}

function current_repository() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo $(git remote -v | cut -d':' -f 2)
}

# these aliases take advantage of the previous function
alias ggpull='git pull origin $(current_branch)'
compdef ggpull=git
alias ggpur='git pull --rebase origin $(current_branch)'
compdef ggpur=git
alias ggpush='git push origin $(current_branch)'
compdef ggpush=git
alias ggpnp='git pull origin $(current_branch) && git push origin $(current_branch)'
compdef ggpnp=git

# Pretty log messages
function _git_log_prettily(){
  if ! [ -z $1 ]; then
    git log --pretty=$1
  fi
}
alias glp="_git_log_prettily"
compdef _git glp=git-log

# Work In Progress (wip)
# These features allow to pause a branch development and switch to another one (wip)
# When you want to go back to work, just unwip it
#
# This function return a warning if the current branch is a wip
function work_in_progress() {
  if $(git log -n 1 2>/dev/null | grep -q -c "\-\-wip\-\-"); then
    echo "WIP!!"
  fi
}
# these alias commit and uncomit wip branches
alias gwip='git add -A; git ls-files --deleted -z | xargs -r0 git rm; git commit -m "--wip--"'
alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'

# these alias ignore changes to file
alias gignore='git update-index --assume-unchanged'
alias gunignore='git update-index --no-assume-unchanged'
# list temporarily ignored files
alias gignored='git ls-files -v | grep "^[[:lower:]]"'



#compdef git
# ------------------------------------------------------------------------------
# Description
# -----------
#
#  Completion script for git-extras (http://github.com/visionmedia/git-extras).
#
# ------------------------------------------------------------------------------
# Authors
# -------
#
#  * Alexis GRIMALDI (https://github.com/agrimaldi)
#
# ------------------------------------------------------------------------------
# Inspirations
# -----------
#
#  * git-extras (http://github.com/visionmedia/git-extras)
#  * git-flow-completion (http://github.com/bobthecow/git-flow-completion)
#
# ------------------------------------------------------------------------------


__git_command_successful () {
    if (( ${#pipestatus:#0} > 0 )); then
        _message 'not a git repository'
        return 1
    fi
    return 0
}


__git_tag_names() {
    local expl
    declare -a tag_names
    tag_names=(${${(f)"$(_call_program branchrefs git for-each-ref --format='"%(refname)"' refs/tags 2>/dev/null)"}#refs/tags/})
    __git_command_successful || return
    _wanted tag-names expl tag-name compadd $* - $tag_names
}


__git_branch_names() {
    local expl
    declare -a branch_names
    branch_names=(${${(f)"$(_call_program branchrefs git for-each-ref --format='"%(refname)"' refs/heads 2>/dev/null)"}#refs/heads/})
    __git_command_successful || return
    _wanted branch-names expl branch-name compadd $* - $branch_names
}


__git_feature_branch_names() {
    local expl
    declare -a branch_names
    branch_names=(${${(f)"$(_call_program branchrefs git for-each-ref --format='"%(refname)"' refs/heads/feature 2>/dev/null)"}#refs/heads/feature/})
    __git_command_successful || return
    _wanted branch-names expl branch-name compadd $* - $branch_names
}


__git_refactor_branch_names() {
    local expl
    declare -a branch_names
    branch_names=(${${(f)"$(_call_program branchrefs git for-each-ref --format='"%(refname)"' refs/heads/refactor 2>/dev/null)"}#refs/heads/refactor/})
    __git_command_successful || return
    _wanted branch-names expl branch-name compadd $* - $branch_names
}


__git_bug_branch_names() {
    local expl
    declare -a branch_names
    branch_names=(${${(f)"$(_call_program branchrefs git for-each-ref --format='"%(refname)"' refs/heads/bug 2>/dev/null)"}#refs/heads/bug/})
    __git_command_successful || return
    _wanted branch-names expl branch-name compadd $* - $branch_names
}


__git_submodule_names() {
    local expl
    declare -a submodule_names
    submodule_names=(${(f)"$(_call_program branchrefs git submodule status | awk '{print $2}')"})
    __git_command_successful || return
    _wanted submodule-names expl submodule-name compadd $* - $submodule_names
}


__git_author_names() {
    local expl
    declare -a author_names
    author_names=(${(f)"$(_call_program branchrefs git log --format='%aN' | sort -u)"})
    __git_command_successful || return
    _wanted author-names expl author-name compadd $* - $author_names
}


_git-changelog() {
    _arguments \
        '(-l --list)'{-l,--list}'[list commits]' \
}


_git-effort() {
    _arguments \
        '--above[ignore file with less than x commits]' \
}


_git-contrib() {
    _arguments \
        ':author:__git_author_names'
}


_git-count() {
    _arguments \
        '--all[detailed commit count]'
}


_git-delete-branch() {
    _arguments \
        ':branch-name:__git_branch_names'
}


_git-delete-submodule() {
    _arguments \
        ':submodule-name:__git_submodule_names'
}


_git-delete-tag() {
    _arguments \
        ':tag-name:__git_tag_names'
}


_git-extras() {
    local curcontext=$curcontext state line ret=1
    declare -A opt_args

    _arguments -C \
        ': :->command' \
        '*:: :->option-or-argument' && ret=0

    case $state in
        (command)
            declare -a commands
            commands=(
                'update:update git-extras'
            )
            _describe -t commands command commands && ret=0
            ;;
    esac

    _arguments \
        '(-v --version)'{-v,--version}'[show current version]' \
}


_git-graft() {
    _arguments \
        ':src-branch-name:__git_branch_names' \
        ':dest-branch-name:__git_branch_names'
}


_git-squash() {
    _arguments \
        ':branch-name:__git_branch_names'
}


_git-feature() {
    local curcontext=$curcontext state line ret=1
    declare -A opt_args

    _arguments -C \
        ': :->command' \
        '*:: :->option-or-argument' && ret=0

    case $state in
        (command)
            declare -a commands
            commands=(
                'finish:merge feature into the current branch'
            )
            _describe -t commands command commands && ret=0
            ;;
        (option-or-argument)
            curcontext=${curcontext%:*}-$line[1]:
            case $line[1] in
                (finish)
                    _arguments -C \
                        ':branch-name:__git_feature_branch_names'
                    ;;
            esac
    esac
}


_git-refactor() {
    local curcontext=$curcontext state line ret=1
    declare -A opt_args

    _arguments -C \
        ': :->command' \
        '*:: :->option-or-argument' && ret=0

    case $state in
        (command)
            declare -a commands
            commands=(
                'finish:merge refactor into the current branch'
            )
            _describe -t commands command commands && ret=0
            ;;
        (option-or-argument)
            curcontext=${curcontext%:*}-$line[1]:
            case $line[1] in
                (finish)
                    _arguments -C \
                        ':branch-name:__git_refactor_branch_names'
                    ;;
            esac
    esac
}


_git-bug() {
    local curcontext=$curcontext state line ret=1
    declare -A opt_args

    _arguments -C \
        ': :->command' \
        '*:: :->option-or-argument' && ret=0

    case $state in
        (command)
            declare -a commands
            commands=(
                'finish:merge bug into the current branch'
            )
            _describe -t commands command commands && ret=0
            ;;
        (option-or-argument)
            curcontext=${curcontext%:*}-$line[1]:
            case $line[1] in
                (finish)
                    _arguments -C \
                        ':branch-name:__git_bug_branch_names'
                    ;;
            esac
    esac
}


zstyle ':completion:*:*:git:*' user-commands \
    changelog:'populate changelog file with commits since the previous tag' \
    contrib:'display author contributions' \
    count:'count commits' \
    delete-branch:'delete local and remote branch' \
    delete-submodule:'delete submodule' \
    delete-tag:'delete local and remote tag' \
    extras:'git-extras' \
    graft:'merge commits from source branch to destination branch' \
    squash:'merge commits from source branch into the current one as a single commit' \
    feature:'create a feature branch' \
    refactor:'create a refactor branch' \
    bug:'create a bug branch' \
    summary:'repository summary' \
    effort:'display effort statistics' \
    repl:'read-eval-print-loop' \
    commits-since:'list commits since a given date' \
    release:'release commit with the given tag' \
    alias:'define, search and show aliases' \
    ignore:'add patterns to .gitignore' \
    info:'show info about the repository' \
    create-branch:'create local and remote branch' \
    fresh-branch:'create empty local branch' \
    undo:'remove the latest commit' \
    setup:'setup a git repository' \
    touch:'one step creation of new files' \
    obliterate:'Completely remove a file from the repository, including past commits and tags' \
    local-commits:'list unpushed commits on the local branch' \
# ZSH Git Prompt Plugin from:
# http://github.com/olivierverdier/zsh-git-prompt
#
export __GIT_PROMPT_DIR=$ZSH/plugins/git-prompt
# Initialize colors.
autoload -U colors
colors

# Allow for functions in the prompt.
setopt PROMPT_SUBST

## Enable auto-execution of functions.
typeset -ga preexec_functions
typeset -ga precmd_functions
typeset -ga chpwd_functions

# Append git functions needed for prompt.
preexec_functions+='preexec_update_git_vars'
precmd_functions+='precmd_update_git_vars'
chpwd_functions+='chpwd_update_git_vars'

## Function definitions
function preexec_update_git_vars() {
    case "$2" in
        git*)
        __EXECUTED_GIT_COMMAND=1
        ;;
    esac
}

function precmd_update_git_vars() {
    if [ -n "$__EXECUTED_GIT_COMMAND" ]; then
        update_current_git_vars
        unset __EXECUTED_GIT_COMMAND
    fi
}

function chpwd_update_git_vars() {
    update_current_git_vars
}

function update_current_git_vars() {
    unset __CURRENT_GIT_STATUS

    local gitstatus="$__GIT_PROMPT_DIR/gitstatus.py"
    _GIT_STATUS=`python ${gitstatus}`
    __CURRENT_GIT_STATUS=("${(f)_GIT_STATUS}")
}

function prompt_git_info() {
    if [ -n "$__CURRENT_GIT_STATUS" ]; then
        echo "(%{${fg[red]}%}$__CURRENT_GIT_STATUS[1]%{${fg[default]}%}$__CURRENT_GIT_STATUS[2]%{${fg[magenta]}%}$__CURRENT_GIT_STATUS[3]%{${fg[default]}%})"
    fi
}

# Set the prompt.
#PROMPT='%B%m%~%b$(prompt_git_info) %# '
# for a right prompt:
#RPROMPT='%b$(prompt_git_info)'
RPROMPT='$(prompt_git_info)'
#!zsh
#
# Installation
# ------------
#
# To achieve git-flow completion nirvana:
#
#  0. Update your zsh's git-completion module to the newest verion.
#     From here. http://zsh.git.sourceforge.net/git/gitweb.cgi?p=zsh/zsh;a=blob_plain;f=Completion/Unix/Command/_git;hb=HEAD
#
#  1. Install this file. Either:
#
#     a. Place it in your .zshrc:
#
#     b. Or, copy it somewhere (e.g. ~/.git-flow-completion.zsh) and put the following line in
#        your .zshrc:
#
#            source ~/.git-flow-completion.zsh
#
#     c. Or, use this file as a oh-my-zsh plugin.
#

#Alias
alias gf='git flow'
alias gcd='git checkout develop'
alias gch='git checkout hotfix'
alias gcr='git checkout release'

_git-flow ()
{
	local curcontext="$curcontext" state line
	typeset -A opt_args

	_arguments -C \
		':command:->command' \
		'*::options:->options'

	case $state in
		(command)

			local -a subcommands
			subcommands=(
				'init:Initialize a new git repo with support for the branching model.'
				'feature:Manage your feature branches.'
				'release:Manage your release branches.'
				'hotfix:Manage your hotfix branches.'
				'support:Manage your support branches.'
				'version:Shows version information.'
			)
			_describe -t commands 'git flow' subcommands
		;;

		(options)
			case $line[1] in

				(init)
					_arguments \
						-f'[Force setting of gitflow branches, even if already configured]'
					;;

					(version)
					;;

					(hotfix)
						__git-flow-hotfix
					;;

					(release)
						__git-flow-release
					;;

					(feature)
						__git-flow-feature
					;;
			esac
		;;
	esac
}

__git-flow-release ()
{
	local curcontext="$curcontext" state line
	typeset -A opt_args

	_arguments -C \
		':command:->command' \
		'*::options:->options'

	case $state in
		(command)

			local -a subcommands
			subcommands=(
				'start:Start a new release branch.'
				'finish:Finish a release branch.'
				'list:List all your release branches. (Alias to `git flow release`)'
				'publish: public'
				'track: track'
			)
			_describe -t commands 'git flow release' subcommands
			_arguments \
				-v'[Verbose (more) output]'
		;;

		(options)
			case $line[1] in

				(start)
					_arguments \
						-F'[Fetch from origin before performing finish]'\
						':version:__git_flow_version_list'
				;;

				(finish)
					_arguments \
						-F'[Fetch from origin before performing finish]' \
						-s'[Sign the release tag cryptographically]'\
						-u'[Use the given GPG-key for the digital signature (implies -s)]'\
						-m'[Use the given tag message]'\
						-p'[Push to $ORIGIN after performing finish]'\
						-k'[Keep branch after performing finish]'\
						-n"[Don't tag this release]"\
						':version:__git_flow_version_list'
				;;

				(publish)
					_arguments \
						':version:__git_flow_version_list'\
				;;

				(track)
					_arguments \
						':version:__git_flow_version_list'\
				;;

				*)
					_arguments \
						-v'[Verbose (more) output]'
				;;
			esac
		;;
	esac
}

__git-flow-hotfix ()
{
	local curcontext="$curcontext" state line
	typeset -A opt_args

	_arguments -C \
		':command:->command' \
		'*::options:->options'

	case $state in
		(command)

			local -a subcommands
			subcommands=(
				'start:Start a new hotfix branch.'
				'finish:Finish a hotfix branch.'
				'list:List all your hotfix branches. (Alias to `git flow hotfix`)'
			)
			_describe -t commands 'git flow hotfix' subcommands
			_arguments \
				-v'[Verbose (more) output]'
		;;

		(options)
			case $line[1] in

				(start)
					_arguments \
						-F'[Fetch from origin before performing finish]'\
						':hotfix:__git_flow_version_list'\
						':branch-name:__git_branch_names'
				;;

				(finish)
					_arguments \
						-F'[Fetch from origin before performing finish]' \
						-s'[Sign the release tag cryptographically]'\
						-u'[Use the given GPG-key for the digital signature (implies -s)]'\
						-m'[Use the given tag message]'\
						-p'[Push to $ORIGIN after performing finish]'\
						-k'[Keep branch after performing finish]'\
						-n"[Don't tag this release]"\
						':hotfix:__git_flow_hotfix_list'
				;;

				*)
					_arguments \
						-v'[Verbose (more) output]'
				;;
			esac
		;;
	esac
}

__git-flow-feature ()
{
	local curcontext="$curcontext" state line
	typeset -A opt_args

	_arguments -C \
		':command:->command' \
		'*::options:->options'

	case $state in
		(command)

			local -a subcommands
			subcommands=(
				'start:Start a new feature branch.'
				'finish:Finish a feature branch.'
				'list:List all your feature branches. (Alias to `git flow feature`)'
				'publish: publish'
				'track: track'
				'diff: diff'
				'rebase: rebase'
				'checkout: checkout'
				'pull: pull'
			)
			_describe -t commands 'git flow feature' subcommands
			_arguments \
				-v'[Verbose (more) output]'
		;;

		(options)
			case $line[1] in

				(start)
					_arguments \
						-F'[Fetch from origin before performing finish]'\
						':feature:__git_flow_feature_list'\
						':branch-name:__git_branch_names'
				;;

				(finish)
					_arguments \
						-F'[Fetch from origin before performing finish]' \
						-r'[Rebase instead of merge]'\
						-k'[Keep branch after performing finish]'\
						':feature:__git_flow_feature_list'
				;;

				(publish)
					_arguments \
						':feature:__git_flow_feature_list'\
				;;

				(track)
					_arguments \
						':feature:__git_flow_feature_list'\
				;;

				(diff)
					_arguments \
						':branch:__git_flow_feature_list'\
				;;

				(rebase)
					_arguments \
						-i'[Do an interactive rebase]' \
						':branch:__git_flow_feature_list'
				;;

				(checkout)
					_arguments \
						':branch:__git_flow_feature_list'\
				;;

				(pull)
					_arguments \
						':remote:__git_remotes'\
						':branch:__git_flow_feature_list'
				;;

				*)
					_arguments \
						-v'[Verbose (more) output]'
				;;
			esac
		;;
	esac
}

__git_flow_version_list ()
{
	local expl
	declare -a versions

	versions=(${${(f)"$(_call_program versions git flow release list 2> /dev/null | tr -d ' |*')"}})
	__git_command_successful || return

	_wanted versions expl 'version' compadd $versions
}

__git_flow_feature_list ()
{
	local expl
	declare -a features

	features=(${${(f)"$(_call_program features git flow feature list 2> /dev/null | tr -d ' |*')"}})
	__git_command_successful || return

	_wanted features expl 'feature' compadd $features
}

__git_remotes () {
	local expl gitdir remotes

	gitdir=$(_call_program gitdir git rev-parse --git-dir 2>/dev/null)
	__git_command_successful || return

	remotes=(${${(f)"$(_call_program remotes git config --get-regexp '"^remote\..*\.url$"')"}//#(#b)remote.(*).url */$match[1]})
	__git_command_successful || return

	# TODO: Should combine the two instead of either or.
	if (( $#remotes > 0 )); then
		_wanted remotes expl remote compadd $* - $remotes
	else
		_wanted remotes expl remote _files $* - -W "($gitdir/remotes)" -g "$gitdir/remotes/*"
	fi
}

__git_flow_hotfix_list ()
{
	local expl
	declare -a hotfixes

	hotfixes=(${${(f)"$(_call_program hotfixes git flow hotfix list 2> /dev/null | tr -d ' |*')"}})
	__git_command_successful || return

	_wanted hotfixes expl 'hotfix' compadd $hotfixes
}

__git_branch_names () {
	local expl
	declare -a branch_names

	branch_names=(${${(f)"$(_call_program branchrefs git for-each-ref --format='"%(refname)"' refs/heads 2>/dev/null)"}#refs/heads/})
	__git_command_successful || return

	_wanted branch-names expl branch-name compadd $* - $branch_names
}

__git_command_successful () {
	if (( ${#pipestatus:#0} > 0 )); then
		_message 'not a git repository'
		return 1
	fi
	return 0
}

zstyle ':completion:*:*:git:*' user-commands flow:'description for foo'
#!zsh
#
# Installation
# ------------
#
# To achieve git-hubflow completion nirvana:
#
#  0. Update your zsh's git-completion module to the newest verion.
#     From here. http://zsh.git.sourceforge.net/git/gitweb.cgi?p=zsh/zsh;a=blob_plain;f=Completion/Unix/Command/_git;hb=HEAD
#
#  1. Install this file. Either:
#
#     a. Place it in your .zshrc:
#
#     b. Or, copy it somewhere (e.g. ~/.git-hubflow-completion.zsh) and put the following line in
#        your .zshrc:
#
#            source ~/.git-hubflow-completion.zsh
#
#     c. Or, use this file as a oh-my-zsh plugin.
#

_git-hf ()
{
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        ':command:->command' \
        '*::options:->options'

    case $state in
        (command)

            local -a subcommands
            subcommands=(
                'init:Initialize a new git repo with support for the branching model.'
                'feature:Manage your feature branches.'
                'release:Manage your release branches.'
                'hotfix:Manage your hotfix branches.'
                'support:Manage your support branches.'
                'update:Pull upstream changes down into your master and develop branches.'
                'version:Shows version information.'
            )
            _describe -t commands 'git hf' subcommands
        ;;

        (options)
            case $line[1] in

                (init)
                    _arguments \
                        -f'[Force setting of gitflow branches, even if already configured]'
                ;;

                (version)
                ;;

                (hotfix)
                    __git-hf-hotfix
                ;;

                (release)
                    __git-hf-release
                ;;

                (feature)
                    __git-hf-feature
                ;;
            esac
        ;;
    esac
}

__git-hf-release ()
{
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        ':command:->command' \
        '*::options:->options'

    case $state in
        (command)

            local -a subcommands
            subcommands=(
                'start:Start a new release branch.'
                'finish:Finish a release branch.'
                'list:List all your release branches. (Alias to `git hf release`)'
                'cancel:Cancel release'
                'push:Push release to github'
                'pull:Pull release from github'
                'track:Track release'
            )
            _describe -t commands 'git hf release' subcommands
            _arguments \
                -v'[Verbose (more) output]'
        ;;

        (options)
            case $line[1] in

                (start)
                    _arguments \
                        -F'[Fetch from origin before performing finish]'\
                        ':version:__git_hf_version_list'
                ;;

                (finish)
                    _arguments \
                        -F'[Fetch from origin before performing finish]' \
                        -s'[Sign the release tag cryptographically]'\
                        -u'[Use the given GPG-key for the digital signature (implies -s)]'\
                        -m'[Use the given tag message]'\
                        -p'[Push to $ORIGIN after performing finish]'\
                        -k'[Keep branch after performing finish]'\
                        -n"[Don't tag this release]"\
                        ':version:__git_hf_version_list'
                ;;

                *)
                    _arguments \
                        -v'[Verbose (more) output]'
                ;;
            esac
        ;;
    esac
}

__git-hf-hotfix ()
{
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        ':command:->command' \
        '*::options:->options'

    case $state in
        (command)

            local -a subcommands
            subcommands=(
                'start:Start a new hotfix branch.'
                'finish:Finish a hotfix branch.'
                'list:List all your hotfix branches. (Alias to `git hf hotfix`)'
                'publish:Publish the hotfix branch.'
                'track:Track the hotfix branch.'
                'pull:Pull the hotfix from github.'
                'push:Push the hotfix to github.'
                'cancel:Cancel the hotfix.'
            )
            _describe -t commands 'git hf hotfix' subcommands
            _arguments \
                -v'[Verbose (more) output]'
        ;;

        (options)
            case $line[1] in

                (start)
                    _arguments \
                        -F'[Fetch from origin before performing finish]'\
                        ':hotfix:__git_hf_version_list'\
                        ':branch-name:__git_branch_names'
                ;;

                (finish)
                    _arguments \
                        -F'[Fetch from origin before performing finish]' \
                        -s'[Sign the release tag cryptographically]'\
                        -u'[Use the given GPG-key for the digital signature (implies -s)]'\
                        -m'[Use the given tag message]'\
                        -p'[Push to $ORIGIN after performing finish]'\
                        -k'[Keep branch after performing finish]'\
                        -n"[Don't tag this release]"\
                        ':hotfix:__git_hf_hotfix_list'
                ;;

                *)
                    _arguments \
                        -v'[Verbose (more) output]'
                ;;
            esac
        ;;
    esac
}

__git-hf-feature ()
{
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        ':command:->command' \
        '*::options:->options'

    case $state in
        (command)

            local -a subcommands
            subcommands=(
                'list:List all your feature branches. (Alias to `git hf feature`)'
                'start:Start a new feature branch'
                'finish:Finish a feature branch'
                'submit:submit'
                'track:track'
                'diff:Diff'
                'rebase:Rebase feature branch against develop'
                'checkout:Checkout feature'
                'pull:Pull feature branch from github'
                'push:Push feature branch to github'
                'cancel:Cancel feature'
            )
            _describe -t commands 'git hf feature' subcommands
            _arguments \
                -v'[Verbose (more) output]'
        ;;

        (options)
            case $line[1] in

                (start)
                    _arguments \
                        -F'[Fetch from origin before performing finish]'\
                        ':feature:__git_hf_feature_list'\
                        ':branch-name:__git_branch_names'
                ;;

                (finish)
                    _arguments \
                        -F'[Fetch from origin before performing finish]' \
                        -r'[Rebase instead of merge]'\
                        ':feature:__git_hf_feature_list'
                ;;

                (publish)
                    _arguments \
                        ':feature:__git_hf_feature_list'\
                ;;

                (track)
                    _arguments \
                        ':feature:__git_hf_feature_list'\
                ;;

                (diff)
                    _arguments \
                        ':branch:__git_branch_names'\
                ;;

                (rebase)
                    _arguments \
                        -i'[Do an interactive rebase]' \
                        ':branch:__git_branch_names'
                ;;

                (checkout)
                    _arguments \
                        ':branch:__git_hf_feature_list'\
                ;;

                (pull)
                    _arguments \
                        ':remote:__git_remotes'\
                        ':branch:__git_branch_names'
                ;;

                *)
                    _arguments \
                        -v'[Verbose (more) output]'
                ;;
            esac
        ;;
    esac
}

__git_hf_version_list ()
{
    local expl
    declare -a versions

    versions=(${${(f)"$(_call_program versions git hf release list 2> /dev/null | tr -d ' |*')"}})
    __git_command_successful || return

    _wanted versions expl 'version' compadd $versions
}

__git_hf_feature_list ()
{
    local expl
    declare -a features

    features=(${${(f)"$(_call_program features git hf feature list 2> /dev/null | tr -d ' |*')"}})
    __git_command_successful || return

    _wanted features expl 'feature' compadd $features
}

__git_remotes () {
    local expl gitdir remotes

    gitdir=$(_call_program gitdir git rev-parse --git-dir 2>/dev/null)
    __git_command_successful || return

    remotes=(${${(f)"$(_call_program remotes git config --get-regexp '"^remote\..*\.url$"')"}//#(#b)remote.(*).url */$match[1]})
    __git_command_successful || return

    # TODO: Should combine the two instead of either or.
    if (( $#remotes > 0 )); then
        _wanted remotes expl remote compadd $* - $remotes
    else
        _wanted remotes expl remote _files $* - -W "($gitdir/remotes)" -g "$gitdir/remotes/*"
    fi
}

__git_hf_hotfix_list ()
{
    local expl
    declare -a hotfixes

    hotfixes=(${${(f)"$(_call_program hotfixes git hf hotfix list 2> /dev/null | tr -d ' |*')"}})
    __git_command_successful || return

    _wanted hotfixes expl 'hotfix' compadd $hotfixes
}

__git_branch_names () {
    local expl
    declare -a branch_names

    branch_names=(${${(f)"$(_call_program branchrefs git for-each-ref --format='"%(refname)"' refs/heads 2>/dev/null)"}#refs/heads/})
    __git_command_successful || return

    _wanted branch-names expl branch-name compadd $* - $branch_names
}

__git_command_successful () {
    if (( ${#pipestatus:#0} > 0 )); then
        _message 'not a git repository'
        return 1
    fi
    return 0
}

zstyle ':completion:*:*:git:*' user-commands flow:'description for foo'
# Mercurial
alias hgc='hg commit'
alias hgb='hg branch'
alias hgba='hg branches'
alias hgbk='hg bookmarks'
alias hgco='hg checkout'
alias hgd='hg diff'
alias hged='hg diffmerge'
# pull and update
alias hgi='hg incoming'
alias hgl='hg pull -u'
alias hglr='hg pull --rebase'
alias hgo='hg outgoing'
alias hgp='hg push'
alias hgs='hg status'
alias hgsl='hg log --limit 20 --template "{node|short} | {date|isodatesec} | {author|user}: {desc|strip|firstline}\n" '
# this is the 'git commit --amend' equivalent
alias hgca='hg qimport -r tip ; hg qrefresh -e ; hg qfinish tip'

function in_hg() {
  if [[ -d .hg ]] || $(hg summary > /dev/null 2>&1); then
    echo 1
  fi
}

function hg_get_branch_name() {
  if [ $(in_hg) ]; then
    echo $(hg branch)
  fi
}

function hg_prompt_info {
  if [ $(in_hg) ]; then
    _DISPLAY=$(hg_get_branch_name)
    echo "$ZSH_PROMPT_BASE_COLOR$ZSH_THEME_HG_PROMPT_PREFIX\
$ZSH_THEME_REPO_NAME_COLOR$_DISPLAY$ZSH_PROMPT_BASE_COLOR$ZSH_THEME_HG_PROMPT_SUFFIX$ZSH_PROMPT_BASE_COLOR$(hg_dirty)$ZSH_PROMPT_BASE_COLOR"
    unset _DISPLAY
  fi
}

function hg_dirty_choose {
  if [ $(in_hg) ]; then
    hg status 2> /dev/null | grep -Eq '^\s*[ACDIM!?L]'
    if [ $pipestatus[-1] -eq 0 ]; then
      # Grep exits with 0 when "One or more lines were selected", return "dirty".
      echo $1
    else
      # Otherwise, no lines were found, or an error occurred. Return clean.
      echo $2
    fi
  fi
}

function hg_dirty {
  hg_dirty_choose $ZSH_THEME_HG_PROMPT_DIRTY $ZSH_THEME_HG_PROMPT_CLEAN
}

function hgic() {
    hg incoming "$@" | grep "changeset" | wc -l
}

function hgoc() {
    hg outgoing "$@" | grep "changeset" | wc -l
}
user_commands=(
  list-units is-active status show help list-unit-files
  is-enabled list-jobs show-environment)

sudo_commands=(
  start stop reload restart try-restart isolate kill
  reset-failed enable disable reenable preset mask unmask
  link load cancel set-environment unset-environment)

for c in $user_commands; do; alias sc-$c="systemctl $c"; done
for c in $sudo_commands; do; alias sc-$c="sudo systemctl $c"; done
local GPG_ENV=$HOME/.gnupg/gpg-agent.env

function start_agent_nossh {
    eval $(/usr/bin/env gpg-agent --quiet --daemon --write-env-file ${GPG_ENV} 2> /dev/null)
    chmod 600 ${GPG_ENV}
    export GPG_AGENT_INFO
}

function start_agent_withssh {
    eval $(/usr/bin/env gpg-agent --quiet --daemon --enable-ssh-support --write-env-file ${GPG_ENV} 2> /dev/null)
    chmod 600 ${GPG_ENV}
    export GPG_AGENT_INFO
    export SSH_AUTH_SOCK
    export SSH_AGENT_PID
}

# check if another agent is running
if ! gpg-connect-agent --quiet /bye > /dev/null 2> /dev/null; then
    # source settings of old agent, if applicable
    if [ -f "${GPG_ENV}" ]; then
        . ${GPG_ENV} > /dev/null
        export GPG_AGENT_INFO
        export SSH_AUTH_SOCK
        export SSH_AGENT_PID
    fi

    # check again if another agent is running using the newly sourced settings
    if ! gpg-connect-agent --quiet /bye > /dev/null 2> /dev/null; then
        # check for existing ssh-agent
        if ssh-add -l > /dev/null 2> /dev/null; then
            # ssh-agent running, start gpg-agent without ssh support
            start_agent_nossh;
        else
            # otherwise start gpg-agent with ssh support
            start_agent_withssh;
        fi
    fi
fi

GPG_TTY=$(tty)
export GPG_TTY
#
# INSTRUCTIONS
#
#   To enabled agent forwarding support add the following to
#   your .zshrc file:
#
#     zstyle :omz:plugins:ssh-agent agent-forwarding on
#
#   To load multiple identities use the identities style, For
#   example:
#
#     zstyle :omz:plugins:ssh-agent identities id_rsa id_rsa2 id_github
#
#   To set the maximum lifetime of the identities, use the
#   lifetime style. The lifetime may be specified in seconds
#   or as described in sshd_config(5) (see TIME FORMATS)
#   If left unspecified, the default lifetime is forever.
#
#     zstyle :omz:plugins:ssh-agent lifetime 4h
#
# CREDITS
#
#   Based on code from Joseph M. Reagle
#   http://www.cygwin.com/ml/cygwin/2001-06/msg00537.html
#
#   Agent forwarding support based on ideas from
#   Florent Thoumie and Jonas Pfenniger
#

local _plugin__ssh_env
local _plugin__forwarding

function _plugin__start_agent()
{
  local -a identities
  local lifetime
  zstyle -s :omz:plugins:ssh-agent lifetime lifetime

  # start ssh-agent and setup environment
  /usr/bin/env ssh-agent ${lifetime:+-t} ${lifetime} | sed 's/^echo/#echo/' > ${_plugin__ssh_env}
  chmod 600 ${_plugin__ssh_env}
  . ${_plugin__ssh_env} > /dev/null

  # load identies
  zstyle -a :omz:plugins:ssh-agent identities identities
  echo starting ssh-agent...

  /usr/bin/ssh-add $HOME/.ssh/${^identities}
}

# Get the filename to store/lookup the environment from
if (( $+commands[scutil] )); then
  # It's OS X!
  _plugin__ssh_env="$HOME/.ssh/environment-$(scutil --get ComputerName)"
else
  _plugin__ssh_env="$HOME/.ssh/environment-$HOST"
fi

# test if agent-forwarding is enabled
zstyle -b :omz:plugins:ssh-agent agent-forwarding _plugin__forwarding
if [[ ${_plugin__forwarding} == "yes" && -n "$SSH_AUTH_SOCK" ]]; then
  # Add a nifty symlink for screen/tmux if agent forwarding
  [[ -L $SSH_AUTH_SOCK ]] || ln -sf "$SSH_AUTH_SOCK" /tmp/ssh-agent-$USER-screen

elif [ -f "${_plugin__ssh_env}" ]; then
  # Source SSH settings, if applicable
  . ${_plugin__ssh_env} > /dev/null
  ps x | grep ${SSH_AGENT_PID} | grep ssh-agent > /dev/null || {
    _plugin__start_agent;
  }
else
  _plugin__start_agent;
fi
SSH_AUTH_SOCK=/tmp/ssh-kfbrYrKNllRB/agent.27670; export SSH_AUTH_SOCK;
SSH_AGENT_PID=27672; export SSH_AGENT_PID;
#echo Agent pid 27672;
starting ssh-agent...

# tidy up after ourselves
unfunction _plugin__start_agent
unset _plugin__forwarding
unset _plugin__ssh_env

# start fbterm automatically in /dev/tty*

if [[ $(tty|grep -o '/dev/tty') = /dev/tty ]] ; then
	fbterm
	exit
fi
grep: warning: GREP_OPTIONS is deprecated; please use an alias or script
# Authors:
# https://github.com/AlexBio
# https://github.com/dbb
# https://github.com/Mappleconfusers
#
# Debian-related zsh aliases and functions for zsh

# Use aptitude if installed, or apt-get if not.
# You can just set apt_pref='apt-get' to override it.
if [[ -e $( which -p aptitude 2>&1 ) ]]; then
    apt_pref='aptitude'
else
    apt_pref='apt-get'
fi

# Use sudo by default if it's installed
if [[ -e $( which -p sudo 2>&1 ) ]]; then
    use_sudo=1
fi

# Aliases ###################################################################
# These are for more obscure uses of apt-get and aptitude that aren't covered
# below.
alias age='apt-get'
alias api='aptitude'

# Some self-explanatory aliases
alias acs="apt-cache search"
alias aps='aptitude search'
alias as="aptitude -F \"* %p -> %d \n(%v/%V)\" \
		--no-gui --disable-columns search"	# search package

# apt-file
alias afs='apt-file search --regexp'


# These are apt-get only
alias asrc='apt-get source'
alias app='apt-cache policy'

# superuser operations ######################################################
if [[ $use_sudo -eq 1 ]]; then
# commands using sudo #######
    alias aac='sudo $apt_pref autoclean'
    alias abd='sudo $apt_pref build-dep'
    alias ac='sudo $apt_pref clean'
    alias ad='sudo $apt_pref update'
    alias adg='sudo $apt_pref update && sudo $apt_pref upgrade'
    alias adu='sudo $apt_pref update && sudo $apt_pref dist-upgrade'
    alias afu='sudo apt-file update'
    alias ag='sudo $apt_pref upgrade'
    alias ai='sudo $apt_pref install'
    # Install all packages given on the command line while using only the first word of each line:
    # acs ... | ail
    alias ail="sed -e 's/  */ /g' -e 's/ *//' | cut -s -d ' ' -f 1 | "' xargs sudo $apt_pref install'
    alias ap='sudo $apt_pref purge'
    alias ar='sudo $apt_pref remove'

    # apt-get only
    alias ads='sudo apt-get dselect-upgrade'

    # Install all .deb files in the current directory.
    # Warning: you will need to put the glob in single quotes if you use:
    # glob_subst
    alias dia='sudo dpkg -i ./*.deb'
    alias di='sudo dpkg -i'

    # Remove ALL kernel images and headers EXCEPT the one in use
    alias kclean='sudo aptitude remove -P ?and(~i~nlinux-(ima|hea) \
        ?not(~n`uname -r`))'


# commands using su #########
else
    alias aac='su -ls \'$apt_pref autoclean\' root'
    abd() {
        cmd="su -lc '$apt_pref build-dep $@' root"
        print "$cmd"
        eval "$cmd"
    }
    alias ac='su -ls \'$apt_pref clean\' root'
    alias ad='su -lc \'$apt_pref update\' root'
    alias adg='su -lc \'$apt_pref update && aptitude safe-upgrade\' root'
    alias adu='su -lc \'$apt_pref update && aptitude dist-upgrade\' root'
    alias afu='su -lc "apt-file update"'
    alias ag='su -lc \'$apt_pref safe-upgrade\' root'
    ai() {
        cmd="su -lc 'aptitude -P install $@' root"
        print "$cmd"
        eval "$cmd"
    }
    ap() {
        cmd="su -lc '$apt_pref -P purge $@' root"
        print "$cmd"
        eval "$cmd"
    }
    ar() {
        cmd="su -lc '$apt_pref -P remove $@' root"
        print "$cmd"
        eval "$cmd"
    }

    # Install all .deb files in the current directory
    # Assumes glob_subst is off
    alias dia='su -lc "dpkg -i ./*.deb" root'
    alias di='su -lc "dpkg -i" root'

    # Remove ALL kernel images and headers EXCEPT the one in use
    alias kclean='su -lc '\''aptitude remove -P ?and(~i~nlinux-(ima|hea) \
        ?not(~n`uname -r`))'\'' root'
fi

# Completion ################################################################

#
# Registers a compdef for $1 that calls $apt_pref with the commands $2
# To do that it creates a new completion function called _apt_pref_$2
#
apt_pref_compdef() {
    local f fb
    f="_apt_pref_${2}"

    eval "function ${f}() {
        shift words; 
	service=\"\$apt_pref\"; 
	words=(\"\$apt_pref\" '$2' \$words); 
	((CURRENT++))
	test \"\${apt_pref}\" = 'aptitude' && _aptitude || _apt
    }"

    compdef "$f" "$1"
}

apt_pref_compdef aac "autoclean"
apt_pref_compdef abd "build-dep"
apt_pref_compdef ac  "clean"
apt_pref_compdef ad  "update"
apt_pref_compdef afu "update"
apt_pref_compdef ag  "upgrade"
apt_pref_compdef ai  "install"
apt_pref_compdef ail "install"
apt_pref_compdef ap  "purge"
apt_pref_compdef ar  "remove"
apt_pref_compdef ads "dselect-upgrade"

# Misc. #####################################################################
# print all installed packages
alias allpkgs='aptitude search -F "%p" --disable-columns ~i'

# Create a basic .deb package
alias mydeb='time dpkg-buildpackage -rfakeroot -us -uc'


# Functions #################################################################
# create a simple script that can be used to 'duplicate' a system
apt-copy() {
    print '#!/bin/sh'"\n" > apt-copy.sh

    cmd='$apt_pref install'

    for p in ${(f)"$(aptitude search -F "%p" --disable-columns \~i)"}; {
        cmd="${cmd} ${p}"
    }

    print $cmd "\n" >> apt-copy.sh

    chmod +x apt-copy.sh
}

# Prints apt history
# Usage:
#   apt-history install
#   apt-history upgrade
#   apt-history remove
#   apt-history rollback
#   apt-history list
# Based On: http://linuxcommando.blogspot.com/2008/08/how-to-show-apt-log-history.html
apt-history () {
  case "$1" in
    install)
      zgrep --no-filename 'install ' $(ls -rt /var/log/dpkg*)
      ;;
    upgrade|remove)
      zgrep --no-filename $1 $(ls -rt /var/log/dpkg*)
      ;;
    rollback)
      zgrep --no-filename upgrade $(ls -rt /var/log/dpkg*) | \
        grep "$2" -A10000000 | \
        grep "$3" -B10000000 | \
        awk '{print $4"="$5}'
      ;;
    list)
      zcat $(ls -rt /var/log/dpkg*)
      ;;
    *)
      echo "Parameters:"
      echo " install - Lists all packages that have been installed."
      echo " upgrade - Lists all packages that have been upgraded."
      echo " remove - Lists all packages that have been removed."
      echo " rollback - Lists rollback information."
      echo " list - Lists all contains of dpkg logs."
      ;;
  esac
}

# Kernel-package building shortcut
kerndeb () {
    # temporarily unset MAKEFLAGS ( '-j3' will fail )
    MAKEFLAGS=$( print - $MAKEFLAGS | perl -pe 's/-j\s*[\d]+//g' )
    print '$MAKEFLAGS set to '"'$MAKEFLAGS'"
	appendage='-custom' # this shows up in $ (uname -r )
    revision=$(date +"%Y%m%d") # this shows up in the .deb file name

    make-kpkg clean

    time fakeroot make-kpkg --append-to-version "$appendage" --revision \
        "$revision" kernel_image kernel_headers
}

# List packages by size
function apt-list-packages {
    dpkg-query -W --showformat='${Installed-Size} ${Package} ${Status}\n' | \
    grep -v deinstall | \
    sort -n | \
    awk '{print $1" "$2}'
}

## Aliases

alias ys="yum search"                       # search package
alias yp="yum info"                         # show package info
alias yl="yum list"                         # list packages
alias ygl="yum grouplist"                   # list package groups
alias yli="yum list installed"              # print all installed packages
alias ymc="yum makecache"                   # rebuilds the yum package list

alias yu="sudo yum update"                  # upgrate packages
alias yi="sudo yum install"                 # install package
alias ygi="sudo yum groupinstall"           # install package group
alias yr="sudo yum remove"                  # remove package
alias ygr="sudo yum groupremove"            # remove pagage group
alias yrl="sudo yum remove --remove-leaves" # remove package and leaves
alias yc="sudo yum clean all"               # clean cache# Find python file
alias pyfind='find . -name "*.py"'

# Remove python compiled byte-code in either current directory or in a
# list of specified directories
function pyclean() {
    ZSH_PYCLEAN_PLACES=${*:-'.'}
    find ${ZSH_PYCLEAN_PLACES} -type f -name "*.py[co]" -delete
    find ${ZSH_PYCLEAN_PLACES} -type d -name "__pycache__" -delete
}

# Grep among .py files
alias pygrep='grep --include="*.py"'

# Usage:
# Just add pip to your installed plugins.

# If you would like to change the cheeseshops used for autocomplete set
# ZSH_PIP_INDEXES in your zshrc. If one of your indexes are bogus you won't get
# any kind of error message, pip will just not autocomplete from them. Double
# check!
#
# If you would like to clear your cache, go ahead and do a
# "zsh-pip-clear-cache".

ZSH_PIP_CACHE_FILE=~/.pip/zsh-cache
ZSH_PIP_INDEXES=(https://pypi.python.org/simple/)

zsh-pip-clear-cache() {
  rm $ZSH_PIP_CACHE_FILE
  unset piplist
}

zsh-pip-clean-packages() {
    sed -n '/<a href/ s/.*>\([^<]\{1,\}\).*/\1/p'
}

zsh-pip-cache-packages() {
  if [[ ! -d ${ZSH_PIP_CACHE_FILE:h} ]]; then
      mkdir -p ${ZSH_PIP_CACHE_FILE:h}
  fi

  if [[ ! -f $ZSH_PIP_CACHE_FILE ]]; then
      echo -n "(...caching package index...)"
      tmp_cache=/tmp/zsh_tmp_cache
      for index in $ZSH_PIP_INDEXES ; do
          # well... I've already got two problems
          curl $index 2>/dev/null | \
              zsh-pip-clean-packages \
               >> $tmp_cache
      done
      sort $tmp_cache | uniq | tr '\n' ' ' > $ZSH_PIP_CACHE_FILE
      rm $tmp_cache
  fi
}

# A test function that validates the regex against known forms of the simple
# index. If you modify the regex to make it work for you, you should add a test
# case in here and make sure that your changes don't break things for someone
# else.
zsh-pip-test-clean-packages() {
    local expected
    local actual
    expected="0x10c-asm
1009558_nester"

    actual=$(echo -n "<html><head><title>Simple Index</title><meta name=\"api-version\" value=\"2\" /></head><body>
<a href='0x10c-asm'>0x10c-asm</a><br/>
<a href='1009558_nester'>1009558_nester</a><br/>
</body></html>" | zsh-pip-clean-packages)

    if [[ $actual != $expected ]] ; then
        echo -e "python's simple index is broken:\n$actual\n  !=\n$expected"
    else
        echo "python's simple index is fine"
    fi

    actual=$(echo -n '<html>
  <head>
    <title>Simple Package Index</title>
  </head>
  <body>
    <a href="0x10c-asm">0x10c-asm</a><br/>
    <a href="1009558_nester">1009558_nester</a><br/>
</body></html>' | zsh-pip-clean-packages)

    if [[ $actual != $expected ]] ; then
        echo -e "the djangopypi2 index is broken:\n$actual\n  !=\n$expected"
    else
        echo "the djangopypi2 index is fine"
    fi
}
function virtualenv_prompt_info(){
  if [[ -n $VIRTUAL_ENV ]]; then
    printf "%s[%s] " "%{${fg[yellow]}%}" ${${VIRTUAL_ENV}:t}
  fi
}

# disables prompt mangling in virtual_env/bin/activate
export VIRTUAL_ENV_DISABLE_PROMPT=1
virtualenvwrapper='virtualenvwrapper.sh'
if (( $+commands[$virtualenvwrapper] )); then
  source ${${virtualenvwrapper}:c}

  if [[ ! $DISABLE_VENV_CD -eq 1 ]]; then
    # Automatically activate Git projects's virtual environments based on the
    # directory name of the project. Virtual environment name can be overridden
    # by placing a .venv file in the project root with a virtualenv name in it
    function workon_cwd {
        if [ ! $WORKON_CWD ]; then
            WORKON_CWD=1
            # Check if this is a Git repo
            PROJECT_ROOT=`git rev-parse --show-toplevel 2> /dev/null`
            if (( $? != 0 )); then
                PROJECT_ROOT="."
            fi
            # Check for virtualenv name override
            if [[ -f "$PROJECT_ROOT/.venv" ]]; then
                ENV_NAME=`cat "$PROJECT_ROOT/.venv"`
            elif [[ -f "$PROJECT_ROOT/.venv/bin/activate" ]];then
                ENV_NAME="$PROJECT_ROOT/.venv"
            elif [[ "$PROJECT_ROOT" != "." ]]; then
                ENV_NAME=`basename "$PROJECT_ROOT"`
            else
                ENV_NAME=""
            fi
            if [[ "$ENV_NAME" != "" ]]; then
                # Activate the environment only if it is not already active
                if [[ "$VIRTUAL_ENV" != "$WORKON_HOME/$ENV_NAME" ]]; then
                    if [[ -e "$WORKON_HOME/$ENV_NAME/bin/activate" ]]; then
                        workon "$ENV_NAME" && export CD_VIRTUAL_ENV="$ENV_NAME"
                    elif [[ -e "$ENV_NAME/bin/activate" ]]; then
                        source $ENV_NAME/bin/activate && export CD_VIRTUAL_ENV="$ENV_NAME"
                    fi
                fi
            elif [ $CD_VIRTUAL_ENV ]; then
                # We've just left the repo, deactivate the environment
                # Note: this only happens if the virtualenv was activated automatically
                deactivate && unset CD_VIRTUAL_ENV
            fi
            unset PROJECT_ROOT
            unset WORKON_CWD
        fi
    }

    # Append workon_cwd to the chpwd_functions array, so it will be called on cd
    # http://zsh.sourceforge.net/Doc/Release/Functions.html
    # TODO: replace with 'add-zsh-hook chpwd workon_cwd' when oh-my-zsh min version is raised above 4.3.4
    if (( ${+chpwd_functions} )); then
        if (( $chpwd_functions[(I)workon_cwd] == 0 )); then
            set -A chpwd_functions $chpwd_functions workon_cwd
        fi
    else
        set -A chpwd_functions workon_cwd
    fi
  fi
else
  print "zsh virtualenvwrapper plugin: Cannot find ${virtualenvwrapper}. Please install with \`pip install virtualenvwrapper\`."
fi
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
if [ "$OS" = "Windows_NT" ] && ([ "$MSYSTEM" = "MINGW32" ] || [ "$MSYSTEM" = "MINGW64" ])
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

# Let the user tell us they never want to cd to projects
# automatically.
export VIRTUALENVWRAPPER_WORKON_CD=${VIRTUALENVWRAPPER_WORKON_CD:-1}

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
        builtin \cd -q "$@"
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
    touch "$file"
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
                fi;;
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
    # Must quote the parameters, as environments could have spaces in their names
    for env_name in "$@"
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
    # Note that this is a little tricky, as there may be spaces in the path.
    #
    # 1. Look for environments by finding the activate scripts.
    #    Use a subshell so we can suppress the message printed
    #    by zsh if the glob pattern fails to match any files.
    #    This yields a single, space-separated line containing all matches.
    # 2. Replace the trailing newline with a space, so every
    #    possible env has a space following it.
    # 3. Strip the bindir/activate script suffix, replacing it with
    #    a slash, as that is an illegal character in a directory name.
    #    This yields a slash-separated list of possible env names.
    # 4. Replace each slash with a newline to show the output one name per line.
    # 5. Eliminate any lines with * on them because that means there 
    #    were no envs.
    (virtualenvwrapper_cd "$WORKON_HOME" && echo */$VIRTUALENVWRAPPER_ENV_BIN_DIR/activate) 2>/dev/null \
        | command \tr "\n" " " \
        | command \sed "s|/$VIRTUALENVWRAPPER_ENV_BIN_DIR/activate |/|g" \
        | command \tr "/" "\n" \
        | command \sed "/^\s*$/d" \
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
    echo "       workon (-c|--cd) envname"
    echo ""
    echo "           After activating the environment, cd to the associated"
    echo "           project directory if it is set."
    echo ""
    echo "       workon (-n|--no-cd) envname"
    echo ""
    echo "           After activating the environment, do not cd to the"
    echo "           associated project directory."
    echo ""
}

#:help:workon: list or change working virtualenvs
function workon {
    typeset -a in_args
    typeset -a out_args

    in_args=( "$@" )

    if [ -n "$ZSH_VERSION" ]
    then
        i=1
        tst="-le"
    else
        i=0
        tst="-lt"
    fi
    typeset cd_after_activate=$VIRTUALENVWRAPPER_WORKON_CD
    while [ $i $tst $# ]
    do
        a="${in_args[$i]}"
        case "$a" in
            -h|--help)
                virtualenvwrapper_workon_help;
                return 0;;
            -n|--no-cd)
                cd_after_activate=0;;
            -c|--cd)
                cd_after_activate=1;;
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

    typeset env_name="$1"
    if [ "$env_name" = "" ]
    then
        lsvirtualenv -b
        return 1
    elif [ "$env_name" = "." ]
    then
        # The IFS default of breaking on whitespace causes issues if there
        # are spaces in the env_name, so change it.
        IFS='%'
        env_name="$(basename $(pwd))"
        unset IFS
    fi

    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_workon_environment "$env_name" || return 1

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

    VIRTUALENVWRAPPER_PROJECT_CD=$cd_after_activate virtualenvwrapper_run_hook "post_activate"

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
    virtualenvwrapper_cd "$site_packages/$1"
}

# Does a ``cd`` to the root of the currently-active virtualenv.
#:help:cdvirtualenv: change to the $VIRTUAL_ENV directory
function cdvirtualenv {
    virtualenvwrapper_verify_workon_home || return 1
    virtualenvwrapper_verify_active_environment || return 1
    virtualenvwrapper_cd "$VIRTUAL_ENV/$1"
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
        # see if it's already in workon
        if [ ! -e "$WORKON_HOME/$src_name" ]; then
            # so it's a virtualenv we are importing
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
    typeset -a in_args
    typeset -a out_args

    in_args=( "$@" )

    if [ -n "$ZSH_VERSION" ]
    then
        i=1
        tst="-le"
    else
        i=0
        tst="-lt"
    fi
    typeset cd_after_activate=$VIRTUALENVWRAPPER_WORKON_CD
    while [ $i $tst $# ]
    do
        a="${in_args[$i]}"
        case "$a" in
            -n|--no-cd)
                cd_after_activate=0;;
            -c|--cd)
                cd_after_activate=1;;
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
    [ "$cd_after_activate" = "1" ] && cdvirtualenv

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
        pip uninstall -y $(cat "$req_file" | grep -v '^-f' | sed 's/>/=/g' | cut -f1 -d=)
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

    # The IFS default of breaking on whitespace causes issues if there
    # are spaces in the env_name, so change it.
    IFS='%'
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
    unset IFS
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
# Aliases
alias pylint-quick='pylint --reports=n --include-ids=y'
compdef _pylint-quick pylint-quick='pylint --reports=n --include-ids=y'# Plugin for highligthing file content
# Plugin highlights file content based on the filename extension.
# If no highlighting method supported for given extension then it tries 
# guess it by looking for file content.

alias colorize='colorize_via_pygmentize'

colorize_via_pygmentize() {
    if [ ! -x $(which pygmentize) ]; then
        echo package \'pygmentize\' is not installed!
        exit -1
    fi

    if [ $# -eq 0 ]; then
        pygmentize -g $@
    fi

    for FNAME in $@
    do
        filename=$(basename "$FNAME")
        lexer=`pygmentize -N \"$filename\"`
        if [ "Z$lexer" != "Ztext" ]; then
            pygmentize -l $lexer "$FNAME"
        else
            pygmentize -g "$FNAME"
        fi
    done
}# TODO: Make this compatible with rvm.
#       Run sudo gem on the system ruby, not the active ruby.
alias sgem='sudo gem'

# Find ruby file
alias rfind='find . -name "*.rb" | xargs grep -n'
alias gemb="gem build *.gemspec"
alias gemp="gem push *.gem"

# gemy GEM 0.0.0 = gem yank GEM -v 0.0.0
function gemy {
	gem yank $1 -v $2
}fpath=($rvm_path/scripts/zsh/Completion $fpath)

alias rubies='rvm list rubies'
alias gemsets='rvm gemset list'

local ruby18='ruby-1.8.7'
local ruby19='ruby-1.9.3'
local ruby20='ruby-2.0.0'

function rb18 {
	if [ -z "$1" ]; then
		rvm use "$ruby18"
	else
		rvm use "$ruby18@$1"
	fi
}

_rb18() {compadd `ls -1 $rvm_path/gems | grep "^$ruby18@" | sed -e "s/^$ruby18@//" | awk '{print $1}'`}
compdef _rb18 rb18

function rb19 {
	if [ -z "$1" ]; then
		rvm use "$ruby19"
	else
		rvm use "$ruby19@$1"
	fi
}

_rb19() {compadd `ls -1 $rvm_path/gems | grep "^$ruby19@" | sed -e "s/^$ruby19@//" | awk '{print $1}'`}
compdef _rb19 rb19

function rb20 {
	if [ -z "$1" ]; then
		rvm use "$ruby20"
	else
		rvm use "$ruby20@$1"
	fi
}

_rb20() {compadd `ls -1 $rvm_path/gems | grep "^$ruby20@" | sed -e "s/^$ruby20@//" | awk '{print $1}'`}
compdef _rb20 rb20

function rvm-update {
	rvm get head
}

# TODO: Make this usable w/o rvm.
function gems {
	local current_ruby=`rvm-prompt i v p`
	local current_gemset=`rvm-prompt g`

	gem list $@ | sed \
		-Ee "s/\([0-9, \.]+( .+)?\)/$fg[blue]&$reset_color/g" \
		-Ee "s|$(echo $rvm_path)|$fg[magenta]\$rvm_path$reset_color|g" \
		-Ee "s/$current_ruby@global/$fg[yellow]&$reset_color/g" \
		-Ee "s/$current_ruby$current_gemset$/$fg[green]&$reset_color/g"
}

function _rvm_completion {
  source $rvm_path"/scripts/zsh/Completion/_rvm"
}
compdef _rvm_completion rvm
alias be="bundle exec"
alias bl="bundle list"
alias bp="bundle package"
alias bo="bundle open"
alias bu="bundle update"

# The following is based on https://github.com/gma/bundler-exec

bundled_commands=(annotate berks cap capify cucumber foodcritic foreman guard irb jekyll kitchen knife middleman nanoc puma rackup rainbows rake rspec ruby shotgun spec spin spork strainer tailor taps thin thor unicorn unicorn_rails)

# Remove $UNBUNDLED_COMMANDS from the bundled_commands list
for cmd in $UNBUNDLED_COMMANDS; do
  bundled_commands=(${bundled_commands#$cmd});
done

## Functions

bi() {
  if _bundler-installed && _within-bundled-project; then
    local bundler_version=`bundle version | cut -d' ' -f3`
    if [[ $bundler_version > '1.4.0' || $bundler_version = '1.4.0' ]]; then
      if [[ "$(uname)" == 'Darwin' ]]
      then
        local cores_num="$(sysctl hw.ncpu | awk '{print $2}')"
      else
        local cores_num="$(nproc)"
      fi
      bundle install --jobs=$cores_num $@
    else
      bundle install $@
    fi
  else
    echo "Can't 'bundle install' outside a bundled project"
  fi
}

_bundler-installed() {
  which bundle > /dev/null 2>&1
}

_within-bundled-project() {
  local check_dir=$PWD
  while [ $check_dir != "/" ]; do
    [ -f "$check_dir/Gemfile" ] && return
    check_dir="$(dirname $check_dir)"
  done
  false
}

_run-with-bundler() {
  if _bundler-installed && _within-bundled-project; then
    bundle exec $@
  else
    $@
  fi
}

## Main program
for cmd in $bundled_commands; do
  eval "function unbundled_$cmd () { $cmd \$@ }"
  eval "function bundled_$cmd () { _run-with-bundler $cmd \$@}"
  alias $cmd=bundled_$cmd

  if which _$cmd > /dev/null 2>&1; then
        compdef _$cmd bundled_$cmd=$cmd
  fi
done

# Thank you Jim for everything you contributed to the Ruby and open source community 
# over the years. We will miss you dearly.
alias jimweirich="rake"  

alias rake="noglob rake" # allows square brackts for rake task invocation
alias brake='noglob bundle exec rake' # execute the bundled rake gem
alias srake='noglob sudo rake' # noglob must come before sudo
alias sbrake='noglob sudo bundle exec rake' # altogether now ... 


_rake_refresh () {
  if [ -f .rake_tasks ]; then
    rm .rake_tasks
  fi
  echo "Generating .rake_tasks..." > /dev/stderr
  _rake_generate
  cat .rake_tasks
}

_rake_does_task_list_need_generating () {
  if [ ! -f .rake_tasks ]; then return 0;
  else
    if [[ $(uname -s) == 'Darwin' ]]; then
      accurate=$(stat -f%m .rake_tasks)
      changed=$(stat -f%m Rakefile)
    else
      accurate=$(stat -c%Y .rake_tasks)
      changed=$(stat -c%Y Rakefile)
    fi
    return $(expr $accurate '>=' $changed)
  fi
}

_rake_generate () {
  rake --silent --tasks | cut -d " " -f 2 > .rake_tasks
}

_rake () {
  if [ -f Rakefile ]; then
    if _rake_does_task_list_need_generating; then
      echo "\nGenerating .rake_tasks..." > /dev/stderr
      _rake_generate
    fi
    compadd `cat .rake_tasks`
  fi
}

compdef _rake rake
alias rake_refresh='_rake_refresh'
_ant_does_target_list_need_generating () {
  [ ! -f .ant_targets ] && return 0;
  [ .ant_targets -nt build.xml ] && return 0;
  return 1;
}

_ant () {
  if [ -f build.xml ]; then
    if _ant_does_target_list_need_generating; then
     sed -n '/<target/s/<target.*name="\([^"]*\).*$/\1/p' build.xml > .ant_targets
    fi
    compadd `cat .ant_targets`
  fi
}

compdef _ant ant
# mvn-color based on https://gist.github.com/1027800
export BOLD=`tput bold`
export UNDERLINE_ON=`tput smul`
export UNDERLINE_OFF=`tput rmul`
export TEXT_BLACK=`tput setaf 0`
export TEXT_RED=`tput setaf 1`
export TEXT_GREEN=`tput setaf 2`
export TEXT_YELLOW=`tput setaf 3`
export TEXT_BLUE=`tput setaf 4`
export TEXT_MAGENTA=`tput setaf 5`
export TEXT_CYAN=`tput setaf 6`
export TEXT_WHITE=`tput setaf 7`
export BACKGROUND_BLACK=`tput setab 0`
export BACKGROUND_RED=`tput setab 1`
export BACKGROUND_GREEN=`tput setab 2`
export BACKGROUND_YELLOW=`tput setab 3`
export BACKGROUND_BLUE=`tput setab 4`
export BACKGROUND_MAGENTA=`tput setab 5`
export BACKGROUND_CYAN=`tput setab 6`
export BACKGROUND_WHITE=`tput setab 7`
export RESET_FORMATTING=`tput sgr0`

 
# Wrapper function for Maven's mvn command.
mvn-color()
{
  (
  # Filter mvn output using sed. Before filtering set the locale to C, so invalid characters won't break some sed implementations
  unset LANG
  LC_CTYPE=C mvn $@ | sed -e "s/\(\[INFO\]\)\(.*\)/${TEXT_BLUE}${BOLD}\1${RESET_FORMATTING}\2/g" \
               -e "s/\(\[INFO\]\ BUILD SUCCESSFUL\)/${BOLD}${TEXT_GREEN}\1${RESET_FORMATTING}/g" \
               -e "s/\(\[WARNING\]\)\(.*\)/${BOLD}${TEXT_YELLOW}\1${RESET_FORMATTING}\2/g" \
               -e "s/\(\[ERROR\]\)\(.*\)/${BOLD}${TEXT_RED}\1${RESET_FORMATTING}\2/g" \
               -e "s/Tests run: \([^,]*\), Failures: \([^,]*\), Errors: \([^,]*\), Skipped: \([^,]*\)/${BOLD}${TEXT_GREEN}Tests run: \1${RESET_FORMATTING}, Failures: ${BOLD}${TEXT_RED}\2${RESET_FORMATTING}, Errors: ${BOLD}${TEXT_RED}\3${RESET_FORMATTING}, Skipped: ${BOLD}${TEXT_YELLOW}\4${RESET_FORMATTING}/g"
 
  # Make sure formatting is reset
  echo -ne ${RESET_FORMATTING}
  )
}
 
# Override the mvn command with the colorized one.
#alias mvn="mvn-color"

# aliases
alias mvncie='mvn clean install eclipse:eclipse'
alias mvnci='mvn clean install'
alias mvne='mvn eclipse:eclipse'
alias mvnce='mvn clean eclipse:clean eclipse:eclipse'
alias mvnd='mvn deploy'
alias mvnp='mvn package'
alias mvnc='mvn clean'
alias mvncom='mvn compile'
alias mvnt='mvn test'
alias mvnag='mvn archetype:generate'
alias mvn-updates='mvn versions:display-dependency-updates'
alias mvntc7='mvn tomcat7:run' 
alias mvntc='mvn tomcat:run'
alias mvnjetty='mvn jetty:run'


function listMavenCompletions { 
     reply=(
        # common lifecycle
        clean process-resources compile process-test-resources test-compile test package verify install deploy site
        
        # common plugins
        deploy failsafe install site surefire checkstyle javadoc jxr pmd ant antrun archetype assembly dependency enforcer gpg help release repository source eclipse idea jetty cargo jboss tomcat tomcat6 tomcat7 exec versions war ear ejb android scm buildnumber nexus repository sonar license hibernate3 liquibase flyway gwt
       
        # deploy
        deploy:deploy-file
        # failsafe
        failsafe:integration-test failsafe:verify
        # install
        install:install-file
        # site
        site:site site:deploy site:run site:stage site:stage-deploy
        # surefire
        surefire:test
            
        # checkstyle
        checkstyle:checkstyle checkstyle:check
        # javadoc
        javadoc:javadoc javadoc:jar javadoc:aggregate
        # jxr
        jxr:jxr
        # pmd
        pmd:pmd pmd:cpd pmd:check pmd:cpd-check

        # ant
        ant:ant ant:clean
        # antrun
        antrun:run
        # archetype
        archetype:generate archetype:create-from-project archetype:crawl
        # assembly
        assembly:single assembly:assembly
        # dependency
        dependency:analyze dependency:analyze-dep-mgt dependency:analyze-only dependency:analyze-report dependency:build-classpath dependency:copy dependency:copy-dependencies dependency:get dependency:go-offline dependency:list dependency:purge-local-repository dependency:resolve dependency:resolve-plugins dependency:sources dependency:tree dependency:unpack dependency:unpack-dependencies
        # enforcer
        enforcer:enforce
        # gpg
        gpg:sign gpg:sign-and-deploy-file
        # help
        help:active-profiles help:all-profiles help:describe help:effective-pom help:effective-settings help:evaluate help:expressions help:system
        # release
        release:clean release:prepare release:rollback release:perform release:stage release:branch release:update-versions
        # repository
        repository:bundle-create repository:bundle-pack
        # source
        source:aggregate source:jar source:jar-no-fork
            
        # eclipse
        eclipse:clean eclipse:eclipse
        # idea
        idea:clean idea:idea
            
        # jetty
        jetty:run jetty:run-exploded
        # cargo
        cargo:start cargo:run cargo:stop cargo:deploy cargo:undeploy cargo:help
        # jboss
        jboss:start jboss:stop jboss:deploy jboss:undeploy jboss:redeploy
        # tomcat
        tomcat:start tomcat:stop tomcat:deploy tomcat:undeploy tomcat:redeploy
        # tomcat6
        tomcat6:run tomcat6:run-war tomcat6:run-war-only tomcat6:stop tomcat6:deploy tomcat6:undeploy
        # tomcat7
        tomcat7:run tomcat7:run-war tomcat7:run-war-only tomcat7:deploy
        # exec
        exec:exec exec:java
        # versions
        versions:display-dependency-updates versions:display-plugin-updates versions:display-property-updates versions:update-parent versions:update-properties versions:update-child-modules versions:lock-snapshots versions:unlock-snapshots versions:resolve-ranges versions:set versions:use-releases versions:use-next-releases versions:use-latest-releases versions:use-next-snapshots versions:use-latest-snapshots versions:use-next-versions versions:use-latest-versions versions:commit versions:revert
        # scm
        scm:add scm:checkin scm:checkout scm:update scm:status
        # buildnumber
        buildnumber:create buildnumber:create-timestamp buildnumber:help buildnumber:hgchangeset

        # war
        war:war war:exploded war:inplace war:manifest
        # ear
        ear:ear ear:generate-application-xml
        # ejb
        ejb:ejb
        # android
        android:apk android:apklib android:deploy android:deploy-dependencies android:dex android:emulator-start android:emulator-stop android:emulator-stop-all android:generate-sources android:help android:instrument android:manifest-update android:pull android:push android:redeploy android:run android:undeploy android:unpack android:version-update android:zipalign android:devices
        # nexus
        nexus:staging-list nexus:staging-close nexus:staging-drop nexus:staging-release nexus:staging-build-promotion nexus:staging-profiles-list nexus:settings-download
        # repository
        repository:bundle-create repository:bundle-pack repository:help

        # sonar
        sonar:sonar
        # license
        license:format license:check
        # hibernate3
        hibernate3:hbm2ddl hibernate3:help
        # liquibase
        liquibase:changelogSync liquibase:changelogSyncSQL liquibase:clearCheckSums liquibase:dbDoc liquibase:diff liquibase:dropAll liquibase:help liquibase:migrate liquibase:listLocks liquibase:migrateSQL liquibase:releaseLocks liquibase:rollback liquibase:rollbackSQL liquibase:status liquibase:tag liquibase:update liquibase:updateSQL liquibase:updateTestingRollback
        # flyway
        flyway:clean flyway:history flyway:init flyway:migrate flyway:status flyway:validate
        # gwt
        gwt:browser gwt:clean gwt:compile gwt:compile-report gwt:css gwt:debug gwt:eclipse gwt:eclipseTest gwt:generateAsync gwt:help gwt:i18n gwt:mergewebxml gwt:resources gwt:run gwt:sdkInstall gwt:source-jar gwt:soyc gwt:test

        # options
        -Dmaven.test.skip=true -DskipTests -Dmaven.surefire.debug -DenableCiProfile -Dpmd.skip=true -Dcheckstyle.skip=true -Dtycho.mode=maven

        # arguments
        -am -amd -B -C -c -cpu -D -e -emp -ep -f -fae -ff -fn -gs -h -l -N -npr -npu -nsu -o -P -pl -q -rf -s -T -t -U -up -V -v -X

        cli:execute cli:execute-phase 
        archetype:generate generate-sources 
        cobertura:cobertura
        -Dtest= `if [ -d ./src/test/java ] ; then find ./src/test/java -type f -name '*.java' | grep -v svn | sed 's?.*/\([^/]*\)\..*?-Dtest=\1?' ; fi`
    ); 
}

compctl -K listMavenCompletions mvn
alias bi="bower install"
alias bl="bower list"
alias bs="bower search"

_bower_installed_packages () {
    bower_package_list=$(bower ls --no-color 2>/dev/null| awk 'NR>3{print p}{p=$0}'| cut -d ' ' -f 2|sed 's/#.*//')
}
_bower ()
{
    local -a _1st_arguments _no_color _dopts _save_dev _force_lastest _production
    local expl
    typeset -A opt_args

    _no_color=('--no-color[Do not print colors (available in all commands)]')

    _dopts=(
        '(--save)--save[Save installed packages into the project"s bower.json dependencies]'
        '(--force)--force[Force fetching remote resources even if a local copy exists on disk]'
    )

    _save_dev=('(--save-dev)--save-dev[Save installed packages into the project"s bower.json devDependencies]')

    _force_lastest=('(--force-latest)--force-latest[Force latest version on conflict]')

    _production=('(--production)--production[Do not install project devDependencies]')

    _1st_arguments=(
    'cache-clean:Clean the Bower cache, or the specified package caches' \
    'help:Display help information about Bower' \
    'info:Version info and description of a particular package' \
    'init:Interactively create a bower.json file' \
    'install:Install a package locally' \
    'link:Symlink a package folder' \
    'lookup:Look up a package URL by name' \
    'register:Register a package' \
    'search:Search for a package by name' \
    'uninstall:Remove a package' \
    'update:Update a package' \
    {ls,list}:'[List all installed packages]'
    )
    _arguments \
    $_no_color \
    '*:: :->subcmds' && return 0

    if (( CURRENT == 1 )); then
        _describe -t commands "bower subcommand" _1st_arguments
        return
    fi

    case "$words[1]" in
        install)
        _arguments \
        $_dopts \
        $_save_dev \
        $_force_lastest \
        $_no_color \
        $_production
        ;;
        update)
        _arguments \
        $_dopts \
        $_no_color \
        $_force_lastest
        _bower_installed_packages
        compadd "$@" $(echo $bower_package_list)
        ;;
        uninstall)
        _arguments \
        $_no_color \
        $_dopts
        _bower_installed_packages
        compadd "$@" $(echo $bower_package_list)
        ;;
        *)
        $_no_color \
        ;;
    esac

}

compdef _bower bower
# if using GNU screen, let the zsh tell screen what the title and hardstatus
# of the tab window should be.
if [[ "$TERM" == screen* ]]; then
  if [[ $_GET_PATH == '' ]]; then
    _GET_PATH='echo $PWD | sed "s/^\/Users\//~/;s/^\/home\//~/;s/^~$USER/~/"'
  fi
  if [[ $_GET_HOST == '' ]]; then
    _GET_HOST='echo $HOST | sed "s/\..*//"'
  fi

  # use the current user as the prefix of the current tab title 
  TAB_TITLE_PREFIX='"`'$_GET_HOST'`:`'$_GET_PATH' | sed "s:..*/::"`$PROMPT_CHAR"'
  # when at the shell prompt, show a truncated version of the current path (with
  # standard ~ replacement) as the rest of the title.
  TAB_TITLE_PROMPT='$SHELL:t'
  # when running a command, show the title of the command as the rest of the
  # title (truncate to drop the path to the command)
  TAB_TITLE_EXEC='$cmd[1]:t'

  # use the current path (with standard ~ replacement) in square brackets as the
  # prefix of the tab window hardstatus.
  TAB_HARDSTATUS_PREFIX='"[`'$_GET_PATH'`] "'
  # when at the shell prompt, use the shell name (truncated to remove the path to
  # the shell) as the rest of the title
  TAB_HARDSTATUS_PROMPT='$SHELL:t'
  # when running a command, show the command name and arguments as the rest of
  # the title
  TAB_HARDSTATUS_EXEC='$cmd'

  # tell GNU screen what the tab window title ($1) and the hardstatus($2) should be
  function screen_set()
  {
    # set the tab window title (%t) for screen
    print -nR $'\033k'$1$'\033'\\\

    # set hardstatus of tab window (%h) for screen
    print -nR $'\033]0;'$2$'\a'
  }
  # called by zsh before executing a command
  function preexec()
  {
    local -a cmd; cmd=(${(z)1}) # the command string
    eval "tab_title=$TAB_TITLE_PREFIX:$TAB_TITLE_EXEC"
    eval "tab_hardstatus=$TAB_HARDSTATUS_PREFIX:$TAB_HARDSTATUS_EXEC"
    screen_set $tab_title $tab_hardstatus
  }
  # called by zsh before showing the prompt
  function precmd()
  {
    eval "tab_title=$TAB_TITLE_PREFIX:$TAB_TITLE_PROMPT"
    eval "tab_hardstatus=$TAB_HARDSTATUS_PREFIX:$TAB_HARDSTATUS_PROMPT"
    screen_set $tab_title $tab_hardstatus
  }
fi#
# Aliases
#

alias ta='tmux attach -t'
alias ts='tmux new-session -s'
alias tl='tmux list-sessions'

# Only run if tmux is actually installed
if which tmux &> /dev/null
	then
	# Configuration variables
	#
	# Automatically start tmux
	[[ -n "$ZSH_TMUX_AUTOSTART" ]] || ZSH_TMUX_AUTOSTART=false
	# Only autostart once. If set to false, tmux will attempt to
	# autostart every time your zsh configs are reloaded.
	[[ -n "$ZSH_TMUX_AUTOSTART_ONCE" ]] || ZSH_TMUX_AUTOSTART_ONCE=true
	# Automatically connect to a previous session if it exists
	[[ -n "$ZSH_TMUX_AUTOCONNECT" ]] || ZSH_TMUX_AUTOCONNECT=true
	# Automatically close the terminal when tmux exits
	[[ -n "$ZSH_TMUX_AUTOQUIT" ]] || ZSH_TMUX_AUTOQUIT=$ZSH_TMUX_AUTOSTART
	# Set term to screen or screen-256color based on current terminal support
	[[ -n "$ZSH_TMUX_FIXTERM" ]] || ZSH_TMUX_FIXTERM=true
	# Set '-CC' option for iTerm2 tmux integration
	[[ -n "$ZSH_TMUX_ITERM2" ]] || ZSH_TMUX_ITERM2=false
	# The TERM to use for non-256 color terminals.
	# Tmux states this should be screen, but you may need to change it on
	# systems without the proper terminfo
	[[ -n "$ZSH_TMUX_FIXTERM_WITHOUT_256COLOR" ]] || ZSH_TMUX_FIXTERM_WITHOUT_256COLOR="screen"
	# The TERM to use for 256 color terminals.
	# Tmux states this should be screen-256color, but you may need to change it on
	# systems without the proper terminfo
	[[ -n "$ZSH_TMUX_FIXTERM_WITH_256COLOR" ]] || ZSH_TMUX_FIXTERM_WITH_256COLOR="screen-256color"


	# Get the absolute path to the current directory
	local zsh_tmux_plugin_path="$(cd "$(dirname "$0")" && pwd)"

	# Determine if the terminal supports 256 colors
	if [[ `tput colors` == "256" ]]
	then
		export ZSH_TMUX_TERM=$ZSH_TMUX_FIXTERM_WITH_256COLOR
	else
		export ZSH_TMUX_TERM=$ZSH_TMUX_FIXTERM_WITHOUT_256COLOR
	fi

	# Set the correct local config file to use.
    if [[ "$ZSH_TMUX_ITERM2" == "false" ]] && [[ -f $HOME/.tmux.conf || -h $HOME/.tmux.conf ]]
	then
		#use this when they have a ~/.tmux.conf
		export _ZSH_TMUX_FIXED_CONFIG="$zsh_tmux_plugin_path/tmux.extra.conf"
	else
		#use this when they don't have a ~/.tmux.conf
		export _ZSH_TMUX_FIXED_CONFIG="$zsh_tmux_plugin_path/tmux.only.conf"
	fi

	# Wrapper function for tmux.
	function _zsh_tmux_plugin_run()
	{
		# We have other arguments, just run them
		if [[ -n "$@" ]]
		then
			\tmux $@
		# Try to connect to an existing session.
		elif [[ "$ZSH_TMUX_AUTOCONNECT" == "true" ]]
		then
			\tmux `[[ "$ZSH_TMUX_ITERM2" == "true" ]] && echo '-CC '` attach || \tmux `[[ "$ZSH_TMUX_ITERM2" == "true" ]] && echo '-CC '` `[[ "$ZSH_TMUX_FIXTERM" == "true" ]] && echo '-f '$_ZSH_TMUX_FIXED_CONFIG` new-session
			[[ "$ZSH_TMUX_AUTOQUIT" == "true" ]] && exit
		# Just run tmux, fixing the TERM variable if requested.
		else
			\tmux `[[ "$ZSH_TMUX_ITERM2" == "true" ]] && echo '-CC '` `[[ "$ZSH_TMUX_FIXTERM" == "true" ]] && echo '-f '$_ZSH_TMUX_FIXED_CONFIG`
			[[ "$ZSH_TMUX_AUTOQUIT" == "true" ]] && exit
		fi
	}

	# Use the completions for tmux for our function
	compdef _tmux _zsh_tmux_plugin_run

	# Alias tmux to our wrapper function.
	alias tmux=_zsh_tmux_plugin_run

	# Autostart if not already in tmux and enabled.
	if [[ ! -n "$TMUX" && "$ZSH_TMUX_AUTOSTART" == "true" ]]
	then
		# Actually don't autostart if we already did and multiple autostarts are disabled.
		if [[ "$ZSH_TMUX_AUTOSTART_ONCE" == "false" || "$ZSH_TMUX_AUTOSTARTED" != "true" ]]
		then
			export ZSH_TMUX_AUTOSTARTED=true
			_zsh_tmux_plugin_run
		fi
	fi
else
	print "zsh tmux plugin: tmux not found. Please install tmux before using this plugin."
fi
zsh tmux plugin: tmux not found. Please install tmux before using this plugin.
################################################################################
# Author: Pete Clark
# Email: pete[dot]clark[at]gmail[dot]com
# Version: 0.1 (05/24/2011)
# License: WTFPL<http://sam.zoy.org/wtfpl/>
#
# This oh-my-zsh plugin adds smart tab completion for
# TaskWarrior<http://taskwarrior.org/>. It uses the zsh tab completion
# script (_task) distributed with TaskWarrior for the completion definitions.
#
# Typing task[tabtab] will give you a list of current tasks, task 66[tabtab]
# gives a list of available modifications for that task, etc.
################################################################################

zstyle ':completion:*:*:task:*' verbose yes
zstyle ':completion:*:*:task:*:descriptions' format '%U%B%d%b%u'

zstyle ':completion:*:*:task:*' group-name ''

alias t=task
compdef _task t=task
# ------------------------------------------------------------------------------
#          FILE:  extract.plugin.zsh
#   DESCRIPTION:  oh-my-zsh plugin file.
#        AUTHOR:  Sorin Ionescu (sorin.ionescu@gmail.com)
#       VERSION:  1.0.1
# ------------------------------------------------------------------------------


function extract() {
  local remove_archive
  local success
  local file_name
  local extract_dir

  if (( $# == 0 )); then
    echo "Usage: extract [-option] [file ...]"
    echo
    echo Options:
    echo "    -r, --remove    Remove archive."
    echo
    echo "Report bugs to <sorin.ionescu@gmail.com>."
  fi

  remove_archive=1
  if [[ "$1" == "-r" ]] || [[ "$1" == "--remove" ]]; then
    remove_archive=0 
    shift
  fi

  while (( $# > 0 )); do
    if [[ ! -f "$1" ]]; then
      echo "extract: '$1' is not a valid file" 1>&2
      shift
      continue
    fi

    success=0
    file_name="$( basename "$1" )"
    extract_dir="$( echo "$file_name" | sed "s/\.${1##*.}//g" )"
    case "$1" in
      (*.tar.gz|*.tgz) tar xvzf "$1" ;;
      (*.tar.bz2|*.tbz|*.tbz2) tar xvjf "$1" ;;
      (*.tar.xz|*.txz) tar --xz --help &> /dev/null \
        && tar --xz -xvf "$1" \
        || xzcat "$1" | tar xvf - ;;
      (*.tar.zma|*.tlz) tar --lzma --help &> /dev/null \
        && tar --lzma -xvf "$1" \
        || lzcat "$1" | tar xvf - ;;
      (*.tar) tar xvf "$1" ;;
      (*.gz) gunzip "$1" ;;
      (*.bz2) bunzip2 "$1" ;;
      (*.xz) unxz "$1" ;;
      (*.lzma) unlzma "$1" ;;
      (*.Z) uncompress "$1" ;;
      (*.zip|*.war|*.jar) unzip "$1" -d $extract_dir ;;
      (*.rar) unrar x -ad "$1" ;;
      (*.7z) 7za x "$1" ;;
      (*.deb)
        mkdir -p "$extract_dir/control"
        mkdir -p "$extract_dir/data"
        cd "$extract_dir"; ar vx "../${1}" > /dev/null
        cd control; tar xzvf ../control.tar.gz
        cd ../data; tar xzvf ../data.tar.gz
        cd ..; rm *.tar.gz debian-binary
        cd ..
      ;;
      (*) 
        echo "extract: '$1' cannot be extracted" 1>&2
        success=1 
      ;; 
    esac

    (( success = $success > 0 ? $success : $? ))
    (( $success == 0 )) && (( $remove_archive == 0 )) && rm "$1"
    shift
  done
}

alias x=extract

# ------------------------------------------------------------------------------
#          FILE:  osx.plugin.zsh
#   DESCRIPTION:  oh-my-zsh plugin file.
#        AUTHOR:  Sorin Ionescu (sorin.ionescu@gmail.com)
#       VERSION:  1.1.0
# ------------------------------------------------------------------------------

function tab() {
  local command="cd \\\"$PWD\\\"; clear; "
  (( $# > 0 )) && command="${command}; $*"

  the_app=$(
    osascript 2>/dev/null <<EOF
      tell application "System Events"
        name of first item of (every process whose frontmost is true)
      end tell
EOF
  )

  [[ "$the_app" == 'Terminal' ]] && {
    osascript 2>/dev/null <<EOF
      tell application "System Events"
        tell process "Terminal" to keystroke "t" using command down
        tell application "Terminal" to do script "${command}" in front window
      end tell
EOF
  }

  [[ "$the_app" == 'iTerm' ]] && {
    osascript 2>/dev/null <<EOF
      tell application "iTerm"
        set current_terminal to current terminal
        tell current_terminal
          launch session "Default Session"
          set current_session to current session
          tell current_session
            write text "${command}"
          end tell
        end tell
      end tell
EOF
  }
}

function vsplit_tab() {
  local command="cd \\\"$PWD\\\""
  (( $# > 0 )) && command="${command}; $*"

  the_app=$(
    osascript 2>/dev/null <<EOF
      tell application "System Events"
        name of first item of (every process whose frontmost is true)
      end tell
EOF
  )

  [[ "$the_app" == 'iTerm' ]] && {
    osascript 2>/dev/null <<EOF
      tell application "iTerm" to activate

      tell application "System Events"
        tell process "iTerm"
          tell menu item "Split Vertically With Current Profile" of menu "Shell" of menu bar item "Shell" of menu bar 1
            click
          end tell
        end tell
        keystroke "${command}; clear;"
        keystroke return
      end tell
EOF
  }
}

function split_tab() {
  local command="cd \\\"$PWD\\\""
  (( $# > 0 )) && command="${command}; $*"

  the_app=$(
    osascript 2>/dev/null <<EOF
      tell application "System Events"
        name of first item of (every process whose frontmost is true)
      end tell
EOF
  )

  [[ "$the_app" == 'iTerm' ]] && {
    osascript 2>/dev/null <<EOF
      tell application "iTerm" to activate

      tell application "System Events"
        tell process "iTerm"
          tell menu item "Split Horizontally With Current Profile" of menu "Shell" of menu bar item "Shell" of menu bar 1
            click
          end tell
        end tell
        keystroke "${command}; clear;"
        keystroke return
      end tell
EOF
  }
}

function pfd() {
  osascript 2>/dev/null <<EOF
    tell application "Finder"
      return POSIX path of (target of window 1 as alias)
    end tell
EOF
}

function pfs() {
  osascript 2>/dev/null <<EOF
    set output to ""
    tell application "Finder" to set the_selection to selection
    set item_count to count the_selection
    repeat with item_index from 1 to count the_selection
      if item_index is less than item_count then set the_delimiter to "\n"
      if item_index is item_count then set the_delimiter to ""
      set output to output & ((item item_index of the_selection as alias)'s POSIX path) & the_delimiter
    end repeat
EOF
}

function cdf() {
  cd "$(pfd)"
}

function pushdf() {
  pushd "$(pfd)"
}

function quick-look() {
  (( $# > 0 )) && qlmanage -p $* &>/dev/null &
}

function man-preview() {
  man -t "$@" | open -f -a Preview
}

function trash() {
  local trash_dir="${HOME}/.Trash"
  local temp_ifs=$IFS
  IFS=$'\n'
  for item in "$@"; do
    if [[ -e "$item" ]]; then
      item_name="$(basename $item)"
      if [[ -e "${trash_dir}/${item_name}" ]]; then
        mv -f "$item" "${trash_dir}/${item_name} $(date "+%H-%M-%S")"
      else
        mv -f "$item" "${trash_dir}/"
      fi
    fi
  done
  IFS=$temp_ifs
}

function vncviewer() {
  open vnc://$@
}

# iTunes control function
function itunes() {
	local opt=$1
	shift
	case "$opt" in
		launch|play|pause|stop|rewind|resume|quit)
			;;
		mute)
			opt="set mute to true"
			;;
		unmute)
			opt="set mute to false"
			;;
		next|previous)
			opt="$opt track"
			;;
		""|-h|--help)
			echo "Usage: itunes <option>"
			echo "option:"
			echo "\tlaunch|play|pause|stop|rewind|resume|quit"
			echo "\tmute|unmute\tcontrol volume set"
			echo "\tnext|previous\tplay next or previous track"
			echo "\thelp\tshow this message and exit"
			return 0
			;;
		*)
			print "Unknown option: $opt"
			return 1
			;;
	esac
	osascript -e "tell application \"iTunes\" to $opt"
}

# ------------------------------------------------------------------------------
#          FILE:  compleat.plugin.zsh
#   DESCRIPTION:  oh-my-zsh plugin file.
#        AUTHOR:  Sorin Ionescu (sorin.ionescu@gmail.com)
#       VERSION:  1.0.0
# ------------------------------------------------------------------------------

if (( ${+commands[compleat]} )); then
  local prefix="${commands[compleat]:h:h}"
  local setup="${prefix}/share/compleat-1.0/compleat_setup" 

  if [[ -f "$setup" ]]; then
    if ! bashcompinit >/dev/null 2>&1; then
      autoload -U bashcompinit
      bashcompinit -i
    fi

    source "$setup" 
  fi
fi

# Load all of your custom configurations from custom/
for config_file ($ZSH_CUSTOM/*.zsh(N)); do
  source $config_file
done
# Add yourself some shortcuts to projects you often work on
# Example:
#
# brainstormr=/Users/robbyrussell/Projects/development/planetargon/brainstormr
#unset config_file

# Load the theme
if [ "$ZSH_THEME" = "random" ]; then
  themes=($ZSH/themes/*zsh-theme)
  N=${#themes[@]}
  ((N=(RANDOM%N)+1))
  RANDOM_THEME=${themes[$N]}
  source "$RANDOM_THEME"
  echo "[oh-my-zsh] Random theme '$RANDOM_THEME' loaded..."
else
  if [ ! "$ZSH_THEME" = ""  ]; then
    if [ -f "$ZSH_CUSTOM/$ZSH_THEME.zsh-theme" ]; then
      source "$ZSH_CUSTOM/$ZSH_THEME.zsh-theme"
    elif [ -f "$ZSH_CUSTOM/themes/$ZSH_THEME.zsh-theme" ]; then
      source "$ZSH_CUSTOM/themes/$ZSH_THEME.zsh-theme"
    else
      source "$ZSH/themes/$ZSH_THEME.zsh-theme"
    fi
  fi
fi
function prompt_char {
	if [ $UID -eq 0 ]; then echo "#"; else echo $; fi
}

PROMPT='%(!.%{$fg_bold[red]%}.%{$fg_bold[green]%}%n@)%m %{$fg_bold[blue]%}%(!.%1~.%~) $(git_prompt_info)$(hg_prompt_info)$(virtualenv_prompt_info)
%_$(prompt_char)%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX="("
ZSH_THEME_GIT_PROMPT_SUFFIX=") "

ZSH_THEME_HG_PROMPT_PREFIX="("
ZSH_THEME_HG_PROMPT_SUFFIX=" "
ZSH_THEME_HG_PROMPT_DIRTY="*) "
ZSH_THEME_HG_PROMPT_CLEAN=") "

# User configuration

export PATH=$HOME/bin:/usr/local/bin:$PATH
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"
#
source $__DOTFILES/etc/zsh/00-zshrc.before.sh


#  __DOTFILES -- local dotfiles repository clone
export __DOTFILES=${__DOTFILES:-"${HOME}/-dotfiles"}

if [ -d /Library ]; then
    export __IS_MAC='true'
else:
    export __IS_LINUX='true'
fi

dotfiles_zsh_reload() {
    echo "# Reloading zsh configuration..."
    _zsh_conf=$__DOTFILES/etc/zsh
  #source ~/.zshrc
    #source 00-zshrc.before.sh

      ## lib: zsh functions
      source $_zsh_conf/01-zshrc.lib.sh

      ## bash: read bash config with bash_source function
      source $_zsh_conf/05-zshrc.bashrc.sh

    ## after:
    source $_zsh_conf/99-zshrc.after.sh
}

function dr () {
    #  dr()     -- dotfiles_zsh_reload $@
    dotfiles_zsh_reload $@
}

dotfiles_zsh_reload
# Reloading zsh configuration...

funcdir=${__DOTFILES}/etc/zsh/functions/

source $funcdir/bash_source.sh
#!/bin/zsh
# bash_source -- load bash scripts with zsh options

emulate -R zsh -c 'autoload -Uz is-at-least'
if is-at-least 5.0.0; then
	emulate -R sh -o kshglob +o shglob +o ignorebraces -o bash_rematch -c '
		function bash_source {
			source "$@"
		}
	'
else
	emulate -R sh -c '
		function bash_source {
			# Do note that functions about to be defined will not be set
			# with these options when run
			setopt kshglob noshglob braceexpand bash_rematch
			source "$@"
		}
	'
fi

# usage::
#   bash_source "$@"

#source $funcdir/lesspipe.sh

# list all path key components leading to file
lspath () {
        if [ "$1" = "${1##/}" ]
        then
	    pathlist=(/ ${(s:/:)PWD} ${(s:/:)1})
	else
	    pathlist=(/ ${(s:/:)1})
	fi
        allpaths=()
        filepath=$pathlist[0]
        shift pathlist
        for i in $pathlist[@]
        do
                allpaths=($allpaths[@] $filepath)
                filepath="${filepath%/}/$i"
        done
        allpaths=($allpaths[@] $filepath)
        ls -ldZ "$allpaths[@]"
        if [ -n "$2" ]; then
            getfacl "$allpaths[@]"
        fi
}

# requires:
#  bash_source function
#  $__DOTFILES

export __IS_ZSH="${__IS_ZSH:-"1"}"
bash_source "${__DOTFILES}/etc/bash/00-bashrc.before.sh"
#
# dotfiles_reload()
grep: warning: GREP_OPTIONS is deprecated; please use an alias or script
_configure_bash_completion:16: command not found: shopt
/home/wturner/-dotfiles/etc/bash/08-bashrc.conda.sh:102: command not found: complete
/home/wturner/-dotfiles/etc/bash/08-bashrc.conda.sh:109: command not found: complete
/home/wturner/-dotfiles/etc/bash/07-bashrc.virtualenvwrapper.sh:21: parse error near `('
/home/wturner/-dotfiles/etc/bash/07-bashrc.virtualenvwrapper.sh:59: parse error near `VIRTUALENVWRAPPER_SC...'
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:6: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:6: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:24: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:37: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:37: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:55: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:55: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:55: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:78: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:78: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:78: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:101: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:101: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:101: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:124: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:124: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:142: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:142: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:160: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:160: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:178: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:178: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:196: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:196: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:214: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:214: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:232: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:245: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:258: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:258: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:276: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:289: command not found: complete
/home/wturner/-dotfiles/etc/venv/scripts/venv.sh:289: command not found: complete
/home/wturner/-dotfiles/etc/bash/10-bashrc.venv.sh:115: command not found: complete
/home/wturner/-dotfiles/etc/bash/10-bashrc.venv.sh:116: command not found: complete
/home/wturner/-dotfiles/scripts/ew:21: command not found: complete
/home/wturner/-dotfiles/scripts/ew:22: command not found: complete
/home/wturner/-dotfiles/scripts/ew:24: parse error: condition expected: ==
/home/wturner/-dotfiles/scripts/makew:16: command not found: complete
/home/wturner/-dotfiles/scripts/hgw:9: command not found: complete
/home/wturner/-dotfiles/scripts/hgw:10: command not found: complete
_usrlog_set_HIST:fc:20: event not found: -a
_usrlog_set_HISTFILE:fc:5: event not found: -a
_usrlog_set_HISTFILE:fc:17: event not found: -r
]0;(dotfiles) #testing  wturner@create.lab.av.us.wrd.nu:/home/wturner/-wrk/-ve27/dotfiles/src/dotfiles# dotfiles_status()
HOSTNAME='create.lab.av.us.wrd.nu'
USER='wturner'
__WRK='/home/wturner/-wrk'
PROJECT_HOME='/home/wturner/-wrk'
CONDA_ROOT='/home/wturner/-wrk/-conda27'
CONDA_ENVS_PATH='/home/wturner/-wrk/-ce27'
WORKON_HOME='/home/wturner/-wrk/-ve27'
VIRTUAL_ENV_NAME='dotfiles'
VIRTUAL_ENV='/home/wturner/-wrk/-ve27/dotfiles'
_SRC='/home/wturner/-wrk/-ve27/dotfiles/src'
_APP='dotfiles'
_WRD='/home/wturner/-wrk/-ve27/dotfiles/src/dotfiles'
_USRLOG='/home/wturner/-wrk/-ve27/dotfiles/-usrlog.log'
_TERM_ID='#testing'
PATH='/home/wturner/bin:/usr/local/bin:/home/wturner/-wrk/-ve27/dotfiles/bin:/home/wturner/-dotfiles/scripts:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:/home/wturner/.local/bin:/home/wturner/bin'
__DOTFILES='/home/wturner/-dotfiles'
#
##
# 99-zsh.after.sh

# <Home> / <End>
bindkey '\e[1~' beginning-of-line
bindkey '\e[4~' end-of-line
exit
