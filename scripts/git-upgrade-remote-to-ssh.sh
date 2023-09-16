#!/usr/bin/env bash
### git-upgrade-remote-to-ssh.sh

# set -x

function git_upgrade_remote_to_ssh_help {
## git_upgrade_remote_to_ssh_help() -- print help
    local __file__=$(basename "${0}")
    echo "${__file__}: <ssh|https|http|git> [<repopath>] [<remotename>]"
    echo "  Upgrade the scheme:// of a git remote.name.url to ssh, https, http, or git"
    echo ""
    echo "  ssh|https|http|git  # ssh is the default"
    echo ""
    echo "  # git -C ./ --config --get remote.origin.url    # print 'origin' URL in ./"
    echo "  $ ${__file__} -h       # print (this) help"
    echo "  $ ${__file__} ssh"
    echo "  $ ${__file__} https"
    echo "  $ ${__file__} http"
    echo "  $ ${__file__} git"
    echo ""
    echo "  # ${__file__} ssh <path> <git remote name>"
    echo "  $ ${__file__} ssh . origin"
    echo ""
    echo "  -t / --test    -- run tests and echo PASS/FAIL"
    echo "  -h / --help    -- print (this) help"
    echo ""

}


function git_upgrade_url_to_ssh {
## git_upgrade_url_to_ssh() -- transform git/http/https URLs to SSH URLs
    local _currenturl="${1}"
    local _ssh_url___="$(echo "${_currenturl}" \
        | sed 's,^\(git\|https\|http\)://\(.*\)$,ssh://git@\2,' - \
        | sed 's,^ssh://\(git@\)\(.*\)@\(.*\),ssh://\2@\3,' -)"
    echo "${_ssh_url___}"
}

function git_upgrade_url_to_http {
## git_upgrade_url_to_https() -- transform git/http/https URLs to HTTPS URLs
    local _currenturl="${1}"
    local _https_url_="$(echo "${_currenturl}" \
        | sed 's,^\(git\|https\|ssh\)://\(.*\)$,http://\2,' - \
        | sed 's,^http://\(git@\)\(.*\)@\(.*\),http://\2@\3,' -)"
    echo "${_https_url_}"
}

function git_upgrade_url_to_https {
## git_upgrade_url_to_https() -- transform git/http/https URLs to HTTPS URLs
    local _currenturl="${1}"
    local _https_url_="$(echo "${_currenturl}" \
        | sed 's,^\(git\|http\|ssh\)://\(.*\)$,https://\2,' - \
        | sed 's,^https://\(git@\)\(.*\)@\(.*\),https://\2@\3,' -)"
    echo "${_https_url_}"
}


function git_upgrade_url_to_git {
## git_upgrade_url_to_https() -- transform git/http/https URLs to HTTPS URLs
    local _currenturl="${1}"
    local _git_url___="$(echo "${_currenturl}" \
        | sed 's,^\(https\|http\|ssh\)://\(.*\)$,git://\2,' - \
        | sed 's,^git://\(git@\)\(.*\)@\(.*\),git://\2@\3,' -)"
    echo "${_git_url___}"
}

function assertEqual {
## assertEqual()    -- assert that "$1" == "$2"
    local _arg1="${1}"
    local _arg2="${2}"
    if [ "${_arg1}" == "${_arg2}" ]; then
        return 0
    else
        echo "ERR: assertEqual <--------------------------->";
        return 1
    fi
}

