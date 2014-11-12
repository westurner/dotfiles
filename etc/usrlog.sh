#!/bin/sh
##  usrlog.sh -- REPL command logs in userspace (per $VIRTUAL_ENV)
#
#  _USRLOG (str): path to .usrlog file to which REPL commands are appended
#
#  _TERM_ID (str): a terminal identifier with which command loglines will
#  be appended (default: _usrlog_randstr)


_usrlog_set__USRLOG () {
    # _usrlog_set__USRLOG()    -- set $_USRLOG (and $__USRLOG)
    if [ -n "$VIRTUAL_ENV" ]; then
        prefix=${VIRTUAL_ENV}
    else
        prefix=${HOME}
    fi
    export _USRLOG="${prefix}/.usrlog"
    export __USRLOG="${HOME}/.usrlog"
}

_usrlog_set_HISTFILE () {
    # _usrlog_set_HISTFILE()   -- configure shell history
    if [ -n "$VIRTUAL_ENV" ]; then
        prefix=${VIRTUAL_ENV}
    else
        prefix=${HOME}
    fi

    #  history -a   -- append any un-flushed lines to $HISTFILE
    history -a
   
    if [ -n "$ZSH_VERSION" ]; then
        export HISTFILE="${prefix}/.zsh_history"
    elif [ -n "$BASH" ]; then
        export HISTFILE="${prefix}/.bash_history"
    else
        export HISTFILE="${prefix}/.history"
    fi

    #  history -c && history -r $HISTFILE   -- clear; reload $HISTFILE
    history -c && history -r $HISTFILE
}

_usrlog_set_HIST() {
    # _usrlog_set_HIST()    -- set shell $HIST<...> variables

    # see HISTSIZE and HISTFILESIZE in bash(1)
    HISTSIZE=1000
    HISTFILESIZE=1000000

    #avoid duplicating datetimes in .usrlog
    #HISTTIMEFORMAT="%Y-%m-%dT%H:%M:%S%z" (iso8601)
    HISTTIMEFORMAT=""

    #don't put duplicate lines in the history. See bash(1) for more options
    # ... or force ignoredups and ignorespace
    # HISTCONTROL=ignoredups:ignorespace
    HISTCONTROL=ignoredups:ignorespace

    # append current lines to history
    history -a

    _usrlog_set_HISTFILE

    if [ -n "$BASH" ] ; then
        # append to the history file, don't overwrite it
        shopt -s histappend > /dev/null 2>&1
        # replace newlines with semicolons
        shopt -s cmdhist > /dev/null 2>&1

        # enable autocd (if available)
        shopt -s autocd > /dev/null 2>&1
    elif [ -n "$ZSH_VERSION" ]; then
        setopt APPEND_HISTORY
        setopt EXTENDED_HISTORY
    fi

}

_usrlog_randstr() {
    # _usrlog_randstr      -- Generate a random string
    #   $1: number of characters

    if [[ `uname -s` == "Darwin" ]]; then
        echo $(dd if=/dev/urandom bs=1 count=$1 2>/dev/null |
                base64 -b 0 |
                rev |
                cut -b 2- |
                tr '/+' '0' |
                rev)
    else
        echo $(dd if=/dev/urandom bs=1 count=$1 2>/dev/null |
                base64 -w 0 |
                rev |
                cut -b 2- |
                tr '/+' '0' |
                rev)
            fi
}

_usrlog_get__TERM_ID() {
    # _usrlog_get__TERM_ID()   -- echo the current _TERM_ID and $_USRLOG
    echo "# _TERM_ID="$_TERM_ID" # [ $_USRLOG ]" >&2
    echo $_TERM_ID
}


