#!/bin/bash

# --- HELP AND USAGE ---
print_help() {
    cat << 'EOF'
setup_kubectl_oc.sh -- Installs and sets up kubectl and oc (OpenShift CLI) binaries.

This script downloads the latest stable kubectl and the oc CLI,
verifies their signatures,
installs them to the specified directory,
and configures shell autocompletion for the current shell (bash or zsh)

Usage: setup_kubectl_oc.sh [options] [install_dir]

Options:
    -h, --help                 Show this help message and exit.
    --kubectl                  Install kubectl.
    --oc                       Install oc CLI.
    --test                     Run basic validation/version commands after install.
    --install-deps             Install required OS package deps (curl, gpg, etc.) with
                               (apt-get, dnf, pacman, apk,)
    --install-dir=<dir>        Specify directory for binaries (default: $HOME/.bin).
    --download-cosign          Download cosign binary in current directory for kubectl verification.
    --install-cosign           Install cosign binary to the BIN_DIR (implies --download-cosign).
    --no-install-completions   Disable modifying .bashrc / .zshrc for shell autocompletion.
    --shells=<list>            Comma-separated list of shells to configure for autocompletion (default: bash,zsh).
    --skip-remote-check-k8s    Skip fetching the latest Kubernetes version from the network.
    --k8s-ver=<version>        Specific Kubernetes version to install (e.g., v1.30.0). Required if skipping remote check.
    --use-redhat-key-v4        Use Red Hat ML-DSA-87+Ed448 Release Key 4 instead of Key 2.
    -v, --verbose              Enable debug logging output.
    -q, --quiet                Suppress info-level output, only printing errors.
    --loglevel=<level>         Explicitly set log level (error/1, info/2, debug/3).

Args:
    install_dir (str, optional): Positional fallback to set installation directory.

Environment Variables:
    HOME: Used to determine the default installation directory and shell configuration files.
    PATH: The script warns the user to ensure the installation directory is in their PATH.

    SHELLS_TO_INSTALL: Comma-separated list of shells to configure for autocompletion (default: bash,zsh).
    SKIP_REMOTE_CHECK_K8S_VERSION: If non-empty, skips fetching the latest k8s version from the network.
    K8S_VER: The specific Kubernetes version to install (e.g., v1.30.0). Required if SKIP_REMOTE_CHECK_K8S_VERSION is set.

EOF
}

set -e

# --- LOGGING ---
LOG_LEVEL_ERROR=1
LOG_LEVEL_INFO=2
LOG_LEVEL_DEBUG=3
LOG_LEVEL=$LOG_LEVEL_INFO

logerror() {
    test "$LOG_LEVEL" -ge "$LOG_LEVEL_ERROR" && echo "[ERROR] $*" >&2
}
loginfo() {
    test "$LOG_LEVEL" -ge "$LOG_LEVEL_INFO" && echo "[INFO]  $*"
}
logdebug() {
    test "$LOG_LEVEL" -ge "$LOG_LEVEL_DEBUG" && echo "[DEBUG] $*"
}

set_loglevel() {
    case "$1" in
        error|ERROR|1) LOG_LEVEL=$LOG_LEVEL_ERROR ;;
        info|INFO|2) LOG_LEVEL=$LOG_LEVEL_INFO ;;
        debug|DEBUG|3) LOG_LEVEL=$LOG_LEVEL_DEBUG ;;
        *) echo "Unknown log level: $1" >&2; exit 1 ;;
    esac
}

# --- ARGUMENT HANDLING ---
parse_args() {
    BIN_DIR="$HOME/.bin"
    INSTALL_KUBECTL=false
    INSTALL_OC=false
    RUN_TESTS=false
    INSTALL_COMPLETIONS=true
    USE_REDHAT_KEY_V4=false
    INSTALL_DEPS=false
    DOWNLOAD_COSIGN=false
    INSTALL_COSIGN=false
    SHELLS_TO_INSTALL="${SHELLS_TO_INSTALL:-bash,zsh}"

    for arg in "$@"; do
        case "$arg" in
            -h|--help)
                print_help
                exit 0
                ;;
            -v|--verbose)
                LOG_LEVEL=$LOG_LEVEL_DEBUG
                ;;
            -q|--quiet)
                LOG_LEVEL=$LOG_LEVEL_ERROR
                ;;
            --loglevel=*)
                set_loglevel "${arg#*=}"
                ;;
            --kubectl)
                INSTALL_KUBECTL=true
                ;;
            --oc)
                INSTALL_OC=true
                ;;
            --test)
                RUN_TESTS=true
                ;;
            --download-cosign)
                DOWNLOAD_COSIGN=true
                ;;
            --install-cosign)
                INSTALL_COSIGN=true
                DOWNLOAD_COSIGN=true
                ;;
            --no-install-completions)
                INSTALL_COMPLETIONS=false
                ;;
            --shells=*)
                SHELLS_TO_INSTALL="${arg#*=}"
                ;;
            --skip-remote-check-k8s)
                export SKIP_REMOTE_CHECK_K8S_VERSION=true
                ;;
            --k8s-ver=*)
                export K8S_VER="${arg#*=}"
                ;;
            --use-redhat-key-v4)
                USE_REDHAT_KEY_V4=true
                ;;
            --install-deps)
                INSTALL_DEPS=true
                ;;
            --install-dir=*)
                BIN_DIR="${arg#*=}"
                ;;
            *)
                # Fallback for old positional arg
                if [[ ! "$arg" == --* ]]; then
                    BIN_DIR="$arg"
                fi
                ;;
        esac
    done

    # Default to both if none specified explicitly
    if [[ "$INSTALL_KUBECTL" == false && "$INSTALL_OC" == false ]]; then
        INSTALL_KUBECTL=true
        INSTALL_OC=true
    fi
}

