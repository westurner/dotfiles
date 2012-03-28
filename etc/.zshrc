# ~/.zshrc

# References:
#  - http://en.gentoo-wiki.com/wiki/Zsh
#  - https://wiki.archlinux.org/index.php/Zsh  
#  - http://my.opera.com/blu3c4t/blog/moving-from-bash-to-zsh 


# If not running interactively, don't do anything
if [ -z "$PS1" ]; then
    return
fi

unsetopt beep
#setopt VI

# zsh histfile
export HISTFILE=~/.histfile
export HISTSIZE=1000
export SAVEHIST=2000
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_SPACE
#setopt SHARE_HISTORY
h() { history $@ }

# Globbing
setopt EXTENDEDGLOB
setopt NO_CASE_GLOB

# Sanity
setopt RM_STAR_WAIT
setopt PRINT_EXIT_VALUE

# Colors
zmodload -a colors

# zsh features
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

autoload zmv

# Tab completion
autoload -Uz compinit
compinit
zmodload -a complist
zmodload -a autocomplete
setopt completealiases
setopt COMPLETE_IN_WORD

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors 'reply=( "=(#b)(*$VAR)(?)*=00=$color[green]=$color[bg-green]" )'
zstyle ':completion:*:*:*:*:hosts' list-colors '=*=30;41'
zstyle ':completion:*:*:*:*:users' list-colors '=*=$color[green]=$color[red]'
#zstyle ':completion:*' list-colors ''

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
###shopt -s checkwinsize

# Prompt
setopt TRANSIENT_RPROMPT
autoload -U promptinit
promptinit
prompt adam2
#PROMPT='[%d]%% '
#PS1=$'%{\e[1;34m%}%n@%{\e[1;32m%}%m %{\e[1;36m%}%1d %{\e[1;36m%}%{\e[0m%}\n%# '
#RPROMPT='(%T - %D)'


# set window title on chpwd (cd)
chpwd() {
  [[ -o interactive ]] || return
  case $TERM in
    sun-cmd) print -Pn "\e]l%~\e\\"
      ;;
    *xterm*|rxvt|(dt|k|E)term) print -Pn "\e]2;%n@%M: %~\a"
      ;;
  esac
}

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh /usr/bin/lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

export TERM=rxvt

#  alt-u            -- chdir to parent directory
bindkey -s "\eu" "^Ucd ..; ls^M"
#  alt-p            -- if AUTO_PUSHD is set, pop the dir stack
bindkey -s "\ep" "^Upopd >/dev/null; dirs -v^M"
#  alt-l            -- pipe the current command through less
bindkey -s "\el" " 2>&1|less^M"
#  alt-s            -- insert sudo at beginning of line
insert_sudo () { zle beginning-of-line; zle -U "sudo " }
zle -N insert-sudo insert_sudo
bindkey -s "\es" insert-sudo
#  alt-n            -- nautilus <here>
nautilus () {
    path=${1:-"."}
    [[ path = "." ]] && shift 
    nautilus $path $@
}
bindkey -s "\en" nautilus"^M"

loadshellaliases() {
    # some more ls aliases
    alias ll='ls -alF'
    alias la='ls -A'
    alias lt='ls -altr'
    alias l='ls -CF'
    #alias vim="~/bin/vim"
    alias sudovim="EDITOR=vim sudoedit"
    alias fumount='fusermount -u'
    alias less='~/bin/less.sh'
    alias less_='/usr/bin/less'
    alias xclip="xclip -selection c"
    alias gitlog="git log --pretty=format:'%h : %an : %s' --topo-order --graph"
    alias gitdiffstat="git diff -p --stat"
    alias pyclean='find . -type f -name "*.py[co]" -exec rm -f \{\} \;'
    if [ -x /usr/bin/dircolors ]; then
        #test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        alias ls='ls --color=auto'
        #alias dir='dir --color=auto'
        #alias vdir='vdir --color=auto'
        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
    fi
}
loadshellaliases

# Get completion above command line
setopt NOALWAYSLASTPROMPT
setopt NOAUTO_REMOVE_SLASH
setopt LIST_TYPES
unlimit

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

###
### Misc completion control
###

