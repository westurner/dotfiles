
### bashrc.editor.sh

_setup_editor() {
    # setup_editor()    -- configure ${EDITOR}
    #   VIMBIN  (str):   /usr/bin/vim
    #   GVIMBIN (str):   /usr/bin/gvim
    #   MVIMBIN (str):   /usr/local/bin/mvim
    #   GUIVIMBIN (str): $GVIMBIN || $MVIMBIN || ""
    #   EDITOR  (str):   $VIMBIN -f || $GUIVIMBIN -f
    #   EDITOR_ (str):   $EDITOR || $GUIVIMBIN $VIMCONF --remote-tab-silent
    #   VIMCONF (str):   --servername ${VIRTUAL_ENV_NAME:-'EDITOR'}
    #   SUDO_EDITOR (str): $EDITOR
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
        export VIMCONF="--servername ${VIRTUAL_ENV_NAME:-"/"}"
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


_setup_pager() {
    # _setup_pager()    -- set PAGER='less'
    export PAGER='/usr/bin/less -R'
}
_setup_pager


ggvim() {
    # ggvim()   -- ${EDITOR} $@ 2>&1 >/dev/null
    ${EDITOR} $@ 2>&1 > /dev/null
}


edits() {
    # edits()   -- open $@ in ${GUIVIMBIN} --servername $1
    servername=$1
    shift
    ${GUIVIMBIN} --servername ${servername} --remote-tab $@
}


e() {
    # e()       -- ${EDITOR_} $@      [ --servername $VIRTUAL_ENV_NAME ]
    ${EDITOR_} $@
}

edit() {
    # edit()    -- ${EDITOR_} $@      [ --servername $VIRTUAL_ENV_NAME ]
    ${EDITOR_} $@
}

editwrd() {
    # editw()   -- ${EDITOR_} ${_WRD}/$arg (for arg in $@)
    (for arg in $@; do echo $arg; done) | \
        el --each -x "${EDITOR_:-${EDITOR}} ${_WRD}/{0}"
}

ew() {
    # ew()   -- ${EDITOR_} ${_WRD}/$arg (for arg in $@) ('excellent')
    editwrd $@
}
_editwrd_complete() {
    #echo "1" $1
    #echo $2
    #echo $@
    local cur="$2";
    COMPREPLY=($(cd $_WRD && compgen -f -- "${cur}" ))
}
complete -o default -o nospace -F _editwrd_complete editwrd
complete -o default -o nospace -F _editwrd_complete ew

editcfg() {
    # editcfg() -- ${EDITOR_} ${_CFG} [ --servername $VIRTUAL_ENV_NAME ]
    ${EDITOR_} ${_CFG}
}

sudoe() {
    # sudoe()   -- EDITOR=${SUDO_EDITOR} sudo -e
    EDITOR=${SUDO_EDITOR} sudo -e $@
}
sudovim() {
    # sudoe()   -- EDITOR=${SUDO_EDITOR} sudo -e
    sudoe $@
}
