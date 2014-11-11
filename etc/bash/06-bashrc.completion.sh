
### bashrc.completion.sh

_configure_bash_completion() {
    # _configure_bash_completion()  -- configure bash completion
    #                               note: `complete -p` lists completions

    if ! shopt -oq posix; then
        return
    fi
    if [ -n "$__IS_MAC" ]; then
        #configure brew (brew install bash-completion)
        BREW=$(which brew 2>/dev/null || false)
        if [ -n "${BREW}" ]; then
            brew_prefix=$(brew --prefix)
            if [ -f ${brew_prefix}/etc/bash_completion ]; then
                source ${brew_prefix}/etc/bash_completion
            fi
        fi
    else
        if [ -f /etc/bash_completion ]; then
            source /etc/bash_completion
        fi
    fi
}
_configure_bash_completion
