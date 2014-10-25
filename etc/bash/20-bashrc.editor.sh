## ${EDITOR} configuration
#
#  VIRTUAL_ENV_NAME
#  _CFG = 
#

## Editor
#export USEGVIM=""
_setup_editor() {
    # Configure ${EDITOR}
    export VIMBIN="/usr/bin/vim"
    export GVIMBIN="/usr/bin/gvim"
    export MVIMBIN="/usr/local/bin/mvim"
    export GUIVIMBIN=""
    if [ -x ${GVIMBIN} ]; then
        export GUIVIMBIN=$GVIMBIN
    elif [ -x ${MVIMBIN} ]; then
        export GUIVIMBIN=$MVIMBIN
    fi

    export EDITOR="${VIMBIN}"
    export SUDO_EDITOR="${VIMBIN}"

    if [ -n "${GUIVIMBIN}" ]; then
        VIMCONF="--servername ${VIRTUAL_ENV_NAME:-'EDITOR'} --remote-tab-silent"
        SUDOCONF="--servername sudo.${VIRTUAL_ENV_NAME:-'EDITOR'} --remote-tab-wait-silent"
        export EDITOR="${GUIVIMBIN} ${VIMCONF}"
        export SUDO_EDITOR="${GUIVIMBIN} ${SUDOCONF}"
        alias vim='${VIMBIN}'
        alias gvim="${GUIMVINBIN} ${VIMCONF}"
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
    ${EDITOR} $@
}

edit() {
    ${EDITOR} $@
}

editcfg() {
    ${EDITOR} $_CFG
}

sudoe() {
    EDITOR=${SUDO_EDITOR} sudo -e
}

sudogvim() {
    EDITOR=${SUDO_EDITOR} sudo -e
}


