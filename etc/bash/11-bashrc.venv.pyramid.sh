
### bashrc.venv.pyramid.sh

workon_pyramid_app() {
    # workon_pyramid_app()  -- $VIRTUAL_ENV_NAME [$_APP] [open_terminals]
    _VENVNAME=$1
    _APP=$2

    _OPEN_TERMS=${3:-""}

    _VENVCMD="workon ${_VENVNAME}"
    we "${_VENVNAME}" "${_APP}"

    export _EGGSETUPPY="${_WRD}/setup.py"
    export _EGGCFG="${_WRD}/development.ini"

    _EDITCFGCMD="${_EDITCMD} ${_EGGCFG}"
    _SHELLCMD="${_BIN}/pshell ${_EGGCFG}"
    _SERVECMD="${_BIN}/pserve --reload --monitor-restart ${_EGGCFG}"
    _TESTCMD="python ${_EGGSETUPPY} nosetests"

    alias _serve="${_SERVECMD}"
    alias _shell="${_SHELLCMD}"
    alias _test="${_TESTCMD}"
    alias _editcfg="${_EDITCFGCMD}"
    alias _glog="hgtk -R "${_WRD}" log"
    alias _log="hg -R "${_WRD}" log"

    if [ -n "${_OPEN_TERMS}" ]; then
        ${EDITOR} "${_WRD}" &
        #open tabs
        #gnome-terminal \
        #--working-directory="${_WRD}" \
        #--tab -t "${_APP} serve" -e "bash -c \"${_SERVECMD}; bash -c \"workon_pyramid_app $VIRTUAL_ENV_NAME $_APP 1\"\"" \
        #--tab -t "${_APP} shell" -e "bash -c \"${_SHELLCMD}; bash\"" \
        #--tab -t "${_APP} bash" -e "bash"
    fi
}