# Manual page completion
man_glob () {
  local a
  read -cA a
  if [[ $a[2] = [0-9]* ]] then	# BSD section number
    reply=( $^manpath/man$a[2]/$1*$2(N:t:r) )
  elif [[ $a[2] = -s ]] then	# SysV section number
    reply=( $^manpath/man$a[3]/$1*$2(N:t:r) )
  else
    reply=( $^manpath/man*/$1*$2(N:t:r) )
  fi
}
compctl -K man_glob man

# Complete commmands after .
compctl -c .



# vimpager setup
vimpager() {
    _PAGER="${HOME}/bin/vimpager"
    # enable vimpager if present
    if [ -x "$_PAGER" ]; then
        export PAGER="$_PAGER"
    fi
}

# view manpages in vim
alias man_="/usr/bin/man"
man() {

    if [ $# -eq 0 ]; then
        /usr/bin/man
    else
        #if [ "$1" == "man" ]; then
        #    exit 0
        #fi

        #/usr/bin/whatis "$@" >/dev/null
        vim --noplugin \
            -c "runtime ftplugin/man.vim" \
            -c "Man $*" \
            -c 'silent! only' \
            -c 'nmap q :q<CR>' \
            -c 'set nomodifiable'
    fi
}


randstr() {
    # Generate a random string
    # param $1: number of characters
    echo $(dd if=/dev/urandom bs=1 count=$1 2>/dev/null |
            base64 -w 0 |
            rev |
            cut -b 2- |
            tr '/+' '0' |
            rev)
}

writehistline() {
    # Write a line to the USRLOG file
    # param $1: text (command) to log
    printf "%-11s: %s ::: " "${TERM_ID}" "$(/bin/date +'%D %R.%S')" >> ${USRLOG}
    printf "%s\n" "${1}" >> ${USRLOG}
}

writelastcmd() {

    if [ -z "$HOLLDON" ]; then
        if [ -n "$VIRTUAL_ENV" ]; then
            export USRLOG="${VIRTUAL_ENV}/.usrlog"
        else
            export USRLOG="${HOME}/.usrlog"
        fi
    fi
    writehistline "$(history 1 | /bin/sed -e $TERM_SED_STR)";
}


set_usrlog_id() {
    # Set an explicit terminal name
    # param $1: terminal name
    RENAME_MSG="# Renaming $TERM_ID to $1 ..."
    echo $RENAME_MSG
    writehistline "$RENAME_MSG"
    export TERM_ID="__$1"
}

stid() {
    # Shortcut alias to set_usrlog_id
    set_usrlog_id $@
}

hist() {
    # Alias to less the current session log
    less -c 'set nomodifiable' $USRLOG
}

histgrep() {
    # Grep for specific sessions
    # param $1: session name
    # param $2: don't strip the line prefix
    NO_STRIP_LINE_PREFIX=$2
    echo $USRLOG >&2
    cat "${USRLOG}" | egrep "$1 .* \:\:\:|Renaming .* to $1" | \
        if [ $NO_STRIP_LINE_PREFIX -n ]; then
            sed -e 's/^\s*.*\:\:\:\s\(.*\)/\1/'
        else
            cat
        fi
}

usrlog() {
    # Bash profile setup for logging unique console sessions
    export USRLOG="${1:-$USRLOG}"
    if [ -z "$USRLOG" ]; then
        if [ -n "$VIRTUAL_ENV" ]; then
            export USRLOG="${VIRTUAL_ENV}/.usrlog"
        else
            export USRLOG="${HOME}/.usrlog"
        fi
    fi

    export TERM_ID="$(randstr 8)"

    #TERM_SED_STR='s/^\s*[0-9]*\s\(.*\)/$TERM_ID: \1/'
    export TERM_SED_STR='s/^\s*[0-9]*\s*//'

    echo "# Starting terminal session: $TERM_ID [$USRLOG]" >&2
    touch $USRLOG

    #PROMPT_COMMAND="writelastcmd;" #$PROMPT_COMMAND"
    precmd() {
        writelastcmd
    }
}

if [ -z "$HOLLDON" ]; then
    usrlog
fi

screenrec() {
    # Record the screen
    # param $1: destination directory (use /tmp if possible)
    # param $2: video name to append to datestamp

    # Press "q" to stop recording

    FILEBASE="screenrec-`date +%Y%m%d-%H%M`"
    if [ -z "$2" ]; then
        FILENAME="$1/${FILEBASE}_unnamed.mpg"
    else
        FILENAME="$1/${FILEBASE}_${2}.mpg"
    fi

    SCREENDIM="$(xdpyinfo | grep 'dimensions:'| awk '{print $2}')"
    ffmpeg \
        -f x11grab \
        -s "$SCREENDIM" \
        -r 25
        -i 0:0 \
        -sameq "$FILENAME" \
            2>&1 | tee "$FILENAME.log"
}


#add_to_path ()
#{
    ## http://superuser.com/questions/ \
    ##   39751/add-directory-to-path-if-its-not-already-there/39840#39840
    #if [[ "$PATH" =~ (^|:)"${1}"(:|$) ]]
    #then
        #return 0
    #fi
    #export PATH=$1:$PATH
#}

# See .profile
# DOTFILES="${HOME}/.dotfiles"
#if [ -d "${DOTFILES}" ]; then
#    add_to_path "${DOTFILES}/bin:${PATH}"
#fi

e() {
    echo $@
}

pythonsetup() {
    # Python
    export PYTHONSTARTUP="${HOME}/.pythonrc"
    #alias ipython="python -c 'import IPython;IPython.Shell.IPShell().mainloop()'"

    export WORKON_HOME="${HOME}/workspace/.virtualenvs"
    _VENVW="/usr/local/bin/virtualenvwrapper.sh"
    source "$_VENVW"

    lsvirtualenv() {
        cmd="${1-echo}"
        for venv in $(ls -adtr "${WORKON_HOME}"/**/lib/python?.? | \
            /bin/sed "s:$WORKON_HOME/\(.*\)/lib/python[0-9]\.[0-9]:\1:g"); do
            $cmd $venv/
        done
    }

    pypath() {
        /usr/bin/env python -c "import sys; print '\n'.join(sys.path)"
    }
}

EDITOR="${EDITOR:-"vim -g"}"
_EDITCMD="${EDITOR}"
_EDITMANYCMD="${EDITCMD} -p"


_newshell() {
    _PATH="$1"
    shift
    _CMD=$2

    gnome-terminal --working-directory="${_PATH}" \
            --tab \
            -t "${_CMD}" \
            -e "bash -c \"source ~/.bashrc; ${_VENVCMD}; cdvirtualenv; ${_CMD}; exec bash; read \""

}

workon_pyramid_app() {
    _VENVNAME=$1
    _APPNAME=$2

    _OPEN_TERMS=${3:-""}

    _VENVCMD="workon ${_VENVNAME}"
    workon "${_VENVNAME}"
    _VENV="${VIRTUAL_ENV}"

    export _SRC="${_VENV}/src"
    export _BIN="${_VENV}/bin"
    export _EGGSRC="${_SRC}/${_APPNAME}"
    export _EGGSETUPPY="${_EGGSRC}/setup.py"
    export _EGGCFG="${_EGGSRC}/development.ini"

    _EDITCFGCMD="${_EDITCMD} ${_EGGCFG}"
    _SHELLCMD="${_BIN}/pshell ${_EGGCFG}"
    _SERVECMD="${_BIN}/pserve --reload --monitor-restart ${_EGGCFG}"
    _TESTCMD="python ${_EGGSETUPPY} nosetests"

    # aliases
    alias _serve="${_SERVECMD}"
    alias _shell="${_SHELLCMD}"
    alias _test="${_TESTCMD}"
    alias _editcfg="${_EDITCFGCMD}"
    alias _glog="hgtk -R "${_EGGSRC}" log"
    alias _log="hg -R "${_EGGSRC}" log"

    alias cdsrc="cd ${_SRC}"
    alias cdbin="cd ${_BIN}"
    alias cdeggsrc="cd ${_EGGSRC}"


    # cd to $_PATH
    cd "${_EGGSRC}"

    if [ "${_OPEN_TERMS}" != "" ]; then
        # open editor
        ${_EDITCMD} "${_EGGSRC}" &
        # open tabs
        #gnome-terminal \
        #    --working-directory="${_EGGSRC}" \
        #    --tab -t "${_APPNAME} serve" -e "bash -c \"${_SERVECMD}; bash -c \"workon_pyramid_app $_VENVNAME $_APPNAME 1\"\"" \
        #    --tab -t "${_APPNAME} shell" -e "bash -c \"${_SHELLCMD}; bash\"" \
        #    --tab -t "${_APPNAME} bash" -e "bash"
    fi
}


pythonsetup
