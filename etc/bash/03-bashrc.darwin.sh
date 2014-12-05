
### bashrc.darwin.sh

# softwareupdate                -- install OSX updates
#  | Docs: https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man8/softwareupdate.8.html
#  softwareupdate -l        # --list
#  softwareupdate -i --all  # --install --all
#  softwareupdate -i -r     # --install --recommended

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
