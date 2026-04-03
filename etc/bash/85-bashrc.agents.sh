
## 85-bashrc.agents.sh

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    source "$(code --locate-shell-integration-path bash)"
    export GIT_PAGER=
fi

export __AGENT=1
