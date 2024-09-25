#!/usr/bin/env sh
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
    if [ -x "${GVIMBIN}" ]; then
        export GUIVIMBIN=$GVIMBIN
    elif [ -x "${MVIMBIN}" ]; then
        export GUIVIMBIN=$MVIMBIN
    fi

    if [ -x "${VIMBIN}" ]; then
        export EDITOR="${VIMBIN} -f"
        export EDITOR_=$(command -v e)
        export SUDO_EDITOR="${VIMBIN} -f"
    fi

    if [ -n "${GUIVIMBIN}" ]; then
        export VIMCONF="--servername ${VIRTUAL_ENV_NAME:-"/"}"
        export EDITOR="${GUIVIMBIN} -f"
        #export EDITOR_="${GUIVIMBIN} ${VIMCONF} --remote-tab-silent"
        export SUDO_EDITOR="${GUIVIMBIN} -f"
        alias gvim='${GUIVIMBIN}'
    else
        unset -f "$GVIMBIN"
        unset -f "$MVIMBIN"
        unset -f "$USEGVIM"
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
    ${EDITOR} "${@}" >/dev/null 2>&1
}


edits() {
    # edits()   -- open $@ in ${GUIVIMBIN} --servername $1
    servername=$1
    shift
    ${GUIVIMBIN} --servername "${servername}" --remote-tab "${@}"
}


editcfg() {
    # editcfg() -- ${EDITOR_} ${_CFG} [ --servername $VIRTUAL_ENV_NAME ]
    e "${_CFG}"
}

sudoe() {
    # sudoe()   -- EDITOR=${SUDO_EDITOR} sudo -e
    EDITOR="${SUDO_EDITOR}" sudo -e "${@}"
}
sudovim() {
    # sudoe()   -- EDITOR=${SUDO_EDITOR} sudo -e
    sudoe "${@}"
}

# e() {
    # e() -- see $__DOTFILES/scripts/_ewrd.sh
# }

egitstatus() {
    # egitstatus() -- git status --short | sed | xargs e
    git status --short | sed 's/^ .* //' | xargs e
}
