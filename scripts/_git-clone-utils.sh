#!/usr/bin/env bash

# _git-clone-utils.sh
# Shared utilities for git clones and config manipulation.
# 
# Testing:
#   Set RUN_TESTS_GIT_CLONE_UTILS="true" before sourcing to run built-in tests.

# Shared globals
LOGLEVEL="info"
SWITCH_TO="upstream"
USERNAME=""
REPO_URL=""
USER_AGENT="git-clone-utils/1.0"
GIT_ARGS=()
COLOR="auto"

_has_color() {
    if [[ "$COLOR" == "yes" || "$COLOR" == "y" || "$COLOR" == "always" ]]; then
        return 0
    elif [[ "$COLOR" == "no" || "$COLOR" == "n" || "$COLOR" == "never" ]]; then
        return 1
    elif [[ "$COLOR" == "auto" ]]; then
        if [[ -t 1 ]]; then
            return 0
        else
            return 1
        fi
    fi
    return 1
}

setup_colors() {
    if _has_color; then
        export C_RESET=$'\e[0m'
        export C_RED=$'\e[31m'
        export C_GREEN=$'\e[32m'
        export C_YELLOW=$'\e[33m'
        export C_BLUE=$'\e[34m'
        export C_MAGENTA=$'\e[35m'
        export C_CYAN=$'\e[36m'
        export C_GRAY=$'\e[90m'
        export PS4=$'\e[35m+ \e[30m${BASH_SOURCE[0]}:${LINENO}:\e[0m '
    else
        export C_RESET=""
        export C_RED=""
        export C_GREEN=""
        export C_YELLOW=""
        export C_BLUE=""
        export C_MAGENTA=""
        export C_CYAN=""
        export C_GRAY=""
        export PS4='+ ${BASH_SOURCE[0]}:${LINENO}: '
    fi
}

log_debug() {
    if [[ "$LOGLEVEL" == "debug" ]]; then
        setup_colors
        echo -e "${C_GRAY}[DEBUG]${C_RESET} $*"
    fi
}

log_info() {
    if [[ "$LOGLEVEL" == "info" || "$LOGLEVEL" == "debug" ]]; then
        setup_colors
        echo -e "${C_BLUE}[INFO]${C_RESET} $*"
    fi
}

log_warn() {
    if [[ "$LOGLEVEL" != "quiet" && "$LOGLEVEL" != "error" ]]; then
        setup_colors
        echo -e "${C_YELLOW}[WARN]${C_RESET} $*"
    fi
}

log_error() {
    if [[ "$LOGLEVEL" != "quiet" ]]; then
        setup_colors
        echo -e "${C_RED}[ERROR]${C_RESET} $*" >&2
    fi
}

log() {
    # Default log fallback
    if [[ "$LOGLEVEL" != "quiet" ]]; then
        echo "$@"
    fi
}

print_commands() {
    if [[ "$LOGLEVEL" == "quiet" ]]; then
        return
    fi

    local branch
    branch=$(git branch --show-current 2>/dev/null || echo "")
    if [[ -z "$branch" ]]; then
        branch="main"
    fi
    
    local behind_msg=""
    if git rev-parse --verify "upstream/$branch" >/dev/null 2>&1 && git rev-parse --verify "origin/$branch" >/dev/null 2>&1; then
        local behind_count
        behind_count=$(git rev-list --count "origin/$branch..upstream/$branch" 2>/dev/null || echo "0")
        if [[ "$behind_count" -gt 0 ]]; then
            behind_msg="⚠️  NOTICE: Your origin/$branch is behind upstream/$branch by $behind_count commit(s).\nTo update your local branch and origin, run:\n  git checkout $branch && git pull upstream $branch && git push origin $branch"
        fi
    fi

    log "========================================="
    if [[ -n "$behind_msg" ]]; then
        if _has_color; then
            printf "${C_YELLOW}%b${C_RESET}\n" "$behind_msg"
        else
            printf "%b\n" "$behind_msg"
        fi
        log "-----------------------------------------"
    fi
    log "Helpful commands for your workflow:"
    log "========================================="
    log "Commit or stash and switch:"
    log "  git commit -am 'message' && git checkout other-branch"
    log "  git stash && git checkout other-branch && git stash pop"
    log ""
    log "Diff between same branch on different remote:"
    log "  git diff upstream/$branch...origin/$branch"
    log ""
    log "Fetch, Pull, Push, Cherry-pick:"
    log "  git fetch upstream"
    log "  git pull upstream $branch"
    log "  git push origin $branch"
    log "  git cherry-pick upstream/$branch"
    log "========================================="
}

