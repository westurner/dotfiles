#!/usr/bin/env bash

set -e

# Source common functionality
source "$(dirname "${BASH_SOURCE[0]}")/_git-clone-utils.sh"

git_clone_and_remote_upstream_parse_args() {
    # First pass: standard args
    for arg in "$@"; do
        case "$arg" in
            -h|--help)
                echo "Clones a repository from a remote host (like GitHub or GitLab) and configures remotes:"
                echo "  origin   -> username/reponame"
                echo "  upstream -> orgname/reponame"
                echo ""
                echo "Usage: $0 [options] <orgname/reponame or URL>"
                echo ""
                echo "Options:"
                echo "  --switch-to=<remote>   Default: upstream"
                echo "  --no-switch-to         Do not switch to remote"
                echo "  --recursive, --recurse-submodules[=<pathspec>] Clone with submodules"
                echo "  --depth=<depth>        Create a shallow clone"
                echo "  --[no-]reject-shallow, --[no-]shallow-submodules"
                echo "  (You can safely pass other unrecognized arguments through to git)"
                echo "  -u|--username=<user>   Set username"
                echo "  -v|--verbose           Enable verbose logging"
                echo "  -q|--quiet             Enable quiet logging"
                echo "  --loglevel=<level>     Set log level"
                echo ""
                echo "Examples:"
                echo "  $0 https://github.com/octocat/Hello-World"
                echo "  $0 -q --username=octocat --switch-to=upstream https://github.com/octocat/Hello-World"
                echo "  $0 https://github.github.io/linguist/subpath"
                echo "  $0 --switch-to=upstream/gh-pages https://github.github.io/linguist/docs"
                exit 0
                ;;
        esac
    done

    # Delegate to common argument parsing
    parse_common_args "$@"

    # Look for the positional argument
    for arg in "${PARSED_POS_ARGS[@]}"; do
        if [[ "$arg" != -* && -z "$REPO_URL" ]]; then
            REPO_URL="$arg"
        fi
    done
}

git_clone_and_remote_upstream_main() {
    git_clone_and_remote_upstream_parse_args "$@"

    if [ -z "$REPO_URL" ]; then
        log_error "Error: Organization/Repository must be provided."
        exit 1
    fi

    local orgname=""
    local reponame=""
    local repotype=""
    local repo_domain=""
    extract_org_repo "$REPO_URL"

    log_info "Cloning $orgname/$reponame (from $repotype) for user $USERNAME..."

    # Clone the user's fork as origin, or the upstream if the fork fails.
    # Set GIT_TERMINAL_PROMPT=0 prevents git hanging on an interactive credential 
    # prompt when a fork doesn't exist (preventing 404/Private auth loops).
    if env GIT_TERMINAL_PROMPT=0 git clone "${GIT_ARGS[@]}" "https://${repo_domain}/$USERNAME/$reponame.git"; then
        cd "$reponame" || exit 1
        # Add upstream
        git remote add upstream "https://${repo_domain}/$orgname/$reponame.git"
    else
        log_warn "Could not clone fork at $USERNAME/$reponame. Cloning upstream instead..."
        git clone "${GIT_ARGS[@]}" "https://${repo_domain}/$orgname/$reponame.git"
        cd "$reponame" || exit 1
        git remote rename origin upstream
        git remote add origin "https://${repo_domain}/$USERNAME/$reponame.git"
    fi

    git fetch "${GIT_ARGS[@]}" upstream

    log_info "Remotes configured:"
    if [[ "$LOGLEVEL" != "quiet" ]]; then
        git remote -v
    fi

    if [ "$SWITCH_TO" != "none" ] && [ -n "$SWITCH_TO" ]; then
        log_info "Switching to $SWITCH_TO..."
        git fetch "${GIT_ARGS[@]}" "${SWITCH_TO%%/*}"
        # TODO: git checkout/switch logic depending on branch would go here
    fi

    print_commands
}

