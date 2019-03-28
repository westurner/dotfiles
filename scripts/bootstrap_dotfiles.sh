#!/usr/bin/env bash

## westurner/dotfiles bootstrap_dotfiles.sh

# Install and upgrade dotfiles for the current user
#
# Can be run:
# * in a virtualenv (as current user)
# * for --user (as current user)
#
# * Clones into $VIRTUAL_ENV/src/dotfiles
# * Symlinks $VIRTUAL_ENV/src/dotfiles) to ${HOME}/-dotfiles
# * Symlinks from ~/-dotfiles/<...> into ${HOME}
#
# usage::
#
#    bash scripts/bootstrap_dotfiles.sh -h

# set -e   -- exit on error (any nonzero return) [ should be set -e ]
set -e
# set -v   -- print source as run   [dotfiles: debug-on(), debug-off()]
#set -v
# set -x   -- print commands        [dotfiles: debug-on(), debug-off()]
#set -x
# echo $-  -- echo current shell set options [e.g. -e -v -x]

function _setup_bootstrap-dotfiles {
    ## date (file suffix for backup_and_symlink)
    BKUPID=$(date +%Y-%m-%dT%H:%M:%S%z)

    PYTHON="${PYTHON:-"$(which python3 || which python)"}"
    PYVER="${PYVER:-"$( \
        "${PYTHON}" -c \
            'import sys; print("".join(map(str, sys.version_info[:2])))')"}"

    ## Virtualenvwrapper [virtualenvwrapper.sh]
    __WRK="${__WRK:-"${HOME}/-wrk"}"    # ~/-wrk
    WORKON_HOME="${WORKON_HOME:-"${__WRK}/-ve${PYVER}"}" # ~/-wrk/-ve27

    ## Virtualenv + Venv [virtualenv, dotfiles.venv]
    VIRTUAL_ENV_NAME="${VIRTUAL_ENV_NAME:-"dotfiles"}"            #  dotfiles
    VIRTUAL_ENV="${WORKON_HOME}/${VIRTUAL_ENV_NAME}"  # ~/-wrk/-ve27/dotfiles
    _SRC="${VIRTUAL_ENV}/src";          # ~/-wrk/-ve27/dotfiles/src
    _WRD="${_SRC}/${VIRTUAL_ENV_NAME}"  # ~/-wrk/-ve27/dotfiles/src/dotfiles
    __DOTFILES="${_WRD}"                # ~/-wrk/-ve27/dotfiles/src/dotfiles
    # __DOTFILES="${__DOTFILES_SYMLINK}"# ~/-dotfiles

    ## bootstrap_dotfiles.sh
    __DOTFILES_SYMLINK="${HOME}/-dotfiles" # ~/-dotfiles

    ## dotfiles repository  -- https://github.com/westurner/dotfiles
    DOTFILES_REPO_DEST_PATH="${_WRD}"
    DOTFILES_GIT_REPO_URL="https://github.com/westurner/dotfiles"
    #DOTFILES_HG_REPO_URL="https://bitbucket.org/westurner/dotfiles"

    ## dotvim repository    -- https://github.com/westurner/dotvim
    DOTVIM_REPO_DEST_PATH="${_WRD}/etc/vim"
    DOTVIM_GIT_REPO_URL="https://github.com/westurner/dotvim"
    #DOTVIM_HG_REPO_URL="https://bitbucket.org/westurner/dotvim"

    #PIP="${HOME}/.local/bin/pip"
    PIP="pip"
    PIP_INSTALL="${PIP} install"
    PIP_INSTALL_USER="${PIP} install --user"
    SETUP_PY_OPTS=""
    SETUP_PY_OPTS_USER="--user"

    test -d "${WORKON_HOME}" || mkdir -p "${WORKON_HOME}"
    test -d "${_SRC}" || mkdir -p "${_SRC}"
}