function test_git_upgrade_url_to_ssh {
## test_git_upgrade_url_to_ssh() -- test scheme:// to ssh:// transform
    assertEqual \
        "ssh://git@bitbucket.org/vinay.sajip/sarge#abc" \
        "$(git_upgrade_url_to_ssh 'ssh://git@bitbucket.org/vinay.sajip/sarge#abc')"
    assertEqual \
        "ssh://git@github.org/westurner/dotfiles#abc" \
        "$(git_upgrade_url_to_ssh 'ssh://git@github.org/westurner/dotfiles#abc')"

    assertEqual \
        "ssh://git@github.com/github/gitignore#abc" \
        "$(git_upgrade_url_to_ssh 'https://github.com/github/gitignore#abc')"
    assertEqual \
        "ssh://git@github.com/github/gitignore#abc" \
        "$(git_upgrade_url_to_ssh 'http://github.com/github/gitignore#abc')"
    assertEqual \
        "ssh://git@bitbucket.org/vinay.sajip/sarge#abc" \
        "$(git_upgrade_url_to_ssh 'https://bitbucket.org/vinay.sajip/sarge#abc')"
    assertEqual \
        "ssh://git@bitbucket.org/vinay.sajip/sarge#abc" \
        "$(git_upgrade_url_to_ssh 'http://bitbucket.org/vinay.sajip/sarge#abc')"
    assertEqual \
        "ssh://git@abc" \
        "$(git_upgrade_url_to_ssh 'http://abc')"

    assertEqual \
        "ssh://user2@localhost:442/origin2/#cba" \
        "$(git_upgrade_url_to_ssh 'https://user2@localhost:442/origin2/#cba')"

    assertEqual \
        "ssh://user2@abc" \
        "$(git_upgrade_url_to_ssh 'http://user2@abc')"

    assertEqual \
        "ssh://git@localhost:442/origin/#efg" \
        "$(git_upgrade_url_to_ssh 'git://localhost:442/origin/#efg')"

    assertEqual \
        "/path/to/#123" \
        "$(git_upgrade_url_to_ssh '/path/to/#123')"

    assertEqual \
        '.' \
        "$(git_upgrade_url_to_ssh '.')"
}

function test_git_upgrade_url_to_http {
## test_git_upgrade_url_to_http() -- test URL to HTTPS
    assertEqual \
        "http://git@bitbucket.org/vinay.sajip/sarge#abc" \
        "$(git_upgrade_url_to_http 'ssh://git@bitbucket.org/vinay.sajip/sarge#abc')"
    assertEqual \
        "http://git@github.org/westurner/dotfiles#abc" \
        "$(git_upgrade_url_to_http 'ssh://git@github.org/westurner/dotfiles#abc')"

    assertEqual \
        "http://github.com/github/gitignore#abc" \
        "$(git_upgrade_url_to_http 'https://github.com/github/gitignore#abc')"
    assertEqual \
        "http://github.com/github/gitignore#abc" \
        "$(git_upgrade_url_to_http 'http://github.com/github/gitignore#abc')"
    assertEqual \
        "http://bitbucket.org/vinay.sajip/sarge#abc" \
        "$(git_upgrade_url_to_http 'https://bitbucket.org/vinay.sajip/sarge#abc')"
    assertEqual \
        "http://bitbucket.org/vinay.sajip/sarge#abc" \
        "$(git_upgrade_url_to_http 'http://bitbucket.org/vinay.sajip/sarge#abc')"
    assertEqual \
        "http://abc" \
        "$(git_upgrade_url_to_http 'http://abc')"

    assertEqual \
        "http://user2@localhost:442/origin2/#cba" \
        "$(git_upgrade_url_to_http 'https://user2@localhost:442/origin2/#cba')"

    assertEqual \
        "http://user2@abc" \
        "$(git_upgrade_url_to_http 'http://user2@abc')"

    assertEqual \
        "http://localhost:442/origin/#efg" \
        "$(git_upgrade_url_to_http 'git://localhost:442/origin/#efg')"

    assertEqual \
        "/path/to/#123" \
        "$(git_upgrade_url_to_http '/path/to/#123')"

    assertEqual \
        '.' \
        "$(git_upgrade_url_to_http '.')"
}


