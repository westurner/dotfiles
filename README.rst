
===========
dotfiles
===========

`GitHub`_ | `BitBucket`_ | `ReadTheDocs`_

.. _GitHub: https://github.com/westurner/dotfiles
.. _BitBucket: https://bitbucket.org/westurner/dotfiles
.. _ReadTheDocs: https://wrdfiles.readthedocs.org/en/latest/

**Bash scripts**, **Python scripts**, and **configuration files**
for working with projects on \*nix platforms in Bash, ZSH, Ruby, and Python.


Goals
=======
* Streamline frequent workflows
* Configure bash and vim
* Support Debian/Ubuntu, OSX 
* Document keyboard shortcuts


Quickstart
===========
The bootstrap shell script clones this repository and
and installs files from this python package.

These instructions assume python, pip, and setuptools are already installed.

There are examples of installing python, pip, and setuptools both in
``scripts/bootstrap_dotfiles.sh`` and the ``Makefile``.


Install dotfiles python package with pip::

    pip install -e git+https://github.com/westurner/dotfiles#egg=dotfiles

Create symlinks from ~/.dotfiles/etc to ~/::

    bash ./dotfiles/scripts/bootstrap_dotfiles.sh -S

