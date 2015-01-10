
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
    echo "__WRK='${__WRK}'"
    echo "PROJECT_HOME='${PROJECT_HOME}'"
    echo "WORKON_HOME='${WORKON_HOME}'"
    echo "VIRTUAL_ENV_NAME='${VIRTUAL_ENV_NAME}'"
    echo "VIRTUAL_ENV='${VIRTUAL_ENV}'"
    echo "_SRC='${_SRC}'"
    echo "_APP='${_APP}'"
    echo "_WRD='${_WRD}'"
    #echo "__DOCSWWW='${_DOCS}'"
    #echo "__SRC='${__SRC}'"
    #echo "__PROJECTSRC='${__PROJECTSRC}'"
    echo "_USRLOG='${_USRLOG}'"
    echo "_TERM_ID='${_TERM_ID}'"
    echo "PATH='${PATH}'"
    echo "__DOTFILES='${__DOTFILES}'"
    #echo $PATH | tr ':' '\n' | sed 's/\(.*\)/#     \1/g'
    echo "#"
}
ds() {
    # ds()                      -- print dotfiles_status
    dotfiles_status $@
}

clr() {
    # clr()                     -- clear scrollback
    if [ -d '/Library' ]; then # see __IS_MAC
        # osascript -e 'if application "Terminal" is frontmost then tell application "System Events" to keystroke "k" using command down'
        clear && printf '\e[3J'
    else
        reset
    fi
}


cls() {
    # cls()                     -- clear scrollback and print dotfiles_status()
    clr ; dotfiles_status
}

#dotfiles_term_uri() {
    ##dotfiles_term_uri()        -- print a URI for the current _TERM_ID
    #term_path="${HOSTNAME}/usrlog/${USER}"
    #term_key=${_APP}/${_TERM_ID}
    #TERM_URI="${term_path}/${term_key}"
    #echo "TERM_URI='${TERM_URL}'"
#}

debug-env() {
    _log=${_LOG:-"."}
    OUTPUT=${1:-"${_log}/$(date +"%FT%T%z").debug-env.env.log"}
    dotfiles_status
    echo "## export"
    export | tee $OUTPUT
    echo "## alias"
    alias | tee $OUTPUT
    # echo "## lspath"
    # lspath | tee $OUTPUT
}

# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html#The-Shopt-Builtin

debug-on() {
    # debug-on()                 -- set -x -v
    set -x -v
    shopt -s extdebug
}
debug-off() {
    # debug-off()                -- set +x +v
    set +x +v
    shopt -s extdebug
}

log_dotfiles_state() {
    # log_dotfiles_state()      -- save current environment to logfiles
    # XXX:
    _log=${_LOG:-"${HOME}/var/log"}
    if [ "${_log}" == "/var/log" ]; then
        _log="${HOME}/var/log"
    fi
    logkey=${1:-'99'}
    logdir=${_log:-"var/log"}/venv.${VIRTUAL_ENV_NAME}.${logkey}/
    exportslogfile=${logdir}/exports.log
    envlogfile=${logdir}/exports_env.log
    test -n $logdir && test -d $logdir || mkdir -p $logdir
    # XXX:
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
    declare -f 'venv_mkdirs' 2>&1 >/dev/null && venv_mkdirs
    test -d ${VIRTUAL_ENV}/var/log || mkdir -p ${VIRTUAL_ENV}/var/log
    echo ""
    echo $(which pip)
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

    local bash_debug_output=$(
        $__VENV -e --verbose --diff --print-bash 2>&1 /dev/null)
    local venv_return_code=$?
    if [ ${venv_return_code} -eq 0 ]; then
        test -n $__VENV \
            && source <($__VENV -e --print-bash)
    else
        echo "${bash_debug_output}" # >2
    fi

    echo "setup usrlog"
    declare -f '_setup_usrlog' 2>&1 > /dev/null \
        && _setup_usrlog
   
    declare -f 'venv_set_prompt' 2>&1 > /dev/null \
        && venv_set_prompt

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

    declare -f '_usrlog_set__USRLOG' 2>&1 > /dev/null \
        && _usrlog_set__USRLOG
   
    dotfiles_reload
}