extract_org_repo() {
    local url="$1"

    is_pages_site="false"
    repo_branch="main"
    repo_path=""
    
    # Handle *.github.io and *.gitlab.io URLs
    if [[ "$url" == *".github.io"* || "$url" == *".gitlab.io"* ]]; then
        is_pages_site="true"
        local url_no_proto="${url#*://}"
        local hostname="${url_no_proto%%/*}"
        local pathname="${url_no_proto#*/}"
        
        [[ "$hostname" == "$pathname" ]] && pathname=""
        
        if [[ "$hostname" == *".github.io"* ]]; then
            repotype="github"
            repo_domain="github.com"
        else
            repotype="gitlab"
            repo_domain="gitlab.com"
        fi
        
        orgname="${hostname%%.*}"
        
        # Clean pathname
        pathname="${pathname#/}"
        pathname="${pathname%/}"
        
        local possible_repo="${pathname%%/*}"
        local possible_subpath="${pathname#*/}"
        [[ "$possible_repo" == "$pathname" ]] && possible_subpath=""
        
        # Use curl to check if the possible repository exists (differentiating user pages vs project pages)
        local status_code="404"
        if [[ -z "$USER_AGENT" ]]; then
            echo "Error: USER_AGENT must be set."
            exit 1
        fi
    
        if [[ -n "$possible_repo" ]]; then
            status_code=$(curl -L -A "$USER_AGENT" -I -s -w "%{http_code}" -o /dev/null "https://${repo_domain}/${orgname}/${possible_repo}")
        fi

        if [[ "$status_code" != "200" && -n "$possible_repo" ]]; then
            if [[ "$repotype" == "github" ]]; then
                status_code=$(curl -L -A "$USER_AGENT" -s -w "%{http_code}" -o /dev/null "https://api.github.com/repos/${orgname}/${possible_repo}")
            elif [[ "$repotype" == "gitlab" ]]; then
                status_code=$(curl -L -A "$USER_AGENT" -s -w "%{http_code}" -o /dev/null "https://gitlab.com/api/v4/projects/${orgname}%2F${possible_repo}")
            fi
        fi

        if [[ "$status_code" == "200" ]]; then
            reponame="$possible_repo"
            repo_path="$possible_subpath"
        else
            reponame="$hostname"
            repo_path="$pathname"
        fi

        # Get default branch using curl
        local api_branch=""
        
        # Check first with HEAD request on default branch names
        local head_main="404"
        local head_master="404"
        
        if [[ "$repotype" == "github" ]]; then
            head_main=$(curl -L -A "$USER_AGENT" -I -s -w "%{http_code}" -o /dev/null "https://${repo_domain}/${orgname}/${reponame}/tree/main")
            if [[ "$head_main" == "200" ]]; then
                api_branch="main"
            else
                head_master=$(curl -L -A "$USER_AGENT" -I -s -w "%{http_code}" -o /dev/null "https://${repo_domain}/${orgname}/${reponame}/tree/master")
                if [[ "$head_master" == "200" ]]; then
                    api_branch="master"
                fi
            fi
        elif [[ "$repotype" == "gitlab" ]]; then
            head_main=$(curl -L -A "$USER_AGENT" -I -s -w "%{http_code}" -o /dev/null "https://${repo_domain}/${orgname}/${reponame}/-/tree/main")
            if [[ "$head_main" == "200" ]]; then
                api_branch="main"
            else
                head_master=$(curl -L -A "$USER_AGENT" -I -s -w "%{http_code}" -o /dev/null "https://${repo_domain}/${orgname}/${reponame}/-/tree/master")
                if [[ "$head_master" == "200" ]]; then
                    api_branch="master"
                fi
            fi
        fi

        # Fallback to API request if HEAD requests failed
        if [[ -z "$api_branch" ]]; then
            if [[ "$repotype" == "github" ]]; then
                api_branch=$(curl -L -A "$USER_AGENT" -s "https://api.github.com/repos/${orgname}/${reponame}" | grep -m1 '"default_branch":' | cut -d'"' -f4)
            elif [[ "$repotype" == "gitlab" ]]; then
                api_branch=$(curl -L -A "$USER_AGENT" -s "https://gitlab.com/api/v4/projects/${orgname}%2F${reponame}" | grep -m1 '"default_branch":' | cut -d'"' -f4)
            fi
        fi

        
        # fallback if API response fails due to limits / parsing mismatch and yields something like 'node_id' or junk
        if [[ -n "$api_branch" && "$api_branch" != "node_id" && "$api_branch" != "id" && "$api_branch" != "description" && "$api_branch" != "message" ]]; then
            repo_branch="$api_branch"
        fi

        return
    fi

    local repo_string="$url"

    case "$url" in
        *gitlab.com*)
            repotype="gitlab"
            repo_domain="gitlab.com"
            ;;
        *bitbucket.org*)
            repotype="bitbucket"
            repo_domain="bitbucket.org"
            ;;
        *github.com*)
            repotype="github"
            repo_domain="github.com"
            ;;
        *)
            repotype="github"
            repo_domain="github.com"
            ;;
    esac

    repo_string="${repo_string#*${repo_domain}/}"
    repo_string="${repo_string#*${repo_domain}:}"
    repo_string="${repo_string%.git}"
    
    orgname="${repo_string%%/*}"
    reponame="${repo_string##*/}"
}

