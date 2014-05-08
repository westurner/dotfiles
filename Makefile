
## westurner/dotfiles/Makefile


DOTFILES_SRC:=https://github.com/westurner/dotfiles
DOTVIM_SRC:=https://bitbucket.org/westurner/dotvim

#  Usage:
#
#	 # Clone and/or install .dotfiles
#	 git clone https://github.com/westurner/dotfiles
#	 # git clone http://git.io/ghGL3w 
#	 python setup.py help
#	 python setup.py test
#
#	 # Run tests
#	 # make test
#	 make dotvim_clone
#	 make dotvim_install
	

REPOSBIN:=python src/dotfiles/repos.py
PYLINE:=python src/dotfiles/pyline.py

PIP:=pip
PIP_OPTS:=
PIP_INSTALL_OPTS:=--user --upgrade
PIP_INSTALL:=$(PIP) $(PIP_OPTS) install $(PIP_INSTALL_OPTS) 

default: test

help:
	python setup.py --help | head -n -4
	python setup.py --command-packages=stdeb.command --help-commands
	$(MAKE) help_commands

clean:
	pyclean .
	find . -name '__pycache__' -exec rm -fv {} \;
	$(MAKE) build_deb_clean
	find . -name '*.egg-info' -exec rm -rfv {} \;

# .. show help as (almost) ReStructuredText TODO
#
.PHONY = help_rst
help_rst:
	# python setup.py --help
	# ========================
	python setup.py --help \
		| sed "s/^\w.*/\0::\n/g" \
		| sed "s/^\s\s/ \0/g"; \
	echo ""
	# Commands
	# =========
	for _cmd in \
		`python setup.py --help-commands | grep '^  \w' | pycut -f 0`;	do \
		echo ""; echo ""; \
		python setup.py --help "$${_cmd}" \
			| tail -n +13 \
			| head -n -6 \
			| sed "s/^Options for '\(.*\)' command:/\`\`python setup.py \1\`\`::\n/g" \
			| sed "s/^\s\s/ \0/g"; \
	done


vim_help:
	test -d etc/vim && \
		$(MAKE) -C etc/vim help

vim_help_all:
	$(MAKE) vim_help


test:
	# Run setuptools test task
	python setup.py test

build:
	# Build source dist and bdist
	python setup.py build sdist bdist

build_test_generate_runtests:
	$(PIP_INSTALL) PyTest
	py.test --genscript=runtests.py

build_deb_setup:
	# Setup building of debian packages
	# apt-get install 
	$(PIP_INSTALL) stdeb

build_deb_debianize:
	# Create a debian/ directory
	python setup.py --command-packages=stdeb.command debianize
	# Manually update this debian/ directory,
	# rather than using stdeb commandline options.

build_deb_sdist_dsc:
	# Build a debian source package
	python setup.py --command-packages=stdeb.command sdist_dsc
	
build_deb_bdist:
	# Build a debian binary package
	python setup.py --command-packages=stdeb.command bdist_deb

build_deb_install:
	# Build and install a debian binary package
	python setup.py --command-packages=stdeb.command install_deb

build_deb_clean:
	# Clean debian dist directory
	rm -rfv deb_dist/


build_tags:
	# Build ctags for this virtualenv (pip install z3c.recipe.tag)
	ls -al tags
	build_tags --ctags-vi --languages=python
	ls -al tags

pip_upgrade_pip:
	# Upgrade pip
	$(PIP) $(PIP_OPTS) install $(PIP_INSTALL_OPTS) pip

pip_install_as_editable:
	# Install dotfiles as a develop egg (pip install -e .)
	$(PIP) $(PIP_OPTS) install $(PIP_INSTALL_OPTS) -e .


pip_install_requirements_all:
	# Run each pip makefile command
	# dev calls testing and docs once
	$(MAKE) pip_install_requirements_dev
	# testing and docs run again
	$(MAKE) pip_install_requirements_testing
	$(MAKE) pip_install_requirements_docs
	#
	$(MAKE) pip_install_requirements_suggests

pip_install_requirements_dev:
	# Install package development requirements
	$(PIP_INSTALL) -r ./requirements/requirements-dev.txt

