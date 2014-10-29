#!/bin/bash

print_i3_comments() {
    (cd $__DOTFILES;
    cat etc/.i3/config \
        | pyline -r '^\s*#\s(\s*.*)' 'rgx and l')
}

print_i3_comments
