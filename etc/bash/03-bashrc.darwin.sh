
### bashrc.darwin.sh

# Docs:
#  softwareupdate -l  # list
#  softwareupdate -i --all
#  softwareupdate -i -r

if [ -z "${__IS_MAC}" ]; then
    return
fi
# if __IS_MAC:

export _FINDERBIN="/System/Library/CoreServices/Finder.app"

finder () {
    # finder()    -- open Finder.app
    if [ -z "$@" ]; then
        open "${_FINDERBIN}"
    else
        open -R $@
    fi
}

finder-killall() {
    # finder-killall()  -- close all Finder.app instances
    killall Finder $_FINDERBIN;
}

finder-restart() {
    # finder-restart()  -- close all and start Finder.app
    finder-killall
    finder
}

finder-show-hidden () {
    # finder-show-hidden()    -- show .hidden files in Finder.app
    defaults write com.apple.finder AppleShowAllFiles YES
    finder-killall
}

finder-hide-hidden () {
    # finder-show-hidden()    -- show .hidden files in Finder.app
    defaults write com.apple.finder AppleShowAllFiles YES
    finder-killall
}
