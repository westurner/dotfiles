#!/usr/bin/env bash
### git-track-all-remotes.sh 

## Adapted from
# - https://stackoverflow.com/questions/67699/clone-all-remote-branches-with-git/4754797#comment50364940_4754797

function git_track_all_remotes_help {
    local __file__="$(basename "${0}")"
    echo "${__file__} <path> [<name:origin>] [prefix:remotes/<name>/]"
    echo ""
    echo "Create Git local tracking branches for **ALL** of a remote's branches."
    echo ""
    echo "  -t/--test             run all tests"
    echo "  -T/--test-fail-early  run tests (and fail early)"
    echo "  -h/--help             print (this) help"
    echo ""
    return 0
}

function git_track_all_remotes {
    ## git_track_all_remotes -- add local tracking branches for all remote
    local _path="${1:-"."}"
    local _name="${2:-"origin"}"
    local _prefix="${3:-"remotes/${_name}/"}"
    echo "# remotes/branches before"
    git -C "${_path}" remote -v
    git -C "${_path}" branch -a
    for BRANCH in \
        $(git -C "${_path}" branch -a \
            | grep remotes \
            | grep -v HEAD \
            | grep -v master); do
        git branch --track "${BRANCH#${_prefix}}" "${BRANCH}";
    done
    echo "# remotes/branches after"
    git -C "${_path}" remote -v
    git -C "${_path}" branch -a
}


### test utils
__TEST_NAME="_unset_"  # GLOBAL

__TESTS_STARTED_ARRAY=( )
__TEST_RESULTS_ARRAY=( )
__TESTS_FAILED_ARRAY=( )
__TESTS_PASSED_ARRAY=( )

GREEN='\033[0;32m'
RED='\033[0;31m'
LIGHT_PURPLE='\033[1;35m'
LIGHT_BLUE='\033[1;34m'
NC='\033[0m' # No Color

function test_start {
    __TEST_NAME="${1:-"${@}"}" 
    __TESTS_STARTED_ARRAY+="${__TEST_NAME}"$'\n'
    printf "${LIGHT_BLUE}###### ${__TEST_NAME} ######${NC}\n"
}
function test_pass {
    local __TEST_NAME="${1:-"${__TEST_NAME}"}"
    local _str="## ${__TEST_NAME} ... ${GREEN}PASS${NC}"
    __TEST_RESULTS_ARRAY+="${_str}"$'\n'
    __TESTS_PASSED_ARRAY+="${_str}"$'\n'
    printf "${GREEN}${_str}${NC}\n"
    return 0
}
function test_fail {
    local __TEST_NAME="${1:-"${__TEST_NAME}"}"
    local _str="#! ${__TEST_NAME} ... ${RED}FAIL${NC}"
    __TEST_RESULTS_ARRAY+="${_str}"$'\n'
    __TESTS_FAILED_ARRAY+="${_str}"$'\n'
    printf "${RED}${_str}${NC}\n"
    return 1
}
###

