#!/bin/sh -x
##  setup_miniconda.sh

# http://conda.pydata.org/miniconda.html
# http://repo.continuum.io/miniconda/

DOWNLOAD_DEST="."
REPO_URL_PREFIX="https://repo.continuum.io/miniconda"

linux_x86=Miniconda3-latest-Linux-x86.sh
linux_x86_64=Miniconda3-latest-Linux-x86_64.sh
osx_x86_64=Miniconda3-latest-MacOSX-x86_64.sh
#win_x86=Miniconda3-latest-Windows-x86.exe
#win_x86_64=Miniconda3-latest-Windows-x86_64.exe


function miniconda_get_download_filename {
    #  miniconda_get_download_filename() -- get a miniconda installer filename
    #    $1 (str) -- versionstr to append (3 or "")
    local verstr="${1}"
    local _uname=$(uname)
    local _uname_m=$(uname -m)  # x86_64, i686
    if [ "${_uname}" == "Darwin" ]; then
        local _filename="Miniconda${verstr}-latest-MacOSX-${_uname_m}.sh"
    elif [ "${_uname}" == "Linux" ]; then
        if [ "${_uname_m}" == "i686" ]; then
            _uname_m="x86"
        fi
        local _filename="Miniconda${verstr}-latest-Linux-${_uname_m}.sh"
    else
        echo "Err: uname '${_uname}' not implemented" >&2
        return 2
    fi
    echo "${_filename}"
    return 0
}
function miniconda_download {
    #  miniconda_download()  -- download the latest miniconda installer
    #    $1 (str)  -- versionstr to append (3 or "")
    #    $2 (str)  -- destination directory in which to store downloaded files
    #    Returns:
    #      1:  -- download err
    #      0:  -- download OK
    local verstr="${1}"
    local destdir="${2:-"${DOWNLOAD_DEST}"}"
    local filename=$(miniconda_get_download_filename "${verstr}")
    local download_url="${REPO_URL_PREFIX}/${filename}"
    local dest="${destdir}/${filename}"
    echo "Downloading: ${download_url}" >&2
    echo "Dest: ${dest}" >&2

    # TODO:
    if [ -n "${SKIP_DOWNLOAD}" ]; then
        echo "${dest}";
        return 1
    fi
    (curl -SL "${download_url}" > "${dest}") 1>&2 >&2 \
        && echo "${dest}" \
        && return 0
    return 1
}

function miniconda_install {
    #  miniconda_install()   -- run the miniconda installer for the
    #    $1 (str)  -- path to miniconda installer .sh
    #    $2 (str)  -- install dest (default: ~/miniconda; __WRK/-conda[27|34])
    #    Returns:
    #      n: Miniconda[3]-latest-*.sh return code
    local miniconda_installer_sh="${1}"
    local prefix="${2:-"${HOME}/miniconda"}"
    shift
    shift
    sh ${miniconda_installer_sh} -b -p "${prefix}" "${@}"
}


###


function _miniconda_check_conda_env {
    #  miniconda_check_conda_env       -- check python and conda in a conda env
    #    $1 (str)  -- path of a conda env
    #       "./here"
    #       "${CONDA_ENVS_PATH}/envname"
    local env="${1}"
    if [ -z "${env}" ]; then
        return 2
    fi
    test -d "${env}"

    local python="${env}/bin/python"
    test -x "${python}"
    "${python}" --version
    "${python}" -m site

    local conda="${env}/bin/conda"
    test -x "${conda}"
    "${conda}" --version
    "${conda}" info

    local pip="${env}/bin/pip"
    test -x "${pip}"
    "${pip}" --version
    #"${pip}" show pip
}
function miniconda_check_conda_env {
    (set -x; _miniconda_check_conda_env "${@}")
}


function miniconda_setup__dotfiles_minicondas {
    #  miniconda_setup__dotfiles_minicondas  -- install CONDA_ROOTs
    #    $1 (str)  -- path for CONDA_ROOTs and CONDA_ENVSs (default: $__WRK)
    #    Returns:
    #      n: sum of Miniconda[3]-latest-*.sh return codes
    local prefix="${1:-"${__WRK}"}"

    local CONDA_ROOT__py27="${CONDA_ROOT__py27:-"${prefix}/-conda27"}"
    local CONDA_ROOT__py37="${CONDA_ROOT__py37:-"${prefix}/-conda37"}"
    local CONDA_ROOT__py38="${CONDA_ROOT__py38:-"${prefix}/-conda38"}"

    local mc2=$(miniconda_download 2)
    echo $mc2
    local mc3=$(miniconda_download 3)
    echo $mc3

    local ret=0;
    if [ -n "${CONDA_ROOT__py27}" ]; then
        miniconda_install "${mc2}" "${CONDA_ROOT__py27}"
        ret=$(expr $ret + $?);
    fi
    if [ -n "${CONDA_ROOT__py34}" ]; then
        miniconda_install "${mc3}" "${CONDA_ROOT__py34}"
        ret=$(expr $ret + $?);
    fi
    if [ -n "${CONDA_ROOT__py35}" ]; then
        miniconda_install "${mc3}" "${CONDA_ROOT__py35}"
        ret=$(expr $ret + $?);
    fi
    if [ -n "${CONDA_ROOT__py36}" ]; then
        miniconda_install "${mc3}" "${CONDA_ROOT__py36}"
        ret=$(expr $ret + $?);
    fi
    if [ -n "${CONDA_ROOT__py37}" ]; then
        miniconda_install "${mc3}" "${CONDA_ROOT__py37}"
        ret=$(expr $ret + $?);
    fi
    if [ -n "${CONDA_ROOT__py38}" ]; then
        miniconda_install "${mc3}" "${CONDA_ROOT__py38}"
        ret=$(expr $ret + $?);
    fi
    return $ret;
}

