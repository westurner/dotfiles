
### bashrc.commands.sh
# usage: bash -c 'source bashrc.commands.sh; funcname <args>'

chown-me () {
    # chown-me()        -- chown -Rv user
    (set -x; \
    chown -Rv $(id -un) $@ )
}

chown-me-mine () {
    # chown-me-mine()   -- chown -Rv user:user && chmod -Rv go-rwx
    (set -x; \
    chown -Rv $(id -un):$(id -un) $@ ; \
    chmod -Rv go-rwx $@ )
}

chown-sme () {
    # chown-sme()       -- sudo chown -Rv user
    (set -x; \
    sudo chown -Rv $(id -un) $@ )
}

chown-sme-mine () {
    # chown-sme-mine()  -- sudo chown -Rv user:user && chmod -Rv go-rwx
    (set -x; \
    sudo chown -Rv $(id -un):$(id -un) $@ ; \
    sudo chmod -Rv go-rwx $@ )
}

chmod-unumask () {
    # chmod-unumask()   -- recursively add other+r (files) and other+rx (dirs)
    path=$1
    sudo find "${path}" -type f -exec chmod -v o+r {} \;
    sudo find "${path}" -type d -exec chmod -v o+rx {} \;
}


new-sh () {
    # new-sh()          -- create and open a new shell script at $1
    file=$1
    if [ -e $1 ]; then
        echo "$1 exists"
    else
        touch $1
        echo "#!/bin/sh" >> $1
        echo "## " >> $1
        chmod 700 $1
        ${EDITOR_} +2 $1
    fi
}

diff-dirs () {
    # diff-dirs()       -- list differences between directories
    F1=$1
    F2=$2
    #FIND="find . -printf '%T@\t%s\t%u\t%Y\t%p\n'"
    diff -Naur \
        <(cd $F1; find . | sort ) \
        <(cd $F2; find . | sort )
}

diff-stdin () {
    # diff-stdin()      -- diff the output of two commands
    DIFFBIN='diff'
    $DIFFBIN -u <($1) <($2)
}

wopen () {
    # wopen()           -- open path/URI/URL $1 in a new browser tab
    #                      see: scripts/x-www-browser
    if [ -n "${__IS_MAC}" ]; then
        open $@
    elif [ -n "${__IS_LINUX}" ]; then
        x-www-browser $@
    else
        python -m webbrowser -t $@
    fi
}

find-largefiles () {
    # find-largefiles() -- find files larger than size (default: +10M)
    SIZE=${1:-"+10M"}
    find . -xdev -type f -size "${SIZE}" -exec ls -alh {} \;
}

