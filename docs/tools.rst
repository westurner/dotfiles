
.. _tools:

=======
Tools
=======


Distro Packages
=================
Operating Systems Packaging

Source and/or binary packages to install from a standard archive
with a *signed* manifest containing file signatures of
package files.



RPM Package
~~~~~~~~~~~~~
https://en.wikipedia.org/wiki/RPM_Package_Manager

* Installable with yum, {...}
* Build with TODO: rpmbuild
* Python: build with bdist_rpm, {...}
* List contents::

   # with lesspipe
   less ~/path/to/local.rpm

* Package Repositories (yum):

  * Local: directories of packages and metadata
  * Network: HTTP, HTTPS, RSYNC, FTP


DEB Package
~~~~~~~~~~~~
https://en.wikipedia.org/wiki/Deb_(file_format)

* Installable with apt-get, aptitutde, 
* Build with dpkg
* List contents::

   # with lesspipe
   less ~/path/to/local.deb

* Package Repositories (apt):

  * Local: directories of packages and metadata
  * Network: HTTP, HTTPS, RSYNC, FTP (apt transports)

* Linux/Mac/Windows: Yes / Fink / No

  
Homebrew
~~~~~~~~~~
https://en.wikipedia.org/wiki/Homebrew_(package_management_software)

* Linux/Mac/Windows: No / Yes / No

* Package Recipe Repositories (brew):

  * Local: 
  * Network: HTTP, HTTPS


NuGet
~~~~~~
https://en.wikipedia.org/wiki/NuGet

* Package Repositories (chocolatey):

  * https://chocolatey.org/ 

* Linux/Mac/Windows: No / No / Yes

  
Portage
~~~~~~~~~
https://en.wikipedia.org/wiki/Portage_(software)

* Build recipes with flag sets
* Package Repositories (portage)  


Port Tree
~~~~~~~~~~
Sources and Makefiles designed to compile software packages
for particular distributions' kernel and standard libraries
on a particular platform.


CoreOS Docker Images
~~~~~~~~~~~~~~~~~~~~~
CoreOS schedules redundant docker images and configuration
over etcd, a key-value store with a D-Bus interface.

* Create high availability zone clusters with fleet
* Systemd init files
 



.. _apt:
.. index:: Apt

Apt
=============
| Wikipedia: `<https://en.wikipedia.org/wiki/Advanced_Packaging_Tool>`_
| Homepage: http://alioth.debian.org/projects/apt 
| Docs: https://wiki.debian.org/Apt 
| Docs: https://www.debian.org/doc/manuals/debian-reference/ch02.en.html
| Docs: https://www.debian.org/doc/manuals/apt-howto/
| Source: git git://anonscm.debian.org/git/apt/apt.git
| IRC: irc://irc.debian.org/debian-apt
|

APT is the Debian package management system.

APT retrieves packages over FTP, HTTP, HTTPS, and RSYNC.

.. code-block:: bash

   man apt-get
   man sources.list
   echo 'deb repo_URL distribution component1' >> /etc/apt/sources.list
   apt-get update
   apt-cache show bash
   apt-get install bash
   apt-get upgrade
   apt-get dist-upgrade


.. _bash:
.. index:: Bash

Bash
===============
| Wikipedia: `<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>`_
| Homepage: http://www.gnu.org/software/bash/
| Docs: https://www.gnu.org/software/bash/manual/
| Source: git git://git.savannah.gnu.org/bash.git
|

Bash, the Bourne-again shell.

.. code-block:: bash

   type bash
   bash --help
   help help
   help type
   apropos bash
   info bash
   man bash

* Designed to work with unix command outputs and return codes
* Functions
* Portability: sh (sh, bash, dash, zsh) shell scripts are mostly
  compatible
* Logging::
  
   set -x  # print commands and arguments
   set -v  # print source