function _dotfiles_check_deps {
    # dotfiles_check_deps   -- check for installed commands and functions
    local ERR=''

    function err {
        function _err {
            local err="[ ] ERR: ${@}"$'\r\n'
            echo " ${err}"
            ERR="${ERR}"" ${err}"
        }
        (set +x; _err ${@})
    }

    function is_declared {
        declare -f "${1}" 2>&1 >/dev/null
        return
    }

    (type bash && bash --version) || err "bash";
    (type "${PYTHON}" && "${PYTHON}" --version) || err "cpython[$PYTHON]";
    (type "${PYTHON}" && "${PYTHON}" -m pip --version) || err "cpython[$PYTHON]: -m pip"
    (type pip && pip --version) || err "pip";
    (type virtualenv && virtualenv -p "${PYTHON}" --version) || err "virtualenv";
    #type virtualenvwrapper_initialize
    (type virtualenvwrapper.sh) || err "virtualenvwrapper.sh";
    set +x; source virtualenvwrapper.sh; set -x;
    (is_declared virtualenvwrapper && virtualenvwrapper | grep -v '^$') || err "virtualenvwrapper"
    (is_declared virtualenvwrapper_verify_project_home &&
        virtualenvwrapper_verify_project_home &&
            virtualenvwrapper_verify_workon_home) || err "virtualenvwrapper verify"
    ($PYTHON -c "import setuptools, pkg_resources; print(pkg_resources.resource_filename('setuptools', ''))") || err "setuptools"
    (type git && git --version) || err "git"
    (type git-flow && (git-flow help || true)) || err "git-flow"
    (type git-hf && (git-hf help || true)) || err "git-hf"
    (type hg && hg --version) || err "hg"
    (type dotfiles && $PYTHON $(which dotfiles) --version) || err "dotfiles"
    (type venv.py && $PYTHON $(which venv.py) --version) || err "venv.py"
    #(is_declared venv)
    (type websh.py && $PYTHON $(which websh.py) --version) || err "websh.py"
    (type pyline.py && $PYTHON $(which pyline.py) --version) || err "pyline.py"
    #(is_declared 'dotfiles_status' && dotfiles_status)
    #(is_declared 'conda_status'    && conda_status)
    function dotfiles_bootstrap_status {
        echo "PYTHON=${PYTHON}"
        echo "__VENV=${__VENV}";
        echo "__DOTFILES=${__DOTFILES}";
        echo "__WRK=${__WRK}";
        echo "WORKON_HOME=${WORKON_HOME}";
        echo "CONDA_ENVS_PATH=${CONDA_ENVS_PATH}";
        echo ""
        (test -n "${ERR}" \
            && echo '## ERRORS ##'  \
            && echo -e "${ERR}" )
    }
    (set +x +v; dotfiles_bootstrap_status)
}

function dotfiles_check_deps {
    #see: _dotfiles_check_deps
    (set -x +e; _dotfiles_check_deps)
}

function git_status {
    # git_status()      -- show git rev, branches, remotes
    (git branch -v && \
    git remote -v &&
    git status)
}

function hg_status {
    # hg_status()       -- show hg id, branches, paths
    pwd && \
    hg log \
        --pager never \
        -r $(hg id -i | cut -f1 -d'+') \
        --template '{date|isodate} {date|age} {node|short} {branch} {tags} {bookmarks} {desc|firstline} [{author|user}]\n' && \
    hg id && \
    hg branch -v && \
    hg paths
}

function show_status {
    # show_status()     -- show status for a (.hg or .git) repository
    dir=${1:-$(pwd)}
    if [[ -d "${dir}/.hg" ]]; then
        hg_status
    elif [[ -d "${dir}/.git" ]]; then
        git_status
    else
        echo ".hg or .git repository not found in ${dir}"
    fi
}

