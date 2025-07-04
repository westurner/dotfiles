#!/bin/sh

set -e -x -v

test -n "" || true
test -z "" && true

test -n "0" && true
test -z "0" && true

(set +x; echo 'Both `test -z 0` and `test -z "0"` return true.')
test -z "0" && true
test -z $((0)) && true

(set +x; echo 'But the string "0" is not empty, which is what `test ! -n` checks.')

test ! -n "0" || true
test ! -n "" && true

(set +x; echo "But shellcheck doesn't like it: 'Use -z instead of ! -n' shellcheck SC2236'")
if [ ! -n "${var}" ]; then
    echo "var is empty"
fi

var=0
if [ ! -n "${var}" ]; then
    echo "var is empty"
fi

echo "Done."