function test_git_track_all_remotes {
    test_start "${LIGHT_PURPLE}test_git_track_all_remotes[]"

    function test_git_track_all_remotes_help {
        test_start "test_git_track_all_remotes_help"
        git_track_all_remotes_help || return 1
        local _output="$(git_track_all_remotes_help)"
        test -n "${_output}" || return 1
    }
    test_git_track_all_remotes_help && test_pass || test_fail

    function __GIT_add_commit {
        local _testfilename="${1:-"README"}"
        local _repodir="${2:-'.'}"
        local _GIT="${3:-"git -C ${_repodir}"}"
        local _testfilepath="${_repodir}/${_testfilename}"
        echo "${_testfilename}" > "${_testfilepath}"
        test -z "${_GIT}" && echo "_GIT unset" && return 1
        $_GIT add "${_testfilename}"
        $_GIT commit "${_testfilename}" -m "DOC: ${_testfilename}"
        return
    }

    function _tearDown_testrepo {
        echo "# _tearDown_testrepo"
        # remove the git repos
        local _repodir="${1:-"./tst"}"
        local _repodir2="${2:-"${_repodir}:origin"}"
        (set -x; \
            rm -rf "${_repodir}"; \
            rm -rf "${_repodir2}" )
    }
    function _setUp_testrepo {
        function __setUp_testrepo {
            ##  -- create a git repository for testing
            local _repodir="${1:-"./tst"}"
            local _repodir2="${_repodir}:origin"

            local _remote0="origin"
            local _remote0url="${_repodir2}"

            local _branch0="master"
            local _branch1="develop"
            local _branch2="patch-1"

            # initialize two repos _repodir and _repodir2
            local _GIT1="git -C ${_repodir}"
            local _GIT2="git -C ${_repodir2}"

            mkdir -p "${_repodir}"
            $_GIT1 init
            __GIT_add_commit "GIT1" "${_repodir}"

            mkdir -p "${_repodir2}"
            $_GIT2 init
            __GIT_add_commit "GIT2" "${_repodir2}"

            # add git remotes 
            $_GIT1 remote add "${_remote0}" "${_remote0url}"
            #$_GIT1 remote add remote2 "${_repodir3}"
            # Print remotes and branches
            $_GIT1 remote -v
            $_GIT1 branch -a

            # Add files on the master branch
            __GIT_add_commit "README" "${_repodir}"

            # Print branches
            $_GIT1 remote -v
            $_GIT1 branch -a

            # add another file
            __GIT_add_commit "README.${_branch0}" "${_repodir}"
            $_GIT1 push "${_remote0}" "${_branch0}"

            # Create a new branch and add another file
            $_GIT1 checkout -b "${_branch1}"
            __GIT_add_commit "README.${_branch1}" "${_repodir}"
            $_GIT1 push "${_remote0}" "${_branch1}"

            # Create a new branch and add another file
            $_GIT1 checkout -b "${_branch2}"
            __GIT_add_commit "README.${_branch2}" "${_repodir}"
            $_GIT1 push "${_remote0}" "${_branch2}"

            $_GIT1 push --mirror "${_remote0}"

            # Print log messages from each repo
            echo "###### GIT1 Log: ${_repodir} ######"
            $_GIT1 log
            echo "###### GIT2 Log: ${_repodir2} ######"
            $_GIT2 log
            # _repodir2 # TODO: revisions

            # Remove repo1 and recreate by cloning from repo2
            # (so as to have a normal git clone origin remote configured)
            rm -rf "${_repodir}"
            git clone "${_repodir2}" "${_repodir}" 

            # Print remotes and branches
            echo "###### GIT1 remote, branches ######"
            $_GIT1 remote -v
            $_GIT1 branch -a

            echo "###### GIT2 remote, branches ######"
            $_GIT2 remote -v
            $_GIT2 branch -a

        }
        (set -x -e; __setUp_testrepo "${@}")
    }


    function test_git_track_all_remotes_setUp_testrepo  {
        test_start "test_git_track_all_remotes_setUp_testrepo "
        local _path="${1:-"./tst"}"
        _tearDown_testrepo "${_path}" || true
        # TODO: assert not present
        _setUp_testrepo "${_path}"
        _assert_git_branches "${_path}"

    }
    test_git_track_all_remotes_setUp_testrepo && test_pass || test_fail


    function _assert_git_track_all_remotes {
        local _path="${1:-'./tst'}"
        local _GIT="git -C ${_path}"
        local _remotes="$($_GIT remote -v)"
        test "${_remotes}" = "${_remotes}"
        echo "${_remotes}"
        _assert_git_branches
    }

    function _assert_git_branches {
        local _branches="$($_GIT branch -a)"
        echo "${_branches}"
        echo "${_branches}" | grep "master" || return 1
        echo "${_branches}" | grep "develop" || return 1
        echo "${_branches}" | grep "patch-1" || return 1

    }

    # TODO
    function test_git_track_all_remotes_null {
        test_start "test_git_track_all_remotes_null"
        local _path="./tst"
        _tearDown_testrepo "${_path}"
        _setUp_testrepo "${_path}"
        
        (cd "${_path}" && git_track_all_remotes) || return
    }
    test_git_track_all_remotes_null

    function test_git_track_all_remotes_dot {
        test_start "test_git_track_all_remotes_dot"
        local _path="./tst"
        _tearDown_testrepo "${_path}"
        _setUp_testrepo "${_path}"
        (cd "${_path}" && git_track_all_remotes .) || return 1
        _assert_git_track_all_remotes "${_path}"
    }
    test_git_track_all_remotes_dot && test_pass || test_fail
    
    function test_git_track_all_remotes_path {
        test_start "test_git_track_all_remotes_path"
        local _path="./tst"
        _tearDown_testrepo "${_path}"
        _setUp_testrepo "${_path}"
        git_track_all_remotes "${_path}"
        _assert_git_track_all_remotes "${_path}"
    }
    test_git_track_all_remotes_path && test_pass || test_fail

    function test_git_track_all_remotes_path_origin {
        test_start "test_git_track_all_remotes_path_origin"
        local _path="./tst"
        _tearDown_testrepo "${_path}"
        _setUp_testrepo "${_path}"
        git_track_all_remotes "${_path}" "origin"
        _assert_git_track_all_remotes "${_path}" "origin"
    }
    test_git_track_all_remotes_path_origin && test_pass || test_fail

    function test_git_track_all_remotes_path_origin_prefix {
        test_start "test_git_track_all_remotes_path_origin_prefix"
        local _path="./tst"
        _tearDown_testrepo "${_path}"
        _setUp_testrepo "${_path}"
        git_track_all_remotes "${_path}" "origin" "remotes/origin/"
        _assert_git_track_all_remotes "${_path}" "origin"
    }
    test_git_track_all_remotes_path_origin_prefix && test_pass || test_fail

    function test_git_track_all_remotes_path_origin2 {
        test_start "test_git_track_all_remotes_path_origin2"
        local _path="./tst"
        _tearDown_testrepo "${_path}"
        _setUp_testrepo "${_path}"
        git_track_all_remotes "${_path}" "origin2"
        _assert_git_track_all_remotes "${_path}" "origin2"
    }
    test_git_track_all_remotes_path_origin2 && test_pass || test_fail

    function test_git_track_all_remotes_path_origin2_prefix {
        test_start "test_git_track_all_remotes_path_origin2_prefix"
        local _path="./tst"
        _tearDown_testrepo "${_path}"
        _setUp_testrepo "${_path}"
        git_track_all_remotes "${_path}" "origin2" "remotes/origin2/"
        _assert_git_track_all_remotes "${_path}" "origin2"
    }
    test_git_track_all_remotes_path_origin2_prefix && test_pass || test_fail

    function test_git_track_all_remotes_path_origin2_prefix_ORIGIN {
        test_start "test_git_track_all_remotes_path_origin2_prefix_ORIGIN"
        local _path="./tst"
        _tearDown_testrepo "${_path}"
        _setUp_testrepo "${_path}"
        git_track_all_remotes "${_path}" "origin2" "remotes/origin/"
        _assert_git_track_all_remotes "${_path}" "origin"
    }
    test_git_track_all_remotes_path_origin2_prefix_ORIGIN && test_pass || test_fail

    _tearDown_testrepo "${_path}"

    #echo "${__TESTS_STARTED_ARRAY}"
    function print_test_results {
        # print test results
        IFS=$'\n'
        local _color"";
        local _pass="";
        if [ -n "${__TESTS_FAILED_ARRAY}" ]; then
            _color="${RED}"
            _pass=""
        else
            _color="${GREEN}"
            _pass=true
        fi
        printf "${_color}###### print_test_results ######${NC}\n"
        for tst in ${__TEST_RESULTS_ARRAY[*]}; do
            printf "${tst}\n"
        done
        if [ -n "${_pass}" ]; then
            printf "${GREEN}PASS${NC}"
            return 0
        else
            printf "${RED}FAIL${NC}"
            return 1
        fi
    }
    (set +x; print_test_results)
    #test -n "${__TEST_FAILED_ARRAY}"
    return
}

function git_track_all_remotes_main {
    for arg in ${@}; do
        case $arg in
            -t|--test)
                shift
                (set -x; test_git_track_all_remotes && return); return
                ;;
            -T|--test-fail-early)
                shift
                (set -e -x; test_git_track_all_remotes); return
                ;;
            -h|--help)
                git_track_all_remotes_help
                return
                ;;
        esac
    done

    git_track_all_remotes "${@}"
    return
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    git_track_all_remotes_main "${@}"
fi
