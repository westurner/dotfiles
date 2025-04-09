#!/bin/sh

trap 'echo ERROR: NOPIPE!' PIPE
echo "#######################" >&2
echo "HERE=${@}" >&2
exit
(set -x; exec cat "${1}")
