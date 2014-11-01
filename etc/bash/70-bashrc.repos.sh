
ensure_symlink() {
    #  ensure_symlink   -- create or update a symlink to $_to from _from
    #    ln -s $_to $_from
    _from=$1
    _to=$2
    _date=${3:-$(date +%FT%T%z)}  #  ISO8601 w/ tz
    # if symlink $_from already exists
    if [ -s $_from ]; then
        # compare the actual paths
        _to_path=(get_realpath $_to)
        _from_path=(get_realpath $_from)
        if [ $_to_path == $_from_path ]; then
            printf "%s already points to %s" "$_from" "$_to"
        else
            printf "%s points to %s" "$_from" "$_to"
            mv -v ${_from} "${_from}.bkp.${_date}"
            ln -v -s ${_to} ${_from}
        fi
    else
        # if a file or folder exists return an errorcode
        if [ -e ${_from} ]; then
            printf "%s exists" "${_from}"
            mv -v ${_from} "${_from}.bkp.${_date}"
            ln -v -s ${_to} ${_from}
        else
            # otherwise, create the symlink
            ln -v -s $_to $_from
        fi
    fi
}

ensure_mkdir() {
    #  ensure_mkdir -- create a directory if it does not yet exist
    prefix=$1
    test -d ${prefix} || mkdir -p ${prefix}
}

_venv_ensure_paths() {
    #  _venv_ensure_paths()   -- 
    prefix=$1
    ensure_mkdir ${prefix}
    ensure_mkdir ${prefix}/bin
    ensure_mkdir ${prefix}/etc
    # ensure_mkdir ${prefix}/home
    ensure_mkdir ${prefix}/lib
    # ensure_mkdir ${prefix}/opt
    # ensure_mkdir ${prefix}/sbin
    ensure_mkdir ${prefix}/src
    # ensure_mkdir ${prefix}/srv
    ensure_mkdir ${prefix}/tmp
    ensure_mkdir ${prefix}/usr/share/doc
    ensure_mkdir ${prefix}/var/cache
    ensure_mkdir ${prefix}/var/log
    ensure_mkdir ${prefix}/var/run
}

mkvirtualenv_conda_if_available() {
    #  mkvirtualenv_conda_if_available -- do mkvirtualenv_conda, mkvirtualenv
    (declare -f 'mkvirtualenv_conda' 2>&1 > /dev/null \
        && mkvirtualenv_conda $@) \
    || \
    (declare -f 'mkvirtualenv' 2>&1 > /dev/null \
        && mkvirtualenv $@)
}

workon_conda_if_available() {
    #  mkvirtualenv_conda_if_available -- do mkvirtualenv_conda, mkvirtualenv
    (declare -f 'workon_conda' 2>&1 > /dev/null \
        && workon_conda $@) \
    || \
    (declare -f 'we' 2>&1 > /dev/null \
        && we $@) \
    || \
    (declare -f 'workon' 2>&1 > /dev/null \
        && workon $@)
}

setup_dotfiles_docs_venv() {
    #  setup_dotfiles_docs_venv -- create default 'docs' venv
    deactivate

    __DOCSENV="docs"
    export __DOCS="${WORKON_HOME}/${__DOCSENV}"
    export __DOCSWWW="${__DOCS}/var/www"
    mkvirtualenv_conda_if_available $__DOCSENV
    workon_conda_if_available $__DOCS
    _venv_ensure_paths $__DOCS
}

setup_dotfiles_src_venv() {
    #  setup_dotfiles_src_venv -- create default 'src' venv
    #
    #   __SRC_HG=${WORKON_HOME}/src/src/hg
    #   __SRC_GIT=${WORKON_HOME}/src/src/git
    #
    #  Hg runs hg commands as user hg
    #  Git runs git commands as user git
    #
    #  Hgclone will mirror to $__SRC_HG
    #  Gitclone will mirror to $__SRC_GIT
    #
    #
    deactivate
    __SRCENV="src"
    export __SRC=${WORKON_HOME}/${__SRCENV}/src
    export __SRC_HG=${__SRC}/hg
    export __SRC_GIT=${__SRC_GIT}/git
    mkvirtualenv_conda_if_available $__SRCENV
    workon_conda_if_available $__SRCENV

    _venv_ensure_paths ${WORKON_HOME}/${__SRCENV}
    ensure_mkdir $__SRC
    ensure_mkdir $__SRC/git
    ensure_mkdir $__SRC/hg
    ensure_mkdir ${prefix}/var/www
}


get_realpath() {
    #  get_realpath     -- get an absolute path to a path or symlink (Python)
    prefix=$1
    #(cd ${prefix}; pwd; basename ${prefix})
    python -c "import os; print(os.path.realpath('${prefix}'))"
    return $?
}



fixperms () {
    #fix permissions for hgweb? TODO
    __PATH=$1
    sudo chown -R hg:hgweb "$__PATH"
    sudo chmod -R g+rw "$__PATH"
}

# __SRC_GIT_REMOTE_URI_PREFIX   -- default git remote uri prefix
__SRC_GIT_REMOTE_URI_PREFIX="ssh://git@git.create.wrd.nu"
# __SRC_GIT_REMOTE_NAME         -- name for git remote v
__SRC_GIT_REMOTE_NAME="create"
# __SRC_HG_REMOTE_URI_PREFIX    -- default hg remote uri prefix
__SRC_HG_REMOTE_URI_PREFIX="ssh://hg@hg.create.wrd.nu"
# __SRC_HG_REMOTE_NAME          -- name for hg paths
__SRC_HG_REMOTE_NAME="create"

