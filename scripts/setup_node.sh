#!/bin/sh
## setup_node.sh

# see also: https://github.com/saltstack-formulas/node-formula/blob/master/node/map.jinja 

# TODO:
# - [ ] don't reset to default version when NODE_VERSION is unspecified
# - [ ] install npm

# sudo node install -g node

_filename="${0}"
__file__="$(basename "${_filename}")"

NODE_VERSION=${NODE_VERSION:-"v0.12.7"}

function setup_node_help {
    echo "${__file__}   -- install node from tar.gz, git, or with NVM"
    echo ""
    echo "  Arguments"
    echo "    --install/-i  -- install node (by default from tar.gz)"
    echo '      $NODE_VERSION  # (default: v0.12.7)'
    echo "    --git/--src   -- install from source (requires -i)"
    echo '      $NODE_VERSION  # (default: v0.12.7)'
    echo "    --nvm         -- install nvm and node w/ nvm (requires -i)"
    echo '      $NVM_DIR       # path to nvm (default: ~/.nvm)'
    echo ""
    echo "  Usage:"
    echo "    ${__file__} -i"
    echo "    ${__file__} -i --git"
    echo "    ${__file__} -i --nvm"
    echo "    ${__file__} -i --nvm --git"
    echo '    NVM_VERSION="master" '"${__file__}"' -i --nvm --git'
    echo '    NVM_DIR="${__DOTFILES}/src/nvm" '"${__file__}"' -i --nvm --git'
    echo ""
    echo "  NodeJS -- Node"
    echo "    Homepage: https://nodejs.org/"
    echo "    Download: https://nodejs.org/download/"
    echo "    Src: https://github.com/joyent/node"
    echo "    Docs: https://docs.nodejs.com/getting-started/installing-node"
    echo "    Docs: https://raw.githubusercontent.com/joyent/node/master/ChangeLog"
    echo ""
    echo "  NPM -- Node Package Manager (now bundled with Node)"
    echo "    Homepage: https://npmjs.com/" 
    echo "    Src: https://github.com/npm/npm" 
    echo "    Docs: https://docs.npmjs.com/"
    echo ""
    echo "  NVM -- Node Version Manager"
    echo "    Src: https://github.com/creationix/nvm"
    echo ""
}

function setup_node_dependencies__dnf {
    dnf install -y gcc g++ python2 make
}

function setup_node_dependencies__apt {
    apt-get install -y gcc g++ python2 make
}

function setup_node_download_node {
    local version="${1:-"${NODE_VERSION}"}"
    
    local filename="node-${version}.tar.gz"
    local url="https://nodejs.org/dist/${version}/${filename}" 
    curl -Ss "${url}" > "${filename}"
    ls -al "${filename}"
    #md5sum "${filename}" | #shasum "${filename}"
    file "${filename}"
    tar xzvf "${filename}"
    cd "node-${version}"  # TODO:
}

function setup_node_node_gitclone_install {
    local rev="${1}"
    local url="https://github.com/joyent/node"
    local dest="./node"
    git clone "${url}" "${dest}"
    cd "${dest}"
    if [ -n "${rev}" ]; then
        git checkout "${rev}"
    fi
}

function setup_node_install_node {
    ./configure --prefix="${HOME}/.local"
    ./configure --prefix="${HOME}/.local/node"
    make
    #make test
    make install
}


##

function setup_node_nvm_download_installsh {
    #| Src: git https://github.com/creationix/nvm 
    local version="v0.25.4"
    #local version="master" # TODO
    local filename="install.sh"
    local url="https://raw.githubusercontent.com/creationix/nvm/${version}/${install.sh}" 
    curl -Ss "${url}" > "${filename}"
}

function setup_node_nvm_installsh_install {
    local version="v0.25.4"
    local filename="install.sh"

    if [ ! -f "${filename}" ]; then
        setup_node_nvm_download_nvm "${version}"
    fi
    
    #NVM_DIR="${HOME}/.nvm"        # default
    #NVM_DIR="${HOME}/.local/nvm"
    bash ./install.sh

}

function setup_node_nvm_gitclone_install {
    local NVM_DIR="${1:-"${HOME}/.nvm"}"        # default
    #local NVM_DIR="${HOME}/.local/nvm"
    local NVM_GIT_URI="https://github.com/creationix/nvm"

    git clone "${NVM_GIT_URI}" "${NVM_DIR}"
    cd "${NVM_DIR}" && git checkout $(git describe --abbrev=0 --tags)
    echo "To use NVM, source nvm.sh into the current shell:"
    echo "$ source ~/.nvm/nvm.sh"
}


function setup_node_nvm_install_and_use {
    local node_verstr="${1:-"stable"}"
    #node_verstr="unstable"
    #node_verstr="v0.12.7"
    _setup_nvm
    nvm install "${node_verstr}"
    nvm use "${node_verstr}"
}
# setup_node_nvm_install_and_use "stable"
#(  nvm install stable; nvm use stable )

function _setup_nvm {
    export NVM_DIR="${1:-"${HOME}/.nvm"}"        # default
    #local NVM_DIR="${__DOTFILES}/src/nvm"
    local nvmsh="${NVM_DIR}/nvm.sh"
    if [ ! -f "${nvmsh}" ]; then
        echo "Err: Not found: ${nvmsh}" >&2
        echo "Err: You might try:" >&2
        echo "Err:   setup_node.sh --install --nvm" >&2
    else
        source "${nvmsh}"
    fi
}

## nn-bashrc.node.sh
# test -d ~/.nvm || echo
# configure anyway


function setup_node_main {
    for arg in "${@}"; do
        case "${arg}" in
            -i|--install)
                local __do_install=1
                ;;
            --src|--git)
                local __do_install_from_source=1;
                ;;
            --nvm)
                local __do_install_with_nvm=1;
                ;;
            -h|--help)
                local __do_help=1;
                ;;
        esac
    done

    if [ -n "${__do_help}" ]; then
        setup_node_help
        exit
    fi

    if [ -n "${__do_install}" ]; then
        if [ -n "${__do_install_with_nvm}" ]; then
            if [ -n "${__do_install_from_source}" ]; then
                setup_node_nvm_gitclone_install
            else
                setup_node_nvm_installsh_install
            fi
            setup_node_nvm_install_and_use "${NODE_VERSION}"
        else
            setup_node_dependencies__apt
            setup_node_dependencies__deb
            if [ -n "${__do_install_from_source}" ]; then
                setup_node_node_gitclone_install "${NODE_VERSION}"
            else
                setup_node_download_node "${NODE_VERSION}"
            fi
            setup_node_install_node
        fi
    fi
}

if [ -n "${BASH_SOURCE}" ] && [ "${BASH_SOURCE}" == "${0}" ]; then
    (setup_node_main "${@}")
    exit
else
    _setup_nvm
fi