test_git_clone_and_remote_upstream() {
    echo "Running git_clone_and_remote_upstream tests..."
    
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
    REPO_URL=""

    git_clone_and_remote_upstream_parse_args "-q" "--username=testdev" "--switch-to=dev" "https://github.com/org/repo"
    assert_eq "$LOGLEVEL" "quiet" "loglevel parsed"
    assert_eq "$USERNAME" "testdev" "username parsed"
    assert_eq "$SWITCH_TO" "dev" "switch-to parsed"
    assert_eq "$REPO_URL" "https://github.com/org/repo" "REPO_URL parsed"

    LOGLEVEL="info"
    SWITCH_TO="upstream"
    USERNAME=""
    REPO_URL=""
    PARSED_POS_ARGS=()
    
    git_clone_and_remote_upstream_parse_args "--switch-to=upstream/gh-pages" "https://github.github.io/linguist/docs"
    assert_eq "$SWITCH_TO" "upstream/gh-pages" "switch-to pages docs parsed"
    assert_eq "$REPO_URL" "https://github.github.io/linguist/docs" "REPO_URL pages docs parsed"

    LOGLEVEL="info"
    SWITCH_TO="upstream"
    USERNAME=""
    REPO_URL=""
    PARSED_POS_ARGS=()

    git_clone_and_remote_upstream_parse_args "-v" "https://westurner.github.io/dotfiles/"
    assert_eq "$LOGLEVEL" "debug" "verbose loglevel parsed"
    assert_eq "$REPO_URL" "https://westurner.github.io/dotfiles/" "westurner pages URL parsed"

    # Test cloning and switching
    local temp_dir="$(mktemp -d)"
    (
        cd "$temp_dir" || exit 1
        
        # Reset globals before full functional mock
        REPO_URL=""
        USERNAME=""
        SWITCH_TO=""
        LOGLEVEL=""
        
        git_clone_and_remote_upstream_main "-q" "--username=octocat" "--switch-to=upstream" "https://github.com/octocat/Hello-World"
        assert_eq "$(basename "$PWD")" "Hello-World" "Switched to correct directory"

        
        local origin_url=$(git remote get-url origin)
        local upstream_url=$(git remote get-url upstream)
        assert_eq "$origin_url" "https://github.com/octocat/Hello-World.git" "Origin URL is correct"
        assert_eq "$upstream_url" "https://github.com/octocat/Hello-World.git" "Upstream URL is correct"
        
        local current_branch=$(git branch --show-current || echo "none")
        assert_eq "$current_branch" "master" "Should remain on master"
    )
    local test_status=$?
    rm -rf "$temp_dir"
    if [ $test_status -ne 0 ]; then
        echo "FAIL: Clone to disk test failed"
        exit 1
    fi

    # Test fallback to upstream when fork doesn't exist
    local temp_dir2="$(mktemp -d)"
    (
        cd "$temp_dir2" || exit 1
        
        REPO_URL=""
        USERNAME=""
        SWITCH_TO=""
        LOGLEVEL=""
        
        git_clone_and_remote_upstream_main "-q" "--username=thisuserdoesnotexisthopefully" "--switch-to=upstream" "https://github.com/octocat/Hello-World"
        assert_eq "$(basename "$PWD")" "Hello-World" "Switched to correct directory"
        
        local origin_url=$(git remote get-url origin)
        local upstream_url=$(git remote get-url upstream)
        assert_eq "$origin_url" "https://github.com/thisuserdoesnotexisthopefully/Hello-World.git" "Origin URL is correct"
        assert_eq "$upstream_url" "https://github.com/octocat/Hello-World.git" "Upstream URL is correct"
    )
    local test_status2=$?
    rm -rf "$temp_dir2"
    if [ $test_status2 -ne 0 ]; then
        echo "FAIL: Clone to disk fallback test failed"
        exit 1
    fi

    # Test cloning a pages url explicitly
    local temp_dir3="$(mktemp -d)"
    (
        cd "$temp_dir3" || exit 1

        REPO_URL=""
        USERNAME=""
        SWITCH_TO=""
        LOGLEVEL=""

        git_clone_and_remote_upstream_main "-q" "--username=westurner" "https://westurner.github.io/dotfiles/"
        assert_eq "$(basename "$PWD")" "dotfiles" "Switched to correctly named pages directory"

        local origin_url=$(git remote get-url origin)
        local upstream_url=$(git remote get-url upstream)
        assert_eq "$origin_url" "https://github.com/westurner/dotfiles.git" "Origin URL is correct for pages clone"
        assert_eq "$upstream_url" "https://github.com/westurner/dotfiles.git" "Upstream URL is correct for pages clone"
    )
    local test_status3=$?
    rm -rf "$temp_dir3"
    if [ $test_status3 -ne 0 ]; then
        echo "FAIL: Clone pages URL directly test failed"
        exit 1
    fi

    echo "All git_clone_and_remote_upstream tests passed!"
}

if [[ "${RUN_TESTS_GIT_CLONE_AND_REMOTE_UPSTREAM:-}" == "true" ]]; then
    test_git_clone_and_remote_upstream
elif [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    git_clone_and_remote_upstream_main "$@"
fi
