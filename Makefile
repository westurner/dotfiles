
### ~/.dotfiles/Makefile
### westurner/dotfiles/Makefile
## westurner/dotfiles Usage:
#
#  # print docs for the Makefile
#  $ make help
#
#  # build the docs and open BUILDDIRHTML/index.html in a browser [websh.py]
#  $ make docs open

#  # build the docs, git push, ghp-import docs/_build/html -> gh-pages & push
#  $ make docs push gh-pages
#
## westurner/dotfiles git workflow:
#
#  - https://github.com/westurner/dotfiles
#    - | Docs: https://westurner.org/dotfiles/
#    - | Docs: https://westurner.org/dotfiles/usage
#    - | Docs: https://westurner.org/dotfiles/venv
#    - | Docs: https://westurner.org/dotfiles/tools/
#      - https://github.com/westurner/tools
#       - | Docs: https://westurner.org/tools/
#       - | Docs: https://westurner.org/tools/#hubflow
#         - Git HubFlow: develop -> {feature release hotfix} -> stable master
#

# GHPREFIX=  should match the set { 'ssh://git@', 'https://', 'git://' }
GHPREFIX=ssh://git@
#GHPREFIX:=https://
#GHPREFIX:=git://

DOTFILES_SRC:=${GHPREFIX}github.com/westurner/dotfiles
DOTFILES_SRC_BRANCH=master
DOTFILES_TOOLS_SRC=${GHPREFIX}github.com/westurner/tools
DOTFILES_TOOLS_SRC_BRANCH=master
DOTVIM_SRC:=${GHPREFIX}github.com/westurner/dotvim

#  Usage::
#
#     # Run make tests     # source <(venv --bash dotfiles) # we dotfiles
#     make test ; make     # makew test ; makew
#     make dotvim_clone    # makew dotvim_clone
#     make dotvim_install  # make -C etc/vim install

# PYRPO:=pyrpo
PYRPO:=python scripts/pyrpo.py
# PYLINE:=pyline
PYLINE:=python scripts/pyline.py

PIP:=pip
PIP_LOCAL:=/usr/local/bin/pip
PIP_OPTS:=
PIP_INSTALL_OPTS:=--upgrade
PIP_INSTALL_USER_OPTS:=--user --upgrade
PIP_INSTALL:=$(PIP) $(PIP_OPTS) install $(PIP_INSTALL_OPTS)
PIP_INSTALL_USER:=$(PIP) $(PIP_OPTS) install ${PIP_INSTALL_USER_OPTS}

#SETUPPY_CMDOPTS:=--command-packages=stdeb.command
SETUPPY_CMDOPTS:=

git:=git -P

default: test

help:
	@echo "dotfiles Makefile"
	@echo "#################"
	@echo "help         -- print dotfiles help"
	@echo "help_vim     -- print dotvim make help"
	@echo "help_vim_txt -- print dotvim help as rst"
	@echo "help_i3      -- print i3wm configuration"
	@echo "help_setuppy -- print setup.py help"
	@echo "help_txt     -- print setup.py help as rst"
	@echo ""
	@echo "install      -- install dotfiles and dotvim [in a VIRTUAL_ENV]"
	@echo "upgrade      -- upgrade dotfiles and dotvim [in a VIRTUAL_ENV]"
	@echo "status       -- print dotfiles_status (ds)"
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
	@echo "install_brew_formulas  -- install brew formulas"
	@echo "update_brew_list       -- overwrite etc/brew/brew.list"
	@echo ""
	@echo "clean  -- remove .pyc, .pyo, __pycache__/ etc"
	@echo "edit   -- edit the project main files README.rst"
	@echo "test   -- run tests"
	@echo "build  -- build a python sdist"
	@echo "generate_venv  -- generate ipython_magics.py, venv.sh, and venv.vim"
	@echo ""
	@echo "start-release -- start a new release named $${VERSION}"
	@echo "release 		 -- finish a release named $${VERSION}"
	@echo ""
	@echo "docs      -- build sphinx documentation"
	@echo "gh-pages  -- overwrite the gh-pages branch with docs/_build/html"
	@echo ""
	@echo "push      -- git push"
	@echo "pull      -- git pull"
	@echo ""

help_setuppy:
	python setup.py --help
	python setup.py $(SETUPPY_CMDOPTS) --help-commands

