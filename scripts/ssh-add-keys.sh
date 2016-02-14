#!/bin/bash
## ssh-add-keys.sh
#
#  ssh-add sets of keys (defined as constants within this script)
#
#  ~/.ssh/<domain>/*.key
#  ln -s ~/.ssh/id_ecdsa ~/.ssh/github.com/id_ecdsa.key

shell_escape_number() {
    # shell_escape_number() -- escape potential single quotes in a number
    #   $1 (strtoescape) -- number/string to escape the single quotes of
    #   XXX TODO TEST
    numtoescape=${1}
    output="$(echo "${numtoescape}" | sed "s,','\"'\"',g")"
    echo ""${output}""
}
shell_escape_single() {
    # shell_escape_single() -- escape single quotes and wrap in single quotes
    #   $1 (strtoescape) -- string to escape ' and wrap in single quotes
    #   XXX TODO TEST
    strtoescape=${1}
    output="$(echo "${strtoescape}" | sed "s,','\"'\"',g")"
    echo "'"${output}"'"
}

function ssh_agent {
    # ssh_agent() -- start ssh-agent (restart if -n $1)
    #   $1 (restart) -- if true, restart w/ 'ssh-agent -k' before $(`eval`)
    restart="${1}"
    if [[ "${SSH_AGENT_PID}" == "" ]]; then
        local output="$(set -x; ssh-agent)"
        # EVAL
        eval "${output}"
    else
        if [[ "${restart}" == '-k' ]]; then
            echo "Restarting ssh-agent..." >&2
            local output="$(set -x; ssh-agent -k)"
            echo "${output}" >&2
            local output="$(ssh-agent)"
            # EVAL
            eval "${output}"
        fi
    fi
    ssh_agent_status
}

function ssh_agent_env {
    # ssh_agent_env() -- echo SSH_AUTH_SOCK and SSH_AGENT_PID
    echo "SSH_AUTH_SOCK=$(shell_escape_single "${SSH_AUTH_SOCK}")"
    echo "SSH_AGENT_PID=$(shell_escape_number "${SSH_AGENT_PID}")"
}

function ssh_agent_status {
    # ssh_agent_status() -- echo SSH_AUTH_SOCK and SSH_AGENT_PID
    ssh_agent_env
    #ssh_agent_list_key_fingerprints
    #ssh_agent_list_key_params
}

function ssh_agent_status_all {
    # ssh_agent_status_all() -- echo SSH_ vars, print key info
    #                           (fingerprints, params)
    ssh_agent_env
    ssh_agent_list_key_fingerprints
    ssh_agent_list_key_params
}

function ssh_agent_list_key_fingerprints {
    # ssh_agent_list_key_fingerprints() -- `ssh-add -l`
    (set -x; ssh-add -l)
}

function ssh_agent_list_key_params {
    # ssh_agent_list_key_fingerprints() -- `ssh-add -L`
    (set -x; ssh-add -L)
}

function ssh_add {
    # ssh_add() -- ssh-add
    # SSH_ADD_BIN=$(which ssh-add)
    # ${SSH_ADD_BIN} "${@}"
    (set -x; ssh-add "${@}")
}

function ls_ssh_keys {
    function _ls_ssh_keys {
        local path="${1:-"."}"
        find "${path}" -maxdepth 1 -type f \
            | file -F $'\0' \
            | grep 'private key$' \
            | cut -f0 -d "$'\0'"
    }
    (set -x; ls_ssh_keys ${@})
}


### ./constants

