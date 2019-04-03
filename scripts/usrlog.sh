#!/usr/bin/env bash
### usrlog.sh -- Shell CLI REPL command logs in userspace (per $VIRTUAL_ENV)
#
#  Log shell commands with metadata as tab-separated lines to ${_USRLOG}
#  with a shell identifier to differentiate between open windows,
#  testing/screencast flows, etc
#
#  By default, _USRLOG will be set to a random string prefixed with '#'
#  by the `stid()` bash function (`_usrlog_set__TERM_ID()`)
#
#  * _TERM_ID can be set to any string;
#  * _TERM_ID is displayed in the PS1 prompt
#  * _TERM_ID is displayed in the window title
#  * _TERM_ID is reset to __TERM_ID upon 'deactivate'
#    (westurner/dotfiles//etc/bash/07-bashrc.virtualenvwrapper.sh:
#     TODO: virtualenvwrapper, conda)
#
#  Environment Variables:
#
#   __USRLOG (str): default -usrlog.log file (~/-usrlog.log)
#   _USRLOG  (str): current -usrlog.log file to append REPL command strings to
#   _TERM_ID (str): a terminal identifier with which command loglines will
#                   be appended (default: _usrlog_randstr)
#

function _usrlog_get_prefix  {
    #  _usrlog_get_prefix()    -- get a dirpath for the current usrlog
    #                             (VIRTUAL_ENV or HOME)
    local prefix="${VENVPREFIX:-${VIRTUAL_ENV:-${HOME}}}"
    if [ "${prefix}" == "/" ]; then
        prefix=$HOME
    fi
    echo "$prefix"
}

function _usrlog_set__USRLOG  {
    #  _usrlog_set__USRLOG()    -- set $_USRLOG (and $__USRLOG)
    export __USRLOG="${HOME}/-usrlog.log"
    prefix="$(_usrlog_get_prefix)"
    export _USRLOG="${prefix}/-usrlog.log"

}

function _usrlog_set_HISTFILE  {
    #  _usrlog_set_HISTFILE()   -- configure shell history
    local prefix="$(_usrlog_get_prefix)"

    if [ -n "${BASH}" ]; then
        #   history -a   -- append any un-flushed lines to $HISTFILE
        history -a
    fi

    # set/touch HISTFILE
    set HISTFILE
    #   history -c && history -r $HISTFILE   -- clear; reload $HISTFILE

    if [ -n "${ZSH_VERSION}" ]; then
        # ZSH_VERSION
        export HISTFILE="${prefix}/.zsh_history"
    elif [ -n "${BASH}" ]; then
        export HISTFILE="${prefix}/.bash_history"
    else
        export HISTFILE="${prefix}/.history"
    fi

    if [ -n "${BASH}" ]; then
        history -c && history -r "${HISTFILE}"
    fi
}

function _usrlog_set_HIST {
    #  _usrlog_set_HIST()    -- set shell $HIST<...> variables

    #  see HISTSIZE and HISTFILESIZE in bash(1)
    HISTSIZE=1000
    HISTFILESIZE=1000000

    #avoid duplicating datetimes in .usrlog
    #HISTTIMEFORMAT="%Y-%m-%dT%H:%M:%S%z" (iso8601)
    #HISTTIMEFORMAT="%t%Y-%m-%dT%H:%M:%S%z%t"
    #  note that HOSTNAME and USER come from the environ
    #  and MUST be evaluated at the time HISTTIMEFORMAT is set.
    HISTTIMEFORMAT="%t%Y-%m-%dT%H:%M:%S%z%t${HOSTNAME}%t${USER}%t\$\$%t"  #  %n  "

    #don't put duplicate lines in the history. See bash(1) for more options
    #  ... or force ignoredups and ignorespace
    #  HISTCONTROL=ignoredups:ignorespace
    HISTCONTROL=ignoredups:ignorespace

    _usrlog_set_HISTFILE

    if [ -n "$ZSH_VERSION" ]; then
        setopt APPEND_HISTORY
        setopt EXTENDED_HISTORY
    elif [ -n "$BASH" ] ; then
        #  append current lines to history
        history -a

        #  append to the history file, don't overwrite it
        #  https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html#The-Shopt-Builtin
        shopt -s histappend > /dev/null 2>&1
        #  replace newlines with semicolons
        shopt -s cmdhist > /dev/null 2>&1
        shopt -s lithist > /dev/null 2>&1

        #  enable autocd (if available)
        shopt -s autocd > /dev/null 2>&1
    fi
}

