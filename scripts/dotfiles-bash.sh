#!/bin/bash

print_bash_comments() {
    echo ""
    echo '::' 
    echo ""
    (cd $__DOTFILES;
    for f in $(ls etc/bash/*.sh); do
        echo "   # $f";
        cat $f | pyline -r '^\s*#\s(\s*.*)' 'rgx and "   " + rgx.group(1)';
        echo "   ";
        echo "   ";
    done)
}

print_bash_comments
