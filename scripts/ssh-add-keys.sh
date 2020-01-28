#!/bin/sh
## ssh-add-keys.sh -- generate and load SSH keys
# Author: @westurner


function ssh_add_keys_help {
    ## ssh_add_keys_help() -- print help for the ssh-add-keys script
    scriptname="$(basename "${0}")"
    echo "${scriptname} [-h] [-a] [keygen:domain/u+n] [gh|gl|bb|local]"
    echo "Generate and load SSH keys"
    echo ""
    echo "# Functions"
    echo "## Generate SSH keys:"
    echo ""
    echo "  ${scriptname}  keygengl:user+key1 -t rsa  # is the same as:"
    echo "  ${scriptname}  keygen:gitlab.com/user+key1 -t rsa"
    echo ""
    echo "In per-domain folders:"
    echo ""
    echo " ls ~/.ssh/keys/<domain>/*"
    echo ""
    echo "With a filename containing the generation timestamp:"
    echo ""
    echo " user+key1__gitlab.com__2020-11-11T11:11:11-0500__id_rsa"
    echo " user+key1__gitlab.com__2020-11-11T11:11:11-0500__id_rsa.pub"
    echo " user+key1__gitlab.com__2020-11-11T11:11:11-0500__id_rsa.key"
    echo ""
    echo "With a symlink linking from <key_file>.key to <key_file>.pub"
    echo ""
    echo " ln -s \\"
    echo "  ~/.ssh/keys/gitlab.com/user+key1__gitlab.com__2020-11-11T11:11:11-0500__id_rsa \\"
    echo "  user+key1__gitlab.com__2020-11-11T11:11:11-0500__id_rsa.key"
    echo ""
    echo "With a comment field containing the filename and ssh-keygen arguments"
    echo "that the key was generated with:"
    echo ""
    echo " 'user+key1__gitlab.com__2020-11-11T11:11:11-0500__id_rsa (ssh-keygen -t rsa) :key:'"
    echo " "
    echo "## Load SSH keys into the ssh-agent keyring with ssh-add:"
    echo ""
    echo " ${scriptname} gl  # is the same as:"
    echo " ssh-add ~/.ssh/keys/gitlab.com/*.key "
    echo ""
    echo "## To symlink and ssh-add an existing SSH key:"
    echo ""
    echo " ln -s ~/.ssh/id_ecdsa ~/.ssh/github.com/id_ecdsa.key"
    echo " ${scriptname} gw"
    echo ""
    echo "# Arguments"
    echo ""
    echo "  -a|--all|all       -- ssh-add each key"
    echo "     gh|github"
    echo "     gl|gitlab"
    echo "     bb|bitbucket"
    echo "     local"
    echo ""
    echo "  -s|--status|status -- print env vars, list keys, list key params"
    echo "    -e --env env     -- print SSH_AUTH_SOCK and SSH_AGENT_PID"
    echo "    -l --list-keys   -- list key fingerprints (ssh-add -l)"
    echo "    -L --list-params -- list key params (ssh-add -L)"
    echo ""
    echo "  -t [key_type]      -- set the key type"
    echo "    -t rsa           -  set the key type to RSA"
    echo "    -t ecdsa         -  set the key type to ECDSA"
    echo "    -t ed25519       -  set the key type to ed25519"
    echo ""
    echo "  ssh-keygen"
    echo "    keygen:domain.tld/user+key    -- generate a key"
    echo "    keygen:github.com/user+key    -- generate a key for gh|github"
    echo "    keygengh:user+key             -- generate a key for gh|github"
    echo "    keygengl:user+key             -- generate a key for gl|gitlab"
    echo "    keygenbb:user+key             -- generate a key for bb|bitbucket"
    echo ""
    echo "    keygen:example.org/userabc+keyxyz    -t rsa"
    echo "    keygengh:my_gh_username+special_key  -t ecdsa"
    echo "    keygengl:my_gh_username+special_key  -t ed25519"
    echo ""
    echo "  -h|--help|help     -- print this help"
    echo ""
}