function _usrlog_randstr {
    #  _usrlog_randstr      -- Generate a random string
    #    $1: number of characters

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

function _usrlog_get__TERM_ID {
    #  _usrlog_get__TERM_ID()   -- echo the current _TERM_ID and $_USRLOG
    echo "#  _TERM_ID="$_TERM_ID" # [ $_USRLOG ]" >&2
    echo $_TERM_ID
}

function _usrlog_set__TERM_ID  {
    #  _usrlog_Set__TERM_ID     -- set or randomize the $_TERM_ID key
    #    $1: _term_id value for _TERM_ID
    local new_term_id="${@}"
    if [ -z "${new_term_id}" ]; then
        new_term_id="#$(_usrlog_randstr 8)"
    fi
    if [[ "${new_term_id}" != "${_TERM_ID}" ]]; then
        #TODO: _usrlog_append_echo
        if [ -z "${_TERM_ID}" ]; then
            _usrlog_append "#ntid  _TERM_ID=\"${new_term_id}\"  #_USRLOG=\"${_USRLOG}\""
        else
            _usrlog_append "#stid  _TERM_ID=\"${new_term_id}\"  #_TERM_ID__=\"${_TERM_ID}\"  #_USRLOG=\"${_USRLOG}\""
        fi
        export _TERM_ID="${new_term_id}"
        _usrlog_set_title

    fi
}


function _usrlog_echo_title  {
    #  _usrlog_echo_title   -- set window title (by echo'ing escape codes)
    local title="${WINDOW_TITLE:+"$WINDOW_TITLE "}"
    local venvtitle="${_APP:-${VIRTUAL_ENV_NAME}}"
    if [ -n "${venvtitle}" ]; then
        title="($venvtitle) ${title}"
    fi
    title="${title} ${USER}@${HOSTNAME}:${PWD}${venvtitle:+" - [${venvtitle^^}]"}"
    local USRLOG_WINDOW_TITLE=${title:-"$@"}
    if [ -n $CLICOLOR ]; then
        echo -ne "\033]0;${USRLOG_WINDOW_TITLE}\007"
    #  else
    #     echo -ne "${USRLOG_WINDOW_TITLE}"
    fi
}

function _usrlog_set_title {
    #  _usrlog_set_title()  --  set xterm title
    #   $1: _window_title (defaults to ${_TERM_ID})
    export WINDOW_TITLE=${1:-"$_TERM_ID"}
    _usrlog_echo_title
    declare -f '_setup_venv_prompt' 2>&1 > /dev/null \
        && _setup_venv_prompt
}


function _usrlog_setup {
    #  _usrlog_setup()      -- configure usrlog for the current shell
    local _usrlog="${1:-$_USRLOG}"
    local term_id="${2:-$_TERM_ID}"

    _usrlog_set_HIST

    _usrlog_set__USRLOG $_usrlog

    #TERM_SED_STR='s/^\s*[0-9]*\s\(.*\)/$_TERM_ID: \1/'
    TERM_SED_STR='s/^\s*[0-9]*\s*//'

    _usrlog_set__TERM_ID $term_id
    touch $_USRLOG

    _usrlog_set_title $_TERM_ID

    #  setup bash
    if [ -n "$BASH" ]; then
        PROMPT_COMMAND="_usrlog_writecmd; _usrlog_echo_title;"
    fi

    #  setup zsh
    if [ -n "$ZSH_VERSION" ]; then
        precmd_functions=(_usrlog_writecmd _usrlog_echo_title)
    fi
}

function _usrlog_append {
    #  _usrlog_append()  -- Write a line to $_USRLOG w/ an ISO8601 timestamp
    #    $1: text (command) to log
    #    note: _TERM_ID must not contain a tab character (tr '\t' ' ')
    #    note: _TERM_ID can be a URN, URL, URL, or simple \w+ str key
    #  example:
    #    2014-11-15T06:42:00-0600	dotfiles	 8311  ls
      #  (pwd -p)?
       #  this from HISTORY
    local cmd="${*}";
    local prefix="${VENVPREFIX:-${VIRTUAL_ENV}}"
    (printf "#  %s\t%s\t%s\t%s\t%s\n" \
        "$(date +%Y-%m-%dT%H:%M:%S%z)" \
        "$(echo "${_TERM_ID}" | tr $'\t' ' ')" \
        "$(echo "${prefix}" | tr $'\t' ' ')" \
        "$(echo "${PWD}" | tr $'\t' ' ')" \
        "$(echo "${cmd}" | tr $'\n' ' ')" \
        ) >> "${_USRLOG:-${__USRLOG}}" 2>/dev/null
    printf "%s\n" \
        "$(echo "${cmd}" | sed 's|.*	$$	\(.*\)|#  \1|g')"
}

#function _usrlog_append_oldstyle {
#    #  _usrlog_append_oldstype -- Write a line to $_USRLOG
#    #    $1: text (command) to log
#    #  examples:
#    #    # qMZwZSGvJv8: 10/28/14 17:25.54 :::   522  histgrep BUG
#    #    #ZbH08n8unY8	2014-11-11T12:27:22-0600	 2238  ls
#    printf "#  %-11s: %s : %s" \
#        "$_TERM_ID" \
#        "$(date +'%D %R.%S')" \
#        "${1:-'\n'}" \
#            | tee -a $_USRLOG >&2
#}


function _usrlog_writecmd {
    #  _usrlog_writecmd()    -- write the most recent command to $_USRLOG
    _usrlog_set_HISTFILE

    if [ -n "$ZSH_VERSION" ]; then
        id 2>&1 > /dev/null
        _cmd=$(fc -l -1 | sed -e "${TERM_SED_STR}")
    elif [ -n "$BASH" ]; then
        _cmd=$(history 1 | sed -e "${TERM_SED_STR}")
    else
        _cmd=$(history 1 | sed -e "${TERM_SED_STR}")
    fi
    _usrlog_append "${_cmd}"
}


## usrlog parsing

function _usrlog_parse_newstyle {
    #  _usrlog_parse_newstyle -- Parse a -usrlog.log with pyline
    #    NOTE: handle when HISTTIMEFORMAT=""
    #    NOTE: this is approxmte (see: venv.py)
    local usrlog="${1}"
    if [ -n "${usrlog}" ]; then
        if [ "${usrlog}" != "-" ]; then
            usrlog="-f ${usrlog}"
        fi
    fi
    pyline.py ${usrlog} \
        -m collections \
        '[collections.OrderedDict((
            ("l", [l]),
            ("date", w[0].lstrip("#  ")),
            ("id", w[1]),
            ("path", w[2]),
            ("virtualenv", w[3]),
            ("histstr", w[4:]),
            ("histn", w[4].strip()),    #  int or {#NOTE, #TODO, #_MSG}
            ("histdate", (w[5] if len(w) > 5 else None)),
            ("histhostname", (w[6] if len(w) > 6 else None)),
            ("histuser", (w[7] if len(w) > 7 else None)),
            ("histcmd", (w[9:] if len(w) > 9 else None)),
            ))
            for w in [ line.split("\t", 9) ]
                if len(w) >= 4]' \
                    -O json
}


