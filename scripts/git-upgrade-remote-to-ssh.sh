#!/usr/bin/env bash
### git-upgrade-remote-to-ssh.sh

# set -x

function git_upgrade_remote_to_ssh_help {
## git_upgrade_remote_to_ssh_help() -- print help
    local __file__=$(basename "${0}")
    echo "${__file__}: [OPTIONS] [SCHEME] [<repopath>] [<remotename>]"
    echo "  Upgrade the scheme:// of a git remote.name.url to ssh, https, http, or git"
    echo ""
    echo "  POSITIONAL ARGS (backward compatible):"
    echo "  ssh|https|http|git        # scheme (default: ssh)"
    echo "  <repopath>                # path to repo (default: .)"
    echo "  <remotename>              # git remote name (default: origin)"
    echo ""
    echo "  NAMED ARGUMENTS:"
    echo "  --scheme <scheme>         # ssh|https|http|git|strip-username"
    echo "  --path <path>             # repository path (default: .)"
    echo "  --repo-path <path>        # alias for --path"
    echo "  --name <name>             # git remote name (default: origin)"
    echo "  --remote-name <name>      # alias for --name"
    echo "  -u / --user <username>    # specify username instead of 'git' (default: git)"
    echo "  --strip-username          # strip username and convert to https (--user "")"
    echo ""
    echo "  OPTIONS:"
    echo "  -t / --test               # run tests and echo PASS/FAIL"
    echo "  -h / --help               # print (this) help"
    echo ""
    echo "  USAGE EXAMPLES:"
    echo "  $ ${__file__} ssh"
    echo "  $ ${__file__} https . origin"
    echo "  $ ${__file__} --scheme ssh --path . --name origin"
    echo "  $ ${__file__} --scheme http --repo-path . --remote-name origin"
    echo "  $ ${__file__} --strip-username . origin"
    echo "  $ ${__file__} -u deploy ssh"
    echo "  $ ${__file__} --user ci https . origin"
    echo ""

}


function git_upgrade_url_to_ssh {
## git_upgrade_url_to_ssh() -- transform git/http/https URLs to SSH URLs
    local _currenturl="${1}"
    local _user="${2-__preserve__}"  # unset=$2 not given: preserve; ""=strip; other=replace
    local _ssh_url_
    if [ "${_user}" = "__preserve__" ]; then
        # No user arg: preserve existing user@, just change scheme
        _ssh_url_="$(echo "${_currenturl}" \
            | sed 's,^\(ssh\|git\|http\|https\)://,ssh://,' -)"
    elif [ -z "${_user}" ]; then
        # Explicitly empty: strip all usernames
        _ssh_url_="$(echo "${_currenturl}" \
            | sed "s,^\(ssh\)://\([^@/]*@\)*\(.*\),ssh://\3," - \
            | sed "s,^\(git\|http\|https\)://\([^@/]*@\)*\(.*\),ssh://\3," -)"
    else
        # Explicit user: replace any existing user
        _ssh_url_="$(echo "${_currenturl}" \
            | sed "s,^\(ssh\)://\([^@/]*@\)*\(.*\),ssh://${_user}@\3," - \
            | sed "s,^\(git\|http\|https\)://\([^@/]*@\)*\(.*\),ssh://${_user}@\3," -)"
    fi
    echo "${_ssh_url_}"
}

function git_upgrade_url_to_http {
## git_upgrade_url_to_http() -- transform git/http/https URLs to HTTP URLs
    local _currenturl="${1}"
    local _user="${2-__preserve__}"  # unset=$2 not given: preserve; ""=strip; other=replace
    local _http_url_
    if [ "${_user}" = "__preserve__" ]; then
        # No user arg: preserve existing user@, just change scheme
        _http_url_="$(echo "${_currenturl}" \
            | sed 's,^\(ssh\|git\|http\|https\)://,http://,' -)"
    elif [ -z "${_user}" ]; then
        # Explicitly empty: strip all usernames
        _http_url_="$(echo "${_currenturl}" \
            | sed "s,^\(http\|git\|https\|ssh\)://\([^@/]*@\)*\(.*\),http://\3," - \
            | sed "s,^\(git\|https\|ssh\)://\([^@/]*@\)*\(.*\),http://\3," -)"
    else
        # Explicit user: replace any existing user
        _http_url_="$(echo "${_currenturl}" \
            | sed "s,^\(http\|git\|https\|ssh\)://\([^@/]*@\)*\(.*\),http://${_user}@\3," - \
            | sed "s,^\(git\|https\|ssh\)://\([^@/]*@\)*\(.*\),http://${_user}@\3," -)"
    fi
    echo "${_http_url_}"
}

