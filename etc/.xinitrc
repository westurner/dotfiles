#!/bin/bash
#
# ~/.xinitrc
#
# Executed by startx

## __DOTFILES path (default: ~/-dotfiles)
#__DOTFILES=${__DOTFILES:-"${HOME}/-dotfiles"}
## start xlck.sh [xautolock, xlock, i3lock] (see also: .i3/config)
bash "$__DOTFILES/scripts/xlck.sh" -S || echo 'xlck.sh -S failed'
## Start i3wm
exec i3