help_setuppy_txt:
	## show help as (almost) ReStructuredText
	python setup.py --help \
		| sed "s|^\w.*|\0::|g" \
		| sed "s|^\s\s| \0|g"; \
	echo ""
	for _cmd in \
		`python setup.py --help-commands \
			| grep '^  \w' \
			| $(PYLINE) 'w and w[0]' \
			| sort`; do \
		echo ""; echo ""; \
		python setup.py --help "$${_cmd}" \
			| scripts/pyline.py '(6 < i < i_last - 13) and l' \
			| scripts/pyline.py -r 'Options for (.*) command:' '(rgx and "## %s" % rgx.group(1)) or l'; \
	done


BASH_LOAD_SCRIPT=scripts/_dotfiles_bash.log.sh
help_bash:
	## Write bash output to BASH_LOAD_SCRIPT
	_TERM_ID="#testing" \
		bash -i -v -c 'exit' \
			> '$(BASH_LOAD_SCRIPT)' 2>&1

help_bash_txt: help_bash
	## Write docs/usage/bash_conf.txt
	_TERM_ID="#testing" \
		bash scripts/_dotfileshelp.sh bash \
			> docs/usage/bash_conf.txt


ZSH_LOAD_SCRIPT=scripts/_dotfiles_zsh.log.sh
help_zsh:
	## Write zsh output to ZSH_LOAD_SCRIPT
	_TERM_ID="#testing" \
	DISABLE_AUTO_UPDATE=true \
		zsh -i -v -c 'exit' > '$(ZSH_LOAD_SCRIPT)' 2>&1 || true

help_zsh_txt: help_zsh
	_TERM_ID="#testing" \
	DISABLE_AUTO_UPDATE=true \
		bash scripts/_dotfileshelp.sh zsh \
			> docs/usage/zsh_conf.txt

help_vim:
	## Print vim output to terminal
	bash scripts/_dotfileshelp.sh vim
	@#test -d etc/vim && \
	 #	$(MAKE) -C etc/vim help | cat

help_vim_txt:
	## Write docs/usage/dotvim_conf.txt
	bash scripts/_dotfileshelp.sh vim \
		> docs/usage/dotvim_conf.txt


help_i3:
	$(MAKE) -C etc/i3 help_i3

help_i3_txt:
	bash scripts/_dotfileshelp.sh i3 \
		> docs/usage/i3_conf.txt

help_readline:
	bash scripts/_dotfileshelp.sh readline

help_readline_txt:
	bash scripts/_dotfileshelp.sh readline \
		> docs/usage/readline_conf.txt

help_dhelp_rst:
	echo "" > docs/usage/dhelp.rst
	echo ".. index:: Usage (dhelp)" >> docs/usage/dhelp.rst
	echo ".. _dhelp:"      >> docs/usage/dhelp.rst
	echo ""				   >> docs/usage/dhelp.rst
	echo "===============" >> docs/usage/dhelp.rst
	echo "Usage (dhelp)"   >> docs/usage/dhelp.rst
	echo "===============" >> docs/usage/dhelp.rst
	echo ""                >> docs/usage/dhelp.rst
	PRINTF_INDEX=1 bash scripts/_dotfileshelp.sh all \
		>> docs/usage/dhelp.rst

help_txt: \
	help_setuppy_txt \
	help_readline_txt \
	help_bash_txt \
	help_vim_txt \
	help_i3_txt \
	help_zsh_txt \
	help_dhelp_rst

help_all:
	$(MAKE) help
	#$(MAKE) help_setuppy
	#$(MAKE) help_setuppy_txt
	$(MAKE) help_bash
	$(MAKE) help_bash_txt
	$(MAKE) help_zsh_txt
	$(MAKE) help_vim
	$(MAKE) help_vim_txt
	$(MAKE) help_i3
	$(MAKE) help_i3_txt
	$(MAKE) help_dhelp_rst

install:
	$(MAKE) install_symlinks
	$(MAKE) pip_install_as_editable
	$(MAKE) pip_install_requirements
	$(MAKE) dotvim_clone dotvim_install

install_symlinks:
	# Install ${HOME}/... symlinks pointing to ${__DOTFILES}/...
	bash ./scripts/bootstrap_dotfiles.sh -S

install_user:
	$(MAKE) install_symlinks
	type 'deactivate' 1>/dev/null 2>/dev/null && deactivate \
		|| echo $(VIRTUAL_ENV)
	$(MAKE) install PIP_INSTALL="$(PIP_LOCAL) install --user"
	$(MAKE) pip_install_requirements_all PIP_INSTALL="$(PIP_LOCAL) install --user"
	$(MAKE) dotvim_clone
	$(MAKE) dotvim_install