__SRC_GIT_GITOLITE_ADMIN=$HOME/gitolite-admin

Git_create_new_repo(){
    ## Create a new hosted repository with gitolite-admin
    #  $1   -- repo [user/]name (e.g. westurner/dotfiles)
    reponame=$1  # (e.g. westurner/dotfiles)
    cd $__SRC_GIT_GITOLITE_ADMIN_REPO && \
    ./add_repo.sh "$reponame" 
}

Git_pushtocreate() {
    ## push a git repository to local git storage
    #  $1   -- repo [user/]name (e.g. westurner/dotfiles) 
    reponame=$1
    repo_uri="${__SRC_GIT_URI}/${reponame}"
    here=$(pwd)
    #  $2   -- path of local repo (e.g. ~/wrk/.ve/dotfiles/src/dotfiles)
    repo_local_path=$2
    remote_name=${__SRC_GIT_REMOTE_NAME}

    Git_create_new_repo $reponame
    (cd $repo_local_path;  \
        git remote add $remote_name $repo_uri  \
            "${__SRC_GIT_URI}/${username}/${reponame}" && \
        git push --all $remote_name && \
        cd $here)
}

Hg_create_new_repo() {
    ## Create a new hosted repository with mercurial-ssh
    reponame=$1
    cd $__SRC_HG_SERVER_REMOTE_ADMIN && \
        ./add_repo.sh "$reponame"  # TODO: create add_repo.sh
}

Hg_pushtocreate() {
    ## push a hg repository to local git storage
    #  $1   -- repo [user/]name (e.g. westurner/dotfiles)
    reponame=$1
    repo_uri="${__SRC_HG_URI}/${reponame}"
    here=$(pwd)
    #  $2   -- path of local repo (e.g. ~/wrk/.ve/dotfiles/src/dotfiles)
    repo_local_path=$2
    remote_name=${__SRC_HG_REMOTE_NAME}    
}


Hgclone () {
    url=$1
    shift
    path="${__SRC}/hg/$1"
    if [ -d $path ]; then
        echo "$path existing. Exiting." >&2
        echo "see: update_repo $1"
        return 0
    fi
    sudo -u hg -i /usr/bin/hg clone $url $path
    fixperms $path
}

Hg() {
    path="${__SRC}/hg/$1"
    path=${path:-'.'}
    shift
    cmd=$@
    sudo -H -u hg -i /usr/bin/hg -R "${path}" $cmd

    #if [ $? -eq 0 ]; then
    #    fixperms ${path}
    #fi
}

Hgcheck() {
    path="${__SRC}/$1"
    path=${path:-'.'}
    shift
    Hg $path tags
    Hg $path id -n
    Hg $path id
    Hg $path branch

    #TODO: last pulled time
}

Hgupdate() {
    path=$1
    shift
    Hg $path update $@
}

Hgstatus() {
    path=$1
    shift
    Hg $path update $@
}

Hgpull() {
    path=$1
    shift
    Hg $path pull $@
    Hgcheck $path
}

Hglog() {
    path=$1
    shift
    Hg -R $path log $@
}

Hgcompare () {
    one=$1
    two=$2
    diff -Naur \
        <(hg -R "${one}" log) \
        <(hg -R "${two}" log)
}

host_docs () {
    #  host_docs    -- build and host documentation in a local directory
    #   param $1: <project_name>
    #   param $2: [<path>]
    #   param $3: [<docs/Makefile>]
    #   param $4: [<docs/conf.py>]
    # * log documentation builds
    # * build a sphinx documentation set with a Makefile and a conf.py
    # * rsync to docs webserver
    # * set permissions

    # this is not readthedocs.org

    # note: you must manually install packages into the
    # local 'docs' virtualenv'
    set -x
    pushd .
    #workon docs
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

    dest="${__DOCSWWW}/${name}"
    group="www-data"

    if [ -z "${_makefile}" ]; then
        if [ -f $_default_makefile ]; then
            _makefile=$_default_makefile;
        else
            echo "404: default_makefile: $_default_makefile" >&2
            __makefiles=$(find "${path}" -maxdepth 2 -type f -name Makefile)
            for __makefile in ${__makefiles[@]}; do
                if [ -n "${__makefile}" ]; then
                    grep -n -H 'sphinx-build' ${__makefile} \
                        && grep -n -H '^html:' ${__makefile}
                    if [ $? -eq 0 ]; then
                        echo 'Found sphinx-build Makefile: $__makefile'
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
                    #TODO: prompt?
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
        #TODO
        #>> 'SPHINX_BUILD =    sphinx-build -Dhtml_theme=default -Dother '
        #<< 'SPHINX_BUILD =    sphinx-build -Dhtml_theme=default'
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
        sed -i.bak -r 's/(^ *html_theme)( *= *)(.*)/\1\2"default"' $_confpy
        sourcedir=$(dirname $_confpy)
        html_path="${sourcedir}/_build/html"
        mkdir -p $html_path
        SPHINXBUILD="sphinx-build -Dhtml_theme=\"default\"" \
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
        rsync -avr "${html_path}/" "${dest}/" \
            | tee -a $_buildlog \
            | tee $_currentbuildlog
        set +x
        sudo chgrp -R $group "${dest}" \
            | tee -a $_buildlog \
            | tee $_currentbuildlog
    else
        echo "### ${_currentbuildlog}"
        cat $_currentbuildlog
    fi

    popd

    set +x
    deactivate
}