function _usrlog_parse_cmds {
    #  _usrlog_parse_cmds -- Show histcmd or histstr from HISTTIMEFORMAT usrlog
    #  with pyline
    #  TODO: handle HISTTIMEFORMAT="" (" histn  <cmd>")
    #  TODO: handle newlines (commands that start on the next line)  (venv.py)
    #  NOTE: HISTTIMEFORMAT histn (OSX  ) [ 8 ]
    #  NOTE: HISTTIMEFORMAT histn (Linux) [ 7 ]
    local usrlog="${1}"
    sed 's,.*\t\$\$\t\(.*\),\1,g' ${usrlog:+"${usrlog}"}

    #if [ -n "${usrlog}" ]; then
    #    if [ "${usrlog}" != "-" ]; then
    #        usrlog="-f ${usrlog}"
    #    fi
    #fi
    #pyline.py ${usrlog} \
    #    'list((
    #        (" ".join(w[10:]).rstrip() if len(w) > 10 else None)
    #        or (" ".join(w[9:]).rstrip() if len(w) > 9 else None)
    #        or (" ".join(w[8:]).rstrip() if len(w) > 8 else None)
    #        or (" ".join(w[7:]).rstrip() if len(w) > 7 else None)
    #        or (" ".join(w[3:]).rstrip() if len(w) > 3 else None)
    #        or " ".join(w).rstrip())
    #        for w in [ line and line.startswith("#") and line.split("\t",9) or [line] ]
    #        )'
    #if try_grep:
    #
    #pyline.py ${usrlog} -r '(\d+:|#\s+) ' \'l and (l.startswith("#" or rgx.groups())) and l.split("\t$$\t", 1)[-1]'
    #pyline.py ${usrlog}  'l and (l.startswith("#")) and l.split("\t$$\t", 1)[-1]'
    # usrlog.py -p${usrlog:-'-'}${usrlog:+"${usrlog}"} --cmd
    #
    # grep -n "usrlog_" "$_USRLOG" | pyline.py -r '^(?P<grep_n>\d+\:)?(?P<start>#\s+)(?P<_words>.*)\t\$\$\t(?P<cmd>.*)' 'l and rgx and (rgx.groups(), rgx.groupdict(), (rgx.groupdict().get("_words","") or "").split("\t"))'  -O json
    #
}
function ugp {
    _usrlog_parse_cmds "${@}"
}

