#!/bin/bash
# print bashmarks in nerdtree format

bashmarks_to_nerdtree() {
    (set -x; _bashmarks_to_nerdtree $@)
}

_bashmarks_to_nerdtree() {
    bookmarks="${1}"
    PYLINE=$(which pyline)
    PYLINE=${PYLINE:-"${__DOTFILES}/scripts/pyline.py"}
    l
    export | grep 'DIR_' | \
        $PYLINE '" ".join(line.split(None, 2)[-1].lstrip("DIR_").rstrip().replace("\"","").split("=",1))' \
        | (test -n "${bookmarks}" && tee "${bookmarks}" || cat)
}

bashmarks_to_nerdtree ${1:-${_NERDTREEBOOKMARKS:-"${HOME}/.NERDTreeBookmarks"}}
