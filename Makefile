test:
	python setup.py test

build:
	python setup.py build

changelog:
	hg log --style=changelog

install:
	python setup.py install

# Local Reports

origin:
	time repo -s ${HOME}/.dotfiles -r origin | tee repo-origins.txt

pip:
	time repo -s ${HOME}/.dotfiles -r pip | tee pip-requirements-autogen.txt

thg:
	time repo -s ${HOME}/.dotfiles -r thg | tee thg-reporegistry.xml

all_reports:
	time repo -s ${HOME}/.dotfiles -r origin -r pip -r thg

# /srv Reports

origin_srv:
	time repo -s /srv -r origin | tee /srv/repo-origins.txt

pip_srv:
	time repo -s /srv -r pip | tee /srv/pip-requirements-autogen.txt

thg_srv:
	time repo -s /srv -r thg | tee /srv/thg-reporegistry.xml

# ~/.config/TortoiseHg Report

thg_all:
	time repo -s /srv -s ${HOME}/.dotfiles --thg | tee ~/.config/TortoiseHg/thg-reporegistry.xml


.PHONY: all
all: test build