function clone_or_update {
    # clone_or_update() -- clone OR pull and update (git [or hg])
    url=$1
    rev=${2:-"master"}  # tip, master
    dest=$3
    echo ""
    if [ -e "${dest}/.git" ]; then
        echo "## pulling from ${url} ---> ${dest}"
        (set -x; cd "${dest}" && \
            git_status && \
            git checkout "$rev" && \
            git pull && \
            git_status);
    elif [ -e "${dest}/.hg" ]; then
        default_path=$(cd "${dest}" && hg paths | grep default)
        echo "## pulling from ${default_path} ---> ${dest}"
        (set -x; cd "${dest}" && echo "cd $(pwd)" && \
            hg_status && \
            hg pull && \
            hg update -r "$rev" && \
            hg_status);
    else
        echo "## cloning from ${url} ---> ${dest}"
        (set -x; git clone --recursive "${url}" "${dest}" && \
            cd "${dest}" && \
            git checkout "$rev" && \
            git_status)
    fi
}


function clone_dotfiles_repo {
    # clone_dotfiles_repo()         -- clone/up dotfiles_repo; create symlinks
    url=${DOTFILES_GIT_REPO_URL}
    rev=${DOTFILES_REPO_REV:-"master"}  # tip, master
    dest=${DOTFILES_REPO_DEST_PATH}
    clone_or_update "${url}" "${rev}" "${dest}"

    # Create a $__DOTFILES symlink
    symlink_home_dotfiles
}


function clone_dotvim_repo {
    # clone_dotvim_repo()           -- clone dotvim to etc/vim
    local url=${DOTVIM_GIT_REPO_URL}
    local rev=${DOTVIM_REPO_REV:-"master"}  # tip, master
    local dest=${DOTVIM_REPO_DEST_PATH}
    clone_or_update "${url}" "${rev}" "${dest}"
}

function install_virtualenvwrapper {
    # install_virtualenvwrapper()   -- pip install virtualenvwrapper
    $PYTHON -m pip install virtualenvwrapper
    #   OR: (manually) apt-get install python-virtualenvwrapper
}

function install_gitflow {
    # install_gitflow()     -- install gitflow git workflow [git flow help]
    #local url="https://github.com/nvie/gitflow"
    local url="https://github.com/westurner/gitflow"
    local rev="master"
    local dest="${__DOTFILES}/src/gitflow"

    clone_or_update "${url}" "${rev}" "${dest}"
    (cd "${dest}"; git submodule init && git submodule update)

    INSTALL_PREFIX="${HOME}/.local/bin" bash "${dest}/contrib/gitflow-installer.sh"
}

function install_hubflow {
    # install_hubflow()     --  Install hubflow git workflow [git hf help]
    #local url="https://github.com/datasift/gitflow"
    local url="https://github.com/westurner/hubflow"
    local rev="master"
    local dest="${__DOTFILES}/src/hubflow"

    clone_or_update "${url}" "${rev}" "${dest}"
    (cd "${dest}"; git submodule init && git submodule update)

    INSTALL_INTO="${HOME}/.local/bin" bash "${dest}/install.sh"
}

function get_md5sums {
    # get_md5sums()     -- get md5sums for a path or directory
    local path=${1}

    if [ -x "/sbin/md5" ]; then
        MD5FUNC="md5"
    else
        MD5FUNC="md5sum"
    fi

    if [[ -d  "$path" ]]; then
        ${MD5FUNC} $(
            find $path -type f \
            | egrep -v '\.git|\.hg/' \
            | cut -f1 -d' ')
    elif [[ -f "$path" ]]; then
        ${MD5FUNC} $path \
            | cut -f1 -d' '
    elif [[ -s "$path" ]]; then
        ${MD5FUNC} $path \
           | cut -f1 -d' '
    fi
}

function __realpath {
    # __realpath()  -- os.path.realpath (~ readlink -f --canonicalize)
    local _path=$1
    python -c "import os,sys;print(os.path.realpath(sys.argv[1]))" "${_path}";
}