function git_upgrade_url_to_https {
## git_upgrade_url_to_https() -- transform git/http/https URLs to HTTPS URLs
    local _currenturl="${1}"
    local _user="${2-__preserve__}"  # unset=$2 not given: preserve; ""=strip; other=replace
    local _https_url_
    if [ "${_user}" = "__preserve__" ]; then
        # No user arg: preserve existing user@, just change scheme
        _https_url_="$(echo "${_currenturl}" \
            | sed 's,^\(ssh\|git\|http\|https\)://,https://,' -)"
    elif [ -z "${_user}" ]; then
        # Explicitly empty: strip all usernames
        _https_url_="$(echo "${_currenturl}" \
            | sed "s,^\(https\|git\|http\|ssh\)://\([^@/]*@\)*\(.*\),https://\3," - \
            | sed "s,^\(git\|http\|ssh\)://\([^@/]*@\)*\(.*\),https://\3," -)"
    else
        # Explicit user: replace any existing user
        _https_url_="$(echo "${_currenturl}" \
            | sed "s,^\(https\|git\|http\|ssh\)://\([^@/]*@\)*\(.*\),https://${_user}@\3," - \
            | sed "s,^\(git\|http\|ssh\)://\([^@/]*@\)*\(.*\),https://${_user}@\3," -)"
    fi
    echo "${_https_url_}"
}


function git_upgrade_url_to_git {
## git_upgrade_url_to_git() -- transform git/http/https URLs to git:// URLs
    local _currenturl="${1}"
    local _user="${2-__preserve__}"  # unset=$2 not given: preserve; ""=strip; other=replace
    local _git_url_
    if [ "${_user}" = "__preserve__" ]; then
        # No user arg: preserve existing user@, just change scheme
        _git_url_="$(echo "${_currenturl}" \
            | sed 's,^\(ssh\|git\|http\|https\)://,git://,' -)"
    elif [ -z "${_user}" ]; then
        # Explicitly empty: strip all usernames
        _git_url_="$(echo "${_currenturl}" \
            | sed "s,^\(git\)://\([^@/]*@\)*\(.*\),git://\3," - \
            | sed "s,^\(http\|https\|ssh\)://\([^@/]*@\)*\(.*\),git://\3," -)"
    else
        # Explicit user: replace any existing user
        _git_url_="$(echo "${_currenturl}" \
            | sed "s,^\(git\)://\([^@/]*@\)*\(.*\),git://${_user}@\3," - \
            | sed "s,^\(http\|https\|ssh\)://\([^@/]*@\)*\(.*\),git://${_user}@\3," -)"
    fi
    echo "${_git_url_}"
}

function git_upgrade_url_strip_username {
## git_upgrade_url_strip_username() -- strip git@ username and convert to https
    local _currenturl="${1}"
    # Convert any scheme to https, and strip git@ username
    local _stripped_url="$(echo "${_currenturl}" \
        | sed 's,^\(ssh\|git\|http\|https\)://\(git@\)\(.*\),https://\3,' - \
        | sed 's,^\(ssh\|git\|http\|https\)://\(.*\),https://\2,' -)"
    echo "${_stripped_url}"
}

# TAP test state (reset at start of test_git_upgrade_remote__main)
_tap_count=0
_tap_failed=0

function tap_comment {
## tap_comment() -- print a TAP diagnostic comment line
    printf '# %s\n' "${*}"
}

function _tap_finish {
## _tap_finish() -- print TAP plan and pass/fail summary
    printf '1..%d\n' "${_tap_count}"
    if [ "${_tap_failed}" -gt 0 ]; then
        tap_comment "FAILED: ${_tap_failed} of ${_tap_count} tests"
    else
        tap_comment "PASSED: ${_tap_count} of ${_tap_count} tests"
    fi
}

