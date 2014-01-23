#!/bin/sh
### Setup and configure pyenv

DESTDIR='.'
DESTDIR="${HOME}"
PYENV_ROOT="${HOME}/.pyenv"
PYENV_PLUGINS="${HOME}/.pyenv/plugins"
GH_URL="ssh://git@github.com"

## pyenv
cd $DESTDIR
git clone ${GH_URL}/yyuu/pyenv $PYENV_ROOT
mkdir -p $PYENV_PLUGINS

## pyenv-virtualenv
git clone ${GH_URL}/yyuu/pyenv-virtualenv $PYENV_PLUGINS/pyenv-virtualenv

## pyenv-virtualenvwrapper
# pip install --user virtualenvwrapper
pip install -U virtualenvwrapper
git clone ${GH_URL}/yyuu/pyenv-virtualenvwrapper $PYENV_PLUGINS/pyenv-virtualenvwrapper

BASH_PROFILE="${HOME}/.bashrc"
ZSH_PROFILE="${HOME}/.zshenv"

# TODO: if not grep idempotence

echo "" >> $BASH_PROFILE
echo "## pyvenv" >> $BASH_PROFILE
echo "export PYENV_ROOT=\"$PYENV_ROOT\"" >> $BASH_PROFILE
echo 'export PATH="${PYENV_ROOT}/bin:$PATH"' >> $BASH_PROFILE
echo 'eval "$(pyenv init -)"' >> $BASH_PROFILE

echo "" >> $ZSH_PROFILE
echo -e "\n## pyvenv" >> $ZSH_PROFILE
echo "export PYENV_ROOT=\"$PYENV_ROOT\"" >> $ZSH_PROFILE
echo 'export PATH="${PYENV_ROOT}/bin:$PATH"' >> $ZSH_PROFILE
echo 'eval "$(pyenv init -)"' >> $ZSH_PROFILE

# TODO: https://github.com/yyuu/pyenv#neckbeard-configuration
