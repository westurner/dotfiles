## Virtualenvwrapper
# sudo apt-get install virtualenvwrapper || easy_install virtualenvwrapper
export PROJECT_HOME="${HOME}/wrk"
export WORKON_HOME="${PROJECT_HOME}/.ve"

_setup_virtualenvwrapper () {
    ## _setup_virtualenvwrapper -- configure $VIRTUALENVWRAPPER_*
    #export VIRTUALENVWRAPPER_SCRIPT="/usr/local/bin/virtualenvwrapper.sh"
    export VIRTUALENVWRAPPER_SCRIPT="${HOME}/.local/bin/virtualenvwrapper.sh"
    export VIRTUALENVWRAPPER_HOOK_DIR="${__DOTFILES}/etc/virtualenvwrapper"
    export VIRTUALENVWRAPPER_LOG_DIR="${PROJECT_HOME}/.virtualenvlogs"
    export VIRTUALENVWRAPPER_PYTHON='/usr/bin/python' # TODO
    export VIRTUALENV_DISTRIBUTE='true'
    source "${VIRTUALENVWRAPPER_SCRIPT}"

    #alias cdv='cdvirtualenv'
    #alias cds='cdvirtualenv src'
    #alias cde='cdvirtualenv etc'
    #alias cdl='cdvirtualenv lib'
    #alias cde='cdvirtualenv src/$_VENVNAME'

}
_setup_virtualenvwrapper

lsvirtualenv() {
    ## lsvirtualenv()   -- list virtualenvs in $WORKON_HOME
    cmd=${@:-""}
    (cd ${WORKON_HOME} &&
    for venv in $(ls -adtr ${WORKON_HOME}/**/lib/python?.? | \
        sed "s:$WORKON_HOME/\(.*\)/lib/python[0-9]\.[0-9]:\1:g"); do
        echo "${venv}" ;
        if [ -n "${cmd}" ]; then
            $cmd $venv ;
        fi
    done)
}

lsve() {
    ## lsve()           -- list virtualenvs in $WORKON_HOME
    lsvirtualenv $@
}


