#!/bin/sh
## find-pdf.sh (requires 'find -printf' and pdfinfo)

function find_pdf() {
    test -n "${__IS_MAC}" && echo "err: __IS_MAC != ''" && return -1
    (set -x; _find_pdf ${@}; return)
    return
}

function _find_pdf () {
    # find-pdf()        -- find pdfs and print info with pdfinfo
    SPATH='.'
    files=$(find "$SPATH" -type f -iname '*.pdf' -printf "%T+||%p\n" | sort -n)
    for f in $files; do
        echo '\n==============='$f;
        fname="$(echo "$f" | pycut -d'||' -f1)";
        echo "FNAME" $fname
        ls -l "$fname"
        pdfinfo "$fname" | egrep --color=none 'Title|Keywords|Author';
    done
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    find_pdf ${@}
    exit
fi