function assertEqual {
## assertEqual() -- assert "$1" == "$2"; print TAP result line
    local _expected="${1}"
    local _actual="${2}"
    _tap_count=$((_tap_count + 1))
    if [ "${_expected}" = "${_actual}" ]; then
        printf 'ok %d - %s\n' "${_tap_count}" "${_expected}"
        return 0
    else
        _tap_failed=$((_tap_failed + 1))
        printf 'not ok %d - %s\n' "${_tap_count}" "${_expected}"
        printf '  ---\n  expected: %s\n  actual:   %s\n  ...\n' \
            "${_expected}" "${_actual}"
        return 1
    fi
}

function test_git_upgrade_url_to_ssh {
## test_git_upgrade_url_to_ssh() -- test scheme:// to ssh:// transform
    tap_comment "SECTION: test_git_upgrade_url_to_ssh"
    assertEqual \
        "ssh://git@bitbucket.org/vinay.sajip/sarge#abc" \
        "$(git_upgrade_url_to_ssh 'ssh://git@bitbucket.org/vinay.sajip/sarge#abc')"
    assertEqual \
        "ssh://git@github.org/westurner/dotfiles#abc" \
        "$(git_upgrade_url_to_ssh 'ssh://git@github.org/westurner/dotfiles#abc')"

    assertEqual \
        "ssh://github.com/github/gitignore#abc" \
        "$(git_upgrade_url_to_ssh 'https://github.com/github/gitignore#abc')"
    assertEqual \
        "ssh://github.com/github/gitignore#abc" \
        "$(git_upgrade_url_to_ssh 'http://github.com/github/gitignore#abc')"
    assertEqual \
        "ssh://bitbucket.org/vinay.sajip/sarge#abc" \
        "$(git_upgrade_url_to_ssh 'https://bitbucket.org/vinay.sajip/sarge#abc')"
    assertEqual \
        "ssh://bitbucket.org/vinay.sajip/sarge#abc" \
        "$(git_upgrade_url_to_ssh 'http://bitbucket.org/vinay.sajip/sarge#abc')"
    assertEqual \
        "ssh://abc" \
        "$(git_upgrade_url_to_ssh 'http://abc')"

    assertEqual \
        "ssh://user2@localhost:442/origin2/#cba" \
        "$(git_upgrade_url_to_ssh 'https://user2@localhost:442/origin2/#cba')"

    assertEqual \
        "ssh://user2@abc" \
        "$(git_upgrade_url_to_ssh 'http://user2@abc')"

    assertEqual \
        "ssh://localhost:442/origin/#efg" \
        "$(git_upgrade_url_to_ssh 'git://localhost:442/origin/#efg')"

    assertEqual \
        "/path/to/#123" \
        "$(git_upgrade_url_to_ssh '/path/to/#123')"

    assertEqual \
        '.' \
        "$(git_upgrade_url_to_ssh '.')"

    ## test with custom user parameter
    assertEqual \
        "ssh://deploy@github.com/org/repo" \
        "$(git_upgrade_url_to_ssh 'https://github.com/org/repo' 'deploy')"
    
    assertEqual \
        "ssh://myuser@github.com/org/repo" \
        "$(git_upgrade_url_to_ssh 'ssh://git@github.com/org/repo' 'myuser')"
}

function test_git_upgrade_url_to_http {
## test_git_upgrade_url_to_http() -- test URL to HTTPS
    tap_comment "SECTION: test_git_upgrade_url_to_http"
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
    tap_comment "SECTION: test_git_upgrade_url_to_https"
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
    tap_comment "SECTION: test_git_upgrade_url_to_git"
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

    ## test with custom user parameter
    assertEqual \
        "git://ci@github.com/org/repo" \
        "$(git_upgrade_url_to_git 'https://github.com/org/repo' 'ci')"
    
    assertEqual \
        "git://deploy@github.com/org/repo" \
        "$(git_upgrade_url_to_git 'git://git@github.com/org/repo' 'deploy')"
}