## usrlog.sh API

### usrlog _TERM_ID commands

function termid {
    #  termid()      -- echo $_TERM_ID
    _usrlog_get__TERM_ID
}


function set_term_id {
    #  set_term_id() -- set $_TERM_ID to a randomstr or $1
    _usrlog_set__TERM_ID $@
}

function stid {
    #  stid()        -- set $_TERM_ID to a randomstr or $1
    _usrlog_set__TERM_ID $@
}
function st {
    #  st()          -- set $_TERM_ID to a randomstr or $1
    _usrlog_set__TERM_ID $@
}

### usrlog tail commands
function ut {
    #  ut()  -- show recent commands
    usrlog_tail "${@}"
}

function uta {
    #  uta()  -- tail all usrlogs from lsusrlogs
    usrlog_tail "$(lsusrlogs)"
}
function utap {
    #  utap()  -- tail all userlogs from lsusrlogs and parse
    usrlog_tail ${@:+"${@}"} "$(lsusrlogs)" | ugp   # TODO: headers
}

function utp {
    #  ut()  -- show recent commands
    usrlog_tail "${@}" | _usrlog_parse_cmds
}

function usrlog_tail {
    #  usrlog_tail()     -- tail -n20 $_USRLOG
    local _args=${@}
    local follow="${_USRLOG_TAIL_FOLLOW}"
    local _usrlog="${_USRLOG}"
    if [ -n "${_args}" ]; then
        for _arg in ${_args}; do
            if [[ "${_arg}" == -* ]]; then
                if [[ "${_arg}" = '-n' ]]; then
                    shift;
                    local count=${1}
                    shift
                elif [[ "${_arg}" = '-v' ]]; then
                    shift
                    local verbose=1
                else
                    # shift
                    echo "_arg: ${_arg}" # TODO: 
                fi
            fi
        done
        local __args=${@}   # after shifts
        if [ -z "${@}" ]; then
            _args=($_args "${_USRLOG}")
        fi
        (set -x; tail ${_args[@]})
    else
        (set -x; tail ${follow:+"-f"} "${_usrlog}")
    fi
}
function usrlog_tail_follow {
    #  usrlogtf()    -- tail -f -n20 $_USRLOG
    _USRLOG_TAIL_FOLLOW=true usrlog_tail "${@}"
}
function utf {
    #  utf()         -- tail -f -n20 $_USRLOG
    usrlog_tail_follow "${@}"
}


