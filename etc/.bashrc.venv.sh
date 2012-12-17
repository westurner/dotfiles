
## Local Shell Environment

reload() {
    source ~/.bashrc
    #      --> .bashrc.venv.sh
}



# Virtualenvwrapper
declare -gx __WORKSPACE="${HOME}/workspace"
declare -gx __PROJECTS="${__WORKSPACE}/.projectsrc.sh"
declare -gx WORKON_HOME="${__WORKSPACE}/.virtualenvs"
declare -gx __DOTFILES="${WORKON_HOME}/dotfiles/src/dotfiles"

declare -gx __SRC="$HOME/src"
[ ! -d $__SRC ] && mkdir -p $__SRC

declare -gx _DOCSHTML="${HOME}/docs"
[ ! -d $_DOCSHTML ] && mkdir -p $_DOCSHTML


# Usrlog
source "${__DOTFILES}/etc/usrlog.sh"
_setup_usrlog

# Bashmarks
source "${__DOTFILES}/etc/.bashmarks.sh"

# list bashmarks for nerdtree
lsbashmarks () {
    declare -gx | grep 'DIR_' | pyline "line[15:].replace('\"','').split('=',1)"
}


# Editor
declare -gx USEGVIM=true
_setup_editor() {
    # Configure $EDITOR
    declare -gx VIMBIN=${VIMBIN:-"/usr/bin/vim"}
    declare -gx GVIMBIN=${GVIMBIN:-"/usr/bin/gvim "}
    declare -gx MVIMBIN=${MVIMBINBIN:-"/usr/local/bin/mvim"}

    declare -gx EDITOR=${EDITOR:-"${VIMBIN} -p"}
    declare -gx SUDO_EDITOR=${SUDO_EDITOR:-"${VIMBIN} -p"}

    if [ -n "${USEGVIM}" ]; then
        if [ -x "${GVIMBIN}" ]; then
            declare -gx GVIMBIN="${GVIMBIN} -p"
            declare -gx EDITOR=${EDITOR:-"${GVIMBIN}"}
            declare -gx SUDO_EDITOR=${SUDO_EDITOR:-"${VIMBIN}"}
        elif [ -x "${MVIMBIN}" ]; then
            declare -gx MVIMBIN="${MVIMBIN} -p -f"
            declare -gx EDITOR=${EDITOR:-"${MVIMBIN}"}
            declare -gx SUDO_EDITOR="${MVIMBIN} -v"
            alias vim="${MVIMBIN} -v -f"
            alias gvim="${MVIMBIN} -v -f"
        fi
    fi
    
    _EDIT_="${EDITOR}"
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
    declare -gx PATH=$1:$PATH
}

if [ -d "${__DOTFILES}" ]; then
    # Add dotfiles executable directories to $PATH
    add_to_path "${__DOTFILES}/bin"
    add_to_path "${__DOTFILES}/scripts"
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
    LSBIN=${3-"ls -a"}
    DIFFBIN=${4:-'diff -u'}

    #LSBIN="find $path -printf '%T@\t%s\t%u\t%Y\t%p\n'"

    HERE=$(pwd)
    $DIFFBIN \
        <(cd $F1; $LSBIN ) \
        <(cd $HERE; $LSBIN )
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
mnt_davfs () {
    #!/bin/sh
    URL="$1"
    MNTPT="$2"
    OPTIONS="-o rw,user,noauto"
    mount -t davfs $OPTIONS $URL $MNTPT
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
    declare -gx PYTHONSTARTUP="${HOME}/.pythonrc"
    declare -gx PIP_REQUIRE_VIRTUALENV=true
    #alias ipython="python -c 'import IPython;IPython.Shell.IPShell().mainloop()'"

}
_setup_python

_setup_virtualenvwrapper () {
    declare -gx VIRTUALENVWRAPPER_SCRIPT="/usr/local/bin/virtualenvwrapper.sh"
    declare -gx VIRTUALENVWRAPPER_PYTHON='/usr/bin/python' # TODO
    declare -gx VIRTUALENV_DISTRIBUTE='true'
    source "${VIRTUALENVWRAPPER_SCRIPT}"

    #alias cdv='cdvirtualenv'
    #alias cds='cdvirtualenv src'
    #alias cde='cdvirtualenv etc'
    #alias cdl='cdvirtualenv lib'
    #alias cde='cdvirtualenv src/$_VENVNAME'

}
_setup_virtualenvwrapper

lsvirtualenv() {
    cmd=${1:-"echo"}
    for venv in $(ls -adtr "${WORKON_HOME}"/**/lib/python?.? | \
        sed "s:$WORKON_HOME/\(.*\)/lib/python[0-9]\.[0-9]:\1:g"); do
        $cmd $venv/
    done
}
lsve() {
    lsvirtualenv $@
}