parse_common_args() {
    local POS_ARGS=()
    for arg in "$@"; do
        case "$arg" in
            -v|--verbose)
                LOGLEVEL="debug"
                set -x
                ;;
            -q|--quiet)
                LOGLEVEL="quiet"
                ;;
            --loglevel=*)
                LOGLEVEL="${arg#*=}"
                ;;
            --switch-to=*)
                SWITCH_TO="${arg#*=}"
                ;;
            --no-switch-to)
                SWITCH_TO="none"
                ;;
            -u=*|--username=*)
                USERNAME="${arg#*=}"
                ;;
            --user-agent=*)
                USER_AGENT="${arg#*=}"
                ;;
            --color=*)
                COLOR="${arg#*=}"
                ;;
            -*)
                # Pass all other unhandled flags (e.g. --jobs=4, --bare, etc.) through to git
                GIT_ARGS+=("$arg")
                ;;
            *)
                POS_ARGS+=("$arg")
                ;;
        esac
    done
    
    setup_colors
    
    if [ -z "$USERNAME" ]; then
        USERNAME=$(git config user.username || echo "$USER")
    fi

    # Pass remaining args back
    PARSED_POS_ARGS=("${POS_ARGS[@]}")
}

test_extract_org_repo() {
    echo "Running extract_org_repo tests..."
    
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

    # Test 1: Standard GitHub HTTPS
    extract_org_repo "https://github.com/torvalds/linux.git"
    assert_eq "$repotype" "github" "HTTPS GitHub repotype"
    assert_eq "$orgname" "torvalds" "HTTPS GitHub orgname"
    assert_eq "$reponame" "linux" "HTTPS GitHub reponame"
    
    # Test 2: Standard GitLab SSH
    extract_org_repo "git@gitlab.com:inkscape/inkscape.git"
    assert_eq "$repotype" "gitlab" "SSH GitLab repotype"
    assert_eq "$orgname" "inkscape" "SSH GitLab orgname"
    assert_eq "$reponame" "inkscape" "SSH GitLab reponame"

    # Test 3: Bitbucket URL
    extract_org_repo "https://bitbucket.org/atlassian/example"
    assert_eq "$repotype" "bitbucket" "Bitbucket repotype"
    assert_eq "$orgname" "atlassian" "Bitbucket orgname"
    assert_eq "$reponame" "example" "Bitbucket reponame"

    # Test 4: GitHub Pages URL
    # Notice: This relies on network access to api.github.com
    extract_org_repo "https://github.github.io/linguist/subpath"
    assert_eq "$repotype" "github" "Pages repotype"
    assert_eq "$orgname" "github" "Pages orgname"
    assert_eq "$reponame" "linguist" "Pages reponame"
    assert_eq "$repo_path" "subpath" "Pages repo_path"

    # Test 5: GitLab Pages URL
    # Notice: This relies on network access to gitlab.com/api/v4
    extract_org_repo "https://gitlab-org.gitlab.io/gitlab-docs/subpath"
    assert_eq "$repotype" "gitlab" "GitLab Pages repotype"
    assert_eq "$orgname" "gitlab-org" "GitLab Pages orgname"
    assert_eq "$reponame" "gitlab-docs" "GitLab Pages reponame"
    assert_eq "$repo_path" "subpath" "GitLab Pages repo_path"

    # Test 6: westurner dotfiles repository
    extract_org_repo "https://westurner.github.io/dotfiles/"
    assert_eq "$repotype" "github" "westurner pages repotype"
    assert_eq "$orgname" "westurner" "westurner pages orgname"
    assert_eq "$reponame" "dotfiles" "westurner pages reponame"
    assert_eq "$repo_path" "" "westurner pages repo_path"

    # Test 7: No internet access simulation
    # We mock curl to just exit with non-zero or return 404/empty
    with_offline_curl() {
        trap 'unset -f curl' RETURN
        curl() {
            if [[ "$*" == *"-I -s -w %{http_code}"* ]]; then
                echo "000"
            else
                echo ""
            fi
            return 1
        }
        "$@"
    }

    with_offline_curl extract_org_repo "https://offline.github.io/someproject/path"
    assert_eq "$repotype" "github" "Offline repotype"
    assert_eq "$orgname" "offline" "Offline orgname"
    assert_eq "$reponame" "offline.github.io" "Offline reponame fallback"
    assert_eq "$repo_branch" "main" "Offline branch fallback"

    USER_AGENT="$old_user_agent"
    echo "All extract_org_repo tests passed!"
}

