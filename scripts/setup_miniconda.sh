#!/bin/sh
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
    #       
    local verstr="${1}"
    local destdir="${2:-"${DOWNLOAD_DEST}"}"
    local filename=$(miniconda_get_download_filename "${verstr}")
    local download_url="${REPO_URL_PREFIX}/${filename}"
    local dest="${destdir}/${filename}"
    echo "Downloading: ${download_url}" >&2
    echo "Dest: ${dest}" >&2
    (curl -SL "${download_url}" > "${dest}") 1>&2 >&2 \
        && echo "${dest}" \
        && return 0
    return 1
}
function miniconda_install {
    local miniconda_installer_sh="${1}"
    local prefix="${2:-"${HOME}/miniconda"}"
    shift
    shift
    sh ${miniconda_installer_sh} -b -p "${prefix}" ${@}
}
function miniconda_setup__dotfiles_defaults {
    local prefix="${1:-"${__WRK}"}"
    local conda_root__py27="${CONDA_ROOT__py27:-"${prefix}/-conda27"}"
    local conda_root__py34="${CONDA_ROOT__py34:-"${prefix}/-conda34"}"

    local mc2=$(miniconda_download)
    echo $mc2
    local mc3=$(miniconda_download 3)
    echo $mc3

    miniconda_install "${mc2}" "${conda_root__py27}"
    #miniconda_install "${mc2}" "${__WRK}/-ace34"
    miniconda_install "${mc3}" "${conda_root__py34}"

    ##  Then, to create environments with each conda instance:
    #${CONDA_ROOT__py27}/bin/conda env create -n name python   readline pip
    #${CONDA_ROOT__py34}/bin/conda env create -n name python=3 readline pip
}
if [ "${BASH_SOURCE}" == "${0}" ]; then
    echo ${@}
    miniconda_setup__dotfiles_defaults ${@}
fi