SSH_KEY_TYPE_DEFAULT="rsa"  # 'rsa' is the ssh-keygen default key type
SSH_KEY_COMMENT_SUFFIX=":key:" # append this to key comments

shell_escape_number() {
    ## shell_escape_number() -- escape potential single quotes in a number
    #   $1 (strtoescape) -- number/string to escape the single quotes of
    #   XXX TODO TEST
    numtoescape=${1}
    output="$(echo "${numtoescape}" | sed "s,','\"'\"',g")"
    echo ""${output}""
}

shell_escape_single() {
    ## shell_escape_single() -- escape single quotes and wrap in single quotes
    #   $1 (strtoescape) -- string to escape ' and wrap in single quotes
    #   XXX TODO TEST
    strtoescape=${1}
    output="$(echo "${strtoescape}" | sed "s,','\"'\"',g")"
    echo "'"${output}"'"
}

function ssh_agent {
    ## ssh_agent() -- start ssh-agent (restart if -n $1)
    #   $1 (restart) -- if true, restart w/ 'ssh-agent -k' before $(`eval`)
    restart="${1}"
    if [[ "${SSH_AGENT_PID}" == "" ]]; then
        output="$(set -x; ssh-agent)"
        # EVAL
        eval "${output}"
    else
        if [[ "${restart}" == '-k' ]]; then
            echo "Restarting ssh-agent..." >&2
            output="$(set -x; ssh-agent -k)"
            echo "${output}" >&2
            output="$(ssh-agent)"
            # EVAL
            eval "${output}"
        fi
    fi
    ssh_agent_status
}

function ssh_agent_env {
    ## ssh_agent_env() -- echo SSH_AUTH_SOCK and SSH_AGENT_PID
    echo "SSH_AUTH_SOCK=$(shell_escape_single "${SSH_AUTH_SOCK}")"
    echo "SSH_AGENT_PID=$(shell_escape_number "${SSH_AGENT_PID}")"
}

function ssh_agent_status {
    ## ssh_agent_status() -- echo SSH_AUTH_SOCK and SSH_AGENT_PID
    ssh_agent_env
    #ssh_agent_list_key_fingerprints
    #ssh_agent_list_key_params
}

function ssh_agent_status_all {
    ## ssh_agent_status_all() -- echo SSH_ vars, print key info
    #                           (fingerprints, params)
    ssh_agent_env
    ssh_agent_list_key_fingerprints
    ssh_agent_list_key_params
}

function ssh_agent_list_key_fingerprints {
    ## ssh_agent_list_key_fingerprints() -- `ssh-add -l`
    (set -x; ssh-add -l)
}

function ssh_agent_list_key_params {
    ## ssh_agent_list_key_fingerprints() -- `ssh-add -L`
    (set -x; ssh-add -L)
}

function ssh_add {
    ## ssh_add() -- `ssh-add ${@}`
    (set -x; ssh-add "${@}")
}

function ls_ssh_keys {
    ## ls_ssh_keys()                -- list ssh keys in path $1
    function _ls_ssh_keys {
        path="${1:-"."}"
        find "${path}" -maxdepth 1 -type f \
            | file -F $'\0' \
            | grep 'private key$' \
            | cut -f0 -d "$'\0'"
    }
    (set -x; ls_ssh_keys ${@})
}


### ./constants