test_parse_common_args() {
    echo "Running parse_common_args tests..."
    
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
    USER_AGENT="git-clone-utils-tests/1.0"
    PARSED_POS_ARGS=()

    # Test 1: positional args and flags
    parse_common_args "pos1" "--username=testuser" "pos2" "-q"
    assert_eq "$USERNAME" "testuser" "Username parsed"
    assert_eq "$LOGLEVEL" "quiet" "Quiet loglevel parsed"
    assert_eq "${#PARSED_POS_ARGS[@]}" "2" "Positional args count"
    assert_eq "${PARSED_POS_ARGS[0]}" "pos1" "Positional arg 1"
    assert_eq "${PARSED_POS_ARGS[1]}" "pos2" "Positional arg 2"

    # Test 2: loglevel and switch
    parse_common_args "--loglevel=warn" "--no-switch-to"
    assert_eq "$LOGLEVEL" "warn" "Loglevel parameter parsed"
    assert_eq "$SWITCH_TO" "none" "No switch to parsed"

    # Test 3: user agent and switch-to
    parse_common_args "--user-agent=test-agent/1" "--switch-to=origin"
    assert_eq "$USER_AGENT" "test-agent/1" "User agent parsed"
    assert_eq "$SWITCH_TO" "origin" "Switch-to parsed"
    
    echo "All parse_common_args tests passed!"
}

if [[ "${RUN_TESTS_GIT_CLONE_UTILS:-}" == "true" ]]; then
    test_extract_org_repo
    test_parse_common_args
fi
