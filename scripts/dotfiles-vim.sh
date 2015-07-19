#!/bin/bash

print_dotvim_comments() {
    (cd $__DOTFILES;
    for f in $(ls etc/vim/vimrc*); do
        echo "   # $f";
        cat $f | pyline.py -r '^\s*"\s(\s*.*)' 'rgx and l';
        echo "   ";
        echo "   ";
    done)
}

print_dotvim_comments
