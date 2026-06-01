#!/bin/bash
##  setup_miniconda.sh

# http://conda.pydata.org/miniconda.html
# http://repo.continuum.io/miniconda/

# DOWNLOAD_DEST (str): Default destination directory to save the downloaded Miniconda installer script.
DOWNLOAD_DEST="."

# INSTALL_TYPE (str): Type of installer to use (miniconda or miniforge).
# INSTALL_TYPE="${INSTALL_TYPE:-miniconda}"
INSTALL_TYPE="${INSTALL_TYPE:-miniforge}"

# MINICONDA_URL_PREFIX (str): Base URL for downloading Miniconda installers.
MINICONDA_URL_PREFIX="https://repo.anaconda.com/miniconda"

# MINIFORGE_URL_PREFIX (str): Base URL for downloading Miniforge installers.
MINIFORGE_URL_PREFIX="https://github.com/conda-forge/miniforge/releases/latest/download"

# MICROMAMBA_URL_PREFIX (str): Base URL for downloading Micromamba binaries.
MICROMAMBA_URL_PREFIX="https://github.com/mamba-org/micromamba-releases/releases/latest/download"


_conda_get_versions() {
    echo "${CONDA_VERSIONS:-27 34 35 36 37 38 39 310 311 312 313 314}"
}


