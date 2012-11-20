
## Local Shell Environment

reload() {
    source ~/.bashrc
    #      --> .bashrc.venv.sh
}


export DOTFILES="${HOME}/.dotfiles"
export PROJECTS="${HOME}/.projectsrc.sh"
export __SRC="/srv/repos/src"

# Virtualenvwrapper
export WORKSPACE="${HOME}/workspace"
export WORKON_HOME="${WORKSPACE}/.virtualenvs"

# Usrlog
source "${DOTFILES}/etc/usrlog.sh"
_setup_usrlog

# Bashmarks
source "${DOTFILES}/etc/.bashmarks.sh"

# Editor
export USEGVIM=true
_setup_editor() {
    # Configure $EDITOR
    export VIMBIN=${VIMBIN:-"/usr/bin/vim"}
    export GVIMBIN=${GVIMBIN:-"/usr/bin/gvim "}
    export MVIMBIN=${MVIMBINBIN:-"/usr/local/bin/mvim"}

    export EDITOR=${EDITOR:-"${VIMBIN} -p"}
    export SUDO_EDITOR=${SUDO_EDITOR:-"${VIMBIN} -p"}

    if [ -n "${USEGVIM}" ]; then
        if [ -x "${GVIMBIN}" ]; then
            export GVIMBIN="${GVIMBIN} -p"
            export EDITOR=${EDITOR:-"${GVIMBIN}"}
            export SUDO_EDITOR=${SUDO_EDITOR:-"${VIMBIN}"}
        elif [ -x "${MVIMBIN}" ]; then
            export MVIMBIN="${MVIMBIN} -p -f"
            export EDITOR=${EDITOR:-"${MVIMBIN}"}
            export SUDO_EDITOR="${MVIMBIN} -v"
            alias vim="${MVIMBIN} -v -f"
            alias gvim="${MVIMBIN} -v -f"
        fi
    fi
    
    _EDITCMD="${EDITOR}"
}
_setup_editor

## $PATH

add_to_path ()
{
    ## http://superuser.com/questions/ \
    ##   39751/add-directory-to-path-if-its-not-already-there/39840#39840
    if [[ "$PATH" =~ (^|:)"${1}"(:|$) ]]; then
        return 0
    fi
    export PATH=$1:$PATH
}

if [ -d "${DOTFILES}" ]; then
    # Add dotfiles executable directories to $PATH
    add_to_path "${DOTFILES}/bin"
    add_to_path "${DOTFILES}/scripts"
fi

## file paths

#__THIS=$(readlink -e "$0")
#__THISDIR=$(dirname "${__THIS}")

path () {
    # print absolute path to file
    echo "$PWD/"$1""
}

expandpath () {
    # Enumerate files from PATH

    COMMAND=${1-"ls -alZ"}
    PATHS=$(echo $PATH | tr ':' ' ')

    for p in $PATHS; do
        find "$p" -type f -print0 | xargs -0 $COMMAND
    done

    echo "#" $PATH
    for p in $PATHS; do
        echo "# " $p
    done
}


_trail () {
    # walk upwards from a path
    # see: http://superuser.com/a/65076  
    unset path
    _pwd=${1:-$(pwd)}
    parts=$(echo ${_pwd} | awk 'BEGIN{FS="/"}{for (i=1; i < NF; i++) print $i}')

    for part in $parts; do
        path="$path/$part"
        ls -ldZ $path
    done

}

chown-me () {
    set -x
    chown -Rv $(id -un):$(id -un) $@
    chmod -Rv go-rwx $@
    set +x

}
chown-sme () {
    set -x
    sudo chown -Rv $(id -un):$(id -un) $@
    sudo chmod -Rv go-rwx $@
    set +x

}
chown-user () {
    set -x
    chown -Rv $(id -un):$(id -un) $@
    chmod -Rv go-rwx $@
    set +x
}


new-sh () {
    # Create and open a new shell script
    file=$1
    if [ -e $1 ]
        then echo "$1 exists"
        else
        touch $1
        echo "#!/bin/sh" >> $1
        echo "" >> $1
        chmod 700 $1
        $EDITOR +2 $1
    fi
}

