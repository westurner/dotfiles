#!/bin/bash
## setup_git_gpg.sh
##  Set up a GPG key for use with GitHub and configure Git signing.

# KEY_TYPE (str): GPG master key type (certify only). Default: RSA
KEY_TYPE="${KEY_TYPE:-RSA}"

# KEY_LENGTH (int): GPG master key length in bits. Default: 4096
KEY_LENGTH="${KEY_LENGTH:-4096}"

# KEY_EXPIRE (str): Key expiration. 0 = no expiry. Default: 0
KEY_EXPIRE="${KEY_EXPIRE:-0}"

# SUBKEY_TYPE (str): GPG subkey type for signing. Default: RSA
SUBKEY_TYPE="${SUBKEY_TYPE:-RSA}"

# SUBKEY_LENGTH (int): GPG subkey length in bits. Default: 4096
SUBKEY_LENGTH="${SUBKEY_LENGTH:-4096}"

# SUBKEY_EXPIRE (str): Subkey expiration. 0 = no expiry. Default: 1y
SUBKEY_EXPIRE="${SUBKEY_EXPIRE:-1y}"

# USE_SUBKEYS (bool): If 1, generate a certify-only master key with sign/encrypt/auth subkeys.
USE_SUBKEYS="${USE_SUBKEYS:-0}"

# GPG_LOOPBACK (bool): If 1, pass --pinentry-mode loopback to gpg commands.
# Required in headless/container environments where no graphical pinentry is available.
GPG_LOOPBACK="${GPG_LOOPBACK:-1}"

_gpg_loopback_args() {
    #  _gpg_loopback_args() -- echo --pinentry-mode loopback if GPG_LOOPBACK=1
    if [ "${GPG_LOOPBACK}" = "1" ]; then
        echo "--pinentry-mode loopback"
    fi
}


gpg_configure_agent_loopback() {
    #  gpg_configure_agent_loopback() -- enable allow-loopback-pinentry in gpg-agent.conf
    #  Required in headless/container environments. Reloads the gpg-agent config.
    local conf="${GNUPGHOME:-${HOME}/.gnupg}/gpg-agent.conf"
    mkdir -p "$(dirname "${conf}")"
    if grep -qF 'allow-loopback-pinentry' "${conf}" 2>/dev/null; then
        echo "allow-loopback-pinentry already set in ${conf}"
    else
        echo 'allow-loopback-pinentry' >> "${conf}"
        echo "Added allow-loopback-pinentry to ${conf}"
    fi
    # Kill any running agent so the next gpg call starts a fresh one with the new config.
    # gpgconf --reload sends SIGHUP (hot-reload) to the running agent if it supports it.
    (set -x
        gpgconf --kill gpg-agent
        gpg-connect-agent /bye 2>/dev/null || true
    )
    echo "gpg-agent restarted with updated config."
}


gpg_generate_key() {
    #  gpg_generate_key() -- interactively generate a new GPG key
    if [ "${GPG_LOOPBACK}" = "1" ]; then
        gpg_configure_agent_loopback
    fi
    # shellcheck disable=SC2046
    (set -x; gpg $(_gpg_loopback_args) --full-generate-key)
}


gpg_generate_key_batch() {
    #  gpg_generate_key_batch() -- generate a GPG key non-interactively
    #    $1 (str) -- real name
    #    $2 (str) -- email address
    #    $3 (str) -- passphrase (optional, empty = no passphrase)
    #  If USE_SUBKEYS=1, generates a certify-only master key with no default subkey;
    #  subkeys are added separately via gpg_add_subkeys().
    local name="${1:?ERROR: name required}"
    local email="${2:?ERROR: email required}"
    local passphrase="${3:-}"  # empty = no passphrase

    local batch_input
    if [ "${USE_SUBKEYS}" = "1" ]; then
        # Master key: certify only (no Sign/Encrypt capability on primary key)
        batch_input=$(cat <<EOF
%echo Generating certify-only master key for ${email}
Key-Type: ${KEY_TYPE}
Key-Length: ${KEY_LENGTH}
Key-Usage: cert
Name-Real: ${name}
Name-Email: ${email}
Expire-Date: ${KEY_EXPIRE}
Passphrase: ${passphrase}
%commit
%echo Master key done
EOF
)
    else
        batch_input=$(cat <<EOF
%echo Generating GPG key for ${email}
Key-Type: ${KEY_TYPE}
Key-Length: ${KEY_LENGTH}
Subkey-Type: ${SUBKEY_TYPE}
Subkey-Length: ${SUBKEY_LENGTH}
Name-Real: ${name}
Name-Email: ${email}
Expire-Date: ${KEY_EXPIRE}
Passphrase: ${passphrase}
%commit
%echo done
EOF
)
    fi
    # shellcheck disable=SC2046
    if [ "${GPG_LOOPBACK}" = "1" ]; then
        gpg_configure_agent_loopback
    fi
    echo "${batch_input}" | (set -x; gpg --batch $(_gpg_loopback_args) --gen-key)
}


