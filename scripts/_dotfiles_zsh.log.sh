# system-wide environment settings for zsh(1)
if [ -x /usr/libexec/path_helper ]; then
	eval `/usr/libexec/path_helper -s`
fi
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
#files: 704	version: 5.0.2

_comps=(
'-' '_precommand'
'-array-value-' '_value'
'-assign-parameter-' '_assign'
'-brace-parameter-' '_brace_parameter'
'-command-' '_autocd'
'-command-line-' '_normal'
'-condition-' '_condition'
'-default-' '_default'
'-equal-' '_equal'
'-first-' '_first'
'-math-' '_math'
'-parameter-' '_parameter'
'-redirect-' '_redirect'
'-redirect-,-default-,-default-' '_files'
'-redirect-,<,bunzip2' '_bzip2'
'-redirect-,<,bzip2' '_bzip2'
'-redirect-,<,compress' '_compress'
'-redirect-,<,gunzip' '_gzip'
'-redirect-,<,gzip' '_gzip'
'-redirect-,<,uncompress' '_compress'
'-redirect-,<,unxz' '_xz'
'-redirect-,<,xz' '_xz'
'-redirect-,>,bzip2' '_bzip2'
'-redirect-,>,compress' '_compress'
'-redirect-,>,gzip' '_gzip'
'-redirect-,>,xz' '_xz'
'-subscript-' '_subscript'
'-tilde-' '_tilde'
'-value-' '_value'
'-value-,-default-,-command-' '_zargs'
'-value-,-default-,-default-' '_value'
'-value-,ADB_TRACE,-default-' '_adb'
'-value-,ANDROID_LOG_TAGS,-default-' '_adb'
'-value-,ANDROID_SERIAL,-default-' '_adb'
'-value-,ANT_ARGS,-default-' '_ant'
'-value-,CFLAGS,-default-' '_gcc'
'-value-,CPPFLAGS,-default-' '_gcc'
'-value-,DISPLAY,-default-' '_x_display'
'-value-,GREP_OPTIONS,-default-' '_grep'
'-value-,GZIP,-default-' '_gzip'
'-value-,LANG,-default-' '_locales'
'-value-,LANGUAGE,-default-' '_locales'
'-value-,LDFLAGS,-default-' '_gcc'
'-value-,LESS,-default-' '_less'
'-value-,LESSCHARSET,-default-' '_less'
'-value-,LPDEST,-default-' '_printers'
'-value-,P4CLIENT,-default-' '_perforce'
'-value-,P4MERGE,-default-' '_perforce'
'-value-,P4PORT,-default-' '_perforce'
'-value-,P4USER,-default-' '_perforce'
'-value-,PERLDOC,-default-' '_perldoc'
'-value-,PRINTER,-default-' '_printers'
'-value-,PROMPT,-default-' '_ps1234'
'-value-,PROMPT2,-default-' '_ps1234'
'-value-,PROMPT3,-default-' '_ps1234'
'-value-,PROMPT4,-default-' '_ps1234'
'-value-,PS1,-default-' '_ps1234'
'-value-,PS2,-default-' '_ps1234'
'-value-,PS3,-default-' '_ps1234'
'-value-,PS4,-default-' '_ps1234'
'-value-,RPROMPT,-default-' '_ps1234'
'-value-,RPROMPT2,-default-' '_ps1234'
'-value-,RPS1,-default-' '_ps1234'
'-value-,RPS2,-default-' '_ps1234'
'-value-,SPROMPT,-default-' '_ps1234'
'-value-,TERM,-default-' '_terminals'
'-value-,TERMINFO_DIRS,-default-' '_dir_list'
'-value-,TZ,-default-' '_time_zone'
'-value-,VALGRIND_OPTS,-default-' '_valgrind'
'-value-,WWW_HOME,-default-' '_urls'
'-value-,XML_CATALOG_FILES,-default-' '_xmlsoft'
'-value-,XZ_DEFAULTS,-default-' '_xz'
'-value-,XZ_OPT,-default-' '_xz'
'-vared-' '_in_vared'
'-zcalc-line-' '_zcalc_line'
'.' '_source'
'5g' '_go'
'5l' '_go'
'6g' '_go'
'6l' '_go'
'8g' '_go'
'8l' '_go'
'Mail' '_mail'
'Mosaic' '_webbrowser'
'SuSEconfig' '_SuSEconfig'
'a2dismod' '_a2utils'
'a2dissite' '_a2utils'
'a2enmod' '_a2utils'
'a2ensite' '_a2utils'
'a2ps' '_a2ps'
'aaaa' '_hosts'
'aap' '_aap'
'acpi' '_acpi'
'acpitool' '_acpitool'
'acroread' '_acroread'
'adb' '_adb'
'admin' '_sccs'
'ali' '_mh'
'alias' '_alias'
'amaya' '_webbrowser'
'analyseplugin' '_analyseplugin'
'animate' '_imagemagick'
'anno' '_mh'
'ant' '_ant'
'antiword' '_antiword'
'aoss' '_precommand'
'apache2ctl' '_apachectl'
'apachectl' '_apachectl'
'apm' '_apm'
'appletviewer' '_java'
'apropos' '_man'
'apt-cache' '_apt'
'apt-cdrom' '_apt'
'apt-config' '_apt'
'apt-file' '_apt-file'
'apt-get' '_apt'
'apt-move' '_apt-move'
'apt-show-versions' '_apt-show-versions'
'aptitude' '_aptitude'
'apvlv' '_pdf'
'arena' '_webbrowser'
'arp' '_arp'
'arping' '_arping'
'at' '_at'
'atq' '_at'
'atrm' '_at'
'attr' '_attr'
'auto-apt' '_auto-apt'
'autoload' '_typeset'
'awk' '_awk'
'axi-cache' '_axi-cache'
'bash' '_sh'
'batch' '_at'
'baz' '_baz'
'beadm' '_beadm'
'bg' '_jobs_bg'
'bindkey' '_bindkey'
'bison' '_bison'
'bogofilter' '_bogofilter'
'bogotune' '_bogofilter'
'bogoutil' '_bogofilter'
'brctl' '_brctl'
'btdownloadcurses' '_bittorrent'
'btdownloadgui' '_bittorrent'
'btdownloadheadless' '_bittorrent'
'btlaunchmany' '_bittorrent'
'btlaunchmanycurses' '_bittorrent'
'btmakemetafile' '_bittorrent'
'btreannounce' '_bittorrent'
'btrename' '_bittorrent'
'btrfs' '_btrfs'
'bts' '_bts'
'btshowmetainfo' '_bittorrent'
'bttrack' '_bittorrent'
'bug' '_bug'
'buildhash' '_ispell'
'builtin' '_builtin'
'bundle' '_bundler'
'bunzip2' '_bzip2'
'burst' '_mh'
'bzcat' '_bzip2'
'bzip2' '_bzip2'
'bzip2recover' '_bzip2'
'bzr' '_bzr'
'c++' '_gcc'
'cal' '_cal'
'calendar' '_calendar'
'catchsegv' '_precommand'
'cc' '_gcc'
'ccal' '_ccal'
'cd' '_cd'
'cdbs-edit-patch' '_cdbs-edit-patch'
'cdc' '_sccs'
'cdcd' '_cdcd'
'cdr' '_cdr'
'cdrdao' '_cdrdao'
'cdrecord' '_cdrecord'
'certtool' '_gnutls'
'cftp' '_twisted'
'chage' '_users'
'chdir' '_cd'
'chflags' '_chflags'
'chfn' '_users'
'chgrp' '_chown'
'chimera' '_webbrowser'
'chkconfig' '_chkconfig'
'chmod' '_chmod'
'chown' '_chown'
'chrt' '_chrt'
'chsh' '_users'
'ci' '_rcs'
'ckeygen' '_twisted'
'clang' '_gcc'
'clang++' '_gcc'
'clay' '_clay'
'clear' '_nothing'
'co' '_rcs'
'comb' '_sccs'
'combine' '_imagemagick'
'comm' '_comm'
'command' '_command'
'comp' '_mh'
'compdef' '_compdef'
'composite' '_imagemagick'
'compress' '_compress'
'conch' '_twisted'
'config.status' '_configure'
'configure' '_configure'
'convert' '_imagemagick'
'coreadm' '_coreadm'
'cowsay' '_cowsay'
'cowthink' '_cowsay'
'cp' '_cp'
'cpio' '_cpio'
'cplay' '_cplay'
'crsh' '_cssh'
'cryptsetup' '_cryptsetup'
'csh' '_sh'
'cssh' '_cssh'
'csup' '_csup'
'curl' '_urls'
'cut' '_cut'
'cvs' '_cvs'
'cvsup' '_cvsup'
'cygcheck' '_cygcheck'
'cygcheck.exe' '_cygcheck'
'cygpath' '_cygpath'
'cygpath.exe' '_cygpath'
'cygrunsrv' '_cygrunsrv'
'cygrunsrv.exe' '_cygrunsrv'
'cygserver' '_cygserver'
'cygserver.exe' '_cygserver'
'cygstart' '_cygstart'
'cygstart.exe' '_cygstart'
'dak' '_dak'
'darcs' '_darcs'
'date' '_date'
'dbus-monitor' '_dbus'
'dbus-send' '_dbus'
'dch' '_debchange'
'dchroot' '_dchroot'
'dchroot-dsa' '_dchroot-dsa'
'dcop' '_dcop'
'dcopclient' '_dcop'
'dcopfind' '_dcop'
'dcopobject' '_dcop'
'dcopref' '_dcop'
'dcopstart' '_dcop'
'dd' '_dd'
'debchange' '_debchange'
'debdiff' '_debdiff'
'debfoster' '_debfoster'
'debsign' '_debsign'
'declare' '_typeset'
'defaults' '_defaults'
'delta' '_sccs'
'devtodo' '_devtodo'
'df' '_directories'
'dhclient' '_dhclient'
'dhclient3' '_dhclient'
'dhcpinfo' '_dhcpinfo'
'dict' '_dict'
'diff' '_diff'
'diffstat' '_diffstat'
'dillo' '_webbrowser'
'dircmp' '_directories'
'dirs' '_dirs'
'disable' '_disable'
'disown' '_jobs_fg'
'display' '_imagemagick'
'dist' '_mh'
'django-admin' '_django'
'django-admin.py' '_django'
'dladm' '_dladm'
'dlocate' '_dlocate'
'dmake' '_make'
'dmidecode' '_dmidecode'
'domainname' '_yp'
'dosdel' '_floppy'
'dosread' '_floppy'
'dpatch-edit-patch' '_dpatch-edit-patch'
'dpkg' '_dpkg'
'dpkg-buildpackage' '_dpkg-buildpackage'
'dpkg-cross' '_dpkg-cross'
'dpkg-deb' '_dpkg'
'dpkg-query' '_dpkg'
'dpkg-reconfigure' '_dpkg'
'dpkg-repack' '_dpkg-repack'
'dpkg-source' '_dpkg_source'
'dput' '_dput'
'dtrace' '_dtrace'
'du' '_du'
'dumpadm' '_dumpadm'
'dumper' '_dumper'
'dumper.exe' '_dumper'
'dupload' '_dupload'
'dvibook' '_dvi'
'dviconcat' '_dvi'
'dvicopy' '_dvi'
'dvidvi' '_dvi'
'dvips' '_dvi'
'dviselect' '_dvi'
'dvitodvi' '_dvi'
'dvitype' '_dvi'
'dwb' '_webbrowser'
'ecasound' '_ecasound'
'echotc' '_echotc'
'echoti' '_echoti'
'egrep' '_grep'
'elinks' '_elinks'
'elm' '_elm'
'emulate' '_emulate'
'enable' '_enable'
'enscript' '_enscript'
'env' '_env'
'epdfview' '_pdf'
'epsffit' '_psutils'
'espeak' '_espeak'
'ethtool' '_ethtool'
'eval' '_precommand'
'eview' '_vim'
'evim' '_vim'
'evince' '_pdf'
'exec' '_precommand'
'exim' '_vim'
'explodepkg' '_pkgtool'
'export' '_typeset'
'express' '_webbrowser'
'extcheck' '_java'
'extract' '_extract'
'extractres' '_psutils'
'fakeroot' '_fakeroot'
'false' '_nothing'
'fc' '_fc'
'fc-list' '_xft_fonts'
'fc-match' '_xft_fonts'
'feh' '_feh'
'fetch' '_fetch'
'fetchmail' '_fetchmail'
'ffmpeg' '_ffmpeg'
'fg' '_jobs_fg'
'fgrep' '_grep'
'figlet' '_figlet'
'find' '_find'
'findaffix' '_ispell'
'finger' '_finger'
'fink' '_fink'
'firefox' '_mozilla'
'fixdlsrps' '_psutils'
'fixfmps' '_psutils'
'fixmacps' '_psutils'
'fixpsditps' '_psutils'
'fixpspps' '_psutils'
'fixscribeps' '_psutils'
'fixtpps' '_psutils'
'fixwfwps' '_psutils'
'fixwpps' '_psutils'
'fixwwps' '_psutils'
'flasher' '_flasher'
'flex' '_flex'
'flist' '_mh'
'flists' '_mh'
'float' '_typeset'
'flowadm' '_flowadm'
'fmadm' '_fmadm'
'fned' '_zed'
'folder' '_mh'
'folders' '_mh'
'fortune' '_fortune'
'forw' '_mh'
'freebsd-update' '_freebsd-update'
'fsh' '_fsh'
'fstat' '_fstat'
'ftp' '_hosts'
'functions' '_typeset'
'fuser' '_fuser'
'fusermount' '_fusermount'
'fwhois' '_whois'
'g++' '_gcc'
'galeon' '_webbrowser'
'gcc' '_gcc'
'gccgo' '_go'
'gcore' '_gcore'
'gdb' '_gdb'
'gdiff' '_diff'
'gem' '_gem'
'genisoimage' '_genisoimage'
'get' '_sccs'
'getafm' '_psutils'
'getclip' '_getclip'
'getclip.exe' '_getclip'
'getconf' '_getconf'
'getent' '_getent'
'getfacl' '_getfacl'
'getfacl.exe' '_getfacl'
'getfattr' '_attr'
'getmail' '_getmail'
'getopts' '_vars'
'gex' '_vim'
'ggv' '_gnome-gv'
'ghostscript' '_gs'
'ghostview' '_pspdf'
'git' '_git'
'git-branch' '_git-branch'
'git-buildpackage' '_git-buildpackage'
'git-cvsserver' '_git'
'git-receive-pack' '_git'
'git-remote' '_git-remote'
'git-shell' '_git'
'git-upload-archive' '_git'
'git-upload-pack' '_git'
'github' '_github'
'gitk' '_git'
'gln' '_ln'
'global' '_global'
'gls' '_ls'
'gm' '_graphicsmagick'
'gmake' '_make'
'gmplayer' '_mplayer'
'gnome-gv' '_gnome-gv'
'gnupod_INIT' '_gnupod'
'gnupod_INIT.pl' '_gnupod'
'gnupod_addsong' '_gnupod'
'gnupod_addsong.pl' '_gnupod'
'gnupod_check' '_gnupod'
'gnupod_check.pl' '_gnupod'
'gnupod_search' '_gnupod'
'gnupod_search.pl' '_gnupod'
'gnutls-cli' '_gnutls'
'gnutls-cli-debug' '_gnutls'
'gofmt' '_go'
'gpg' '_gpg'
'gpg-zip' '_gpg'
'gpgv' '_gpg'
'gphoto2' '_gphoto2'
'gprof' '_gprof'
'gqview' '_gqview'
'gradle' '_gradle'
'gradlew' '_gradle'
'grail' '_webbrowser'
'grep' '_grep'
'grep-excuses' '_grep-excuses'
'groff' '_groff'
'groupadd' '_user_admin'
'groupdel' '_groups'
'groupmod' '_user_admin'
'groups' '_users'
'growisofs' '_growisofs'
'gs' '_gs'
'gsbj' '_pspdf'
'gsdj' '_pspdf'
'gsdj500' '_pspdf'
'gslj' '_pspdf'
'gslp' '_pspdf'
'gsnd' '_pspdf'
'gtar' '_tar'
'guilt' '_guilt'
'guilt-add' '_guilt'
'guilt-applied' '_guilt'
'guilt-delete' '_guilt'
'guilt-files' '_guilt'
'guilt-fold' '_guilt'
'guilt-fork' '_guilt'
'guilt-header' '_guilt'
'guilt-help' '_guilt'
'guilt-import' '_guilt'
'guilt-import-commit' '_guilt'
'guilt-init' '_guilt'
'guilt-new' '_guilt'
'guilt-next' '_guilt'
'guilt-patchbomb' '_guilt'
'guilt-pop' '_guilt'
'guilt-prev' '_guilt'
'guilt-push' '_guilt'
'guilt-rebase' '_guilt'
'guilt-refresh' '_guilt'
'guilt-rm' '_guilt'
'guilt-series' '_guilt'
'guilt-status' '_guilt'
'guilt-top' '_guilt'
'guilt-unapplied' '_guilt'
'gunzip' '_gzip'
'gv' '_gv'
'gview' '_vim'
'gvim' '_vim'
'gvimdiff' '_vim'
'gzcat' '_gzip'
'gzilla' '_webbrowser'
'gzip' '_gzip'
'hash' '_hash'
'hdiutil' '_hdiutil'
'help' '_sccs'
'hg' '_hg'
'hilite' '_precommand'
'history' '_fc'
'host' '_hosts'
'hotjava' '_webbrowser'
'hwinfo' '_hwinfo'
'iceweasel' '_mozilla'
'icombine' '_ispell'
'iconv' '_iconv'
'id' '_id'
'identify' '_imagemagick'
'ifconfig' '_ifconfig'
'ifdown' '_net_interfaces'
'iftop' '_iftop'
'ifup' '_net_interfaces'
'ijoin' '_ispell'
'import' '_imagemagick'
'inc' '_mh'
'includeres' '_psutils'
'inetadm' '_inetadm'
'info' '_texinfo'
'infocmp' '_terminals'
'initctl' '_initctl'
'insmod' '_modutils'
'install-info' '_texinfo'
'installpkg' '_pkgtool'
'integer' '_typeset'
'invoke-rc.d' '_invoke-rc.d'
'ionice' '_ionice'
'ip' '_ip'
'ipadm' '_ipadm'
'ipset' '_ipset'
'iptables' '_iptables'
'iptables-restore' '_iptables'
'iptables-save' '_iptables'
'irssi' '_irssi'
'ispell' '_ispell'
'iwconfig' '_iwconfig'
'jadetex' '_tex'
'jar' '_java'
'jarsigner' '_java'
'java' '_java'
'javac' '_java'
'javadoc' '_java'
'javah' '_java'
'javap' '_java'
'jdb' '_java'
'jobs' '_jobs_builtin'
'joe' '_joe'
'join' '_join'
'keytool' '_java'
'kfmclient' '_kfmclient'
'kill' '_kill'
'killall' '_killall'
'killall5' '_killall'
'kioclient' '_kfmclient'
'kldload' '_kld'
'kldunload' '_kld'
'knock' '_knock'
'konqueror' '_webbrowser'
'kpdf' '_pdf'
'ksh' '_sh'
'kvno' '_kvno'
'last' '_last'
'lastb' '_last'
'latex' '_tex'
'latexmk' '_tex'
'ldd' '_ldd'
'less' '_less'
'let' '_math'
'lftp' '_ncftp'
'lha' '_lha'
'light' '_webbrowser'
'lighty-disable-mod' '_lighttpd'
'lighty-enable-mod' '_lighttpd'
'limit' '_limit'
'linda' '_linda'
'links' '_links'
'lintian' '_lintian'
'lintian-info' '_lintian'
'linux' '_uml'
'llvm-g++' '_gcc'
'llvm-gcc' '_gcc'
'ln' '_ln'
'loadkeys' '_loadkeys'
'local' '_typeset'
'locate' '_locate'
'log' '_nothing'
'logname' '_nothing'
'look' '_look'
'lore' '_twisted'
'losetup' '_losetup'
'lp' '_lp'
'lpadmin' '_lp'
'lpinfo' '_lp'
'lpoptions' '_lp'
'lpq' '_lp'
'lpr' '_lp'
'lprm' '_lp'
'lpstat' '_lp'
'ls' '_ls'
'lscfg' '_lscfg'
'lsdev' '_lsdev'
'lslv' '_lslv'
'lsmod' '_modutils'
'lsof' '_lsof'
'lspv' '_lspv'
'lsusb' '_lsusb'
'lsvg' '_lsvg'
'lynx' '_lynx'
'lzcat' '_xz'
'lzma' '_xz'
'lzop' '_lzop'
'm-a' '_module-assistant'
'madison' '_madison'
'mail' '_mail'
'mailx' '_mail'
'make' '_make'
'make-kpkg' '_make-kpkg'
'makeinfo' '_texinfo'
'makepkg' '_pkgtool'
'man' '_man'
'man-preview' '_man-preview'
'manage.py' '_django'
'manhole' '_twisted'
'mark' '_mh'
'matlab' '_matlab'
'mattrib' '_mtools'
'mcd' '_mtools'
'mcopy' '_mtools'
'md5sum' '_md5sum'
'mdadm' '_mdadm'
'mdel' '_mtools'
'mdeltree' '_mtools'
'mdir' '_mtools'
'mdu' '_mtools'
'members' '_members'
'mencal' '_mencal'
'mere' '_mere'
'merge' '_rcs'
'mergechanges' '_mergechanges'
'metaflac' '_metaflac'
'mformat' '_mtools'
'mgv' '_pspdf'
'mhlist' '_mh'
'mhmail' '_mh'
'mhn' '_mh'
'mhparam' '_mh'
'mhpath' '_mh'
'mhshow' '_mh'
'mhstore' '_mh'
'mii-tool' '_mii-tool'
'mkdir' '_mkdir'
'mkisofs' '_growisofs'
'mkshortcut' '_mkshortcut'
'mkshortcut.exe' '_mkshortcut'
'mktap' '_twisted'
'mktunes' '_gnupod'
'mktunes.pl' '_gnupod'
'mkzsh' '_mkzsh'
'mkzsh.exe' '_mkzsh'
'mlabel' '_mtools'
'mlocate' '_locate'
'mmd' '_mtools'
'mmm' '_webbrowser'
'mmount' '_mtools'
'mmove' '_mtools'
'modinfo' '_modutils'
'modprobe' '_modutils'
'module' '_module'
'module-assistant' '_module-assistant'
'mogrify' '_imagemagick'
'mondoarchive' '_mondo'
'montage' '_imagemagick'
'mosh' '_mosh'
'mount' '_mount'
'mozilla' '_mozilla'
'mozilla-firefox' '_mozilla'
'mozilla-xremote-client' '_mozilla'
'mpc' '_mpc'
'mplayer' '_mplayer'
'mrd' '_mtools'
'mread' '_mtools'
'mren' '_mtools'
'msgchk' '_mh'
'mt' '_mt'
'mtn' '_monotone'
'mtoolstest' '_mtools'
'mtr' '_mtr'
'mtype' '_mtools'
'munchlist' '_ispell'
'mush' '_mail'
'mutt' '_mutt'
'mx' '_hosts'
'mysql' '_mysql_utils'
'mysqladmin' '_mysql_utils'
'mysqldiff' '_mysqldiff'
'mysqldump' '_mysql_utils'
'mysqlimport' '_mysql_utils'
'mysqlshow' '_mysql_utils'
'nail' '_mail'
'native2ascii' '_java'
'nautilus' '_nautilus'
'nc' '_netcat'
'ncal' '_cal'
'ncftp' '_ncftp'
'ncl' '_nedit'
'nedit' '_nedit'
'nedit-nc' '_nedit'
'netcat' '_netcat'
'netrik' '_webbrowser'
'netscape' '_netscape'
'netstat' '_netstat'
'newgrp' '_groups'
'next' '_mh'
'nice' '_nice'
'nkf' '_nkf'
'nm' '_nm'
'nmap' '_nmap'
'nmblookup' '_samba'
'nmcli' '_nmcli'
'nocorrect' '_precommand'
'noglob' '_precommand'
'nohup' '_precommand'
'notmuch' '_notmuch'
'npm' '_npm'
'ns' '_hosts'
'nslookup' '_nslookup'
'ntalk' '_other_accounts'
'odme' '_object_classes'
'odmget' '_object_classes'
'odmshow' '_object_classes'
'ogg123' '_vorbis'
'oggdec' '_vorbis'
'oggenc' '_vorbis'
'ogginfo' '_vorbis'
'okular' '_okular'
'open' '_open'
'opera' '_webbrowser'
'opera-next' '_webbrowser'
'osc' '_osc'
'p4' '_perforce'
'p4d' '_perforce'
'pack' '_pack'
'packf' '_mh'
'parsehdlist' '_urpmi'
'passwd' '_users'
'patch' '_patch'
'pax' '_pax'
'pbuilder' '_pbuilder'
'pcat' '_pack'
'pcred' '_pids'
'pdf2dsc' '_pdf'
'pdf2ps' '_pdf'
'pdffonts' '_pdf'
'pdfimages' '_pdf'
'pdfinfo' '_pdf'
'pdfjadetex' '_tex'
'pdflatex' '_tex'
'pdfopt' '_pdf'
'pdftex' '_tex'
'pdftk' '_pdftk'
'pdftopbm' '_pdf'
'pdftops' '_pdf'
'pdftotext' '_pdf'
'pep8' '_pep8'
'perl' '_perl'
'perldoc' '_perldoc'
'pfctl' '_pfctl'
'pfexec' '_pfexec'
'pfiles' '_pids'
'pflags' '_pids'
'pgrep' '_pgrep'
'php' '_php'
'pick' '_mh'
'pine' '_pine'
'pinef' '_pine'
'ping' '_ping'
'pip' '_pip'
'piuparts' '_piuparts'
'pkg' '_pkg5'
'pkg-config' '_pkg-config'
'pkg_add' '_bsd_pkg'
'pkg_create' '_bsd_pkg'
'pkg_delete' '_bsd_pkg'
'pkg_info' '_bsd_pkg'
'pkgadd' '_pkgadd'
'pkginfo' '_pkginfo'
'pkgrm' '_pkgrm'
'pkgtool' '_pkgtool'
'pkill' '_pgrep'
'pldd' '_pids'
'pmake' '_make'
'pman' '_perl_modules'
'pmap' '_pids'
'pmcat' '_perl_modules'
'pmdesc' '_perl_modules'
'pmeth' '_perl_modules'
'pmexp' '_perl_modules'
'pmfunc' '_perl_modules'
'pmload' '_perl_modules'
'pmls' '_perl_modules'
'pmpath' '_perl_modules'
'pmvers' '_perl_modules'
'podgrep' '_perl_modules'
'podpath' '_perl_modules'
'podtoc' '_perl_modules'
'poff' '_pon'
'policytool' '_java'
'pon' '_pon'
'popd' '_directory_stack'
'portaudit' '_portaudit'
'portlint' '_portlint'
'portmaster' '_portmaster'
'portsnap' '_portsnap'
'postsuper' '_postfix'
'powerd' '_powerd'
'prcs' '_prcs'
'prev' '_mh'
'print' '_print'
'printenv' '_printenv'
'printf' '_print'
'procstat' '_procstat'
'prompt' '_prompt'
'prs' '_sccs'
'prstat' '_prstat'
'prt' '_sccs'
'prun' '_pids'
'ps2ascii' '_pspdf'
'ps2epsi' '_ps'
'ps2pdf' '_ps'
'ps2pdf12' '_ps'
'ps2pdf13' '_ps'
'ps2pdf14' '_ps'
'ps2pdfwr' '_ps'
'ps2ps' '_ps'
'psbook' '_psutils'
'pscp' '_pscp'
'pscp.exe' '_pscp'
'psig' '_pids'
'psmerge' '_psutils'
'psmulti' '_ps'
'psnup' '_psutils'
'psresize' '_psutils'
'psselect' '_psutils'
'pstack' '_pids'
'pstoedit' '_pspdf'
'pstop' '_pids'
'pstops' '_psutils'
'pstotgif' '_pspdf'
'pswrap' '_ps'
'ptree' '_pids'
'pump' '_pump'
'pushd' '_cd'
'putclip' '_putclip'
'putclip.exe' '_putclip'
'pwait' '_pids'
'pwdx' '_pids'
'pydoc' '_pydoc'
'pyhtmlizer' '_twisted'
'pylint' '_pylint'
'python' '_python'
'qemu' '_qemu'
'qiv' '_qiv'
'qtplay' '_qtplay'
'querybts' '_bug'
'quilt' '_quilt'
'r' '_fc'
'raggle' '_raggle'
'rake' '_rake'
'ranlib' '_ranlib'
'rar' '_rar'
'rc' '_sh'
'rcp' '_rlogin'
'rcs' '_rcs'
'rcsdiff' '_rcs'
'read' '_read'
'readonly' '_typeset'
'readshortcut' '_readshortcut'
'readshortcut.exe' '_readshortcut'
'rebootin' '_rebootin'
'refile' '_mh'
'rehash' '_hash'
'reload' '_initctl'
'removepkg' '_pkgtool'
'remsh' '_rlogin'
'renice' '_renice'
'repl' '_mh'
'reportbug' '_bug'
'reprepro' '_reprepro'
'restart' '_initctl'
'retawq' '_webbrowser'
'rgview' '_vim'
'rgvim' '_vim'
'ri' '_ri'
'rlogin' '_rlogin'
'rm' '_rm'
'rmadison' '_madison'
'rmdel' '_sccs'
'rmdir' '_directories'
'rmf' '_mh'
'rmic' '_java'
'rmid' '_java'
'rmiregistry' '_java'
'rmm' '_mh'
'rmmod' '_modutils'
'rpm' '_rpm'
'rpmbuild' '_rpmbuild'
'rrdtool' '_rrdtool'
'rsh' '_rlogin'
'rsync' '_rsync'
'rtin' '_tin'
'rubber' '_rubber'
'rubber-info' '_rubber'
'rubber-pipe' '_rubber'
'ruby' '_ruby'
'rup' '_hosts'
'rusage' '_precommand'
'rview' '_vim'
'rvim' '_vim'
'rwho' '_hosts'
'rxvt' '_urxvt'
'sabcmd' '_sablotron'
'sact' '_sccs'
'savecore' '_savecore'
'scan' '_mh'
'sccs' '_sccs'
'sccsdiff' '_sccs'
'sched' '_sched'
'schedtool' '_schedtool'
'schroot' '_schroot'
'scp' '_ssh'
'screen' '_screen'
'sed' '_sed'
'serialver' '_java'
'service' '_service'
'set' '_set'
'setfacl' '_setfacl'
'setfacl.exe' '_setfacl'
'setfattr' '_attr'
'setopt' '_setopt'
'sftp' '_ssh'
'sh' '_sh'
'shift' '_arrays'
'show' '_mh'
'showchar' '_psutils'
'showmount' '_showmount'
'sisu' '_sisu'
'skipstone' '_webbrowser'
'slitex' '_tex'
'slocate' '_locate'
'slogin' '_ssh'
'slrn' '_slrn'
'smbclient' '_samba'
'smbcontrol' '_samba'
'smbstatus' '_samba'
'smit' '_smit'
'smitty' '_smit'
'snoop' '_snoop'
'soa' '_hosts'
'socket' '_socket'
'sockstat' '_sockstat'
'softwareupdate' '_softwareupdate'
'sort' '_sort'
'sortm' '_mh'
'source' '_source'
'spamassassin' '_spamassassin'
'sqlite' '_sqlite'
'sqlite3' '_sqlite'
'sqsh' '_sqsh'
'sr' '_surfraw'
'srptool' '_gnutls'
'ssh' '_ssh'
'ssh-add' '_ssh'
'ssh-agent' '_ssh'
'ssh-copy-id' '_ssh'
'ssh-keygen' '_ssh'
'sshfs' '_sshfs'
'star' '_tar'
'start' '_initctl'
'stat' '_stat'
'status' '_initctl'
'stg' '_stgit'
'stop' '_initctl'
'strace' '_strace'
'strip' '_strip'
'stty' '_stty'
'su' '_su'
'sudo' '_sudo'
'sudoedit' '_sudo'
'surfraw' '_surfraw'
'svcadm' '_svcadm'
'svccfg' '_svccfg'
'svcprop' '_svcprop'
'svcs' '_svcs'
'svn' '_subversion'
'svn-buildpackage' '_svn-buildpackage'
'svnadmin' '_subversion'
'svnadmin-static' '_subversion'
'sync' '_nothing'
'sysctl' '_sysctl'
'systemctl' '_systemd'
'systemd-loginctl' '_systemd'
'talk' '_other_accounts'
'tap2deb' '_twisted'
'tap2rpm' '_twisted'
'tapconvert' '_twisted'
'tar' '_tar'
'tardy' '_tardy'
'task' '_task'
'tcp_open' '_tcpsys'
'tcpdump' '_tcpdump'
'tcptraceroute' '_tcptraceroute'
'tcsh' '_sh'
'tda' '_devtodo'
'tdd' '_devtodo'
'tde' '_devtodo'
'tdr' '_devtodo'
'telnet' '_telnet'
'tex' '_tex'
'texi2dvi' '_texinfo'
'texindex' '_texinfo'
'tg' '_topgit'
'tidy' '_tidy'
'tig' '_git'
'time' '_precommand'
'times' '_nothing'
'tin' '_tin'
'tkconch' '_twisted'
'tkinfo' '_texinfo'
'tkmktap' '_twisted'
'tla' '_tla'
'tmux' '_tmux'
'todo' '_devtodo'
'todo.sh' '_todo.sh'
'toilet' '_toilet'
'totdconfig' '_totd'
'tpb' '_tpb'
'tpconfig' '_tpconfig'
'tpkg-debarch' '_toolchain-source'
'tpkg-install' '_toolchain-source'
'tpkg-install-libc' '_toolchain-source'
'tpkg-make' '_toolchain-source'
'tpkg-update' '_toolchain-source'
'tracepath' '_tracepath'
'tracepath6' '_tracepath'
'traceroute' '_hosts'
'trap' '_trap'
'tree' '_tree'
'trial' '_twisted'
'true' '_nothing'
'tryaffix' '_ispell'
'ttyctl' '_ttyctl'
'tunctl' '_uml'
'tune2fs' '_tune2fs'
'tunes2pod' '_gnupod'
'tunes2pod.pl' '_gnupod'
'twidge' '_twidge'
'twistd' '_twisted'
'txt' '_hosts'
'type' '_which'
'typeset' '_typeset'
'ulimit' '_ulimit'
'uml_mconsole' '_uml'
'uml_moo' '_uml'
'uml_switch' '_uml'
'umount' '_mount'
'unace' '_unace'
'unalias' '_aliases'
'uname' '_uname'
'uncompress' '_compress'
'unexpand' '_unexpand'
'unfunction' '_functions'
'unget' '_sccs'
'unhash' '_unhash'
'uniq' '_uniq'
'unison' '_unison'
'units' '_units'
'unlimit' '_limits'
'unlzma' '_xz'
'unpack' '_pack'
'unrar' '_rar'
'unset' '_vars'
'unsetopt' '_unsetopt'
'unxz' '_xz'
'unzip' '_zip'
'update-alternatives' '_update-alternatives'
'update-rc.d' '_update-rc.d'
'upgradepkg' '_pkgtool'
'urpme' '_urpmi'
'urpmf' '_urpmi'
'urpmi' '_urpmi'
'urpmi.addmedia' '_urpmi'
'urpmi.removemedia' '_urpmi'
'urpmi.update' '_urpmi'
'urpmq' '_urpmi'
'urxvt' '_urxvt'
'urxvtc' '_urxvt'
'uscan' '_uscan'
'useradd' '_user_admin'
'userdel' '_users'
'usermod' '_user_admin'
'uzbl' '_uzbl'
'uzbl-browser' '_uzbl'
'uzbl-tabbed' '_uzbl'
'val' '_sccs'
'valgrind' '_valgrind'
'vared' '_vared'
'vcsh' '_vcsh'
'vim' '_vim'
'vim-addons' '_vim-addons'
'vimdiff' '_vim'
'vncserver' '_vnc'
'vncviewer' '_vnc'
'vorbiscomment' '_vorbiscomment'
'vserver' '_vserver'
'vux' '_vux'
'vuxctl' '_vux'
'w3m' '_w3m'
'wait' '_wait'
'wajig' '_wajig'
'wanna-build' '_wanna-build'
'wd' '_wd.sh'
'websetroot' '_twisted'
'wget' '_wget'
'what' '_sccs'
'whatis' '_man'
'whence' '_which'
'where' '_which'
'whereis' '_whereis'
'which' '_which'
'whoami' '_nothing'
'whois' '_whois'
'whom' '_mh'
'wiggle' '_wiggle'
'wodim' '_cdrecord'
'wpa_cli' '_wpa_cli'
'write' '_users_on'
'www' '_webbrowser'
'xargs' '_xargs'
'xauth' '_xauth'
'xclip' '_xclip'
'xdpyinfo' '_x_utils'
'xdvi' '_xdvi'
'xelatex' '_tex'
'xetex' '_tex'
'xev' '_x_utils'
'xfd' '_x_utils'
'xfig' '_xfig'
'xfontsel' '_x_utils'
'xhost' '_x_utils'
'xkill' '_x_utils'
'xli' '_xloadimage'
'xloadimage' '_xloadimage'
'xlsatoms' '_x_utils'
'xmllint' '_xmlsoft'
'xmms2' '_xmms2'
'xmodmap' '_xmodmap'
'xmosaic' '_webbrowser'
'xon' '_x_utils'
'xournal' '_xournal'
'xpdf' '_xpdf'
'xping' '_hosts'
'xprop' '_x_utils'
'xrandr' '_xrandr'
'xrdb' '_x_utils'
'xscreensaver-command' '_xscreensaver'
'xset' '_xset'
'xsetbg' '_xloadimage'
'xsetroot' '_x_utils'
'xsltproc' '_xmlsoft'
'xterm' '_xterm'
'xtightvncviewer' '_vnc'
'xtp' '_imagemagick'
'xv' '_xv'
'xview' '_xloadimage'
'xvnc4viewer' '_vnc'
'xvncviewer' '_vnc'
'xwd' '_x_utils'
'xwininfo' '_x_utils'
'xwit' '_xwit'
'xwud' '_x_utils'
'xz' '_xz'
'xzcat' '_xz'
'yast' '_yast'
'yast2' '_yast'
'ypbind' '_yp'
'ypcat' '_yp'
'ypmatch' '_yp'
'yppasswd' '_yp'
'yppoll' '_yp'
'yppush' '_yp'
'ypserv' '_yp'
'ypset' '_yp'
'ypwhich' '_yp'
'ypxfr' '_yp'
'ytalk' '_other_accounts'
'yum' '_yum'
'zargs' '_zargs'
'zathura' '_pspdf'
'zcat' '_zcat'
'zcompile' '_zcompile'
'zcp' '_zmv'
'zdelattr' '_zattr'
'zdump' '_zdump'
'zed' '_zed'
'zen' '_webbrowser'
'zfs' '_zfs'
'zgetattr' '_zattr'
'zip' '_zip'
'zipinfo' '_zip'
'zle' '_zle'
'zlistattr' '_zattr'
'zln' '_zmv'
'zlogin' '_zlogin'
'zmail' '_mail'
'zmodload' '_zmodload'
'zmv' '_zmv'
'zone' '_hosts'
'zoneadm' '_zoneadm'
'zpool' '_zpool'
'zpty' '_zpty'
'zsetattr' '_zattr'
'zsh' '_sh'
'zsh-mime-handler' '_zsh-mime-handler'
'zstat' '_stat'
'zstyle' '_zstyle'
'ztodo' '_ztodo'
'zxpdf' '_xpdf'
'zypper' '_zypper'
)

