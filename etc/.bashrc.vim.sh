## ViM

vimpager() {
    # TODO: lesspipe
    _PAGER="${HOME}/bin/vimpager"
    if [ -x $_PAGER ]; then
        export PAGER=$_PAGER
    else
        _PAGER="/usr/local/bin/vimpager"
        if [ -x $_PAGER ]; then
            export PAGER=$_PAGER
        fi
    fi
}

less_ () {
    ## start Vim with less.vim.
    # Read stdin if no arguments were given.
    if test -t 1; then
        if test $# = 0; then
        vim -c "let g:tinyvim=1" \
            --cmd "runtime! macros/less.vim" \
            --cmd "set nomod" \
            --cmd "set noswf" \
            -c "set colorcolumn=0" \
            -c "map <C-End> <Esc>G" \
            -
        else
        vim --noplugin \
            -c "let g:tinyvim=1" \
            -c "runtime! macros/less.vim" \
            --cmd "set nomod" \
            --cmd "set noswf" \
            -c "set colorcolumn=0" \
            -c "map <C-End> <Esc>G" \
            $@
        fi
    else
        # Output is not a terminal, cat arguments or stdin
        if test $# = 0; then
            less
        else
            less "$@"
        fi
    fi
}

# view manpages in vim
man() {
    alias man_="/usr/bin/man"
    if [ $# -eq 0 ]; then
        /usr/bin/man
    else
        #if [ "$1" == "man" ]; then
        #    exit 0
        #fi

        #/usr/bin/whatis "$@" >/dev/null
        vim \
            --noplugin \
            -c "runtime ftplugin/man.vim" \
            -c "Man $*" \
            -c 'silent! only' \
            -c 'nmap q :q<CR>' \
            -c 'set nomodifiable' \
            -c 'set colorcolumn=0'
    fi
}