_setup_venv () {
    declare -gx _VENV="${__DOTFILES}/etc/ipython/ipython_config.py"
}
_setup_venv


venv() {
    $_VENV  $@
}

_venv() {
    venv -E $@
}

we () {
    workon $1 $2 $3 $4 && source <($_VENV -E --bash) && reload
}


## CD shortcuts

cdb () {
    cd "${_BIN}"/$@
}
cde () {
    cd "${_ETC}"/$@
}
cdv () {
    cd "${VIRTUAL_ENV}"/$@
}
cdve () {
    cd "${WORKON_HOME}"/$@
}
cdvar () {
    cd "${_VAR}"/$@
}
cdlog () {
    cd "${_LOG}"/$@
}
cdww () {
    cd "${_WWW}"/$@
}
cdl () {
    cd "${_LIB}"/$@
}
cdpylib () {
    cd "${_PYLIB}"/$@
}
cdpysite () {
    cd "${_PYSITE}"/$@
}
cds () {
    cd "${_SRC}"/$@
}

cdw () {
    cd "${_WRD}"/$@
}

## Grin search
grinv() {
    grin --follow $@ "${VIRTUAL_ENV}"
}
grindv() {
    grind --follow $@ --dirs "${VIRTUAL_ENV}"
}
grins() {
    grin --follow $@ "${_SRC}"
}
grinds() {
    grind --follow $@ --dirs "${_SRC}"
}
grinw() {
    grin --follow $@ "${_WRD}"
}
grindw() {
    grind --follow $@ --dirs "${_WRD}"
}

grindctags() {
    args="$@"
    if [ -z $args ]; then
        args='*.py'
    fi
    grind --follow "$args" | ctags -L -
}


_loadaliases() {

    # some more ls aliases
    alias ll='ls -alF'
    alias la='ls -A'
    alias lt='ls -altr'
    #alias l='ls -CF'
    ggvim() {
        gvim $@ 2>&1 > /dev/null
    }

    alias sudogvim="EDITOR=$GVIMBIN sudo -e"
    alias sudovim="EDITOR=$EDITOR sudo -e"

    _EDIT_="gvim --servername \"${VIRTUAL_ENV_NAME:-'_ -'}\" --remote-tab"
    alias edit='$_EDIT_'
    alias e='$_EDIT_'
    alias _edit='$_EDIT_'
    alias _editcfg='$_EDIT_ \"${_CFG}\"'
    alias _glog='hgtk -R "${_WRD}" log'
    alias _gvim='gvim --servername "math" --remote-tab'
    alias _log='hg -R "${_WRD}" log'
    alias _make='cd "${_WRD}" && make'
    alias _serve='${_SERVE_}'
    alias _shell='${_SHELL_}'
    alias _test='python "${_WRD_SETUPY}" test'
    alias chmodr='chmod -R'
    alias chownr='chown -R'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias fumnt='fusermount -u'
    alias gitdiffstat='git diff -p --stat'
    alias gitlog='git log --pretty=format:"%h : %an : %s" --topo-order --graph'
    alias grep='grep --color=auto'
    alias grindp='grind --sys.path'
    alias grinp='grin --sys-path'
    alias gvim='gvim'
    alias hgl='hg log -l10'
    alias hgs='hg status'
    alias ifc='ifconfig'
    alias ish='ipython -p shell'
    alias la='ls -A'
    alias ll='ls -alF'
    alias ls='ls --color=auto'
    alias lt='ls -altr'
    alias man_='/usr/bin/man'
    alias pyclean='find . -type f -name "*.py[co]" -exec rm -f \{\} \;'
    alias ssv='supervisord -c "${_SVCFG}"'
    alias sv='supervisorctl -c "${_SVCFG}"'
    alias svd='supervisorctl -c "${_SVCFG}" restart dev && supervisorctl -c "${_SVCFG}" tail -f dev'
    alias svt='sv tail -f'
    alias t='tail'
    alias xclip='xclip -selection c'
    
}
_loadaliases

less_ () {
    ## start Vim with less.vim.
    # Read stdin if no arguments were given.
    if test -t 1; then
        if test $# = 0; then
        vim -c "let g:tinyvim=1" \
            --cmd "runtime! macros/less.vim" \
            --cmd "set nomod" \
            --cmd "set noswf" \
            -c "set colorcolumn=0" \
            -c "map <C-End> <Esc>G" \
            -
        else
        vim --noplugin \
            -c "let g:tinyvim=1" \
            -c "runtime! macros/less.vim" \
            --cmd "set nomod" \
            --cmd "set noswf" \
            -c "set colorcolumn=0" \
            -c "map <C-End> <Esc>G" \
            $@
        fi
    else
        # Output is not a terminal, cat arguments or stdin
        if test $# = 0; then
            less
        else
            less "$@"
        fi
    fi
}