_usrlog_set__TERM_ID () {
    # _usrlog_Set__TERM_ID     -- set or randomize the $_TERM_ID key
    #   $1: terminal name
    new_term_id="${@}"
    if [ -z "${new_term_id}" ]; then
        new_term_id="#$(_usrlog_randstr 8)"
    fi
    if [[ "${new_term_id}" != "${_TERM_ID}" ]]; then
        if [ -z "${_TERM_ID}" ]; then
            RENAME_MSG="# new_term_id ::: ${new_term_id} [ ${_USRLOG} ]"
        else
            RENAME_MSG="# set_term_id ::: ${_TERM_ID} -> ${new_term_id} [ ${_USRLOG} ]"
        fi
        echo $RENAME_MSG
        _usrlog_append "$RENAME_MSG"
        export _TERM_ID="${new_term_id}"
        _usrlog_set_title

        declare -f '_venv_set_prompt' 2>&1 > /dev/null \
            && _venv_set_prompt
    fi
}

_usrlog_echo_title () {
    # _usrlog_echo_title   -- set window title
    _usrlog_window_title="${WINDOW_TITLE:+"$WINDOW_TITLE "}${VIRTUAL_ENV_NAME:+"($VIRTUAL_ENV_NAME) "}${USER}@${HOSTNAME}:${PWD}"
    usrlog_window_title=${_usrlog_window_title:-"$@"}
    if [ -n $CLICOLOR ]; then
        echo -ne "\033]0;${usrlog_window_title}\007"
    else
        echo -ne "${usrlog_window_title}"
    fi
}

_usrlog_set_title() {
    # _usrlog_set_title()  --  set xterm title
    export WINDOW_TITLE=${1:-"$_TERM_ID"}
    _usrlog_echo_title
}

_usrlog_setup() {
    # _usrlog_setup()      -- configure usrlog for the current shell
    _usrlog="${1:-$_USRLOG}"
    term_id="${2:-$_TERM_ID}"

    _usrlog_set_HIST

    _usrlog_set__USRLOG $_usrlog

    #TERM_SED_STR='s/^\s*[0-9]*\s\(.*\)/$_TERM_ID: \1/'
    TERM_SED_STR='s/^\s*[0-9]*\s*//'

    _usrlog_set__TERM_ID $term_id
    touch $_USRLOG

    _usrlog_set_title $_TERM_ID

    # setup bash
    if [ -n "$BASH" ]; then
        PROMPT_COMMAND="_usrlog_writecmd; _usrlog_echo_title;"
    fi

    # setup zsh
    if [ -n "$ZSH_VERSION" ]; then
        precmd_functions=(_usrlog_writecmd _usrlog_echo_title)
    fi
}

_usrlog_append() {
    # _usrlog_append()  -- Write a line to $_USRLOG w/ an ISO8601 timestamp 
    #   $1: text (command) to log
    #   note: _TERM_ID must not contain a tab character (tr '\t' ' ')
    #   note: _TERM_ID can be a URN, URL, URL, or simple \w+ str key
    # example:
    # #ZbH08n8unY8	2014-11-11T12:27:22-0600	 2238  ls
    printf "%s\t%s\t%s\n" \
        $(echo "${_TERM_ID}" | tr '\t' ' ') \
        "$(date +%Y-%m-%dT%H:%M:%S%z)" \
        "${*}" \
            | tee -a $_USRLOG >&2
}

_usrlog_append_oldstyle() {
    # _usrlog_append_oldstype -- Write a line to $_USRLOG
    #   $1: text (command) to log
    # example:
    # # qMZwZSGvJv8: 10/28/14 17:25.54 :::   522  histgrep BUG
    printf "# %-11s: %s : %s" \
        "$_TERM_ID" \
        "$(date +'%D %R.%S')" \
        "${1:-'\n'}" \
            | tee -a $_USRLOG >&2
}

_usrlog_writecmd() {
    # _usrlog_writecmd()    -- write the most recent command to $_USRLOG
    _usrlog_set_HISTFILE

    if [ -n "$ZSH_VERSION" ]; then
        id 2>&1 > /dev/null
        _cmd=$(fc -l -1 | sed -e $TERM_SED_STR)
    elif [ -n "$BASH" ]; then
        _cmd=$(history 1 | sed -e $TERM_SED_STR)
    else
        _cmd=$(history 1 | sed -e $TERM_SED_STR)
    fi
    _usrlog_append "${_cmd}"
}



## usrlog.sh API



