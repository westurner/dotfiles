
### ~/.dotfiles/Makefile
## westurner/dotfiles/Makefile


DOTFILES_SRC:=https://github.com/westurner/dotfiles
DOTVIM_SRC:=https://bitbucket.org/westurner/dotvim

#  Usage::
#
#	 # clone and/or install .dotfiles::
#	 git clone https://github.com/westurner/dotfiles ~/.dotfiles
#	 # shorturl: git clone http://git.io/ghGL3w ~/.dotfiles
#	 cd ~/.dotfiles
#	 git pull
#
#	 # Run make tests
#	 make test
#	 make dotvim_clone
#	 make dotvim_install
	

REPOSBIN:=python src/dotfiles/repos.py
PYLINE:=python src/dotfiles/pyline.py

PIP:=pip
PIP_OPTS:=
PIP_INSTALL_OPTS:=--upgrade
PIP_INSTALL_USER_OPTS:=--user --upgrade
PIP_INSTALL:=$(PIP) $(PIP_OPTS) install $(PIP_INSTALL_OPTS)
PIP_INSTALL_USER:=$(PIP) $(PIP_OPTS) install ${PIP_INSTALL_USER_OPTS}

default: test

help:
	@echo "dotfiles Makefile"
	@echo "#################"
	@echo "help         -- print dotfiles help"
	@echo "help_setuppy -- print setup.py help"
	@echo "help_rst     -- print setup.py help as rst"
	@echo "help_i3		-- print i3wm configuration"
	@echo "help_vim     -- print dotvim make help"
	@echo "help_vim_rst -- print dotvim help as rst"
	@echo "help_zsh		-- print zsh help"
	@echo ""
	@echo "install	  -- install dotfiles and dotvim [in a VIRTUAL_ENV]"
	@echo "upgrade	  -- upgrade dotfiles and dotvim [in a VIRTUAL_ENV]"
	@echo ""
	@echo "install_user -- install dotfiles and dotvim (with 'pip --user')"
	@echo "upgrade_user -- upgrade dodtfiles and dotfile (with 'pip --user')"
	@echo ""
	@echo "pip_upgrade pip              -- upgrade pip"
	@echo "pip_install_requirements_all -- install all pip requirements"
	@echo ""
	@echo "install_gitflow -- install gitflow from github"
	@echo "install_hubflow -- install hubflow from github"
	@echo ""
	@echo "clean  -- remove .pyc, .pyo, __pycache__/ etc"
	@echo "edit   -- edit the project main files README.rst"
	@echo "test   -- run tests"
	@echo "build  -- build a python sdist"
	@echo "docs   -- build sphinx documentation"
	@echo ""

help_setuppy:
	python setup.py --help | head -n -4
	python setup.py --command-packages=stdeb.command --help-commands
	$(MAKE) help_commands

install:
	$(MAKE) pip_install_as_editable
	$(MAKE) pip_install_requirements
	# Install ${HOME} symlinks
	bash ./scripts/bootstrap_dotfiles.sh -S
	#bash ./scripts/bootstrap_dotfiles.sh -R
	$(MAKE) dotvim_clone
	$(MAKE) dotvim_install

install_user:
	type 'deactivate' 1>/dev/null 2>/dev/null && deactivate \
		|| echo $(VIRTUAL_ENV)
	$(MAKE) install PIP_INSTALL="~/.local/bin/pip install --user"
	$(MAKE) pip_install_requirements_all PIP_INSTALL="~/.local/bin/pip install --user"
	bash ./scripts/bootstrap_dotfiles.sh -S
	$(MAKE) dotvim_clone
	$(MAKE) dotvim_install

upgrade:
	# Update and upgrade
	bash ./scripts/bootstrap_dotfiles.sh -U
	$(MAKE) dotvim_clone
	$(MAKE) dotvim_install

upgrade_user:
	type 'deactivate' 1>/dev/null 2>/dev/null && deactivate \
		|| echo $(VIRTUAL_ENV)
	$(MAKE) install PIP_INSTALL="~/.local/bin/pip install --upgrade --user"
	bash ./scripts/bootstrap_dotfiles.sh -U