_services=(
'-redirect-,<,bunzip2' 'bunzip2'
'-redirect-,<,bzip2' 'bzip2'
'-redirect-,<,compress' 'compress'
'-redirect-,<,gunzip' 'gunzip'
'-redirect-,<,gzip' 'gzip'
'-redirect-,<,uncompress' 'uncompress'
'-redirect-,<,unxz' 'unxz'
'-redirect-,<,xz' 'xz'
'-redirect-,>,bzip2' 'bunzip2'
'-redirect-,>,compress' 'uncompress'
'-redirect-,>,gzip' 'gunzip'
'-redirect-,>,xz' 'unxz'
'Mail' 'mail'
'bzcat' 'bunzip2'
'dch' 'debchange'
'gnupod_INIT.pl' 'gnupod_INIT'
'gnupod_addsong.pl' 'gnupod_addsong'
'gnupod_check.pl' 'gnupod_check'
'gnupod_search.pl' 'gnupod_search'
'gzcat' 'gunzip'
'iceweasel' 'firefox'
'lzcat' 'unxz'
'lzma' 'xz'
'mailx' 'mail'
'mktunes.pl' 'mktunes'
'nail' 'mail'
'ncl' 'nc'
'nedit-nc' 'nc'
'pcat' 'unpack'
'remsh' 'rsh'
'slogin' 'ssh'
'svnadmin-static' 'svnadmin'
'tunes2pod.pl' 'tunes2pod'
'unlzma' 'unxz'
'xelatex' 'latex'
'xetex' 'tex'
'xzcat' 'unxz'
)

