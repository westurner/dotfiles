#!/bin/bash
#
# ~/.xinitrc
#
# Executed by startx

__DOTFILES=${__DOTFILES:-"${HOME}/-dotfiles"}

# start _xautolock &
bash "$__DOTFILES/scripts/xlck.sh" -S
