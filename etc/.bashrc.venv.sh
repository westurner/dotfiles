## .bashrc.venv.sh
# 
# sh configuration
# intended to be sourced from (after) ~/.bashrc
#
# 

reload() {
    source ~/.bashrc
    # --> source ${__DOTFILES}/etc/.bashrc.venv.sh
}


# Virtualenvwrapper
# sudo apt-get install virtualenvwrapper || easy_install virtualenvwrapper
export PROJECT_HOME="${HOME}/wrk"
declare -x WORKON_HOME="${PROJECT_HOME}/.ve"

# 
export __DOTFILES="${WORKON_HOME}/dotfiles/src/dotfiles"
export __PROJECTS="${PROJECT_HOME}/.projectsrc.sh"

export __SRC="${HOME}/src/hg"
[ ! -d $__SRC ] && mkdir -p $__SRC

export _DOCSHTML="${HOME}/docs"
[ ! -d $_DOCSHTML ] && mkdir -p $_DOCSHTML


# Usrlog
source "${__DOTFILES}/etc/usrlog.sh"
_setup_usrlog

# screensaver
if [ ! -d '/Library' ]; then
    source "${__DOTFILES}/etc/screensaver.sh"
fi

# Bashmarks
source "${__DOTFILES}/etc/.bashmarks.sh"

# list bashmarks for nerdtree
lsbashmarks () {
    export | grep 'DIR_' | pyline "line[15:].replace('\"','').split('=',1)"
}


# Editor
#export USEGVIM=""
_setup_editor() {
    # Configure $EDITOR
    export VIMBIN="/usr/bin/vim"
    export GVIMBIN="/usr/bin/gvim"
    export MVIMBIN="/usr/local/bin/mvim"

    [ -f $GVIMBIN ] && export USEGVIM="true" || export USEGVIM=""

    export EDITOR="${VIMBIN}"
    export SUDO_EDITOR="${VIMBIN}"

    if [ -n "${USEGVIM}" ]; then
        VIMCONF='--servername '${VIRTUAL_ENV_NAME:-main}' --remote-tab-silent'
        SUDOCONF="--servername sudo.${VIRTUAL_ENV_NAME:-main} --remote-tab-wait-silent"
        if [ -x "${GVIMBIN}" ]; then
            export EDITOR="${GVIMBIN} ${VIMCONF}"
            export SUDO_EDITOR="${GVIMBIN} ${SUDOCONF}"
        elif [ -x "${MVIMBIN}" ]; then
            export GVIMBIN=$MVIMBIN
            export EDITOR="${MVIMBIN} ${VIMCONF}"
            export SUDO_EDITOR="${MVIMBIN} ${SUDOCONF} "
            alias vim='${EDITOR} -f'
            alias gvim='${EDITOR} -f'
        else
            unset -f $GVIMBIN
            unset -f $MVIMBIN
        fi
    else
        unset -f $GVIMBIN
        unset -f $MVIMBIN
        unset -f $USEGVIM
    fi

    export _EDIT_="${EDITOR}"

    ggvim() {
        $EDITOR $@ 2>&1 > /dev/null
    }

    alias _edit='$EDITOR'
    alias _editcfg='$EDITOR \"${_CFG}\"'
    alias _gvim='$EDITOR'
    alias e='$EDITOR'
    alias edit='$EDITOR'
    alias sudogvim='EDITOR="${SUDO_EDITOR}" sudo -e'
    alias sudovim='EDITOR="${SUDO_EDITOR}" sudo -e'
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

    #FIND="find . -printf '%T@\t%s\t%u\t%Y\t%p\n'"
    diff -Naur \
        <(cd $F1; find . | sort ) \
        <(cd $F2; find . | sort )
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
    export PYTHONSTARTUP="${HOME}/.pythonrc"
    export PIP_REQUIRE_VIRTUALENV=true
    #alias ipython="python -c 'import IPython;IPython.Shell.IPShell().mainloop()'"

}
_setup_python

