#!/usr/bin/env bash

set -e

# Source common functionality
source "$(dirname "${BASH_SOURCE[0]}")/_git-clone-utils.sh"

git_fork_and_update_remotes_parse_args() {
    # First pass: standard args
    for arg in "$@"; do
        case "$arg" in
            -h|--help)
                echo "Updates remotes for an existing cloned repository to match the structure:"
                echo "  origin   -> username/reponame"
                echo "  upstream -> orgname/reponame"
                echo ""
                echo "Usage: $0 [options]"
                echo ""
                echo "Options:"
                echo "  --switch-to=<remote>   Default: upstream"
                echo "  --no-switch-to         Do not switch to remote"
                echo "  --recursive, --recurse-submodules[=<pathspec>],"
                echo "  --depth=<depth>, --[no-]shallow-submodules,"
                echo "  --[no-]reject-shallow  Passed directly to git clone/fetch"
                echo "  (You can safely pass other unrecognized arguments through to git)"
                echo "  -u|--username=<user>   Set username"
                echo "  -v|--verbose           Enable verbose logging"
                echo "  -q|--quiet             Enable quiet logging"
                echo "  --loglevel=<level>     Set log level"
                echo ""
                echo "Examples:"
                echo "  $0 --username=octocat --switch-to=origin"
                echo "  $0"
                echo "  $0 --switch-to=upstream/main"
                echo "  $0 --switch-to=upstream/gh-pages https://github.github.io/linguist/docs"
                exit 0
                ;;
        esac
    done

    # Delegate to common argument parsing
    parse_common_args "$@"
}

git_fork_and_update_remotes_main() {
    git_fork_and_update_remotes_parse_args "$@"

    # Get current origin URL
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        log_error "Error: Must be run inside a git repository."
        exit 1
    fi

    local current_origin=
    current_origin=$(git remote get-url origin 2>/dev/null || echo "")
    if [ -z "$current_origin" ]; then
        log_error "Error: No origin remote found."
        exit 1
    fi

    local orgname=""
    local reponame=""
    local repotype=""
    local repo_domain=""
    extract_org_repo "$current_origin"

    log_info "Updating remotes for repo: $reponame (Username: $USERNAME)"

    # If origin doesn't belong to the username, move it to upstream
    if [[ "$current_origin" != *"$USERNAME"* ]]; then
        git remote rename origin upstream || true
        # Add new origin pointing to the fork
        git remote add origin "git@${repo_domain}:$USERNAME/$reponame.git" || git remote add origin "https://${repo_domain}/$USERNAME/$reponame.git"
    fi

    git fetch "${GIT_ARGS[@]}" --all

    log_info "Remotes configured:"
    if [[ "$LOGLEVEL" != "quiet" ]]; then
        git remote -v
    fi

    if [ "$SWITCH_TO" != "none" ] && [ -n "$SWITCH_TO" ]; then
        log_info "Switching to $SWITCH_TO..."
        git fetch "${GIT_ARGS[@]}" "$SWITCH_TO"
    fi
    
    # We still need a check here if we want to run git submodule update
    # Since we dropped the boolean let's check the array
    local has_recursive=false
    for arg in "${GIT_ARGS[@]}"; do
        if [[ "$arg" == "--recursive" || "$arg" == "--recurse-submodules"* ]]; then
            has_recursive=true
            break
        fi
    done

    if [[ "$has_recursive" == "true" ]]; then
        log_info "Updating submodules..."
        git submodule update --init --recursive
    fi

    print_commands
}

test_git_fork_and_update_remotes() {
    echo "Running git_fork_and_update_remotes tests..."
    
    assert_eq() {
        local actual="$1"
        local expected="$2"
        local msg="$3"
        if [[ "$expected" != "$actual" ]]; then
            echo "FAIL: $msg. Expected '$expected', got '$actual'"
            exit 1
        fi
    }

    # Reset globals before test
    LOGLEVEL="info"
    SWITCH_TO="upstream"
    USERNAME=""
    PARSED_POS_ARGS=()

    git_fork_and_update_remotes_parse_args "-q" "--username=testdev" "--no-switch-to"
    assert_eq "$LOGLEVEL" "quiet" "loglevel parsed"
    assert_eq "$USERNAME" "testdev" "username parsed"
    assert_eq "$SWITCH_TO" "none" "switch-to parsed"

    git_fork_and_update_remotes_parse_args "--switch-to=upstream/gh-pages" "https://github.github.io/linguist/docs"
    assert_eq "$SWITCH_TO" "upstream/gh-pages" "switch-to pages branch parsed"
    assert_eq "${#PARSED_POS_ARGS[@]}" "1" "Positional url passed to array"
    assert_eq "${PARSED_POS_ARGS[0]}" "https://github.github.io/linguist/docs" "Positional pages url is retained"

    echo "All git_fork_and_update_remotes tests passed!"
}

if [[ "${RUN_TESTS_GIT_FORK_AND_UPDATE_REMOTES:-}" == "true" ]]; then
    test_git_fork_and_update_remotes
elif [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    git_fork_and_update_remotes_main "$@"
fi
