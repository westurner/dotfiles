#!/bin/sh

# TODO
#
ensurelineinfile() {
    export cargopath='/root/.cargo/bin'

    grep '^export PATH="'"${cargopath}"'"' ~/.bashrc || \
    echo 'export PATH="'"${cargopath}"'":$PATH' >> ~/.bashrc

}
