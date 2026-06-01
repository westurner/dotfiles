#!/bin/sh

# git-list-files-in.sh

listfilesinrev() {
    local rev=$1;
    if ! test -n "$rev"; then
        echo "ERROR: you must specify a rev";
        return 2;
    fi;

    #git show "$rev" | pyline "(l[0:3] in ['+++','---']) and l"

    git show --name-only --oneline --pretty="format:" "$rev"
}

listfilesinrev_main() {

    listfilesinrev "${@}"
}

listfilesinrev_main "${@}"
