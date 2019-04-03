#!/usr/bin/env bash
# setup_lgo.sh -- Setup lgo Go Jupyter Kernel
# https://github.com/yunabe/lgo

function setup_lgo_env {
    local prefix="${1:-"${__WRK}"}"
    export GOVERSION="${GOVERSION:-"1.11"}"
    export GOPATH="${GOPATH:-"${prefix}/go${GOVERSION}"}"
    export LGOPATH="${prefix}/lgo${GOVERSION}"
}

function _setup_lgo_dependencies {
    if [ -n "${SKIPPKGS}" ]; then
        return 0
    fi
    if [ -n "$(which dnf)" ]; then
        sudo dnf install -y zeromq-devel
    elif [ -n "$(which apt-get)" ]; then
        sudo apt-get install -y libzmq-dev
    fi
    if [ -n "$(which conda)" ]; then
        conda install -y jupyter_client nodejs
    else
        pip install jupyter_client
    fi
}

function _setup_lgo_install_jupyterlab_extension {
    if [ -z "$(which node)" ]; then
        echo "ERROR: node is not installed. Not installing extension."
        return 2
    fi
    if [ -z "$(which jupyter-lab)" ]; then
        echo "ERROR: jupyter-lab is not installed. Not installing extension"
        return 3
    fi
    jupyter labextension install @yunabe/lgo_extension
    # jupyter lab clean
}


function _setup_lgo {
    if [ -z "${GOPATH}" ]; then
        echo 'ERROR: $GOPATH is not set' >&2
        return 1
    fi
    if [ ! -d "${GOPATH}" ]; then
        echo 'ERROR: $GOPATH does not exist' >&2
        return 2
    fi

    setup_lgo_env
    test -d "${LGOPATH}" || mkdir -p "${LGOPATH}"

    _setup_lgo_dependencies

    go get github.com/yunabe/lgo/cmd/lgo
    go get -d github.com/yunabe/lgo/cmd/lgo-internal
    "${GOPATH}/bin/lgo" install
    "${GOPATH}/src/github.com/yunabe/lgo/bin/install_kernel"

    _setup_lgo_install_jupyterlab_extension
    return $?
}


if [ "${0}" == "${BASH_SOURCE}" ]; then
    _setup_lgo
fi

setup_lgo_env
