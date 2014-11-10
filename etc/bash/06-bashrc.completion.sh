

_configure_completion() {
    ## configure bash completion (`complete -p` to list completions)
    if [ -n "$__IS_MAC" ]; then
        # configure brew (brew install bash-completion)
        BREW=$(which brew 2>/dev/null || false)
        if [ -n "${BREW}" ]; then
            brew_prefix=$(brew --prefix)
            if [ -f ${brew_prefix}/etc/bash_completion ]; then
                source ${brew_prefix}/etc/bash_completion
            fi
        fi
    fi
}
_configure_completion