_setup_virtualenvwrapper () {
    export VIRTUALENVWRAPPER_SCRIPT="/usr/local/bin/virtualenvwrapper.sh"
    export VIRTUALENVWRAPPER_HOOK_DIR="${__DOTFILES}/etc/virtualenvwrapper" # TODO: FIXME
    export VIRTUALENVWRAPPER_LOG_DIR="${PROJECT_HOME}/.virtualenvlogs"
    export VIRTUALENVWRAPPER_PYTHON='/usr/bin/python' # TODO
    export VIRTUALENV_DISTRIBUTE='true'
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

export _VENV="${__DOTFILES}/etc/ipython/ipython_config.py"


venv() {
    $_VENV  $@
}

_venv() {
    venv -E $@
}

we () {
    workon $1 && source <($_VENV --bash $@)
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

    # bashmarks.sh
    #alias l =#bashmarks: list bookmarks
    #alias s =#bashmarks: save bookmark as $1
    #alias g =#bashmarks: goto bookmark $1
    #alias p =#bashmarks: print bookmark $1
    #alias d =#bashmarks: delete bookmark $1

    alias _glog='hgtk -R "${_WRD}" log'
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
    alias hgd='hg diff'
    alias hgdl='hg diff --color=always | less -R'
    alias ifc='ifconfig'
    alias ish='ipython -p shell'
    alias la='ls -A --color=auto'
    alias ll='ls -alF --color=auto'
    alias ls='ls --color=auto'
    alias lt='ls -altr --color=auto'
    alias man_='/usr/bin/man'
    alias pyclean='find . -type f -name "*.py[co]" -exec rm -f \{\} \;'
    alias ssv='supervisord -c "${_SVCFG}"'
    alias sv='supervisorctl -c "${_SVCFG}"'
    alias svd='supervisorctl -c "${_SVCFG}" restart dev && supervisorctl -c "${_SVCFG}" tail -f dev'
    alias svt='sv tail -f'
    alias t='tail'
    alias xclip='xclip -selection c'

    if [ -x "$MVIMBIN" ]; then
        alias la='ls -A -G'
        alias ll='ls -alF -G'
        alias ls='ls -G'
        alias lt='ls -altr -G'
    fi
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
            export VIRTUAL_ENV_NAME="$(basename $VIRTUAL_ENV)" # TODO
        else
            unset -v VIRTUAL_ENV_NAME
        fi
    fi

    if [ "$color_prompt" = yes ]; then
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ '
    else
        PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\n\$ '
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
        export PAGER=$_PAGER
    else
        _PAGER="/usr/local/bin/vimpager"
        if [ -x $_PAGER ]; then
            export PAGER=$_PAGER
        fi
    fi
}

unumask() {
    path=$1
    sudo find "${path}" -type f -exec chmod -v o+r {} \;
    sudo find "${path}" -type d -exec chmod -v o+rx {} \;
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
    # * build a sphinx documentation set with a Makefile and a conf.py
    # * rsync to docs webserver
    # * set permissions

    # this is not readthedocs.org

    # note: you must manually install packages into the
    # local 'docs' virtualenv'
    set -x
    pushd .
    workon docs
    name=${1}

    if [ -z "${name}" ]; then
        echo "must specify an application name"
        return 1
    fi

    path=${2:-"${__SRC}/${name}"}
    _makefile=${3}
    _confpy=${4}
    _default_makefile="${path}/docs/Makefile"
    _default_confpy="${path}/docs/conf.py"

    _default_builddir="${path}/_build"

    dest="${_DOCSHTML}/${name}"
    group="www-data"

    if [ -z "${_makefile}" ]; then
        if [ -f $_default_makefile ]; then
            _makefile=$_default_makefile;
        else
            echo "404: default_makefile: $_default_makefile" >&2
            __makefiles=$(find "${path}" -maxdepth 2 -type f -name Makefile)
            for __makefile in ${__makefiles[@]}; do
                if [ -n "${__makefile}" ]; then
                    grep -n -H 'sphinx-build' ${__makefile}
                    if [ $? -eq 0 ]; then
                        echo 'found sphinx-build Makefile: $__makefile'
                        # TODO: prompt?
                        _makefile=$__makefile
                    fi
                fi
            done
        fi

        if [ -f "${_makefile}" ]; then
            _builddir=$(dirname $_makefile)
        fi
    fi

    if [ -z "${_confpy}" ]; then
        if [ -f $_default_confpy ]; then
            _confpy=$_default_confpy;
        else
            echo "404: default_confpy: $_default_confpy" >&2
            confpys=$(find "${path}" -maxdepth 2 -type f -name conf.py)
            for __confpy in ${confpys[@]}; do
                grep -n -H 'sphinx-build' ${__confpy}
                if [ $? -eq 0 ]; then
                    echo 'found conf.py: $__confpy'
                    # TODO: prompt?
                    _confpy=$__confpy
                fi
            done
        fi

        if [ ! -f $_makefile ]; then
            _builddir=$(dirname $__confpy)
        fi

    fi

    _builddir=${_builddir:-${_default_builddir}}
    _buildlog="${_builddir}/build.log"
    _currentbuildlog="${_builddir}/build.current.log"


    cd $path
    rm -f $_currentbuildlog
    html_path=""
    echo '#' $(date) | tee -a $_buildlog | tee $_currentbuildlog

    if [ -n "$_makefile" ]; then
        # TODO
        # >> 'SPHINX_BUILD =    sphinx-build -Dhtml_theme=default -Dother '
        # << 'SPHINX_BUILD =    sphinx-build -Dhtml_theme=default'
        #sed -i -r 's/(^SPHINXBUILD)( *= *)(sphinx-build)(.*)/\1\2\3 -Dhtml_theme="default"/g' $_makefile

        cd $(dirname $_makefile)
        make \
            SPHINXBUILD="sphinx-build -Dhtml_theme=\"default\"" \
            html | \
            tee -a $_buildlog | tee $_currentbuildlog
        html_path=$(tail -n 1 $_currentbuildlog | \
            sed -r 's/(.*)The HTML pages are in (.*).$/\2/g')
        echo $html_path

    elif [ -n "$_confpy" ]; then
        # >> 'html_theme = "_-_"
        # << 'html_theme = 'default'
        sed -i -r 's/(^ *html_theme)( *= *)(.*)/\1\2"default"' $_confpy
        sourcedir=$(dirname $_confpy)
        html_path="${sourcedir}/_build/html"
        mkdir -p $html_path
        sphinx-build \
            -b html \
            -D html_theme="default" \
            -c "${_confpy}" \
            $sourcedir \
            $html_path
    fi

    if [ -n "${html_path}" ]; then
        echo "html-path:" ${html_path}
        echo "dest:" ${dest}
        set -x
        rsync -avr "${html_path}/" "${dest}/" | tee -a $_buildlog | tee $_currentbuildlog
        set +x
        sudo chgrp -R $group "${dest}" | tee -a $_buildlog | tee $_currentbuildlog
    else
        echo "### ${_currentbuildlog}"
        cat $_currentbuildlog
    fi

    popd

    set +x
    deactivate
}


### source $__PROJECTS script, if it exists
[ -f $__PROJECTS ] && source $__PROJECTS
