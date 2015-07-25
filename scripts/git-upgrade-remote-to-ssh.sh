#!/bin/bash
### git-upgrade-remote-to-ssh.sh 

function git_upgrade_remote_to_ssh_help {
## git_upgrade_remote_to_ssh_help() -- print help
    local __file__=$(basename "${0}")
    echo "${__file__}: <path> <remote>"
    echo "  Upgrade Git remote URLs to SSH URLs"
    echo ""
    echo "  -t / --test    -- run tests and echo PASS/FAIL"
    echo "  -h / --help    -- print (this) help"
    echo ""
    echo "  # git -C ./ --config --get remote.origin.url    # print 'origin' URL in ./"
    echo "  $ ${__file__} -h       # print (this) help"
    echo "  $ ${__file__}          # upgrade 'origin' URLs in ./"
    echo "  $ ${__file__} .        # upgrade 'origin' URLs in ./"
    echo "  $ ${__file__} . upstream       # upgrade 'upstream' URLs in ./"
    echo "  $ ${__file__} ./path           # upgrade 'origin' URLs in ./path"
    echo "  $ ${__file__} ./path upstream  # upgrade 'upstream' URLs in ./path"
    echo ""
}


function git_upgrade_url_to_ssh {
## git_upgrade_url_to_ssh() -- transform git/http/https URLs to SSH URLs
    local _currenturl="${1}"
    local _hostpath="$(echo "${_currenturl}" \
        | sed 's,^\(git\|http\|https\)://\(.*\)$,ssh://git@\2,' - \
        | sed 's,^ssh://\(git@\)\(.*\)@\(.*\),ssh://\2@\3,' -)"
    echo "${_hostpath}"
}

function test_git_upgrade_url_to_ssh {
## test_git_upgrade_url_to_ssh() -- test URL to SSH (or identity) transforms
    test \
        "$(git_upgrade_url_to_ssh "ssh://git@bitbucket.org/vinay.sajip/sarge#abc")" \
        = "ssh://git@bitbucket.org/vinay.sajip/sarge#abc"
    test \
        "$(git_upgrade_url_to_ssh "ssh://git@github.org/westurner/dotfiles#abc")" \
        = "ssh://git@github.org/westurner/dotfiles#abc"

    test \
        "$(git_upgrade_url_to_ssh "https://github.com/github/gitignore#abc")" \
        = "ssh://git@github.com/github/gitignore#abc"
    test \
        "$(git_upgrade_url_to_ssh "http://github.com/github/gitignore#abc")" \
        = "ssh://git@github.com/github/gitignore#abc"
    test \
        "$(git_upgrade_url_to_ssh "https://bitbucket.org/vinay.sajip/sarge#abc")" \
        = "ssh://git@bitbucket.org/vinay.sajip/sarge#abc"
    test \
        "$(git_upgrade_url_to_ssh "http://bitbucket.org/vinay.sajip/sarge#abc")" \
        = "ssh://git@bitbucket.org/vinay.sajip/sarge#abc"
    test \
        "$(git_upgrade_url_to_ssh "http://abc")" \
        = "ssh://git@abc"

    test \
        "$(git_upgrade_url_to_ssh "https://user2@localhost:442/origin2/#cba")" \
        = "ssh://user2@localhost:442/origin2/#cba"

    test \
        "$(git_upgrade_url_to_ssh "http://user2@abc")" \
        = "ssh://user2@abc"

    test \
        "$(git_upgrade_url_to_ssh "git://localhost:442/origin/#efg")" \
        = "ssh://git@localhost:442/origin/#efg" || return

    test \
        "$(git_upgrade_url_to_ssh "/path/to/#123")" \
        = "/path/to/#123" || return

    test \
        "$(git_upgrade_url_to_ssh ".")" \
        = "." || return
}

function git_upgrade_remote_to_ssh {
## git_track_all_remotes() -- add local tracking branches for all remote
    local _path="${1:-"."}"
    local _name="${2:-"origin"}"

    local _GIT="git -C ${_path}"
    local _currenturl=$($_GIT config --get "remote.${_name}.url")
    local _newurl=$(git_upgrade_url_to_ssh "${_currenturl}")
    test -n "${_newurl}"
    echo "# $_GIT remote set-url ${_name} ${_currenturl}"  # XXX singleescape
    (set -x; $_GIT remote set-url "${_name}" "${_newurl}")
}

