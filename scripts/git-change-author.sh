#!/usr/bin/env bash

function git_change_author {
    FROM_EMAIL="${1:-${FROM_EMAIL:-"email@example.org"}}"
    FROM_NAME="${2:-${FROM_NAME:-"User Name"}}"
    TO_EMAIL="${3:-${GIT_AUTHOR_EMAIL}}"
    TO_NAME="${4:-${GIT_AUTHOR_NAME}}"
    shift; shift; shift; shift
    test -n "${FROM_EMAIL}" || (echo '$1 - FROM_EMAIL - email@example.org' && return 2)
    test -n "${FROM_NAME}" || (echo '$2 - FROM_NAME - "User Name"' && return 3)
    test -n "${TO_EMAIL}" || (echo '$3 - TO_EMAIL - ${GIT_AUTHOR_EMAIL}' && return 4)
    test -n "${TO_NAME}" || (echo '$4 - TO_NAME - ${GIT_AUTHOR_NAME}' && return 5)
    git filter-branch --commit-filter "
            if [ \"\$GIT_AUTHOR_EMAIL\" = '${FROM_EMAIL}' ] \
                || [ \"\$GIT_AUTHOR_NAME\" = '${FROM_NAME}' ];
            then
                    GIT_AUTHOR_NAME='${TO_NAME}';
                    GIT_AUTHOR_EMAIL='${TO_EMAIL}';
                    git commit-tree "\$@";
            else
                    git commit-tree "\$@";
            fi" "${@}" HEAD
            # 1ebcf80
            # HEAD
}

function main {
    (set -v -e -x; git_change_author "${@}")
}

if [[ "${BASH_SOURCE}" == "${0}" ]]; then
    main "${@}"
fi
