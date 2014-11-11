
### bashrc.aliases.sh

## bash

#__THIS=$(readlink -e "$0")
#__THISDIR=$(dirname "${__THIS}")

echo_args() {
    #  echo_args    -- echo $@ (for checking quoting)
    echo $@
}

## file paths

realpath () {
    #  realpath()    -- print absolute path (os.path.realpath) to path $1
    #                  note: OSX does not have readlink -f
    python -c "import os,sys; print(os.path.realpath(os.path.expanduser(sys.argv[1])))" "${1}"
    return
}
path () {
    #  path()        -- realpath()
    realpath ${1}
}

lightpath() {
    #  lightpath()  -- display $PATH with newlines
    echo ''
    echo $PATH | tr ':' '\n'
}

lspath() {
    #  lspath()     -- list files in each directory in $PATH
    echo "# PATH=$PATH"
    lightpath | sed 's/\(.*\)/# \1/g'
    echo '#'
    cmd=${1:-'ls -ald'}
    for f in $(lightpath); do
        echo "# $f";
        ${cmd} $f/*;
        echo '#'
    done
}

lspath-less() {
    #  lspath_less()    -- lspath with less (color)
    if [ -n "${__IS_MAC}" ]; then
        cmd=${1:-'ls -ald -G'}
    else
        cmd=${1:-'ls -ald --color=always'}
    fi
    lspath "${cmd}" | less -R
}

_loadaliases () {
    #  _load_aliases()  -- load aliases
    alias chmodr='chmod -R'
    alias chownr='chown -R'

    alias grep='grep --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'

    alias grindp='grind --sys.path'
    alias grinp='grin --sys-path'

    alias fumnt='fusermount -u'

    alias ga='git add'
    alias gl='git log --pretty=format:"%h : %an : %s" --topo-order --graph'
    alias gs='git status'
    alias gd='git diff'
    alias gds='git diff -p --stat'
    alias gc='git commit'
    alias gco='git checkout'
    alias gdc='git diff --cached'
    alias gsl='git stash list'
    alias gsn='git stash save'
    alias gss='git stash save'
    alias gitr='git remote -v'

    alias hgl='hg glog --pager=yes'
    alias hgs='hg status'
    alias hgd='hg diff'
    alias hgds='hg diff --stat'
    alias hgdl='hg diff --color=always | less -R'
    alias hgc='hg commit'
    alias hgu='hg update'
    alias hgq='hg qseries'
    alias hgqd='hg qdiff'
    alias hgqs='hg qseries'
    alias hgqn='hg qnew'
    alias hgr='hg paths'

    if [ -n "${__IS_MAC}" ]; then
        alias la='ls -A -G'
        alias ll='ls -alF -G'
        alias ls='ls -G'
        alias lt='ls -altr -G'
    else
        alias la='ls -A --color=auto'
        alias ll='ls -alF --color=auto'
        alias ls='ls --color=auto'
        alias lt='ls -altr --color=auto'
    fi

    if [ -n "${__IS_LINUX}" ]; then
        alias psx='ps uxaw'
        alias psf='ps uxawf'
        alias psxs='ps uxawf --sort=tty,ppid,pid'
        alias psxh='ps uxawf --sort=tty,ppid,pid | head'

        alias psh='ps uxaw | head'

        alias psc='ps uxaw --sort=-pcpu'
        alias psch='ps uxaw --sort=-pcpu | head'

        alias psm='ps uxaw --sort=-pmem'
        alias psmh='ps uxaw --sort=-pmem | head'
    elif [ -n "${__IS_MAC}" ]; then
        alias psx='ps uxaw'
        alias psf='ps uxaw' # no -f

        alias psh='ps uxaw | head'

        alias psc='ps uxaw -c'
        alias psch='ps uxaw -c | head'

        alias psm='ps uxaw -m'
        alias psmh='ps uxaw -m | head'
    fi
    
    alias shtop='sudo htop'
    alias t='tail'
    alias tf='tail -f'
    alias xclipc='xclip -selection c'
}
_loadaliases


hgst() {
    ## hgst()   -- hg diff --stat, hg status, hg diff
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


chown-me () {
    (set -x; \
    chown -Rv $(id -un) $@ )
}

chown-me-mine () {
    (set -x; \
    chown -Rv $(id -un):$(id -un) $@ ; \
    chmod -Rv go-rwx $@ )
}

chown-sme () {
    (set -x; \
    sudo chown -Rv $(id -un) $@ )
}

chown-sme-mine () {
    (set -x; \
    sudo chown -Rv $(id -un):$(id -un) $@ ; \
    sudo chmod -Rv go-rwx $@ )
}

chmod-unumask () {
    #  chmod-unumask()  -- recursively add other+r (files) and other+rx (dirs)
    path=$1
    sudo find "${path}" -type f -exec chmod -v o+r {} \;
    sudo find "${path}" -type d -exec chmod -v o+rx {} \;
}


new-sh () {
    #  new-sh()         -- create and open a new shell script at $1
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
    #  diff-dirs()      -- list differences between directories
    F1=$1
    F2=$2

    #FIND="find . -printf '%T@\t%s\t%u\t%Y\t%p\n'"
    diff -Naur \
        <(cd $F1; find . | sort ) \
        <(cd $F2; find . | sort )
}

diff-stdin () {
    #  diff-stdin()     -- diff the output of two commands
    DIFFBIN='diff'
    $DIFFBIN -u <($1) <($2)
}

wopen () {
    #  wopen()  -- open path/URI/URL $1 in a new browser tab
    #              see: scripts/x-www-browser
    if [ -n "${__IS_MAC}" ]; then
        open $@
    elif [ -n "${__IS_LINUX}" ]; then
        x-www-browser $@
    else
        python -m webbrowser -t $@
    fi
}

find-largefiles () {
    #  find-largefiles  -- find files larger than size (default: +10M)
    SIZE=${1:-"+10M"}
    find . -xdev -type f -size "${SIZE}" -exec ls -alh {} \;
}

find-pdf () {
    #  find-pdf         -- find pdfs and print info with pdfinfo
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
    #   find-lately()   -- list and sort files in paths $@ by mtime
    set -x
    paths=${@:-"/"}
    lately="lately.$(date +'%Y%m%d%H%M%S')"

    #find $paths -printf "%T@\t%s\t%u\t%Y\t%p\n" > ${lately}
    find $paths -exec \
        stat -f '%Sc%t%N%t%z%t%Su%t%Sg%t%Sp%t%T' -t '%F %T%z' {} \; \
        > ${lately} 2> ${lately}.errors
    # time_epoch \t size \t user \t type \t path
    sort ${lately} > ${lately}.sorted
    set +x
}

find-setuid () {
    #  find-setuid()    -- find all setuid and setgid files
    #                       stderr > find-setuid.errors
    #                       stdout > find-setuid.files
    sudo \
        find /  -type f \( -perm -4000 -o -perm -2000 \) -exec ls -ld '{}' \; \
        2> find-setuid.errors \
        > find-setuid.files
}

find-startup () {
    #  find-startup()   -- find common startup files in common locations
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
    #  find-ssl()       -- find .pem and .db files and print their metadata
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
    #  find-dpkgfile()  -- search dpkgs with apt-file
    apt-file search $@
}

find-dpkgfiles () {
    #  find-dpkgfiles() -- sort dpkg /var/lib/dpkg/info/<name>.list
    cat /var/lib/dpkg/info/${1}.list | sort
}

deb-chksums () {
    # checks filesystem against dpkg's md5sums 
    #
    # Author: Filippo Giunchedi <filippo@esaurito.net>
    # Version: 0.1
    #
    # this file is public domain 

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
    #  deb-mkrepo   -- create dpkg Packages.gz and Sources.gz from dir ${1}
    REPODIR=${1:-"/var/www/nginx-default/"}
    cd $REPODIR
    dpkg-scanpackages . /dev/null | gzip -9c > $REPODIR/Packages.gz
    dpkg-scansources . /dev/null | gzip -9c > $REPODIR/Sources.gz
}

mnt-chroot-bind () {
    #  mnt-chroot-bind()    -- bind mount linux chroot directories
    DEST=$1
    sudo mount proc -t proc ${DEST}/proc
    sudo mount -o bind /dev ${DEST}/dev
    sudo mount sysfs -t sysfs ${DEST}/sys
    sudo mount -o bind,ro /boot {DEST}/boot
}
mnt-cifs () {
    #  mnt-cifs()           -- mount a CIFS mount
    URI="$1" # //host/share
    MNTPT="$2"
    OPTIONS="-o user=$3,password=$4"
    mount -t cifs $OPTIONS $URI $MNTPT
}
mnt-davfs () {
    #  mnt-davfs()          -- mount a WebDAV mount
    URL="$1"
    MNTPT="$2"
    OPTIONS="-o rw,user,noauto"
    mount -t davfs $OPTIONS $URL $MNTPT
}

lsof-sh () {
    #  lsof-sh()            -- something like lsof
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
    #  lsof-net()           -- lsof the network things
    ARGS=${@:-''}
    for pid in `lsof -n -t -U -i4 2>/dev/null`; do
        echo "-----------";
        ps $pid;
        lsof -n -a $ARGS -p $pid 2>/dev/null;
    done
}


net-stat () {
    #  net-stat()           -- print networking information
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
    #  ssh-prx()            -- SSH SOCKS
    RUSERHOST=$1
    RPORT=$2

    LOCADDR=${3:-"10.10.10.10"}
    PRXADDR="$LOCADDR:1080"
    sudo ip addr add $LOCADDR dev lo netmask 255.255.255.0
    ssh -ND $PRXADDR $RUSERHOST -p $RPORT

    echo "$PRXADDR"
}

strace- () {
    #  strace-()            -- strace with helpful options
    strace -ttt -f -F $@ 2>&1
}
strace-f () {
    #  strace-f()           -- strace -e trace=file + helpful options
    strace_ -e trace=file $@
}

strace-f-noeno () {
    #  strace-f-noeno       -- strace -e trace=file | grep -v ENOENT
    strace_ -e trace=file $@ 2>&1 \
        | grep -v '-1 ENOENT (No such file or directory)$' 
}

walkpath () {
    #  walkpath()    -- walk down a path
    #   $1 : path (optional; default: pwd)
    #   $2 : cmd  (optional; default: ls -ald --color=auto)
    #   see: http://superuser.com/a/65076 
    dir=${1:-$(pwd)}
    if [ -n "${__IS_MAC}" ]; then
        cmd=${2:-"ls -ldaG"}
    else
        cmd=${2:-"ls -lda --color=auto"}
    fi
    dir=$(realpath ${dir})
    parts=$(echo ${dir} \
        | awk 'BEGIN{FS="/"}{for (i=1; i < NF+2; i++) print $i}')
    paths=('/')
    unset path
    for part in $parts; do
        path="$path/$part"
        paths=("${paths[@]}" $path)
    done
    ${cmd} ${paths[@]}
}