function test_git_upgrade_url_to_https {
## test_git_upgrade_url_to_https() -- test URL to HTTPS
    assertEqual \
        "https://git@bitbucket.org/vinay.sajip/sarge#abc" \
        "$(git_upgrade_url_to_https 'ssh://git@bitbucket.org/vinay.sajip/sarge#abc')"
    assertEqual \
        "https://git@github.org/westurner/dotfiles#abc" \
        "$(git_upgrade_url_to_https 'ssh://git@github.org/westurner/dotfiles#abc')"

    assertEqual \
        "https://github.com/github/gitignore#abc" \
        "$(git_upgrade_url_to_https 'https://github.com/github/gitignore#abc')"
    assertEqual \
        "https://github.com/github/gitignore#abc" \
        "$(git_upgrade_url_to_https 'http://github.com/github/gitignore#abc')"
    assertEqual \
        "https://bitbucket.org/vinay.sajip/sarge#abc" \
        "$(git_upgrade_url_to_https 'https://bitbucket.org/vinay.sajip/sarge#abc')"
    assertEqual \
        "https://bitbucket.org/vinay.sajip/sarge#abc" \
        "$(git_upgrade_url_to_https 'http://bitbucket.org/vinay.sajip/sarge#abc')"
    assertEqual \
        "https://abc" \
        "$(git_upgrade_url_to_https 'http://abc')"

    assertEqual \
        "https://user2@localhost:442/origin2/#cba" \
        "$(git_upgrade_url_to_https 'https://user2@localhost:442/origin2/#cba')"

    assertEqual \
        "https://user2@abc" \
        "$(git_upgrade_url_to_https 'http://user2@abc')"

    assertEqual \
        "https://localhost:442/origin/#efg" \
        "$(git_upgrade_url_to_https 'git://localhost:442/origin/#efg')"

    assertEqual \
        "/path/to/#123" \
        "$(git_upgrade_url_to_https '/path/to/#123')"

    assertEqual \
        '.' \
        "$(git_upgrade_url_to_https '.')"
}

function test_git_upgrade_url_to_git {
## test_git_upgrade_url_to_git() -- test scheme:// to git://
    assertEqual \
        "git://git@bitbucket.org/vinay.sajip/sarge#abc" \
        "$(git_upgrade_url_to_git 'ssh://git@bitbucket.org/vinay.sajip/sarge#abc')"
    assertEqual \
        "git://git@github.org/westurner/dotfiles#abc" \
        "$(git_upgrade_url_to_git 'ssh://git@github.org/westurner/dotfiles#abc')"

    assertEqual \
        "git://github.com/github/gitignore#abc" \
        "$(git_upgrade_url_to_git 'https://github.com/github/gitignore#abc')"
    assertEqual \
        "git://github.com/github/gitignore#abc" \
        "$(git_upgrade_url_to_git 'http://github.com/github/gitignore#abc')"
    assertEqual \
        "git://bitbucket.org/vinay.sajip/sarge#abc" \
        "$(git_upgrade_url_to_git 'https://bitbucket.org/vinay.sajip/sarge#abc')"
    assertEqual \
        "git://bitbucket.org/vinay.sajip/sarge#abc" \
        "$(git_upgrade_url_to_git 'http://bitbucket.org/vinay.sajip/sarge#abc')"
    assertEqual \
        "git://abc" \
        "$(git_upgrade_url_to_git 'http://abc')"

    assertEqual \
        "git://user2@localhost:442/origin2/#cba" \
        "$(git_upgrade_url_to_git 'https://user2@localhost:442/origin2/#cba')"

    assertEqual \
        "git://user2@abc" \
        "$(git_upgrade_url_to_git 'http://user2@abc')"

    assertEqual \
        "git://localhost:442/origin/#efg" \
        "$(git_upgrade_url_to_git 'git://localhost:442/origin/#efg')"

    assertEqual \
        "/path/to/#123" \
        "$(git_upgrade_url_to_git '/path/to/#123')"

    assertEqual \
        '.' \
        "$(git_upgrade_url_to_git '.')"
}

function git_upgrade_remote_to {
## git_upgrade_remote_to() -- upgrade remote.${2:-origin}.url to $1:-"ssh"
    local _scheme="${1:-"ssh"}"
    local _path="${2:-"."}"
    local _name="${3:-"origin"}"
    local _git_args="${GIT_ARGS}"

    local _GIT="git -C ${_path}${_git_args:+" ${_git_args}"}"
    local _currenturl=$($_GIT config --get "remote.${_name}.url")
    case "$_scheme" in
        ssh)
            local _newurl=$(git_upgrade_url_to_ssh "${_currenturl}");;
        https)
            local _newurl=$(git_upgrade_url_to_https "${_currenturl}");;
        http)
            local _newurl=$(git_upgrade_url_to_http "${_currenturl}");;
        git)
            local _newurl=$(git_upgrade_url_to_git "${_currenturl}");;
        *)
            echo "Unknown git scheme: $_scheme" >&2
            return 2
            ;;
    esac
    test -n "${_newurl}"
    echo "# $_GIT remote set-url ${_name} ${_currenturl}"  # XXX singleescape
    (set -x; $_GIT remote set-url "${_name}" "${_newurl}")
}