Bash Configuration::

   /etc/profile
   /etc/bash.bashrc
   /etc/profile.d/*.sh
   ${HOME}/.profile        /etc/skel/.profile   # PATH=+$HOME/bin  # umask
   ${HOME}/.bash_profile   # empty. preempts .profile

Linux/Mac/Windows: Almost Always / Bash 3.2 / Cygwin/Mingwin


.. index:: Compiz
.. _compiz:   

Compiz
=======
| Wikipedia: https://en.wikipedia.org/wiki/Compiz
| Homepage: https://launchpad.net/compiz
| Docs: http://wiki.compiz.org/
| Source: bzr branch lp:compiz
|

Linux/Mac/Windows: Yes / No / No


.. _dpkg:
.. index:: Dpkg

Dpkg
==============
| Wikipedia: `<https://en.wikipedia.org/wiki/Dpkg>`_
| Homepage: http://wiki.debian.org/Teams/Dpkg
| Docs: `<https://en.wikipedia.org/wiki/Debian_build_toolchain>`_
| Docs: `<https://en.wikipedia.org/wiki/Deb_(file_format)>`_
|

Lower-level package management scripts for creating and working with
.DEB Debian packages.


.. _docker:
.. index:: Docker

Docker
=================
| Wikipedia: `<https://en.wikipedia.org/wiki/Docker_(software)>`_
| Homepage: https://docker.io/
| Docs: http://docs.docker.io/
| Source: https://github.com/dotcloud/docker
|

Docker is an OS virtualization project which utilizes Linux LXC Containers
to partition process workloads all running under one kernel.

Limitations

* Writing to `/etc/hosts`: https://github.com/dotcloud/docker/issues/2267
* Apt-get upgrade: https://github.com/dotcloud/docker/issues/3934


.. _docutils:
.. index:: Docutils

Docutils
===================
| Homepage: http://docutils.sourceforge.net
| Docs: http://docutils.sourceforge.net/docs/
| Docs: http://docutils.sourceforge.net/rst.html 
| Docs: http://docutils.sourceforge.net/docs/ref/doctree.html
| Source: svn http://svn.code.sf.net/p/docutils/code/trunk 
|

Docutils is a text processing system which 'parses" :ref:`ReStructuredText`
lightweight markup language into a doctree which it serializes into
HTML, LaTeX, man-pages, Open Document files, XML, and a number of other
formats.


.. _fhs:
.. index:: Filesystem Hierarchy Standard

Filesystem Hierarchy Standard
=======================================
| Wikipedia: https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
| Website: http://www.linuxfoundation.org/collaborate/workgroups/lsb/fhs
|

The Filesystem Hierarchy Standard is a well-worn industry-supported
system file naming structure.

:ref:`Ubuntu` and :ref:`Virtualenv` implement
a Filesystem Hierarchy.

:ref:`Docker` layers filesystem hierarchies with aufs and now
also btrfs subvolumes.


.. _git:
.. index:: Git

Git
==============
| Wikipedia: `<https://en.wikipedia.org/wiki/Git_(software)>`_
| Homepage: http://git-scm.com/
| Docs: http://git-scm.com/documentation
| Docs: http://documentup.com/skwp/git-workflows-book
| Source: git https://github.com/git/git
|

Git is a distributed version control system for tracking a branching
and merging repository of file revisions.


.. index:: Gnome
.. _gnome:   

Gnome
======
| Wikipedia: https://en.wikipedia.org/wiki/GNOME
| Homepage: http://www.gnome.org/
| Docs: https://help.gnome.org/
| Source: https://git.gnome.org/browse/
|

* https://wiki.gnome.org/GnomeLove


.. _go:
.. index:: Go

Go
=============
| Wikipedia: `<https://en.wikipedia.org/wiki/Go_(programming_language)>`_
| Homepage: http://golang.org/
| Docs: http://golang.org/doc/
| Source: hg https://code.google.com/p/go/
|

Go is a relatively new statically-typed C-based language.


.. index:: Htop
.. _htop:

Htop
=====
| Wikipedia: https://en.wikipedia.org/wiki/Htop
| Homepage: http://hisham.hm/htop/
| Source: git http://hisham.hm/htop/
|


.. index:: i3wm
.. _i3wm:

I3wm
=========
| Wikipedia: `<https://en.wikipedia.org/wiki/I3_(window_manager)>`__
| Homepage: http://i3wm.org/
| Docs: http://i3wm.org/docs/
| Source: git git://code.i3wm.org/i3 
|

* http://i3wm.org/downloads/


.. index:: IPython
.. _IPython:

IPython
========
| Wikipedia: https://en.wikipedia.org/wiki/IPython
| Homepage: http://ipython.org/
| Docs: http://ipython.org/ipython-doc/stable/
| Source: git https://github.com/ipython/ipython
|

* https://registry.hub.docker.com/u/ipython
* https://registry.hub.docker.com/u/jupyter
* https://github.com/jupyter


.. _json:
.. index:: Json

JSON
===============
| Wikipedia: https://en.wikipedia.org/wiki/JSON
| Homepage: http://json.org/
|

Parse and indent JSON with :ref:`Python` and :ref:`Bash`::

    cat example.json | python -m json.tool


.. _libcloud:
.. index:: Libcloud

Libcloud
==================
| Homepage: https://libcloud.apache.org/ 
| Docs: https://libcloud.readthedocs.org/
| Docs: https://libcloud.readthedocs.org/en/latest/supported_providers.html
| Source: git git://git.apache.org/libcloud.git
| Source: git https://github.com/apache/libcloud 
|

Apache Libcloud is a :ref:`Python` library
which abstracts and unifies a large number of Cloud APIs for
Compute Resources, Object Storage, Load Balancing, and DNS.


.. _libvirt:
.. index:: Libvirt

Libvirt
=================
| Wikipedia: http://libvirt.org/
| Homepage: http://libvirt.org/
| Docs: http://libvirt.org/docs.html 
| Docs: http://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.virt.html
| Source: git git://libvirt.org/libvirt-appdev-guide.git
|

Libvirt is a system for platform virtualization with
various :ref:`Linux` hypervisors.

* KVM/QEMU
* Xen
* LXC
* OpenVZ
* VirtualBox


.. _linux:
.. index:: Linux

Linux
================
| Wikipedia: https://en.wikipedia.org/wiki/Linux
| Homepage: https://www.kernel.org
| Docs: https://www.kernel.org/doc/
| Source: git https://github.com/torvalds/linux
|

A free and open source operating system kernel written in C.

.. code-block:: bash

   uname -a


.. _make:
.. index:: Make

Make
===============
| Wikipedia: `<https://en.wikipedia.org/wiki/Make_(software)>`_
| Homepage:  https://www.gnu.org/software/make/
| Project: https://savannah.gnu.org/projects/make/ 
| Docs:  https://www.gnu.org/software/make/manual/make.html
| Source: git git://git.savannah.gnu.org/make.git
|

GNU Make is a classic, ubiquitous software build tool
designed for file-based source code compilation.

:ref:`Bash`, :ref:`Python`, and the GNU/:ref:`Linux` kernel
are all built with Make.

Make build task chains are represented in a :ref:`Makefile`.

Pros

* Simple, easy to read syntax
* Designed to build files on disk
* Nesting: ``make -C <path> <taskname>``
* Variable Syntax: ``$(VARIABLE_NAME)``  
* Bash completion: ``make <tab>``
* Python: Parseable with disutils.text_file Text File 
* Logging: command names and values to stdout  

Cons

* Platform Portability: make is not installed everywhere  
* Global Variables: Parametrization with shell scripts
  
* Linux/Mac/Windows: Usually / brew / executable


.. index:: Hg
.. index:: Mercurial
.. _hg:

Mercurial
==========
| Wikipedia: https://en.wikipedia.org/wiki/Mercurial
| Homepage: http://hg.selenic.org/
| Docs: http://mercurial.selenic.com/guide
| Source: hg http://selenic.com/hg
| Source: hg http://hg.intevation.org/mercurial/crew
|

* http://hgbook.red-bean.com/


.. _msgpack:
.. index:: MessagePack

MessagePack
=====================
| Wikipedia: https://en.wikipedia.org/wiki/MessagePack  
| Homepage: http://msgpack.org/ 
|

MessagePack is a data interchange format
with implementations in many languages.

:ref:`Salt` 


.. _packer:
.. index:: Packer

Packer
=================
| Homepage: http://www.packer.io/
| Docs: http://www.packer.io/docs
| Docs: http://www.packer.io/docs/basics/terminology.html
| Source: git https://github.com/mitchellh/packer
|

Packer generates machine images for multiple platforms, clouds,
and hypervisors from a parameterizable template.

.. glossary::

   Packer Artifact
      Build products: machine image and manifest

   Packer Template
      JSON build definitions with optional variables and templating

   Packer Build
      A task defined by a JSON file containing build steps
      which produce a machine image

   Packer Builder
      Packer components which produce machine images
      for one of many platforms:

      - VirtualBox
      - Docker
      - OpenStack
      - GCE
      - EC2
      - VMware
      - QEMU (KVM, Xen)
      - http://www.packer.io/docs/templates/builders.html

   Packer Provisioner
      Packer components for provisioning machine images at build time

      - Shell scripts
      - File uploads
      - ansible
      - chef
      - solo
      - puppet
      - salt

   Packer Post-Processor
      Packer components for compressing and uploading built machine images



.. _perl:
.. index:: Perl

Perl
===============
| Wikipedia: https://en.wikipedia.org/wiki/Perl
| Homepage: http://www.perl.org/
| Project: http://dev.perl.org/perl5/ 
| Docs: http://www.perl.org/docs.html
| Source: git git://perl5.git.perl.org/perl.git
|


Perl is a dynamically typed, C-based scripting language.

Many of the Debian system management tools are or were originally written
in Perl.


.. _python:
.. index:: Python

Python
=================
| Wikipedia: `<https://en.wikipedia.org/wiki/Python_(programming_language)>`_
| Homepage: https://www.python.org/
| Docs: https://docs.python.org/2/
| Docs: https://docs.python.org/3/
| Docs: https://docs.python.org/devguide/
| Docs: https://docs.python.org/devguide/documenting.html
| Source: hg https://hg.python.org/cpython
|

Python is a dynamically-typed, C-based scripting language.

Many of the RedHat system management tools are or were originally written
in Python.

:ref:`Pip`, :ref:`Sphinx`, :ref:`Salt`, :ref:`Tox`, :ref:`Virtualenv`,
and :ref:`Virtualenvwrapper` are all written in Python.


awesome-python-testing
~~~~~~~~~~~~~~~~~~~~~~~~
| Homepage: https://westurner.github.io/wiki/awesome-python-testing.html
| Source: https://github.com/westurner/wiki/blob/master/awesome-python-testing.rest
|


.. _python-package:
.. index:: Python Package

Python Package
========================
Archive of source and/or binary files containing a setup.py.

A setup.py calls a ``distutils.setup`` or ``setuptools.setup`` function
with package metadata fields like name, version, maintainer name,
maintainer email, and home page;
as well as package requirements: lists of
package names and version specifiers in ``install_requires`` and
``tests_require``, and a dict for any ``extras_require`` such
that '``easy_install setup.py``, ``python setup.py install``,
and ``pip install --upgrade pip`` can all retrieve versions of
packages which it depends on.


* Distutils is in the Python standard library
* Setuptools is widely implemented: ``easy_install``
* Setuptools can be installed with ``python ez_setup.py``
* Setuptools can be installed with a system package manager (apt, yum)
* Python packages are tested and repackaged by package maintainers
* Python packages are served from a package index
* PyPi is the Python Community package home  
* Packages are released to PyPi



* Package Repositories (setup.py -> pypi)
* Package Repositories (conda)
* Package Repositories (enpkg)
* Package Repositories (deb/apt, rpm/yum)

* Build RPM and DEB packages from Python packages with setuptools

  * ``python setup.py bdist_rpm --help``
  * ``python setup.py --command-packages=stdeb.command bdist_deb --help``



.. _pip:
.. index:: Pip

Pip
==============
| Wikipedia: `<https://en.wikipedia.org/wiki/Pip_(package_manager)>`_
| Homepage: http://www.pip-installer.org/
| Docs: http://www.pip-installer.org/en/latest/user_guide.html 
| Docs: https://pip.readthedocs.org/en/latest/
| Docs: http://packaging.python.org/en/latest/
| Source: git https://github.com/pypa/pip
| Pypi: https://pypi.python.org/pypi/pip
| IRC: #pypa
| IRC: #pypa-dev
|

Pip is a tool for working with :ref:`Python` packages.

::

   pip help
   pip help install
   pip --version

   sudo apt-get install python-pip
   pip install --upgrade pip

   pip install libcloud
   pip install -r requirements.txt
   pip uninstall libcloud


* Pip retrieves and installs packages from package indexes
* Pip can do uninstall and upgrade
* Pip builds upon distutils and setuptools
* Pip can install from version control repository URLs  
* Pip configuration is in ``${HOME}/.pip/pip.conf``.
* Pip can maintain a local cache of downloaded packages

.. note:: With :ref:`Python` 2, pip is preferable to ``easy_install``
   because Pip installs ``backports.ssl_match_hostname``.

.. glossary::

   Pip Requirements File
      Plaintext list of packages and package URIs to install.

      Requirements files may contain version specifiers (``pip >= 1.5``)

      Pip installs Pip Requirement Files::

         pip install -r requirements.txt
         pip install --upgrade -r requirements.txt
         pip install --upgrade --user --force-reinstall -r requirements.txt

      An example ``requirements.txt`` file::

         # install pip from the default index (PyPi)
         pip
         --index=https://pypi.python.org/simple --upgrade pip

         # Install pip 1.5 or greater from PyPi
         pip >= 1.5

         # Git clone and install pip as an editable develop egg
         -e git+https://github.com/pypa/pip@1.5.X#egg=pip

         # Install a source distribution release from PyPi
         # and check the MD5 checksum in the URL
         https://pypi.python.org/packages/source/p/pip/pip-1.5.5.tar.gz#md5=7520581ba0687dec1ce85bd15496537b

         # Install a source distribution release from Warehouse
         https://warehouse.python.org/packages/source/p/pip/pip-1.5.5.tar.gz

         # Install an additional requirements.txt file
         -r requirements/more-requirements.txt

        
.. index:: Readline
.. _readline:

Readline
=========
| Wikipedia: https://en.wikipedia.org/wiki/GNU_Readline
| Homepage: http://tiswww.case.edu/php/chet/readline/rltop.html
| Docs: http://tiswww.case.edu/php/chet/readline/readline.html
| Docs: http://tiswww.case.edu/php/chet/readline/history.html
| Docs: http://tiswww.case.edu/php/chet/readline/rluserman.html
| Source: ftp ftp://ftp.gnu.org/gnu/readline/readline-6.3.tar.gz
|


* https://pypi.python.org/pypi/gnureadline


.. _restructuredtext:
.. index:: ReStructuredText

ReStructuredText
==========================
| Wikipedia: https://en.wikipedia.org/wiki/ReStructuredText 
| Homepage: http://docutils.sourceforge.net/rst.html 
| Docs: http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html
| Docs: http://docutils.sourceforge.net/docs/ref/rst/directives.html 
| Docs: http://docutils.sourceforge.net/docs/ref/rst/roles.html
| Docs: http://sphinx-doc.org/rest.html
| 

ReStructuredText (RST, ReST) is a plaintext
lightweight markup language commonly used for
narrative documentation and Python docstrings.

:ref:`Sphinx` is built on :ref:`Docutils`, 
which is the primary implementation of ReStructuredText.

Pandoc also supports a form of ReStructuredText.

.. glossary::

   ReStructuredText Directive
      Actionable blocks of ReStructuredText
      
      .. code-block:: rest

         .. include:: goals.rst

         .. contents:: Table of Contents
            :depth: 3

         .. include:: LICENSE


   ReStructuredText Role
      RestructuredText role extensions
      
      .. code-block:: rest

            .. _anchor-name:

            :ref:`Anchor <anchor-name>` 


.. _salt:
.. index:: Salt

Salt
===============
| Wikipedia: `<https://en.wikipedia.org/wiki/Salt_(software)>`_
| Homepage: http://www.saltstack.com
| Docs: http://docs.saltstack.com/en/latest/
| Docs: http://salt.readthedocs.org/en/latest/ref/clients/index.html#python-api 
| Docs: http://docs.saltstack.com/en/latest/topics/development/hacking.html 
| Glossary: http://docs.saltstack.com/en/latest/glossary.html 
| Source: git https://github.com/saltstack/salt
| Pypi: https://pypi.python.org/pypi/salt
| IRC: #salt
|

Salt is an open source configuration management system for managing 
one or more physical and virtual machines running various operating systems.

.. glossary::

   Salt Top File
      Root of a Salt Environment (``top.sls``)

   Salt Environment
      Folder of Salt States with a top.sls top file.

   Salt Bootstrap
      Installer for salt master and/or salt minion 

   Salt Minion
      Daemon process which executes Salt States on the local machine.

      Can run as a background daemon.
      Can retrieve and execute states from a salt master

      Can execute local states in a standalone minion setup::

         salt-call --local grains.items
 
   Salt Minion ID
      Machine ID value uniquely identifying a minion instance
      to a Salt Master.

      By default the minion ID is set to the FQDN
      
      .. code-block:: bash
      
         python -c 'import socket; print(socket.getfqdn())'
      
      The minion ID can be set explicitly in two ways:

      * /etc/salt/minion.conf::
        
         id: devserver-123.example.org
      
      * /etc/salt/minion_id::

         $ hostname -f > /etc/salt/minion_id
         $ cat /etc/salt/minion_id
         devserver-123.example.org

   Salt Master
      Server daemon which compiles pillar data for and executes commands
      on Salt Minions::

         salt '*' grains.items

   Salt SSH
      Execute salt commands and states over SSH without a minion process::

          salt-ssh '*' grains.items

   Salt Grains
      Static system information keys and values
      
      * hostname
      * operating system
      * ip address
      * interfaces

      Show grains on the local system::

         salt-call --local grains.items

   Salt Modules
      Remote execution functions for files, packages, services, commands.

      Can be called with salt-call

   Salt States
      Graphs of nodes and attributes which are templated and compiled into
      ordered sequences of system configuration steps.

      Naturally stored in ``.sls`` :ref:`YAML` files
      parsed by ``salt.states.<state>.py``.

      Salt States files are processed as Jinja templates (by default)
      they can access system-specific grains and pillar data at compile time.

   Salt Renderers
      Templating engines (by default: Jinja) for processing templated
      states and configuration files.

   Salt Pillar
      Key Value data interface for storing and making available
      global and host-specific values for minions:
      values like hostnames, usernames, and keys.
 
      Pillar configuration must be kept separate from states
      (e.g. users, keys) but works the same way.

      In a master/minion configuration, minions do not have access to
      the whole pillar.

   Salt Cloud
      Salt Cloud can provision cloud image, instance, and networking services
      with various cloud providers (libcloud):

      + Google Compute Engine (GCE) [KVM]
      + Amazon EC2 [Xen]
      + Rackspace Cloud [KVM]
      + OpenStack [https://wiki.openstack.org/wiki/HypervisorSupportMatrix]
      + Linux LXC (Cgroups)
      + KVM 


.. _sphinx:
.. index:: Sphinx

Sphinx
=================
| Wikipedia: `<https://en.wikipedia.org/wiki/Sphinx_(documentation_generator)>`_
| Homepage: https://pypi.python.org/pypi/Sphinx
| Docs: http://sphinx-doc.org/contents.html  
| Docs: http://sphinx-doc.org/markup/code.html 
| Docs: http://pygments.org/docs/lexers/
| Docs: http://thomas-cokelaer.info/tutorials/sphinx/rest_syntax.html 
| Source: hg https://bitbucket.org/birkenfeld/sphinx/
| Pypi: https://pypi.python.org/pypi/Sphinx 
|

Sphinx is a tool for working with
:ref:`ReStructuredText` documentation trees
and rendering them into HTML, PDF, LaTeX, ePub,
and a number of other formats.

Sphinx extends :ref:`Docutils` with a number of useful markup behaviors
which are not supported by other ReStructuredText parsers.

Most other ReStructuredText parsers do not support Sphinx directives;
so, for example,

* GitHub and BitBucket do not support Sphinx but do support ReStructuredText
  so README.rst containing Sphinx tags renders in plaintext or raises errors.

  For example, the index page of this
  :ref:`Sphinx` documentation set is generated from
  a file named ``index.rst`` and referenced by ``docs/conf.py``.

  * Input: https://raw.githubusercontent.com/westurner/provis/master/docs/index.rst 
  * Output: https://github.com/westurner/provis/blob/master/docs/index.rst 
  * Output: :ref:`ReadTheDocs` http://provis.readthedocs.org/en/latest/

.. glossary::

   Sphinx Builder
      Render Sphinx :ref:`ReStructuredText` into various forms:

         * HTML
         * LaTeX
         * PDF
         * ePub
    
      See: `Sphinx Builders <http://sphinx-doc.org/builders.html>`_

   Sphinx ReStructuredText
      Sphinx extends :ref:`ReStructuredText` with roles and directives
      which only work with Sphinx.

   Sphinx Directive
      Sphinx extensions of :ref:`Docutils` :ref:`ReStructuredText` directives.

      Most other ReStructuredText parsers do not support Sphinx directives.

      .. code-block:: rest

         .. toctree::

            readme
            installation
            usage

      See: `Sphinx Directives <http://sphinx-doc.org/rest.html#directives>`_

   Sphinx Role
      Sphinx extensions of :ref:`Docutils` :ref:`RestructuredText` roles
      
      Most other ReStructured

      .. code-block:: rest

            .. _anchor-name:

            :ref:`Anchor <anchor-name>`        


.. _ruby:
.. index:: Ruby

Ruby
===============
| Wikipedia: `<https://en.wikipedia.org/wiki/Ruby_(programming_language)>`_
| Homepage: https://www.ruby-lang.org/
| Docs: https://www.ruby-lang.org/en/documentation/
| Source: svn http://svn.ruby-lang.org/repos/ruby/trunk
|

Ruby is a dynamically-typed programming language.

:ref:`Vagrant` is written in Ruby.


.. index:: RubyGems
.. _rubygems:   

RubyGems
=========
| Wikipedia: https://en.wikipedia.org/wiki/RubyGems
| Homepage: https://rubygems.org/
| Docs: http://guides.rubygems.org/
| Source: https://github.com/rubygems/rubygems
|


.. _tox:
.. index:: Tox

Tox
==============
| Homepage: https://testrun.org/tox/
| Docs: https://tox.readthedocs.org
| Source: hg https://bitbucket.org/hpk42/tox
| Pypi: https://pypi.python.org/pypi/tox
|

Tox is a build automation tool designed to build and test Python projects
with multiple language versions and environments
in separate :ref:`virtualenvs <virtualenv>`.

Run the py27 environment::

   tox -v -e py27
   tox --help


.. _ubuntu:
.. index:: Ubuntu

Ubuntu
=================
| Wikipedia: `<https://en.wikipedia.org/wiki/Ubuntu_(operating_system)>`_
| Homepage: http://www.ubuntu.com/
| Docs: https://help.ubuntu.com/
| Source: https://launchpad.net/ubuntu 
| Source: http://archive.ubuntu.com/
| Source: http://releases.ubuntu.com/
|

.. _vagrant:
.. index:: Vagrant

Vagrant
==================
| Wikipedia: `<https://en.wikipedia.org/wiki/Vagrant_(software)>`_
| Homepage: http://www.vagrantup.com/
| Docs: http://docs.vagrantup.com/v2/
| Source: git https://github.com/mitchellh/vagrant
|

Vagrant is a tool for creating and managing virtual machine instances
with CPU, RAM, Storage, and Networking.

* Vagrant:

  * provides helpful commandline porcelain on top of
    :ref:`VirtualBox` ``VboxManage``
  * 

::

   vagrant help
   vagrant status
   vagrant init ubuntu/trusty64
   vagrant up
   vagrant ssh
   $EDITOR Vagrantfile
   vagrant provision
   vagrant halt
   vagrant destroy

.. glossary::

   Vagrantfile
      Vagrant script defining a team of one or more
      virtual machines and networks.

      Create a Vagrantfile::

         vagrant init [basebox]
         cat Vagrantfile

      Start virtual machines and networks defined in the Vagrantfile::

         vagrant status
         vagrant up

   Vagrant Box
      Vagrant base machine virtual machine image.

      There are many baseboxes for various operating systems.

      Essentially a virtual disk plus CPU, RAM, Storage, and Networking
      metadata.

      Locally-stored and cached vagrant boxes can be listed with::

         vagrant help box
         vagrant box list

      A running vagrant environment can be packaged into a new box with::

         vagrant package

      :ref:`Packer` generates :ref:`VirtualBox` Vagrant Boxes
      with a Post-Processor.

   Vagrant Cloud
      Vagrant-hosted public Vagrant Box storage.
      
      Install a box from Vagrant cloud::

         vagrant init ubuntu/trusty64
         vagrant up
         vagrant ssh

   Vagrant Provider
      A driver for running Vagrant Boxes with a hypervisor or in a cloud.

      The Vagrant :ref:`VirtualBox` Provider is well-supported.

      With Plugins: https://github.com/mitchellh/vagrant/wiki/Available-Vagrant-Plugins

      See also: :ref:`libcloud`.

   Vagrant Provisioner
      Set of hooks to install and run shell scripts and
      configuration managment tools over ``vagrant ssh``.

      Vagrant up runs ``vagrant provision`` on first invocation of
      ``vagrant up``.

      ::

         vagrant provision

 
.. note:: Vagrant configures a default NFS share mounted at ``/vagrant``.


.. note:: Vagrant adds a default NAT Adapter as eth0; presumably for
   DNS, the default route, and to ensure ``vagrant ssh`` connectivity.


.. _vim:
.. index:: Vim

Vim
====
| Wikipedia: `<https://en.wikipedia.org/wiki/Vim_(text_editor)> __
| Homepage: http://www.vim.org/
| Docs: http://www.vim.org/docs.php
| Source: hg https://vim.googlecode.com/hg/
|

* https://github.com/scrooloose/nerdtree
* https://github.com/westurner/dotvim


.. _vimium:
.. index:: Vimium   

Vimium
=======
| Wikipedia: https://en.wikipedia.org/wiki/Vimium
| Homepage: https://vimium.github.io/
| Source: git https://github.com/philc/vimium
|

* https://chrome.google.com/webstore/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb?hl=en


.. _vimperator:
.. index:: Vimperator

Vimperator
===========
| Wikipedia: https://en.wikipedia.org/wiki/Vimperator
| Homepage: http://www.vimperator.org/
| Source: https://github.com/vimperator/vimperator-labs
|

* https://addons.mozilla.org/en-US/firefox/addon/vimperator/


Wasavi
=======
| Homepage: http://appsweets.net/wasavi/
| Docs: http://appsweets.net/wasavi/
| Source: https://github.com/akahuku/wasavi
|


* https://chrome.google.com/webstore/detail/dgogifpkoilgiofhhhodbodcfgomelhe
* https://addons.opera.com/en/extensions/details/wasavi/
* https://addons.mozilla.org/en-US/firefox/addon/wasavi/



.. _virtualbox:
.. index:: VirtualBox

VirtualBox
=====================
| Wikipedia: https://en.wikipedia.org/wiki/VirtualBox
| Homepage: https://www.virtualbox.org/
| Docs: https://www.virtualbox.org/wiki/Documentation
| Source: svn svn://www.virtualbox.org/svn/vbox/trunk
|

Oracle VirtualBox is a platform virtualization package
for running one or more guest VMs (virtual machines) within a host system.

VirtualBox:

* runs on many platforms: :ref:`Linux`, OSX, Windows
* has support for full platform NX/AMD-v virtualization
* requires matching kernel modules

:ref:`Vagrant` scripts VirtualBox.


.. _virtualenv:
.. index:: Virtualenv

Virtualenv
====================
| Homepage: http://www.virtualenv.org
| Docs: http://www.virtualenv.org/en/latest/ 
| Source: git https://github.com/pypa/virtualenv
| PyPI: https://pypi.python.org/pypi/virtualenv 
| IRC: #pip
|

Virtualenv is a tool for creating reproducible :ref:`Python` environments.

Virtualenv sets the shell environment variable $VIRTUAL_ENV when active.

Paths within a virtualenv are more-or-less :ref:`FSH
<filesystem_hierarchy_standard>` standard paths, making
virtualenv structure very useful for building
chroot and container overlays.

A standard virtual environment::

   bin/           # pip, easy_install, console_scripts
   bin/activate   # source bin/activate to work on a virtualenv
   include/       # (symlinks to) dev headers (python-dev/python-devel)
   lib/           # libraries
   lib/python2.7/site-packages/  # pip and easy_installed packages
   local/         # symlinks to bin, include, and lib

   src/           # pip installs editable requirements here

   # also useful
   etc/           # configuration
   var/log        # logs
   var/run        # sockets, PID files
   tmp/           # mkstemp temporary files with permission bits
   srv/           # local data

:ref:`Virtualenvwrapper` wraps virtualenv. In the following
code shell example, comments with ``##`` are virtualenvwrapper

.. code-block:: bash

   # Print Python site settings
   python -m site

   # Create a virtualenv
   cd $WORKON_HOME
   virtualenv example
   source ./example/bin/activate
   ## mkvirtualenv example
   ## workon example

   # Review virtualenv Python site settings
   python -m site

   # List files in site-packages
   ls -altr $VIRTUAL_ENV/lib/python*/site-packages/**
   ## (cdsitepackages && ls -altr **)
   ## lssitepackages -altr **


.. _virtualenvwrapper:
.. index:: Virtualenvwrapper

Virtualenvwrapper
===========================
| Docs: http://virtualenvwrapper.readthedocs.org/en/latest/
| Source: hg https://bitbucket.org/dhellmann/virtualenvwrapper
| PyPI: https://pypi.python.org/pypi/virtualenvwrapper
|

Virtualenvwrapper is a tool which extends virtualenvwrapper.

Virtualenvwrapper provides a number of
useful shell commands and python functions
for working with and within :ref:`virtualenvs <virtualenv>`,
as well as project event scripts (e.g. ``postactivate``, ``postmkvirtualenv``)
and two filesystem configuration variables
useful for structuring
development projects of any language within :ref:`virtualenvs <virtualenv>`:
``$PROJECT_HOME`` and ``$WORKON_HOME``.

Virtualenvwrapper is sourced into the shell::

   # pip install --user --upgrade virtualenvwrapper
   source ~/.local/bin/virtualenvwrapper.sh

   # sudo apt-get install virtualenvwrapper
   source /etc/bash_completion.d/virtualenvwrapper


.. code-block:: bash

   echo $PROJECT_HOME; echo ~/wrk        # default: ~/workspace
   echo $WORKON_HOME;  echo ~/wrk/.ve    # default: ~/.virtualenvs

   mkvirtualenv example
   workon example
   cdvirtualenv ; ls
   mkdir src ; cd src/

   cdsitepackages
   lssitepackages


   deactivate
   rmvirtualenv example



.. _yaml:
.. index:: YAML

YAML
==============
| Wikipedia: https://en.wikipedia.org/wiki/YAML 
| Homepage: http://yaml.org
|

YAML ("YAML Ain't Markup Language") is a concise data serialization format.


Most :ref:`Salt` states and pillar data are written in YAML. Here's an
example ``top.sls`` file:

.. code-block:: yaml

   base:
    '*':
      - openssh
    '*-webserver':
      - webserver
    '*-workstation':
      - gnome
      - i3



.. _zsh:
.. index:: ZSH

ZSH
====
| Wikipedia: https://en.wikipedia.org/wiki/Z_shell
| Docs: http://zsh.sourceforge.net/Guide/zshguide.html
| Docs: http://zsh.sourceforge.net/Doc/
| Homepage: http://www.zsh.org/
| Source: git git://git.code.sf.net/p/zsh/code
|

* https://github.com/robbyrussell/oh-my-zsh