function ssh_add_keys__local {
    ssh_add ~/.ssh/keys/local/*.key
}

function ssh_add_keys__github {
    ssh_add ~/.ssh/keys/github.com/*.key
}

function ssh_add_keys__bitbucket {
    ssh_add ~/.ssh/keys/bitbucket.org/*.key
}

function ssh_add_keys_all {
    # ssh_add_keys_all() -- add each key [and prompt for passphrase]
    ssh_add_keys__github
    ssh_add_keys__bitbucket
    ssh_add_keys__local
}

### ./constants

function ssh_add_keys_help {
    # ssh_add_keys_help() -- print help for the ssh-add-keys script
    local scriptname="$(basename "${0}")"
    echo "${scriptname} [-h] [-a|--all] [-s|--status] [-e|--env] [-l] [-L]"
    echo ""
    echo "  -a|--all|all       -- ssh-add each key"
    echo "     gh|github"
    echo "     bb|bitbucket"
    echo "     local"
    echo ""
    echo "  -s|--status|status -- print env vars, list keys, list key params"
    echo "    -e|--env|env     -- print SSH_AUTH_SOCK and SSH_AGENT_PID"
    echo "    -l               -- list key fingerprints (ssh-add -l)"
    echo "    -L               -- list key params (ssh-add -L)"
    echo ""
    echo "  -h|--help|help     -- print this help"
    echo ""
}

function _debug {
    # _debug()  -- echo "## ${@}" >&2
    echo "## ${@}" >&2
}

function ssh_add_keys {
    # ssh_add_keys()  -- ssh_add_keys main function (help, args, tasks)
    if [[ "${@}" == "" ]]; then
        ssh_add_keys_help
        exit
    fi

    local _ssh_add_keys_help=
    local _ssh_add_keys_run_tests=
    local _ssh_add_keys_all=
    local _ssh_add_keys__github=
    local _ssh_add_keys__bitbucket=
    local _ssh_add_keys__local=
    local _ssh_agent_status=
    local _ssh_agent_list_key_fingerprints=
    local _ssh_agent_list_key_params=

    for arg in "${@}"; do
        case "${arg}" in
            -h|--help|help)
                ssh_add_keys_help
                ;;
            -a|--all|all)
                _ssh_add_keys_all=1
                ;;

            -e|--env|env)
                _ssh_agent_status=1
                ;;
            -s|--status|status)
                _ssh_agent_status_all=1
                ;;
            -l)
                _ssh_agent_list_key_fingerprints=1
                ;;
            -L)
                _ssh_agent_list_key_params=1;
                ;;
            -t)
                _ssh_add_keys_run_tests=1;
                ;;

            gh|github)
                _ssh_add_keys__github=1
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
        esac
    done

    if [ -n "${_ssh_add_keys_run_tests}" ]; then
        ssh_add_keys_run_tests
    fi

    local -a _opts_add_all=(
        $_ssh_add_keys_all
        $_ssh_add_keys__github
        $_ssh_add_keys__bitbucket
        $_ssh_add_keys__local
    )

    if [ -n "${_opts_add_all[@]}" ]; then
        if [ -n "${_ssh_agent_list_key_fingerprints}" ] || \
            [ -n "${_ssh_agent_list_key_params}" ]; then
            echo "# before"
            local _key_fingerprints_before=0
            local _key_fingerprints_after=
            local _key_params_before=0
            local _key_params_after=
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
        test -n "${_ssh_add_keys__bitbucket}" && ssh_add_keys__bitbucket
        test -n "${_ssh_add_keys__local}" && ssh_add_keys__local
    fi
    if [ -n "${_ssh_agent_status}" ]; then
        ssh_agent_status
    fi
    if [ -n "${_ssh_agent_status_all}" ]; then
        ssh_agent_status_all
    fi
    if [ -n "${_ssh_agent_list_key_fingerprints}" ]; then
        _key_fingerprints_after="$(ssh_agent_list_key_fingerprints)"
        echo "${_key_fingerprints_after}"
        if [ -n "${_key_fingerprints_before}" ]; then
            diff -Naur \
                <(echo "${_key_fingerprints_before}") \
                <(echo "${_key_fingerprints_after}")
        fi
    fi
    if [ -n "${_ssh_agent_list_key_params}" ]; then
        _key_params_after="$(ssh_agent_list_key_params)"
        echo "${_key_params_after}"
        if [ -n "${_key_params_before}" ]; then
            diff -Naur \
                <(echo "${_key_params_before}") \
                <(echo "${_key_params_after}")
        fi
    fi
}

function ssh_add_keys_run_tests {
    #set -x
    _TEST__NAME=
    function test_start {
        export _TEST__NAME="${@}"
        # echo "# ${@}" >&2
    }

    function test_fail {
        local _test_name="${1:-"${_TEST__NAME}"}"
        shift
        local _msg="${@}"
        echo "# - [FAIL] ${_test_name} : ${_msg}" >&2
    }
    function test_pass {
        local _test_name="${1:-"${_TEST__NAME}"}"
        shift
        local _msg="${@}"
        echo "# - [PASS] ${_test_name} : ${_msg}" >&2
    }
    function test_eval {
        local _test_name="${1:-"${_expect_retcode}"}"

        local expect_retcode="${2:-0}"
        local retcode="${3:-${?}}" # TODO: doe this work?
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

if [ "${BASH_SOURCE}" == "${0}" ]; then
    # echo '# ${@}='"$(shell_escape_single ${@})" >&2
    if [[ "${_logdest}" != "" ]]; then
        ssh_add_keys "${@}" | tee -a "${_logdest}"
    else
        ssh_add_keys "${@}"
    fi
    exit
fi