function git_upgrade_remote_to_ssh {
## git_upgrade_remote_to_ssh() -- upgrade remote.${2:-origin}.url to ssh://
    # local _path="${1:-"."}"
    # local _name="${2:-"origin"}"
    git_upgrade_remote_to ssh "${1}" "${2}"
}

function git_upgrade_remote_to_http {
## git_upgrade_remote_to_http() -- upgrade remote.${2:-origin}.url to http://
    # local _path="${1:-"."}"
    # local _name="${2:-"origin"}"
    git_upgrade_remote_to http "${1}" "${2}"
}

function git_upgrade_remote_to_https {
## git_upgrade_remote_to_https() -- upgrade remote.${2:-origin}.url to https://
    # local _path="${1:-"."}"
    # local _name="${2:-"origin"}"
    git_upgrade_remote_to https "${1}" "${2}"
}

function git_upgrade_remote_to_git {
## git_upgrade_remote_to_git() -- upgrade remote.${2:-origin}.url to https://
    # local _path="${1:-"."}"
    # local _name="${2:-"origin"}"
    git_upgrade_remote_to git "${1}" "${2}"
}

function test_git_upgrade_remote__main {
## test_git_upgrade_remote__main() -- tests git_upgrade_remote_to_ssh
    set -x
    set +e

    ## print git_upgrade_remote_to_ssh_help
    git_upgrade_remote_to_ssh_help || return 1
    test -n "$(git_upgrade_remote_to_ssh_help)" || return 1

    ## test git_upgrade_url_to_ssh
    test_git_upgrade_url_to_ssh || return 1

    ## test git_upgrade_url_to_http
    test_git_upgrade_url_to_http || return 1

    ## test git_upgrade_url_to_https
    test_git_upgrade_url_to_https || return 1

    ## test git_upgrade_url_to_git
    test_git_upgrade_url_to_git || return 1

    #echo "HERE"
    #return 1

    ## test git_upgrade_remote_to_ssh
    function _setUp_testrepo {
        function __setUp_testrepo {
            ##  -- create a git repository for testing
            local _repodir="${1:-"./tst"}"
            local _originurl_http="${2:-"http://localhost:440/origin/#abc"}"
            local _originurl2_https="${3:-"https://user2@localhost:442/origin2/#cba"}"

            local _GIT="git -C ${_repodir}"
            mkdir -p "${_repodir}"
            $_GIT init -q
            local _testfilename="README"
            local _testfilepath="${_repodir}/${_testfilename}"
            echo "${_testfilename}" > "${_testfilepath}"
            $_GIT add "${_testfilename}"
            $_GIT commit -q "${_testfilename}" -m "DOC: ${_testfilename}"
            test -n "${_originurl_http}" && \
                $_GIT remote add origin "${_originurl_http}"
            test -n "${_originurl2_https}" && \
                $_GIT remote add origin2 "${_originurl2_https}"
            $_GIT remote -v
        }
        (set -x; __setUp_testrepo "${@}")
    }

    function _tearDown_testrepo {
        ##  -- rmthing
        local _repodir="${1:-"./tst"}"
        (set -x; rm -rf "${_repodir}")
    }

    function assert_remote_url {
        local _repodir="${1:-"./tst"}"
        local _testvalue="${2}"
        local _name="${3}"
        test -n "${_name}"
        local _GIT="git -C ${_repodir}"
        local _currenturl=$($_GIT config --get "remote.${_name}.url")
        test "${_currenturl}" = "${_testvalue}"
    }

    local _repodir="./tst"

    local _originurl_http="http://localhost:440/origin/#abc"
    local _originurl_ssh="ssh://git@localhost:440/origin/#abc"

    local _originurl2_https="https://user2@localhost:442/origin2/#cba"
    local _originurl2_ssh="ssh://user2@localhost:442/origin2/#cba"

    function _test_git_upgrade_remote_to_ssh_this_repo_null {
        ## if '.' or no args then upgrade the origin remote in '.'
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_to_ssh
        assert_remote_url "${_repodir}" "${_originurl_ssh}" "origin"
    }
    # _test_git_upgrade_remote_to_ssh_this_repo_null [destructive]

    function _test_git_upgrade_remote_to_ssh_this_repo_dot {
        ## if '.' or no args then upgrade the origin remote in '.'
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_to_ssh .
        assert_remote_url "${_repodir}" "${_originurl_ssh}" "origin"
    }
    # _test_git_upgrade_remote_to_ssh_this_repo_dot [destructive]

    function _test_git_upgrade_remote_to_ssh_0 {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_to_ssh "${_repodir}"
        assert_remote_url "${_repodir}" "${_originurl_ssh}" origin
        git_upgrade_remote_to_ssh "${_repodir}" origin2
        assert_remote_url "${_repodir}" "${_originurl2_ssh}" origin2
    }
    _test_git_upgrade_remote_to_ssh_0 || return

    function _test_git_upgrade_remote_to_ssh_1 {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_to_ssh "${_repodir}" origin
        assert_remote_url "${_repodir}" "${_originurl_ssh}" origin
        git_upgrade_remote_to_ssh "${_repodir}" origin2
        assert_remote_url "${_repodir}" "${_originurl2_ssh}" origin2
    }
    _test_git_upgrade_remote_to_ssh_1 || return

    function _test_git_upgrade_remote_to_ssh_2 {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_to_ssh "${_repodir}" origin "remotes/origin"
        assert_remote_url "${_repodir}" "${_originurl_ssh}" origin
        git_upgrade_remote_to_ssh "${_repodir}" origin2
        assert_remote_url "${_repodir}" "${_originurl2_ssh}" origin2
    }
    _test_git_upgrade_remote_to_ssh_2 || return

    function _test_git_upgrade_remote_to_ssh_3 {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_to_ssh "${_repodir}" origin
        assert_remote_url "${_repodir}" "${_originurl_ssh}" origin
        git_upgrade_remote_to_ssh "${_repodir}" origin2
        assert_remote_url "${_repodir}" "${_originurl2_ssh}" origin2
    }
    _test_git_upgrade_remote_to_ssh_3 || return

    _tearDown_testrepo
    return
}

