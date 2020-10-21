#!/usr/bin/env bash
### 70-bashrc.repos.sh


function git_commit() {
    #  git-commit()   -- git commit ${2:} -m ${1}; git log -n1
    (set -x;
    msg="${1}";
    shift;
    files=( "${@}" );
    git commit "${files[@]}" -m "${msg}" && \
    git log -n1 --stat --decorate=full --color=always;
    )
}

function gc() {
    #  gc()             -- git-commit() <files> -m <log> ; log log -n1
    git_commit "${@}"
}

function git_add_commit() {
    #  git-add-commit()   -- git add ${2:}; git commit ${2} -m ${1}; git log -n1
    (set -x;
    msg="${1}";
    shift;
    files=( "${@}" );
    git add "${files[@]}";
    git commit "${files[@]}" -m "${msg}" && \
    git log -n1 --stat --decorate=full --color=always;
    )
}

function gac() {
    #  gac()            -- git-add-commit $@
    git_add_commit "${@}"
}

# function msg {
#   export _MSG="${@}"
#   see: usrlog.sh
# }

function git_commit_msg() {
    #  gitcmsg()    -- gitc "${_MSG}" "${@}"
    git_commit "${_MSG}" "${@}"
    msg -
}

function git_add_commit_msg() {
    #  gitcaddmsg()    -- gitc "${_MSG}" "${@}"
    git_add_commit "${_MSG}" "${@}"
    msg -
}


#objectives:
#* [ ] create a dotfiles venv (should already be created by dotfiles install)
#* [ ] create a src venv (for managing a local set of repositories)
#
#* [x] create Hg_ methods for working with a local repo set
#* [ ] create Git_ methods for working with a local repo set
#
#* [-] host docs locally with a one-shot command (host_docs)
#
# Use Cases
# * Original: a bunch of commands that i was running frequently
#   before readthedocs (and hostthedocs)
# * local mirrors (manual, daily?)
#   * no internet, outages
#   * push -f
#   * (~offline) Puppet/Salt source installs
#     * bandwidth: testing a recipe that pulls a whole repositor(ies)
# * what's changed in <project>'s source dependencies, since i looked last
#
# Justification
# * very real risks for all development projects
#   * we just assume that GitHub etc. are immutable and forever
#
# Features (TODO) [see: pyrpo]
# * Hg <subcommands>
# * Git <subcommands>
# * Bzr <subcommands>
# * periodic backups / mirroring
# * gitweb / hgweb
# * mirror_and_backup <URL>
# * all changes since <date> for <set_of_hg-git-bzr-svn_repositories>
# * ideally: transparent proxy
#   * +1: easiest
#   * -1: pushing upstream
#
# Caveats
# * pasting / referencing links which are local paths
# * synchronization lag
# * duplication: $__SRC/hg/<pkg> AND $VIRTUAL_ENV/src/<pkg>
#

setup_dotfiles_docs_venv() {
    #  setup_dotfiles_docs_venv -- create default 'docs' venv
    deactivate

    __DOCSENV="docs"
    export __DOCS="${WORKON_HOME}/${__DOCSENV}"
    export __DOCSWWW="${__DOCS}/var/www"
    mkvirtualenv_conda_if_available "$__DOCSENV"
    venv_mkdirs "$__DOCS"
    workon_conda_if_available "$__DOCS"
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
    _VIRTUAL_ENV="${WORKON_HOME}/${__SRCENV}"

    venv_mkdirs "${_VIRTUAL_ENV}"
    ensure_mkdir "$__SRC"
    ensure_mkdir "$__SRC/git"
    ensure_mkdir "$__SRC/hg"
    ensure_mkdir "${_VIRTUAL_ENV}/var/www"
}


fixperms () {
    #fix permissions for hgweb? TODO
    __PATH=$1
    sudo chown -R hg:hgweb "$__PATH"
    sudo chmod -R g+rw "$__PATH"
}

# __SRC_GIT_REMOTE_URI_PREFIX   -- default git remote uri prefix
# __SRC_GIT_REMOTE_URI_PREFIX="ssh://git@git.create.wrd.nu"
# __SRC_GIT_REMOTE_NAME         -- name for git remote v
# __SRC_GIT_REMOTE_NAME="create"
# __SRC_HG_REMOTE_URI_PREFIX    -- default hg remote uri prefix
# __SRC_HG_REMOTE_URI_PREFIX="ssh://hg@hg.create.wrd.nu"
# __SRC_HG_REMOTE_NAME          -- name for hg paths
# __SRC_HG_REMOTE_NAME="create"

# __SRC_GIT_GITOLITE_ADMIN=$HOME/gitolite-admin

Git_create_new_repo(){
    ## Create a new hosted repository with gitolite-admin
    #  $1   -- repo [user/]name (e.g. westurner/dotfiles)
    reponame=$1  # (e.g. westurner/dotfiles)
    cd "$__SRC_GIT_GITOLITE_ADMIN_REPO" && \
        ./add_repo.sh "$reponame"
}

Git_pushtocreate() {
    ## push a git repository to local git storage
    #  $1   -- repo [user/]name (e.g. westurner/dotfiles)
    reponame=$1
    repo_uri="${__SRC_GIT_URI}/${reponame}"
    username="westurner"
    here=$(pwd)
    #  $2   -- path of local repo (e.g. ~/wrk/.ve/dotfiles/src/dotfiles)
    repo_local_path=$2
    remote_name=${__SRC_GIT_REMOTE_NAME}

    Git_create_new_repo "$reponame"
    (cd "$repo_local_path" || return;  \
        git remote add "$remote_name" "$repo_uri"  \
            "${__SRC_GIT_URI}/${username}/${reponame}" && \
        git push --all "$remote_name" && \
        cd "$here" || return)
}

Hg_create_new_repo() {
    ## Create a new hosted repository with mercurial-ssh
    reponame=$1
    (cd "$__SRC_HG_SERVER_REMOTE_ADMIN" || return && \
        ./add_repo.sh "$reponame")  # TODO: create add_repo.sh
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
    if [ -d "$path" ]; then
        echo "$path exists. Exiting." >&2
        echo "see: update_repo $1"
        return 0
    fi
    sudo -u hg -i /usr/bin/hg clone "$url" "$path"
    fixperms "$path"
}

Hg() {
    path="${__SRC}/hg/$1"
    path=${path:-'.'}
    shift
    cmd=( "${@}" )
    sudo -H -u hg -i /usr/bin/hg -R "${path}" "${cmd[@]}"

    #if [ $? -eq 0 ]; then
    #    fixperms ${path}
    #fi
}

Hgcheck() {
    path="${__SRC}/$1"
    path=${path:-'.'}
    shift
    Hg "$path" tags
    Hg "$path" id -n
    Hg "$path" id
    Hg "$path" branch

    #TODO: last pulled time
}

Hgupdate() {
    path=$1
    shift
    Hg "$path" update "${@}"
}

Hgstatus() {
    path=$1
    shift
    Hg "$path" update "${@}"
}

Hgpull() {
    path=$1
    shift
    Hg "$path" pull "${@}"
    Hgcheck "$path"
}

Hglog() {
    path=$1
    shift
    Hg -R "$path" log "${@}"
}

Hgcompare () {
    one=$1
    two=$2
    diff -Naur \
        <(hg -R "${one}" log) \
        <(hg -R "${two}" log)
}
