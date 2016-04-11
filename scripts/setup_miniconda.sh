#!/bin/sh -x
##  setup_miniconda.sh

# http://conda.pydata.org/miniconda.html
# http://repo.continuum.io/miniconda/

DOWNLOAD_DEST="."
REPO_URL_PREFIX="http://repo.continuum.io/miniconda/"

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
    local _uname_m=$(uname -m)  # x86, x86_64
    if [ "${_uname}" == "Darwin" ]; then
        local _filename="Miniconda${verstr}-latest-MacOSX-${_uname_m}.sh"
    elif [ "${_uname}" == "Linux" ]; then
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
    local download_url="${REPO_URL_PREFIX}${filename}"
    local dest="${destdir}/${filename}"
    echo "Downloading: ${download_url}" >&2
    echo "Dest: ${dest}" >&2
    if [ -f "${dest}" ]; then
        echo "${dest} exists. skipping" >&2
        return 0
    fi
    (curl -C - -SL "${download_url}" > "${dest}") 1>&2 >&2 \
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
    sh ${miniconda_installer_sh} -b -p "${prefix}" ${@}
}

function miniconda_setup__dotfiles_minicondas {
    #  miniconda_setup__dotfiles_minicondas  -- install CONDA_ROOTs
    #    $1 (str)  -- path for CONDA_ROOTs and CONDA_ENVSs (default: $__WRK)
    #    Returns:
    #      n: sum of Miniconda[3]-latest-*.sh return codes
    local prefix="${1:-"${__WRK}"}"
    local CONDA_ROOT__py27="${CONDA_ROOT__py27:-"${prefix}/-conda27"}"
    local CONDA_ROOT__py34="${CONDA_ROOT__py34:-"${prefix}/-conda34"}"
    local CONDA_ROOT__py35="${CONDA_ROOT__py35:-"${prefix}/-conda35"}"

    local mc2=$(miniconda_download)
    echo $mc2
    local mc3=$(miniconda_download 3)
    echo $mc3

    local ret=0;
    miniconda_install "${mc2}" "${CONDA_ROOT__py27}"
    ret=$(expr $ret+$?);
    miniconda_install "${mc3}" "${CONDA_ROOT__py34}"  # TODO: python=3.4
    ret=$(expr $ret+$?);
    miniconda_install "${mc3}" "${CONDA_ROOT__py35}"  # TODO: python=3.5
    ret=$(expr $ret+$?);
    return $ret;
}

function miniconda_setup__dotfiles_condaenvs {
    local prefix="${1:-"${__WRK}"}"
    local CONDA_ROOT__py27="${CONDA_ROOT__py27:-"${prefix}/-conda27"}"
    local CONDA_ROOT__py34="${CONDA_ROOT__py34:-"${prefix}/-conda34"}"
    local CONDA_ROOT__py35="${CONDA_ROOT__py35:-"${prefix}/-conda35"}"
    local CONDA_ENVS__py27="${CONDA_ENVS__py27:-"${prefix}/-ce27"}"
    local CONDA_ENVS__py34="${CONDA_ENVS__py34:-"${prefix}/-ce34"}"
    local CONDA_ENVS__py35="${CONDA_ENVS__py35:-"${prefix}/-ce35"}"

    ## with one CONDA_ROOT
    # conda create -n dotfiles-27 python=2.7
    # conda create -n dotfiles-34 python=3.4
    # conda create -n dotfiles-35 python=3.5

    ## with multiple CONDA_ROOT / CONDA_ENVS_PATH pairs
    # mkvirtualenv_conda dotfiles 27
    # mkvirtualenv_conda dotfiles 34
    # mkvirtualenv_conda dotfiles 35

    function mkcondaenv_dotfiles {
        ## create environments with each conda instance:
        local CONDA_ROOT="${1}"       # ${CONDA_ROOT__py27}
        local CONDA_ENVS_PATH="${2}"  # ${CONDA_ENVS__py27}"
        local pyver="${3}"            # 2.7, 3.4, 3.5, 3.5.X
        shift;
        shift;
        shift;
        local basepkgs="conda-env pip readline ipython"

        # create a root conda w/ basepkgs installed and python=${pyver}
        "${CONDA_ROOT}/bin/conda" install -y -n root python=${pyver} ${basepkgs}

        # create a conda env named "dotfiles"
        if [ ! -d "${CONDA_ENVS_PATH}/dotfiles" ]; then
            "${CONDA_ROOT}/bin/conda" create -f -y -n dotfiles \
                "python=${pyver}" \
                && mkdir -p "${CONDA_ENVS_PATH}/dotfiles/src"
        fi
    }

    mkcondaenv_dotfiles "${CONDA_ROOT__py27}" "${CONDA_ENVS__py27}" "2.7"
    mkcondaenv_dotfiles "${CONDA_ROOT__py34}" "${CONDA_ENVS__py34}" "3.4"
    mkcondaenv_dotfiles "${CONDA_ROOT__py35}" "${CONDA_ENVS__py35}" "3.5"
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
