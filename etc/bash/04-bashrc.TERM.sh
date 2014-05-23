
## set TERM [man terminfo]

#  CLICOLOR=1   # ls colors
export CLICOLOR=1

#  CLICOLOR_256=1
export CLICOLOR_256=$CLICOLOR


configure_TERM() {
    term=$1
    if [ -n "${TERM}" ]; then
        __term=${TERM}
    fi
    if [ -n "${term}" ]; then
        export TERM="${term}"
    else
        if [ -n "${TMUX}" ] ; then
            # tmux
            export TERM="screen"
        elif [ -n "$(echo $TERMCAP | grep -q screen)" ]; then
            # screen
            export TERM="screen"
        elif [ -n "${ZSH_TMUX_TERM}" ]; then
            # zsh+tmux: oh-my-zsh/plugins/tmux/tmux.plugin.zsh
            export TERM="${ZSH_TMUX_TERM}"
        fi
        if [ -n "${CLICOLOR_256}" ]; then
            (echo $TERM | grep -v -q 256color) && \
                export TERM="${TERM}-256color"
        fi
    fi
    if [ "${TERM}" != "${__term}" ]; then
        echo "# TERM='${__term}'"
        echo "TERM='${TERM}'"
    fi
}

configure_TERM