diff-dirs () {
    # List differences between directories
    F1=$1
    F2=$2
    #LSBIN=${3-'ls -a | sort'}
    DIFFBIN=${4:-'diff -u'}

    LSBIN="find $path -printf '%T@\t%s\t%u\t%Y\t%p\n'"

    HERE=$(pwd)
    $DIFFBIN \
        <(cd $F1; find . -printf '%T@\t%s\t%u\t%Y\t%p\n';) \
        <(cd $HERE; cd $F2; find . -printf '%T@\t%s\t%u\t%Y\t%p\n';)
    cd $HERE
}

diff-stdin () {
    # Diff the output of two commands
    DIFFBIN='diff'
    $DIFFBIN -u <($1) <($2)
}


wopen () {
    # open in new tab
    python -m webbrowser -t $@
}

find_largefiles () {
    SIZE=${1:-"+10M"}
    find . -xdev -type f -size "${SIZE}" -exec ls -alh {} \;
}
find_pdf () {
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
find_lately () {
    set -x
    paths=$@
    lately="lately.$(date +'%Y%m%d%H%M%S')"

    find $paths -printf "%T@\t%s\t%u\t%Y\t%p\n" | tee $lately
    # time_epoch \t size \t user \t type \t path
    sort $lately > $lately.sorted

    less $lately.sorted
    set +x
    #for p in $paths; do
    #    repos -s $p
    #done
}

find_setuid () {
    find /  -type f \( -perm -4000 -o -perm -2000 \) -exec ls -ld '{}' \;
}
find_startup () {
    cmd=${@:-"ls"}
    paths='/etc/rc?.d /etc/init.d /etc/init /etc/xdg/autostart /etc/dbus-1'
    paths="$paths ~/.config/autostart /usr/share/gnome/autostart"
    for p in $paths; do
        if [ -d $p ]; then
            find $p -type f | xargs $cmd
        fi
    done
}

find_ssl() {
    # apt-get install libnss3-tools
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

find_pkgfile () {
    apt-file search $@
}

find_pkgfiles () {
    cat /var/lib/dpkg/info/$1.list | sort
}

deb_chksums () {
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




deb_mkrepo () {
    REPODIR=${1:-"/var/www/nginx-default/"}
    cd $REPODIR
    dpkg-scanpackages . /dev/null | gzip -9c > $REPODIR/Packages.gz
    dpkg-scansources . /dev/null | gzip -9c > $REPODIR/Sources.gz
}

mnt_bind () {
    DEST=$1
    mount -o bind /dev ${DEST}/dev
    mount -o bind /proc ${DEST}/proc
    mount -o bind /sys ${DEST}/sys
    # TODO
}
mnt_cifs () {
    URI="$1" # //host/share
    MNTPT="$2"
    OPTIONS="-o user=$3,password=$4"
    mount -t cifs $OPTIONS $URI $MNTPT
}
mnt.davfs () {
    #!/bin/sh
    URL="$1"
    MNTPT="$2"
    OPTIONS="-o rw,user,noauto"
    mount -t davfs $OPRTIONS $URL $MNTPT
}

lsof_ () {
    #!/bin/bash 

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


lsof_net () {
    ARGS=${@:-''}
    for pid in `lsof -n -t -U -i4 2>/dev/null`; do
        echo "-----------";
        ps $pid;
        lsof -n -a $ARGS -p $pid 2>/dev/null;
    done
}


net_stat () {
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

ssh_prx () {
    RUSERHOST=$1
    RPORT=$2

    LOCADDR=${3:-"10.10.10.10"}
    PRXADDR="$LOCADDR:1080"
    sudo ip addr add $LOCADDR dev lo netmask 255.255.255.0
    ssh -ND $PRXADDR $RUSERHOST -p $RPORT

    echo "$PRXADDR"
}

strace_ () {
    strace -ttt -f -F $@ 2>&1
}
strace_f () {
    strace_ -e trace=file
}

strace_f_noeno () {
    strace_ -e trace=file $@ 2>&1 \
        | grep -v '-1 ENOENT (No such file or directory)$' 
}

### Python/Virtualenv[wrapper] setup

_setup_python () {
    # Python
    export PYTHONSTARTUP="${HOME}/.pythonrc"
    #alias ipython="python -c 'import IPython;IPython.Shell.IPShell().mainloop()'"

}
_setup_python

_setup_venvwrapper () {
    export _VENVW="/usr/local/bin/virtualenvwrapper.sh"
    source "$_VENVW"

    alias cdw="cd $WORKON_HOME"
    alias cdv='cdvirtualenv'
    alias cdsrc='cdvirtualenv src'
    alias cdetc='cdvirtualenv etc'
    alias cdlib='cdvirtualenv lib'
    #alias cde='cdvirtualenv src/$_VENVNAME'

}
_setup_venvwrapper

lsvirtualenv() {
    cmd="${1-echo}"
    for venv in $(ls -adtr "${WORKON_HOME}"/**/lib/python?.? | \
        sed "s:$WORKON_HOME/\(.*\)/lib/python[0-9]\.[0-9]:\1:g"); do
        $cmd $venv/
    done
}

pypath() {
    /usr/bin/env python -c "import sys; print '\n'.join(sys.path)"
}

lightpath() {
    echo $PATH | sed 's/\:/\n'
}

_gvim() {
    gvim --servername ${_VENVNAME} --remote ${_VENVNAME} $@
}

_grinvenv() {
    grin $@ "${_VENV}"
}
_grindvenv() {
    grind $@ "${_VENV}"
}
_grinsrc() {
    grin $@ "${_EGGSRC}"
}
_grindsrc() {
    grind $@ "${_EGGSRC}"
}

workon_project() {
    _VENVNAME=$1
    _APPNAME=${2:-$1}

    _open_editors=${3:-""}
    _open_terminals=${4:-""}
    
    workon "${_VENVNAME}"

    _VENV="${VIRTUAL_ENV}"

    export _SRC="${_VENV}/src"
    export _BIN="${_VENV}/bin"
    export _ETC="${_VENV}/etc"
    export _EGGSRC="${_SRC}/${_APPNAME}"
    export _EGGSETUPPY="${_EGGSRC}/setup.py"
    export _EGGCFG="${_VENV}/etc/development.ini"

    _EDITCFGCMD="${_EDITCMD} ${_EGGCFG}"
    _SHELLCMD="${_BIN}/pshell ${_EGGCFG}" #${_APPNAME}"
    _SERVECMD="${_BIN}/pserve --reload --monitor-restart ${_EGGCFG}"
    _TESTCMD="python ${_EGGSETUPPY} nosetests"

    # aliases
    alias cde='cd ${_EGGSRC}'

    alias _serve="${_SERVECMD}"
    alias _shell="${_SHELLCMD}"
    alias _test="${_TESTCMD}"
    alias _editcfg="${_EDITCFGCMD}"
    alias _glog="hgtk -R '${_EGGSRC}' log"
    alias _log="hg -R '${_EGGSRC}' log"
    alias _make="cdvirtualenv; make"

    # cd
    cd "${_EGGSRC}"

    if [ -n "${_open_editors}" ]; then
        _gvim \
            ${_EGGSRC} \
            ./TODO* \
            ./README.rst \
            ./CHANGES.rst \
            ./Makefile  \
            ./setup.py \
            ${_SRC} \
            ${_ETC} \
            ${_BIN} \
            ${_VENVW} 
    fi

    if [ -n "${_open_terminals}" ]; then
        # open editor
        # open tabs
        gnome-terminal \
            --working-directory="${_EGGSRC}" \
            --tab --title="${_APPNAME} bash" \
                --command="bash" \
            --tab --title="${_APPNAME} serve" \
                --command="bash -c 'workon_pyramid_app $_VENVNAME $_APPNAME; \
                    ${_SERVECMD} ; \
                    bash'" \
            --tab --title="${_APPNAME} shell" \
                --command="bash -c '${_SHELLCMD}'; \\
                    bash" 
    fi
}
we () {
    workon_project $@
}



loadaliases() {

    # some more ls aliases
    alias ll='ls -alF'
    alias la='ls -A'
    alias lt='ls -altr'
    #alias l='ls -CF'
    ggvim() {
        gvim $@ 2>&1 > /dev/null
    }

    alias chownr="chown -R"
    alias chmodr="chmod -R"
    alias fumnt='fusermount -u'
    alias gitdiffstat="git diff -p --stat"
    alias gitlog="git log --pretty=format:'%h : %an : %s' --topo-order --graph"
    alias hgl='hg log -l10'
    alias hgs='hg status'
    alias ifc='ifconfig'

    alias less='~/bin/less.sh'
    alias less_='/usr/bin/less'

    alias pyclean='find . -type f -name "*.py[co]" -exec rm -f \{\} \;'
    alias ish='ipython -p shell'

    alias sudogvim="EDITOR=$GVIMBIN sudo -e"
    alias sudovim="EDITOR=$EDITOR sudo -e"

    alias t='tail'

    alias xclip="xclip -selection c"
    
    alias grinp="grin --sys-path"
    alias grindp="grind --sys.path"
}
loadaliases

_set_prompt() {
    if [ -n "$VIRTUAL_ENV" ]; then
        export venv_name="$(basename $VIRTUAL_ENV)" # TODO
    else
        unset -v venv_name
    fi

    if [ "$color_prompt" = yes ]; then
        PS1='${debian_chroot:+($debian_chroot)}${venv_name:+($venv_name)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ '
    else
        PS1='${debian_chroot:+($debian_chroot)}${venv_name:+($venv_name)}\u@\h:\w\n\$ '
        unset color_prompt
    fi
}
_set_prompt

# view manpages in vim
man() {
    alias man_="/usr/bin/man"
    if [ $# -eq 0 ]; then
        /usr/bin/man
    else
        #if [ "$1" == "man" ]; then
        #    exit 0
        #fi

        #/usr/bin/whatis "$@" >/dev/null
        vim \
            --noplugin \
            -c "runtime ftplugin/man.vim" \
            -c "Man $*" \
            -c 'silent! only' \
            -c 'nmap q :q<CR>' \
            -c 'set nomodifiable' \
            -c 'set colorcolumn=0'
    fi
}

e() {
    echo $@
}

vimpager() {
    _PAGER="${HOME}/bin/vimpager"
    # enable vimpager if present
    if [ -x "$_PAGER" ]; then
        export PAGER="$_PAGER"
    fi
}

unumask() {
    path=$1
    find "${path}" -type f -exec chmod -v o+r {} \;
    find "${path}" -type d -exec chmod -v o+rx {} \;
}

_rro_find_repo() {
    [ -d $1/.hg ] || [ -d $1/.git ] || [ -d $1/.bzr ] && cd $path
}

rro () {
    # walk down a path
    # see: http://superuser.com/a/65076 
    # FIXME
    # TODO
    unset path
    _pwd=$(pwd)
    parts=$(pwd | awk 'BEGIN{FS="/"}{for (i=1; i < NF+1; i++) print "/"$i}')

    _rro_find_repo $_pwd
    for part in $parts; do
        path="$path/$part"
       
        ls -ld $path
        _rro_find_repo $path

    done
}

###
# Kernel
_update_initram () {
    DATESTR=$(date +%s-%H.%M.%S%z)
    BACKUPDIR="/boot.old/${DATESTR}/"
    [ -d $BACKUPDIR ] || sudo mkdir -p $BACKUPDIR
    sudo rsync -avpr /boot/* $BACKUPDIR
    sudo /usr/sbin/update-initramfs -k all -u -v
}

_unpack_initram () {
    # http://wiki.openvz.org/Modifying_initrd_image
    INITRAM=$1
    DEST=${2:-"initrdunpack"}
    INITRAM_GZ="${INITRAM}.gz"
    INITRAM_NAME=$(basename ${INITRAM_GZ})
    #mkdir "d-$F"
    mkdir -p ${DEST}
    cp ${INITRAM} ${DEST}/${INITRAM_NAME}

    zcat ${DEST}/${INITRAM_NAME} | cpio -imd ${DEST}
    # TODO
}

_setup_deb_kernel () {
    return
    sudo apt-get install linux-source ncurses-dev libncurses-dev
    cd /usr/src/
    tar xjvf *.bz2
    cd *-source*
    ls /boot/config-*
    cp /boot/config-* .config # TODO:
    make menuconfig
}

### Vim Setup

_setup_deb_vim () {
    SRCDIR="~/src/vim"
    VIMHG="https://vim.googlecode.com/hg/"
    sudo apt-get install build-essential \
        libncurses5-dev libgnome2-dev libgnomeui-dev  \
        libgtk2.0-dev libatk1.0-dev libbonoboui2-dev libcairo2-dev \
        libx11-dev libxpm-dev libxt-dev libssl-dev
    if ![ -d $SRCDIR ]; then
        hg clone $VIMHG $SRCDIR
    fi
    cd $SRCDIR
    ./configure \
        --enable-multibyte \
        --enable-pythoninterp \
        --enable-rubyinterp \
        --enable-cscope \
        --enable-xim \
        --with-features=huge \
        --enable-gui=gnome2
    make
}



[ -f $PROJECTS ] && source $PROJECTS
