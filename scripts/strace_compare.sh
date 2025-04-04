#!/bin/sh

function strace_compare {
    ##   strace_compare() -- compare output of straces, after stripping hex addrs
    cmd1="$1"
    cmd2="$2"
    sed_strip_hexaddrs='s/0x[0-9a-f]\{12\}//g'

    if [ -n "$STRIP_HEXADDRS" ]; then
        git diff --word-diff \
            <(${cmd1} 2>&1 | sed "$sed_strip_hexaddrs") \
            <(${cmd2} 2>&1 | sed "$sed_strip_hexaddrs")
    else
        git diff --word-diff \
            <(${cmd1} 2>&1) \
            <(${cmd2} 2>&1)
    fi
}

function test_strace_compare_01 {
    cmd1='strace -e trace=file python -c "import math"'
    #cmd2="strace -e trace=file python -c "import cmath"'
    cmd2='strace -e trace=file python -c "import thiss"'

    strace_compare "$cmd1" "$cmd2"
    retcode=$?
    test $retcode -eq 0
}

function _strace_compare_test_main {
    (set -x;
    test_strace_compare_01;
    )
}

_THIS=$(basename "$0")
function _strace_compare_print_usage {
    echo "${_THIS} [-h] <cmd1> <cmd2>"
    echo ""
}

function _main {
    for arg in "${@}"; do
        case "$arg" in
            -h|--help)
                shift
                _strace_compare_print_usage
                return
                ;;
            -v|--verbose)
                shift
                set -x
                ;;
            --strip-hex-12)
                shift
                export STRIP_HEXADDRS=1
                ;;
            --test)
                shift
                _strace_compare_test_main
                ;;
        esac
    done
    strace_compare "${@}"
}

_main "${@}"
