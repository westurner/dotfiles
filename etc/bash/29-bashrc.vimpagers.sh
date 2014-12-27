
### bashrc.vimpagers.sh

_configure_lesspipe() {
    # _configure_lesspipe() -- (less <file.zip> | lessv)
    lesspipe=$(which lesspipe.sh 2>/dev/null || false)
    if [ -n "${lesspipe}" ]; then
        eval "$(${lesspipe})"
    fi
}
_configure_lesspipe


vimpager() {
    # vimpager() -- call vimpager
    _PAGER=$(which vimpager)
    if [ -x "${_PAGER}" ]; then
        ${_PAGER} $@
    else
        echo "error: vimpager not found. (see lessv: 'lessv $@')"
    fi
}


lessv () {
    # lessv()   -- less with less.vim and vim (g:tinyvim=1)
    if [ -t 1 ]; then
        if [ $# -eq 0 ]; then
            if [ -n "$VIMPAGER_SYNTAX" ]; then
                #read stdin
                ${VIMBIN} --cmd "let g:tinyvim=1" \
                    --cmd "runtime! macros/less.vim" \
                    --cmd "set nomod" \
                    --cmd "set noswf" \
                    -c "set colorcolumn=0" \
                    -c "map <C-End> <Esc>G" \
                    -c "set syntax=${VIMPAGER_SYNTAX}" \
                    -
            else
                ${VIMBIN} --cmd "let g:tinyvim=1" \
                    --cmd "runtime! macros/less.vim" \
                    --cmd "set nomod" \
                    --cmd "set noswf" \
                    -c "set colorcolumn=0" \
                    -c "map <C-End> <Esc>G" \
                    -
            fi
        elif [ -n "$VIMPAGER_SYNTAX" ]; then
            ${VIMBIN} \
                --cmd "let g:tinyvim=1" \
                --cmd "runtime! macros/less.vim" \
                --cmd "set nomod" \
                --cmd "set noswf" \
                -c "set colorcolumn=0" \
                -c "map <C-End> <Esc>G" \
                -c "set syntax=${VIMPAGER_SYNTAX}" \
                ${@}

        else
            ${VIMBIN} \
                --cmd "let g:tinyvim=1" \
                --cmd "runtime! macros/less.vim" \
                --cmd "set nomod" \
                --cmd "set noswf" \
                -c "set colorcolumn=0" \
                -c "map <C-End> <Esc>G" \
                ${@}
        fi
    else
        #Output is not a terminal, cat arguments or stdin
        if [ $# -eq 0 ]; then
            less
        else
            less $@
        fi
    fi
}

lessg() {
    # lessg()   -- less with less.vim and gvim / mvim
    VIMBIN=${GUIVIMBIN} lessv $@
}

lesse() {
    # lesse()   -- less with current venv's vim server
    ${EDITOR_} $@
}

manv() {
    # manv()    -- view manpages in vim
    alias man_="/usr/bin/man"
    if [ $# -eq 0 ]; then
        /usr/bin/man
    else
        #/usr/bin/whatis "$@" >/dev/null
        $(which vim) \
            --noplugin \
            -c "runtime ftplugin/man.vim" \
            -c "Man $*" \
            -c 'silent! only' \
            -c 'nmap q :q<CR>' \
            -c 'set nomodifiable' \
            -c 'set colorcolumn=0'
    fi
}

mang() {
    # mang()    -- view manpages in gvim / mvim
    if [ $# -eq 0 ]; then
        /usr/bin/man
    else
        ${GUIVIMBIN} \
            --noplugin \
            -c "runtime ftplugin/man.vim" \
            -c "Man $*" \
            -c 'silent! only' \
            -c 'nmap q :q<CR>' \
            -c 'set nomodifiable' \
            -c 'set colorcolumn=0'
    fi
}

mane() {
    # mane()    -- open manpage with venv's vim server
    ${GUIVIMBIN} ${VIMCONF} --remote-send "<ESC>:Man $@<CR>"
}