termid() {
    # termid()      -- echo $_TERM_ID
    _usrlog_get__TERM_ID
}


set_term_id() {
    # set_term_id() -- set $_TERM_ID to a randomstr or $1
    _usrlog_set__TERM_ID $@
}

stid() {
    # stid()        -- set $_TERM_ID to a randomstr or $1
    _usrlog_set__TERM_ID $@
}
st() {
    # st()          -- set $_TERM_ID to a randomstr or $1
    _usrlog_set__TERM_ID $@
}


## Old (hist, histgrep, histgrep_session)

hist() {
    # less()       --  less the current session log
    less $_USRLOG
}


histgrep () {
    # histgrep()   -- egrep $@ $_USRLOG
    egrep $@ $_USRLOG 
}

histgrep_session () {
    # histgrep_session()    -- grep for specific sessions
    #   $1: session name
    #   $2: don't strip the line prefix
    NO_STRIP_LINE_PREFIX=$2
    #echo $_USRLOG >&2
    cat $_USRLOG | egrep "$1 .* \:\:\:|Renaming .* to $1" | \
        if [ -n $NO_STRIP_LINE_PREFIX ]; then
            sed -e 's/^\s*.*\:\:\:\s\(.*\)/\1/'
        else
            cat
        fi
}

## New (u*, usrlog*)

usrlog_tail() {
    # usrlogt()     -- tail -n20 $_USRLOG
    if [ -n "$@" ]; then
        _usrlog=${@:-${_USRLOG}}
        tail ${_usrlog} 
    else
        tail $_USRLOG
    fi
}
ut() {
    # ut()          -- tail -n20 $_USRLOG
    usrlog_tail ${@}
}


usrlog_tail_follow() {
    # usrlogtf()    -- tail -f -n20 $_USRLOG
    tail -f -n20 ${@:-"${_USRLOG}"}
}
utf() {
    # utf()         -- tail -f -n20 $_USRLOG
    usrlog_tail_follow $@
}


usrlog_grep() {
    # usrlog_grep() -- egrep -n $_USRLOG
    set -x
    args=${@}
    egrep -n "${args}" ${_USRLOG}
    set +x
}
ug() {
    # ug()          -- egrep -n $_USRLOG
    usrlog_grep ${@}
}

usrlog_grin() {
    # usrlog_grin() -- grin -s $@ $_USRLOG
    set -x
    args=${@}
    grin -s "${args}" ${_USRLOG}
    set +x
}
ugrin () {
    # ugrin()       -- grin -s $@ $_USRLOG
    usrlog_grin ${@}
}

lsusrlogs() {
    # lsusrlogs()   -- ls $__USRLOG ${WORKON_HOME}/*/.usrlog
    ls -tr "${__USRLOG}" ${WORKON_HOME}/*/.usrlog
}

usrlog_grep_all() {
    # usrlog_grep_all()    -- grep usrlogs (drop filenames with -h)
    (set -x;
    args=${@}
    usrlogs=$(lsusrlogs)
    egrep "${args}" ${usrlogs} )
}
ugall() {
    # ugall()              -- grep usrlogs (drop filenames with -h)
    usrlog_grep_all ${@}
}

usrlog_grin_all() {
    # usrlog_grin_all()    -- grin usrlogs
    (set -x;
    args=${@}
    usrlogs=$(lsusrlogs)
    grin -s "${args}" ${usrlogs} )
}
ugrinall() {
    # usrlog_grin_all()    -- grin usrlogs
    usrlog_grin_all ${@}
}

note() {
    # note()   -- _usrlog_append "#note  #note: $@"
    _usrlog_append "#note  #note: $@"
}


usrlog_screenrec_ffmpeg() {
    # usrlog_screenrec_ffmpeg() -- record a screencast
    #   $1: destination directory (use /tmp if possible)
    #   $2: video name to append to datestamp
    # Press "q" to stop recording
    DATESTR=$(date +%Y%m%d-%H%M)
    FILEBASE="screenrec-${DATESTR}"
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


## calls _usrlog_setup when sourced
_usrlog_setup