function test_git_upgrade_url_strip_username {
## test_git_upgrade_url_strip_username() -- test strip git@ username and convert to https
    tap_comment "SECTION: test_git_upgrade_url_strip_username"
    assertEqual \
        "https://bitbucket.org/vinay.sajip/sarge#abc" \
        "$(git_upgrade_url_strip_username 'ssh://git@bitbucket.org/vinay.sajip/sarge#abc')"
    assertEqual \
        "https://github.org/westurner/dotfiles#abc" \
        "$(git_upgrade_url_strip_username 'ssh://git@github.org/westurner/dotfiles#abc')"

    assertEqual \
        "https://github.com/github/gitignore#abc" \
        "$(git_upgrade_url_strip_username 'https://github.com/github/gitignore#abc')"
    assertEqual \
        "https://github.com/github/gitignore#abc" \
        "$(git_upgrade_url_strip_username 'http://github.com/github/gitignore#abc')"
    assertEqual \
        "https://bitbucket.org/vinay.sajip/sarge#abc" \
        "$(git_upgrade_url_strip_username 'ssh://git@bitbucket.org/vinay.sajip/sarge#abc')"
    assertEqual \
        "https://bitbucket.org/vinay.sajip/sarge#abc" \
        "$(git_upgrade_url_strip_username 'http://bitbucket.org/vinay.sajip/sarge#abc')"
    assertEqual \
        "https://abc" \
        "$(git_upgrade_url_strip_username 'http://abc')"
    assertEqual \
        "https://abc" \
        "$(git_upgrade_url_strip_username 'ssh://git@abc')"

    assertEqual \
        "https://user2@localhost:442/origin2/#cba" \
        "$(git_upgrade_url_strip_username 'https://user2@localhost:442/origin2/#cba')"

    assertEqual \
        "https://localhost:442/origin/#efg" \
        "$(git_upgrade_url_strip_username 'git://localhost:442/origin/#efg')"

    assertEqual \
        "https://localhost:442/origin/#efg" \
        "$(git_upgrade_url_strip_username 'ssh://git@localhost:442/origin/#efg')"

    assertEqual \
        "/path/to/#123" \
        "$(git_upgrade_url_strip_username '/path/to/#123')"

    assertEqual \
        '.' \
        "$(git_upgrade_url_strip_username '.')"
}

function git_upgrade_remote_to {
## git_upgrade_remote_to() -- upgrade remote.${2:-origin}.url to $1:-"ssh"
    local _scheme="${1:-"ssh"}"
    local _path="${2:-"."}"
    local _name="${3:-"origin"}"
    local _user="${4-__preserve__}"  # unset: preserve existing user; "": strip; other: replace
    local _git_args="${GIT_ARGS}"

    local _GIT="git -C ${_path}${_git_args:+" ${_git_args}"}"
    local _currenturl=$($_GIT config --get "remote.${_name}.url")

    # For ssh + github.com/gitlab.com without explicit user: default to "git"
    if [ "${_scheme}" = "ssh" ] && [ "${_user}" = "__preserve__" ]; then
        if echo "${_currenturl}" | grep -qE 'github\.com|gitlab\.com'; then
            _user="git"
        fi
    fi

    case "$_scheme" in
        ssh)
            local _newurl=$(git_upgrade_url_to_ssh "${_currenturl}" "${_user}");;
        https)
            local _newurl=$(git_upgrade_url_to_https "${_currenturl}" "${_user}");;
        http)
            local _newurl=$(git_upgrade_url_to_http "${_currenturl}" "${_user}");;
        git)
            local _newurl=$(git_upgrade_url_to_git "${_currenturl}" "${_user}");;
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
    # local _user  # unset=preserve; ""=strip; other=replace
    git_upgrade_remote_to ssh "${1}" "${2}" "${3-__preserve__}"
}

function git_upgrade_remote_to_http {
## git_upgrade_remote_to_http() -- upgrade remote.${2:-origin}.url to http://
    # local _path="${1:-"."}"
    # local _name="${2:-"origin"}"
    # local _user  # unset=preserve; ""=strip; other=replace
    git_upgrade_remote_to http "${1}" "${2}" "${3-__preserve__}"
}

