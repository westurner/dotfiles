#!/bin/bash

function du-xa {
    #  Sort files by size
    local logfile="${1:-"${HOME}/du-xa.log"}"
    local basedir="${2:-"$(pwd)"}"
    (cd /;
        du --one-file-system --all --total \
            --time --time-style=long-iso \
            --exclude="/usr/share/texlive/texmf*" \
            --threshold=0 \
            > "${logfile}")
    local logfile_sorted="${logfile}.sorted.size:desc.log"
    sort -r -n "${logfile}" > "${logfile_sorted}"
}

time (du-xa "${@}")
