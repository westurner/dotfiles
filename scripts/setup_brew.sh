#!/bin/sh -x

BREW_RB_URL="https://raw.github.com/mxcl/homebrew/go/install"
if [ ! -x "/usr/local/bin/brew" ]; then
    curl -fsSL "${BREW_RB_URL}" > brew_install.rb
    ruby ./brew_install.rb
fi
for formula in $(cat $__DOTFILES/etc/brew/brew.list); do
    brew install $formula
done
