
### bashrc.dotfiles.sh


dotfiles_add_path() {
    ## dotfiles_add_path    -- Add ${__DOTFILES}/scripts to $PATH
    if [ -d "${__DOTFILES}" ]; then
        #add_to_path "${__DOTFILES}/bin"  # [01-bashrc.lib.sh]
        add_to_path "${__DOTFILES}/scripts"
    fi
}

#
# See etc/bash/05-bashrc.dotfiles.sh
## dotfiles_status()        -- print dotfiles_status 

dotfiles_status() {
    #  dotfiles_status()    -- print dotfiles_status
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

dotfiles_term_url() {
    term_path="${HOSTNAME}/usrlog/${USER}"
    term_key=${_APP}/${_TERM_ID}
    TERM_URL="${term_path}/${term_key}"
    echo "TERM_URL='${TERM_URL}'"
}

ds() {
    #  ds                   -- print dotfiles_status
    dotfiles_status $@
}

log_dotfiles_state() {
    # log_dotfiles_state    -- save current environment to logfiles

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
    ## dotfiles_initialize()  -- virtualenvwrapper initialize
    log_dotfiles_state 'initialize'
}

dotfiles_preactivate() {
    ## dotfiles_preactivate()  -- virtualenvwrapper preactivate
    log_dotfiles_state 'preactivate'
}

dotfiles_postactivate() {
    ## dotfiles_postactivate()  -- virtualenvwrapper postactivate
    log_dotfiles_state 'postactivate'

    test -n $_VENV \
        && source <(python $_VENV -E --bash)

    declare -f '_usrlog_setup' 2>&1 > /dev/null \
        && _usrlog_setup
   
    declare -f '_venv_set_prompt' 2>&1 > /dev/null \
        && _venv_set_prompt

}

dotfiles_predeactivate() {
    ## dotfiles_predeactivate()  -- virtualenvwrapper predeactivate
    log_dotfiles_state 'predeactivate'
}

dotfiles_postdeactivate() {
    ## dotfiles_postdeactivate()  -- virtualenvwrapper postdeactivate
    log_dotfiles_state 'postdeactivate'
    unset VIRTUAL_ENV_NAME
    unset _SRC
    unset _WRD
    unset _USRLOG
    export _USRLOG=~/.usrlog
    # __DOTFILES='/Users/W/.dotfiles'
    # __DOCSWWW=''
    # __SRC='/Users/W/src'
    # __PROJECTSRC='/Users/W/wrk/.projectsrc.sh'
    # PROJECT_HOME='/Users/W/wrk'
    # WORKON_HOME='/Users/W/wrk/.ve'

    dotfiles_reload
}
