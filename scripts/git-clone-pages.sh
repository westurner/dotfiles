#!/usr/bin/env bash

set -e

# Source common functionality
source "$(dirname "${BASH_SOURCE[0]}")/_git-clone-utils.sh"

git_clone_pages_main() {
    local url="$1"
    if [[ -z "$url" || "$url" == "-h" || "$url" == "--help" ]]; then
        echo "Parses a GitHub Pages or GitLab Pages (.io) URL and constructs its source repository URL."
        echo ""
        echo "Usage: $0 <github.io or gitlab.io URL>"
        echo ""
        echo "Examples:"
        echo "  $0 https://github.github.io/linguist/subpath"
        echo "    -> Repo URL: https://github.com/github/linguist"
        echo "    -> Path URL: https://github.com/github/linguist/tree/main/subpath"
        echo ""
        echo "  $0 https://gitlab-org.gitlab.io/gitlab-docs/subpath"
        echo "    -> Repo URL: https://gitlab.com/gitlab-org/gitlab-docs"
        echo "    -> Path URL: https://gitlab.com/gitlab-org/gitlab-docs/tree/master/subpath"
        exit 1
    fi

    local orgname=""
    local reponame=""
    local repotype=""
    local repo_domain=""
    local is_pages_site=""
    local repo_branch=""
    local repo_path=""
    
    # We leverage extract_org_repo which already handles *.github.io specifically
    extract_org_repo "$url"

    if [[ "$is_pages_site" != "true" || -z "$orgname" || -z "$repo_domain" ]]; then
        echo "Error: Not a known .github.io or .gitlab.io domain or repo could not be parsed."
        exit 1
    fi

    local repo_url="https://${repo_domain}/${orgname}/${reponame}"
    local path_url="$repo_url"
    
    if [[ -n "$repo_path" ]]; then
        path_url="${repo_url}/tree/${repo_branch}/${repo_path}"
    fi

    echo "Repo URL: $repo_url"
    echo "Path URL: $path_url"
}

test_git_clone_pages() {
    echo "Running git_clone_pages tests..."
    
    assert_eq() {
        local actual="$1"
        local expected="$2"
        local msg="$3"
        if [[ "$expected" != "$actual" ]]; then
            echo "FAIL: $msg. Expected '$expected', got '$actual'"
            exit 1
        fi
    }

    local old_user_agent="${USER_AGENT:-}"
    USER_AGENT="git-clone-utils-tests/1.0"

    local output
    output=$(git_clone_pages_main "https://github.github.io/linguist/subpath")
    if [[ "$output" != *"Path URL: https://github.com/github/linguist/tree/main/subpath"* ]]; then
        echo "FAIL: Result did not contain expected Github Path URL. Output: $output"
        exit 1
    fi

    output=$(git_clone_pages_main "https://gitlab-org.gitlab.io/gitlab-docs/subpath")
    if [[ "$output" != *"Path URL: https://gitlab.com/gitlab-org/gitlab-docs/tree/master/subpath"* && "$output" != *"Path URL: https://gitlab.com/gitlab-org/gitlab-docs/tree/main/subpath"* ]]; then
        echo "FAIL: Result did not contain expected GitLab Path URL. Output: $output"
        exit 1
    fi

    USER_AGENT="$old_user_agent"
    echo "All git_clone_pages tests passed!"
}

if [[ "${RUN_TESTS_GIT_CLONE_PAGES:-}" == "true" ]]; then
    test_git_clone_pages
elif [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    git_clone_pages_main "$@"
fi