function backup_and_symlink {
    # backup_and_symlink()  -- Create symlink at $dest, pointing to $src
    # Args:
    #  filename: basename of file
    #  dest: location of symlink
    #  src: where symlink will point
    #  BKUPID: file suffix ( *.bkp.* ) (date)
    local filename=${1}
    local dest=${2:-"${HOME}/${filename}"}
    local src=${3:-"${__DOTFILES_SYMLINK}/etc/${filename}"}

    local bkp="${dest}.bkp.${BKUPID}"
    local dest_md5=''
    local src_md5=''
    #echo "# $filename $dest $src"
    if (test -a "${dest}" || test -h "${dest}"); then
        if [[ -s "${dest}" ]]; then
            dest_md5=$(__realpath $dest)
            src_md5=$(__realpath $src)
        else
            dest_md5=$(get_md5sums $dest)
            src_md5=$(get_md5sums $src)
        fi
        if [ -z "$src_md5" ] && [ -z "$dest_md5" ]; then
            echo "#  $filename $dest $src"
            echo "#! empy md5s"
        fi
        if [ "$src_md5" != "$dest_md5" ]; then
            echo "$dest"
            echo "$dest_md5"
            echo "$src"
            echo "$src_md5"

            #diff -Naur $src $dest | tee dotfiles.backup.${BKUPID}.diff

            mv "${dest}" "${bkp}"
            echo "mv ${dest} ${bkp}"
            ln -s "${src}" "${dest}"
            echo "ln -s ${src} ${dest}"
        else
            # if either src_md5 or dest_md5 are null
            if [ -z "$src_md5" ] || [ -z "$dest_md5" ]; then
                echo "# $src $dest"
                if [ -h "${dest}" ]; then
                    local actual=$(__realpath ${dest})
                    if [ "$actual" != "$src" ]; then
                        mv ${dest} ${bkp}
                        echo "mv ${dest} ${bkp}"
                        ln -s "${src}" "${dest}"
                        echo "ln -s ${src} ${dest}"
                    fi
                else
                    #echo "skip: " $src "->" $dest
                    true
                fi
            else
                echo "## ln -s '${src}' '${dest}'"
                #echo "... $src_md5 == $dest_md5"
            fi
        fi
    else
        ln -s "${src}" "${dest}"
        echo "ln -s ${src} ${dest}"
    fi

}

## /begin symlinks

function symlink_home_dotfiles {
    backup_and_symlink "" "${__DOTFILES_SYMLINK}" "${_WRD}"
}

function symlink_etc_vim {
    backup_and_symlink vim/vimrc "${HOME}/.vimrc"
    backup_and_symlink vim "${HOME}/.vim"
}

function symlink_bashrc {
    backup_and_symlink .bashrc
}

function symlink_zshrc {
    backup_and_symlink .zshrc
}

function symlink_hgrc {
    backup_and_symlink .hgrc
    backup_and_symlink .hgignore_global
    #TODO: set name in ~/.hgrc
}

function symlink_gitconfig {
    backup_and_symlink .gitconfig
    backup_and_symlink .gitignore_global
    #TODO: set name in ~/.gitconfig
}

function symlink_inputrc {
    backup_and_symlink .inputrc
}

function symlink_htoprc {
    backup_and_symlink .htoprc
}

function symlink_mutt {
    backup_and_symlink mutt "${HOME}/.mutt"
}

function symlink_gtk {
    backup_and_symlink .gtkrc
    backup_and_symlink .gtkrc-2.0
    mkdir -p "${HOME}/.config"
    backup_and_symlink .config/gtk-3.0
}

function symlink_mimeapps {
    mkdir -p "${HOME}/.local/share/applications"
    backup_and_symlink mimeapps.list \
        "${HOME}/.local/share/applications/mimeapps.list"
}

function symlink_i3 {
    backup_and_symlink i3 "${HOME}/.i3"
}

function symlink_xinitrc_screensaver {
    backup_and_symlink .xinitrc
}

function symlink_xmodmap {
    backup_and_symlink .Xmodmap
}

function symlink_python {
    backup_and_symlink .pythonrc
    backup_and_symlink .pdbrc
    backup_and_symlink .pydistutils.cfg

    #test -d "${HOME}/.pip" || mkdir -p "${HOME}/.pip"
    #backup_and_symlink .pip/pip.conf
    backup_and_symlink pip  "${HOME}/.pip"

    backup_and_symlink .noserc
}