function miniconda_setup__dotfiles_env {
    declare -g CONDA_ROOT__py27="${CONDA_ROOT__py27:-"${prefix}/-conda27"}"
    declare -g CONDA_ENVS__py27="${CONDA_ENVS__py27:-"${prefix}/-ce27"}"
    declare -g CONDA_ROOT__py34="${CONDA_ROOT__py34:-"${prefix}/-conda34"}"
    declare -g CONDA_ENVS__py34="${CONDA_ENVS__py34:-"${prefix}/-ce34"}"
    declare -g CONDA_ROOT__py35="${CONDA_ROOT__py35:-"${prefix}/-conda35"}"
    declare -g CONDA_ENVS__py35="${CONDA_ENVS__py35:-"${prefix}/-ce35"}"
    declare -g CONDA_ROOT__py36="${CONDA_ROOT__py36:-"${prefix}/-conda36"}"
    declare -g CONDA_ENVS__py36="${CONDA_ENVS__py36:-"${prefix}/-ce36"}"
    declare -g CONDA_ROOT__py37="${CONDA_ROOT__py37:-"${prefix}/-conda37"}"
    declare -g CONDA_ENVS__py37="${CONDA_ENVS__py37:-"${prefix}/-ce37"}"
    declare -g CONDA_ROOT__py38="${CONDA_ROOT__py38:-"${prefix}/-conda38"}"
    declare -g CONDA_ENVS__py38="${CONDA_ENVS__py38:-"${prefix}/-ce38"}"
}

function miniconda_setup__dotfiles_condaenvs {
    local prefix="${1:-"${__WRK}"}"
    miniconda_setup__dotfiles_env

    local envname="dotfiles"
    # local baseenvname="root"
    local baseenvname="base"

    ## create a condaenv for each python version
    # create a dotfiles condaenv for each python version
    CONDA_ROOT=$CONDA_ROOT__py27
    CONDA_ENVS_PATH=$CONDA_ENVS__py27
    "${CONDA_ROOT__py27}/bin/conda" install -y -n "${baseenvname}" conda-env python=2.7 pip readline
    test -d "${CONDA_ENVS__py27}/${envname}" || "${CONDA_ROOT__py27}/bin/conda" create -y -n "${envname}"
    miniconda_check_conda_env "${CONDA_ENVS__py27}/${envname}"

    CONDA_ROOT=$CONDA_ROOT__py34
    CONDA_ENVS_PATH=$CONDA_ENVS__py34
    "${CONDA_ROOT__py34}/bin/conda" install -y -n "${baseenvname}" conda-env python=3.4 pip readline
    test -d "${CONDA_ENVS__py34}/${envname}" || "${CONDA_ROOT__py34}/bin/conda" create -y -n "${envname}"
    miniconda_check_conda_env "${CONDA_ENVS__py34}/${envname}"

    CONDA_ROOT=$CONDA_ROOT__py35
    CONDA_ENVS_PATH=$CONDA_ENVS__py35
    "${CONDA_ROOT__py35}/bin/conda" install -y -n "${baseenvname}" conda-env python=3.5 pip readline
    test -d "${CONDA_ENVS__py35}/${envname}" || "${CONDA_ROOT__py35}/bin/conda" create -y -n "${envname}"
    miniconda_check_conda_env "${CONDA_ENVS__py35}/${envname}"

    CONDA_ROOT=$CONDA_ROOT__py36
    CONDA_ENVS_PATH=$CONDA_ENVS__py36
    "${CONDA_ROOT__py36}/bin/conda" install -y -n "${baseenvname}" conda-env python=3.6 pip readline
    test -d "${CONDA_ENVS__py36}/${envname}" || "${CONDA_ROOT__py36}/bin/conda" create -y -n "${envname}"
    miniconda_check_conda_env "${CONDA_ENVS__py36}/${envname}"

    CONDA_ROOT=$CONDA_ROOT__py37
    CONDA_ENVS_PATH=$CONDA_ENVS__py37
    "${CONDA_ROOT__py37}/bin/conda" install -y -n "${baseenvname}" conda-env python=3.7 pip readline
    test -d "${CONDA_ENVS__py37}/${envname}" || "${CONDA_ROOT__py37}/bin/conda" create -y -n "${envname}"
    miniconda_check_conda_env "${CONDA_ENVS__py37}/${envname}"

    CONDA_ROOT=$CONDA_ROOT__py38
    CONDA_ENVS_PATH=$CONDA_ENVS__py38
    "${CONDA_ROOT__py38}/bin/conda" install -y -n "${baseenvname}" conda-env python=3.8 pip readline
    test -d "${CONDA_ENVS__py38}/${envname}" || "${CONDA_ROOT__py37}/bin/conda" create -y -n "${envname}"
    miniconda_check_conda_env "${CONDA_ENVS__py38}/${envname}"
}

function _miniconda_setup_main {
    ## install miniconda and configure condaenvs
    miniconda_setup__dotfiles_env
    miniconda_setup__dotfiles_minicondas "${@}";
    miniconda_setup__dotfiles_condaenvs "${@}";
}
function miniconda_setup_main {
    (set -x; _miniconda_setup_main "${@}")
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    miniconda_setup_main "${@}"
    exit
fi
