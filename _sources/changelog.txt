
.. index:: Changelog
.. _changelog:

.. include:: ../CHANGELOG.rst


Git Commit Log
================
| Releases: https://github.com/westurner/dotfiles/commits/master
| Development: https://github.com/westurner/dotfiles/commits/develop

.. command-output:: test -d ../.git && \
   git -C ../ log --pretty=format:'%h %cr %cn %s' --graph \
   # git shortnocolor --graph \
   # git l \
   $ gl
   :shell:
