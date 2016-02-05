#!/usr/bin/env bash

function this_init() {
    set -x
    USERNAME="${1:-"p6"}"
    HOMEDIR="${2:-"${HOME}/.gnupg"}"
    BUILDDIR="${3:-"."}"
    PUBRING="${USERNAME}.pub"
    SECRING="${USERNAME}.sec"
    EMAIL="${USERNAME}@localhost"
    KEYTYPE="default"
    SUBKEYTYPE="default"
    NAME_REAL="${USERNAME}"
    NAME_COMMENT="\#${USERNAME}"
    EXPIRE_DATE="0"
}

function this_generate_key() {
    set +x
    PASSPHRASE="${1}"  # "abc"
    PASSPHRASESTR=""
    if [ -n "${PASSPHRASE}" ]; then
        PASSPHRASESTR="Passphrase: ${PASSPHRASE}"
    fi
    set -x
    echo - | gpg2 --gen-key --batch << EOF
%echo Generating a default key
Key-Type: ${KEYTYPE}
Subkey-Type: ${SUBKEYTYPE}
Name-Real: ${NAME_REAL}
Name-Comment: ${NAME_COMMENT}
Name-Email: ${EMAIL}
Expire-Date: ${EXPIRE_DATE}
${PASSPHRASESTR}
%pubring ${BUILDDIR}/${PUBRING}
%secring ${BUILDDIR}/${SECRING}
# Do a commit here, so that we can later print "done" :-)
%commit
%echo done
EOF
    this_list_keys
}

function this_list_keys() {
    local builddir=${1:-${BUILDDIR}}
    gpg2 \
        --no-default-keyring \
        --secret-keyring="${builddir}/${SECRING}" \
        --keyring="${builddir}/${PUBRING}" \
        --list-secret-keys \
        --fingerprint
}


function copy_backup() {
    set -x
    local src=${1}
    local dest=${2}
    local datetime=${3:-$(date +'%FT%T%z')}
    if [ -f "${dst}" ]; then
        rsync -pv "${dst}" "${dst}.bkp.${datetime}"
    fi
    rsync -pv "${src}" "${dst}"
}

function push_new_keyset() {
    set -x
    local builddir=${1:-${BUILDDIR}}
    local destdir=${2:-${HOMEDIR}}
    local SECRING=${SECRING}
    local PUBRING=${PUBRING}
    SECRING_SRC=${builddir}/${SECRING}
    PUBRING_SRC=${builddir}/${PUBRING}
    SECRING_DST=${destdir}/${SECRING}
    PUBRING_DST=${destdir}/${PUBRING}
    copy_backup "${SECRING_SRC}" "${SECRING_DST}"
    copy_backup "${PUBRING_SRC}" "${PUBRING_DST}"
}

function this_encode() {
    ## XXX: --trust-model always (allow use unsigned key (${EMAIL}))
    gpg2 \
        --no-default-keyring \
        --secret-keyring="${BUILDDIR}/${SECRING}" \
        --keyring="${BUILDDIR}/${PUBRING}" \
        --trust-model=always \
        --armor \
        --encrypt \
        -r ${EMAIL}
}

function this_decode() {
    gpg2 \
        --no-default-keyring \
        --secret-keyring="${BUILDDIR}/${SECRING}" \
        --keyring="${BUILDDIR}/${PUBRING}" \
        --decrypt
}

function this_test() {
    TEST_STRING='test_one_two_two\n#123\n\n.';
    output="$(echo "${TEST_STRING}" | this_encode | this_decode)"
    if [[ "${output}" != "${TEST_STRING}" ]]; then
        echo "FAIL: assertEqual(output, TEST_STRING)"
        echo "# ${output}"
        echo "# ${TEST_STRING}"
        return -1
    else
        echo "PASS: assertEqual(output, TEST_STRING)"
    fi
}

function this__() {
    # for prompt6,
    # i think it makes sense to 
    # encode for a stable p6 key        # -r p6@localhost
    # encode with (one of) other keys   # -u user@domain 
    #
    # this way, one or more keys can be used to update values
    # without having to re-encode the whole tree
    echo ''
}

function this_help () {
    echo "${0} -- keygen/encode/decode wrapper"
    echo ""
    echo "  -G  -- Generate new key"
    echo "  -l  -- List keys and fingerprints"
    echo "  -t  -- Run Tests"
    echo "  -h  -- Print help"
    echo ""

}

function this_main () {
    while getopts "Glth" opt; do
        case "${opt}" in
            G)
                _this_generate_key=true;
                ;;
            l)
                _this_list_keys=true;
                ;;
            t)
                _this_run_tests=true;
                ;;
            *|h)
                _this_help=true;
                ;;
        esac
    done
    test -n ${_this_help} && this_help && return 0

    this_init

    if [ -n ${_this_list_keys} ]; then
        this_list_keys
    fi
    if [ -n ${_this_generate_key} ]; then
        this_generate_key
        if [ -n ${_this_list_keys} ]; then
            this_list_keys
        fi
    fi
    if [ -n ${_this_run_tests} ]; then
        this_test
    fi
    return $?
}
if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    this_main ${@}
    exit
fi
