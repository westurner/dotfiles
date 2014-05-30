#!/bin/bash

print_i3_comments() {
    echo ""
    echo '::' 
    echo ""
    (cd $__DOTFILES;
    cat etc/.i3/config \
        | pyline -r '^\s*#\s(\s*.*)' 'rgx and "   " + rgx.group(1)')
}

print_i3_comments