clean:
	pyclean .
	find . -type d -name '__pycache__' -exec rm -rfv {} \;
	find . -name '*.egg-info' -exec rm -rfv {} \;
	python setup.py clean
	$(MAKE) build_deb_clean


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


help_bash:
	bash -i -v -c 'exit' 2> bash_load.sh
	$(EDITOR) bash_load.sh

help_bash_rst:
	bash scripts/dotfiles-bash.sh > docs/bash_conf.rst

help_zsh:
	zsh -i -v -c 'exit' 2> zsh_load.zsh
	$(EDITOR) zsh_load.zsh

help_vim:
	test -d etc/vim && \
		$(MAKE) -C etc/vim help

help_vim_rst:
	bash scripts/dotfiles-vim.sh > docs/dotvim_conf.rst

help_i3:
	$(MAKE) -C etc/.i3 help_i3

help_i3_rst:
	bash ./scripts/dotfiles-i3.sh > docs/i3_conf.rst

test:
	# Run setuptools test task
	python setup.py test

test_build:
	$(MAKE) test
	py.test -v ./tests/ 
	# TODO: test scripts/bootstrap_dotfiles.sh

build:
	# Build source dist and bdist
	$(MAKE) build_tags
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
	$(PIP_INSTALL) pip

pip_install_as_editable:
	# Install dotfiles as a develop egg (pip install -e .)
	$(PIP_INSTALL) -e .


pip_install_requirements:
	# Install requirements.txt
	$(PIP_INSTALL) -r requirements.txt

pip_install_requirements_all:
	# Run each pip makefile command
	# dev calls testing and docs once
	# pip install -r requirements-all.txt
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

dotvim_install:
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
THG_RREG_REPORT:=$(SRVROOT)/thg-reporegistry.xml


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

docs_api:
	## Generate API docs with sphinx-autodoc (requires `make docs_setup`)
	rm -f docs/api.rst
	rm -f docs/modules.rst
	# https://bitbucket.org/birkenfeld/sphinx/issue/1456/apidoc-add-a-m-option-to-put-module
	#         # https://bitbucket.org/westurner/sphinx/branch/apidoc_output_order
	sphinx-apidoc -M --no-toc --no-headings -o docs/ src/dotfiles
	mv docs/dotfiles.rst docs/api.rst
	cat docs/api.rst | sed 's/dotfiles package/API/' > docs/api.rst

.PHONY: all test build install edit docs
all: test build install docs


docs:
	$(MAKE) docs_api
	$(MAKE) help_vim_rst
	$(MAKE) help_i3_rst
	$(MAKE) -C docs clean html singlehtml

docs_clean_rsync_local:
	rm -rf /srv/repos/var/www/docs/dotfiles/*

docs_rsync_to_local: docs_clean_rsync_local
	rsync -vr ./docs/_build/html/ /srv/repos/var/www/docs/dotfiles/

docs_rebuild:
	$(MAKE) docs
	$(MAKE) docs_rsync_to_local

test_show_env:
	env

## gitflow

checkout_gitflow:
	test -d src/gitflow \
		&& (cd src/gitflow \
			&& git pull \
			&& git checkout master) \
		|| git clone https://github.com/nvie/gitflow src/gitflow

install_gitflow:
	$(MAKE) checkout_gitflow
	INSTALL_PREFIX="${HOME}/.local/bin" bash src/gitflow/contrib/gitflow-installer.sh

install_gitflow_system:
	$(MAKE) checkout_gitflow
	INSTALL_PREFIX="/usr/local/bin" sudo bash src/gitflow/contrib/gitflow-installer.sh

## hubflow

checkout_hubflow:
	test -d src/hubflow \
		&& (cd src/hubflow \
			&& git pull \
			&& git checkout master) \
		|| git clone https://github.com/datasift/gitflow src/hubflow

install_hubflow:
	$(MAKE) checkout_hubflow
	INSTALL_INTO="${HOME}/.local/bin" bash src/hubflow/install.sh

install_hubflow_system:
	$(MAKE) checkout_hubflow
	INSTALL_INTO="/usr/local/bin" sudo bash src/hubflow/install.sh


