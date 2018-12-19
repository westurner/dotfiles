#!/bin/sh

# emulate something like ps
# Usage:
#    ps.sh
#    PS_CGROUPS=1 PS_ENVIRON=1 ps.sh

function ps_sh {
    for file in $(ls /proc/*/cmdline); do
        n=$(basename "$(dirname "$file")");
        echo "# $n";
        cat "/proc/${n}/cmdline" | tr '\0' ' ';
        echo -e "\n---";
        if [ -n "${PS_CGROUPS}" ]; then
            (set -x; cat "/proc/${n}/cgroup");
        fi
        if [ -n "${PS_ENVIRON}" ]; then
            (set -x; cat "/proc/${n}/environ" | tr '\0' '\n');
            echo ''
        fi
    done
}

function main {
    (ps_sh "${@}")
}

main
