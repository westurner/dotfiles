#!/bin/sh
# setup_ipython_notebook_deb.sh

# Install and configure ipython notebook

sudo apt-get install -y ipython-notebook

ipython profile create
conf="$__DOTFILES/etc/ipython/ipython_config.py"
dest="${HOME}/ipython/profile_default/ipython_config.py"
mv $dest $dest.orig.py
ln -s $conf $dest

# ipython notebook --help
# ipython --notebook {...}