get_os_id() {
    local os_id=""
    if [[ -f /etc/os-release ]]; then
        while IFS='=' read -r key value; do
            if [[ "$key" == "ID" ]]; then
                os_id="${value//[\"\']/}"
                break
            fi
        done < /etc/os-release
    else
        logerror "/etc/os-release could not be read. Unknown OS"
    fi
    echo "$os_id"
}

install_dependencies() {
    if [[ -f /etc/os-release ]]; then
        loginfo "--- Installing OS Dependencies ---"
        export _OS_ID="$(get_os_id)"
        case "$_OS_ID" in
            debian|ubuntu|pop|linuxmint)
                loginfo "Detected Debian-based OS ($_OS_ID). Using apt-get..."
                sudo apt-get update
                sudo apt-get install -y curl gnupg tar coreutils grep gawk
                ;;
            fedora|rhel|centos|rocky|almalinux)
                loginfo "Detected Red Hat-based OS ($_OS_ID). Using dnf..."
                sudo dnf install -y curl gnupg2 tar coreutils grep gawk
                ;;
            arch|manjaro)
                loginfo "Detected Arch-based OS ($_OS_ID). Using pacman..."
                sudo pacman -Sy --noconfirm curl gnupg tar coreutils grep gawk
                ;;
            alpine)
                loginfo "Detected Alpine Linux ($_OS_ID). Using apk..."
                sudo apk add curl gnupg tar coreutils grep gawk
                ;;
            *)
                logerror "Unsupported OS for pkg dependency installation: $_OS_ID"
                ;;
        esac
    fi

    if [[ "$INSTALL_KUBECTL" == true ]]; then
        if ! command -v cosign >/dev/null 2>&1 && [[ "$INSTALL_COSIGN" != true ]]; then
            loginfo "Note: 'cosign' is required to install kubectl but must be installed manually."
            loginfo "Please visit https://github.com/sigstore/cosign/releases for instructions."
            loginfo "Alternatively, append --install-cosign to your command."
        fi
    fi
}

check_dependencies() {
    local missing_deps=()
    local deps=("curl" "gpg" "tar" "sha256sum" "grep" "awk")

    # If installing cosign, we need jq to parse GitHub releases
    if [[ "$DOWNLOAD_COSIGN" == true ]]; then
        deps+=("jq")
    fi

    if [[ "$INSTALL_KUBECTL" == true ]]; then
        # if we are intentionally installing cosign as part of this run, don't fail dependency check for it
        if [[ "$INSTALL_COSIGN" != true ]]; then
            deps+=("cosign")
        fi
    fi

    for cmd in "${deps[@]}"; do
        #if ! command -v "$cmd" >/dev/null 2>&1; then
        if ! command -v "$cmd"; then
            missing_deps+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        logerror "Missing required dependencies: ${missing_deps[*]}"
        logerror "Please install them before running this script."
        exit 1
    fi
}

setup_env() {
    # Change BIN_DIR to your preferred local path
    # BIN_DIR=$(eval echo "$BIN_DIR")
    export BIN_DIR=$BIN_DIR

    # URLs to be maintained by script maintainers:
    # URL to fetch the latest stable Kubernetes version.
    export K8S_VER=${K8S_VER}

    # TODO: if k8s
    setup_env_k8s
    
    # TODO: if oc
    setup_env_oc

    # Create local bin directory
    mkdir -p "$BIN_DIR"

    # Temporary directory for work
    export START_DIR="$PWD"
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"
}

