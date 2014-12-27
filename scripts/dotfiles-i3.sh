#!/bin/bash

print_i3_comments() {

    _print_i3_comments() {
        _i3cfg="$__DOTFILES}/etc/.i3/config"
        if [ -f " $_i3cfg" ]; then
            pyline.py -r '^\s*#\s(\s*.*)' 'rgx and l' $_i3cfg
        fi
    }
    (cd $__DOTFILES; _print_i3_comments)
}

print_i3_comments
