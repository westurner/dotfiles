

## _configure_lesspipe  -- (less <file.zip> | lessv)
_configure_lesspipe() {
    lesspipe=$(which lesspipe.sh 2>/dev/null || false)
    if [ -n "${lesspipe}" ]; then
        source <(${lesspipe})
    fi
}
_configure_lesspipe


## vimpager     -- call vimpager
vimpager() {
    # TODO: lesspipe
    _PAGER=$(which vimpager)
    if [ -x "${_PAGER}" ]; then
        ${_PAGER} $@
    else
        echo "error: vimpager not found. (see lessv: 'lessv $@')"
    fi
}


### less commands -- lessv, lessg, lesse
## lessv    -- less with less.vim and regular vim
lessv () {

    ## start Vim with less.vim and vim
    # Read stdin if no arguments were given.
    if [ -t 1 ]; then
        if [ $# -eq 0 ]; then
            ${VIMBIN} --cmd "let g:tinyvim=1" \
                --cmd "runtime! macros/less.vim" \
                --cmd "set nomod" \
                --cmd "set noswf" \
                -c "set colorcolumn=0" \
                -c "map <C-End> <Esc>G" \
                -
        else
            ${VIMBIN} \
                --cmd "let g:tinyvim=1" \
                --cmd "runtime! macros/less.vim" \
                --cmd "set nomod" \
                --cmd "set noswf" \
                -c "set colorcolumn=0" \
                -c "map <C-End> <Esc>G" \
                $@
        fi
    else
        # Output is not a terminal, cat arguments or stdin
        if [ $# -eq 0 ]; then
            less
        else
            less "$@"
        fi
    fi
}

## lessg    -- less with less.vim and gvim / mvim
lessg() {
    VIMBIN=${GUIVIMBIN} lessv $@
}

## lesse    -- less with current venv's vim server
lesse() {
    ${EDITOR} $@
}

### Man commands -- manv, mang, mane
## manv     -- view manpages in vim
manv() {
    alias man_="/usr/bin/man"
    if [ $# -eq 0 ]; then
        /usr/bin/man
    else
        #if [ "$1" == "man" ]; then
        #    exit 0
        #fi

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

## mang()   -- view manpages in gvim / mvim
mang() {
    if [ $# -eq 0 ]; then
        /usr/bin/man
    else
        $GUIVIMBIN \
            --noplugin \
            -c "runtime ftplugin/man.vim" \
            -c "Man $*" \
            -c 'silent! only' \
            -c 'nmap q :q<CR>' \
            -c 'set nomodifiable' \
            -c 'set colorcolumn=0'
    fi
}

## mane()   -- open manpage with venv's vim server
mane() {
    $GUIVIMBIN --servername ${VIRTUAL_ENV_NAME} --remote-send "<ESC>:Man $@<CR>"
}
