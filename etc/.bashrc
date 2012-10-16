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



if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\n\$ '
    unset color_prompt
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
esac

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    source /etc/bash_completion
fi

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

vimpager() {
    _PAGER="${HOME}/bin/vimpager"
    # enable vimpager if present
    if [ -x "$_PAGER" ]; then
        export PAGER="$_PAGER"
    fi
}

loadshellaliases() {


# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias lt='ls -altr'
alias l='ls -CF'
ggvim() {
    gvim $@ 2>&1 > /dev/null
}
alias sudovim="EDITOR='vim' sudoedit"
alias sudogvim="EDITOR='gvim' sudoedit"
alias fumount='fusermount -u'

alias xclip="xclip -selection c"
alias gitlog="git log --pretty=format:'%h : %an : %s' --topo-order --graph"
alias gitdiffstat="git diff -p --stat"
alias pyclean='find . -type f -name "*.py[co]" -exec rm -f \{\} \;'
alias sv='supervisorctl'
alias ssv='supervisord'
alias hgs='hg status'
alias hgl='hg log'
alias hgl10='hg log -l10'
alias spp='sudo puppetd -tv'
alias ifc='ifconfig'
}
loadshellaliases

alias less_='/usr/bin/less'
alias _less='/usr/bin/less'
less () {
    #start Vim with less.vim.
    # Read stdin if no arguments were given.
    if test -t 1; then
    if test $# = 0; then
    vim -c "let g:tinyvim=1" \
        --cmd "runtime! macros/less.vim" \
        --cmd "set nomod" \
        --cmd "set noswf" \
        -c "set colorcolumn=0" \
        -c "map <C-End> <Esc>G" \
        -
    else
    vim --noplugin \
        -c "let g:tinyvim=1" \
        -c "runtime! macros/less.vim" \
        --cmd "set nomod" \
        --cmd "set noswf" \
        -c "set colorcolumn=0" \
        -c "map <C-End> <Esc>G" \
        $@
    fi
    else
    # Output is not a terminal, cat arguments or stdin
    if test $# = 0; then
        less
    else
        less "$@"
    fi
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

h() {
    history $@
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
    printf "%-11s: %s ::: %s\n" "$TERM_ID" "`date +'%D %R.%S'`" "$1" >> $USRLOG
}

writelastcmd() {

    if [ -z "$HOLLDON" ]; then
        if [ -n "$VIRTUAL_ENV" ]; then
            USRLOG="${VIRTUAL_ENV}/.usrlog"
        else
            USRLOG="${HOME}/.usrlog"
        fi
    fi
    writehistline "$(history 1 | sed -e $TERM_SED_STR)";
}


set_usrlog_id() {
    # Set an explicit terminal name
    # param $1: terminal name
    RENAME_MSG="# Renaming $TERM_ID to $1 ..."
    echo $RENAME_MSG
    writehistline "$RENAME_MSG"
    TERM_ID="__$1"
    export TERM_ID
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
    cat $USRLOG | egrep "$1 .* \:\:\:|Renaming .* to $1" | \
        if [ $NO_STRIP_LINE_PREFIX -n ]; then
            sed -e 's/^\s*.*\:\:\:\s\(.*\)/\1/'
        else
            cat
        fi
}

usrlog() {
    # Bash profile setup for logging unique console sessions
    USRLOG="${1-$USRLOG}"
    if [ -z "$USRLOG" ]; then
        if [ -n "$VIRTUAL_ENV" ]; then
            USRLOG="${VIRTUAL_ENV}/.usrlog"
        else
            USRLOG="${HOME}/.usrlog"
        fi
    fi

    TERM_ID="$(randstr 8)"

    #TERM_SED_STR='s/^\s*[0-9]*\s\(.*\)/$TERM_ID: \1/'
    TERM_SED_STR='s/^\s*[0-9]*\s*//'

    echo "# Starting terminal session: $TERM_ID [$USRLOG]" >&2
    touch $USRLOG

    PROMPT_COMMAND="writelastcmd;" #$PROMPT_COMMAND"
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
            sed "s:$WORKON_HOME/\(.*\)/lib/python[0-9]\.[0-9]:\1:g"); do
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