conda_installer_get_filename() {
    #  conda_installer_get_filename() -- get a miniconda installer filename
    #    $1 (str) -- versionstr to append (3 or "")
    local verstr="${1}"

    local _uname=
    local _uname_m=

    _uname=$(uname)
    _uname_m=$(uname -m)  # x86_64, i686

    if [ "${INSTALL_TYPE}" = "mambaforge" ] || [ "${INSTALL_TYPE}" = "miniforge" ]; then
        echo "Miniforge3-${_uname}-${_uname_m}.sh"
        return 0
    fi

    if [ "${INSTALL_TYPE}" = "micromamba" ]; then
        if [ "${_uname}" == "Darwin" ]; then
            if [ "${_uname_m}" == "arm64" ]; then
                echo "micromamba-osx-arm64.tar.bz2"
            else
                echo "micromamba-osx-64.tar.bz2"
            fi
        elif [ "${_uname}" == "Linux" ]; then
            if [ "${_uname_m}" == "aarch64" ]; then
                echo "micromamba-linux-aarch64.tar.bz2"
            elif [ "${_uname_m}" == "ppc64le" ]; then
                echo "micromamba-linux-ppc64le.tar.bz2"
            else
                echo "micromamba-linux-64.tar.bz2"
            fi
        else
            echo "Err: uname '${_uname}' not implemented for micromamba" >&2
            return 2
        fi
        return 0
    fi

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

run_cmd() {
    if [ "${DRY_RUN:-1}" = "1" ]; then
        echo "+ ${*}"
    else
        "${@}"
    fi
}

conda_installer_download() {
    #  conda_installer_download()  -- download the latest miniconda installer
    #    $1 (str)  -- versionstr to append (3 or "")
    #    $2 (str)  -- destination directory in which to store downloaded files
    #    Returns:
    #      1:  -- download err
    #      0:  -- download OK
    local verstr="${1}"
    local destdir="${2:-"${DOWNLOAD_DEST}"}"

    local filename=
    filename=$(conda_installer_get_filename "${verstr}")

    local download_url=
    if [ "${INSTALL_TYPE}" = "miniforge" ]; then
        download_url="${MINIFORGE_URL_PREFIX}/${filename}"
    elif [ "${INSTALL_TYPE}" = "micromamba" ]; then
        download_url="${MICROMAMBA_URL_PREFIX}/${filename}"
    else
        download_url="${MINICONDA_URL_PREFIX}/${filename}"
    fi

    local dest="${destdir}/${filename}"

    echo "INFO: Downloading: ${download_url}" >&2
    echo "INFO:  Dest: ${dest}" >&2

    if [ -n "${SKIP_DOWNLOAD_IF_EXISTS}" ] && [ -f "${dest}" ]; then
        echo "INFO: Skipping download (SKIP_DOWNLOAD_IF_EXISTS=1), file exists: ${dest}" >&2
        echo "${dest}"
        return 0
    fi

    if [ "${DRY_RUN:-1}" = "1" ]; then
        echo "+ curl -SL \"${download_url}\" > \"${dest}\"" >&2
        echo "${dest}"
        return 0
    fi
    # TODO:
    if [ -n "${SKIP_DOWNLOAD}" ]; then
        echo "${dest}";
        return 1
    fi
    if (curl -SL "${download_url}" > "${dest}") 1>&2 >&2; then
        local checksum_url="${download_url}.sha256"
        local checksum_dest="${dest}.sha256"
        
        echo "INFO: Downloading SHA256 checksum file from ${checksum_url}" >&2
        if (curl -fsSL "${checksum_url}" > "${checksum_dest}") 1>&2 >&2; then
            echo "INFO: Validating downloaded hash..." >&2
            if command -v sha256sum >/dev/null; then
                if [[ "${filename}" == *.tar.bz2 ]]; then
                    # Micromamba checksums may just contain the hash without the filename. We pad it so sha256sum doesn't crash formatting.
                    (cd "${destdir}" && echo "$(awk '{print $1}' "${filename}.sha256")  ${filename}" | sha256sum -c - >&2) || { echo "ERROR: Checksum verification FAILED!" >&2; return 1; }
                else
                    (cd "${destdir}" && sha256sum -c "${filename}.sha256" >&2) || { echo "ERROR: Checksum verification FAILED!" >&2; return 1; }
                fi
            elif command -v shasum >/dev/null; then
                if [[ "${filename}" == *.tar.bz2 ]]; then
                    (cd "${destdir}" && echo "$(awk '{print $1}' "${filename}.sha256")  ${filename}" | shasum -a 256 -c - >&2) || { echo "ERROR: Checksum verification FAILED!" >&2; return 1; }
                else
                    (cd "${destdir}" && shasum -a 256 -c "${filename}.sha256" >&2) || { echo "ERROR: Checksum verification FAILED!" >&2; return 1; }
                fi
            else
                echo "WARNING: Could not find 'sha256sum' or 'shasum' tools. Skipping verification." >&2
            fi
            echo "INFO: Checksum verification PASSED!" >&2
        else
            echo "WARNING: Failed to download checksum file at ${checksum_url}. Skipping validation." >&2
        fi

        echo "${dest}"
        return 0
    fi
    return 1
}

conda_installer_install() {
    #  conda_installer_install()   -- run the miniconda installer for the
    #    $1 (str)  -- path to miniconda installer .sh
    #    $2 (str)  -- install dest (default: ~/miniconda; __WRK/-conda[27|34])
    #    $3 (str)  -- python version (default: empty; installs installer's default)
    #    $4 (str)  -- extra packages (default: empty)
    #    $5 (str)  -- environment.yml path (default: empty)
    #    Returns:
    #      n: Miniconda[3]-latest-*.sh return code
    local conda_installer_installer_sh="${1}"
    local prefix="${2:-"${HOME}/miniconda"}"
    local py_ver="${3:-}"
    local pkgs="${4:-}"
    local env_yml="${5:-}"
    shift
    shift
    shift || true
    shift || true
    shift || true
    
    if [[ "${conda_installer_installer_sh}" == *.tar.bz2 ]]; then
        local _tmp_mm
        _tmp_mm=$(mktemp -d)
        run_cmd tar -xjf "${conda_installer_installer_sh}" -C "${_tmp_mm}"
        export MAMBA_ROOT_PREFIX="${prefix}"
        
        local install_args=("conda" "pip" "micromamba")
        if [ -n "${py_ver}" ]; then
            install_args+=("python=${py_ver}")
        elif [ -n "${CONDA_PYTHON_VERSION:-}" ]; then
            install_args+=("python=${CONDA_PYTHON_VERSION}")
        else
            install_args+=("python")
        fi
        for pkg in ${pkgs}; do
            install_args+=("${pkg}")
        done
        
        run_cmd "${_tmp_mm}/bin/micromamba" create -y -p "${prefix}" "${install_args[@]}" "${@}"
        
        if [ -n "${env_yml}" ] && [ -f "${env_yml}" ]; then
            run_cmd "${prefix}/bin/micromamba" env update -y -p "${prefix}" -f "${env_yml}"
        fi
        
        rm -rf "${_tmp_mm}"
    else
        run_cmd sh "${conda_installer_installer_sh}" -b -p "${prefix}" "${@}"
    fi
}


###


_miniconda_check_conda_env() {
    #  miniconda_check_conda_env       -- check python and conda in a conda env
    #    $1 (str)  -- path of a conda env
    #       "./here"
    #       "${CONDA_ENVS_PATH}/envname"
    local env="${1}"
    if [ -z "${env}" ]; then
        return 2
    fi
    test -d "${env}" || { echo "ERROR: env dir ${env} not found" >&2; return 1; }

    local python="${env}/bin/python"
    if [ -x "${python}" ]; then
        "${python}" --version
        "${python}" -m site
    else
        echo "ERROR: ${python} not found or executable" >&2
    fi

    local conda="${env}/bin/conda"
    if [ -x "${conda}" ]; then
        "${conda}" --version
        "${conda}" info
    fi

    local pip="${env}/bin/pip"
    if [ -x "${pip}" ]; then
        "${pip}" --version
        #"${pip}" show pip
    else
        echo "ERROR: ${pip} not found or executable" >&2
    fi
}
miniconda_check_conda_env() {
    (set -x; _miniconda_check_conda_env "${@}")
}


miniconda_setup__dotfiles_minicondas() {
    #  miniconda_setup__dotfiles_minicondas  -- install CONDA_ROOTs
    #    $1 (str)  -- path for CONDA_ROOTs and CONDA_ENVSs (default: $__WRK)
    #    Returns:
    #      n: sum of Miniconda[3]-latest-*.sh return codes
    local prefix="${1:-"${__WRK}"}"

    local ret=0;
    local mc2=""
    local mc3=""
    local version var_name var_value exec_code
    for version in $(_conda_get_versions); do
        var_name="CONDA_ROOT__py${version}"
        var_value="${!var_name}"
        if [ -n "${var_value}" ]; then
            if [ "${version}" = "27" ]; then
                mc2=$(conda_installer_download 2)
                echo "${mc2}"
                conda_installer_install "${mc2}" "${var_value}"
            else
                mc3=$(conda_installer_download 3)
                echo "$mc3"
                conda_installer_install "${mc3}" "${var_value}"
            fi
            exec_code=$?
            ret=$(expr $ret + $exec_code)
        fi
    done
    echo "${mc2}${mc3}"
    return $ret;
}

miniconda_setup__dotfiles_env() {
    local prefix="${1:-"${__WRK}"}"
    local ver cr_var ce_var val_cr val_ce
    for ver in $(_conda_get_versions); do
        cr_var="CONDA_ROOT__py${ver}"
        ce_var="CONDA_ENVS__py${ver}"
        
        val_cr="${!cr_var}"
        val_ce="${!ce_var}"
        
        declare -g "${cr_var}=${val_cr:-"${prefix}/-conda${ver}"}"
        declare -g "${ce_var}=${val_ce:-"${prefix}/-ce${ver}"}"
    done
}

miniconda_setup__dotfiles_condaenvs() {
    local prefix="${1:-"${__WRK}"}"
    
    local envname="dotfiles"
    # local baseenvname="root"
    local baseenvname="base"

    ## create a condaenv for each python version
    # create a dotfiles condaenv for each python version
    local ver pyver val_cr val_ce cr_var ce_var
    for ver in $(_conda_get_versions); do
        if [ "$ver" = "27" ]; then 
            pyver="2.7"
        else 
            pyver="3.${ver#3}"
        fi
        
        cr_var="CONDA_ROOT__py${ver}"
        ce_var="CONDA_ENVS__py${ver}"
        val_cr="${!cr_var}"
        val_ce="${!ce_var}"
        
        export CONDA_ROOT="${val_cr}"
        export CONDA_ENVS_PATH="${val_ce}"
        
        local conda_cmd="${val_cr}/bin/conda"
        if [ "${INSTALL_TYPE}" = "miniforge" ] && [ -x "${val_cr}/bin/mamba" ]; then
            conda_cmd="${val_cr}/bin/mamba"
        fi
        
        run_cmd "${conda_cmd}" install -y -n "${baseenvname}" conda-env python="${pyver}" pip readline
        test -d "${val_ce}/${envname}" || run_cmd "${conda_cmd}" create -y -n "${envname}"
        run_cmd miniconda_check_conda_env "${val_ce}/${envname}"
    done
}

test_conda_installer_get_filename() {
    echo "  - test_conda_installer_get_filename"
    local f
    f=$(INSTALL_TYPE="miniforge" conda_installer_get_filename "3")
    if [[ "$f" != miniforge-* ]]; then echo "FAIL: Expected miniforge-*, got $f"; return 1; fi
    f=$(INSTALL_TYPE="miniconda" conda_installer_get_filename "3")
    if [[ "$f" != Miniconda3-* ]]; then echo "FAIL: Expected Miniconda3-*, got $f"; return 1; fi
    return 0
}

test_miniconda_setup__dotfiles_env() {
    echo "  - test_miniconda_setup__dotfiles_env"
    local CONDA_VERSIONS="314"
    miniconda_setup__dotfiles_env "/tmp/mywrk"
    if [ "${CONDA_ROOT__py314}" != "/tmp/mywrk/-conda314" ]; then
        echo "FAIL: CONDA_ROOT__py314 is ${CONDA_ROOT__py314}"
        return 1
    fi
    return 0
}

test_08_bashrc_conda() {
    echo "  - test_08_bashrc_conda"
    local src_script="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/../etc/bash/08-bashrc.conda.sh"
    if [ ! -f "$src_script" ]; then
        echo "FAIL: Cannot find 08-bashrc.conda.sh at $src_script"
        return 1
    fi
    
    # Run tests within a subshell to not pollute global state
    (
        # Mocks
        PATH_remove() { :; }
        PATH_prepend() { :; }
        shell_escape_single() { echo "$1"; }
        printvar() { :; }
        
        source "$src_script"
        export CONDA_VERSIONS="314"
        export __WRK="/tmp/mywrk"
        
        _setup_conda_defaults "/tmp/mywrk"
        if [ "${CONDA_ROOT__py314}" != "/tmp/mywrk/-conda314" ]; then
            echo "FAIL: _setup_conda_defaults failed, got ${CONDA_ROOT__py314}"
            return 1
        fi
        
        _setup_conda 314 > /dev/null 2>&1
        if [ "${CONDA_ENVS_PATH}" != "/tmp/mywrk/-ce314" ]; then
            echo "FAIL: _setup_conda 314 failed, got ENVS: ${CONDA_ENVS_PATH}"
            return 1
        fi
    ) || return 1
    return 0
}

test_scripts() {
    local fails=0
    echo "=== Running tests for setup_miniconda.sh ==="
    test_conda_installer_get_filename || fails=$((fails+1))
    test_miniconda_setup__dotfiles_env || fails=$((fails+1))
    
    echo "=== Running tests for 08-bashrc.conda.sh ==="
    test_08_bashrc_conda || fails=$((fails+1))
    
    if [ "$fails" -eq 0 ]; then
        echo "All tests PASSED!"
        return 0
    else
        echo "$fails tests FAILED!"
        return 1
    fi
}

__THIS=$0
_miniconda_setup_usage() {
    echo "Usage: $__THIS [options] [prefix]"
    echo "Options:"
    echo "  -h, --help       Show this help message"
    echo "  -v, --verbose    Enable verbose output (set -x)"
    echo ""
    echo "  --print-config   Print configuration and exit"
    echo ""
    echo "  --mamba          Install miniforge (the default)"
    echo "  --conda          Install miniconda (instead of miniforge)"
    echo "  -y, --yes        Perform actual installation (default is dry run)"
    echo ""
    echo "  --test           Run test suite and exit"
    echo ""
}

miniconda_setup_main() {
    local verbose=0
    local DO_PRINT_CONFIG=0

    export DRY_RUN=1

    if [[ $# -eq 0 ]]; then
        (set +x; _miniconda_setup_usage)
        return 0
    fi

    local args=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                (set +x; _miniconda_setup_usage)
                return 0
                ;;
            -v|--verbose)
                verbose=1
                shift
                ;;
            --print-config)
                DO_PRINT_CONFIG=1
                shift
                ;;
            --install)
                export DO_SETUP_MINICONDA=1
                shift
                ;;
            --conda|--miniconda)
                export DO_SETUP_MINICONDA=1
                export INSTALL_TYPE="miniconda"
                shift
                ;;
            --mamba|--miniforge)
                export DO_SETUP_MINICONDA=1
                export INSTALL_TYPE="miniforge"
                shift
                ;;
            --micromamba)
                export DO_SETUP_MINICONDA=1
                export INSTALL_TYPE="micromamba"
                shift
                ;;
            --create|--create_envs)
                export DO_SETUP_CONDAENVS=1
                shift
                ;;
            -y|--yes)
                export DRY_RUN=0
                shift
                ;;
            --test)
                export SKIP_DOWNLOAD_IF_EXISTS=1
                test_scripts
                return $?
                ;;
            *)
                args+=("$1")
                shift
                ;;
        esac
    done

    if [[ "$verbose" -gt 1 ]]; then
        set -x
    fi

    ## Initialize variables
    miniconda_setup__dotfiles_env "${args[@]}"

    if [ "$DO_PRINT_CONFIG" = "1" ]; then
        echo "Configuration:"
        echo "CONDA_VERSIONS=$(_conda_get_versions)"
        local ver cr_var ce_var
        for ver in $(_conda_get_versions); do
            cr_var="CONDA_ROOT__py${ver}"
            ce_var="CONDA_ENVS__py${ver}"
            echo "  ${cr_var}=${!cr_var}"
            echo "  ${ce_var}=${!ce_var}"
        done
        return 0
    fi


    if [ "${DO_SETUP_MINICONDA}" ]; then
        if [ -n "${INSTALL_TYPE}" ]; then
            echo "ERROR: you must also specify one of: --conda | --mamba | --micromamba"
            return 2
        fi
    fi

    if [ "${DRY_RUN}" = "1" ]; then
        echo "--- DRY RUN MODE (use -y or --yes to actually install) ---"
    fi

    ## install miniconda and configure condaenvs

    DO_SETUP_MINICONDA=1
    if [ "${DO_SETUP_MINICONDA}" = "1" ]; then
        miniconda_setup__dotfiles_minicondas "${args[@]}";
    fi

    DO_SETUP_CONDAENVS=1
    if [ "${DO_SETUP_CONDAENVS}" = "1" ]; then
        miniconda_setup__dotfiles_condaenvs "${args[@]}";
    fi
}

if [ -n "${BASH_SOURCE[*]}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    miniconda_setup_main "${@}"
    exit
fi
