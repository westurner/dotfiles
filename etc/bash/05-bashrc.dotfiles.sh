
### bashrc.dotfiles.sh


dotfiles_add_path() {
    ## Add ${__DOTFILES}/scripts to $PATH
    if [ -d "${__DOTFILES}" ]; then
        #add_to_path "${__DOTFILES}/bin"  # [01-bashrc.lib.sh]
        add_to_path "${__DOTFILES}/scripts"
    fi
}

#
# See etc/bash/05-bashrc.dotfiles.sh
## dotfiles_status()    -- print 

dotfiles_status() {
    #  dotfiles_status()    -- print dotfiles_status
    #echo "## dotfiles_status()"
    #lightpath | sed 's/^\(.*\)/#  \1/g'
    echo "USER='${USER}'"
    echo "HOSTNAME='${HOSTNAME}'"
    echo "VIRTUAL_ENV_NAME='${VIRTUAL_ENV_NAME}'"
    echo "VIRTUAL_ENV='${VIRTUAL_ENV}'"
    echo "_SRC='${_SRC}'"
    echo "_WRD='${_WRD}'"
    echo "_USRLOG='${_USRLOG}'"
    echo "__DOTFILES='${__DOTFILES}'"
    echo "__DOCSWWW='${_DOCS}'"
    echo "__SRC='${__SRC}'"
    echo "__PROJECTSRC='${__PROJECTSRC}'"
    echo "PROJECT_HOME='${PROJECT_HOME}'"
    echo "WORKON_HOME='${WORKON_HOME}'"
    echo "PATH='${PATH}'"
}

ds() {
    #  ds                   -- print dotfiles_status
    dotfiles_status $@
}

log_dotfiles_state() {
    logkey=${1:-'99'}
    logdir=${_LOG:-"var/log"}/venv.${logkey}/
    exportslogfile=${logdir}/exports.log
    envlogfile=${logdir}/exports_env.log
    test -n $logdir && test -d $logdir || mkdir -p $logdir
    export > $exportslogfile
    set > $envlogfile
}

dotfiles_initialize() {
    log_dotfiles_state 'initialize'
}

dotfiles_preactivate() {
    log_dotfiles_state 'preactivate'
    test -n $_VENV \
        && source <(python $_VENV -E --bash)
}

dotfiles_postactivate() {
    log_dotfiles_state 'postactivate'
}

dotfiles_predeactivate() {
    log_dotfiles_state 'predeactivate'
}

dotfiles_postdeactivate() {
    log_dotfiles_state 'postdeactivate'
    unset VIRTUAL_ENV_NAME
    unset _SRC
    unset _WRD
    unset _USRLOG
    export _USRLOG=~/.usrlog  ## TODO: __USRLOG
    # __DOTFILES='/Users/W/.dotfiles'
    # __DOCSWWW=''
    # __SRC='/Users/W/src'
    # __PROJECTSRC='/Users/W/wrk/.projectsrc.sh'
    # PROJECT_HOME='/Users/W/wrk'
    # WORKON_HOME='/Users/W/wrk/.ve'
    dotfiles_reload
}
