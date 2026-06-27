
.. _developing:

Developing
============

Create a virtualenv with virtualenvwrapper
--------------------------------------------
Install **virtualenvwrapper** (with pip):

.. code-block:: bash

    pi install --upgrade --user pip virtualenv
    pip install --upgrade --user virtualenvwrapper
    source $(HOME)/.local/bin/virtualenvwrapper.sh 

Make a **virtualenv** for the **dotfiles** source with
**virtualenvwrapper**:

.. code-block:: bash

    mkvirtualenv dotfiles
    workon dotfiles
    cdvirtualenv
    ls -ld **/**

    mkdir -p ${VIRTUAL_ENV}/src
    cdvirtualenv src


Install this package 
----------------------
* Install into ``$VIRTUAL_ENV`` (with pip):
  
.. code-block:: bash

   workon dotfiles
   pip install -e git+https://github.com/westurner/dotfiles#egg=dotfiles


Test and build this package
-----------------------------
* Install into ``$VIRTUAL_ENV`` (manually):
  
.. code-block:: bash

   cd ${VIRTUAL_ENV}/src
   git clone https://github.com/westurner/dotfiles
   hg clone https://bitbucket.org/westurner/dotfiles

   cd dotfiles
   ls -l ./dotfiles/**
   hg paths || git remote -v && git branch -v

   ls -l ./dotfiles/etc/vim/**
   cd ./dotfiles/etc/vim
   hg paths || git remote -v && git branch -v

   cd ${VIRTUAL_ENV}/src/dotfiles
   # cd $_WRD
   # cdw
   # pip install -e .
   python setup.py develop

* Build

.. code-block:: bash

    # sudo apt-get install make git mercurial

    cd ${VIRTUAL_ENV}/src/dotfiles
    echo $EDITOR
    make build_tags
    make edit
    make test
    make build
    make install

    # pip install -r ./requirements-all.txt
    make pip_install_requirements_all


