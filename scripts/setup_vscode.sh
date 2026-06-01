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


function _setup_vscode_flatpak_tmpdir {
    set -e

    # Define a shared temp directory within the Flatpak data directory so it maps 1:1 
    # between the host and the container.
    export SHARED_TMP_DIR="${HOME}/.var/app/com.visualstudio.code/data/devcontainer-tmp"
    (set -x SHARED_TMP_DIR="${SHARED_TMP_DIR}")

    echo "1. Creating shared temp directory at $SHARED_TMP_DIR"
    (set -x; mkdir -p "$SHARED_TMP_DIR")


    echo "2. Applying SELinux context so Podman can mount it..."
    (set -x; 
    ls -aldZ "${SHARED_TMP_DIR}";
    # container_file_t (or svirt_sandbox_file_t) allows the container runtime to access it
    chcon -Rt container_file_t "$SHARED_TMP_DIR";
    ls -aldZ "${SHARED_TMP_DIR}"
    )

    echo "3. Configuring VS Code Flatpak to use this directory as TMPDIR..."
    # This override ensures VS Code (and the Dev Containers extension) writes temporary
    # build contexts to our shared folder instead of the isolated Flatpak /tmp
    (set -x; flatpak override --user --env=TMPDIR="$SHARED_TMP_DIR" com.visualstudio.code)

    echo "=========================================================================="
    echo "Setup complete! "
    (set -x; declare -p SHARED_TMP_DIR)
    echo "Please completely close VS Code to ensure the new environment variable takes effect:"
    echo "   flatpak kill com.visualstudio.code"
    echo ""
    echo "Then reopen VS Code and try rebuilding your Dev Container."
    echo "=========================================================================="
}


THISFILE="${0}"

function _setup_vscode_usage {
    echo "${THISFILE} : install VSCode, extensions, and settings"
    echo ""
    echo " status       -- print VSCode version"
    echo " -i | install -- install VSCode"
    echo " -e | extensions -- install VSCode extensions (for the current user)"
    echo " -s | settings   -- install VSCode settings (for the current user)"
    echo " --tmpdir        -- install VSCode tmpdir ('chcon -Rt container_file_t \$TMPDIR')"
    echo " -a | all        -- install VSCode; extensions, and settings (for the current user)"
    echo " --rmh | rmhtmlhandler -- remove VSCode default html handler"
    echo ""
}

function _setup_vscode_main {
    if [ -z "${*}" ]; then
        _setup_vscode_usage
        return 1
    fi
    for arg in "${@}"; do
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
            --tmpdir|tmpdir)
                _setup_vscode_flatpak_tmpdir
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
