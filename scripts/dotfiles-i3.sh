#!/bin/bash

_print_i3_comments() {
    _i3cfg="${__DOTFILES}/etc/.i3/config"
    if [ -f "$_i3cfg" ]; then
        cat $_i3cfg | \
            ${__DOTFILES}/scripts/pyline.py -r '^\s*#\s(\s*.*)' 'rgx and l'
    fi
}

print_i3_comments() {

    (cd $__DOTFILES; _print_i3_comments)
}

print_i3_comments