install_apt:
	# install packages with apt
	sudo apt install -y wmctrl xdotool xclip
	$(MAKE) -c etc/i3 setuppkgs_apt

install_dnf:
	# install packages
	sudo dnf install -y wmctrl xdotool xclip
	$(MAKE) -c etc/i3 setuppkgs_dnf

upgrade:
	# Update and upgrade
	bash ./scripts/bootstrap_dotfiles.sh -U
	$(MAKE) dotvim_clone
	$(MAKE) dotvim_install

upgrade_user:
	type 'deactivate' 1>/dev/null 2>/dev/null && deactivate \
		|| echo $(VIRTUAL_ENV)
	$(MAKE) install PIP_INSTALL="$(PIP) install --upgrade --user"
	bash ./scripts/bootstrap_dotfiles.sh -U

status:
	$(shell dotfiles_status)

clean:
	$(MAKE) pyclean
	$(MAKE) build_deb_clean


pyclean:
	find . -type f -name '*.pyc' -print0 | xargs -0 rm -fv
	find . -type f -name '*.pyo' -print0 | xargs -0 rm -fv
	find . -type d -name '__pycache__' -print0 | xargs -0 rm -rfv
	find . -name '*.egg-info' -print0 | xargs -0 rm -rfv
	python setup.py clean

vimclean:
	find . -type f -name '*.un~' -exec rm -fv {} \;

vimclean_ls_undotree:
	find . -type f -name '*.un~' -exec ls -l {} \;

test:
	# Run setuptools test task
	python setup.py test

pytest:
	py.test -v ./tests/ ./scripts/ ./src/dotfiles
	# TODO: test scripts/bootstrap_dotfiles.sh

test_build:
	$(MAKE) test
	$(MAKE) build
	# linux-only
	$(MAKE) build_deb_all
	$(MAKE) pytest


build:
	# Build source dist and bdist
	python setup.py build sdist bdist

build_deb_setup:
	# Setup building of debian packages
	# apt-get install
	$(PIP_INSTALL) stdeb

build_deb_debianize:
	# Create a debian/ directory
	python setup.py $(SETUPPY_CMDOPTS) debianize
	# Manually update this debian/ directory,
	# rather than using stdeb commandline options.

build_deb_sdist_dsc:
	# Build a debian source package
	python setup.py $(SETUPPY_CMDOPTS) sdist_dsc

build_deb_bdist:
	# Build a debian binary package
	python setup.py $(SETUPPY_CMDOPTS) bdist_deb

build_deb_install:
	# Build and install a debian binary package
	python setup.py $(SETUPPY_CMDOPTS) install_deb

build_deb_clean:
	# Clean debian dist directory
	rm -rfv deb_dist/

build_deb_all:
	# Build a debian sdist, bdist, install
	$(MAKE) build_deb_setup && touch build_deb_setup
	$(MAKE) build_deb_clean
	$(MAKE) build_deb_sdist_dsc
	$(MAKE) build_deb_bdist
	$(MAKE) build_deb_install


build_tags:
	# Build ctags for this virtualenv (pip install z3c.recipe.tag)
	ls -al tags
	build_tags --ctags-vi --languages=python
	ls -al tags

build-docker-bootstrap_dotfiles.sh:
	# Copy bootstrap_dotfiles.sh into the Dockerfile
	@#   because:
	@#   - Docker ADD does not support symlinks
	@#   - Git breaks hard links
	@#   - mount -o bind requires caps
	rm -f docker/*/*/bootstrap_dotfiles.sh
	cp scripts/bootstrap_dotfiles.sh docker/fedora/22/
	cp scripts/bootstrap_dotfiles.sh docker/fedora/23/
	cp scripts/bootstrap_dotfiles.sh docker/debian/8/
	cp scripts/bootstrap_dotfiles.sh docker/ubuntu/12.04/
	cp scripts/bootstrap_dotfiles.sh docker/ubuntu/14.04/
	cp scripts/bootstrap_dotfiles.sh docker/ubuntu/15.04/
	$(git) add docker/*/*/bootstrap_dotfiles.sh && \
	 $(git) commit docker/*/*/bootstrap_dotfiles.sh \
	 	-m "BLD: */bootstrap_dotfiles: build-docker-bootstrap_dotfiles.sh"

build-docker:
	$(MAKE) build-docker-fedora-22
	$(MAKE) build-docker-fedora-23
	$(MAKE) build-docker-debian-8
	$(MAKE) build-docker-ubuntu-12.04
	$(MAKE) build-docker-ubuntu-14.04
	$(MAKE) build-docker-ubuntu-15.04