setup_env_k8s() { 
    # URL to fetch for latest version of k8s
    export K8S_LATEST_VER_TXT_URL="https://dl.k8s.io/release/stable.txt"
    # Fetch the latest version of k8s


    export LATEST_K8S_VER=
    if [ -z "${SKIP_REMOTE_CHECK_K8S_VERSION}" ]; then
        LATEST_K8S_VER=$(curl -L -s  "${K8S_LATEST_VER_TXT_URL}")
    fi

    if [ -z "${K8S_VER}" ]; then
        if [ -n "${LATEST_K8S_VER}" ]; then
            K8S_VER=$LATEST_K8S_VER
        else
            logerror "Could not determine the Kubernetes version to install."
            logerror "Please set K8S_VER explicitly (e.g., export K8S_VER=v1.30.0) or unset SKIP_REMOTE_CHECK_K8S_VERSION."
            return 2
        fi
    fi

    # URL to download kubectl binary from
    export K8S_URL="https://dl.k8s.io/release/$K8S_VER/bin/linux/amd64"

}

setup_env_oc() {
    # Base URL for the OpenShift v4 clients mirror.
    # Update if the mirror structure changes.
    export OC_MIRROR="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable"

    export RED_HAT_GPG_KEY=
    export RED_HAT_GPG_FINGERPRINT=

    # URL for the Red Hat Release GPG Key used for verifying the OpenShift client.
    # Update if Red Hat rotates this key.
    # Check https://access.redhat.com/security/team/key to find current keys.
    # To find the fingerprint for a key matching a URL, download it and run:
    #   gpg --with-colons --import-options show-only --import key.txt | awk -F: '$1 == "fpr" {print $10; exit}'
    if [[ "$USE_REDHAT_KEY_V4" == true ]]; then
        # Currently using: "Red Hat, Inc. (release key 4) <security@redhat.com>" (ML-DSA-87+Ed448/D246D6276AFEDF8F)
        RED_HAT_GPG_KEY="https://access.redhat.com/security/data/6afedf8f.txt"
        RED_HAT_GPG_FINGERPRINT="FCD355B305707A62DA143AB6E422397E50FE8467A2A95343D246D6276AFEDF8F"
    else
        # Currently using: "Red Hat, Inc. (release key 2) <security@redhat.com>"
        RED_HAT_GPG_KEY="https://access.redhat.com/security/data/fd431d51.txt"
        RED_HAT_GPG_FINGERPRINT="567E347AD0044ADE55BA8A5F199E2F91FD431D51"
    fi
}

setup_cosign() {
    loginfo "--- Downloading and Verifying cosign ---"
    local organdrepo="sigstore/cosign"
    local jsonpath="cosign_latest.json"

    curl -sSfL "https://api.github.com/repos/${organdrepo}/releases/latest" -o "${jsonpath}"

    local cosign_url
    cosign_url=$(jq -r '.assets[] | select(.name == "cosign-linux-amd64") | .browser_download_url' "${jsonpath}")
    local checksum_url
    checksum_url=$(jq -r '.assets[] | select(.name == "cosign_checksums.txt") | .browser_download_url' "${jsonpath}")

    if [[ -z "$cosign_url" || -z "$checksum_url" ]]; then
        logerror "Could not find cosign download URLs in GitHub release."
        return 1
    fi

    loginfo "Downloading cosign from $cosign_url"
    # Download cosign binary and checksums
    curl -sSfL "$cosign_url" -o cosign-linux-amd64
    curl -sSfL "$checksum_url" -o cosign_checksums.txt

    # Verify checksum
    # Note: `grep` finds the exact line matching the filename we downloaded and isolates it
    grep -E " cosign-linux-amd64" cosign_checksums.txt > cosign_single_checksum.txt
    sha256sum -c cosign_single_checksum.txt --ignore-missing

    chmod +x cosign-linux-amd64

    if [[ "$INSTALL_COSIGN" == true ]]; then
        mv cosign-linux-amd64 "$BIN_DIR/cosign"
        loginfo "Installed cosign to $BIN_DIR/cosign"
    elif [[ "$DOWNLOAD_COSIGN" == true ]]; then
        cp cosign-linux-amd64 "$START_DIR/cosign"
        loginfo "Downloaded cosign to $START_DIR/cosign"
    fi
}


setup_kubectl() {
    loginfo "--- Verifying and Installing kubectl ($K8S_VER) ---"
    for file in kubectl kubectl.sig kubectl.cert; do
        curl -sSfL "$K8S_URL/$file" -o "$file"
    done

    logdebug "Verifying kubectl using cosign"
    # Verify using Cosign (Keyless/OIDC)
    cosign verify-blob kubectl \
        --signature kubectl.sig \
        --certificate kubectl.cert \
        --certificate-identity krel-staging@k8s-releng-prod.iam.gserviceaccount.com \
        --certificate-oidc-issuer https://accounts.google.com

    chmod +x kubectl
    mv kubectl "$BIN_DIR/kubectl"

}