gpg_add_subkeys() {
    #  gpg_add_subkeys() -- add sign, encrypt, and auth subkeys to a master key
    #    $1 (str) -- master key ID or email
    #  Uses SUBKEY_TYPE, SUBKEY_LENGTH, SUBKEY_EXPIRE env vars.
    #  Requires gpg >= 2.1 (uses --quick-add-key).
    local key_id="${1:?ERROR: master key ID or email required}"
    echo "Adding subkeys to master key: ${key_id}"
    (set -x
        gpg --quick-add-key "${key_id}" "${SUBKEY_TYPE}" sign  "${SUBKEY_EXPIRE}"
        gpg --quick-add-key "${key_id}" "${SUBKEY_TYPE}" encr  "${SUBKEY_EXPIRE}"
        gpg --quick-add-key "${key_id}" "${SUBKEY_TYPE}" auth  "${SUBKEY_EXPIRE}"
    )
    echo "Subkeys added. Use 'list' to verify."
}


gpg_export_secret_subkeys() {
    #  gpg_export_secret_subkeys() -- export only secret subkeys (not the master)
    #    $1 (str) -- master key ID or email
    #  Use this to load only subkeys onto a device, keeping the master key offline.
    local key_id="${1:?ERROR: key ID or email required}"
    (set -x; gpg --armor --export-secret-subkeys "${key_id}")
}


gpg_export_master_key_backup() {
    #  gpg_export_master_key_backup() -- export the full secret master key for offline backup
    #    $1 (str) -- key ID or email
    #    $2 (str) -- output file (default: <key_id>-master-secret.asc)
    local key_id="${1:?ERROR: key ID or email required}"
    local outfile="${2:-${key_id}-master-secret.asc}"
    (set -x; gpg --armor --export-secret-keys "${key_id}" > "${outfile}")
    echo "Master secret key exported to: ${outfile}"
    echo "Store this file securely offline and delete it from this machine if desired."
}


gpg_delete_master_secret_key() {
    #  gpg_delete_master_secret_key() -- delete the master secret key, leaving only subkeys
    #    $1 (str) -- master key ID
    #  WARNING: Ensure you have an offline backup before running this.
    local key_id="${1:?ERROR: key ID required}"
    echo "WARNING: This will delete the master secret key for: ${key_id}"
    echo "Ensure you have an offline backup (export-master-backup) before proceeding."
    read -r -p "Type 'yes' to confirm: " confirm
    if [ "${confirm}" != "yes" ]; then
        echo "Aborted."
        return 1
    fi
    (set -x; gpg --delete-secret-key "${key_id}")
}


gpg_edit_key() {
    #  gpg_edit_key() -- open interactive key editor (expire, revoke, trust, etc.)
    #    $1 (str) -- key ID or email
    local key_id="${1:?ERROR: key ID or email required}"
    (set -x; gpg --edit-key "${key_id}")
}


gpg_list_keys() {
    #  gpg_list_keys() -- list secret keys with long key IDs
    (set -x; gpg --list-secret-keys --keyid-format=long)
}


gpg_export_public_key() {
    #  gpg_export_public_key() -- export the ASCII-armored public key block
    #    $1 (str) -- key ID or email
    local key_id="${1:?ERROR: key ID or email required}"
    (set -x; gpg --armor --export "${key_id}")
}


gpg_configure_git() {
    #  gpg_configure_git() -- configure Git to sign commits and tags with a key
    #    $1 (str) -- key ID
    local key_id="${1:?ERROR: key ID required}"
    (set -x
        git config --global user.signingkey "${key_id}"
        git config --global commit.gpgsign true
        git config --global tag.gpgsign true
    )
    echo "Git configured to sign with key: ${key_id}"
}


gpg_show_git_config() {
    #  gpg_show_git_config() -- show current Git GPG signing config
    (set -x
        git config --global --get user.signingkey   || true
        git config --global --get commit.gpgsign    || true
        git config --global --get tag.gpgsign       || true
    )
}


gpg_add_tty_export() {
    #  gpg_add_tty_export() -- append GPG_TTY export to shell rc file
    #    $1 (str) -- rc file path (default: ~/.bashrc)
    local rcfile="${1:-${HOME}/.bashrc}"
    local line='export GPG_TTY=$(tty)'
    if grep -qF "${line}" "${rcfile}" 2>/dev/null; then
        echo "GPG_TTY export already present in ${rcfile}"
    else
        echo "" >> "${rcfile}"
        echo "# GPG_TTY -- required for GPG passphrase prompts in terminals" >> "${rcfile}"
        echo "${line}" >> "${rcfile}"
        echo "Added GPG_TTY export to ${rcfile}"
    fi
}


gpg_test_sign() {
    #  gpg_test_sign() -- test that GPG signing works
    echo "test" | (set -x; gpg --clearsign)
}


gpg_open_github() {
    #  gpg_open_github() -- open the GitHub GPG keys settings page
    local url="https://github.com/settings/gpg/new"
    echo "Open this URL in your browser to add the key to GitHub:"
    echo "  ${url}"
    if command -v xdg-open &>/dev/null; then
        xdg-open "${url}" 2>/dev/null || true
    elif command -v open &>/dev/null; then
        open "${url}" 2>/dev/null || true
    fi
}