DOCKER_BUILD_SUDO=sudo
DOCKER_BUILD_SUDO=
DOCKER_BUILD=sudo DOCKER_BUILDKIT=1 docker build
DOCKER_BUILD=${DOCKER_BUILD_SUDO} DOCKER_BUILDKIT=1 docker build

DOCKER_TAG_PREFIX=westurner/dotfiles

build-docker-fedora-22:
	${DOCKER_BUILD} -t westurner/dotfiles:fedora22 -f Dockerfile.fedora22 .

build-docker-fedora-23:
	${DOCKER_BUILD} -t westurner/dotfiles:fedora23 -f Dockerfile.fedora23 .

build-docker-fedora-24:
	${DOCKER_BUILD} -t westurner/dotfiles:fedora24 -f Dockerfile.fedora24 .

build-docker-fedora-25:
	${DOCKER_BUILD} -t westurner/dotfiles:fedora25 -f Dockerfile.fedora25 .

build-docker-fedora-29:
	${DOCKER_BUILD} -t westurner/dotfiles:fedora29 -f Dockerfile.fedora29 .

build-docker-fedora-33:
	${DOCKER_BUILD} -t westurner/dotfiles:fedora33 -f Dockerfile.fedora33 .

build-docker-debian-8:
	${DOCKER_BUILD} -t westurner/dotfiles:debian-8 -f Dockerfile.debian8 .

build-docker-ubuntu-12.04:
	${DOCKER_BUILD} -t westurner/dotfiles:ubuntu-12.04 -f Dockerfile.ubuntu12.04 .

build-docker-ubuntu-14.04:
	${DOCKER_BUILD} -t westurner/dotfiles:ubuntu-14.04 -f Dockerfile.ubuntu14.04 .

build-docker-ubuntu-15.04:
	${DOCKER_BUILD} -t westurner/dotfiles:ubuntu-15.04 -f Dockerfile.ubuntu15.04 .

build-docker-ubuntu-16.04:
	${DOCKER_BUILD} -t westurner/dotfiles:ubuntu-16.04 -f Dockerfile.ubuntu16.04 .

build-docker-ubuntu-20.04:
	${DOCKER_BUILD} -t westurner/dotfiles:ubuntu-20.04 -f Dockerfile.ubuntu20.04 .

pip_upgrade_pip:
	# Upgrade pip
	$(PIP_INSTALL) pip

pip_install:
	$(PIP_INSTALL) .

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

pip_install_requirements_docs.log:
	# Install package documentation tools
	$(PIP_INSTALL) -r ./requirements/requirements-docs.txt
	$(PIP_INSTALL) -r ./docs/requirements.txt
	$(PIP_INSTALL) -e .
	touch pip_install_requirements_docs.log
	# Note that you need zsh installed
	#   dnf install -y zsh
	#   apt-get install -y zsh

pip_install_requirements_docs: pip_install_requirements_docs.log

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
	mkdir -p ./etc
	(test -d ./etc/vim/.$(git) && cd etc/vim && $(git) pull) \
		|| $(git) clone '$(DOTVIM_SRC)' ./etc/vim

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
	$(PYRPO) -s . -r origin | tee repo-origins.txt

dotfiles_status_report:
	$(PYRPO) -s $(HOME)

dotfiles_pip_report:
	$(PYRPO) -s ${HOME}/.dotfiles -r pip | tee pip-requirements-autogen.txt

dotfiles_thg_report:
	$(PYRPO) -s ${HOME}/.dotfiles -r thg | tee thg-reporegistry.xml

dotfiles_all_reports:
	$(PYRPO) -s ${HOME}/.dotfiles -r origin -r pip -r thg


# /srv Reports

SRVROOT:=/srv
ORIGIN_REPORT:=$(SRVROOT)/repo-origins.txt
PIP_REQS_REPORT:=$(SRVROOT)/pip-requirements-autogen.txt
THG_RREG_REPORT:=$(SRVROOT)/thg-reporegistry.xml


# /srv setup
setup_srv:
	# Make the directory structure for source repositories
	mkdir -p $(SRVROOT)/etc
	mkdir -p $(SRVROOT)/repos/$(git) $(SRVROOT)/repos/hg
	mkdir -p $(HOME)/src
	ln -s $(SRVROOT)/repos/$(git) $(HOME)/src/git
	ln -s $(SRVROOT)/repos/hg $(HOME)/src/hg

