## ${EDITOR} configuration
#
#  VIRTUAL_ENV_NAME
#  _CFG = 
#

## Editor
#export USEGVIM=""
_setup_editor() {
    # setup_editor()    -- configure ${EDITOR}
    export VIMBIN="/usr/bin/vim"
    export GVIMBIN="/usr/bin/gvim"
    export MVIMBIN="/usr/local/bin/mvim"
    export GUIVIMBIN=""
    if [ -x ${GVIMBIN} ]; then
        export GUIVIMBIN=$GVIMBIN
    elif [ -x ${MVIMBIN} ]; then
        export GUIVIMBIN=$MVIMBIN
    fi

    export EDITOR="${VIMBIN} -f"
    export EDITOR_="${EDITOR}"
    export SUDO_EDITOR="${VIMBIN} -f"

    if [ -n "${GUIVIMBIN}" ]; then
        export VIMCONF="--servername ${VIRTUAL_ENV_NAME:-'EDITOR'}"
        export SUDOCONF="--servername sudo.${VIRTUAL_ENV_NAME:-'EDITOR'}"
        export EDITOR="${GUIVIMBIN} -f"
        export EDITOR_="${GUIVIMBIN} ${VIMCONF} --remote-tab-silent"
        export SUDO_EDITOR="${GUIVIMBIN} -f"
        alias gvim="${GUIVIMBIN}"
    else
        unset -f $GVIMBIN
        unset -f $MVIMBIN
        unset -f $USEGVIM
    fi

    export _EDITOR="${EDITOR}"
}
_setup_editor


ggvim() {
    ${EDITOR} $@ 2>&1 > /dev/null
}


e() {
    ${EDITOR_} $@
}

edit() {
    ${EDITOR_} $@
}

editcfg() {
    ${EDITOR_} $_CFG
}

sudoe() {
    EDITOR=${SUDO_EDITOR} sudo -e
}

sudogvim() {
    EDITOR=${SUDO_EDITOR} sudo -e
}