function symlink_virtualenvwrapper {
    backup_and_symlink virtualenvwrapper
}

function symlink_venv {
    local ipyprofile="${1:-"${HOME}/.ipython/profile_default"}"
    mkdir -p "${ipyprofile}/startup"
    backup_and_symlink "" "${ipyprofile}/startup/20-venv_ipymagics.py" \
        "${__DOTFILES_SYMLINK}/scripts/venv_ipymagics.py"
    backup_and_symlink "" "${ipyprofile}/ipython_config.py" \
        "${__DOTFILES_SYMLINK}/scripts/venv_ipyconfig.py"
    #backup_and_symlink "${__DOTFILES_SYMLINK}/scripts/venv_ipymagics.py" \
    #    "${ipyprofile}/startup/20-venv_ipymagics.py"
    #backup_and_symlink ipython/ipython_config.py \
    #    "${ipyprofile}/ipython_config.py"
}

function symlink_conda {
    local condarc="${HOME}/.condarc"
    backup_and_symlink "" "${condarc}" \
        "${__DOTFILES_SYMLINK}/etc/.condarc"
}

function symlink_jupyter {
    backup_and_symlink .jupyter
}

function symlink_ruby {
    backup_and_symlink .gemrc
}


## end /symlinks

function dotfiles_symlink_all {
    ## Create symlinks
    symlink_home_dotfiles

    symlink_inputrc
    symlink_bashrc
    symlink_zshrc
    symlink_htoprc
    symlink_etc_vim

    symlink_python
    symlink_virtualenvwrapper
    symlink_venv

    symlink_conda
    symlink_jupyter

    symlink_ruby

    symlink_gtk
    symlink_i3
    symlink_xinitrc_screensaver
    symlink_xmodmap

    # {{ full_name }}
    symlink_gitconfig
    symlink_hgrc
    symlink_mutt

}

function create_virtualenv {
    ## create a new virtualenv
    local VENVWRAPPER="$(which virtualenvwrapper.sh)"
    local VIRTUAL_ENV_NAME="${VIRTUAL_ENV_NAME}"
    local VIRTUAL_ENV="$VIRTUAL_ENV"
    if [[ -x "${VENVWRAPPER}" ]]; then
        dotfiles_setup_virtualenvwrapper
        source "${VENVWRAPPER}"
        mkvirtualenv "${VIRTUAL_ENV_NAME}"
        workon "${VIRTUAL_ENV_NAME}"
    else 
        virtualenv -p "${PYTHON}" "${VIRTUAL_ENV}"
        source "${VIRTUAL_ENV}/bin/activate"
    fi
}

function deactivate_virtualenv {
    ## deactivate any current VIRTUAL_ENV in this $SHELL
    type 'virtualenv_deactivate' 2>/dev/null && virtualenv_deactivate || true
    type 'virtualenv_deactivate' 2>/dev/null && virtualenv_deactivate || true
    unset VIRTUAL_ENV
}

function dotfiles_install_bootstrap {
    ## pip install --upgrade --editable and create symlinks

    #TODO
    if [ -n "${_VIRTUAL_ENV}" ] && [ -z "$SETUP_PY_OPTS" ] ; then
        source "${_VIRTUAL_ENV}/bin/activate"
    else
        deactivate_virtualenv
    fi
    ${PIP_INSTALL} --upgrade --editable "${_WRD}"
    cd "${_WRD}" && \
        dotfiles_symlink_all
}

function dotfiles_install_bootstrap_user {
    ## pip install --user --editable and create symlinks
    function _dotfiles_install_bootstrap_user {
        ${PIP_INSTALL_USER} --upgrade --editable "${_WRD}"
        cd "${_WRD}" && \
            dotfiles_symlink_all
    }
    (deactivate ; _dotfiles_install_bootstrap_user)
}

#function dotfiles_install_bootstrap_pip {
     # Upgrade system pip
     #pip_bootstrap_pip
     ###pip_upgrade_local_pip
     #pip_upgrade_system_pip
     #pip_upgrade_system_setuptools
#}

