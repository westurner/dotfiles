
workon_pyramid_app() {
    _VENVNAME=$1
    _APPNAME=$2

    _OPEN_TERMS=${3:-""}

    _VENVCMD="workon ${_VENVNAME}"
    we "${_VENVNAME}" "${_APPNAME}"
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


