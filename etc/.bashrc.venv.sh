
## Local Shell Environment

reload() {
    source ~/.bashrc
}

export WORKON_HOME="${HOME}/workspace/.virtualenvs"

export DOTFILES="${HOME}/.dotfiles"
source "${DOTFILES}/etc/usrlog.sh"
_setup_usrlog

source "${HOME}/etc/.bashmarks.sh"

export PROJECTS="${HOME}/.projectsrc.sh"
export DOCSHTML="${HOME}/docs"

#__THIS=$(readlink -e "$0")
#__THISDIR=$(dirname "${__THIS}")

if [ -x '/usr/local/bin/mvim' ]; then
    export EDITOR='/usr/local/bin/mvim -f'
    export SUDO_EDITOR='/usr/local/bin/mvim -v -f'
    alias vim='/usr/local/bin/mvim -v -f'
else
    export EDITOR="${EDITOR:-"vim -g"}"
    _EDITCMD="${EDITOR}"
    _EDITMANYCMD="${EDITCMD} -p"
fi

path () {
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


add_to_path ()
{
    ## http://superuser.com/questions/ \
    ##   39751/add-directory-to-path-if-its-not-already-there/39840#39840
    if [[ "$PATH" =~ (^|:)"${1}"(:|$) ]]; then
        return 0
    fi
    export PATH=$1:$PATH
}


# TODO: symlink to ~/bin
#if [ -d "${DOTFILES}" ]; then
#    add_to_path "${DOTFILES}/bin"
#fi


chown_me () {
    set -x
    sudo chown -R $(id -un):$(id -un) $@
    sudo chmod -R go-rwx $@
    set +x

}
chown_sme () {
    set -x
    sudo chown -Rv $(id -un):$(id -un) $@
    sudo chmod -Rv go-rwx $@
    set +x

}
chown_user () {
    set -x
    chown -Rv $(id -un):$(id -un) $@
    chmod -Rv go-rwx $@
    set +x
}

new_sh () {
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

diff_dirs () {
    F1=$1
    F2=$2
    #LSBIN=${3-'ls -a | sort'}
    DIFFBIN=${4:-'diff -u'}

    HERE=$(pwd)
    $DIFFBIN <(cd $F1; ls -a | sort;) <(cd $HERE; cd $F2; ls -a | sort;)
    cd $HERE
}
diff_stdin () {
    DIFFBIN='diff'
    $DIFFBIN -u <($1) <($2)
}


wopen () {
    # open in new tab
    python -m webbrowser -t $@
}

find_largefiles () {
    #!/bin/bash -x

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

check_setuid () {
    find /  -type f \( -perm -4000 -o -perm -2000 \) -exec ls -ld '{}' \;
}
check_startup () {
    cmd=${@:-"ls"}
    paths='/etc/rc?.d /etc/init.d /etc/init /etc/xdg/autostart /etc/dbus-1'
    paths="$paths ~/.config/autostart /usr/share/gnome/autostart"
    for p in $paths; do
        if [ -d $p ]; then
            find $p -type f | xargs $cmd
        fi
    done

}

check_ssl() {
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

    _runcmd "locate *.pem"

    for d in $(locate '*.db' | egrep 'key[[:digit:]].db'); do  
        kpath=$(dirname $d) 
        _runcmd "certutil  -L -d sql:${kpath}"  "${kpath}"
    done

}

deb_file () {
    apt-file search $@
}

deb_listfiles () {
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


deb_kernel () {
    sudo apt-get install linux-source ncurses-dev libncurses-dev
    cd /usr/src/
    tar xjvf *.bz2
    cd *-source*
    ls /boot/config-*
    cp /boot/config-* .config # TODO:
    make menuconfig
}

deb_makevim () {
    sudo apt-get install libncurses5-dev libgnome2-dev libgnomeui-dev  \
        libgtk2.0-dev libatk1.0-dev libbonoboui2-dev libcairo2-dev \
        libx11-dev libxpm-dev libxt-dev libssl-dev
    if ![ -d '~/src/vim' ]; then
        hg clone https://vim.googlecode.com/hg/ ~/src/vim
    fi
    cd ~/src/vim
    ./configure --enable-multibyte --enable-pythoninterp --enable-rubyinterp --enable-cscope --enable-xim --with-features=huge --enable-gui=gnome2
    make

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
    mount -t cifs $URI $MNTPT $OPTIONS
    }
    mnt.davfs () {
    #!/bin/sh
    URL="$1"
    MNTPT="$2"
    $URL $MNTPT davfs rw,user,noauto 0 0
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
    strace -f -F $@ 2>&1
}
strace_f () {
    strace -f -F -e trace=file $@ 2>&1
}

### Python/Virtualenv[wrapper] setup

_setup_python () {
    # Python
    export PYTHONSTARTUP="${HOME}/.pythonrc"
    #alias ipython="python -c 'import IPython;IPython.Shell.IPShell().mainloop()'"

}
_setup_python

_setup_venvwrapper () {
    _VENVW="/usr/local/bin/virtualenvwrapper.sh"
    source "$_VENVW"


    alias cdw="cd $WORKON_HOME"
    alias cdv='cdvirtualenv'
    alias cds='cdvirtualenv src'
    alias cde='cdvirtualenv etc'
    alias cdl='cdvirtualenv lib'

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

workon_project() {
    _VENVNAME=$1
    _APPNAME=$2

    _OPEN_TERMS=${3:-""}

    _VENVCMD="workon ${_VENVNAME}"
    _VENV="${VIRTUAL_ENV}"

    export _SRC="${_VENV}/src"
    export _BIN="${_VENV}/bin"
    export _EGGSRC="${_SRC}/${_APPNAME}"
    export _EGGSETUPPY="${_EGGSRC}/setup.py"
    export _EGGCFG="${_VENV}/etc/development.ini"

    _EDITCFGCMD="${_EDITCMD} ${_EGGCFG}"
    _SHELLCMD="${_BIN}/pshell ${_EGGCFG}" #${_APPNAME}"
    _SERVECMD="${_BIN}/pserve --reload --monitor-restart ${_EGGCFG}"
    _TESTCMD="python ${_EGGSETUPPY} nosetests"

    # aliases
    alias _serve="${_SERVECMD}"
    alias _shell="${_SHELLCMD}"
    alias _test="${_TESTCMD}"
    alias _editcfg="${_EDITCFGCMD}"
    alias _glog="hgtk -R "${_EGGSRC}" log"
    alias _log="hg -R "${_EGGSRC}" log"

    alias cdsrc="cd ${_SRC}"
    alias cdbin="cd ${_BIN}"
    alias cdeggsrc="cd ${_EGGSRC}"

    alias _make="cdvirtualenv; make"

    workon "${_VENVNAME}"

    # cd to $_PATH
    cd "${_EGGSRC}"

    if [ "${_OPEN_TERMS}" != "" ]; then
        # open editor
        ${_EDITCMD} "${_EGGSRC}" &
        # open tabs
        #gnome-terminal \
        #    --working-directory="${_EGGSRC}" \
        #    --tab -t "${_APPNAME} serve" -e "bash -c \"${_SERVECMD}; bash -c \"workon_pyramid_app $_VENVNAME $_APPNAME 1\"\"" \
        #    --tab -t "${_APPNAME} shell" -e "bash -c \"${_SHELLCMD}; bash\"" \
        #    --tab -t "${_APPNAME} bash" -e "bash"
    fi
}


###
update_initram () {
    DATESTR=$(date +%s-%H.%M.%S%z)
    BACKUPDIR="/boot.old/${DATESTR}/"
    [ -d $BACKUPDIR ] || sudo mkdir -p $BACKUPDIR
    sudo rsync -avpr /boot/* $BACKUPDIR
    sudo /usr/sbin/update-initramfs -k all -u -v
}

initram_unpack () {
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

    alias sudogvim="EDITOR='gvim' sudo -e"
    alias sudovim="EDITOR='vim' sudo -e"

    alias t='tail'

    alias xclip="xclip -selection c"
    
    alias grinp="grin --sys-path"
    alias grindp="grind --sys.path"
}
loadaliases


if [ -n "$VIRTUAL_ENV" ]; then
    export venv_name="$(basename $VIRTUAL_ENV)"
else
    unset -v venv_name
fi


if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}${venv_name:+($venv_name)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}${venv_name:+($venv_name)}\u@\h:\w\n\$ '
    unset color_prompt
fi


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


fixperms () {
    repo="$1"
    sudo chown -R hg:hgweb "$repo"
    sudo chmod -R g+rw "$repo"
}

__SRC="/srv/repos/src"
clone_repo () {
    url=$1
    shift
    path="${__SRC}/$1"
    if [ -d $path ]; then
        echo "$path existing. Exiting." >&2
        echo "see: update_repo $1"
        return 0
    fi
    sudo -H -u hg hg clone $url $path
    fixperms $path
}

repo() {
    path="${__SRC}/$1"
    shift
    sudo -H -u hg hg --repo $path $@
    fixperms $path 
}

update_repo() {
    path=$1
    shift
    repo $path update $@
}



unumask() {
    path=$1
    find "${path}" -type f -exec chmod -v o+r {} \;
    find "${path}" -type d -exec chmod -v o+rx {} \;
}

_rro_check_dir() {
    [ -d $1/.hg ] || [ -d $1/.git ] || [ -d $1/.bzr ] && echo $1
}


rro () {
    # walk upwards from a path
    # see: http://superuser.com/a/65076  
    unset path
    _pwd=$(pwd)
    parts=$(pwd | awk 'BEGIN{FS="/"}{for (i=1; i < NF; i++) print $i}')

    [ -f $_pwd/.hg] || [ -f $_pwd/.git ] || [ -f $_pwd/.bzr ] &&
        cd $path

    for part in $parts; do
        path="$path/$part"
        ls -ld $path   # do whatever checking you need here
        [ -f $path/.hg ] || [ -f $path/.git ] || [ -f $path/.bzr ] && \
            cd $path
    done
}

host_docs () {
    workon docs

    name=$1
    path=${2}
    dest="${DOCSHTML}/${name}"
    group="hgweb"
    if [ -z "${name}" ]; then
        echo "must specify an application name"
        return 1
    fi

    pushd .
    cd $path
    make html | tee build.log > build.current.log

    html_path=$(tail -n 2 build.current.log | sed -r \
        's/^Build finished. The HTML pages are in (.*)\.$/\1/g' -)

    if [ -n "${html_path}" ]; then
        rsync -avr ${html_path} "${dest}"
        chgrp -R $group ${dest}
    else
        cat ./build.current.log
    fi

    deactivate
}

[ -f $PROJECTS ] && source $PROJECTS