pip_install_requirements_testing:
	# Install package test tools
	$(PIP_INSTALL) -r ./requirements/requirements-testing.txt

pip_install_requirements_docs:
	# Install package documentation tools
	$(PIP_INSTALL) -r ./requirements/requirements-docs.txt

pip_install_requirements_suggests:
	# Install suggested package requirements
	$(PIP_INSTALL) -r ./requirements/requirements-suggests.txt 

PIP_REQUIREMENTS:=requirements/requirements-dev.txt requirements/requirements-docs.txt requirements/requirements-suggests.txt

pip_list_editable_requirements:
	# Find editable paths in pip requirements files
	cat $(PIP_REQUIREMENTS) \
		| egrep '\s+-e\s+' \
		| sed 's/^#\s*//g' \
		| tee ./requirements/editable-sources.txt

dotvim_clone:
	# Clone and/or install .dotvim/Makefile
	mkdir -p ~/.dotfiles/etc
	test -d ~/.dotfiles/etc/vim/.hg \
		|| hg clone $(DOTVIM_SRC) ~/.dotfiles/etc/vim
	hg -R ~/.dotfiles/etc/vim pull

dotvim_make_install:
	# Install vim with Makefile
	$(MAKE) -C etc/vim install


edit:
	# Open (EDITOR) with project files
	$(EDITOR) README.rst Makefile setup.py CHANGELOG.rst
	# Also open (EDITOR) with vim files (cd etc/vim; make install)
	test -f etc/vim/Makefile && \
		$(MAKE) -C etc/vim edit


changelog:
	# Show hg log in changelog format
	hg log --style=changelog


# Local Reports


dotfiles_origin_report:
	$(REPOSBIN) -s . -r origin | tee repo-origins.txt

dotfiles_status_report:
	$(REPOSBIN) -s $(HOME)

dotfiles_pip_report:
	$(REPOSBIN) -s ${HOME}/.dotfiles -r pip | tee pip-requirements-autogen.txt

dotfiles_thg_report:
	$(REPOSBIN) -s ${HOME}/.dotfiles -r thg | tee thg-reporegistry.xml

dotfiles_all_reports:
	$(REPOSBIN) -s ${HOME}/.dotfiles -r origin -r pip -r thg


# /srv Reports

SRVROOT:=/srv
ORIGIN_REPORT:=$(SRVROOT)/repo-origins.txt
PIP_REQS_REPORT:=$(SRVROOT)/pip-requirements-autogen.txt
THG_RREG_REPORT:=$(SRVROOT)/thx-reporegistry.xml


# /srv setup
setup_srv:
	# Make the directory structure for source repositories
	mkdir -p $(SRVROOT)/etc
	mkdir -p $(SRVROOT)/repos/git $(SRVROOT)/repos/hg
	mkdir -p $(HOME)/src
	ln -s $(SRVROOT)/repos/git $(HOME)/src/git
	ln -s $(SRVROOT)/repos/hg $(HOME)/src/hg

srv_origin_report:
	$(REPOSBIN) -s $(SRVROOT) -r origin | tee $(ORIGIN_REPORT)
	echo "Report written to $(ORIGIN_REPORT)"

srv_origin_report_parse:
	cat $(ORIGIN_REPORT) |  \
		$(PYLINE) -r '(.*)\s+=\s+(.*)' \
			'len(words)==2 and words[0].split("://",1)' -s 2

srv_pip_report:
	$(REPOSBIN) -s $(SRVROOT) -r pip | tee $(PIP_REQS_REPORT)
	echo "Report written to $(PIP_REQS_REPORT)"

srv_thg_report:
	$(REPOSBIN) -s $(SRVROOT) -r thg | tee $(THG_RREG_REPORT)
	echo "Report written to $(THG_RREG_REPORT)"


# ~/.config/TortoiseHg Report

thg_all:
	$(REPOSBIN) -s $(SRVROOT) -s ${HOME}/.dotfiles --thg \
		| tee ~/.config/TortoiseHg/thg-reporegistry.xml


.PHONY: all test build install edit
all: test build


test_show_env:
	env