_patcomps=(
'*/(init|rc[0-9S]#).d/*' '_init_d'
'zf*' '_zftp'
)

_postpatcomps=(
'(p[bgpn]m*|*top[bgpn]m)' '_pbm'
'(texi(2*|ndex))' '_texi'
'(tiff*|*2tiff|pal2rgb)' '_tiff'
'*/X11(|R<4->)/*' '_x_arguments'
'-value-,(ftp|http(|s))_proxy,-default-' '_urls'
'-value-,*PATH,-default-' '_dir_list'
'-value-,*path,-default-' '_directories'
'-value-,LC_*,-default-' '_locales'
'-value-,RUBY(LIB|OPT|PATH),-default-' '_ruby'
'yodl(|2*)' '_yodl'
)

_compautos=(
'_call_program' '+X'
)

zle -C _bash_complete-word .complete-word _bash_completions
zle -C _bash_list-choices .list-choices _bash_completions
zle -C _complete_debug .complete-word _complete_debug
zle -C _complete_help .complete-word _complete_help
zle -C _complete_tag .complete-word _complete_tag
zle -C _correct_filename .complete-word _correct_filename
zle -C _correct_word .complete-word _correct_word
zle -C _expand_alias .complete-word _expand_alias
zle -C _expand_word .complete-word _expand_word
zle -C _history-complete-newer .complete-word _history_complete_word
zle -C _history-complete-older .complete-word _history_complete_word
zle -C _list_expansions .list-choices _expand_word
zle -C _most_recent_file .complete-word _most_recent_file
zle -C _next_tags .list-choices _next_tags
zle -C _read_comp .complete-word _read_comp
bindkey '^X^R' _read_comp
bindkey '^X?' _complete_debug
bindkey '^XC' _correct_filename
bindkey '^Xa' _expand_alias
bindkey '^Xc' _correct_word
bindkey '^Xd' _list_expansions
bindkey '^Xe' _expand_word
bindkey '^Xh' _complete_help
bindkey '^Xm' _most_recent_file
bindkey '^Xn' _next_tags
bindkey '^Xt' _complete_tag
bindkey '^X~' _bash_list-choices
bindkey '^[,' _history-complete-newer
bindkey '^[/' _history-complete-older
bindkey '^[~' _bash_complete-word

