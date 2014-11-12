
### 30-bashrc.xlck.sh
## xlck     -- minimal X screensaver

_setup_xlck() {
    # _setup_xlck() -- source ${__DOTFILES}/etc/xlck.sh (if -z __IS_MAC)
    if [ -z "${__IS_MAC}" ]; then
        source "${__DOTFILES}/etc/xlck.sh"
    fi
}

    # xlock_lock        -- lock the current display
    # _xlck_xlck()      -- start xlock (white on black w/ a 3 second delay)