_set_prompt() {
    if [ -n "$VIRTUAL_ENV_NAME" ]; then
        if [ -n "$VIRTUAL_ENV" ]; then
            declare -gx VIRTUAL_ENV_NAME="$(basename $VIRTUAL_ENV)" # TODO
        else
            unset -v VIRTUAL_ENV_NAME
        fi
    fi

    if [ "$color_prompt" = yes ]; then
        PS1='${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV_NAME:+($VIRTUAL_ENV_NAME)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ '
    else
        PS1='${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV_NAME:+($VIRTUAL_ENV_NAME)}\u@\h:\w\n\$ '
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

echo_args() {
    echo $@
}

vimpager() {
    # TODO: lesspipe
    _PAGER="${HOME}/bin/vimpager"
    if [ -x $_PAGER ]; then
        declare -gx PAGER=$_PAGER
    else
        _PAGER="/usr/local/bin/vimpager"
        if [ -x $_PAGER ]; then
            declare -gx PAGER=$_PAGER
        fi
    fi
}

unumask() {
    path=$1
    sudo chmod -v o+r $(find "${path}" -type f)
    sudo chmod -v o+rx $(find "${path}" -type d)
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

pypath() {
    /usr/bin/env python -m site
}

lightpath() {
    echo $PATH | sed 's/\:/\n/'
}



unset -f fixperms
fixperms () {
    __PATH="$1"
    echo $__PATH >&2
}

Hgclone () {
    url=$1
    shift
    path="${__SRC}/$1"
    if [ -d $path ]; then
        echo "$path existing. Exiting." >&2
        echo "see: update_repo $1"
        return 0
    fi
    sudo -u hg -i /usr/bin/hg clone $url $path
    fixperms $path
}

Hg() {
    path="${__SRC}/$1"
    path=${path:-'.'}
    shift
    cmd=$@
    sudo -H -u hg -i /usr/bin/hg -R "${path}" $cmd

    #if [ $? -eq 0 ]; then
    #    fixperms ${path}
    #fi
}

Hgupdate() {
    path=$1
    shift
    Hg $path update $@
}

Hgpull() {
    path=$1
    shift
    Hg $path pull $@
    HGcheck $path
}

Hgcheck() {
    path="${__SRC}/$1"
    path=${path:-'.'}
    shift
    hg -R $path tags
    hg -R $path id -n
    hg -R $path id
    hg -R $path branch

    #TODO: last pulled time
}

Hglog() {
    path=$1
    shift
    hg -R $path log $@
}

Hgcompare () {
    one=$1
    two=$2
    diff -Naur \
        <(hg -R "${one}" log) \
        <(hg -R "${two}" log)
}

host_docs () {
    # * log documentation builds
    # * build a sphinx documentation set with a Makefile 
    # * rsync to docs webserver
    # * set permissions

    # this is not readthedocs.org

    pushd .
    workon docs
    name=${1}
    path=${2:-"~/src/${1}/docs"}

    _makefile=${3:-"${path}/Makefile"}
    _confpy=${4:-"${path}/conf.py"}

    dest="${DOCSHTML}/${name}"
    group="www-data"
    if [ -z "${name}" ]; then
        echo "must specify an application name"
        return 1
    fi

    _buildlog="${path}/build.current.log"
    _currentbuildlog="${path}/build.current.log"

    cd $path
    rm $_currentbuildlog 
    echo '#' $(date) | tee -a $_buildlog | tee $_currentbuildlog

    # TODO
    # >> 'SPHINX_BUILD =    sphinx-build -Dhtml_theme=default -Dother '
    # << 'SPHINX_BUILD =    sphinx-build -Dhtml_theme=default'
    sed -r 's/(^SPHINX_BUILD)( *= *)(sphinx-build)(.*)/\1\2\3 -Dhtml_theme="default"' $_makefile
    # >> 'html_theme = "_-_"
    # << 'html_theme = 'default'
    sed -r 's/(^ *html_theme)( *= *)(.*)/\1\2"default"' $_confpy

    make html | tee -a $_buildlog | tee $_currentbuildlog

    html_path=$(tail -n 1 build.current.log | \
        sed -r 's/(.*)The HTML pages are in (.*).$/\2/g')

    if [ -n "${html_path}" ]; then
        echo "html-path:" ${html_path}
        echo "dest:" ${dest}
        set -x
        rsync -avr "${html_path}/" "${dest}/" | tee -a build.log | tee build.current.log
        set +x
        sudo chgrp -R $group "${dest}" | tee -a build.log | tee build.current.log
    else
        echo "### ./build.current.log"
        cat $_currentbuildlog
    fi

    popd
    deactivate
}


### source $__PROJECTS script, if it exists
[ -f $__PROJECTS ] && source $__PROJECTS