function git_upgrade_remote_to_https {
## git_upgrade_remote_to_https() -- upgrade remote.${2:-origin}.url to https://
    # local _path="${1:-"."}"
    # local _name="${2:-"origin"}"
    # local _user  # unset=preserve; ""=strip; other=replace
    git_upgrade_remote_to https "${1}" "${2}" "${3-__preserve__}"
}

function git_upgrade_remote_to_git {
## git_upgrade_remote_to_git() -- upgrade remote.${2:-origin}.url to git://
    # local _path="${1:-"."}"
    # local _name="${2:-"origin"}"
    # local _user  # unset=preserve; ""=strip; other=replace
    git_upgrade_remote_to git "${1}" "${2}" "${3-__preserve__}"
}

function git_upgrade_remote_to_strip_username {
## git_upgrade_remote_to_strip_username() -- strip git@ username and upgrade to https://
    local _path="${1:-"."}"
    local _name="${2:-"origin"}"
    local _git_args="${GIT_ARGS}"

    local _GIT="git -C ${_path}${_git_args:+" ${_git_args}"}"
    local _currenturl=$($_GIT config --get "remote.${_name}.url")
    local _newurl=$(git_upgrade_url_strip_username "${_currenturl}")
    test -n "${_newurl}"
    echo "# $_GIT remote set-url ${_name} ${_currenturl}"  # XXX singleescape
    (set -x; $_GIT remote set-url "${_name}" "${_newurl}")
}