autoload -Uz _SuSEconfig _a2ps _a2utils _aap _acpi \
            _acpitool _acroread _adb _alias _aliases \
            _all_labels _all_matches _alternative _analyseplugin _ant \
            _antiword _apachectl _apm _approximate _apt \
            _apt-file _apt-move _apt-show-versions _aptitude _arch_archives \
            _arch_namespace _arg_compile _arguments _arp _arping \
            _arrays _assign _at _attr _auto-apt \
            _autocd _awk _axi-cache _bash_completions _baz \
            _be_name _beadm _bind_addresses _bindkey _bison \
            _bittorrent _bogofilter _brace_parameter _brctl _bsd_pkg \
            _btrfs _bts _bug _builtin _bundler \
            _bzip2 _bzr _cache_invalid _cal _calendar \
            _call_function _canonical_paths _ccal _cd _cdbs-edit-patch \
            _cdcd _cdr _cdrdao _cdrecord _chflags \
            _chkconfig _chmod _chown _chrt _clay \
            _combination _comm _command _command_names _compdef \
            _complete _complete_debug _complete_help _complete_help_generic _complete_tag \
            _compress _condition _configure _coreadm _correct \
            _correct_filename _correct_word _cowsay _cp _cpio \
            _cplay _cryptsetup _cssh _csup _ctags_tags \
            _cut _cvs _cvsup _cygcheck _cygpath \
            _cygrunsrv _cygserver _cygstart _dak _darcs \
            _date _dbus _dchroot _dchroot-dsa _dcop \
            _dd _deb_packages _debchange _debdiff _debfoster \
            _debsign _default _defaults _delimiters _describe \
            _description _devtodo _dhclient _dhcpinfo _dict \
            _dict_words _diff _diff_options _diffstat _dir_list \
            _directories _directory_stack _dirs _disable _dispatch \
            _django _dladm _dlocate _dmidecode _domains \
            _dpatch-edit-patch _dpkg _dpkg-buildpackage _dpkg-cross _dpkg-repack \
            _dpkg_source _dput _dtrace _du _dumpadm \
            _dumper _dupload _dvi _dynamic_directory_name _ecasound \
            _echotc _echoti _elinks _elm _email_addresses \
            _emulate _enable _enscript _env _equal \
            _espeak _ethtool _expand _expand_alias _expand_word \
            _extract _fakeroot _fc _feh _fetch \
            _fetchmail _ffmpeg _figlet _file_descriptors _file_systems \
            _files _find _finger _fink _first \
            _flasher _flex _floppy _flowadm _fmadm \
            _fortune _freebsd-update _fsh _fstat _functions \
            _fuse_arguments _fuse_values _fuser _fusermount _gcc \
            _gcore _gdb _gem _generic _genisoimage \
            _getclip _getconf _getent _getfacl _getmail \
            _git _git-branch _git-buildpackage _git-remote _github \
            _global _global_tags _globflags _globqual_delims _globquals \
            _gnome-gv _gnu_generic _gnupod _gnutls _go \
            _gpg _gphoto2 _gprof _gqview _gradle \
            _graphicsmagick _grep _grep-excuses _groff _groups \
            _growisofs _gs _guard _guilt _gv \
            _gzip _hash _have_glob_qual _hdiutil _hg \
            _history _history_complete_word _history_modifiers _hosts _hwinfo \
            _iconv _id _ifconfig _iftop _ignored \
            _imagemagick _in_vared _inetadm _init_d _initctl \
            _invoke-rc.d _ionice _ip _ipadm _ipset \
            _iptables _irssi _ispell _iwconfig _java \
            _java_class _jobs _jobs_bg _jobs_builtin _jobs_fg \
            _joe _join _kfmclient _kill _killall \
            _kld _knock _kvno _last _ldd \
            _less _lha _lighttpd _limit _limits \
            _linda _links _lintian _list _list_files \
            _ln _loadkeys _locales _locate _logical_volumes \
            _look _losetup _lp _ls _lscfg \
            _lsdev _lslv _lsof _lspv _lsusb \
            _lsvg _lynx _lzop _mac_applications _mac_files_for_application \
            _madison _mail _mailboxes _main_complete _make \
            _make-kpkg _man _man-preview _match _math \
            _matlab _md5sum _mdadm _members _mencal \
            _menu _mere _mergechanges _message _metaflac \
            _mh _mii-tool _mime_types _mkdir _mkshortcut \
            _mkzsh _module _module-assistant _modutils _mondo \
            _monotone _mosh _most_recent_file _mount _mozilla \
            _mpc _mplayer _mt _mtools _mtr \
            _multi_parts _mutt _my_accounts _mysql_utils _mysqldiff \
            _nautilus _ncftp _nedit _net_interfaces _netcat \
            _netscape _netstat _newsgroups _next_label _next_tags \
            _nice _nkf _nm _nmap _nmcli \
            _normal _nothing _notmuch _npm _nslookup \
            _object_classes _okular _oldlist _open _options \
            _options_set _options_unset _osc _other_accounts _pack \
            _parameter _parameters _patch _path_commands _path_files \
            _pax _pbm _pbuilder _pdf _pdftk \
            _pep8 _perforce _perl _perl_basepods _perl_modules \
            _perldoc _pfctl _pfexec _pgrep _php \
            _physical_volumes _pick_variant _pids _pine _ping \
            _pip _piuparts _pkg-config _pkg5 _pkg_instance \
            _pkgadd _pkginfo _pkgrm _pkgtool _pon \
            _portaudit _portlint _portmaster _ports _portsnap \
            _postfix _powerd _prcs _precommand _prefix \
            _print _printenv _printers _procstat _prompt \
            _prstat _ps _ps1234 _pscp _pspdf \
            _psutils _ptree _pump _putclip _pydoc \
            _pylint _python _qemu _qiv _qtplay \
            _quilt _raggle _rake _ranlib _rar \
            _rcs _read _read_comp _readshortcut _rebootin \
            _redirect _regex_arguments _regex_words _remote_files _renice \
            _reprepro _requested _retrieve_cache _retrieve_mac_apps _ri \
            _rlogin _rm _rpm _rpmbuild _rrdtool \
            _rsync _rubber _ruby _sablotron _samba \
            _savecore _sccs _sched _schedtool _schroot \
            _screen _sed _sep_parts _service _services \
            _set _set_command _setfacl _setopt _setup \
            _sh _showmount _signals _sisu _slrn \
            _smit _snoop _socket _sockstat _softwareupdate \
            _sort _source _spamassassin _sqlite _sqsh \
            _ssh _sshfs _stat _stgit _store_cache \
            _strace _strip _stty _su _sub_commands \
            _subscript _subversion _sudo _suffix_alias_files _surfraw \
            _svcadm _svccfg _svcprop _svcs _svcs_fmri \
            _svn-buildpackage _sysctl _systemd _tags _tar \
            _tar_archive _tardy _task _tcpdump _tcpsys \
            _tcptraceroute _telnet _terminals _tex _texi \
            _texinfo _tidy _tiff _tilde _tilde_files \
            _time_zone _tin _tla _tmux _todo.sh \
            _toilet _toolchain-source _topgit _totd _tpb \
            _tpconfig _tracepath _trap _tree _ttyctl \
            _tune2fs _twidge _twisted _typeset _ulimit \
            _uml _unace _uname _unexpand _unhash \
            _uniq _unison _units _unsetopt _update-alternatives \
            _update-rc.d _urls _urpmi _urxvt _uscan \
            _user_admin _user_at_host _user_expand _users _users_on \
            _uzbl _valgrind _value _values _vared \
            _vars _vcsh _vim _vim-addons _vnc \
            _volume_groups _vorbis _vorbiscomment _vserver _vux \
            _w3m _wait _wajig _wakeup_capable_devices _wanna-build \
            _wanted _wd.sh _webbrowser _wget _whereis \
            _which _whois _wiggle _wpa_cli _x_arguments \
            _x_borderwidth _x_color _x_colormapid _x_cursor _x_display \
            _x_extension _x_font _x_geometry _x_keysym _x_locale \
            _x_modifier _x_name _x_resource _x_selection_timeout _x_title \
            _x_utils _x_visual _x_window _xargs _xauth \
            _xclip _xdvi _xfig _xft_fonts _xloadimage \
            _xmlsoft _xmms2 _xmodmap _xournal _xpdf \
            _xrandr _xscreensaver _xset _xt_arguments _xt_session_id \
            _xterm _xv _xwit _xz _yast \
            _yast2 _yodl _yp _yum _zargs \
            _zattr _zcalc_line _zcat _zcompile _zdump \
            _zed _zfs _zfs_dataset _zfs_keysource_props _zfs_pool \
            _zftp _zip _zle _zlogin _zmodload \
            _zmv _zoneadm _zones _zpool _zpty \
            _zsh-mime-handler _zstyle _ztodo _zypper
autoload -Uz +X _call_program

typeset -gUa _comp_assocs
_comp_assocs=( '' )

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
GPG_AGENT_INFO=/tmp/gpg-uBHDhr/S.gpg-agent:23366:1
SSH_AUTH_SOCK=/tmp/gpg-vV8H2W/S.gpg-agent.ssh
SSH_AGENT_PID=23366

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
SSH_AUTH_SOCK=/var/folders/sh/m3c88fyn4x319133n00kjhg00000gn/T//ssh-gl6Lv3Rjnecu/agent.23373; export SSH_AUTH_SOCK;
SSH_AGENT_PID=23375; export SSH_AGENT_PID;
#echo Agent pid 23375;

# tidy up after ourselves
unfunction _plugin__start_agent
unset _plugin__forwarding
unset _plugin__ssh_env

# start fbterm automatically in /dev/tty*

if [[ $(tty|grep -o '/dev/tty') = /dev/tty ]] ; then
	fbterm
	exit
fi
/Users/W/-dotfiles/etc/zsh/oh-my-zsh/plugins/fbterm/fbterm.plugin.zsh:4: command not found: fbterm
