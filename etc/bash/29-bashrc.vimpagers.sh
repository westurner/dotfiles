
### bashrc.vimpagers.sh

function _configure_lesspipe {
    # _configure_lesspipe() -- (less <file.zip> | lessv)
    lesspipe="$(which lesspipe.sh 2>/dev/null)"
    if [ -n "${lesspipe}" ]; then
        eval "$(${lesspipe})"
    fi
}
_configure_lesspipe


function _setup_vimpager {
    __THIS=$(readlink -e "$0")
}

function vimpager {
    # vimpager() -- call vimpager
    # _PAGER=$(which vimpager)
    if [ -x "${_PAGER}" ]; then
        "${_PAGER}" "${@}"
    else
        lessv "$@"
        echo "error: vimpager not found. (see lessv: 'lessv $@')"
    fi
}


function lessv {
    # lessv()   -- less with less.vim and vim (g:tinyvim=1)
    if [ -t 1 ]; then
        if [ $# -eq 0 ]; then
            if [ -n "$VIMPAGER_SYNTAX" ]; then
                #read stdin
                "${VIMBIN}" --cmd "let g:tinyvim=1" \
                    --cmd "runtime! macros/less.vim" \
                    --cmd "set nomod" \
                    --cmd "set noswf" \
                    -c "set colorcolumn=0" \
                    -c "map <C-End> <Esc>G" \
                    -c "set syntax=${VIMPAGER_SYNTAX}" \
                    -c "set cursorline nocursorcolumn" \
                    -
            else
                "${VIMBIN}" --cmd "let g:tinyvim=1" \
                    --cmd "runtime! macros/less.vim" \
                    --cmd "set nomod" \
                    --cmd "set noswf" \
                    -c "set colorcolumn=0" \
                    -c "map <C-End> <Esc>G" \
                    -c "set cursorline nocursorcolumn" \
                    -
            fi
        elif [ -n "$VIMPAGER_SYNTAX" ]; then
            "${VIMBIN}" \
                --cmd "let g:tinyvim=1" \
                --cmd "runtime! macros/less.vim" \
                --cmd "set nomod" \
                --cmd "set noswf" \
                -c "set colorcolumn=0" \
                -c "map <C-End> <Esc>G" \
                -c "set syntax=${VIMPAGER_SYNTAX}" \
                -c "set cursorline nocursorcolumn" \
                "${@}"

        else
            "${VIMBIN}" \
                --cmd "let g:tinyvim=1" \
                --cmd "runtime! macros/less.vim" \
                --cmd "set nomod" \
                --cmd "set noswf" \
                -c "set colorcolumn=0" \
                -c "map <C-End> <Esc>G" \
                -c "set cursorline nocursorcolumn" \
                "${@}"
        fi
    else
        #Output is not a terminal, cat arguments or stdin
        if [ $# -eq 0 ]; then
            less
        else
            less "${@}"
        fi
    fi
}

function lessg {
    # lessg()   -- less with less.vim and gvim / mvim
    VIMBIN="${GUIVIMBIN}" lessv "${@}"
}

function lesse {
    # lesse()   -- less with current venv's vim server
    "${GUIVIMBIN}" --servername "${VIRTUAL_ENV_NAME:-"/"}" --remote-tab "${@}";
}

function manv {
    # manv()    -- view manpages in vim
    alias man_="/usr/bin/man"
    if [ $# -eq 0 ]; then
        /usr/bin/man
    else
        #/usr/bin/whatis "$@" >/dev/null
        "$(which vim)" \
            --noplugin \
            -c "runtime ftplugin/man.vim" \
            -c "Man $*" \
            -c 'silent! only' \
            -c 'nmap q :q<CR>' \
            -c 'set nomodifiable' \
            -c 'set colorcolumn=0' \
            -c "set cursorline nocursorcolumn"
    fi
}

function mang {
    # mang()    -- view manpages in gvim / mvim
    if [ $# -eq 0 ]; then
        /usr/bin/man
    else
        "${GUIVIMBIN}" \
            --noplugin \
            -c "runtime ftplugin/man.vim" \
            -c "Man $*" \
            -c 'silent! only' \
            -c 'nmap q :q<CR>' \
            -c 'set nomodifiable' \
            -c 'set colorcolumn=0' \
            -c "set cursorline nocursorcolumn"
    fi
}

function mane {
    # mane()    -- open manpage with venv's vim server
    ${GUIVIMBIN} ${VIMCONF} --remote-send "<ESC>:Man $@<CR>"
}

function gitpager {
    # gitpager()    -- export GIT_PAGER to $1 or GIT_PAGER_DEFAULT or
    export GIT_PAGER="${1:-${GIT_PAGER:-${GIT_PAGER_DEFAULT}}}"
    if [ "${GIT_PAGER}" == "" ]; then
        unset GIT_PAGER
    fi
    echo "GIT_PAGER=$(shell_escape_single "${GIT_PAGER}")"
}

function nogitpager {
    # nogitpager()  -- export GIT_PAGER=""
    export GIT_PAGER=""
    echo "GIT_PAGER=$(shell_escape_single "${GIT_PAGER}")"
}
