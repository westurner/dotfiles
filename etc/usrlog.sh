## Consolidated SHELL log
# Generates $(source) invocation _randstr per-invocation

HISTFILE='~/.bash_history'

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=1000000

# avoid duplicating datetimes in .usrlog
HISTTIMEFORMAT=""

h() {
    # history 10    -- list last 10 lines
    history $@
}

_randstr() {
    # Generate a random string
    # param $1: number of characters

    if [ `uname -s` == "Darwin" ]; then
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

_get_term_id() {
    echo "# term_id ::: $TERM_ID [ $_USRLOG ]" 
}

termid() {
    _get_term_id
}

_set_term_id () {
    # Set an explicit terminal name
    # param $1: terminal name
    new_term_id="${1:-$(_randstr 8)}"
    RENAME_MSG="# set_term_id ::: $TERM_ID -> $new_term_id [ $_USRLOG ]"
    echo $RENAME_MSG
    _writehist "$RENAME_MSG"
    export TERM_ID="${new_term_id}"
}

stid () {
    # Shortcut alias to _set_term_id
    _set_term_id $@
    _get_term_id
}

_set_usrlog () {
    _USRLOG="${1:${_USRLOG}}"
    if [ -n "$VIRTUAL_ENV" ]; then
        declare -gx _USRLOG="${VIRTUAL_ENV}/.usrlog"
        declare -gx HISTFILE="${VIRTUAL_ENV}/.bash_history"
    else
        declare -gx _USRLOG="${HOME}/.usrlog"
        declare -gx HISTFILE="~/.bash_history"
    fi
}


hist() {
    # Alias to less the current session log
    less $_USRLOG
}


histgrep () {
    grep "$@" $_USRLOG 
}

histgrep_session () {
    # Grep for specific sessions
    # param $1: session name
    # param $2: don't strip the line prefix
    NO_STRIP_LINE_PREFIX=$2
    #echo $_USRLOG >&2
    cat $_USRLOG | egrep "$1 .* \:\:\:|Renaming .* to $1" | \
        if [ -n $NO_STRIP_LINE_PREFIX ]; then
            sed -e 's/^\s*.*\:\:\:\s\(.*\)/\1/'
        else
            cat
        fi
}

_writehist() {
    # Write a line to the _USRLOG file
    # param $1: text (command) to log
    printf "%-11s: %s ::: %s\n" \
        "$TERM_ID" \
        "$(date +'%D %R.%S')" \
        "${1:-'\n'}" | tee -a $_USRLOG >&2
}

_writecmd() {
    if [ -z "$HOLLDON" ]; then
        _set_usrlog
    fi
    _writehist "$(history 1 | sed -e $TERM_SED_STR)";
}


_setup_usrlog() {
    # Bash profile setup for logging unique console sessions
    _USRLOG="${1-$_USRLOG}"
    term_id="${2-$TERM_ID}"
    if [ -z "$_USRLOG" ]; then
        _set_usrlog
    fi

    TERM_ID="${term_id:-$(_randstr 8)}"

    #TERM_SED_STR='s/^\s*[0-9]*\s\(.*\)/$TERM_ID: \1/'
    TERM_SED_STR='s/^\s*[0-9]*\s*//'

    _get_term_id
    touch $_USRLOG

    # execute PROMPT_COMMAND for all shell commands
    export PROMPT_COMMAND="_writecmd;" #$PROMPT_COMMAND"
}

screenrec() {
    # Record the screen
    # param $1: destination directory (use /tmp if possible)
    # param $2: video name to append to datestamp

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
