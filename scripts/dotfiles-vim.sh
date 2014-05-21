#!/bin/bash

print_dotvim_comments() {
    echo ""
    echo '::' 
    echo ""
    (cd $__DOTFILES;
    cat etc/vim/vimrc \
        etc/vim/vimrc.bundles \
        | pyline -r '^\s*"\s(\s*.*)' 'rgx and "   " + rgx.group(1)')
}

print_dotvim_comments