find-pdf () {
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

find-lately () {
    # find-lately()     -- list and sort files in paths $@ by ISO8601 mtime
    #                      stderr > lately.$(date).errors
    #                      stdout > lately.$(date).files
    #                      stdout > lately.$(date).sorted
    #                      note: 
    set -x
    paths=${@:-"/"}
    lately="lately.$(date +'%FT%T%z')"
    find $paths -exec \
        stat -f '%Sc%t%N%t%z%t%Su%t%Sg%t%Sp%t%T' -t '%F %T%z' {} \; \
        2> ${lately}.errors \
        > ${lately}.files
    sort ${lately} > ${lately}.sorted
    set +x
}

find-setuid () {
    # find-setuid()     -- find all setuid and setgid files
    #                      stderr > find-setuid.errors
    #                      stdout > find-setuid.files
    sudo \
        find /  -type f \( -perm -4000 -o -perm -2000 \) -exec ls -ld '{}' \; \
        2> find-setuid.errors \
        > find-setuid.files
}

find-startup () {
    # find-startup()    -- find common startup files in common locations
    cmd=${@:-"ls"}
    paths='/etc/rc?.d /etc/init.d /etc/init /etc/xdg/autostart /etc/dbus-1'
    paths="$paths ~/.config/autostart /usr/share/gnome/autostart"
    for p in $paths; do
        if [ -d $p ]; then
            find $p -type f | xargs $cmd
        fi
    done
}

find-ssl() {
    # find-ssl()        -- find .pem and .db files and print their metadata
    #apt-get install libnss3-tools
    _runcmd(){
        cmd="${1}"
        desc="${2}"
        echo "#######"
        echo "'${cmd}' : ${desc}"
        echo "#------"
        echo -e "$($cmd)"
        echo -e "\n#."
    }

    for cert in $(locate *.pem); do
        echo "-- $cert --"
        openssl x509 -in $cert -text
    done
    for d in $(locate '*.db' | egrep 'key[[:digit:]].db'); do  
        kpath=$(dirname $d) 
        _runcmd "certutil  -L -d sql:${kpath}"  "${kpath}"
    done
}

find-dpkgfile () {
    # find-dpkgfile()   -- search dpkgs with apt-file
    apt-file search $@
}

find-dpkgfiles () {
    # find-dpkgfiles()  -- sort dpkg /var/lib/dpkg/info/<name>.list
    cat /var/lib/dpkg/info/${1}.list | sort
}

deb-chksums () {
    # deb-chksums()     -- check dpkg md5 checksums with md5sums
    #checks filesystem against dpkg's md5sums 
    #Author: Filippo Giunchedi <filippo@esaurito.net>
    #Version: 0.1
    #this file is public domain 

    exclude="usr/share/locale/"
    include="bin/"

    pushd .
    cd /

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

    popd
}

deb-mkrepo () {
    # deb-mkrepo()      -- create dpkg Packages.gz and Sources.gz from dir ${1}
    REPODIR=${1:-"/var/www/nginx-default/"}
    cd $REPODIR
    dpkg-scanpackages . /dev/null | gzip -9c > $REPODIR/Packages.gz
    dpkg-scansources . /dev/null | gzip -9c > $REPODIR/Sources.gz
}

mnt-chroot-bind () {
    # mnt-chroot-bind() -- bind mount linux chroot directories
    DEST=$1
    sudo mount proc -t proc ${DEST}/proc
    sudo mount -o bind /dev ${DEST}/dev
    sudo mount sysfs -t sysfs ${DEST}/sys
    sudo mount -o bind,ro /boot {DEST}/boot
}
mnt-cifs () {
    # mnt-cifs()        -- mount a CIFS mount
    URI="$1" # //host/share
    MNTPT="$2"
    OPTIONS="-o user=$3,password=$4"
    mount -t cifs $OPTIONS $URI $MNTPT
}
mnt-davfs () {
    # mnt-davfs()       -- mount a WebDAV mount
    URL="$1"
    MNTPT="$2"
    OPTIONS="-o rw,user,noauto"
    mount -t davfs $OPTIONS $URL $MNTPT
}

lsof-sh () {
    # lsof-sh()         -- something like lsof
    processes=$(find /proc -regextype egrep -maxdepth 1 -type d -readable -regex '.*[[:digit:]]+')
    for p in $processes; do
        cmdline=$(cat $p/cmdline)
        cmd=$(echo $cmdline | sed 's/\(.*\)\s.*/\1/g' | sed 's/\//\\\//g')
        pid=$(echo $p | sed 's/\/proc\/\([0-9]*\)/\1/')
        echo $pid $cmdline 
        #maps=$(cat $p/maps )
        sed_pattern="s/\(.*\)/$pid \1\t$cmd/g"
        cat $p/maps | sed "$sed_pattern"
    done
    #~ lsof_ | grep 'fb' | pycut -f 6,5,0,2,1,7 -O '%s' | sort -n 
}


lsof-net () {
    # lsof-net()        -- lsof the network things
    ARGS=${@:-''}
    for pid in `lsof -n -t -U -i4 2>/dev/null`; do
        echo "-----------";
        ps $pid;
        lsof -n -a $ARGS -p $pid 2>/dev/null;
    done
}


net-stat () {
    # net-stat()        -- print networking information
    echo "# net_stat:"  `date`
    echo "#####################################################"
    set -x
    sudo ip a 2>&1
    sudo ip r 2>&1
    sudo ifconfig -a 2>&1
    sudo route -n 2>&1
    sudo iptables -L -n 2>&1
    sudo netstat -ntaup 2>&1 | sort -n
    set +x
}


ssh-prx () {
    # ssh-prx()         -- SSH SOCKS
    RUSERHOST=$1
    RPORT=$2

    LOCADDR=${3:-"10.10.10.10"}
    PRXADDR="$LOCADDR:1080"
    sudo ip addr add $LOCADDR dev lo netmask 255.255.255.0
    ssh -ND $PRXADDR $RUSERHOST -p $RPORT

    echo "$PRXADDR"
}

strace- () {
    # strace-()         -- strace with helpful options
    strace -ttt -f -F $@ 2>&1
}

strace-f () {
    # strace-f()        -- strace -e trace=file + helpful options
    strace_ -e trace=file $@
}

strace-f-noeno () {
    # strace-f-noeno()  -- strace -e trace=file | grep -v ENOENT
    strace_ -e trace=file $@ 2>&1 \
        | grep -v '-1 ENOENT (No such file or directory)$' 
}

hgst() {
    # hgst()            -- hg diff --stat, hg status, hg diff
    repo=${1:-"$(pwd)"}
    shift

    hgopts="-R ${repo} --pager=no"

    if [ -n "$(echo "$@" | grep "color")" ]; then
        hgopts="${hgopts} --color=always"
    fi
    echo "###"
    echo "## ${repo}"
    echo '###'
    hg ${hgopts} diff --stat | sed 's/^/## /'
    echo '###'
    hg ${hgopts} status | sed 's/^/## /'
    echo '###'
    hg ${hgopts} diff
    echo '###'
}


