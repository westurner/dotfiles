#!/bin/sh
## deb-checksums.sh

function deb_checksums() {
    (set -x; cd /; _deb_checksums ${@}; return)
    return
}

function _deb_checksums() {
    # deb_checksums()     -- check dpkg md5 checksums with md5sums
    #checks filesystem against dpkg's md5sums 
    #Author: Filippo Giunchedi <filippo@esaurito.net>
    #Version: 0.1
    #this file is public domain 

    exclude="usr/share/locale/"
    include="bin/"

    for f in /var/lib/dpkg/info/*.md5sums; do
        package=$( basename "$f" | cut -d. -f1 )
        tmpfile=$( mktemp /tmp/dpkgcheck.XXXXXX )
        egrep "$include" "$f" | egrep -v "$exclude" > $tmpfile
        if [ -z "$(head $tmpfile)" ]; then continue; fi
        md5sum -c "$tmpfile"
        if [ $? -gt 0 ]; then
            echo "md5sum for $package has failed!"
            rm "$tmpfile"
            break
        fi
        rm "$tmpfile"
    done
    return
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    deb_checksums ${@}
    exit
fi