### usrlog grep commands

function usrlog_grep {
    #  usrlog_grep() -- egrep -n $_USRLOG
    #local _args="${@}"
    local _paths="${_USRLOG_GREP_PATHS:-"${_USRLOG}"}"
    if [ -z "${@}" ]; then
        (set -x; cat "${_paths}")
    else
        (set -x; egrep --text -n "${@}" ${_paths})
    fi
}
function ug {
    #  ug()          -- egrep -n $_USRLOG
    #    Usage:
    #      ug 'pip' | ugp
    #      ug | ugp | grep -C 20 'pip'
    #      ug | usrlog.py -
    usrlog_grep "${@}"
}

function uga2 {
    #  uga2()
    _USRLOG_GREP_PATHS="$(lsusrlogs)" usrlog_grep "${@}"
}

#function usrlog_grep_session_id {
#     # usrlog_grep_session_id()  -- egrep ".*\t${1:-$_TERM_ID}"
#     (set -x;
#     local _term_id=${1:-"${_TERM_ID}"};
#     local _usrlog=${2:-"${_USRLOG}"};
#     egrep "# [\d-T:Z ]+\t${_term_id}\t" ${_USRLOG} )
#}

function _usrlog_grep_venvs {
    egrep ${@} '((we[c]?)|workon_venv|workon_conda|workon|mkvirtualenv|mkvirtualenv_conda|rmvirtualenv|rmvirtualenv_conda)[ ;]'

}
function usrlog_grep_venvs {
    cat ${@:-${_USRLOG}} | _usrlog_grep_venvs
}
function ugv {
    usrlog_grep_venvs "${@}"
}
function ugva {
    usrlog_grep_venvs $(lsusrlogs) | sort -n
}

function _usrlog_grep_todo_fixme_xxx {
    grep --text -E -i '(todo|fixme|xxx)'
}
function _usrlog_grep_todos {
    grep --text '$$'$'\t''#\(TODO\|NOTE\|_MSG\)'
}
function usrlog_grep_todos {
    cat "${@:-${_USRLOG}}" | _usrlog_grep_todos
}
function uggt {
    usrlog_grep_todos "${@}"
}

function usrlog_grep_todos_parse {
    usrlog_grep_todos "${@}" | _usrlog_parse_cmds
}

function ugtp {
    # usrlog_grep_todos | _usrlog_parse_cmds
    uggt "${@}" | ugp
}

function ugtptodo {
    # usrlog_grep_todos | _usrlog_parse_cmds
    ugtp "${@}" | grep --text --color=never '^#TODO'
}
function ugtptodonote {
    # usrlog_grep_todos | _usrlog_parse_cmds
    ugtp "${@}" | grep --text --color=never '^#\(TODO\|NOTE\)'
}

function usrlog_format_as_txt {
    sed 's/^#TODO: /- /' \
        | sed 's/^#NOTE: /- NOTE: /' \
        | sed 's/^#_MSG: /- _MSG: /'
    # pyline '(l.replace("#TODO: ", "- [ ] ", 1).replace("#NOTE:", "- ", 1) if l.startswith("#TODO: ", "#NOTE: ") else l)'
}

function ugft {
    usrlog_format_as_txt "${@}"
}

function ugtodo {
    usrlog_grep_todos_parse "${@}" | usrlog_format_as_txt
    #ugtp "${@}" | ugft
}

function ugt {
    #usrlog_grep_todos_parse | usrlog_format_as_txt
    ugtodo "${@}"
}

