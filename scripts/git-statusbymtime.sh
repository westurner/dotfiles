#!/bin/sh


__THISFILE="${0}"

PYLINE_SORT_FLAG="-s"

git_statusbymtime() {
    git -C "${GIT_REPO_PATH:-"."}" status -s \
        | pyline.py -m "os" '[
            [(getattr(os.stat(p), "st_mtime") if p and os.path.exists(p) else None), gitstatus, p]
            for p, gitstatus in [(l[3:].rstrip(), l[:2])]
        ][0]' ${PYLINE_SORT_FLAG} '0' -O tsv \
            | pyline.py -m datetime --input-delim=$'\t' --max-split=1 "${@}" 'w[1:] + [datetime.datetime.fromtimestamp(float(w[0])).isoformat(" ", "seconds") if w[0] else None]'
}

print_usage() {
    echo "${__THISFILE} [-C <path>] [args [for [pyline]]]"
    echo ""
    echo "Usage:"
    echo "${__THISFILE} --help  # print pyline help"
    echo "${__THISFILE} -O tsv"
    echo "${__THISFILE} -O csv"
    echo "${__THISFILE} -O json"
}

main() {
    for arg in "${@}"; do
        case "${arg}" in
            -C)
                shift;
                export GIT_REPO_PATH="${1}"
                shift;
                ;;
            -R)
                export PYLINE_SORT_FLAG="-S"
                shift
                ;;
            -h)
                shift;
                print_usage;
                return;
                ;;
        esac
    done
    (set +xv; git_statusbymtime "${@}")
    return
}


main "${@}"
