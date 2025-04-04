#!/bin/sh

usrlog_sh="usrlog.sh"

test_usrlog_001() {
    source "${usrlog_sh}"
}

test_usrlog_tail_001() {
    usrlog_tail
    usrlog_tail "${_USRLOG}"
    ut
    ut "${_USRLOG}"
}


_test_main() {
    test_usrlog_001
    test_usrlog_tail_001
}

test_main() {
    (set -ex; _test_main "${@}")
}

test_main # "${@}"