function dotfiles_install_boostrap_env {
    ## Setup system dependencies

    # dotfiles_install_bootstrap_pip

    function _dotfiles_install_bootstrap_env {
        # Install virtualenv and virtualenvwrapper into ~/.local/bin/
        pip_install_virtualenv
        pip_install_virtualenvwrapper

        dotfiles_setup_virtualenvwrapper
    }
    (deactivate_virtualenv; _dotfiles_install_bootstrap_env)
}

function dotfiles_upgrade {
    ## clone and/or pull and update dotfiles and dotvim; then install dotfiles

    # Clone the dotfiles repository
    clone_dotfiles_repo

    # Clone the dotvim repository
    clone_dotvim_repo

    # Install dotfiles into ${HOME}
    dotfiles_install_bootstrap

    # Install dotfiles into ~/.local/
    #(dotfiles_install_bootstrap_user)

}

function dotfiles_install {
    ## Install the dotfiles

    # install and configure virtualenv and virtualenvwrapper
    dotfiles_install_boostrap_env

    if [ -r "$SETUP_PY_OPTS" ]; then
        # create or activate $_VIRTUAL_ENV
        create_virtualenv #  ${VIRTUAL_ENV_NAME}
    fi

    ## Clone and/or pull and update dotfiles and dotvim; then install dotfiles
    dotfiles_upgrade

    # Symlink dotfiles into ${HOME}
    dotfiles_symlink_all
}

function dotfiles_install_requirements {
    ## Install all pip requirements
    ${PIP_INSTALL} -r "${DOTFILES_REPO_DEST_PATH}/requirements-all.txt"
}


function pip_upgrade_system_setuptools {
    ## Upgrade setuptools with pip
    sudo pip install --upgrade setuptools
}

function pip_upgrade_system_pip {
    ## Upgrade system pip with pip (careful)
    sudo pip install --upgrade pip
}

function pip_upgrade_local_pip {
    ## Upgrade pip with pip (does not work)
    ${PIP_INSTALL_USER} --force-reinstall --upgrade pip  # seems to error out
}

function pip_bootstrap_pip {
    ## Install pip (and setuptools)
    wget --continue 'https://bootstrap.pypa.io/get-pip.py'
    python get-pip.py $SETUP_PY_OPTS
}

function bootstrap_setuptools {
    ## Install setuptools
    wget --continue 'https://bootstrap.pypa.io/ez_setup.py'
    python ez_setup.py $SETUP_PY_OPTS
}


function pip_install_virtualenv {
    ## Install virtualenv
    ${PIP_INSTALL} --upgrade --no-use-wheel virtualenv
}

function pip_install_virtualenvwrapper {
    ## Install virtualenvwrapper
    ${PIP_INSTALL} --upgrade --no-use-wheel virtualenvwrapper
}


function dotfiles_setup_virtualenvwrapper {
    ## source virtualenvwrapper[_lazy].sh from $PATH

    VIRTUALENVWRAPPER_SH_NAME="virtualenvwrapper.sh"
    #VIRTUALENVWRAPPER_SH_NAME="virtualenvwrapper_lazy.sh

    VIRTUALENVWRAPPER_SH=$(which ${VIRTUALENVWRAPPER_SH_NAME})
    #VIRTUALENVWRAPPER_SH="${HOME}/.local/bin/${VIRTUALENVWRAPPER_SH_NAME}"

    if [[ -f "${VIRTUALENVWRAPPER_SH}" ]]; then
        source "${VIRTUALENVWRAPPER_SH}"
    else
        echo "404: VIRTUALENVWRAPPER_SH=${VIRTUALENVWRAPPER_SH}"
    fi
}


