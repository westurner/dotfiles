#!/bin/bash
#
# Install VSCode and extensions on Fedora
#
# Usage:
# ```bash
# ./setup_vscode.sh -a  # this will sudo prompt
# ./setup_vscode.sh -i  # this will not sudo prompt
# ./setup_vscode.sh -h 
# ```
#
# References:
# - https://code.visualstudio.com/docs/setup/linux
# - https://fedoraproject.org/wiki/Visual_Studio_Code

VSCODE_REPO_PATH='/etc/yum.repos.d/vscode.repo'

function _setup_vscode_add_repo_dnf {
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > '"${VSCODE_REPO_PATH}"
    dnf check-update
}

function _setup_vscode_install {
    if [ ! -f "${VSCODE_REPO_PATH}" ]; then
        _setup_vscode_add_repo_dnf
    fi
    which code
    dnf install -y code
    which code
}

function _setup_vscode_extensions {
    (set -x; __setup_vscode_extensions)
}

function __setup_vscode_extensions {
    local _before="vscode.extensions.before.txt"
    local _after="vscode.extensions.after.txt"
    code --list-extensions --show-versions | tee "${_before}"

    cmd="code --install-extension"
    ## .gitignore
    $cmd "stubailo.ignore-gitignore"
    ## Make
    $cmd "alexnesnes.makerunner"
    ## Vim
    $cmd "vscodevim.vim"
    $cmd "mattn.openvim"
    $cmd "tickleforce.scrolloff"
    $cmd "stkb.rewrap"
    ## reStructuredText
    $cmd "lextudio.restructuredtext"
    ## Python
    $cmd "peterjausovec.vscode-docker"
    $cmd "donjayamanne.python-extension-pack"
    # $cmd "ms-python.python"
    $cmd "jithurjacob.nbpreviewer"
    ## JS
    $cmd "mgmcdermott.vscode-language-babel"
    ## Ansible
    $cmd "vscoss.vscode-ansible"

    code --list-extensions --show-versions | tee "${_after}"
    (set -x; diff -Nau "${_before}" "${_after}")
}

function _setup_vscode_settings {
    #cat << EOF
    # "telemetry.enableTelemetry": false
    # "telemetry.enableCrashReporter": false

    # "editor.fontFamily": "'Source Code Pro for Powerline', 'Droid Sans Mono', 'monospace', monospace, 'Droid Sans Fallback'"
    # "editor.fontSize": 12
    # "editor.wordWrap": "wordWrapColumn"
    # "editor.wordWrapColumn": 80

    # # https://code.visualstudio.com/docs/python/linting#_specific-linters
    #EOF
    echo "TODO: Settings"
    return 2
}

function _setup_vscode_status {
    sudo -u nobody code --version
    # sudo -u nobody code --list-extensions
}

function _setup_vscode_remove_html_handler {
    local file="${HOME}/.local/share/applications/code-url-handler.desktop"
    (set -x; test -f "${file}" && rm -fv "${file}")
    local file="/usr/share/applications/code-url-handler.desktop"
    (set -x; test -f "${file}" && sudo rm -fv "${file}")
}

THISFILE="${0}"

function _setup_vscode_usage {
    echo "${THISFILE} : install VSCode, extensions, and settings"
    echo ""
    echo " status       -- print VSCode version"
    echo " -i | install -- install VSCode"
    echo " -e | extensions -- install VSCode extensions (for the current user)"
    echo " -s | settings   -- install VSCode settings (for the current user)"
    echo " -a | all        -- install VSCode; extensions, and settings (for the current user)"
    echo " --rmh | rmhtmlhandler -- remove VSCode default html handler"
    echo ""
}

function _setup_vscode_main {
    if [ -z "${@}" ]; then
        _setup_vscode_usage
        return 1
    fi
    for arg in ${@}; do
        case "$arg" in
            -i|install)
                _setup_vscode_install
                _setup_vscode_remove_html_handler
                _setup_vscode_status
                ;;
            status)
                _setup_vscode_status
                ;;
            -e|installextensions)
                _setup_vscode_extensions
                ;;
            -s|settings)
                _setup_vscode_settings
                ;;
            -a|all)
                # These require sudo
                sudo bash "${THISFILE}" -i      # _setup_vscode_install
                sudo bash "${THISFILE}" status  # _setup_vscode_status
                # These should not be run with sudo
                _setup_vscode_extensions
                _setup_vscode_settings
                ;;
            --rmh|rmhtmlhandler)
                _setup_vscode_remove_html_handler
                ;;
            -h|--help|help)
                _setup_vscode_usage
                return 1
                ;;
        esac
    done
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    _setup_vscode_main "${@}"
    exit "$?"
fi
