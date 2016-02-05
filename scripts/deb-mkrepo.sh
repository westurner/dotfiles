#!/bin/sh
## deb-mkrepo.sh

function deb_mkrepo () {
    (set -x; _deb_mkrepo ${@}; return)
    return
}

function _deb_mkrepo () {
    # deb_mkrepo()      -- create dpkg Packages.gz and Sources.gz from dir ${1}
    REPODIR=${1:-"/var/www/nginx-default/_repodir_"}
    cd $REPODIR
    dpkg-scanpackages . /dev/null | gzip -9c > $REPODIR/Packages.gz
    dpkg-scansources . /dev/null | gzip -9c > $REPODIR/Sources.gz
    return
}


if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    deb_mkrepo ${@}
    exit
fi
