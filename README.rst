
westurner/tools
=================

| Docs: https://westurner.github.io/tools/
| Src: https://github.com/westurner/tools

Tools Documentation

Objectives:

- [ ] OBJ1: Document Tools as RST
- [ ] OBJ2: Document Tools as RDF
- [ ] OBJ3: Document Tools as JSON-LD

Tasks:

.. code:: bash

    source $__DOTFILES/etc/.bashrc

    setup() {
       we westurner tools;
       cdsrc; git clone https://github.com/westurner/tools
    }
    pull() {
       cdsrc;
       mv dotfiles/tools.rst tools/tools.rst
       # dotfiles, wrdrd, 
    }
    PROJECT_FILES="Makefile conf.py tools.rst tools.rest"
    e $PROJECT_FILES

- [ ] BLD: Makefile: ln *.rest <-> *.rst for
      Sphinx subtree/subrepo/remote use with GitHub wiki
