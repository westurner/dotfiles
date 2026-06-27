
.. index:: Changelog
.. _changelog:

.. include:: ../CHANGELOG.rst


Git Commit Log
================
| Releases: https://github.com/westurner/dotfiles/commits/master
| Development: https://github.com/westurner/dotfiles/commits/develop

``make docs`` calls ``make help_bash_txt``
and ``make help_zsh_txt`` to aggregate initial configuration
into one file (sans line numbers) for debugging
and docstring extraction:

* `src/dotfiles/venv/ipython_config.py <https://github.com/westurner/dotfiles/blame/master/src/dotfiles/venv/ipython_config.py>`__
* `etc/bash <https://github.com/westurner/dotfiles/commits/master/etc/bash>`__
* `scripts/_dotfiles_bash.log.sh <https://github.com/westurner/dotfiles/commits/develop/scripts/_dotfiles_bash.log.sh>`__
* `etc/zsh <https://github.com/westurner/dotfiles/commits/master/etc/zsh>`__
* `scripts/_dotfiles_zsh.log.sh <https://github.com/westurner/dotfiles/commits/develop/scripts/_dotfiles_zsh.log.sh>`__

.. code:: bash


   git shortnocolor --graph
   git l
   gl

.. command-output:: test -d ../.git && \
   git -C ../ log --pretty=format:"%h %d %ci [%cn]%n%s" --graph
   :shell:
