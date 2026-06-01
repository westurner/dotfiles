#!/bin/bash

# Conditionally enable debug mode
[ "${DEBUG:-0}" = "1" ] && set -x

is_rpm_ostree_system() {
    command -v rpm-ostree >/dev/null 2>&1 || return 1
    rpm-ostree status >/dev/null 2>&1
}

# On rpm-ostree systems, default to python dnf backend unless user overrides DNFPY.
if is_rpm_ostree_system && [ -z "${DNFPY+x}" ]; then
    DNFPY=1
fi

if [ -n "$DNFPY" ]; then
    dnf_() {
        /usr/bin/python3 -m dnf.cli.main "${@}"
    }
else
    dnf_() {
        dnf "${@}"
    }
fi

if [ "$1" = "search" ]; then
    # Re-sets $@ to: $1, "-C", and everything from $2 onwards
    set -- "$1" "-C" "${@:2}"
elif [ "$1" = "search_" ]; then
    set -- "search" "${@:1}"
fi

# Generate offline setopt flags dynamically from dnf config
make_offline_flags() {
    # Ensure -C (cacheonly) works for non-root users by explicitly pointing to their cachedir.
    # Otherwise, DNF tries to read/write the system /var/cache/dnf and fails with Permission Denied.
    if [ "${EUID:-$(id -u)}" -ne 0 ]; then
        local user_cachedir=""
        if command -v python3 >/dev/null 2>&1; then
            user_cachedir=$(python3 -c "import dnf; print(dnf.Base().conf.cachedir)" 2>/dev/null)
        fi
        if [ -z "$user_cachedir" ]; then
            user_cachedir=$(ls -td /var/tmp/dnf-"${USER:-$(whoami)}"-* 2>/dev/null | head -n1)
        fi
        if [ -n "$user_cachedir" ]; then
            mkdir -p "${user_cachedir}/persist" 2>/dev/null || true
            echo "--setopt=cachedir=$user_cachedir"
            echo "--setopt=persistdir=${user_cachedir}/persist"
        fi
    fi

    # Get list of enabled repos from dnf, extract only repo IDs (skip header and description columns)
    local repos
    repos=$(dnf_ repolist --enabled -q 2>/dev/null | awk 'NR>1 {print $1}')
    if [ -n "$repos" ]; then
        # Add base metadata_expire flag
        echo "--setopt=metadata_expire=-1"
        # Add per-repo metadata_expire flags
        while IFS= read -r repo; do
            [ -z "$repo" ] && continue
            echo "--setopt=${repo}.metadata_expire=-1"
        done <<< "$repos"
    else
        # Fallback to hardcoded list if dnf repolist fails
        local fallback_repos=("" "fedora" "fedora-update" "rpmfusion-free" "rpmfusion-nonfree")
        for repo in "${fallback_repos[@]}"; do
            if [ -z "$repo" ]; then
                echo "--setopt=metadata_expire=-1"
            else
                echo "--setopt=${repo}.metadata_expire=-1"
            fi
        done
    fi
}

function dnfoffline {
    local -a flags
    mapfile -t flags < <(make_offline_flags) || return 1
    dnf_ "${flags[@]}" "${@}" || return $?
}

# ============================================================================
# Testing Infrastructure
# ============================================================================

declare -i TESTS_PASSED=0
declare -i TESTS_FAILED=0
declare -a FAILURES=()

# Assert function for testing
_assert() {
    local description="$1"
    local expected="$2"
    local actual="$3"
    
    if [ "$expected" = "$actual" ]; then
        ((TESTS_PASSED++))
        printf "[PASS] %s\n" "$description"
    else
        ((TESTS_FAILED++))
        printf "[FAIL] %s\n" "$description"
        printf "  Expected: %s\n" "$expected"
        printf "  Actual:   %s\n" "$actual"
        FAILURES+=("$description")
    fi
}

# Test: make_offline_flags produces valid setopt flags
test_make_offline_flags() {
    local output
    output=$(make_offline_flags)
    
    # Should contain base metadata_expire flag
    if echo "$output" | grep -q "^--setopt=metadata_expire=-1$"; then
        _assert "make_offline_flags includes base metadata_expire" "true" "true"
    else
        _assert "make_offline_flags includes base metadata_expire" "true" "false"
    fi
    
    # Should contain only valid setopt format (no spaces in repo names)
    if echo "$output" | grep -v "^--setopt=[a-zA-Z0-9._-:]*\.metadata_expire=-1$" \
                      | grep -v "^--setopt=metadata_expire=-1$" \
                      | grep -v "^--setopt=cachedir=.*$" \
                      | grep -v "^--setopt=persistdir=.*$" \
                      | grep -q .; then
        _assert "make_offline_flags format validation" "valid" "invalid"
    else
        _assert "make_offline_flags format validation" "valid" "valid"
    fi
}

# Test: search argument handling
test_search_argument_handling() {
    # Source the argument handling logic in a subshell
    local result
    result=$(bash -c '
        if [ "$1" = "search" ]; then
            set -- "$1" "-C" "${@:2}"
        fi
        echo "$@"
    ' -- search test_arg)
    
    _assert "search argument adds -C flag" "search -C test_arg" "$result"
}

# Test: fallback repos list
test_fallback_repos() {
    # Simulate dnf_ failure in a subshell so fallback path is exercised safely
    local output
    output=$(
        dnf_() { return 1; }
        make_offline_flags 2>&1
    )
    
    # Should contain fallback repos
    if echo "$output" | grep -q "fedora"; then
        _assert "fallback repos includes fedora" "true" "true"
    else
        _assert "fallback repos includes fedora" "true" "false"
    fi
}

# Test: dynamic repos list is parsed correctly when repos are present
test_dynamic_repos_parsing() {
    local output
    output=$(
        dnf_() {
            cat <<'EOF'
repo id                                        repo name
fedora                                         Fedora 43 - x86_64
updates                                        Fedora 43 - x86_64 - Updates
EOF
        }
        make_offline_flags
    )

    if echo "$output" | grep -q "^--setopt=fedora.metadata_expire=-1$"; then
        _assert "dynamic repos includes fedora flag" "true" "true"
    else
        _assert "dynamic repos includes fedora flag" "true" "false"
    fi

    if echo "$output" | grep -q "^--setopt=updates.metadata_expire=-1$"; then
        _assert "dynamic repos includes updates flag" "true" "true"
    else
        _assert "dynamic repos includes updates flag" "true" "false"
    fi

    if echo "$output" | grep -q "Fedora 43"; then
        _assert "dynamic repos strips repo descriptions" "absent" "present"
    else
        _assert "dynamic repos strips repo descriptions" "absent" "absent"
    fi
}

# Run all tests and output BAT format
run_tests() {
    printf "=== DNF Offline Script Tests ===\n"
    printf "Running: %s\n\n" "$(date)"
    
    test_make_offline_flags
    test_search_argument_handling
    test_fallback_repos
    test_dynamic_repos_parsing
    
    printf "\n=== Test Results ===\n"
    printf "Passed: %d\n" "$TESTS_PASSED"
    printf "Failed: %d\n" "$TESTS_FAILED"
    
    if [ ${#FAILURES[@]} -gt 0 ]; then
        printf "\nFailed tests:\n"
        for failure in "${FAILURES[@]}"; do
            printf "  - %s\n" "$failure"
        done
        return 1
    fi
    
    return 0
}

# Main execution
if [ "$1" = "--test" ] || [ "$1" = "-t" ]; then
    run_tests
else
    dnfoffline "${@}"
fi
