## $EDITOR configuration
#
#  VIRTUAL_ENV_NAME
#  _CFG = 
#

## Editor
#export USEGVIM=""
_setup_editor() {
    # Configure $EDITOR
    export VIMBIN="/usr/bin/vim"
    export GVIMBIN="/usr/bin/gvim"
    export MVIMBIN="/usr/local/bin/mvim"

    [ -f $GVIMBIN ] && export USEGVIM="true" || export USEGVIM=""

    export EDITOR="${VIMBIN}"
    export SUDO_EDITOR="${VIMBIN}"

    if [ -n "${USEGVIM}" ]; then
        VIMCONF='--servername ${VIRTUAL_ENV_NAME:-"main"} --remote-tab-silent'
        SUDOCONF="--servername sudo.${VIRTUAL_ENV_NAME:-"main"} --remote-tab-wait-silent"
        if [ -x "${GVIMBIN}" ]; then
            export EDITOR="${GVIMBIN} ${VIMCONF}"
            export SUDO_EDITOR="${GVIMBIN} ${SUDOCONF}"
        elif [ -x "${MVIMBIN}" ]; then
            export GVIMBIN=$MVIMBIN
            export EDITOR="${MVIMBIN} ${VIMCONF}"
            export SUDO_EDITOR="${MVIMBIN} ${SUDOCONF} "
            alias vim='${EDITOR} -f'
            alias gvim='${EDITOR} -f'
        else
            unset -f $GVIMBIN
            unset -f $MVIMBIN
        fi
    else
        unset -f $GVIMBIN
        unset -f $MVIMBIN
        unset -f $USEGVIM
    fi

    export _EDIT_="${EDITOR}"


}
_setup_editor


ggvim() {
    $EDITOR $@ 2>&1 > /dev/null
}


e() {
    $EDITOR $@
}
edit() {
    $EDITOR $@
}
_edit() {
    $EDITOR $@
}
_editcfg() {
    $EDITOR $_CFG
}
_gvim() {
    $EDITOR $@
}

sudoe() {
    EDITOR=$SUDO_EDITOR sudo -e
}
sudogvim() {
    EDITOR=$SUDO_EDITOR sudo -e
}