function _dotfiles_bootstrap_usage {
    ## print usage information
    echo "## dotfiles_bootstrap -- a shell wrapper for cloning and installing"
    local progname="$(basename "${0}")"
    echo "## Usage: ${progname}  <actions> <options>"
    echo "#"
    echo "## Actions"
    echo "#  -I   --  Install the dotfiles (implies -S)";
    echo "#  -S   --  Install dotfiles symlinks";
    echo "#  -U   --  Update and Upgrade the dotfiles (implies -S)";
    echo "#  -R   --  pip install -r requirements-all.txt"
    echo "#  -G   --  install Gitflow and hubflow"
    echo "#  -C   --  check for installed components"
    echo "#  -h   --  print this help message"
    echo "#"
    echo "## Options"
    echo "#  -u   --  pip install --user (modified for other actions)"
    echo "#  -d   --  show debugging info (set -x)"
    exit;
}

function dotfiles_bootstrap_usage {
    (set +x +v; _dotfiles_bootstrap_usage)
}

function dotfiles_bootstrap_parse_arg {
    local arg="${1}"
    if [ -z "${arg}" ]; then
        return
    fi
    case "${arg}" in
        u|-u|user|--user)
            export u=${OPTARG};
            export PIP_INSTALL="${PIP_INSTALL_USER}"
            export SETUP_PY_OPTS="${SETUP_PY_OPTS_USER}"
            ;;
        I|-I|install|--install|installdotfiles)
            export I=${OPTARG};
            export DO_INSTALL="true"
            export DO_SYMLINK="true"
            ;;
        S|-S|symlink|--symlink)
            export S=${OPTARG};
            export DO_SYMLINK="true"
            ;;
        U|-U|upgrade|--upgrade)
            export U=${OPTARG};
            export DO_UPGRADE="true"
            export DO_SYMLINK="true"
            ;;
        R|-R|piprequirements|piprequires|pipreqs|pipreq)
            export R=${OPTARG};
            export DO_PIP_REQUIREMENTS="true"
            ;;
        G|-G|gitflow|--gitflow|hubflow|--hubflow)
            export G=${OPTARG};
            export DO_GIT_REQUIREMENTS="true"
            ;;
        C|-C|check|--check)
            export C=${OPTARG};
            export DO_CHECK="true"
            ;;
        d|-d|debug|--debug)
            export d=${OPTARG};
            DEBUG_BOOTSTRAP="true"
            ;;
        h|-h|help|--help)
            export DO_HELP="true"
            ;;
    esac
}

function dotfiles_bootstrap_main {
    ## parse opts, set flags, and run commands
    #function _dotfiles_bootstrap_parse_args_getopts {
    #    while getopts "uISURGCdh" o; do
    #        dotfiles_bootstrap_parse_arg "${o}"
    #    done
    #}
    #_dotfiles_bootstrap_parse_args_getopts || true
    for arg in ${@}; do
        dotfiles_bootstrap_parse_arg "${arg}"
    done

    if [ -n "$DEBUG_BOOTSTRAP" ]; then
        set -x -v
    fi

    DO__ANY="${DO_INSTALL}${DO_UPGRADE}${DO_SYMLINK}${DO_PIP_REQUIREMENTS}${DO_GIT_REQUIREMENTS}"
    if [ -n "${DO_HELP}" ] || [ -z "${DO__ANY}${DO_CHECK}" ]; then
        dotfiles_bootstrap_usage
        return 1
    fi

    if [ -n "$DO_CHECK" ]; then
        dotfiles_check_deps;
    fi
    if [ -n "$DO_INSTALL" ]; then
        dotfiles_install;
    fi
    if [ -n "$DO_UPGRADE" ]; then
        dotfiles_upgrade;
    fi
    if [ -n "$DO_SYMLINK" ]; then
        dotfiles_symlink_all;
    fi
    if [ -n "$DO_PIP_REQUIREMENTS" ]; then
        dotfiles_install_requirements
    fi
    if [ -n "$DO_GIT_REQUIREMENTS" ]; then
        install_gitflow;
        install_hubflow;
    fi
    if [ -n "$DO_CHECK" ] && [ -n "$DO__ANY" ]; then
        dotfiles_check_deps
    fi
}

## execute main if called as a script
## (e.g. not with `source`)
if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    _setup_bootstrap-dotfiles
    dotfiles_bootstrap_main ${@}
    exit
fi

