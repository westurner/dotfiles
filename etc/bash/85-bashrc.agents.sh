#!/bin/bash
## 85-bashrc.agents.sh

remove_venvprompt_prefix() {

    ps1_extra_prefix="\[\](dotfiles) \[\]${VENVPROMPT}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ \[\]\[\]"
    ps1_expected="\[\]${VENVPROMPT}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ \[\]\[\]"

    ps1="${ps1_extra_prefix}"

    if [ ! "${ps1}" = "${ps1_expected}" ]; then
        printf "ERROR: ps1 != ps2 \n"
        printf "ps1=%s\n" "${ps1}"
        printf "pse=%s\n" "${ps1_expected}"
    fi

    unset ps1_extra_prefix ps1_expected ps1
}

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    echo "INFO: bashrc.agents.sh Running in vscode"
    vscode_shell_integration_sh="$(code --locate-shell-integration-path bash)"
    source "${vscode_shell_integration_sh}"
    export GIT_PAGER=
    #export GIT_PAGER=sh -x -c -- GIT_CONFIG_PARAMETERS="'color.ui=never'" GIT_PAGER=code\ --wait\ -
    if type -a code.sh.stdin.sh; then
        export GIT_PAGER=code.sh.stdin.sh
    fi
    export EDITOR=code
    export GIT_EDITOR=code\ --wait

    if [ -n "${VIRTUAL_ENV}" ]; then
        workon "${VIRTUAL_ENV}"
    else
        remove_venvprompt_prefix
    fi

fi

export __AGENT=1