function ssh_add_keys__local {
    ## ssh_add_keys__bitbucket()    -- add keys for local
    ssh_add ~/.ssh/keys/local/*.key
}

function ssh_add_keys__github {
    ## ssh_add_keys__bitbucket()    -- add keys for github.com
    ssh_add ~/.ssh/keys/github.com/*.key
}

function ssh_add_keys__gitlab {
    ## ssh_add_keys__gitlab()    -- add keys for gitlab.com
    ssh_add ~/.ssh/keys/gitlab.com/*.key
}

function ssh_add_keys__bitbucket {
    ## ssh_add_keys__bitbucket()    -- add keys for bitbucket.org
    ssh_add ~/.ssh/keys/bitbucket.org/*.key
}

function ssh_add_keys_all {
    ## ssh_add_keys_all() -- add each key [and prompt for passphrase]
    ssh_add_keys__github
    ssh_add_keys__gitlab
    ssh_add_keys__bitbucket
    ssh_add_keys__local
}

### ./constants


function _debug {
    ## _debug()  -- echo "## ${@}" >&2
    echo "## ${@}" >&2
}

function ssh_add_keys {
    ## ssh_add_keys()  -- ssh_add_keys main function (help, args, tasks)
    _args=( "${@}" )
    if [ -z "${_args[*]}" ]; then
        (set +x +v; ssh_add_keys_help)
        exit
    fi

    _ssh_add_keys_help=
    _ssh_add_keys_run_tests=
    _ssh_add_keys_all=
    _ssh_add_keys__github=
    _ssh_add_keys__gitlab=
    _ssh_add_keys__bitbucket=
    _ssh_add_keys__local=
    _ssh_agent_status=
    _ssh_agent_list_key_fingerprints=
    _ssh_agent_list_key_params=
    _ssh_keygen__default=
    _ssh_keygen__github=
    _ssh_keygen__gitlab=
    _ssh_keygen__bitbucket=
    _ssh_keygen__local=

    for arg in "${_args[@]}"; do
        case "${arg}" in
            -h|--help|help)
                (set +x +v; ssh_add_keys_help)
                return 0
                ;;
        esac
    done
    for arg in "${_args[@]}"; do
        shift
        case "${arg}" in
            -a|--all|all)
                _ssh_add_keys_all=1
                ;;

            -e|--env|env)
                _ssh_agent_status=1
                ;;
            -s|--status|status)
                _ssh_agent_status_all=1
                ;;
            -l|--list-keys|list)
                _ssh_agent_list_key_fingerprints=1
                ;;
            -L|--list-params|params)
                _ssh_agent_list_key_params=1;
                ;;
            --test|test)
                _ssh_add_keys_run_tests=1;
                ;;

            gh|github)
                _ssh_add_keys__github=1
                ;;
            gl|gitlab)
                _ssh_add_keys__gitlab=1
                ;;
            bb|bitbucket)
                _ssh_add_keys__bitbucket=1
                ;;
            local)
                _ssh_add_keys__local=1
                ;;

            pwd)
                make -C "${__DOTFILES}" pwd 2>/dev/null &
                ;;

            -t)
                _keytype="${1}"
                otherargs=( ${otherargs[@]} "-t"  )
                ;;

            keygen*)  # keygen123:domain.tld/user+keyname
                # _keygensuffix='123'
                _keygensuffix=$(echo "${arg}" \
                    | sed 's/^keygen\(.*\)\:\(.*\)/\1/')
                # _keygenargs='domain.tld/user+keyname'
                _keygenargs=$(echo "${arg}" \
                    | sed 's/^keygen\(.*\)\:\(.*\)/\2/')

                if [ -z "${_keygenargs}" ]; then
                    echo "specify a _namekey like keygen:domain.tld/user+keyname"
                    return 1
                fi
                if [ -z "${_keygensuffix}" ]; then
                    _ssh_keygen__default=1
                else
                    case "${_keygensuffix}" in
                        gh|github)
                            _ssh_keygen__github=1
                            ;;
                        gl|gitlab)
                            _ssh_keygen__gitlab=1
                            ;;
                        bb|bitbucket)
                            _ssh_keygen__bitbucket=1
                            ;;
                        local)
                            _ssh_keygen__local=1
                            ;;
                        *)
                            echo "${_keygensuffix} unsupported"
                            return 1
                            ;;
                    esac
                fi
                ;;
            *)
                # echo "Adding arg '$arg' to otherargs"
                otherargs=(${otherargs[@]} "${arg}")
                ;;
        esac
    done

    # --test
    if [ -n "${_ssh_add_keys_run_tests}" ]; then
        ssh_add_keys_run_tests
    fi

    _ssh_keygen_args=( "${_keygenargs}" "${otherargs[@]}" )

    # keygengen
    if [ -n "${_ssh_keygen__default}" ]; then
        _ssh_keygen__default "${_ssh_keygen_args[@]}"
    fi
    # keygen:gh
    if [ -n "${_ssh_keygen__github}" ]; then
        _ssh_keygen__github "${_ssh_keygen_args[@]}"
    fi
    # keygen:gl
    if [ -n "${_ssh_keygen__gitlab}" ]; then
        _ssh_keygen__gitlab "${_ssh_keygen_args[@]}"
    fi
    # keygen:bb
    if [ -n "${_ssh_keygen__bitbucket}" ]; then
        _ssh_keygen__bitbucket "${_ssh_keygen_args[@]}"
    fi
    # keygen:local
    if [ -n "${_ssh_keygen__local}" ]; then
        _ssh_keygen__local "${_ssh_keygen_args[@]}"
    fi

    # -a
    _opts_add_all=(
        $_ssh_add_keys_all
        $_ssh_add_keys__github
        $_ssh_add_keys__gitlab
        $_ssh_add_keys__bitbucket
        $_ssh_add_keys__local
    )

    if [ -n "${_opts_add_all[@]}" ]; then
        if [ -n "${_ssh_agent_list_key_fingerprints}" ] || \
            [ -n "${_ssh_agent_list_key_params}" ]; then
            echo "# before"
            _key_fingerprints_before=0
            _key_fingerprints_after=
            _key_params_before=0
            _key_params_after=
            if [ -n "${_ssh_agent_list_key_fingerprints}" ]; then
                _key_fingerprints_before=$(ssh_agent_list_key_fingerprints)
                echo "${_key_fingerprints_before}"
            fi
            if [ -n "${_ssh_agent_list_key_params}" ]; then
                _key_params_before=$(ssh_agent_list_key_params)
                echo "${_key_params_before}"
            fi
        fi
        test -n "${_ssh_add_keys_all}" && ssh_add_keys_all
        test -n "${_ssh_add_keys__github}" && ssh_add_keys__github
        test -n "${_ssh_add_keys__gitlab}" && ssh_add_keys__gitlab
        test -n "${_ssh_add_keys__bitbucket}" && ssh_add_keys__bitbucket
        test -n "${_ssh_add_keys__local}" && ssh_add_keys__local
    fi
    # -e / --env / env
    if [ -n "${_ssh_agent_status}" ]; then
        ssh_agent_status
    fi
    # -s / --status / status
    if [ -n "${_ssh_agent_status_all}" ]; then
        ssh_agent_status_all
    fi

    TMPDIR="${TMPDIR:-"${HOME}/.cache"}"
    tmpdir="${TMPDIR}/ssh-add-keys.sh"
    # -l / --list-keys / list
    if [ -n "${_ssh_agent_list_key_fingerprints}" ]; then
        _key_fingerprints_after="$(ssh_agent_list_key_fingerprints)"
        echo "${_key_fingerprints_after}"
        if [ -n "${_key_fingerprints_before}" ]; then
            (umask 0007; mkdir -p "${tmpdir}")
            old="${tmpdir}/ssh-add-keys__old.$$.$RANDOM"
            new="${tmpdir}/ssh-add-keys__new.$$.$RANDOM"
            echo "${_key_fingerprints_before}" > "${old}"
            echo "${_key_fingerprints_after}" > "${new}"
            diff -Naur "${old}" "${new}"
            rm -rf "${tmpdir}"
        fi
    fi
    # -L / --list-params / params
    if [ -n "${_ssh_agent_list_key_params}" ]; then
        _key_params_after="$(ssh_agent_list_key_params)"
        echo "${_key_params_after}"
        if [ -n "${_key_params_before}" ]; then
            (umask 0007; mkdir -p "${tmpdir}")
            old="${tmpdir}/ssh-add-keys__old.$$.$RANDOM"
            new="${tmpdir}/ssh-add-keys__new.$$.$RANDOM"
            echo "${_key_fingerprints_before}" > "${old}"
            echo "${_key_fingerprints_after}" > "${new}"
            diff -Naur "${old}" "${new}"
            rm -rf "${tmpdir}"
        fi
    fi
}

function prefix__iso8601datetime {
    ## prefix__iso8601datetime()    -- return {prefix}__{iso8601datetime}
    _prefix="${1}"
    _date=$(date +"%FT%T%z")
    _prefixdate="${_prefix}__${_date}"
    echo "${_prefixdate}"
}

function _ssh_keygen__ {
    ## _ssh_keygen__()  -- generate an ssh key with ssh-keygen
    function _ssh_keygen___ {
        _sshkeypath="${SSHKEYPATH:-"${HOME}/.ssh/keys"}"
        _namekey="${1}"  # domain.tld/user+keyname
        shift
        _keydir="$(dirname "${_namekey}")"
        _keyname="$(basename "${_namekey}")"
        if [ -z "${_namekey}" ]; then
            echo "ERROR: ValueError: \$1 should be a namekey"
            echo ""
            ssh_add_keys_help
            return 2
        fi
        if [ -z "${_keytype}" ]; then
            echo "INFO: _keytype is not set."
            echo "Defaulting to ${SSH_KEY_TYPE_DEFAULT} (SSH_KEY_TYPE_DEFAULT)"
            _keytype="${SSH_KEY_TYPE_DEFAULT}"
        fi
        _keyname="$(prefix__iso8601datetime "${_keyname}")"
        _keyname__type="${_keyname}__id_${_keytype}"
        __keydir="${_sshkeypath}/${_keydir}"
        _keypath="${__keydir}/${_keyname__type}"
        _comment="${_keyname__type} (ssh-keygen -t ${_keytype}${@:+"${@}"})${SSH_KEY_COMMENT_SUFFIX:+" ${SSH_KEY_COMMENT_SUFFIX}"}"
        mkdir -p "${__keydir}"
        chmod 0700 "${__keydir}"
        (set -x; ssh-keygen -f "${_keypath}" -C "${_comment}" "${@}")

        echo "To load this key with ssh-add-key.sh [gh|gl|local|[..]]"
        echo "create a .key symlink:"
        echo "ln -s '${_keypath}' '${_keypath}.key'"
        (set -x; cd "${__keydir}"; ln -s "${_keyname__type}" "${_keyname__type}.key")
        echo "Pubkey: '${_keypath}.pub'"
    }
    (set -x; _ssh_keygen___ "${@}")
}

function _ssh_keygen__default {
    ## _ssh_keygen__default()  -- generate an ssh key (-t ecdsa)
    _namekey="${1}"
    shift
    _ssh_keygen__ "${_namekey}" "${@}"
}

function _ssh_keygen__github {
    ## _ssh_keygen__github()  -- generate an ssh key for github (-t rsa)
    _namekey="github.com/${1}__github.com"
    shift
    _ssh_keygen__ "${_namekey}" "${@}"
}

function _ssh_keygen__gitlab {
    ## _ssh_keygen__gitlab()  -- generate an ssh key for gitlab (-t rsa)
    _namekey="gitlab.com/${1}__gitlab.com"
    shift
    _ssh_keygen__ "${_namekey}" "${@}"
}

function _ssh_keygen__bitbucket {
    ## _ssh_keygen__github()  -- generate an ssh key for bitbucket (-t rsa)
    _namekey="bitbucket.org/${1}__bitbucket.org"
    shift
    _ssh_keygen__ "${_namekey}" "${@}"
}

function _ssh_keygen__local {
    ## _ssh_keygen__github()  -- generate an ssh key for (-t rsa)
    _namekey="local/${1}__local"
    shift
    _ssh_keygen__ "${_namekey}" "${@}"
}

function ssh_add_keys_run_tests {
    ## ssh_add_keys_run_tests()     -- run tests
    #set -x
    _TEST__NAME=
    function test_start {
        export _TEST__NAME="${@}"
        # echo "# ${@}" >&2
    }

    function test_fail {
        _test_name="${1:-"${_TEST__NAME}"}"
        shift
        _msg="${@}"
        echo "# - [FAIL] ${_test_name} : ${_msg}" >&2
    }
    function test_pass {
        _test_name="${1:-"${_TEST__NAME}"}"
        shift
        _msg="${@}"
        echo "# - [PASS] ${_test_name} : ${_msg}" >&2
    }
    function test_eval {
        _test_name="${1:-"${_expect_retcode}"}"

        expect_retcode="${2:-0}"
        retcode="${3:-${?}}" # TODO: doe this work?
        if [[ "${retcode}" != "${expect_retcode}" ]]; then
            test_fail "${_TEST__NAME}" \
                "retcode ${retcode} != ${expect_retcode}"
        else
            test_pass "${_TEST__NAME}" \
                "retcode ${retcode} == ${expect_retcode}"
        fi
    }

    test_start "ssh_add_keys_help"
    ssh_add_keys_help
    test_eval "ssh_add_keys_help"

    test_start "ssh_add_keys__-h"
    ssh_add_keys -h
    test_eval "ssh_agent_env"


    test_start "ssh_agent_env"
    ssh_agent_env
    test_eval "ssh_agent_env"

    test_start "ssh_add_keys__-e"
    ssh_add_keys -e
    test_eval "ssh_add_keys__-e"


    test_start "ssh_agent_status"
    ssh_agent_status
    test_eval "ssh_agent_status"

    test_start "ssh_add_keys__-s"
    ssh_add_keys -s
    test_eval "ssh_add_keys__-s"


    test_start "ssh_agent_status_all"
    ssh_agent_status_all
    # TODO ssh_add_keys --agent-status-all
    test_eval "ssh_agent_status_all"


    test_start "ssh_agent_list_key_fingerprints"
    ssh_agent_list_key_fingerprints
    test_eval "ssh_agent_list_key_fingerprints"

    test_start "ssh_agent_list_key_fingerprints__-l"
    ssh_add_keys -l
    test_eval "ssh_agent_list_key_fingerprints"


    test_start "ssh_agent_list_key_params"
    ssh_agent_list_key_params
    test_eval "ssh_agent_list_key_params"

    test_start "ssh_add_keys_-l"
    ssh_add_keys -L
    test_eval "ssh_add_keys_-l"


    #test_start "ssh_add_keys_all"
    #ssh_add_keys -a
    #test_eval "ssh_add_keys_all"

    #test_start "ssh_add_keys_all_list_fingerprints"
    #ssh_add_keys -a -l
    #test_eval "ssh_add_keys_all_list_fingerprints"

    #test_start "ssh_add_keys_all_list_params"
    #ssh_add_keys -a -l
    #test_eval "ssh_add_keys_all_list_params"

    #test_start "ssh_add_keys_all_list_fingerprints_and_params"
    #ssh_add_keys -a -l -L
    #test_eval "ssh_add_keys_all_list_fingerprints_and_params"
}

function ssh_add_keys__main {
    ## ssh_add_keys__main()     -- ssh-add_keys main function
    # echo '# ${@}='"$(shell_escape_single ${@})" >&2
    if [[ "${_logdest}" != "" ]]; then
        ssh_add_keys "${@}" | tee -a "${_logdest}"
    else
        ssh_add_keys "${@}"
    fi
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    ssh_add_keys__main "${@}"
    exit
fi