print_help() {
    echo "Usage: ${0} [-h] <command> [args...]"
    echo ""
    echo "Set up a GPG key for GitHub and configure Git commit signing."
    echo ""
    echo "Commands:"
    echo "  configure-agent                   -- enable allow-loopback-pinentry in gpg-agent.conf"
    echo "  generate                          -- interactively generate a new GPG key"
    echo "  generate-batch <name> <email> [passphrase]"
    echo "                                    -- generate a GPG key non-interactively"
    echo "  add-subkeys <key-id|email>        -- add sign/encr/auth subkeys to a master key"
    echo "  list                              -- list existing secret keys (long format)"
    echo "  export <key-id|email>             -- print ASCII-armored public key block"
    echo "  export-subkeys <key-id|email>     -- export secret subkeys only (not master)"
    echo "  export-master-backup <key-id> [file]"
    echo "                                    -- export full secret master key for offline backup"
    echo "  delete-master-secret <key-id>     -- delete master secret key (keep subkeys only)"
    echo "  edit-key <key-id|email>           -- open interactive key editor"
    echo "  configure-git <key-id>            -- set user.signingkey, commit.gpgsign, tag.gpgsign"
    echo "  show-git-config                   -- show current Git GPG signing settings"
    echo "  add-tty-export [rcfile]           -- add GPG_TTY=\$(tty) to ~/.bashrc (or rcfile)"
    echo "  test-sign                         -- test GPG signing with a simple message"
    echo "  open-github                       -- print (and open) the GitHub GPG keys URL"
    echo ""
    echo "Typical workflow (simple):"
    echo "  ${0} generate"
    echo "  ${0} list"
    echo "  ${0} export <key-id>   # copy output to GitHub → Settings → GPG keys"
    echo "  ${0} open-github"
    echo "  ${0} configure-git <key-id>"
    echo "  ${0} add-tty-export"
    echo "  ${0} test-sign"
    echo ""
    echo "Typical workflow (master key + subkeys, USE_SUBKEYS=1):"
    echo "  USE_SUBKEYS=1 ${0} generate-batch <name> <email>"
    echo "  ${0} list"
    echo "  ${0} add-subkeys <master-key-id>"
    echo "  ${0} export-master-backup <master-key-id>   # store offline"
    echo "  ${0} delete-master-secret <master-key-id>  # optional: keep only subkeys online"
    echo "  ${0} export <master-key-id>                # copy public key to GitHub"
    echo "  ${0} configure-git <signing-subkey-id>!"
    echo "  ${0} add-tty-export"
    echo "  ${0} test-sign"
    echo ""
    echo "Environment variables:"
    echo "  KEY_TYPE       Master key type (default: ${KEY_TYPE})"
    echo "  KEY_LENGTH     Master key length in bits (default: ${KEY_LENGTH})"
    echo "  KEY_EXPIRE     Master key expiration, 0=never (default: ${KEY_EXPIRE})"
    echo "  SUBKEY_TYPE    Subkey type (default: ${SUBKEY_TYPE})"
    echo "  SUBKEY_LENGTH  Subkey length in bits (default: ${SUBKEY_LENGTH})"
    echo "  SUBKEY_EXPIRE  Subkey expiration (default: ${SUBKEY_EXPIRE})"
    echo "  USE_SUBKEYS    If 1, generate-batch creates a certify-only master key (default: ${USE_SUBKEYS})"
    echo "  GPG_LOOPBACK   If 1, pass --pinentry-mode loopback (default: ${GPG_LOOPBACK}; for headless/container use)"
    echo ""
}


main() {
    for arg in "${@}"; do
        case "${arg}" in
            -h|--help) print_help; return 0;;
        esac
    done

    if [ -z "${*}" ]; then
        print_help
        return 0
    fi

    local cmd="${1}"
    shift

    case "${cmd}" in
        configure-agent)
            gpg_configure_agent_loopback
            ;;
        generate)
            gpg_generate_key
            ;;
        generate-batch)
            gpg_generate_key_batch "${@}"
            ;;
        add-subkeys)
            gpg_add_subkeys "${@}"
            ;;
        list)
            gpg_list_keys
            ;;
        export)
            gpg_export_public_key "${@}"
            ;;
        export-subkeys)
            gpg_export_secret_subkeys "${@}"
            ;;
        export-master-backup)
            gpg_export_master_key_backup "${@}"
            ;;
        delete-master-secret)
            gpg_delete_master_secret_key "${@}"
            ;;
        edit-key)
            gpg_edit_key "${@}"
            ;;
        configure-git)
            gpg_configure_git "${@}"
            ;;
        show-git-config)
            gpg_show_git_config
            ;;
        add-tty-export)
            gpg_add_tty_export "${@}"
            ;;
        test-sign)
            gpg_test_sign
            ;;
        open-github)
            gpg_open_github
            ;;
        *)
            echo "ERROR: Unknown command: '${cmd}'"
            echo ""
            print_help
            return 1
            ;;
    esac
}

main "${@}"