function ugtodoall {
    ugtp "${@}" $(lsusrlogs)
}

function ugta {
    ugtodoall "${@}"
}

function usrlog_grin {
    #  usrlog_grin() -- grin -s $@ $_USRLOG
    local args="${@}"
    (set -x;
    grin -s "${args}" "${_USRLOG}")
}
function ugrin  {
    #  ugrin()       -- grin -s $@ $_USRLOG
    usrlog_grin "${@}"
}


function usrlog_grin_session_id {
    #  usrlog_grin_session_id()  -- egrep ".*\t${1:-$_TERM_ID}"
    (set -x;
    local _term_id="${1:-"${_TERM_ID}"}";
    local _usrlog="${2:-"${_USRLOG}"}";
    grin -s '#  [\d\-:TZ\s]+\t'${_term_id}'\t(.*)$' ${_usrlog} --no-color;);
}


function usrlog_grin_session_id_cmds {
    #  usrlog_grin_session_id()  -- egrep ".*\t${1:-$_TERM_ID}"
    (set -x;
    local _term_id="${1:-"${_TERM_ID}"}";
    local _usrlog="${2:-"${_USRLOG}"}";
    grin -N --no-color --without-filename -s \
        '#  [\d\-:TZ\s]+\t'${_term_id}'\t(.*)$' \
        "${_usrlog}" \
            | _usrlog_parse_cmds -  ;
    );
}


function usrlog_grin_session_id_all {
    #  usrlog_grin_session_id_all()  -- grep $2:-$_USRLOG for $1:-$_TERM_ID
    #                                   in column position
    #    :returns: unsorted list of log entries in files
    #              listed by mtime and then cat
    #
    #  .. warning:: output lines are in file sequence but otherwise
    #                unsorted
    #
    (set -x;
    local _term_id=${1:-"${_TERM_ID}"}; \
    local _usrlog=${2:-"${_USRLOG}"}; \
    local _usrlogs=$(lsusrlogs_date_desc);
    grin -s     '#  [\d\-:TZ\s]+\t'${_term_id}'\t' ${_usrlogs} --no-color;)
}
function ugrins  {
    #  ugrins()  -- grep $2:-$_USRLOG for $1:-$_TERM_ID in column position
    usrlog_grin_session_id_all ${@}
}

function usrlog_grin_session_id_all_cmds {
    #  usrlog_grin_session_id_all_cmds()  -- grep $2:-$_USRLOG for $1:-$_TERM_ID
    #                                        in column position
    (set -x;
    local _term_id=${1:-"${_TERM_ID}"}; \
    local _usrlog=${2:-"${_USRLOG}"}; \
    local _usrlogs=$(lsusrlogs_date_asc);
    grin -N --no-color --without-filename -s \
        '#  [\d\-:TZ\s]+\t'${_term_id}'\t' \
        "${_usrlogs}" \
        | _usrlog_parse_cmds -  ;
    );
}


function lsusrlogs_date_desc {
    #  lsusrlogs_date_desc()   -- ls $__USRLOG ${WORKON_HOME}/*/.usrlog
    #                             (oldest first)
    ls -tr \
        "${__USRLOG}" \
        ${WORKON_HOME}/*/.usrlog \
        ${WORKON_HOME}/*/-usrlog.log $@ 2>/dev/null
}
function lsusrlogs_date_asc {
    #  lsusrlogs_date_desc()   -- ls $__USRLOG ${WORKON_HOME}/*/.usrlog
    #                             (newest first)
    ls -t \
        "${__USRLOG}" \
        ${WORKON_HOME}/*/.usrlog \
        ${WORKON_HOME}/*/-usrlog.log $@ 2>/dev/null
}
function lsusrlogs {
    #  lsusrlogs()             -- list usrlogs (oldest first)
    lsusrlogs_date_desc "${@}"
}

function usrlog_lately {
    #  usrlog_lately()      -- lsusrlogs by mtime
    lsusrlogs_date_desc "${@}" | xargs ls -ltr
}
function ull {
    #  ull()                -- usrlog_lately() (lsusrlogs by mtime)
    usrlog_lately "${@}"
}