test_kubectl() {
    loginfo "Testing kubectl version:"
    "${BIN_DIR}/kubectl" --version

}

setup_oc() {
    loginfo "--- Verifying and Installing oc CLI ---"
    curl -sSfL "$OC_MIRROR/openshift-client-linux.tar.gz" -o oc.tar.gz
    curl -sSfL "$OC_MIRROR/sha256sum.txt" -o sha256sum.txt
    curl -sSfL "$OC_MIRROR/sha256sum.txt.sig" -o sha256sum.txt.sig

    # Import Red Hat Release Key and verify
    loginfo "Fetching Red Hat GPG key"
    curl -sSfL "$RED_HAT_GPG_KEY" -o rh_key.txt
    
    local fetched_fpr
    fetched_fpr=$(gpg --with-colons --import-options show-only --import rh_key.txt | awk -F: '$1 == "fpr" {print $10; exit}')
    
    if [[ "$fetched_fpr" != "$RED_HAT_GPG_FINGERPRINT" ]]; then
        logerror "Red Hat GPG key fingerprint mismatch!"
        logerror "Expected: $RED_HAT_GPG_FINGERPRINT"
        logerror "Got:      $fetched_fpr"
        exit 1
    fi
    
    # Also verify the key exists on a public keyserver
    loginfo "Checking Red Hat GPG key fingerprint on ubuntu keyserver"
    if ! gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys "$RED_HAT_GPG_FINGERPRINT" &>/dev/null; then
        logerror "Failed to verify GPG key fingerprint on keyserver.ubuntu.com!"
        exit 1
    fi
    
    gpg --import rh_key.txt &>/dev/null
    gpg --verify sha256sum.txt.sig sha256sum.txt
    sha256sum -c sha256sum.txt --ignore-missing

    # Unpack and move
    tar -xzf oc.tar.gz
    chmod +x oc
    mv oc "$BIN_DIR/oc"

}

test_oc() {
    logdebug "Testing oc version:"
    "${BIN_DIR}/oc" --version
}


setup_kubectl_oc_shell_completion() {
    loginfo "--- Setting up Shell Autocompletion ---"
    
    IFS=',' read -ra SHELL_LIST <<< "$SHELLS_TO_INSTALL"
    for current_shell in "${SHELL_LIST[@]}"; do
        local comp_file=""

        if [[ "$current_shell" == "bash" ]]; then
            comp_file="$HOME/.bashrc"
        elif [[ "$current_shell" == "zsh" ]]; then
            comp_file="$HOME/.zshrc"
        fi

        if [[ -n "$comp_file" ]]; then
            # Add only if not already present
            grep -q "kubectl completion" "$comp_file" || (printf '\n'; echo "source <(kubectl completion $current_shell)"; printf '\n') >> "$comp_file"
            grep -q "oc completion" "$comp_file" || (printf '\n'; echo "source <(oc completion $current_shell)"; printf '\n') >> "$comp_file"
            loginfo "Autocompletion added to $comp_file for $current_shell"
        fi
    done
}


setup_kubectl_oc_main() {

    parse_args "$@"

    if [[ "$INSTALL_DEPS" == true ]]; then
        install_dependencies
    fi

    check_dependencies

    setup_env

    if [[ "$DOWNLOAD_COSIGN" == true ]]; then
        setup_cosign
    fi

    if [[ "$INSTALL_KUBECTL" == true ]]; then
        setup_kubectl
    fi

    if [[ "$INSTALL_OC" == true ]]; then
        setup_oc
    fi

    # these maybe should be done as a different user; not as the package install user
    if [[ "$RUN_TESTS" == true ]]; then
        if [[ "$INSTALL_KUBECTL" == true ]]; then test_kubectl; fi
        if [[ "$INSTALL_OC" == true ]]; then test_oc; fi
    fi

    if [[ "$INSTALL_COMPLETIONS" == true ]]; then
        setup_kubectl_oc_shell_completion
    fi

    # Cleanup
    rm -rf "$TMP_DIR"

    loginfo "--- Installation Complete ---"
    loginfo "Binaries installed to: $BIN_DIR"
    
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        loginfo "IMPORTANT: '$BIN_DIR' is not in your PATH."
        loginfo "To add it temporarily for this session, run:"
        loginfo "    export PATH=\"$BIN_DIR:\$PATH\""
        loginfo "To add it permanently, add the above line to your shell's rc file (e.g. ~/.bashrc or ~/.zshrc)."
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_kubectl_oc_main "$@"
fi