function test_git_upgrade_remote__main {
## test_git_upgrade_remote__main() -- tests git_upgrade_remote_to_ssh
    set +e
    _tap_count=0
    _tap_failed=0
    printf 'TAP version 13\n'

    ## verify git_upgrade_remote_to_ssh_help produces output
    tap_comment "SECTION: git_upgrade_remote_to_ssh_help"
    git_upgrade_remote_to_ssh_help > /dev/null || return 1
    test -n "$(git_upgrade_remote_to_ssh_help)" || return 1

    ## test git_upgrade_url_to_ssh
    test_git_upgrade_url_to_ssh

    ## test git_upgrade_url_to_http
    test_git_upgrade_url_to_http

    ## test git_upgrade_url_to_https
    test_git_upgrade_url_to_https

    ## test git_upgrade_url_to_git
    test_git_upgrade_url_to_git

    ## test git_upgrade_url_strip_username
    test_git_upgrade_url_strip_username

    tap_comment "SECTION: integration tests"

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
        assertEqual "${_testvalue}" "${_currenturl}"
    }

    local _repodir="./tst"

    local _originurl_http="http://localhost:440/origin/#abc"
    local _originurl_ssh="ssh://localhost:440/origin/#abc"  # preserve: no user in http source

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
    _test_git_upgrade_remote_to_ssh_0 || { _tap_finish; return; }

    function _test_git_upgrade_remote_to_ssh_1 {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_to_ssh "${_repodir}" origin
        assert_remote_url "${_repodir}" "${_originurl_ssh}" origin
        git_upgrade_remote_to_ssh "${_repodir}" origin2
        assert_remote_url "${_repodir}" "${_originurl2_ssh}" origin2
    }
    _test_git_upgrade_remote_to_ssh_1 || { _tap_finish; return; }

    function _test_git_upgrade_remote_to_ssh_2 {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_to_ssh "${_repodir}" origin
        assert_remote_url "${_repodir}" "${_originurl_ssh}" origin
        git_upgrade_remote_to_ssh "${_repodir}" origin2
        assert_remote_url "${_repodir}" "${_originurl2_ssh}" origin2
    }
    _test_git_upgrade_remote_to_ssh_2 || { _tap_finish; return; }

    function _test_git_upgrade_remote_to_ssh_3 {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_to_ssh "${_repodir}" origin
        assert_remote_url "${_repodir}" "${_originurl_ssh}" origin
        git_upgrade_remote_to_ssh "${_repodir}" origin2
        assert_remote_url "${_repodir}" "${_originurl2_ssh}" origin2
    }
    _test_git_upgrade_remote_to_ssh_3 || { _tap_finish; return; }

    ## test custom user (-u/--user argument with wrapper functions)
    function _test_custom_user_ssh {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_to_ssh "${_repodir}" origin "deploy"
        assert_remote_url "${_repodir}" "ssh://deploy@localhost:440/origin/#abc" origin
    }
    _test_custom_user_ssh || { _tap_finish; return; }

    function _test_custom_user_https {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_to_https "${_repodir}" origin "myuser"
        assert_remote_url "${_repodir}" "https://myuser@localhost:440/origin/#abc" origin
    }
    _test_custom_user_https || { _tap_finish; return; }

    function _test_custom_user_git {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_to_git "${_repodir}" origin "ci"
        assert_remote_url "${_repodir}" "git://ci@localhost:440/origin/#abc" origin
    }
    _test_custom_user_git || { _tap_finish; return; }

    ## test named arguments (--scheme, --path/--repo-path, --name/--remote-name)
    function _test_named_args_scheme_path_name {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_scheme__main --scheme ssh --path "${_repodir}" --name origin
        assert_remote_url "${_repodir}" "ssh://localhost:440/origin/#abc" origin
    }
    _test_named_args_scheme_path_name || { _tap_finish; return; }

    function _test_named_args_repo_path_remote_name {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_scheme__main --scheme https --repo-path "${_repodir}" --remote-name origin
        assert_remote_url "${_repodir}" "https://localhost:440/origin/#abc" origin
    }
    _test_named_args_repo_path_remote_name || { _tap_finish; return; }

    function _test_named_args_with_user_https {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_scheme__main --user deploy --scheme https --path "${_repodir}" --name origin
        assert_remote_url "${_repodir}" "https://deploy@localhost:440/origin/#abc" origin
    }
    _test_named_args_with_user_https || { _tap_finish; return; }

    function _test_named_args_scheme_equals {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_scheme__main --scheme=git --path="${_repodir}" --name=origin
        assert_remote_url "${_repodir}" "git://localhost:440/origin/#abc" origin
    }
    _test_named_args_scheme_equals || { _tap_finish; return; }

    function _test_named_args_user_equals {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_scheme__main --user=deploy --scheme=ssh --path="${_repodir}" --name=origin
        assert_remote_url "${_repodir}" "ssh://deploy@localhost:440/origin/#abc" origin
    }
    _test_named_args_user_equals || { _tap_finish; return; }

    function _test_named_args_empty_user_strip {
        _tearDown_testrepo
        _setUp_testrepo
        git_upgrade_remote_scheme__main --user="" --scheme=ssh --path="${_repodir}" --name=origin
        assert_remote_url "${_repodir}" "ssh://localhost:440/origin/#abc" origin
    }
    _test_named_args_empty_user_strip || { _tap_finish; return; }

    ## test github.com/gitlab.com + ssh: add "git" user even without --user
    function _test_github_ssh_adds_git_user {
        _tearDown_testrepo
        _setUp_testrepo "${_repodir}" "https://github.com/org/testrepo"
        git_upgrade_remote_scheme__main --scheme ssh --path "${_repodir}" --name origin
        assert_remote_url "${_repodir}" "ssh://git@github.com/org/testrepo" origin
    }
    _test_github_ssh_adds_git_user || { _tap_finish; return; }

    function _test_gitlab_ssh_adds_git_user {
        _tearDown_testrepo
        _setUp_testrepo "${_repodir}" "https://gitlab.com/org/testrepo"
        git_upgrade_remote_scheme__main --scheme ssh --path "${_repodir}" --name origin
        assert_remote_url "${_repodir}" "ssh://git@gitlab.com/org/testrepo" origin
    }
    _test_gitlab_ssh_adds_git_user || { _tap_finish; return; }

    function _test_non_github_ssh_preserves_user {
        ## non-github/gitlab host: SSH conversion preserves existing user
        _tearDown_testrepo
        _setUp_testrepo "${_repodir}" "https://deploy@myserver.com/org/repo"
        git_upgrade_remote_scheme__main --scheme ssh --path "${_repodir}" --name origin
        assert_remote_url "${_repodir}" "ssh://deploy@myserver.com/org/repo" origin
    }
    _test_non_github_ssh_preserves_user || { _tap_finish; return; }

    _tearDown_testrepo
    _tap_finish
    return
}

