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

DEFAULT_PYVERS=("py27" "py34" "py35" "py36" "py37")

function miniconda_get_download_filename {
    #  miniconda_get_download_filename() -- get a miniconda installer filename
    #    $1 (str) -- versionstr to append (3 or "")
    local conda_env_verstr="${1}"
    local _uname=$(uname)
    local _uname_m=$(uname -m)  # x86, x86_64
    if [ "${_uname}" == "Darwin" ]; then
        local _filename="Miniconda${conda_env_verstr}-latest-MacOSX-${_uname_m}.sh"
    elif [ "${_uname}" == "Linux" ]; then
        local _filename="Miniconda${conda_env_verstr}-latest-Linux-${_uname_m}.sh"
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
    local conda_env_verstr="${1}"
    local destdir="${2:-"${DOWNLOAD_DEST}"}"
    local filename=$(miniconda_get_download_filename "${conda_env_verstr}")
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
    sh "${miniconda_installer_sh}" -b -p "${prefix}" "${@}"
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
    local CONDA_ROOT__py34="${CONDA_ROOT__py34:-"${prefix}/-conda34"}"

    local mc2=$(miniconda_download)
    echo $mc2
    local mc3=$(miniconda_download 3)
    echo $mc3

    local ret=0;
    miniconda_install "${mc2}" "${CONDA_ROOT__py27}"
    ret=$(expr $ret + $?);
    #miniconda_install "${mc2}" "${__WRK}/-ace34"
    miniconda_install "${mc3}" "${CONDA_ROOT__py34}"
    ret=$(expr $ret + $?);
    miniconda_install "${mc3}" "${CONDA_ROOT__py35}"
    ret=$(expr $ret + $?);
    miniconda_install "${mc3}" "${CONDA_ROOT__py36}"
    ret=$(expr $ret + $?);
    miniconda_install "${mc3}" "${CONDA_ROOT__py37}"
    ret=$(expr $ret + $?);
    return $ret;
}


function _setup_dotfiles_condaenvs_defaults {
    local prefix="${1:-"${__WRK}"}"
    #local CONDA_ROOT__py27="${CONDA_ROOT__py27:-"${prefix}/-conda27"}"
    #local CONDA_ENVS__py27="${CONDA_ENVS__py27:-"${prefix}/-ce27"}"
    #local CONDA_ROOT__py34="${CONDA_ROOT__py34:-"${prefix}/-conda34"}"
    #local CONDA_ENVS__py34="${CONDA_ENVS__py34:-"${prefix}/-ce34"}"
    #local CONDA_ROOT__py35="${CONDA_ROOT__py35:-"${prefix}/-conda35"}"
    #local CONDA_ENVS__py35="${CONDA_ENVS__py35:-"${prefix}/-ce35"}"
    #local CONDA_ROOT__py36="${CONDA_ROOT__py36:-"${prefix}/-conda36"}"
    #local CONDA_ENVS__py36="${CONDA_ENVS__py36:-"${prefix}/-ce36"}"
    #local CONDA_ROOT__py37="${CONDA_ROOT__py37:-"${prefix}/-conda37"}"
    #local CONDA_ENVS__py37="${CONDA_ENVS__py37:-"${prefix}/-ce37"}"

    for x in "${DEFAULT_PYVERS[@]}"; do
        #eval('export CONDA_ROOT__${x}')
        #eval('export CONDA_ENVS__${x}')
        # declare -g -x ?
        declare -g -x "CONDA_ROOT__${x}"="${prefix}/-conda${conda_env_verstr}"
        declare -g -x "CONDA_ENVS__${x}"="${prefix}/-ce${conda_env_verstr}"
    done
}

function configure_env_from_pyver {
    local pyver="${1}"
    local prefix="${2:-"${__WRK:-"."}"}"
    if [ -n "${pyver}" ]; then
        echo "ERR: pyver not specified"
        return 3
    fi
    # TODO
    output=$(echo "${pyver}" | grep -E '^py[0-9][0-9]')
    if [ -z "${output}" ]; then
        echo "ERR: pyver must be of the form: pyver[\d\d] (py27-py37)"
        return 3
    fi

    export conda_env_verstr="${pyver:-2:2}" # echo "${pyver}" | sed 's/^py//'
    export conda_env_verdotted="${conda_env_verstr:1:1}.${conda_env_verstr:2:1}"
    export conda_root_varname="CONDA_ROOT__${conda_env_verstr}"
    export conda_envs_varname="CONDA_ENVS__${conda_env_verstr}"  # TODO: _PATH ?
    declare -g -x "${conda_root_varname}"="${prefix}/-conda${conda_env_verstr}"
    declare -g -x "${conda_envs_varname}"="${prefix}/-ce${conda_env_verstr}"

    #export CONDA_ROOT=$(eval 'echo "'"${conda_root_varname}"'"')
    #export CONDA_ENVS_PATH=$(eval 'echo "'"${conda_envs_varname}"'"')
    #export CONDA_ROOT="${!conda_root_varnem}"
    #export CONDA_ENVS_PATH="${!conda_envs_varname}"
    declare -g -x CONDA_ROOT="${prefix}/-conda${conda_env_verstr}"
    declare -g -x CONDA_ENVS_PATH="${prefix}/-ce${conda_env_verstr}"
}

function miniconda_setup__dotfiles_condaenvs {
    local prefix="${1:-"${__WRK}"}"
    # _setup_dotfiles_condaenvs "${prefix}"  # TODO: delete this

    local envname="dotfiles"

    local CONDA_ENV__ROOT_DEFAULTPKGS="conda-env pip readline"

    ## create a condaenv for each python version
    # create a dotfiles condaenv for each python version
    for pyver in "${DEFAULT_PYVERS[@]}"; do
        configure_env_from_pyver "${pyver}" "${prefix}"
        # - CONDA_ROOT
        # - CONDA_ENVS_PATH
        test -d "${CONDA_ROOT}" || \
            "${CONDA_ROOT}/bin/conda" install -y -n root python="${conda_env_verdotted}" "${CONDA_ENV__ROOT_DEFAULTPKGS}"
        test -d "${CONDA_ENVS}/${envname}" || \
            "${CONDA_ROOT}/bin/conda" create -y -n "${envname}"
        miniconda_check_conda_env "${CONDA_ENVS_PATH}/${envname}" 

    done


}

function miniconda_setup_main {
    ## install miniconda and configure condaenvs
    miniconda_setup__dotfiles_minicondas "${@}";
    miniconda_setup__dotfiles_condaenvs "${@}";
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    miniconda_setup_main "${@}"
    exit
fi
