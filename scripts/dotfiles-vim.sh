#!/bin/bash

print_dotvim_comments() {
    echo ""
    echo '::' 
    echo ""
    (cd $__DOTFILES;

    for f in $(ls etc/vim/vimrc*); do
        echo "   # $f";
        cat $f | pyline -r '^\s*"\s(\s*.*)' 'rgx and "   " + rgx.group(1)';
        echo "   ";
        echo "   ";
    done)
}

print_dotvim_comments