srv_origin_report:
	$(PYRPO) -s $(SRVROOT) -r origin | tee $(ORIGIN_REPORT)
	echo "Report written to $(ORIGIN_REPORT)"

srv_origin_report_parse:
	cat $(ORIGIN_REPORT) |  \
		$(PYLINE) -r '(.*)\s+=\s+(.*)' \
			'len(words)==2 and words[0].split("://",1)' -s 2

srv_pip_report:
	$(PYRPO) -s $(SRVROOT) -r pip | tee $(PIP_REQS_REPORT)
	echo "Report written to $(PIP_REQS_REPORT)"

srv_thg_report:
	$(PYRPO) -s $(SRVROOT) -r thg | tee $(THG_RREG_REPORT)
	echo "Report written to $(THG_RREG_REPORT)"


# ~/.config/TortoiseHg Report

thg_all:
	$(PYRPO) -s $(SRVROOT) -s ${HOME}/.dotfiles --thg \
		| tee ~/.config/TortoiseHg/thg-reporegistry.xml

docs_api:
	## Generate API docs with sphinx-autodoc (requires `make docs_setup`)
	rm -f docs/api.rst
	rm -f docs/modules.rst
	rm -f docs/dotfiles.*.rst
	# https://bitbucket.org/birkenfeld/sphinx/issue/1456/apidoc-add-a-m-option-to-put-module
	sphinx-apidoc -f -M --no-toc -o docs/ src/dotfiles
	mv docs/dotfiles.rst docs/api.rst
	sed -i.bak 's/dotfiles package/Dotfiles API/' docs/api.rst
	rm docs/api.rst.bak


docs: localcss localjs pip_install_requirements_docs.log
	$(MAKE) docs_api
	$(MAKE) help_bash_txt
	$(MAKE) help_zsh_txt
	$(MAKE) help_vim_txt
	$(MAKE) help_i3_txt
	$(MAKE) help_dhelp_rst
	$(MAKE) docs_commit_autogen
	$(MAKE) -C docs clean html   # singlehtml
	$(MAKE) docs_write_rev_txt
	$(MAKE) docs-notify

DOCSREVDIR=${BUILDDIRHTML}
DOCS_REV_TXT=${DOCSREVDIR}/_gitrev.txt
docs_write_rev_txt:
	$(git) -C $$PWD rev-parse --short HEAD > '${DOCS_REV_TXT}'
	cat '${DOCS_REV_TXT}'

docs-notify:
	$(shell (hash notify-send \
		&& notify-send -t 30000 "docs build complete." \
		'$(shell pwd)') || true)

DOCS_AUTOGEN_FILES:=\
	docs/usage/readline_conf.txt \
	docs/usage/bash_conf.txt \
	docs/usage/zsh_conf.txt \
	docs/usage/i3_conf.txt \
	docs/usage/dotvim_conf.txt \
	docs/usage/dhelp.rst \
	$(BASH_LOAD_SCRIPT) \
	$(ZSH_LOAD_SCRIPT)

docs_commit_autogen:
	$(git) add -f $(DOCS_AUTOGEN_FILES)
	$(git) diff --cached --exit-code -- $(DOCS_AUTOGEN_FILES) \
		|| $(git) commit $(DOCS_AUTOGEN_FILES) -m \
		'DOC: docs/usage/: dotfiles usage docs: $(shell \
			$(git) -C . rev-parse --short HEAD) :boat:'

_projectname_="dotfiles"

_WWW:=${SRVROOT}/repos/var/www
_WWW_PATH:=${_WWW}/docs/${_projectname_}

