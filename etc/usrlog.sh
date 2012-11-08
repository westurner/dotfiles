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
HISTFILESIZE=2000

h() {
    # history 10    -- list last 10 lines
    history $@
}

_randstr() {
    # Generate a random string
    # param $1: number of characters
    echo $(dd if=/dev/urandom bs=1 count=$1 2>/dev/null |
            base64 -w 0 |
            rev |
            cut -b 2- |
            tr '/+' '0' |
            rev)
}

_get_term_id() {
    echo "# term_id ::: $TERM_ID [ $USRLOG ]" 
}

termid() {
    _get_term_id
}

_set_term_id () {
    # Set an explicit terminal name
    # param $1: terminal name
    new_term_id="${1:-$(_randstr 8)}"
    RENAME_MSG="# set_term_id ::: $TERM_ID -> $new_term_id [ $USRLOG ]"
    echo $RENAME_MSG
    _writehist "$RENAME_MSG"
    export TERM_ID="${new_term_id}"
}

stid () {
    # Shortcut alias to _set_term_id
    _set_term_id $@
    _get_term_id
}

_usrlog () {
    USRLOG="${1:${USRLOG}}"
    if [ -n "$VIRTUAL_ENV" ]; then
        USRLOG="${VIRTUAL_ENV}/.usrlog"
    else
        USRLOG="${HOME}/.usrlog"
    fi
    export USRLOG
}


hist() {
    # Alias to less the current session log
    less $USRLOG
}


histgrep () {
    grep "$@" $USRLOG 
}

histgrep_session () {
    # Grep for specific sessions
    # param $1: session name
    # param $2: don't strip the line prefix
    NO_STRIP_LINE_PREFIX=$2
    #echo $USRLOG >&2
    cat $USRLOG | egrep "$1 .* \:\:\:|Renaming .* to $1" | \
        if [ -n $NO_STRIP_LINE_PREFIX ]; then
            sed -e 's/^\s*.*\:\:\:\s\(.*\)/\1/'
        else
            cat
        fi
}

_writehist() {
    # Write a line to the USRLOG file
    # param $1: text (command) to log
    printf "%-11s: %s ::: %s\n" \
        "$TERM_ID" \
        "$(date +'%D %R.%S')" \
        "$1" >> $USRLOG
}

_writecmd() {
    if [ -z "$HOLLDON" ]; then
        _usrlog
    fi
    _writehist "$(history 1 | sed -e $TERM_SED_STR)";
}


_setup_usrlog() {
    # Bash profile setup for logging unique console sessions
    USRLOG="${1-$USRLOG}"
    term_id="${2-$TERM_ID}"
    if [ -z "$USRLOG" ]; then
        _usrlog
    fi

    TERM_ID="${term_id:-$(_randstr 8)}"

    #TERM_SED_STR='s/^\s*[0-9]*\s\(.*\)/$TERM_ID: \1/'
    TERM_SED_STR='s/^\s*[0-9]*\s*//'

    _get_term_id
    touch $USRLOG

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
