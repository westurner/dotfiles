#!/usr/bin/env bash 

# hg-git workaround
# lookup corresponding .hg rev ids for hg-git mapped revs
# output suitable for .hgtags or .hg/localtags

# usage:
usage() {
    echo "$0: hg-git tags"
    echo ""
    echo "usage: $0 <path>"
    echo "ex: $0 . >> ./.hg/localtags"
}

if [ "$1" == "-h" ]; then
    usage
    exit 0
fi

repo=$1

if [ -d "${repo}/.hg/git" ]; then
    repodir="${repo}/.hg/git"
elif [ -d "${repo}/.git" ]; then
    repodir="${repo}/.git"
else
    echo "Repository "${repo}" not specified or not found"
    exit -1
fi

gittags="${repodir}/refs/tags"

for f in `ls "${gittags}"`; do
    githsh=`cat ${gittags}/${f}`;
    hghsh=`grep ${githsh} ${repo}/.hg/git-mapfile | cut -f2 -d' '`;
    echo ${hghsh} ${f};
done