function usrlog_grep_all {
    #  usrlog_grep_all()    -- grep $(lsusrlogs) (drop filenames with -h)
    (set -x;
    args="${@}"
    usrlogs=$(lsusrlogs)
    egrep ${args} ${usrlogs} \
        | sed 's/:/'$'\t''/')
       #| pyline.py 'l.replace(":","\t",1)'  # grep filename output
}
function ugall {
    #  ugall()              -- grep $(lsusrlogs) (drop filenames with -h)
    usrlog_grep_all "${@}"
}
function uga {
    #  uga()                -- grep $(lsusrlogs) (drop filenames with -h)
    usrlog_grep_all "${@}"
}

function usrlog_grin_all {
    #  usrlog_grin_all()    -- grin usrlogs
    (set -x;
    args="${@}"
    usrlogs=$(lsusrlogs)
    grin --no-skip-hidden-files ${args} ${usrlogs} \
        | sed 's/:/'$'\t''/' \
        | grin ${args})
}
function ugrinall {
    #  usrlog_grin_all()    -- grin usrlogs
    usrlog_grin_all "${@}"
}

function todo {
    #  todo()   -- _usrlog_append a #TODO and set _TODO ('-' unsets, '' prints)
    #      see: usrlog_grep_todos_parse (ugt, ugtp) 
    local _todo="${@}"
    if [ -z "${_todo}" ]; then
        echo "_TODO=${_TODO}"
        return
    elif [[ "${_todo}" = "-" ]]; then
        unset _TODO
        echo "_TODO=${_TODO}"
        return
    else
        export _TODO="${_todo}"
        echo "_TODO=${_TODO}"
        startstr="#TODO	$(date +'%FT%T%z')	${HOSTNAME}	${USER}	\$$	"
        #_usrlog_append "#note  #note: $@"
        _usrlog_append "${startstr}#TODO: [ ] ${_todo}"
        return
    fi
}
function note {
    #  note()   -- _usrlog_append a #NOTE and set _NOTE ('-' unsets, '' prints)
    local _note="${@}"
    if [ -z "${_note}" ]; then
        echo "_NOTE=${_NOTE}"
        return
    elif [[ "${_note}" = "-" ]]; then
        unset _NOTE
        echo "_NOTE=${_NOTE}"
        return
    else
        export _NOTE="${_note}"
        echo "_NOTE=${_NOTE}"
        startstr="#NOTE	$(date +'%FT%T%z')	${HOSTNAME}	${USER}	\$$	"
        _usrlog_append "${startstr}#NOTE: ${_note}"
        return
    fi
}
function msg {
    #  msg()   -- _usrlog_append a #_MSG and set __MSG ('-' unsets, '' prints)
    local _msg="${@}"
    if [ -z "${_msg}" ]; then
        echo "_MSG=${_MSG}"
        return
    elif [[ "${_msg}" == "-" ]]; then
        unset _MSG
        echo "_MSG=${_MSG}"
        return
    else
        export _MSG="${_msg}"
        echo "_MSG=${_MSG}"
        startstr="#_MSG	$(date +'%FT%T%z')	${HOSTNAME}	${USER}	\$$	"
        _usrlog_append "${startstr}#_MSG: ${_msg}"
        return
    fi
}

function usrlog_screenrec_ffmpeg {
    #  usrlog_screenrec_ffmpeg() -- record a screencast
    #    $1: destination directory (use /tmp if possible)
    #    $2: video name to append to datestamp
    #    - Press "q" to stop recording
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

function usrlogw {
    #  usrlogw()       -- usrlog.py -p ${_USRLOG} ${@}
    (set -x; usrlog.py -p "${_USRLOG}" ${@})
}

function _setup_usrlog {
    #  _setup_usrlog() -- call _usrlog_setup $@
    _usrlog_setup $@
}


if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
## calls _usrlog_setup when sourced
    _usrlog_setup
else
    _usrlog_setup
fi