function test_git_upgrade_remote_to_ssh_main {
## test_git_upgrade_remote_to_ssh_main() -- tests git_upgrade_remote_to_ssh
    set -x

    ## print git_upgrade_remote_to_ssh_help
    git_upgrade_remote_to_ssh_help || return
    test -n "$(git_upgrade_remote_to_ssh_help)" || return

    ## test git_upgrade_url_to_ssh
    test_git_upgrade_url_to_ssh || return

    ## test git_upgrade_remote_to_ssh
    function _setUp_testrepo {
        function __setUp_testrepo {
            ##  -- create a git repository for testing
            local _repodir="${1:-"./tst"}"
            local _originurl="${2:-"http://localhost:440/origin/#abc"}"
            local _origin2url="${3:-"https://user2@localhost:442/origin2/#cba"}"

            local _GIT="git -C ${_repodir}"
            mkdir -p "${_repodir}"
            $_GIT init -q
            local _testfilename="README"
            local _testfilepath="${_repodir}/${_testfilename}"
            echo "${_testfilename}" > "${_testfilepath}"
            $_GIT add "${_testfilename}"
            $_GIT commit -q "${_testfilename}" -m "DOC: ${_testfilename}"
            test -n "${_originurl}" && \
                $_GIT remote add origin "${_originurl}"
            test -n "${_origin2url}" && \
                $_GIT remote add origin2 "${_origin2url}"
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

    local _originurl="http://localhost:440/origin/#abc"
    local _originurl_up="ssh://git@localhost:440/origin/#abc"

    local _origin2url="https://user2@localhost:442/origin2/#cba"
    local _origin2url_up="ssh://user2@localhost:442/origin2/#cba"

    function _test_git_upgrade_remote_to_ssh_this_repo_null {
        ## if '.' or no args then upgrade the origin remote in '.'
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_to_ssh
        assert_remote_url "${_repodir}" "${_originurl_up}" "origin"
    }
    # _test_git_upgrade_remote_to_ssh_this_repo_null [destructive]

    function _test_git_upgrade_remote_to_ssh_this_repo_dot {
        ## if '.' or no args then upgrade the origin remote in '.'
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_to_ssh .
        assert_remote_url "${_repodir}" "${_originurl_up}" "origin"
    }
    # _test_git_upgrade_remote_to_ssh_this_repo_dot [destructive]

    function _test_git_upgrade_remote_to_ssh_0 {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_to_ssh "${_repodir}"
        assert_remote_url "${_repodir}" "${_originurl_up}" origin
        git_upgrade_remote_to_ssh "${_repodir}" origin2
        assert_remote_url "${_repodir}" "${_origin2url_up}" origin2
    }
    _test_git_upgrade_remote_to_ssh_0 || return
    
    function _test_git_upgrade_remote_to_ssh_1 {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_to_ssh "${_repodir}" origin
        assert_remote_url "${_repodir}" "${_originurl_up}" origin
        git_upgrade_remote_to_ssh "${_repodir}" origin2
        assert_remote_url "${_repodir}" "${_origin2url_up}" origin2
    }
    _test_git_upgrade_remote_to_ssh_1 || return

    function _test_git_upgrade_remote_to_ssh_2 {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_to_ssh "${_repodir}" origin "remotes/origin"
        assert_remote_url "${_repodir}" "${_originurl_up}" origin
        git_upgrade_remote_to_ssh "${_repodir}" origin2
        assert_remote_url "${_repodir}" "${_origin2url_up}" origin2
    }
    _test_git_upgrade_remote_to_ssh_2 || return

    function _test_git_upgrade_remote_to_ssh_3 {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_to_ssh "${_repodir}" origin
        assert_remote_url "${_repodir}" "${_originurl_up}" origin
        git_upgrade_remote_to_ssh "${_repodir}" origin2
        assert_remote_url "${_repodir}" "${_origin2url_up}" origin2
    }
    _test_git_upgrade_remote_to_ssh_3 || return

    _tearDown_testrepo
    return
}

function git_upgrade_remote_to_ssh_main {
## git_upgrade_remote_to_ssh_main -- main argument handling
    for arg in ${@}; do
        case $arg in
            -t|--test)
                shift  # remove -t or --test from ${@}
                git_upgrade_remote_to_ssh_help
                test_git_upgrade_remote_to_ssh_main "${@}" && \
                    echo 'PASS' || echo 'FAIL'
                return
                ;;
            -h|--help)
                git_upgrade_remote_to_ssh_help
                return
                ;;
        esac
    done
    
    git_upgrade_remote_to_ssh "${@}"
    return
}

if [ "${BASH_SOURCE}" == "${0}" ]; then
    git_upgrade_remote_to_ssh_main "${@}"
fi
