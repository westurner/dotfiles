#!/bin/sh
## git-subrepo2submodule.sh -- git submodule add <remote.branch.url> <./path>
#
#  :author: Wes Turner <wes@wrd.nu>
#  :license: BSD 3-Clause

function git_subrepo2submodule_help {
    local _cmd="${0}"
    echo "${_cmd} <subrepopath> [repopath] [branch name (default: master)]" 
    echo "   Convert a cloned repository to a git submodule"
    echo ""
    echo " $ ${_cmd} ./salt/formulas/salt-formula"
    echo " $ ${_cmd} ./salt/formulas/salt-formula \$(pwd) master"
    echo ""
}

function git_subrepo2submodule {
    ## git_subrepo2submodule() -- git submodule add <remote.[branch].url> <subrepo_path>
    #    $1 (_subrepopath): path to a guest cloned git repo (within _repopath)
    #    $2 (_repopath): path the host git repo (d: ".")
    #    $3 (_master_branchname): primary tracked remote branch (d: "master")
    (set -x -v; _git_subrepo2submodule ${@})
    return
}

function _git_subrepo2submodule {
    ## _git_subrepo2submodule() -- git submodule add <remote.[branch].url> <subrepo_path>
    #    $1 (_subrepopath): path to a guest cloned git repo (within _repopath)
    #    $2 (_repopath): path the host git repo (d: ".")
    #    $3 (_master_branchname): primary tracked remote branch (d: "master")
    _subrepopath="${1}"
    _repopath="${2:-"."}"
    _master_branchname="${3:-"master"}"
    _master_remote_branchname=$(git -C "${_subrepopath}" config \
        --get "branch.${_master_branchname}.remote")
    _master_remote_url=$(git -C "${_subrepopath}" config \
        --get "remote.${_master_remote_branchname}.url")
    git -C "${_repopath}" submodule add \
        "${_master_remote_url}" "${_subrepopath}"
    return
}

function git_subrepo2submodule_main {
    ## call git_subrepo2submodule ${@} or print usage/help
    if [ -z "${@}" ]; then
        echo "Err: you must specify arguments"
        echo ""
        git_subrepo2submodule_help
        return 2
    fi
    git_subrepo2submodule ${@}
    return
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    git_subrepo2submodule_main "${@}"
    exit
fi
