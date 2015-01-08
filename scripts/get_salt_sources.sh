#!/bin/bash
#/srv/repos/etc/requirements-saltdev.ini
set -x
set -v
repos_='salt salt-api salt-testing salt-cloud salt-contrib salt-states salt-ci salt-genesis';
repos=( $repos_ )

for repo in ${repos[*]}; do
    git clone "ssh://git@github.com/saltstack/${repo}"
done
