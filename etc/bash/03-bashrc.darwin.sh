#!/usr/bin/env bash
### bashrc.darwin.sh

# softwareupdate                -- install OSX updates
#  | Docs: https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man8/softwareupdate.8.html
#  softwareupdate -l        # --list
#  softwareupdate -i --all  # --install --all
#  softwareupdate -i -r     # --install --recommended

# Mac Boot-time modifiers: (right after the chime)
#
#  Option    -- boot to boot disk selector menu
#  C         -- boot from CD/DVD
#  Shift     -- boot into Safe mode
#  Command-V -- boot into verbose mode
#   sudo nvram boot-args="-v"  # always boot verbosely
#   sudo nvram boot-args=""    # boot normally
#   sudo nvram -p              # print current nvram settings

if [ -z "${__IS_MAC}" ]; then
    return
fi
# if __IS_MAC:

export _FINDERBIN="/System/Library/CoreServices/Finder.app"

# shellcheck disable=2120
function finder {
    ## finder()          -- open Finder.app
    if [ -z "$*" ]; then
        open "${_FINDERBIN}"
    else
        open -R "${@}"
    fi
}

function finder_killall {
    # finder-killall()  -- close all Finder.app instances
    killall Finder "$_FINDERBIN";
}

function finder_restart {
    # finder-restart()  -- close all and start Finder.app
    finder-killall
    finder
}

function finder_hide_hidden {
    # finder-hide-hidden()    -- hide .hidden files in Finder.app
    #                            (and close all Finder windows)
    defaults write com.apple.finder AppleShowAllFiles NO
    finder-killall
}

function finder_show_hidden {
    # finder-show-hidden()    -- show .hidden files in Finder.app
    #                            (and close all Finder windows)
    defaults write com.apple.finder AppleShowAllFiles YES
    finder-killall
}