function git_upgrade_remote_scheme__main {
## git_upgrade_remote_scheme__main -- main argument handling

    if [ -z "${*}" ]; then
        git_upgrade_remote_to_ssh_help
        return
    fi

    local scheme=""
    local _path_arg="."
    local _name_arg="origin"
    local _git_user="__preserve__"  # default: preserve existing user; set via --user
    local _positional_count=0
    
    # Parse arguments
    while [ $# -gt 0 ]; do
        case "${1}" in
            -h|--help)
                git_upgrade_remote_to_ssh_help
                return
                ;;
            -t|--test)
                git_upgrade_remote_to_ssh_help >&2
                test_git_upgrade_remote__main && \
                    echo 'PASS' || echo 'FAIL'
                return
                ;;
            -u|--user)
                shift
                _git_user="${1}"
                shift
                ;;
            --user=*)
                _git_user="${1#--user=}"
                shift
                ;;
            --scheme)
                shift
                scheme="${1}"
                shift
                ;;
            --scheme=*)
                scheme="${1#--scheme=}"
                shift
                ;;
            --path)
                shift
                _path_arg="${1}"
                shift
                ;;
            --path=*)
                _path_arg="${1#--path=}"
                shift
                ;;
            --repo-path)
                shift
                _path_arg="${1}"
                shift
                ;;
            --repo-path=*)
                _path_arg="${1#--repo-path=}"
                shift
                ;;
            --name)
                shift
                _name_arg="${1}"
                shift
                ;;
            --name=*)
                _name_arg="${1#--name=}"
                shift
                ;;
            --remote-name)
                shift
                _name_arg="${1}"
                shift
                ;;
            --remote-name=*)
                _name_arg="${1#--remote-name=}"
                shift
                ;;
            ssh|Ssh|SSH)
                scheme="ssh"
                shift
                ;;
            https|Https|HTTPS)
                scheme="https"
                shift
                ;;
            http|Http|HTTP)
                scheme="http"
                shift
                ;;
            git|Git|GIT)
                scheme="git"
                shift
                ;;
            --strip-username)
                scheme="strip-username"
                shift
                ;;
            -C|--work-dir|--work-tree)
                # Skip git-specific arguments
                shift 2
                ;;
            --work-dir=*|--work-tree=*)
                # Skip git-specific arguments
                shift
                ;;
            *)
                # Positional argument: path or name
                if [ -z "${scheme}" ]; then
                    # Before scheme, shouldn't happen
                    shift
                elif [ "${_positional_count}" -eq 0 ]; then
                    _path_arg="${1}"
                    _positional_count=1
                    shift
                elif [ "${_positional_count}" -eq 1 ]; then
                    _name_arg="${1}"
                    _positional_count=2
                    shift
                else
                    # Extra argument, ignore
                    shift
                fi
                ;;
        esac
    done

    if [ -n "${_git_user}" ] && [ "${_git_user}" != "git" ] && [ "${_git_user}" != "__preserve__" ]; then
        tap_comment "+GIT_USER=${_git_user}"
    fi

    # If user is empty and no scheme specified, treat as strip-username
    if [ -z "${scheme}" ] && [ -z "${_git_user}" ]; then
        scheme="strip-username"
    fi

    # Call appropriate scheme function
    case "${scheme}" in
        ssh)
            git_upgrade_remote_to ssh "${_path_arg}" "${_name_arg}" "${_git_user}"
            return
            ;;
        https)
            git_upgrade_remote_to https "${_path_arg}" "${_name_arg}" "${_git_user}"
            return
            ;;
        http)
            git_upgrade_remote_to http "${_path_arg}" "${_name_arg}" "${_git_user}"
            return
            ;;
        git)
            git_upgrade_remote_to git "${_path_arg}" "${_name_arg}" "${_git_user}"
            return
            ;;
        strip-username)
            git_upgrade_remote_to_strip_username "${_path_arg}" "${_name_arg}"
            return
            ;;
        *)
            git_upgrade_remote_to_ssh_help
            return
            ;;
    esac

    return
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    git_upgrade_remote_scheme__main "${@}"
    exit
fi