docs_clean_rsync_local:
	## docs_clean_rsync_local -- remove (rm!) all files in _WWW_PATH
	rm -rf $(_WWW_PATH)/*

docs_rsync_to_local: docs_clean_rsync_local
	## docs_rsync_to_local    -- rsync ${BUILDDIRHTML} to ${_WWW_PATH}/
	rsync -vr '$(BUILDDIRHTML)' '$(_WWW_PATH)/'

DOTFILES_TOOLS_REMOTE:=tools_remote
DOTFILES_TOOLS_BRANCH:=tools_branch

SUBTREE_SRC:=${DOTFILES_TOOLS_SRC}
SUBTREE_SRC_BRANCH:=${DOTFILES_TOOLS_SRC_BRANCH}
SUBTREE_BRANCH:=${DOTFILES_TOOLS_BRANCH}
SUBTREE_REMOTE:=${DOTFILES_TOOLS_REMOTE}
SUBTREE_SRC_PATH:='docs/tools.git'
SUBTREE_PATH:='docs/tools'

docs_tools_subtree_setup:
	## docs_tools_subtree_setup  --  add a remote, fetch, checkout, read-tree
	# $(git) read-tree --prefix=${SUBTREE_PATH} tools_branch
	# NOTE: about $(git) subtree branch tag merging:
	#  - remote_tags that do not exist are created (* e.g. version sort collision)
	#  - new tags that conflict with remote_tags must then be set with -f
	#  - remote_tags that do exist are not overwritten
	$(git) remote show '$(SUBTREE_REMOTE)' \
		|| $(git) remote add -f '$(SUBTREE_REMOTE)' '$(SUBTREE_SRC)'
	$(git) fetch '$(SUBTREE_REMOTE)'
	$(git) checkout --track -B '$(SUBTREE_BRANCH)' \
		'$(SUBTREE_REMOTE)/$(SUBTREE_BRANCH)'
	$(git) checkout '$(SUBTREE_SRC_BRANCH)'
	$(git) read-tree --prefix='$(SUBTREE_SRC_PATH)/' '$(SUBTREE_BRANCH)'
	$(git) add '$(SUBTREE_PATH)' && \
		$(git) commit '$(SUBTREE_PATH)' -m \
			'DOC: $(SUBTREE_PATH): :boat: Merge in from $(SUBTREE_SRC) $(shell \
				$(git) -C . rev-parse --short HEAD)'


docs_tools_subtree_diff:
	$(git) diff-tree -p tools_branch

docs_tools_subtree_merge: docs_tools_subtree_diff
	# Pull in changes and generate a squashed commit
	# $(git) fetch
	$(git) fetch tools_remote
	$(git) checkout tools_branch
	$(git) pull
	$(git) checkout master
	#$(git) merge --squash -s subtree --no-commit tools_branch
	$(git) merge --squash -s ours -Xsubtree=docs/tools.git/ --no-commit tools_branch
	$(git) diff --cached
	$(git) diff

docs_tools_submodule:
	$(git) -C docs/tools/ pull origin master

docs_tools_submodule_upgrade: docs_tools_submodule
	$(git) commit docs/tools -m "DOC: docs/tools: pull latest: $(shell $(git) -C docs/tools rev-parse --short HEAD)"

docs-tools: docs_tools_submodule_upgrade docs

docs_rebuild:
	$(MAKE) docs
	$(MAKE) docs_rsync_to_local


BUILDDIR:=./docs/_build
BUILDDIRHTML:=./docs/_build/html
BUILDDIRSINGLEHTML:=./docs/_build/singlehtml
STATIC:=./docs/_static
LOCALCSS=$(STATIC)/css/local.css
localcss:
	echo '' > $(LOCALCSS)
	cat '$(STATIC)/css/custom.css' >> '$(LOCALCSS)'
	cat '$(STATIC)/css/sidenav-scrollto.css' >> '$(LOCALCSS)'
	cat '$(STATIC)/css/leftnavbar.css' >> '$(LOCALCSS)'
	cat '$(STATIC)/css/newtab.css' >> '$(LOCALCSS)'

LOCALJS=$(STATIC)/js/local.js
localjs:
	echo '' > $(LOCALJS)
	cat '$(STATIC)/js/ga.js' >> '$(LOCALJS)'
	cat '$(STATIC)/js/js.cookie.js' >> '$(LOCALJS)'
	cat '$(STATIC)/js/newtab.js' >> '$(LOCALJS)'
	cat '$(STATIC)/js/sidenav-affix.js' >> '$(LOCALJS)'
	cat '$(STATIC)/js/jquery.scrollTo.js' >> '$(LOCALJS)'
	cat '$(STATIC)/js/jquery.isonscreen.js' >> '$(LOCALJS)'
	cat '$(STATIC)/js/sidenav-scrollto.js' >> '$(LOCALJS)'

localjs-live:
	$(MAKE) localjs
	cp -v '$(LOCALJS)' '$(BUILDDIRHTML)/_static/js/local.js'  || true;
	cp -v '$(LOCALJS)' '$(BUILDDIRSINGLEHTML)/_static/js/local.js'  || true;

localcss-live:
	$(MAKE) localcss
	cp -v '$(LOCALCSS)' '$(BUILDDIRHTML)/_static/css/local.css || true;
	cp -v '$(LOCALCSS)' '$(BUILDDIRSINGLEHTML)/_static/css/local.css || true;

local-live:
	$(MAKE) localjs-live
	$(MAKE) localcss-live


docs-open: docs open

open:
	## open  -- open the docs in a browser (w/ websh.py)
	@# python -m webbrowser 'file://'"${BUILDDIRHTML}/index.html"
	@# -> websh.py
	@#    web ./docs/_build/html/index.html
	@#    web ./docs/_build/singlehtml/index.html
	scripts/websh.py '$(BUILDDIRHTML)/index.html'

update_get-pip.py:
	cd ./scripts && wget 'https://bootstrap.pypa.io/get-pip.py'
	$(git) add ./scripts/get-pip.py
	$(git) diff --cached ./scripts/get-pip.py

update_bootstrap-salt.sh:
	@#cd ./scripts && wget 'https://raw.githubusercontent.com/saltstack/salt-bootstrap/develop/bootstrap-salt.sh'
	cd ./scripts && wget 'https://raw.githubusercontent.com/saltstack/salt-bootstrap/stable/bootstrap-salt.sh'
	$(git) add ./scripts/bootstrap-salt.sh
	$(git) diff --cached ./scripts/bootstrap-salt.sh

update_manifest:
	python setup.py git_manifest
	$(git) add ./MANIFEST.in
	$(git) diff --cached --exit-code ./MANIFEST.in || \
		$(git) commit ./MANIFEST.in \
		-m "RLS: MANIFEST.in: :boat: python setup.py git_manifest"

start-release:
	# start-release   -- $(git) hf release start ${VERSION} (VERSION="0.1.0")
	#   VERSION (str): version string without a 'v' prefix (e.g "0.1.0")
	$(git) hf release start '$(VERSION)'

VERSION_TXT:=VERSION.txt
release: clean
	# release         -- finish a release that is already started
	#   VERSION (str): version string without prefix (e.g "0.1.0")
	test -n '$(VERSION)'
	#$(git) hf release start $(VERSION)
	echo '$(VERSION)' > '$(VERSION_TXT)'
	$(git) add '$(VERSION_TXT)'
	$(git) diff --cached --exit-code ./VERSION.txt || \
		$(git) commit '$(VERSION_TXT)' -m \
			"RLS: VERSION.txt: $(VERSION) :boat:"
	$(MAKE) docs
	$(MAKE) update_manifest
	$(git) hf release finish '$(VERSION)' || \
		$(git) hf release finish '$(VERSION)'
	#$(MAKE) upload

upload:
	@#python setup.py register   -r https://pypi.python.org/pypi
	python setup.py sdist upload -r https://pypi.python.org/pypi

sdist: clean
	python setup.py sdist
	ls -l dist

BUILDDIRHTML=./docs/_build/html/
DOCS_GIT_HTML_BRANCH=gh-pages
gh-pages:
	# Push docs to gh-pages branch with a .nojekyll file
	ghp-import -n -b '${DOCS_GIT_HTML_BRANCH}' -p '${BUILDDIRHTML}' \
		-m 'DOC,RLS: :books: docs built from: $(shell cat ${DOCS_REV_TXT})'
	$(git) log -n3 --stat '${DOCS_GIT_HTML_BRANCH}'


pull:
	$(git) pull

push:
	$(git) push


test_show_env:
	env

## gitflow

checkout_gitflow:
	test -d src/gitflow \
		&& (cd src/gitflow \
			&& $(git) pull \
			&& $(git) checkout master) \
		|| $(git) clone https://github.com/nvie/gitflow src/gitflow

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
			&& $(git) pull \
			&& $(git) checkout master) \
		|| $(git) clone https://github.com/datasift/gitflow src/hubflow

install_hubflow:
	$(MAKE) checkout_hubflow
	INSTALL_INTO="${HOME}/.local/bin" bash src/hubflow/install.sh

install_hubflow_system:
	$(MAKE) checkout_hubflow
	INSTALL_INTO="/usr/local/bin" sudo bash src/hubflow/install.sh

update_brew_list:
	brew leaves > ./etc/brew/brew.list.tmp
	diff -Naur ./etc/brew/brew.list ./etc/brew/brew.list.tmp || true
	mv ./etc/brew/brew.list.tmp ./etc/brew/brew.list

install_brew_formulas:
	cat ./etc/brew/brew.list | xargs brew install

_VENV:=./src/dotfiles/venv/venv.py
_VENV:=./scripts/venv.py

generate_venv: build-venv

build-venv:
	# generate ipython_magics.py, venv.sh, and venv.vim
	test -d etc/venv && rm -rfv etc/venv || rm etc/venv || true
	ln -s ../src/dotfiles/venv ./etc/venv
	$(_VENV) --print-ipython-magics . \
		> ./src/dotfiles/venv/venv_ipymagics.py
	$(_VENV) --print-bash-aliases --compress --prefix=/ \
		> ./src/dotfiles/venv/scripts/venv_cdaliases.sh
	cd ./src/dotfiles/venv/scripts && rm venv.sh && ln -s venv_cdaliases.sh venv.sh
	cd ./src/dotfiles/venv/ && rm venv.py && ln -s venv_ipyconfig.py venv.py
	$(_VENV) --print-bash --compress --prefix=/ \
		| grep -v '^export HOME=' > ./src/dotfiles/venv/scripts/venv_root_prefix.sh
	chmod +x ./src/dotfiles/venv/scripts/venv_root_prefix.sh
	$(MAKE) build-venv-vim-cdalias

build-venv-vim-cdalias:
	$(_VENV) --print-vim-cdalias . > ./src/dotfiles/venv/venv.vim

vendor-venv-vim:
	cp ./src/dotfiles/venv/venv.vim ./etc/vim/bundle/venv.vim/plugin/venv.vim


vendor-venv:
	# for development/testing:
	# PATH_prepend "${__DOTFILES}/etc/venv"
	cp ./src/dotfiles/venv/venv_ipyconfig.py ./scripts/venv_ipyconfig.py \
		&& chmod +x ./scripts/venv_ipyconfig.py
	cd ./scripts && rm venv.py && ln -s venv_ipyconfig.py venv.py
	cp ./src/dotfiles/venv/venv_ipymagics.py ./scripts/venv_ipymagics.py
	rm ./scripts/venv.sh || true
	cp ./src/dotfiles/venv/scripts/venv_cdaliases.sh ./scripts/venv_cdaliases.sh
	rm ./scripts/venv.sh || true
	cd ./scripts; ln -s venv_cdaliases.sh venv.sh
	rm ./scripts/venv_root_prefix.sh || true
	cp ./src/dotfiles/venv/scripts/venv_root_prefix.sh \
		./scripts/venv_root_prefix.sh

pwd:
	make -C src/pwd open || websh.py ./scripts/pwd.html

vendor-pwd:
	cd src/pwd && $(git) branch -a && $(git) log -1 && $(git) status
	cp src/pwd/pwd/html/index.html ./scripts/pwd.html
	$(git) add ./scripts/pwd.html
	$(git) diff --cached ./scripts/pwd.html
	$(git) commit ./scripts/pwd.html -m \
		"RLS: scripts/pwd.html: :fast_forward: https://github.com/westurner/pwd/commit/$(shell \
		$(git) -C src/pwd rev-parse --short HEAD)" && $(git) log -1

vendor-pyline:
	cd src/pyline && $(git) branch -a && $(git) log -1 && $(git) status
	cp src/pyline/pyline/pyline.py ./scripts/pyline.py
	$(git) add ./scripts/pyline.py
	$(git) diff --cached ./scripts/pyline.py
	$(git) commit ./scripts/pyline.py -m \
		"RLS: scripts/pyline.py: :fast_forward: https://github.com/westurner/pyline/commit/$(shell \
		$(git) -C src/pyline rev-parse --short HEAD)" && $(git) log -1

vendor-pyrpo:
	cd src/pyrpo && $(git) branch -a && $(git) log -1 && $(git) status
	cp src/pyrpo/pyrpo/pyrpo.py ./scripts/pyrpo.py
	$(git) add ./scripts/pyrpo.py
	$(git) diff --cached ./scripts/pyrpo.py
	$(git) commit ./scripts/pyrpo.py -m \
		"RLS: scripts/pyrpo.py: :fast_forward: https://github.com/westurner/pyrpo/commit/$(shell \
		$(git) -C src/pyrpo rev-parse --short HEAD)" && $(git) log -1

vendor-i3t:
	cd src/i3t && $(git) branch -a && $(git) log -1 && $(git) status
	cp src/i3t/i3t.py ./scripts/i3t.py
	$(git) add ./scripts/i3t.py
	$(git) diff --cached ./scripts/i3t.py
	$(git) commit ./scripts/i3t.py -m \
		"RLS: scripts/i3t.py: :fast_forward: https://github.com/westurner/i3t/commit/$(shell \
		$(git) -C src/i3t rev-parse --short HEAD)" && $(git) log -1