function git_upgrade_remote_scheme__main {
## git_upgrade_remote_scheme__main -- main argument handling

    if [ -z "${*}" ]; then
        git_upgrade_remote_to_ssh_help
        return
    fi

    _git_args=""
    for arg in "${@}"; do
        if [ -n "${_append_next_arg_to_git_args}" ]; then
            _git_args="${_git_args} ${arg}"
            _append_next_arg_to_git_args=
            continue
        fi
        case "${arg}" in
            -C|--work-dir|--work-tree)
                _git_args="${_git_args:+"${_git_args} "}""${arg}"
                shift
                _append_next_arg_to_git_args=1
                shift
                ;;
            --work-dir=*|--work-tree=*)
                _git_args="${_git_args:+"${_git_args} "}""${arg}"
                shift
                ;;
        esac
    done
    if [ -n "${_git_args}" ]; then
        export GIT_ARGS="${_git_args}"
        echo "+GIT_ARGS=${GIT_ARGS}"
    fi

    local scheme
    for arg in ${@}; do
        case "${arg}" in

            ssh|Ssh|SSH)
                shift
                scheme="ssh";;
            https|Https|HTTPS)
                shift
                scheme="https";;
            http|Http|HTTP)
                shift
                scheme="http";;
            git|Git|GIT)
                shift
                schema="git";;

            -t|--test)
                shift  # remove -t or --test from ${@}
                git_upgrade_remote_to_ssh_help
                test_git_upgrade_remote__main "${@}" && \
                    echo 'PASS' || echo 'FAIL'
                return
                ;;
            -h|--help)
                git_upgrade_remote_to_ssh_help
                return
                ;;
        esac
    done

    case "${scheme}" in
        ssh)
            git_upgrade_remote_to_ssh "${@}";
            return
            ;;
        https)
            git_upgrade_remote_to_https "${@}"
            return
            ;;
        http)
            git_upgrade_remote_to_http "${@}"
            return
            ;;
        git)
            git_upgrade_remote_to_git "${@}"
            return
            ;;
    esac

    return
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    git_upgrade_remote_scheme__main "${@}"
    exit
fi
