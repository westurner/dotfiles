

dotfiles
+++++++++++
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

Install dotfiles python package into ~/.local with pip::

    git clone https://github.com/westurner/dotfiles
    pip install --user -e ./dotfiles
    python -m site
