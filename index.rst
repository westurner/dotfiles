

.. index:: westurner/tools
.. index:: Tools
.. _tools:

================
Tools
================

| Docs: https://westurner.org/tools/
| Src: https://github.com/westurner/tools

See Also: https://westurner.org/wiki/projects#tools


.. index:: Packages
.. _packages:

Packages
==========
| Wikipedia: `<https://en.wikipedia.org/wiki/Package_(package_management_system)>`__


A software package is an archive of files
with a manifest that lists the files included.
Often, the manifest contains file checksums
and a *signature*.

Many packaging tools make a distinction between source
and/or binary packages.

Some packaging tools provide configuration options for:

* Scripts to run when packaging
* Scripts to run at install time
* Scripts to run at uninstal time
* Patches to apply to the "*vanilla*" source tree,
  as might be obtained from a version control repository

There is a package maintainer whose responsibilities include:

* Testing new *upstream* releases
* *Vetting* changes from release to release
* *Repackaging* upstream releases
* *Signing* new package releases

*Packaging lag* refers to how long it takes a package maintainer
to repackage upstream releases for the target platform(s).


.. index:: Anaconda
.. _anaconda:

Anaconda
~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Anaconda_(Python_distribution)>`__
| Homepage: https://store.continuum.io/cshop/anaconda/
| Docs: http://docs.continuum.io/anaconda/
| Docs: http://docs.continuum.io/anaconda/pkg-docs.html


Anaconda is a maintained distribution of many popular :ref:`Python Packages`.

Anaconda works with :ref:`Conda` packages.

.. note:: `<https://en.wikipedia.org/wiki/Anaconda_(installer)>`__ (1999)
   is the installer for :ref:`RPM`-based :ref:`Linux` distributions; which is
   also written in :ref:`Python` (and :ref:`C`).


.. index:: APT
.. _apt:

APT
~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Advanced_Packaging_Tool>`_
| Homepage: https://alioth.debian.org/projects/apt
| Docs: https://wiki.debian.org/Apt
| Docs: https://www.debian.org/doc/manuals/debian-reference/ch02.en.html
| Docs: https://www.debian.org/doc/manuals/apt-howto/
| Docs: https://wiki.debian.org/SecureApt
| Source: git git://anonscm.debian.org/git/apt/apt.git
| IRC: irc://irc.debian.org/debian-apt


APT ("Advanced Packaging Tool") is the core of Debian package management.

An APT package repository serves :ref:`DEB` packages created with :ref:`Dpkg`.

An APT package repository can be accessed from a local filesystem
or over a network protocol ("apt transports") like HTTP, HTTPS, RSYNC, FTP,
and BitTorrent.

An example of APT usage
(e.g. to maintain an updated :ref:`Ubuntu` :ref:`Linux` system):

.. code-block:: bash

   apt-get update
   apt-get upgrade
   apt-get dist-upgrade

   apt-cache show bash
   apt-get install bash

   apt-get --help
   man apt-get
   man sources.list


.. index:: Bower
.. _bower:

Bower
~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Bower_(software)>`__
| Homepage: https://www.bower.io/
| Source: https://github.com/bower/bower


Bower is "a package manager for the web" (:ref:`Javascript` packages)
built on :ref:`NPM`.


.. index:: Cabal
.. _cabal:

Cabal
~~~~~~
| Homepage: https://www.haskell.org/cabal/
| Docs: http://hackage.haskell.org/
| Docs: https://www.haskell.org/cabal/users-guide/
| Docs: https://www.haskell.org/cabal/release/cabal-latest/doc/API/Cabal/

Cabal is a package manager for :ref:`Haskell` packages.

Hackage is the community Cabal package index: https://hackage.haskell.org/


.. index:: DEB
.. _deb:

DEB
~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Deb_(file_format)>`__


DEB is the Debian software package format.

DEB packages are built with :ref:`dpkg` and often hosted in an :ref:`APT`
package repository.

.. index:: Dpkg
.. _dpkg:

Dpkg
~~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Dpkg>`_
| Homepage: https://wiki.debian.org/Teams/Dpkg
| Docs: `<https://en.wikipedia.org/wiki/Debian_build_toolchain>`_
| Docs: https://www.debian.org/doc/manuals/debian-faq/ch-pkg_basics.en.html
| Docs: https://www.debian.org/doc/manuals/debian-faq/ch-pkgtools.en.html
| Docs:


Dpkg is a collection of tools for creating and working with
:ref:`DEB` packages.


.. index:: Brew
.. index:: Homebrew
.. _homebrew:

Homebrew
~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Homebrew_(package_management_software)>`__
| Homepage: http://brew.sh/


Homebrew is a package manager (``brew``) for :ref:`OSX`.


.. index:: NPM
.. index:: Node Package Manager
.. _npm:

NPM
~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Npm_(software)>`__
| Homepage: https://www.npmjs.org/
| Source: https://github.com/npm/npm


NPM is a :ref:`Javascript` package manager created for :ref:`Node.js`.

:ref:`Bower` builds on NPM.


.. index:: NuGet
.. _nuget:

NuGet
~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/NuGet
| Homepage: https://www.nuget.org/


* Package Repositories (chocolatey):

  * https://chocolatey.org/

* Linux/Mac/Windows: No / No / Yes


.. index:: Portage
.. _portage:

Portage
~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Portage_(software)>`__
| Homepage: http://wiki.gentoo.org/wiki/Project:Portage


* Build recipes with flag sets
* Package Repositories (portage)


.. index:: Ports
.. _ports:

Ports
~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Ports_collection
| Homepage: https://www.freebsd.org/ports/


Sources and Makefiles designed to compile software packages
for particular distributions' kernel and standard libraries
on a particular platform.


.. index:: RPM
.. _rpm:

RPM
~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/RPM_Package_Manager


* Install with ``rpm``, ``yum``
* Build with tools like ``rpmbuild`` and ``fpm``
* Python: build with ``bdist_rpm``, ``fpm``
* List contents::

   less ~/path/to/local.rpm   # requires lesspipe to be configured

* Package Repositories (yum):

  * Local: directories of packages and metadata
  * Network: HTTP, HTTPS, RSYNC, FTP


.. index:: Egg
.. index:: Python Egg
.. index:: Python Packages
.. _python packages:

Python Packages
~~~~~~~~~~~~~~~~~~~~~~~~
| Homepage: https://pypi.python.org/pypi
| Docs: https://packaging.python.org/en/latest/
| Docs: https://packaging.python.org/en/latest/peps.html
| Docs: https://packaging.python.org/en/latest/projects.html

A Python Package is a collection of source code and package data files.

* Python packages have dependencies: they depend on other packages
* Python packages can be served from a package index
* :ref:`PyPI` is the community Python Package Index
* A Python package is an archive of files
  (``.zip`` (``.egg``, ``.whl``), ``.tar``, ``.tar.gz``,)
  containing a ``setup.py`` file
  containing a version string and metadata that is meant for distribution.
* An source dist (``sdist``) package contains source code
  (every file listed in or matching a pattern in a ``MANIFEST.in`` text file).
* A binary dist (``bdist``, ``bdist_egg``, ``bdist_wheel``)
  is derived from an sdist and may be compiled and named
  for a specific platform.
* sdists and bdists are defined by a ``setup.py`` file
  which contains a call to a
  ``distutils.setup()`` or ``setuptools.setup()`` function.
* The arguments to the ``setup.py`` function are things like
  ``version``, ``author``, ``author_email``, and ``homepage``;
  in addition to package dependency strings required for the package to work
  (``install_requires``), for tests to run (``tests_require``),
  and for optional things to work (``extras_require``).
* A package dependency string can specify an exact version (``==``)
  or a greater-than (``>=``) or less-than (``<=``) requirement
  for each package.
* Package names are looked up from an index server (``--index``),
  such as :ref:`PyPI`,
  and or an HTML page (``--find-links``) containing URLs
  containing package names, version strings, and platform strings.
* ``easy_install`` (:ref:`setuptools`) and :ref:`pip` can install packages
  from: the local filesystem, a remote index server, or a local index server.
* ``easy_install`` and ``pip`` read the ``install_requires``
  (and ``extras_require``) attributes of ``setup.py`` files
  contained in packages in order to resolve a dependency graph
  (which can contain cycles) and install necessary packages.




.. index:: distutils
.. _distutils:

Distuils
+++++++++
| Docs: https://docs.python.org/2/distutils/

Distutils is a collection of tools for common packaging needs.

Distutils is included in the Python standard library.


.. index:: setuptools
.. _setuptools:

Setuptools
++++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Setuptools
| Docs: https://pythonhosted.org/setuptools/
| Source: hg https://bitbucket.org/pypa/setuptools
| PyPI: https://pypi.python.org/pypi/setuptools


Setuptools is a :ref:`Python package <python packages>` for working with other
:ref:`Python Packages`.

* Setuptools builds upon :ref:`distutils`
* Setuptools is widely implemented
* Most Python packages are installed by setuptools (by :ref:`Pip`)
* Setuptools can be installed by downloading ``ez_setup.py``
  and then running ``python ez_setup.py``; or,
  setuptools can be installed with a system package manager (apt, yum)
* Setuptools installs a script called ``easy_install`` which can
  be used to install packages from the local filesystem,
  a remote index server, a local index server, or an HTML page
* ``easy_install pip`` installs :ref:`Pip` from PyPI
* Like ``easy_install``, :ref:`Pip` installs python packages,
  with a number of additional configuration options
* Setuptools can build :ref:`RPM` and :ref:`DEB` packages
  from python packages, with some extra configuration::

    python setup.py bdist_rpm --help
    python setup.py --command-packages=stdeb.command bdist_deb --help


.. index:: Pip
.. _pip:

Pip
++++++++++++++
| Wikipedia: `<https://en.wikipedia.org/wiki/Pip_(package_manager)>`_
| Homepage: https://pip.pypa.io/
| Docs: https://pip.pypa.io/en/latest/user_guide.html
| Docs: https://pip.readthedocs.org/en/latest/
| Source: git https://github.com/pypa/pip
| Pypi: https://pypi.python.org/pypi/pip
| IRC: #pypa
| IRC: #pypa-dev


Pip is a tool for installing, upgrading, and uninstalling
:ref:`Python` packages.

::

   pip help
   pip help install
   pip --version

   sudo apt-get install python-pip
   pip install --upgrade pip

   pip install libcloud
   pip install -r requirements.txt
   pip uninstall libcloud


* Pip stands upon :ref:`distutils` and :ref:`setuptools`.
* Pip retrieves, installs, upgrades, and uninstalls packages.
* Pip can list installed packages with ``pip freeze`` (and ``pip
  list``).
* Pip can install packages as 'editable' packages (``pip install -e``)
  from version control repository URLs
  which must begin with ``vcs+``,
  end with ``#egg=<usuallythepackagename>``,
  and may contain an ``@vcstag`` tag
  (such as a branch name or a version tag).
* Pip installs packages as editable by first
  cloning (or checking out) the code to ``./src``
  (or ``${VIRTUAL_ENV}/src`` if working in a :ref:`virtualenv`)
  and then running ``setup.py develop``.
* Pip configuration is in ``${HOME}/.pip/pip.conf``.
* Pip can maintain a local cache of downloaded packages,
  which can lessen the load on package servers during testing.
* Pip skips reinstallation if a package requirement is already
  satisfied.
* Pip requires the ``--upgrade`` and/or ``--force-reinstall`` options
  to be added to the ``pip install`` command in order to upgrade
  or reinstall.
* At the time of this writing, the latest stable pip version is
  ``1.5.6``.

.. warning::
   With :ref:`Python` 2, pip is preferable to
   :ref:`setuptools`'s ``easy_install``
   because pip installs ``backports.ssl_match_hostname``
   in order to validate ``HTTPS`` certificates
   (by making sure that the certificate hostname matches the hostname
   from which the DNS resolved to).

   Cloning packages from source repositories over ``ssh://``
   or ``https://``,
   either manually or with ``pip install -e`` avoids this concern.

   There is also a tool called :ref:`peep` which
   requires considered-good SHA256 checksums to be specified
   for every dependency listed in a ``requirements.txt`` file.

   For more information, see:
   http://legacy.python.org/dev/peps/pep-0476/#python-versions

.. glossary::

   Pip Requirements File
      Plaintext list of packages and package URIs to install.

      Requirements files may contain version specifiers (``pip >= 1.5``)

      Pip installs Pip Requirement Files::

         pip install -r requirements.txt
         pip install --upgrade -r requirements.txt
         pip install --upgrade --user --force-reinstall -r requirements.txt

      An example ``requirements.txt`` file::

         # install pip from the default index (PyPI)
         pip
         --index=https://pypi.python.org/simple --upgrade pip

         # Install pip 1.5 or greater from PyPI
         pip >= 1.5

         # Git clone and install pip as an editable develop egg
         -e git+https://github.com/pypa/pip@1.5.X#egg=pip

         # Install a source distribution release from PyPI
         # and check the MD5 checksum in the URL
         https://pypi.python.org/packages/source/p/pip/pip-1.5.5.tar.gz#md5=7520581ba0687dec1ce85bd15496537b

         # Install a source distribution release from Warehouse
         https://warehouse.python.org/packages/source/p/pip/pip-1.5.5.tar.gz

         # Install an additional requirements.txt file
         -r requirements/more-requirements.txt

.. index:: Peep
.. _peep:

Peep
+++++
| Source: https://github.com/erikrose/peep
| PyPI: https://pypi.python.org/pypi/peep


Peep works just like :ref:`pip`, but requires ``SHA256`` checksum hashes
to be specified for each package in ``requirements.txt`` file.


.. index:: Python Package Index
.. index:: PyPI
.. _pypi:

PyPI
++++++
| Wikipedia: https://en.wikipedia.org/wiki/Python_Package_Index
| Docs: https://wiki.python.org/moin/CheeseShop
| Docs: https://wiki.python.org/moin/CheeseShopDev
| Homepage: https://pypi.python.org/pypi
| Source: https://bitbucket.org/pypa/pypi


PyPI is the Python Package Index.


.. index:: Warehouse
.. _warehouse:

Warehouse
++++++++++
| Homepage: https://warehouse.python.org/
| Docs: https://warehouse.readthedocs.org/en/latest/
| Source: https://github.com/pypa/warehouse


Warehouse is the "Next Generation Python Package Repository".

All packages uploaded to :ref:`PyPI` are also available from Warehouse.


.. index:: Python Wheel
.. index:: Wheel
.. _wheel:

Wheel
++++++
| Docs: http://legacy.python.org/dev/peps/pep-0427/
| Docs: http://wheel.readthedocs.org/en/latest/
| Source: hg https://bitbucket.org/pypa/wheel/
| PyPI: https://pypi.python.org/pypi/wheel


* Wheel is a newer, PEP-based standard (``.whl``) with a different
  metadata format, the ability to specify (JSON) digital signatures
  for a package within the package, and a number
  of additional speed and platform-consistency advantages.
* Wheels can be uploaded to PyPI.
* Wheels are generally faster than traditional Python packages.

Packages available as wheels are listed at `<http://pythonwheels.com/>`__.


.. index:: Conda Package
.. index:: Conda
.. _conda:

Conda
+++++++
| Docs: http://conda.pydata.org/docs/
| Source: git https://github.com/conda/conda
| PyPI: https://pypi.python.org/pypi/conda


* Conda installs packages written in any language; especially Python
* Conda packages are basically tar archives with build, link (optional), and
  uninstall (optional) scripts.
* Conda packages are generated from a conda build recipe
  with a ``meta.yaml``, a ``build.sh``, and/or a ``build.bat``
  by conda-build.
* ``conda skeleton`` can automatically create conda packages
  from ``PyPI`` (Python), ``CRAN`` (R), and from ``CPAN`` (Perl)
* An ``environment.yml`` lists conda and :ref:`pip` packages
  to be installed with conda-env.

  .. code:: bash

      # Export and environment.yml
      source deactivate; conda env export -n root | tee environment.yml

      # Create an environment from an environment.yml
      conda env create -n example -f ./environment.yml

* Conda was originally created for the Anaconda Python Distribution,
  which installs packages written in :ref:`Python`,
  R,
  :ref:`Javascript`,
  :ref:`Ruby`,
  :ref:`C`,
  :ref:`Fortran`
* Conda (and :ref:`Anaconda`) packages are hosted by
  `<https://binstar.org>`__,
  which hosts free public and paid private Conda packages.

  * Anaconda Server is an internal
    "Private, Secure Package Repository"
    that
    "supports over 100 different repositories,
    including PyPI, CRAN, conda, and the Anaconda repository."

To create a fresh conda env:

.. code:: bash

   # Python 2.7
   conda env create -n exmpl2 --yes python readline pip
   # conda install ipython-notebook

   # Python 3.X
   conda env create -n exmpl3 --yes python3 readline pip

Work on a conda env:

.. code:: bash

   source activate exmpl2
   conda list
   source deactivate


* https://github.com/conda/conda-env
* https://github.com/conda/conda-build
* https://github.com/conda/conda-recipes


.. index:: Ruby Gem
.. index:: RubyGems
.. _rubygems:

RubyGems
~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/RubyGems
| Homepage: https://rubygems.org/
| Docs: http://guides.rubygems.org/
| Source: https://github.com/rubygems/rubygems

RubyGems is a package manager for :ref:`Ruby` packages ("Gems").


.. index:: Yum
.. _yum:

Yum
~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Yellowdog_Updater,_Modified
| Homepage: http://yum.baseurl.org/


Yum is a tool for installing, upgrading, and uninstalling :ref:`RPM`
packages.


.. index:: Version Control Systems
.. index:: Distributed Version Control Systems
.. _vcs:

Version Control Systems
========================
| Wikipedia: https://en.wikipedia.org/wiki/Revision_control
| Wikipedia: https://en.wikipedia.org/wiki/Distributed_revision_control

Version Control Systems (VCS) --- or Revision Control Systems (RCS) ---
are designed to solve various problems
in change management.

* VCS store code in a **repository**.
* Changes to one or more files are called **changesets**, **commits**,
  or **revisions**
* Changesets are **comitted** or **checked into** to a repository.
* Changesets are **checked out** from a repository
* Many/most VCS differentiate between the repository
  and a **working directory**, which is currently **checked out**
  to a specific *changeset* identified by a **revision identifier**;
  possibly with **uncommitted** local changes.
* A **branch** is forked from a line of development
  and then **merged** back in.
* Most projects designate a *main line* of development
  referred to as a **trunk**, **master**, or **default** branch.
* Many projects work with *feature* and *release* branches,
  which, ideally, eventually converge by being merged back into
  **trunk**. (see: :ref:`HubFlow` for an excellent example of branching)
* Traditional VCS are centralized on a single point-of-failure.
* Some VCS have a concept of *locking* to prevent multiple peoples'
  changes from *colliding*
* Distributed Version Control Systems (DVCS) (can) **clone** all **revisions**
  of every **branch** of a repository every time. *
* DVCS changesets are **pushed** to a different repository
* DVCS changesets are **pulled** from another repository into a *local*
  **clone** or **copy** of a repository
* Teams working with DVCS often designate a central repository
  hosted by a project forge service
  like SourceForge, GNU Savannah, GitHub, or BitBucket.
* Contributors send **patches** which build upon a specific revision,
  which can be applied by a maintainer with **commit access**
  permissions.
* Contributors **fork** a new **branch** from a specific revision,
  commit changes, and then send a **pull request**,
  which can be applied by a maintainer with **commit access**
  permissions.


.. index:: CVS
.. _cvs:

CVS
~~~~~
| Homepage: http://www.nongnu.org/cvs/
| Homepage: http://savannah.nongnu.org/projects/cvs
| Wikipedia: https://en.wikipedia.org/wiki/Concurrent_Versions_System
| Docs: http://www.nongnu.org/cvs/#documentation

CVS (``cvs``) is a centralized version control system (VCS) written in :ref:`C`.

CVS predates most/many other VCS.


.. index:: Subversion
.. _subversion:

Subversion
~~~~~~~~~~~~~
| Homepage: https://subversion.apache.org/
| Wikipedia: https://en.wikipedia.org/wiki/Apache_Subversion
| Docs: https://subversion.apache.org/docs/
| Docs: https://subversion.apache.org/quick-start
| Source: svn http://svn.apache.org/repos/asf/subversion/trunk

Apache Subversion (``svn``) is a centralized revision control system (VCS)
written in :ref:`C`.

To checkout a revision of a repository with ``svn``:

.. code:: bash

   svn co http://svn.apache.org/repos/asf/subversion/trunk subversion


.. index:: Bazaar
.. _bazaar:

Bazaar
~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/GNU_Bazaar
| Homepage: http://bazaar.canonical.com/en/
| Homepage: https://launchpad.net/bzr
| Docs: http://doc.bazaar.canonical.com/en/
| Docs: http://doc.bazaar.canonical.com/latest/en/mini-tutorial/index.html
| Source: bzr lp:bzr

GNU Bazaar (``bzr``) is a distributed revision control system (DVCS, RCS, VCS)
written in :ref:`Python` and :ref:`C`.

http://launchpad.net hosts Bazaar repositories;
with special support from the ``bzr`` tool in the form of ``lp:`` urls
like ``lp:bzr``.

To clone a repository with ``bzr``:

.. code:: bash

  bzr branch lp:bzr



.. index:: Git
.. _git:

Git
~~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Git_(software)>`_
| Homepage: http://git-scm.com/
| Docs: http://git-scm.com/documentation
| Docs: http://git-scm.com/book/en/
| Docs: http://documentup.com/skwp/git-workflows-book
| Docs: http://learnxinyminutes.com/docs/git/
| Source: git https://github.com/git/git


Git (``git``) is a distributed version control system for tracking a branching
and merging repository of file revisions written in :ref:`C` (DVCS, VCS,
RCS).

To clone a repository with ``git``:

.. code:: bash

  git clone https://github.com/git/git


.. index:: HubFlow
.. _hubflow:

HubFlow
~~~~~~~~~
| Src: https://github.com/datasift/gitflow
| Docs: https://datasift.github.io/gitflow/
| Docs: https://datasift.github.io/gitflow/IntroducingGitFlow.html
| Docs: https://datasift.github.io/gitflow/TheHubFlowTools.html

HubFlow is a fork of GitFlow
that adds extremely useful commands for working with Git and GitHub.

HubFlow is a named branch workflow with mostly-automated merges
between branches.

Branch names are configurable; the defaults are as follows:


+--------------------+-------------------------------------------------------------------------+
| **Branch Name**    | **Description**                                                         |
|                    | (and `Code Labels <https://westurner.org/wiki/workflow#code-labels>`__) |
+--------------------+-------------------------------------------------------------------------+
| ``master``         | Stable trunk (latest release)                                           |
+--------------------+-------------------------------------------------------------------------+
| ``develop``        | Development main line                                                   |
+--------------------+-------------------------------------------------------------------------+
| ``feature/<name>`` | New features for the next release (e.g. ``ENH``, ``PRF``)               |
+--------------------+-------------------------------------------------------------------------+
| ``hotfix/<name>``  | Fixes to merge to both ``master`` and ``develop``                       |
|                    | (e.g. ``BUG``, ``TST``, ``DOC``)                                        |
+--------------------+-------------------------------------------------------------------------+
| ``release/<name>`` | In-progress release branches (e.g. ``RLS``)                             |
+--------------------+-------------------------------------------------------------------------+

Creating a new release with :ref:`Git` and HubFlow:

.. code:: bash

  git clone ssh://git@github.com/westurner/dotfiles
  # git checkout master
  git hf init
  ## Update versiontag in .git/config to prefix release tags with 'v'
  git config hubflow.prefix.versiontag=v
  #cat .git/config # ...
  # [hubflow "prefix"]
  # feature = feature/
  # release = release/
  # hotfix = hotfix/
  # support = support/
  # versiontag = v
  #
  git hf feature start ENH_print_hello_world
  ## commit, commit, commit
  git hf feature finish ENH_print_hello_world   # ENH<TAB>
  git hf release start 0.1.0
  ## commit (e.g. update __version__, setup.py, release notes)
  git hf release finish 0.1.0
  git hf release finish 0.1.0
  git tag | grep 'v0.1.0'

The GitFlow HubFlow illustrations are very helpful for visualizing
and understanding any DVCS workflow:
`<https://datasift.github.io/gitflow/IntroducingGitFlow.html>`__.


.. index:: Hg
.. index:: Mercurial
.. _mercurial:

Mercurial
~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Mercurial
| Homepage: http://hg.selenic.org/
| Docs: http://mercurial.selenic.com/guide
| Docs: http://hgbook.red-bean.com/
| Source: hg http://selenic.com/hg
| Source: hg http://hg.intevation.org/mercurial/crew

Mercurial (``hg``) is a distributed revision control system
written in :ref:`Python` and :ref:`C` (DVCS, VCS, RCS).

To clone a repository with ``hg``:

.. code:: bash

   hg clone http://selenic.com/hg


Languages
===========

.. index:: Lightweight Markup Languages
.. _lightweight markup language:

Lightweight Markup Language
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Lightweight_markup_language
| WikipediaCategory: https://en.wikipedia.org/wiki/Category:Lightweight_markup_languages


.. index:: BBCode
.. _bbcode:

BBCode
++++++++
| Wikipedia: https://en.wikipedia.org/wiki/BBCode
| Homepage: http://www.bbcode.org/
| Docs: http://www.bbcode.org/reference.php
| Docs: http://www.bbcode.org/examples/

BBCode is a :ref:`Lightweight markup language`
often used by bulletin boards and forums.


.. index:: Markdown
.. _markdown:

Markdown
++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Markdown
| Homepage: https://daringfireball.net/projects/markdown/
| Standard: https://daringfireball.net/projects/markdown/syntax
| Docs: http://www.w3.org/community/markdown/wiki/MarkdownImplementations
| Docs: http://learnxinyminutes.com/docs/markdown/
| Docs: https://guides.github.com/features/mastering-markdown/
| Docs: https://help.github.com/articles/github-flavored-markdown/
| Docs: https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet
| FileExt: ``.Md``
| FileExt: ``.md``

Markdown is a :ref:`Lightweight markup language`
which can be parsed and transformed to
valid :ref:`HTML`.


.. index:: MediaWiki Markup
.. _mediawiki markup:

MediaWiki Markup
++++++++++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Help:Wiki_markup
| Standard: https://www.mediawiki.org/wiki/Markup_spec
| Docs: https://en.wikipedia.org/wiki/Help:Wiki_markup#Link_to_another_namespace
| Docs: https://www.mediawiki.org/wiki/Help:Formatting
| Docs: https://meta.wikimedia.org/wiki/Help:Wikitext_examples
| Docs: https://en.wikipedia.org/wiki/Help:Displaying_a_formula

MediaWiki Markup is a
:ref:`Lightweight markup language`
"WikiText"
which can be parsed and transformed to
valid :ref:`HTML`
that is utilized by Wikipedia.


.. index:: RD
.. index:: Ruby Document Format
.. _rd:

RD
++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Ruby_Document_format
| Standard: https://github.com/uwabami/rdtool/blob/master/doc/rd-draft.rd
| Standard: https://github.com/uwabami/rdtool/blob/master/doc/rd-draft.rd.ja

RD is a :ref:`Lightweight markup language` for documenting :ref:`Ruby`
code and programs.


.. index:: Rdoc
.. _rdoc:

RDoc
++++++
| Source: https://github.com/rdoc/rdoc
| Docs: http://docs.seattlerb.org/rdoc/
| Docs: https://raw.githubusercontent.com/rdoc/rdoc/master/ExampleRDoc.rdoc

RDoc is a tool and a
:ref:`Lightweight markup language`
for generating HTML and command-line documentation
for :ref:`Ruby` projects.

To not build RDoc docs when installing a :ref:`Gem <RubyGems>`:

.. code:: bash

   gem install --no-rdoc --no-ri
   gem install --no-document
   gem install -N


.. index:: ReStructuredText
.. _restructuredtext:

ReStructuredText
++++++++++++++++++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/ReStructuredText
| Homepage: http://docutils.sourceforge.net/rst.html
| Docs: http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html
| Docs: http://docutils.sourceforge.net/docs/ref/rst/directives.html
| Docs: http://docutils.sourceforge.net/docs/ref/rst/roles.html
| Docs: http://sphinx-doc.org/rest.html

ReStructuredText (RST, ReST) is a
:ref:`Lightweight markup language` commonly used for
narrative documentation and {Python, C, Java, ...} docstrings
which can be parsed and transformed to
valid :ref:`HTML`, ePub, LaTeX, PDF.

:ref:`Sphinx` is built on :ref:`Docutils`,
the primary implementation of ReStructuredText.

:ref:`Pandoc` also supports a form of ReStructuredText.

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



.. index:: C
.. _c:

C
~~
| Wikipedia: `<https://en.wikipedia.org/wiki/C_(programming_language)>`__
| Docs: http://learnxinyminutes.com/docs/c/

C is a third-generation programming language which affords relatively
low-level machine access while providing helpful abstractions.

The GNU/:ref:`Linux` kernel is written in C
and often compiled by :ref:`GCC` or :ref:`Clang`
for a particular architecture (see: ``man uname``)

:ref:`Libc` libraries are written in C.

Almost all of the projects linked here, at some point,
utilize code written in C.


.. index:: Libc
.. _libc:

Libc
++++++
| Wikipedia: https://en.wikipedia.org/wiki/C_POSIX_library

A libc is a standard library of :ref:`C` routines.

Libc implementations:

* :ref:`Glibc`
* https://en.wikipedia.org/wiki/C_standard_library#BSD_libc
* https://en.wikipedia.org/wiki/UClibc
* `<https://en.wikipedia.org/wiki/Bionic_(software)>`__


.. index:: GNU Libc
.. index:: Glibc
.. _glibc:

------
Glibc
------
| Wikipedia: https://en.wikipedia.org/wiki/GNU_C_Library
| Homepage: https://www.gnu.org/software/libc/
| Docs: https://www.gnu.org/software/libc/documentation.html
| Docs: https://www.gnu.org/software/libc/manual/html_mono/libc.html
| Docs: http://sourceware.org/glibc/wiki/HomePage
| Source: https://en.wikipedia.org/wiki/GNU_C_Library

Glibc is the GNU :ref:`C` Library (:ref:`libc`).

Many :ref:`Linux` packages
and the :ref:`GNU/Linux <linux>` kernel build from Glibc.


.. index:: C++
.. _c++:

C++
~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/C++>`__
| Docs: http://learnxinyminutes.com/docs/c++/

C++ is a third-generation programming language
which adds object orientation and a standard library to :ref:`C`.

* C++ is an ISO specification: C++98, C++03, C++11 (C++0x), C++14, [ C++17 ]


.. index:: Fortran
.. _fortran:

Fortran
~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Fortran


Fortran (or FORTRAN) is a third-generation programming language
frequently used for mathematical and scientific computing.

Some of the :ref:`SciPy` libraries build
optimized mathematical Fortran routines.


.. index:: Haskell
.. _haskell:

Haskell
~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Haskell_(programming_language)>`__
| Homepage: https://www.haskell.org/
| Download: https://www.haskell.org/downloads
| Download: https://www.haskell.org/platform/
| Docs: https://www.haskell.org/documentation
| Docs: http://learnxinyminutes.com/docs/haskell/
| Docs: http://learnyouahaskell.com/chapters
| Docs: https://en.wikipedia.org/wiki/Haskell_features

Haskell is a strongly staticly typed purely functional
programming language.

:ref:`Cabal` manages :ref:`Haskell` packages.


.. index:: Go
.. _go:

Go
~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Go_(programming_language)>`_
| Homepage: http://golang.org/
| Docs: http://golang.org/doc/
| Source: hg https://code.google.com/p/go/

Go is a statically-typed :reF:`C`-based third generation language.


.. index:: Java
.. _Java:

Java
~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Java_(programming_language)>`__
| Docs: http://javadocs.org/
| Docs: http://learnxinyminutes.com/docs/java/

Java is a third-generation programming language which is
compiled into code that runs in a virtual machine
(``JVM``) written in :ref:`C` for many different operating systems.


.. index:: Javascript
.. _Javascript:

JavaScript
~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/JavaScript
| Docs: https://en.wikipedia.org/wiki/ECMAScript
| Docs: http://learnxinyminutes.com/docs/javascript/

JavaScript is a third-generation programming language
designed to run in an interpreter; now specified as *ECMAScript*.

All major web browsers support Javascript.

Client-side (web) applications can be written in Javascript.

Server-side (web) applications can be written in Javascript,
often with :ref:`Node.js` and :ref:`NPM` packages.

.. note:: Java and JavaScript are two distinctly different languages
   and developer ecosystems.

.. index:: Node.js
.. _node.js:

Node.js
+++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Node.js
| Homepage: http://www.nodejs.org
| Source: https://github.com/joyent/node


Node.js is a framework for :ref:`Javascript` applications
written in :ref:`C`, :ref:`C++`, and :ref:`Javascript`.



.. index:: Jinja2
.. _jinja2:

Jinja2
~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Jinja_%28template_engine%29>`__
| Homepage: http://jinja.pocoo.org/
| Source: https://github.com/mitsuhiko/jinja2
| Docs: https://jinja2.readthedocs.org/en/latest/
| Docs: http://jinja.pocoo.org/docs/dev/

Jinja (jinja2) is a templating engine written in :ref:`Python`.

:ref:`Sphinx` and :ref:`Salt` are two projects that utilize Jinja2.

.. index:: Perl
.. _perl:

Perl
~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Perl
| Homepage: http://www.perl.org/
| Project: http://dev.perl.org/perl5/
| Docs: http://www.perl.org/docs.html
| Source: git git://perl5.git.perl.org/perl.git

Perl is a dynamically typed, :ref:`C`-based third-generation
programming language.

Many of the Debian system management tools are or were originally written
in Perl.


.. index:: Python
.. _python:

Python
~~~~~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Python_(programming_language)>`_
| Homepage: https://www.python.org/
| Docs: https://docs.python.org/2/
| Docs: https://docs.python.org/devguide/
| Docs: https://docs.python.org/devguide/documenting.html
| Docs: http://learnxinyminutes.com/docs/python/
| Source: hg https://hg.python.org/cpython

Python is a dynamically-typed, :ref:`C`-based third-generation
programming language.

As a multi-paradigm language with support for functional
and object-oriented code,
Python is often utilized for system administration
and scientific software development.

Many of the RedHat system management tools (such as :ref:`Yum`)
are written in Python. Gentoo :ref:`Portage` is written in Python.

:ref:`IPython`, :ref:`Pip`, :ref:`Conda`,
:ref:`Sphinx`, :ref:`Docutils`, :ref:`Mercurial`,
:ref:`Libcloud`, :ref:`Salt`, :ref:`Tox`, :ref:`Virtualenv`,
and :ref:`Virtualenvwrapper` are all written in Python.


The Python community is generously supported by a number of sponsors
and the Python Infrastructure Team:

* https://www.python.org/psf/sponsorship/
* https://www.python.org/psf/members/#sponsor-members
* http://psf-salt.readthedocs.org/en/latest/overview/


.. index:: CPython
.. _cpython:

CPython
++++++++
| Wikipedia: `<https://en.wikipedia.org/wiki/Python_(programming_language)>`_
| Homepage: https://www.python.org/
| Docs: https://docs.python.org/2/
| Docs: https://docs.python.org/devguide/
| Docs: https://docs.python.org/devguide/documenting.html
| Docs: http://learnxinyminutes.com/docs/python/
| Source: hg https://hg.python.org/cpython

CPython is the reference :ref:`Python` language implementation written in
:ref:`C`.

* https://github.com/python/cpython/blob/master/Grammar/Grammar

CPython can interface with other :ref:`C` libraries
through a number of interfaces:

* https://docs.python.org/2/c-api/
* https://cffi.readthedocs.org/en/latest/
* :ref:`Cython`


.. index:: Cython
.. _cython:

Cython
++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Cython
| Hompage: http://cython.org/
| PyPI: https://pypi.python.org/pypi/Cython
| Docs: http://docs.cython.org/
| Docs: http://docs.cython.org/src/userguide/language_basics.html

Cython is a superset of :ref:`CPython` which adds static type definitions;
making :ref:`CPython` code faster, in many cases.


.. index:: NumPy
.. _numpy:

NumPy
++++++
| Wikipedia: https://en.wikipedia.org/wiki/NumPy
| Homepage: http://www.numpy.org/
| Src: https://github.com/numpy/numpy
| Docs: http://docs.scipy.org/doc/numpy/

NumPy is a library of array-based mathematical functions
implemented in :ref:`C` and :ref:`Python`.

* http://nbviewer.ipython.org/github/jrjohansson/scientific-python-lectures/blob/master/Lecture-2-Numpy.ipynb
* https://scipy-lectures.github.io/intro/numpy/index.html
* https://scipy-lectures.github.io/advanced/advanced_numpy/index.html

NumPy and other languages:

* http://wiki.scipy.org/NumPy_for_Matlab_Users
* https://github.com/ipython/ipython/wiki/Extensions-Index


.. index:: SciPy
.. _scipy:

SciPy
++++++++
| Wikipedia: https://en.wikipedia.org/wiki/SciPy
| Homepage: http://scipy.org/
| Src: https://github.com/scipy/scipy
| Docs: http://www.scipy.org/docs.html
| Docs: http://docs.scipy.org/doc/scipy/reference/
| Docs: http://www.scipy.org/install.html

SciPy is a set of science and engineering libraries
for :ref:`Python`, primarily written in :ref:`C`.

* http://nbviewer.ipython.org/github/jrjohansson/scientific-python-lectures/blob/master/Lecture-3-Scipy.ipynb
* https://scipy-lectures.github.io/intro/scipy.html

The :ref:`SciPy Stack <scipystack>` specification
includes the SciPy package and its dependencies.


.. index:: SciPy
.. _scipystack:

SciPy Stack
+++++++++++++
| Docs: http://www.scipy.org/stackspec.html
| Docs: http://www.scipy.org/install.html

Python Distributions

* Sage
* :ref:`Anaconda` (:ref:`Conda`)
* Enthought Canopy
* Python(x,y)
* WinPython
* Pyzo
* Algorete Loopy (:ref:`Conda`)

Scipy Stack Docker Containers

* https://registry.hub.docker.com/u/ipython/ipython/
* https://registry.hub.docker.com/u/ipython/scipystack/
* https://registry.hub.docker.com/u/ipython/scipyserver/



.. index:: PyPy
.. _pypy:

PyPy
+++++
| Wikipedia: https://en.wikipedia.org/wiki/PyPy
| Homepage: http://pypy.org/
| Source: https://bitbucket.org/pypy/pypy
| Docs: http://buildbot.pypy.org/waterfall
| Docs: https://pypy.readthedocs.org/en/latest/
| Docs: https://pypy.readthedocs.org/en/latest/introduction.html

PyPy is a JIT LLVM compiler for :ref:`Python` code
written in RPython -- a restricted subset of :ref:`CPython` syntax --
which compiles to :ref:`C`, and is often faster than :ref:`CPython`
for many types of purposes.


.. index:: NumPyPy
.. _numpypy:

NumPyPy
++++++++
NumPyPy is a port of :ref:`NumPy` to :ref:`PyPy`:

| Src: https://bitbucket.org/pypy/numpypy
| Docs: http://buildbot.pypy.org/numpy-status/latest.html
| Docs: http://pypy.org/numpydonate.html


.. index:: Python 3
.. _python3:

Python 3
++++++++++
| Docs: https://docs.python.org/3/
| Docs: https://docs.python.org/3/howto/pyporting.html
| Docs: https://docs.python.org/3/howto/cporting.html
| Docs: http://learnxinyminutes.com/docs/python3/


Python 3 made a number of incompatible changes,
requiring developers to update and review their Python 2 code
in order to "port to" Python 3.

Python 2 will be supported in "no-new-features" status
for quite some time.

Python 3 Wall of Superpowers tracks which popular packages
have been ported to support Python 3: https://python3wos.appspot.com/

There are a number of projects which help bridge the gap between
the two language versions:

* https://pypi.python.org/pypi/six
* http://pythonhosted.org/six/
* https://pypi.python.org/pypi/nine
* https://github.com/nandoflorestan/nine/blob/master/nine/__init__.py
* https://pypi.python.org/pypi/future
* http://python-future.org/

The Anaconda Python distribution (:ref:`Conda`)
maintains a working set of packages
for Python 2.6, 2.7, 3.3, and 3.4:
http://docs.continuum.io/anaconda/pkg-docs.html


.. index:: awesome-python-testing
.. _awesome-python-testing:

awesome-python-testing
++++++++++++++++++++++++
| Homepage: https://westurner.org/wiki/awesome-python-testing.html
| Source: https://github.com/westurner/wiki/blob/master/awesome-python-testing.rest


.. index:: Tox
.. _tox:

Tox
++++++++++++++
| Homepage: https://testrun.org/tox/
| Docs: https://tox.readthedocs.org/en/latest/
| Source: hg https://bitbucket.org/hpk42/tox
| Pypi: https://pypi.python.org/pypi/tox


Tox is a build automation tool designed to build and test Python projects
with multiple language versions and environments
in separate :ref:`virtualenvs <virtualenv>`.

Run the py27 environment::

   tox -v -e py27
   tox --help



.. index:: Ruby
.. _ruby:

Ruby
~~~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Ruby_(programming_language)>`_
| Homepage: https://www.ruby-lang.org/
| Docs: https://www.ruby-lang.org/en/documentation/
| Docs: http://learnxinyminutes.com/docs/ruby/
| Source: svn http://svn.ruby-lang.org/repos/ruby/trunk

Ruby is a dynamically-typed programming language.

:ref:`Vagrant` is written in Ruby.


.. index:: YAML
.. _yaml:

YAML
~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/YAML
| Homepage: http://yaml.org
| Docs: http://learnxinyminutes.com/docs/yaml/


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


.. index:: Compilers
.. _compilers:

Compilers
==========

.. index:: Binutils
.. index:: GNU Binutils
.. _binutils:

Binutils
~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/GNU_Binutils
| Homepage: https://www.gnu.org/software/binutils/
| Src: git git://sourceware.org/git/binutils-gdb.git
| Docs: https://sourceware.org/binutils/docs-2.24/
| Docs: https://sourceware.org/binutils/docs-2.24/binutils/index.html
| Docs: https://sourceware.org/binutils/docs-2.24/as/index.html
| Docs: https://sourceware.org/binutils/docs-2.24/ld/index.html

GNU Binutils are a set of utilities for working with assembly and
binary.

:ref:`GCC` utilizes GNU Binutils to compile the GNU/:ref:`Linux` kernel
and userspace.

GAS, the GNU Assembler (``as``) assembles ASM code for linking by
the GNU linker (``ld``).


.. index:: Clang
.. _clang:

Clang
~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Clang
| Homepage: http://clang.llvm.org/
| Docs: http://clang.llvm.org/docs/
| Docs: http://clang.llvm.org/docs/UsersManual.html

Clang is a compiler front end for :ref:`C`, :ref:`C++`, and Objective C/++.


.. index:: GCC
.. index:: GNU Compiler Collection
.. _gcc:

GCC
~~~~
| Wikipedia: https://en.wikipedia.org/wiki/GNU_Compiler_Collection
| Homepage: https://gcc.gnu.org/
| Docs: https://gcc.gnu.org/onlinedocs/
| Source: git ssh://gcc.gnu.org/git/gcc.git


The GNU Compiler Collection started as a Free and Open Source
compiler for :ref:`C`.

There are now GCC frontends for many languages, including
:ref:`C++`, :ref:`Fortran`, :ref:`Java`, and :ref:`Go`.


.. index:: LLVM
.. _llvm:

LLVM
~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/LLVM
| Homepage: http://llvm.org/
| Source: git http://llvm.org/git/llvm.git
| Docs: http://llvm.org/docs/
| Docs: http://llvm.org/docs/GettingStarted.html
| Docs: http://llvm.org/docs/ReleaseNotes.html
| Docs: http://llvm.org/ProjectsWithLLVM/

LLVM "*Low Level Virtual Machine*" is a reusable compiler infrastructure
with frontends for many languages.

* :ref:`Clang`
* :ref:`PyPy`



.. index:: Operating Systems
.. _operating-systems:

Operating Systems
===================

.. index:: GNU/Linux
.. index:: Linux
.. _linux:

Linux
~~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Linux
| Homepage: https://www.kernel.org/
| Docs: https://www.kernel.org/doc/
| Source: git https://github.com/torvalds/linux

GNU/Linux ("Linux") is a free and open source operating system kernel
written in :ref:`C`.

.. code-block:: bash

   uname -a; echo "Linux"
   uname -o; echo "GNU/Linux"


.. index:: Linux Distributions
.. _linux-distributions:

Linux Distributions
~~~~~~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Linux_distribution

A *Linux Distribution* is a collection of :ref:`Packages`
compiled to work with a :ref:`GNU/Linux <linux>` kernel and a :ref:`libc`.

* https://commons.wikimedia.org/wiki/File:Linux_Distribution_Timeline_with_Android.svg


.. index:: Debian
.. _debian:

Debian
+++++++++++++++++
| Wikipedia: `<https://en.wikipedia.org/wiki/Debian>`__
| Homepage: https://www.debian.org/
| Download: https://www.debian.org/distrib/
| DockerHub: https://registry.hub.docker.com/_/debian/
| Docs: https://www.debian.org/doc/
| Docs: https://www.debian.org/doc/manuals/debian-reference/
| Docs: https://www.debian.org/doc/#manuals
| Docs: https://www.debian.org/doc/debian-policy/ (main, contrib, non-free)
| Docs: https://www.debian.org/releases/stable/releasenotes
| Docs: https://www.debian.org/releases/stable/i386/release-notes/
| Docs: https://www.debian.org/releases/stable/amd64/release-notes/

Debian
is a :ref:`Linux Distribution <linux-distributions>`
that is built from :ref:`DEB` packages.

.. index:: Ubuntu
.. _ubuntu:

Ubuntu
+++++++++++++++++
| Wikipedia: `<https://en.wikipedia.org/wiki/Ubuntu_(operating_system)>`_
| Homepage: http://www.ubuntu.com/
| Source: https://launchpad.net/ubuntu
| Source: http://archive.ubuntu.com/
| Source: http://releases.ubuntu.com/
| Download: http://www.ubuntu.com/download
| DockerHub: https://registry.hub.docker.com/_/ubuntu/
| Docs: https://help.ubuntu.com/
| Q&A: https://askubuntu.com

Ubuntu
is a :ref:`Linux Distribution <linux-distributions>`
that is built from :ref:`DEB` packages
which are often derived from :ref:`Debian` packages.


.. index:: Fedora
.. _fedora:

Fedora
+++++++
| Wikipedia: `<https://en.wikipedia.org/wiki/Fedora_(operating_system)>`__
| Homepage: https://getfedora.org/
| Download: https://getfedora.org/en/workstation/download/
| Download: https://getfedora.org/en/server/download/
| Download: https://getfedora.org/en/cloud/download/
| Docs: https://docs.fedoraproject.org/en-US/index.html
| Docs: https://fedoraproject.org/wiki/Fedora_Project_Wiki
| Docs: https://fedoraproject.org/wiki/EPEL

Fedora
is a :ref:`Linux Distribution <linux-distributions>`
that is built from :ref:`RPM` packages.

.. index:: RHEL
.. index:: RedHat Enterprise Linux
.. _rhel:

RedHat
++++++++
| Wikipedia: `<https://en.wikipedia.org/wiki/Red_Hat_Enterprise_Linux>`__
| Homepage: https://www.redhat.com/en/technologies/linux-platforms/enterprise-linux
| Docs: https://access.redhat.com/documentation/en-US/
| Docs: https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/

RedHat Enterprise Linux ("RHEL")
is a :ref:`Linux Distribution <linux-distributions>`
that is built from :ref:`RPM` packages.


.. index:: CentOS
.. _centos:

--------
CentOS
--------
| Wikipedia: https://en.wikipedia.org/wiki/CentOS
| Homepage: https://www.centos.org/
| Download: https://www.centos.org/download/
| Docs: https://wiki.centos.org/
| Docs: https://www.centos.org/docs/
| DockerHub: https://registry.hub.docker.com/_/centos/

CentOS is a :ref:`Linux Distribution <linux-distributions>`
that is built from :ref:`RPM` packages
which is derived from :ref:`RHEL`.


.. index:: Scientific Linux
.. _scientific-linux:

Scientific Linux
-----------------
| Wikipedia: https://en.wikipedia.org/wiki/Scientific_Linux
| Homepage: https://en.wikipedia.org/wiki/Scientific_Linux

Scientific Linux is a :ref:`Linux Distribution <linux-distributions>`
that is built from :ref:`RPM` packages
which is derived from :ref:`CentOS`.
which is derived from :ref:`RHEL`.

* ``rdfs:seeAlso`` :ref:`Anaconda` (:ref:`Conda`)
* ``rdfs:seeAlso`` :ref:`Portage`


.. index:: Oracle Linux
.. _oracle-linux:

------------
Oracle
------------
| Wikipedia: https://en.wikipedia.org/wiki/Oracle_Linux
| Homepage: http://www.oracle.com/linux
| Docs: http://www.oracle.com/us/technologies/linux/resources/index.html
| Docs: http://www.oracle.com/us/technologies/linux/openstack/overview/index.html

Oracle Linux is a :ref:`Linux Distribution <linux-distributions>`
that is built from :ref:`RPM` packages
which is derived from :ref:`RHEL`.


.. index:: Gentoo
.. _gentoo:

Gentoo
++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Gentoo
| Homepage: https://gentoo.org/
| Source: https://github.com/gentoo
| Source: git https://github.com/gentoo/portage
| Docs: https://wiki.gentoo.org/wiki/
| Docs: https://wiki.gentoo.org/wiki/Handbook:Main_Page
| Docs: https://wiki.gentoo.org/wiki/Handbook:AMD64
| Docs: https://wiki.gentoo.org/wiki/Handbook:X86
| Docs: https://wiki.gentoo.org/wiki/Project:Portage
| Docs: https://wiki.gentoo.org/wiki/Project:Hardened

Gentoo is a :ref:`Linux Distribution <linux-distributions>`
built on :ref:`Portage`.

* https://registry.hub.docker.com/search?q=gentoo (Stage 3 + Portage)


.. index:: ChromiumOS
.. _chromiumos:

ChromiumOS
+++++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Chromium_OS
| Homepage: https://www.chromium.org/chromium-os
| Docs: https://www.chromium.org/chromium-os/quick-start-guide
| Docs: https://www.chromium.org/chromium-os/developer-guide
| Source: https://chromium.googlesource.com/ (``chromiumos*/``)

ChromiumOS is a :ref:`Linux Distribution <linux-distributions>`
built on :ref:`Portage`.


.. index:: Crouton
.. _crouton:

------------
Crouton
------------
| Source: https://github.com/dnschneid/crouton

Crouton ("Chromium OS Universal Chroot Environment")
installs and debootstraps a :ref:`Linux Distribution <linux-distributions>`
(i.e. :ref:`Debian` or :ref:`Ubuntu`)
within a :ref:`ChromiumOS` or :ref:`ChromeOS` chroot.


.. index:: ChromeOS
.. _chromeos:

ChromeOS
+++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Chrome_OS

ChromeOS is a :ref:`Linux Distribution <linux-distributions>`
built on :ref:`ChromiumOS`
and :ref:`Portage`.

* ChromeOS powers Chromebooks

  * https://en.wikipedia.org/wiki/Chromebook

* ChromeOS powers Chromeboxes

  * https://en.wikipedia.org/wiki/Chromebox


.. index:: CoreOS
.. _coreos:

CoreOS
++++++++
| Wikipedia: https://en.wikipedia.org/wiki/CoreOS
| Homepage: https://coreos.com/
| Source: https://github.com/coreos
| Docs: https://coreos.com/docs/
| Docs: https://coreos.com/docs/#running-coreos
| Docs: https://coreos.com/docs/running-coreos/platforms/vagrant/
| Docs: https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/getting-started-guides/coreos.md

CoreOS is a :ref:`Linux Distribution <linux-distributions>`
for highly available distributed computing.

CoreOS schedules redundant :ref:`docker` images with **fleet**
and **systemd** according to configuration stored in **etcd**,
a key-value store with a D-Bus interface.

* CoreOS runs on very many platforms
* CoreOS does not provide a package manager
* CoreOS schedules Docker

* CoreOS -- Operating System
* etcd -- Consensus and Discovery
* rkt -- Container Runtime
* fleet -- Distributed init system (etcd, systemd)
* flannel -- Networking





.. index:: Linux Notes
.. _linux-notes:

Linux Notes
+++++++++++++

* https://github.com/westurner/provis

  * https://github.com/saltstack/salt-bootstrap

    curl -L https://bootstrap.saltstack.com scripts/bootstrap-salt.sh

  * Masterless Salt Config: ``make salt_local_highstate_test``

    * [ ] Workstation role

----------------
Linux Dual Boot
----------------
* [ ] GRUB chainloader to partition boot record

  * Ubuntu and Fedora GRUB try to autodiscover Windows partitions


.. index:: Android
.. _android:

Android
+++++++++
| Wikipedia: `<https://en.wikipedia.org/wiki/Android_(operating_system)>`__
| Homepage: https://www.android.com/
| Homepage: https://developer.android.com/


.. index:: Android SDK
.. _android sdk:

-------------
Android SDK
-------------
| Homepage: https://developer.android.com/sdk/
| Source: https://android.googlesource.com/
| Source: https://github.com/android
| Docs: https://developer.android.com/sdk/
| Docs: https://developer.android.com/sdk/installing/index.html
| Docs: https://developer.android.com/sdk/installing/adding-packages.html
| Docs: https://source.android.com/source/index.html
| Docs: https://source.android.com/source/downloading.html
| Docs: https://source.android.com/source/developing.html
| Docs: https://source.android.com/source/contributing.html
| Docs: https://sites.google.com/a/android.com/tools/build
| Docs: https://developer.android.com/tools/workflow/index.html



.. index:: Android Studio
.. _android studio:

----------------
Android Studio
----------------
|
| Homepage: https://developer.android.com/tools/studio/index.html
| Docs: https://developer.android.com/tools/workflow/index.html
| Docs: https://sites.google.com/a/android.com/tools/build/studio



.. index:: Apple OSX
.. index:: OS X
.. index:: OSX
.. _osx:

OS X
~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/OS_X
| Homepage: http://www.apple.com/osx
| Docs: https://developer.apple.com/technologies/mac/
| Docs: https://developer.apple.com/library/mac/navigation/
| Docs: https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/
| Source: https://www.apple.com/opensource/


OS X is a UNIX operating system based upon the Mach kernel from NeXTSTEP,
which was partially derived from NetBSD and FreeBSD.

OS X GUI support is built from XFree86/X.org :ref:`X11`.

OS X maintains forks of many POSIX BSD and GNU tools like ``bash``,
``readlink``, and ``find``.

:ref:`Homebrew` installs and maintains packages for OS X.

.. code-block:: bash

   uname; echo "Darwin"

OSX Notes
++++++++++
* https://github.com/westurner/dotfiles/blob/master/scripts/ ``setup_*.sh``

  * [ ] Manually updae to latest versions (of zip, tar.gz, .dmg)
  * [ ] Port to salt formulas
  * https://github.com/westurner/dotfiles/blob/master/scripts/setup_brew.sh
  * https://github.com/westurner/dotfiles/blob/master/scripts/setup_mavericks_python.sh
  * https://github.com/westurner/dotfiles/blob/master/scripts/setup_chrome.sh
  * https://github.com/westurner/dotfiles/blob/master/scripts/setup_chromium.sh
  * https://github.com/westurner/dotfiles/blob/master/scripts/setup_firefox.sh
  * https://github.com/westurner/dotfiles/blob/master/scripts/setup_adobereader.sh
  * https://github.com/westurner/dotfiles/blob/master/scripts/setup_vlc.sh
  * https://github.com/westurner/dotfiles/blob/master/scripts/setup_f.lux.sh
  * https://github.com/westurner/dotfiles/blob/master/scripts/setup_powerline_fonts.sh
  * https://github.com/westurner/dotfiles/blob/master/scripts/setup_macvim.sh
  * [ ] Miniconda #dotfiles (setup_miniconda.sh?)

* https://github.com/westurner/provis

  * [ ] https://github.com/westurner/provis/compare/feature/osx_support

    * [ ] create / remap "root" group
  * [ ] http://docs.saltstack.com/en/latest/topics/installation/osx.html


    ``brew install saltstack`` OR ``pip install salt``


--------------
OSX Reinstall
--------------
* [ ] Generate installation media
* [ ] Reboot to recovery partition
* [ ] Adjust partitions
* [ ] Format?
* [ ] Install OS
* [ ] (wait)
* [ ] Manual time/date/language config
* [ ] Run workstation provis scripts

------------------
OSX Fresh Install
------------------
* [ ] Generate / obtain installation media
* [ ] Boot from installation media
* [ ] Manual time/date/language config
* [ ] Run workstation provis scripts


--------------
OSX Dual Boot
--------------

* http://www.howtogeek.com/187410/how-to-install-and-dual-boot-linux-on-a-mac/
* http://www.rodsbooks.com/refind/installing.html#osx




.. index:: Windows
.. _windows:

Windows
~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Microsoft_Windows
| Homepage: http://windows.microsoft.com/
| Docs: https://www.microsoft.com/enable/products/docs/
| Docs:

Windows is a NT-kernel based operating system.

There used to be a POSIX compatibility mode.

Chocolatey maintains a set of :ref:`NuGet` packages for Windows.

Windows Notes
+++++++++++++++

A few annotated excerpts from this Chocolatey :ref:`NuGet` :ref:`PowerShell` script
https://gist.github.com/westurner/10950476#file-cinst_workstation_minimal-ps1
::

    cinst GnuWin
    cinst sysinternals      # Process Explorer XP
    cinst 7zip
    cinst curl

* [ ] Install Chocolatey NuGet package manager: http://chocolatey.org
* [ ] Install packages listed here: https://gist.github.com/westurner/10950476

  * [ ] (Optional) uncomment salt first (optionally specify master) [OR Install salt]

* [ ] Install salt: http://docs.saltstack.com/en/latest/topics/installation/windows.html

* ``<Win>+R`` (Start > Run)
* [ ] Run ``services.msc`` and log/prune unutilized services (e.g. workstation, server)

  * https://en.wikipedia.org/wiki/Windows_service

------------------
Windows Dual Boot
------------------
* [ ] Windows MBR chainloads to parition GRUB (`Linux`_)
* [ ] Ubuntu WUBI .exe Linux Installer (XP, 7, 8*)

  * It's now better to install to a separate partition from a bootable ISO

-----
UEFI
-----
| Wikipedia: https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface

* https://help.ubuntu.com/community/UEFI



* Cygwin Windows Linux Userspace: ~ https://chocolatey.org/packages/Cygwin
* https://github.com/giampaolo/psutil/blob/master/psutil/_psutil_windows.c
* http://winappdbg.sourceforge.net/#related-projects




.. index:: Configuration Management
.. _configuration management:

Configuration Management
==========================
| Wikipedia: https://en.wikipedia.org/wiki/Software_configuration_management
| Wikipedia: https://en.wikipedia.org/wiki/Comparison_of_open-source_configuration_management_software


.. index:: Ansible
.. _ansible:

Ansible
~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Ansible_(software)>`__
| Homepage: http://ansible.com/
| Source: https://github.com/ansible/ansible

Ansible is a :ref:`Configuration Management` tool
written in :ref:`Python`
which runs idempotent Ansible Playbooks
written in :ref:`YAML`
for managing
one or more physical and virtual machines running various operating systems
over SSH.


.. index:: JuJu
.. _juju:

Juju
~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Juju_(software)>`__
| Homepage: https://jujucharms.com/
| Source:
| Docs: https://jujucharms.com/docs/
| TcpPort: 8001
| Twitter: http://www.twitter.com/ubuntucloud

Juju is a :ref:`Configuration Management` tool
written in :ref:`Python`
which runs Juju Charms
written in :ref:`Python`
on one or more systems over SSH,
for managing
one or more physical and virtual machines running :ref:`Ubuntu`.

* https://github.com/juju/juju/issues/470


.. index:: Make
.. _make:

Make
~~~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Make_(software)>`_
| Homepage:  https://www.gnu.org/software/make/
| Project: https://savannah.gnu.org/projects/make/
| Docs:  https://www.gnu.org/software/make/manual/make.html
| Source: git git://git.savannah.gnu.org/make.git


GNU Make is a classic, ubiquitous software build tool
designed for file-based source code compilation.

:ref:`Bash`, :ref:`Python`, and the GNU/:ref:`Linux` kernel
are all built with Make.

Make build task chains are represented in a ``Makefile``.

Pros

* Simple, easy to read syntax
* Designed to build files on disk (see: ``.PHONY``)
* Nesting: ``make -C <path> <taskname>``
* Variable Syntax: ``$(VARIABLE_NAME)`` or ``${VARIABLE_NAME}``
* Bash completion: ``make <tab>``
* Python: Initially parseable with *disutils.text_file*
* Logging: command names and values print to stdout (unless prefixed
  with ``@``)

Cons

* Platform Portability: make is not installed everywhere
* Global Variables: parametrization with shell scripts

.. code:: bash

   VARIABLE_NAME="value" make test
   make test VARIABLE_NAME="value"

   # ...
   export VARIABLE_NAME="value"
   make test


.. index:: osquery
.. _osquery:

osquery
~~~~~~~~
| Homepage: https://osquery.io/
| Src: https://github.com/facebook/osquery
| Docs: https://osquery.io/docs/tables/
| Docs: https://osquery.readthedocs.org/en/stable/
| Tools: https://westurner.org/tools/#osquery

OSQuery is a tool for reading and querying
many sources of system data
with SQL
for :ref:`OSX` and :ref:`Linux`.

* https://github.com/westurner/dotfiles/blob/develop/scripts/osquery-all.sh


.. index:: Puppet
.. _puppet:

Puppet
~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Puppet_(software)>`__
| Homepage: https://puppetlabs.com/
| Docs: http://docs.puppetlabs.com/
| Docs: http://docs.puppetlabs.com/puppet/
| Source: git https://github.com/puppetlabs
| TcpPort: 8140

Puppet is a :ref:`Configuration Management` system
written in :ref:`Ruby`
which runs Puppet Modules
written in Puppet DSL or :ref:`Ruby`
for managing
one or more physical and virtual machines running various operating systems.

* https://github.com/nanliu/puppet-transport


.. index:: Salt
.. _salt:

Salt
~~~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Salt_(software)>`_
| Homepage: http://www.saltstack.com
| Docs: https://docs.saltstack.com/en/latest/
| Docs: https://docs.saltstack.com/en/latest/salt-modindex.html
| Docs: https://docs.saltstack.com/en/latest/ref/states/all/index.html
| Docs: https://docs.saltstack.com/en/latest/ref/clients/index.html#python-api
| Docs: https://docs.saltstack.com/en/latest/topics/development/hacking.html
| Docs: https://docs.saltstack.com/en/latest/glossary.html
| Source: git https://github.com/saltstack/salt
| Pypi: https://pypi.python.org/pypi/salt
| IRC: #salt
| TcpPort: 4505
| TcpPort: 4506


Salt is a :ref:`Configuration Management` system
written in :ref:`Python`
which runs Salt Formulas
written in :ref:`YAML`, :ref:`Jinja2`, :ref:`Python`
for managing
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
      with various cloud providers (:ref:`libcloud`):

      + Google Compute Engine (GCE) [KVM]
      + Amazon EC2 [Xen]
      + Rackspace Cloud [KVM]
      + OpenStack [https://wiki.openstack.org/wiki/HypervisorSupportMatrix]
      + Linux LXC (Cgroups)
      + KVM



.. index:: Virtualization
.. _virtualization:

Virtualization
===============

.. index:: Cgroups
.. _cgroups:

Cgroups
~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Cgroups>`__
| Docs: https://www.kernel.org/doc/Documentation/cgroups/
| Docs: http://www.freedesktop.org/wiki/Software/systemd/ControlGroupInterface/
| Docs: https://docs.fedoraproject.org/en-US/Fedora/17/html-single/Resource_Management_Guide/index.html#sec-How_Control_Groups_Are_Organized
| Docs: https://wiki.archlinux.org/index.php/Cgroups

Cgroups are a :ref:`Linux` mechanism for containerizing
groups of processes and resources.

* https://chimeracoder.github.io/docker-without-docker/#1

  * ``systemd-nspawn``, ``systemd-cgroup``
  * ``machinectl``, ``systemctl``, ``journalctl``,


.. index:: Docker
.. _docker:

Docker
~~~~~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Docker_(software)>`_
| Homepage: https://www.docker.com/
| Docs: https://docs.docker.com/
| Source: https://github.com/docker/docker

Docker is an OS virtualization project which utilizes Linux LXC Containers
to partition process workloads all running under one kernel.

Limitations

* Writing to `/etc/hosts`: https://github.com/docker/docker/issues/2267
* Apt-get upgrade: https://github.com/docker/docker/issues/3934


.. index:: Kubernetes
.. _kubernetes:

Kubernetes
~~~~~~~~~~~
| Homepage: http://kubernetes.io/
| Source: https://github.com/GoogleCloudPlatform/kubernetes
| Docs: http://kubernetes.io/gettingstarted/
| Docs: https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/getting-started-guides/docker.md
| Docs: https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/getting-started-guides/vagrant.md
| Docs: https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/getting-started-guides/coreos.md
| Docs: https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/getting-started-guides/mesos.md
| Q&A: http://stackoverflow.com/questions/tagged/kubernetes
| Twitter: https://twitter.com/googlecloud

Kubernetes is a highly-available distributed cluster scheduler
which works with groups of :ref:`Docker` containers
called Pods.


.. index:: Kubernetes-Mesos
.. _kubernetes-mesos:

Kubernetes-Mesos
~~~~~~~~~~~~~~~~~
| Source: https://github.com/mesosphere/kubernetes-mesos

kubernetes-mesos integrates
:ref:`Kubernetes` :ref:`Docker` Pod scheduling with :ref:`Mesos`.

.. epigraph::

    Kubernetes and Mesos are a match made in heaven.

    Kubernetes enables the Pod,
    an abstraction that represents a group of co-located containers, along
    with Labels for service discovery, load-balancing, and replication control.

    Mesos provides the fine-grained resource allocations for pods
    across nodes in a cluster,
    and facilitates resource sharing
    among Kubernetes and other frameworks running on the same cluster.


.. index:: KVM
.. _KVM:

KVM
~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Kernel-based_Virtual_Machine
| Homepage: http://www.linux-kvm.org/
| Docs: http://www.linux-kvm.org/page/Documents

KVM is a full virtualization platform with support for
Intel VT and AMD-V; which supports running
various guest operating systems,
each with their own kernel,
on a given host machine.


.. index:: Libcloud
.. _libcloud:

Libcloud
~~~~~~~~~~~~~~~~~~
| Homepage: https://libcloud.apache.org/
| Docs: https://libcloud.readthedocs.org/en/latest/
| Docs: https://libcloud.readthedocs.org/en/latest/supported_providers.html
| Source: git git://git.apache.org/libcloud.git
| Source: git https://github.com/apache/libcloud

Apache libcloud is a :ref:`Python` library
which abstracts and unifies a large number of Cloud APIs for
Compute Resources, Object Storage, Load Balancing, and DNS.

:ref:`Salt` :term:`salt cloud` depends upon libcloud.


.. index:: Libvirt
.. _libvirt:

Libvirt
~~~~~~~~~~~~~~~~~
| Wikipedia: https://libvirt.org/
| Homepage: https://libvirt.org/
| Docs: https://libvirt.org/docs.html
| Docs: https://libvirt.org/cgroups.html
| Docs: https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.virt.html
| Source: git git://libvirt.org/libvirt-appdev-guide.git

Libvirt is a system for platform virtualization with
various :ref:`Linux` hypervisors.

* Xen
* QEMU, :ref:`KVM`
* OpenVZ, :ref:`LXC`
* :ref:`VirtualBox`


.. index:: LXC
.. _LXC:

LXC
~~~~
| Wikipedia: https://en.wikipedia.org/wiki/LXC
| Homepage: https://linuxcontainers.org/
| Docs: https://linuxcontainers.org/lxc/documentation/
| Source: https://github.com/lxc/lxc

LXC ("Linux Containers"),
written in :ref:`C`,
builds upon :ref:`Linux` :ref:`Cgroups`
to provide containerized OS chroots
(all running under :ref:`the host kernel <linux>`).

LXC is included in recent :ref:`Linux` kernels.


.. index:: LXD
.. _LXD:

LXD
~~~~
| Homepage: https://linuxcontainers.org/lxd/
| Docs: https://linuxcontainers.org/lxd/
| Source: https://github.com/lxc/lxd

LXD,
written in :ref:`Go`,
builds upon :ref:`LXC` to provide a system-wide daemon
and an :ref:`OpenStack` Nova hypervisor plugin.


.. index:: Mesos
.. _mesos:

Mesos
~~~~~~
| Homepage: https://mesos.apache.org/
| Source: git https://github.com/apache/mesos
| Q&A: https://stackoverflow.com/tags/mesos
| Twitter: https://twitter.com/ApacheMesos

Apache Mesos is a highly-available distributed datacenter operating system,
for which there are many different task/process/service schedulers.

.. epigraph::

    Apache Mesos abstracts CPU, memory, storage,
    and other compute resources away from machines (physical or virtual),
    enabling fault-tolerant and elastic distributed systems
    to easily be built and run effectively.


.. index:: Mesosphere
.. _mesosphere:

Mesosphere
~~~~~~~~~~~~~
| Homepage: https://mesosphere.com/
| Source: https://github.com/mesosphere
| Q&A: https://stackoverflow.com/tags/mesosphere
| Twitter: https://twitter.com/mesosphere

* Apache :ref:`Mesos` is a core Mesosphere service


.. index:: OpenStack
.. _openstack:

OpenStack
~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/OpenStack
| Homepage: https://www.openstack.org/
| Source: https://git.openstack.org
| Source: https://github.com/openstack
| Q&A: https://stackoverflow.com/questions/tagged/openstack
| Docs: http://docs.openstack.org/
| Docs: https://wiki.openstack.org/
| Docs: https://wiki.openstack.org/wiki/Get_OpenStack
| Twitter: https://twitter.com/openstack

OpenStack is a platform of infrastructure services
for running a cloud datacenter.

OpenStack can be installed on one machine with enough RAM,
or many thousands of machines.

OpenStack Nova implements a Hypervisor API
which abstracts various :ref:`Virtualization` providers
(e.g. :ref:`KVM`, :ref:`Docker`, :ref:`LXC`, :ref:`LXD`).

* https://wiki.openstack.org/wiki/HypervisorSupportMatrix
* http://docs.openstack.org/developer/nova/support-matrix.html

OpenStack Swift implements redundant HTTP-based Object Storage
as a service.

OpenStack Keystone implements cluster/grid/cloud-level
authentication and authorization
as a service.

OpenStack Horizon is the web-based OpenStack Dashboard,
which is written in Django.

OpenStack can configure enterprise networking services
and DNS, DHCP, VLANs, SDN.

OpenStack makes it possible for end-users to create a new virtual
machine from the available pool of resources.

``rdfs:seeAlso`` :ref:`Libcloud`.


.. index:: OpenStack DevStack
.. _openstack-devstack:

OpenStack DevStack
~~~~~~~~~~~~~~~~~~
| Docs: http://docs.openstack.org/developer/devstack/
| Docs: http://docs.openstack.org/developer/devstack/overview.html
| Source: git https://github.com/openstack-dev/devstack
| Issues: https://launchpad.net/devstack

OpenStack DevStack is a default development configuration
for :ref:`OpenStack`.

* https://github.com/openstack-dev/devstack-vagrant

There are many alternatives to and implementations of OpenStack DevStack:

* https://github.com/saltstack-formulas/openstack-standalone-formula
* https://github.com/CSSCorp/openstack-automation
* https://github.com/openstack-ansible/openstack-ansible
* https://forge.puppetlabs.com/puppetlabs/openstack
* https://jujucharms.com/q/openstack
* https://anvil.readthedocs.org/en/latest/topics/summary.html


.. index:: Packer
.. _packer:

Packer
~~~~~~~~~~~~~~~~~
| Homepage: https://www.packer.io/
| Docs: http://www.packer.io/docs
| Docs: http://www.packer.io/docs/basics/terminology.html
| Source: git https://github.com/mitchellh/packer

Packer generates machine images for multiple platforms, clouds,
and hypervisors from a parameterizable template.

.. glossary::

   Packer Artifact
      Build products: machine image and manifest

   Packer Template
      JSON build definitions with optional variables and templating

   Packer Build
      Task defined by a JSON file containing build steps
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



.. index:: Vagrant
.. _vagrant:

Vagrant
~~~~~~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Vagrant_(software)>`_
| Homepage: https://www.vagrantup.com/
| Docs: http://docs.vagrantup.com/v2/
| Source: git https://github.com/mitchellh/vagrant


Vagrant is a tool written in :ref:`Ruby`
for creating and managing virtual machine instances
with CPU, RAM, Storage, and Networking.

* Vagrant:

  * Works with a number of Cloud :ref:`Virtualization` providers:

    * VirtualBox
    * AWS
    * GCE
    * OpenStack

  * provides helpful commandline porcelain on top of
    :ref:`VirtualBox` ``VboxManage``
  * installs and lifecycles *Vagrant Boxes*

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



.. index:: VirtualBox
.. _virtualbox:

VirtualBox
~~~~~~~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/VirtualBox
| Homepage: https://www.virtualbox.org/
| Docs: https://www.virtualbox.org/wiki/Documentation
| Source: svn svn://www.virtualbox.org/svn/vbox/trunk


Oracle VirtualBox is a platform virtualization package
for running one or more guest VMs (virtual machines) within a host system.

VirtualBox:

* runs on many platforms: :ref:`Linux`, OSX, Windows
* has support for full platform NX/AMD-v virtualization
* requires matching kernel modules

:ref:`Vagrant` scripts VirtualBox.


.. index:: Shells
.. shells:

Shells
========

.. index:: Bash
.. _bash:

Bash
~~~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>`__
| Homepage: http://www.gnu.org/software/bash/
| Docs: https://www.gnu.org/software/bash/manual/
| Source: git git://git.savannah.gnu.org/bash.git

GNU Bash, the Bourne-again shell.

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


.. index:: Readline
.. _readline:

Readline
~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/GNU_Readline
| Homepage: http://tiswww.case.edu/php/chet/readline/rltop.html
| Docs: http://tiswww.case.edu/php/chet/readline/readline.html
| Docs: http://tiswww.case.edu/php/chet/readline/history.html
| Docs: http://tiswww.case.edu/php/chet/readline/rluserman.html
| Source: ftp ftp://ftp.gnu.org/gnu/readline/readline-6.3.tar.gz
| Pypi: https://pypi.python.org/pypi/gnureadline


.. index:: IPython
.. index:: ipython
.. _ipython:

IPython
~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/IPython
| Homepage: http://ipython.org/
| Docs: http://ipython.org/ipython-doc/stable/
| Docs: https://github.com/ipython/ipython/wiki/Extensions-Index
| Docs: https://github.com/ipython/ipython/wiki/A-gallery-of-interesting-IPython-Notebooks
| Source: git https://github.com/ipython/ipython

IPython is an interactive REPL and distributed computation framework
written in :ref:`Python`.

An IPython notebook file (``.ipynb``) is a
JSON document containing input and output
for a linear sequence of cells;
which can be exported to many output formats (e.g. HTML, RST, LaTeX, PDF);
and edited through the web with
IPython Notebook.

.. code:: python

    1 + 1
    x = 1+1
    print("1 + 1 = %d" (x))

    # IPython
    ?                              # help
    %lsmagic
    %<tab>                         # list magic commands and aliases
    %logstart?                     # help for the %logstart magic command
    %logstart -o logoutput.log.py  # log input and output to a file
    import json
    json?                          # print(json.__doc__)
    json??                         # print(inspect.getsource(json))

    # IPython shell
    !cat ./README.rst; echo $PWD   # run shell commands
    lines = !ls -al                # capture shell command output
    print(lines[0:])
    %run -i -t example.py          # run a script with timing info,
                                   # in the local namespace
    %run -d example.py             # run a script with pdb
    %pdb on                        # automatically run pdb on Exception

.. note:: IPython notebook runs code and shell commands as
  the user the process is running as, on a remote or local machine.

  IPython notebook supports more than 20 different languages.

Reproducible :ref:`SciPy Stack <scipystack>`
IPython / Jupyter Notebook servers
implement best practices like process isolation and privilege separation:

* https://github.com/ipython/ipython/wiki/Install:-Docker
* https://registry.hub.docker.com/repos/ipython/
* https://registry.hub.docker.com/repos/jupyter/
* https://registry.hub.docker.com/u/jupyter/tmpnb/


IPython / Jupyter Notebook Viewer (``nbviewer``)
is an application for serving read-only
versions of notebooks which have HTTP URLs.

* http://nbviewer.ipython.org
* https://github.com/jupyter/nbviewer


.. index:: PowerShell
.. index:: Windows PowerShell
.. _powershell:

PowerShell
~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Windows_PowerShell
| Homepage: https://microsoft.com/powershell

Windows PowerShell is a shell for :ref:`Windows`.


.. index:: ZSH
.. _zsh:

ZSH
~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Z_shell
| Homepage: http://www.zsh.org/
| Docs: http://zsh.sourceforge.net/Guide/zshguide.html
| Docs: http://zsh.sourceforge.net/Doc/
| Source: git git://git.code.sf.net/p/zsh/code


* https://github.com/robbyrussell/oh-my-zsh


.. index:: Shell Utilities
.. shell-utilities:

Shell Utilities
=================


.. index:: Awk
.. _awk:

Awk
~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/AWK>`__
| Docs: https://en.wikipedia.org/wiki/AWK#Versions_and_implementations
| GNU Awk
| Project: https://savannah.gnu.org/projects/gawk/
| Homepage: https://www.gnu.org/software/gawk/
| Docs: https://www.gnu.org/software/gawk/manual/
| Docs: https://www.gnu.org/software/gawk/manual/gawk.html
| Source: git git://git.savannah.gnu.org/gawk.git

AWK is a pattern programming language for matching and transforming text.

.. index:: Grep
.. _grep:

Grep
~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Grep>`__
| Homepage: https://www.gnu.org/software/grep/
| Project: https://savannah.gnu.org/projects/grep/
| Docs: https://www.gnu.org/software/grep/manual/
| Docs: https://www.gnu.org/software/grep/manual/grep.html
| Source: git git://git.savannah.gnu.org/grep.git

Grep is a UXIX CLI utility for pattern-based text matching.


.. index:: Htop
.. _htop:

Htop
~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Htop
| Homepage: http://hisham.hm/htop/
| Source: git http://hisham.hm/htop/


.. index:: Pyline
.. _pyline:

Pyline
~~~~~~~~
| Homepage: https://github.com/westurner/pyline
| Docs: https://pyline.readthedocs.org/en/latest/
| Source: git https://github.com/westurner/pyline
| Pypi: https://pypi.python.org/pypi/pyline

Pyline is a UNIX command-line tool for line-based processing in Python
with regex and output transform features similar to
:ref:`grep`, :ref:`sed`, and :ref:`awk`.

Pyline can generate quoted CSV, :ref:`JSON`, HTML, etc.


.. index:: Pyrpo
.. _pyrpo:

Pyrpo
~~~~~~
| Homepage: https://github.com/westurner/pyrpo
| Source: git https://github.com/westurner/pyrpo
| Pypi: https://pypi.python.org/pypi/pyrpo

Pyrpo is a tool for locating and generating reports
from :ref:`Git`, :ref:`Mercurial`, :ref:`Bazaar`,
and :ref:`Subversion` repositories.


.. index:: Sed
.. _sed:

Sed
~~~~~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Sed>`__
| Homepage: https://www.gnu.org/software/sed/
| Project: https://savannah.gnu.org/projects/sed
| Docs: https://www.gnu.org/software/sed/manual/
| Docs: https://www.gnu.org/software/sed/manual/sed.html
| Docs: http://sed.sourceforge.net/
| Source: git git.savannah.gnu.org/sed.git

GNU Sed is a UNIX CLI utility for transforming text.

.. note:: BSD Sed

   Use ``<Ctrl-V><tab>`` for explicit tabs (as ``\t`` does not work)

   Use ``\\\n`` or ``'$'\n`` for newlines (as ``\n`` does not work)

   ``sed -E`` should be consistent extended regular expressions
   between GNU Sed (e.g. Linux) and BSD Sed (FreeBSD, OSX).

   OR: ``brew install gnu-sed``

   See: https://unix.stackexchange.com/questions/101059/sed-behaves-different-on-freebsd-and-on-linux

   See: https://superuser.com/questions/307165/newlines-in-sed-on-mac-os-x


.. index:: Dotfiles
.. _dotfiles:

Dotfiles
==========

Userspace configuration in files that are often prefixed with "dot"
(e.g. ``~/.bashrc`` for :ref:`Bash`)

| Src: https://github.com/westurner/dotfiles
| Docs: https://westurner.org/dotfiles/


.. index:: Dotvim
.. _dotvim:

Dotvim
~~~~~~~~

| Src: https://github.com/westurner/dotvim
| Docs: https://westurner.org/dotfiles/usage#vim



.. index:: Venv
.. _venv:

Venv
~~~~~

| Docs: https://westurner.org/dotfiles/venv
| Docs: https://westurner.org/dotfiles/dotfiles.venv
| Src: https://github.com/westurner/dotfiles/blob/develop/src/dotfiles/venv/
| Src: https://github.com/westurner/dotfiles/blob/develop/etc/bash/10-bashrc.venv.sh

Venv is a tool for making working with :ref:`Virtualenv`,
:ref:`Virtualenvwrapper`, :ref:`Bash`, :ref:`ZSH`, :ref:`Vim`,
and :ref:`IPython` within a project context very easy.

Venv defines standard paths, environment variables, and aliases
for routinizing workflow.

+---------------------+--------------------------------+--------------------------------------+----------------------------------------+
| **var name**        | **description**                | **cdaliases**                        | **example path**                       |
|                     |                                |                                      |                                        |
|                     |                                | Bash: ``cdhelp``                     |                                        |
|                     |                                |                                      |                                        |
|                     |                                | IPython: ``%cdhelp``                 |                                        |
|                     |                                |                                      |                                        |
|                     |                                | Vim: ``:Cdhelp``                     |                                        |
+---------------------+--------------------------------+--------------------------------------+----------------------------------------+
| ``HOME``            | user home directory            | Bash/ZSH: ``cdh``, ``cdhome``        | ``~/``                                 |
|                     |                                |                                      |                                        |
|                     |                                | IPython: ``%cdh``, ``%cdhome``       |                                        |
|                     |                                |                                      |                                        |
|                     |                                | Vim: ``:Cdh``, ``:Cdhome``           |                                        |
+---------------------+--------------------------------+--------------------------------------+----------------------------------------+
| ``__WRK``           | workspace root                 | ``cdwrk`` (ibid.)                    | ~/``-wrk``                             |
+---------------------+--------------------------------+--------------------------------------+----------------------------------------+
| ``WORKON_HOME``     | virtualenvs root               | ``cdwh``, ``cdworkonhome``, ``cdve`` | ~/-wrk/``-ve27``                       |
+---------------------+--------------------------------+--------------------------------------+----------------------------------------+
| ``CONDA_ENVS_PATH`` | condaenvs root                 | ``cdch``, ``cdcondahome``            | ~/-wrk/``-ce27``                       |
+---------------------+--------------------------------+--------------------------------------+----------------------------------------+
| ``VIRTUAL_ENV``     | virtualenv root                | ``cdv``, ``cdvirtualenv``            | ~/-wrk/-ve27/``dotfiles``              |
+---------------------+--------------------------------+--------------------------------------+----------------------------------------+
| ``_BIN``            | virtualenv executables         | ``cdb``, ``cdbin``                   | ~/-wrk/-ve27/dotfiles/``bin``          |
+---------------------+--------------------------------+--------------------------------------+----------------------------------------+
| ``_ETC``            | virtualenv configuration       | ``cd``, ``cdetc``                    | ~/-wrk/-ve27/dotfiles/``etc``          |
+---------------------+--------------------------------+--------------------------------------+----------------------------------------+
| ``_LIB``            | virtualenv lib directory       | ``cdl``, ``cdlib``                   | ~/-wrk/-ve27/dotfiles/``lib``          |
+---------------------+--------------------------------+--------------------------------------+----------------------------------------+
| ``_LOG``            | virtualenv log directory       | ``cdlog``                            | ~/-wrk/-ve27/dotfiles/``var/log``      |
+---------------------+--------------------------------+--------------------------------------+----------------------------------------+
| ``_SRC``            | virtualenv source repositories | ``cds``, ``cdsrc``                   | ~/-wrk/-ve27/dotfiles/``src``          |
+---------------------+--------------------------------+--------------------------------------+----------------------------------------+
| ``_WRD``            | virtualenv working directory   | ``cdw``, ``cdwrd``                   | ~/-wrk/-ve27/dotfiles/``src/dotfiles`` |
|                     |                                |                                      |                                        |
+---------------------+--------------------------------+--------------------------------------+----------------------------------------+

To generate this venv config:

.. code:: bash

   python -m dotfiles.venv.ipython_config --print-bash dotfiles
   venv.py --print-bash dotfiles
   venv --print-bash dotfiles docs
   venv --print-bash dotfiles ~/path
   venv --print-bash ~/-wrk/-ve27/dotfiles ~/path

To generate a default venv config with a prefix of ``/``:

.. code:: bash

    venv --print-bash --prefix=/

To launch an interactive shell within a venv:

.. code:: bash

    venv --run-bash dotfiles
    venv -xb dotfiles

.. note:: ``pyvenv`` is the :ref:`Virtualenv` -like functionality
   now included in :ref:`Python >= 3.3 <python3>` (``python3 -m venv``)

   Python pyvenv docs: https://docs.python.org/3/library/venv.html

.. index:: Virtualenv
.. _virtualenv:

Virtualenv
~~~~~~~~~~~~~~~~~~~~
| Homepage: http://www.virtualenv.org
| Docs: https://virtualenv.pypa.io/en/latest/
| Source: git https://github.com/pypa/virtualenv
| PyPI: https://pypi.python.org/pypi/virtualenv
| IRC: #pip

Virtualenv is a tool for creating reproducible :ref:`Python` environments.

Virtualenv sets the shell environment variable ``$VIRTUAL_ENV`` when active.

Virtualenv installs a copy of :ref:`Python`, :ref:`Setuptools`, and
:ref:`Pip` when a new virtualenv is created.

A virtualenv is activated by ``source``-ing ``${VIRTUAL_ENV}/bin/activate``.

Paths within a virtualenv are more-or-less :ref:`FHS <fhs>`
standard paths, which makes
virtualenv structure very useful for building
chroot and container overlays.

A standard virtual environment::

   bin/           # pip, easy_install, console_scripts
   bin/activate   # source bin/activate to work on a virtualenv
   include/       # (symlinks to) dev headers (python-dev/python-devel)
   lib/           # libraries
   lib/python2.7/distutils/
   lib/python2.7/site-packages/  # pip and easy_installed packages
   local/         # symlinks to bin, include, and lib
   src/           # editable requirements (source repositories)

   # also useful
   etc/           # configuration
   var/log        # logs
   var/run        # sockets, PID files
   tmp/           # mkstemp temporary files with permission bits
   srv/           # local data

:ref:`Virtualenvwrapper` wraps virtualenv.

.. code-block:: bash

   echo $PATH; echo $VIRTUAL_ENV
   python -m site; pip list

   virtualenv example               # mkvirtualenv example
   source ./example/bin/activate    # workon example

   echo $PATH; echo $VIRTUAL_ENV
   python -m site; pip list

   ls -altr $VIRTUAL_ENV/lib/python*/site-packages/**  # lssitepackages -altr


.. note:: :ref:`Venv` extends :ref:`virtualenv` and :ref:`virtualenvwrapper`.

.. note::
   Python 3.3+ now also contain a script called **venv**, which
   performs the same functions and works similarly to virtualenv:
   `<https://docs.python.org/3/library/venv.html>`_.


.. index:: Virtualenvwrapper
.. _virtualenvwrapper:

Virtualenvwrapper
~~~~~~~~~~~~~~~~~~~~~~~~~~~
| Docs: http://virtualenvwrapper.readthedocs.org/en/latest/
| Source: hg https://bitbucket.org/dhellmann/virtualenvwrapper
| PyPI: https://pypi.python.org/pypi/virtualenvwrapper

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

.. note:: :ref:`Venv` extends :ref:`virtualenv` and :ref:`virtualenvwrapper`.

.. code-block:: bash

   echo $PROJECT_HOME; echo ~/workspace             # venv: ~/-wrk
   cd $PROJECT_HOME                                 # venv: cdp; cdph
   echo $WORKON_HOME;  echo ~/.virtualenvs          # venv: ~/-wrk/-ve27
   cd $WORKON_HOME                                  # venv: cdwh; cdwrk

   mkvirtualenv example
   workon example                                   # venv: we example

   cdvirtualenv; cd $VIRTUAL_ENV                    # venv: cdv
   echo $VIRTUAL_ENV; echo ~/.virtualenvs/example   # venv: ~/-wrk/-ve27/example

   mkdir src ; cd src/                              # venv: cds; cd $_SRC

   pip install -e git+https://github.com/westurner/dotfiles#egg=dotfiles

   cd src/dotfiles; cd $VIRTUAL_ENV/src/dotfiles    # venv: cdw; cds dotfiles
   head README.rst

                                                    # venv: cdpylib
   cdsitepackages                                   # venv: cdpysite
   lssitepackages

   deactivate
   rmvirtualenv example

   lsvirtualenvs; ls -d $WORKON_HOME                # venv: lsve; lsve 'ls -d'




.. index:: Window Managers
.. window-managers:

Window Managers
================

.. index:: Compiz
.. _compiz:

Compiz
~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Compiz
| Homepage: https://launchpad.net/compiz
| Docs: http://wiki.compiz.org/
| Source: bzr branch lp:compiz


Compiz is a window compositing layer for :ref:`X11` which adds
lots of cool and productivity-enhancing visual capabilities.

Compiz works with :ref:`Gnome`, :ref:`KDE`, and :ref:`Qt` applications.


.. index:: Gnome
.. _gnome:

Gnome
~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/GNOME
| Homepage: http://www.gnome.org/
| Docs: https://help.gnome.org/
| Source: https://git.gnome.org/browse/


* https://wiki.gnome.org/GnomeLove


.. index:: i3wm
.. _i3wm:

i3wm
~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/I3_(window_manager)>`__
| Homepage: http://i3wm.org/
| Docs: http://i3wm.org/docs/
| Source: git git://code.i3wm.org/i3

i3wm is a tiling window manager for :ref:`X11` (:ref:`Linux`)
with extremely-configurable :ref:`Vim`-like keyboard shortcuts.

i3wm works with :ref:`Gnome`, :ref:`KDE`, and :ref:`Qt` applications.

* http://i3wm.org/downloads/


.. index:: KDE
.. _kde:

KDE
~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/KDE
| Homepage: https://www.kde.org/
| Docs: https://docs.kde.org/
| Docs: https://www.kde.org/documentation/
| Source: https://techbase.kde.org/Getting_Started/Sources
| Source: https://techbase.kde.org/Getting_Started/Sources/Subversion
| Source: https://techbase.kde.org/Development/Git
| Source: https://projects.kde.org/projects


KDE is a GUI framework built on :ref:`Qt`.

KWin is the main KDE window manager for :ref:`X11`.


.. index:: Qt
.. _qt:

Qt
~~~
| Wikipedia: https://en.wikipedia.org/wiki/Qt_Project
| Homepage: https://qt-project.org/
| Homepage: http://qt.io/
| Docs: http://doc.qt.io/
| Docs: http://doc.qt.io/qt-5/qtexamplesandtutorials.html
| Docs: http://www.qt.io/contribute/
| Docs: http://wiki.qt.io/Main_Page
| Docs: https://wiki.qt.io/Get_the_Source
| Src: git http://code.qt.io/cgit/

Qt is a Graphical User Interface toolkit for
developing applications with
Android, iOS, :ref:`OSX`, Windows, Embedded :ref:`Linux`, and :ref:`X11`.


.. index:: Wayland
.. _wayland:

Wayland
~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Wayland_(display_server_protocol)>`_
| Homepage: http://wayland.freedesktop.org/
| Source:


Wayland is a display server protocol for GUI window management.

Wayland is an alternative to :ref:`X11` servers like XFree86 and X.org.

The reference Wayland implementation, Weston, is written in :ref:`C`.


.. index:: X Window System
.. index:: X11
.. _x11:

X11
~~~~
| Wikipedia: https://en.wikipedia.org/wiki/X_Window_System
| Homepage: http://www.x.org/
| Docs: http://www.x.org/wiki/Documentation/
| Source: git git://anongit.freedesktop.org/git/xorg/


X Window System (X, X11) is a display server protocol for window management
(drawing windows on the screen).

Most UNIX and :ref:`Linux` systems utilize XFree86 or the newer X.org
X11 window managers.

:ref:`Gnome`, :ref:`KDE`, :ref:`I3wm`, :ref:`OSX`, and :ref:`Compiz`
build upon X11.

.. index:: Browsers
.. _browsers:


Browsers
==========

.. index:: Chrome
.. _chrome:

Chrome
~~~~~~~

.. index:: Chrome DevTools
.. _chrome-devtools:

Chrome DevTools
++++++++++++++++
| Homepage: https://developer.chrome.com/devtools
| Docs: https://developer.chrome.com/devtools

* Right-click > "Inspect Element"
* OSX: ``<option>`` + ``<command>`` + ``i``

.. index:: Chrome Extensions

Chrome Extensions
+++++++++++++++++++

**Accessibility**

* `Accessibility Developer Tools`_
* `ChromeVox`_
* `Deluminate`_
* `High Contrast`_
* `Spectrum`_
* `Stylish`_


**Safety**

* `Ghostery`_
* `HTTPS Everywhere`_
* `uBlock`_

**Content**

* `Hypothesis`_
* `Pocket`_
* `Zotero`_

**Tab**

* `OneTab`_
* `Snipe`_
* `Tabs Outliner`_

**Development**

* `FireBug`_ (see: `Chrome DevTools`_)
* `FireLogger for Chrome`_
* `JSONView`_
* `Postman`_
* `React Developer Tools`_
* `Requirify`_
* `Web Developer`_

**Vim**

* `Vimium`_
* `Wasavi`_

.. index:: pbm
.. _pbm:

pbm
++++
| Source: git https://github.com/westurner/pbm
| PyPI: https://pypi.python.org/pypi/pbm
| Warehouse: https://warehouse.python.org/project/pbm

* backup and organize :ref:`Chrome` ``Bookmarks`` JSON in an offline batch
* date-based transforms
* quicklinks
* starred bookmarks (with trailing ``##``)

.. index:: Chrome Android
.. _chrome android:

Chrome Android
~~~~~~~~~~~~~~~
**Extensions**

Chrome Android does not support extensions.

.. index:: Wandroid
.. _wandroid:

Wandroid
++++++++++
| Source: hg https://bitbucket.org/westurner/wandroid

 + https://bitbucket.org/westurner/wandroid/src/tip/wandroid/apps/chrome/config.py
 + https://bitbucket.org/westurner/wandroid/src/tip/wandroid/apps/chrome/userdata.py


.. index:: Firefox
.. _firefox:

Firefox
~~~~~~~~

.. index:: Firefox Extensions
.. _firefox extensions:

Firefox Extensions
+++++++++++++++++++
**Accessibility**

* `Stylish`_

**Safety**

* `Ghostery`_
* `HTTPS Everywhere`_
* `uBlock`_

**Content**

* `Pocket`_
* `Zotero`_

**Tabs**

* `OneTab`_
* `Tree Style Tab`_

**Development**

* `FireBug`_
* `FireLogger`_
* `Web Developer`_

**Vim**

* `Vimperator`_
* `Wasavi`_

.. index:: Firefox Android
.. _firefox android:

Firefox Android
~~~~~~~~~~~~~~~~

.. index:: Firefox Android Extensions
.. _firefox android extensions:

Firefox Android Extensions
+++++++++++++++++++++++++++
* `Ghostery`_
* `HTTPS Everywhere`_


.. index:: Safari
.. _safari:

Safari
~~~~~~~

.. index:: Safari Extensions
.. _safari extension:

Safari Extensions
+++++++++++++++++++
**Safety**

* `Ghostery`_
* `uBlock`_

**Content**

* `Zotero`_
* `Pocket`_



.. index:: Safari iOS
.. _safari ios:

Safari iOS
~~~~~~~~~~~~~~~

* `Pocket`_


.. index:: Browser Extensions
.. _browser extensions:

Browser Extensions
====================

.. index:: Browser Extensions > Accessibility
.. _accessibility extensions:

Accessibility Extensions
~~~~~~~~~~~~~~~~~~~~~~~~~~

* Google Chrome Accesibility Extensions:
  https://chrome.google.com/webstore/category/ext/22-accessibility?hl=en
* Mozilla Firefox Accesibility Extensions:
  `<https://addons.mozilla.org/en-US/firefox/search/?q=accessibility>`__


.. index:: Accessibility Developer Tools
.. _accessibility developer tools:

Accessibility Developer Tools
++++++++++++++++++++++++++++++
| ChromeExt: https://chrome.google.com/webstore/detail/accessibility-developer-t/fpkknkljclfencbdbgkenhalefipecmb


.. index:: ChromeVox
.. _chromevox:

ChromeVox
++++++++++
| Homepage: http://www.chromevox.com/
| ChromeExt: https://chrome.google.com/webstore/detail/chromevox/kgejglhpjiefppelpmljglcjbhoiplfn


.. index:: Deluminate
.. _deluminate:

Deluminate
+++++++++++
| Homepage: https://deluminate.github.io/
| Source: https://github.com/abstiles/deluminate
| ChromeExt: https://chrome.google.com/webstore/detail/deluminate/iebboopaeangfpceklajfohhbpkkfiaa


.. index:: High Contrast
.. _high contrast:

High Contrast
++++++++++++++
| ChromeExt: https://chrome.google.com/webstore/detail/high-contrast/djcfdncoelnlbldjfhinnjlhdjlikmph


.. index:: Spectrum
.. _spectrum:

Spectrum
+++++++++
| Source: https://github.com/lvivski/spectrum
| ChromeExt: https://chrome.google.com/webstore/detail/spectrum/ofclemegkcmilinpcimpjkfhjfgmhieb


.. index:: Stylish
.. _stylish:

Stylish
++++++++
| ChromeExt: https://chrome.google.com/webstore/detail/stylish/fjnbnpbmkenffdnngjfgmeleoegfcffe
| FirefoxExt: https://addons.mozilla.org/en-us/firefox/addon/stylish/
| FirefoxXPI: https://addons.mozilla.org/firefox/downloads/latest/2108/addon-2108-latest.xpi
| Docs: https://userstyles.org/help/
| Docs: https://userstyles.org/help/stylish_chrome
| Docs: https://userstyles.org/help/stylish_firefox

* https://userstyles.org/


.. index:: Browser Extensions > Safety
.. index:: Safety Extensions
.. _safety extensions:

Safety Extensions
~~~~~~~~~~~~~~~~~~~

.. index:: Ghostery
.. _ghostery:

Ghostery
++++++++++
| Homepage: https://www.ghostery.com/en/home
| Source: https://www.ghostery.com/en/download
| FirefoxExt: https://addons.mozilla.org/en-us/firefox/addon/ghostery/
| FirefoxXPI: https://addons.mozilla.org/firefox/downloads/latest/9609/addon-9609-latest.xpi
| ChromeExt: https://chrome.google.com/webstore/detail/ghostery/mlomiejdfkolichcflejclcbmpeaniij
| OperaExt: https://addons.opera.com/addons/extensions/details/ghostery/
| SafariExt: https://www.ghostery.com/safari/Ghostery.safariextz
| MSIEExt: https://www.ghostery.com/ie/ghostery-ie.exe
| AndroidApp: https://play.google.com/store/apps/details?id=com.ghostery.android.ghostery
| iOSApp: https://itunes.apple.com/us/app/ghostery/id472789016
| FirefoxAndroidXPI: https://addons.mozilla.org/android/downloads/latest/ghostery
| FirefoxAndroidExt: https://addons.mozilla.org/en-US/android/addon/ghostery/


.. index:: HTTPS Everywhere
.. _https everywhere:

HTTPS Everywhere
+++++++++++++++++
| Homepage: https://www.eff.org/https-everywhere
| Source: https://github.com/EFForg/https-everywhere
| ChromeExt: https://chrome.google.com/webstore/detail/gcbommkclmclpchllfjekcdonpmejbdp
| FirefoxXPI: https://www.eff.org/files/https-everywhere-latest.xpi
| FirefoxAndroidXPI: https://www.eff.org/files/https-everywhere-android.xpi
| Twitter: https://twitter.com/HTTPSEverywhere

.. index:: uBlock
.. _ublock:

uBlock
++++++++
| Homepage: https://www.ublock.org/
| Source: https://github.com/chrisaljoudi/ublock
| Download: https://github.com/chrisaljoudi/uBlock/releases/latest
| ChromeExt: https://chrome.google.com/webstore/detail/ublock/epcnnfbjfcgphgdmggkamkmgojdagdnn
| FirefoxExt: https://addons.mozilla.org/en-US/firefox/addon/ublock/
| SafariExt: https://extensions.apple.com/details/?id=net.gorhill.uBlock-96G4BAKDQ9
| Docs: https://www.ublock.org/faq/

.. code:: bash

   _repo="chrisaljoudi/ublock"
   curl -s "https://api.github.com/repos/${_repo}/releases" > ./releases.json
   cat releases.json \
       | grep browser_download_url \
       | pyline 'w and w[1][1:-1]' \
       | pyline --regex \
           '.*download/(.*)/(uBlock.(firefox.xpi|chromium.zip))$' \
           'rgx and rgx.group(1,2)'


.. index:: Browser Extensions > Content
.. index:: Content Extensions
.. _content-extensions:

Content Extensions
~~~~~~~~~~~~~~~~~~~~

.. index:: Hypothesis
.. _hypothesis:

Hypothesis
+++++++++++
| Homepage: https://hypothes.is/
| Source: https://github.com/hypothesis/h
| ChromeExt: https://chrome.google.com/webstore/detail/hypothesis-web-pdf-annota/bjfhmglciegochdpefhhlphglcehbmek
| Twitter: https://twitter.com/hypothes_is

Hypothesis can also be included as a sidebar on a site:

.. code:: html

   <script async defer src="//hypothes.is/embed.js"></script>


.. index:: Pocket
.. _pocket:

Pocket
+++++++
| Homepage: https://getpocket.com/
| ChromeApp: https://chrome.google.com/webstore/detail/pocket/mjcnijlhddpbdemagnpefmlkjdagkogk
| ChromeExt: https://chrome.google.com/webstore/detail/save-to-pocket/niloccemoadcdkdjlinkgdfekeahmflj
| FirefoxExt: https://addons.mozilla.org/en-US/firefox/addon/read-it-later/
| FirefoxXPI: https://addons.mozilla.org/firefox/downloads/latest/7661/addon-7661-latest.xpi
| SafariLink: https://getpocket.com/safari/
| iOSLink: https://getpocket.com/ios/


.. index:: Zotero
.. _zotero:

Zotero
++++++++
| Homepage: https://www.zotero.org/
| ChromeExt: https://chrome.google.com/webstore/detail/zotero-connector/ekhagklcjbdpajgpjgmbionohlpdbjgc
| FirefoxXPI: https://download.zotero.org/extension/zotero-4.0.26.4.xpi
| SafariExt: https://download.zotero.org/connector/safari/Zotero_Connector-4.0.21-1.safariextz
| Download: https://www.zotero.org/download/
| Docs: https://www.zotero.org/support/
| Docs: https://www.zotero.org/support/sync
| Docs: https://www.zotero.org/support/kb/webdav_services

Zotero archives and tags resources with bibliographic metadata.

* Zotero is really helpful for research.
* Browsers other than Firefox connect to Zotero Standalone
* Zotero can store a full-page archive of a given resource (e.g. HTML, PDF)
* Zotero can store and synchronize data on Zotero's servers
  with Zotero File Storage
* Zotero can store and synchronize data over WebDAV
* Zotero can export a collection of resources' bibliographic metadata
  in one of many citation styles ("CSL") (e.g. MLA, APA, [Journal XYZ])

  * https://www.zotero.org/styles
  * http://citationstyles.org/

* Zotero can export a collection of resources' bibliographic metadata
  as RDF


.. index:: Zotero and Schema.org RDFa

-------------------------------
[ ] Zotero and Schema.org RDFa
-------------------------------
* https://forums.zotero.org/discussion/35992/export-to-schemaorg-rdfa-andor-microdata/

> How would I go about adding HTML + RDFa [1] and/or HTML + Microdata [2] export templates with Schema.org classes and properties to Zotero?

* https://groups.google.com/forum/#!topic/zotero-dev/rJnMZYrhwM4
* https://lists.w3.org/Archives/Public/public-vocabs/2014Apr/0202.html
  (COinS, Citeproc-js, OpenAnnotation (+1))


.. index:: Browser Extensions > Tabs
.. index:: Tab Extensions
.. _tab extensions:

Tab Extensions
~~~~~~~~~~~~~~~~

.. index:: OneTab
.. _onetab:

OneTab
+++++++
| Homepage: https://www.one-tab.com/
| ChromeExt: https://chrome.google.com/webstore/detail/onetab/chphlpgkkbolifaimnlloiipkdnihall
| FirefoxExt: https://addons.mozilla.org/en-US/firefox/addon/onetab/
| FirefoxXPI: https://addons.mozilla.org/firefox/downloads/latest/525044/addon-525044-latest.xpi

* https://github.com/Greduan/chrome-ext-tabulator


.. index:: Snipe
.. _snipe:

Snipe
+++++++
| Homepage: http://joe.sh/snipe
| Source: https://github.com/josephschmitt/Snipe
| ChromeExt: https://chrome.google.com/webstore/detail/snipe/glmjakogmemenallddiiajdgjfoogegl


.. index:: Tabs Outliner
.. _tabs outliner:

Tabs Outliner
++++++++++++++
| ChromeExt: https://chrome.google.com/webstore/detail/tabs-outliner/eggkanocgddhmamlbiijnphhppkpkmkl


.. index:: Tree Style Tab
.. _tree style tab:

Tree Style Tab
+++++++++++++++
| Homepage: http://piro.sakura.ne.jp/xul/_treestyletab.html.en
| FirefoxExt: https://addons.mozilla.org/en-US/firefox/addon/tree-style-tab/


.. index:: Browser Extensions > Development
.. index:: Development Extensions
.. _development extensions:

Development Extensions
~~~~~~~~~~~~~~~~~~~~~~~~~

.. index:: FireBug
.. _firebug:

FireBug
+++++++++
| Homepage: http://getfirebug.com/
| FirefoxExt: https://addons.mozilla.org/en-us/firefox/addon/firebug/
| FirefoxXPI: https://addons.mozilla.org/firefox/downloads/latest/1843/addon-1843-latest.xpi
| ChromeExt: https://chrome.google.com/extensions/detail/bmagokdooijbeehmkpknfglimnifench

* https://getfirebug.com/firebuglite
* https://getfirebug.com/wiki/index.php/Firebug_Extensions


.. index:: FireLogger
.. _firelogger:

FireLogger
++++++++++++
| Homepage: http://firelogger.binaryage.com/
| Source: https://github.com/binaryage/firelogger
| FirefoxExt: https://addons.mozilla.org/en-US/firefox/addon/firelogger/
| FirefoxXPI: https://addons.mozilla.org/firefox/downloads/file/226289/firelogger-1.3-fx.xpi
| Docs: https://github.com/binaryage/firelogger/wiki

* Python: https://github.com/binaryage/firelogger.py
* PHP: https://github.com/binaryage/firelogger.php
* ColdFusion: http://cffirelogger.riaforge.org/
* Java: https://github.com/clescot/webappender


.. index:: FireLogger for Chrome
.. _firelogger for chrome:

FireLogger for Chrome
++++++++++++++++++++++
| Source: https://github.com/MattSkala/chrome-firelogger
| ChromeExt: https://chrome.google.com/webstore/detail/firelogger-for-chrome/hmagilfopmdjkeomnjpchokglfdfjfeh

See: `FireLogger`_


.. index:: JSONView
.. _jsonview:

JSONView
+++++++++
| Source: https://github.com/gildas-lormeau/JSONView-for-Chrome
| ChromeExt: https://chrome.google.com/webstore/detail/jsonview/chklaanhfefbnpoihckbnefhakgolnmc


.. index:: Postman
.. _postman:

Postman
++++++++
| Source: https://github.com/a85/POSTMan-Chrome-Extension
| ChromeExt: https://chrome.google.com/webstore/detail/postman-rest-client/fdmmgilgnpjigdojojpjoooidkmcomcm
| Twitter: https://twitter.com/postmanclient


.. index:: React Developer Tools
.. _react developer tools:

React Developer Tools
++++++++++++++++++++++
| ChromeExt: https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi


.. index:: Requirify
.. _requirify:

Requirify
+++++++++++
| Homepage: https://wzrd.in/
| Source: https://github.com/mathisonian/requirify
| ChromeExt: https://chrome.google.com/webstore/detail/requirify/gajpkncnknlljkhblhllcnnfjpbcmebm
| NPM: https://www.npmjs.com/package/requirify
| Docs: https://github.com/jfhbrook/browserify-cdn

Requirify adds `NPM`_ modules to the local namespace (e.g. from `Chrome DevTools`_
JS console).

> require() npm modules in the browser console

.. code::javascript

    require('jquery');
    require('d3');


.. index:: local-requirify
.. _local-requirify:

----------------
Local-requirify
----------------
| NPM: https://www.npmjs.com/package/local-requirify

Require local `NPM`_ modules with `Requirify`_


.. index:: Web Developer Extension
.. _web developer extension:

Web Developer
++++++++++++++
| ChromeExt: https://chrome.google.com/webstore/detail/web-developer/bfbameneiokkgbdmiekhjnmfkcnldhhm
| Homepage: http://chrispederick.com/work/web-developer/
| Source: https://github.com/chrispederick/web-developer/
| FirefoxExt: https://addons.mozilla.org/en-us/firefox/addon/web-developer/
| FirefoxXPI: https://addons.mozilla.org/firefox/downloads/latest/60/addon-60-latest.xpi

Web Developer Extension, originally just for Firefox, adds many
useful developer tools and bookmarklets in a structured menu.

.. index:: Vim Extensions
.. _vim-extensions:

Vim Extensions
~~~~~~~~~~~~~~~~

.. index:: Vimium
.. _vimium:

Vimium
+++++++
| Wikipedia: https://en.wikipedia.org/wiki/Vimium
| Homepage: https://vimium.github.io/
| Source: git https://github.com/philc/vimium
| ChromeExt: https://chrome.google.com/webstore/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb?hl=en

Vimium is a Chrome Extension which adds vim-like functionality.


+---------------+---------------------+--+--+
| **function**  | **vimium shortcut** |  |  |
+---------------+---------------------+--+--+
|  help         | ``?``               |  |  |
+---------------+---------------------+--+--+
|  jump to link | ``f``               |  |  |
+---------------+---------------------+--+--+
|  ...          |                     |  |  |
+---------------+---------------------+--+--+

.. index:: Vimperator
.. _vimperator:

Vimperator
+++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Vimperator
| Homepage: http://www.vimperator.org/
| Source: https://github.com/vimperator/vimperator-labs
| FirefoxExt: https://addons.mozilla.org/en-US/firefox/addon/vimperator/

Vimperator connects a JS shell with VIM command interpretation
to the Firefox API, with vim-like functionality.

* ``vimperatorrc`` can configure settings in ``about:config``

.. index:: Wasavi
.. _wasavi:

Wasavi
+++++++
| Homepage: http://appsweets.net/wasavi/
| Source: https://github.com/akahuku/wasavi
| ChromeExt: https://chrome.google.com/webstore/detail/wasavi/dgogifpkoilgiofhhhodbodcfgomelhe
| OperaExt: https://addons.opera.com/en/extensions/details/wasavi/
| FirefoxExt: https://addons.mozilla.org/en-US/firefox/addon/wasavi/
| Docs: http://appsweets.net/wasavi/

Wasavi converts the focused ``textarea`` to an in-page editor with
vim-like functionality.

.. index:: Documentation
.. _documentation-tools:

Documentation Tools
=====================


.. index:: Docutils
.. _docutils:

Docutils
~~~~~~~~~~~~~~~~~~~
| Homepage: http://docutils.sourceforge.net
| PyPI: https://pypi.python.org/pypi/docutils
| Docs: http://docutils.sourceforge.net/docs/
| Docs: http://docutils.sourceforge.net/rst.html
| Docs: http://docutils.sourceforge.net/docs/ref/doctree.html
| Source: svn http://svn.code.sf.net/p/docutils/code/trunk

Docutils is a :ref:`Python` library which 'parses" :ref:`ReStructuredText`
lightweight markup language into a doctree (~DOM)
which can be serialized into
HTML, ePub, MOBI, LaTeX, man pages,
Open Document files,
XML, JSON, and a number of other formats.


.. index:: Pandoc
.. _pandoc:

Pandoc
~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Pandoc
| Homepage: http://pandoc.org/
| Docs: http://pandoc.org/README.html
| Docs: http://pandoc.org/releases.html
| Download: https://github.com/jgm/pandoc/releases
| BrewPkg: pandoc
| AptPkg: pandoc
| YumPkg: pandoc

Pandoc is a "universal" markup converter written in :ref:`Haskell`
which can convert between HTML,
:ref:`BBCode`,
:ref:`Markdown`,
:ref:`MediaWiki Markup <mediawiki markup>`,
:ref:`ReStructuredText`,
HTML, and a number of other formats.

.. index:: Sphinx
.. _sphinx:

Sphinx
~~~~~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Sphinx_(documentation_generator)>`_
| Homepage: https://pypi.python.org/pypi/Sphinx
| Docs: http://sphinx-doc.org/contents.html
| Docs: http://sphinx-doc.org/markup/code.html
| Docs: http://pygments.org/docs/lexers/
| Docs: http://thomas-cokelaer.info/tutorials/sphinx/rest_syntax.html
| Source: hg https://bitbucket.org/birkenfeld/sphinx/
| Pypi: https://pypi.python.org/pypi/Sphinx


Sphinx is a tool for working with
:ref:`ReStructuredText` documentation trees
and rendering them into HTML, PDF, LaTeX, ePub,
and a number of other formats.

Sphinx extends :ref:`Docutils` with a number of useful markup behaviors
which are not supported by other ReStructuredText parsers.

Most other ReStructuredText parsers do not support Sphinx directives;
so, for example,

* GitHub and BitBucket do not support Sphinx but do support ReStructuredText
  so ``README.rst`` containing Sphinx tags renders in plaintext or raises errors.

  For example, the index page of this
  :ref:`Sphinx` documentation set is generated from
  a file named ``index.rst`` that referenced by ``docs/conf.py``,
  which is utilized by ``sphinx-build`` in the ``Makefile``.

  * Input: https://raw.githubusercontent.com/westurner/tools/master/index.rst
  * Output: https://github.com/westurner/tools/blob/master/index.rst
  * Output: *ReadTheDocs*: https://westurner.org/tools/

.. glossary::

   Sphinx Builder
      A Sphinx Builder transforms :ref:`ReStructuredText` into various
      output forms:

         * HTML
         * LaTeX
         * PDF
         * ePub
         * MOBI
         * JSON
         * OpenDocument (OpenOffice)
         * Office Open XML (MS Word)

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


.. index:: Standards
.. _standards:

Standards
============

References:

* https://wrdrd.com/docs/consulting/knowledge-engineering#web-standards
* https://wrdrd.com/docs/consulting/knowledge-engineering#semantic-web-standards


.. index:: Filesystem Hierarchy Standard
.. _fhs:

Filesystem Hierarchy Standard
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
| Website: http://www.linuxfoundation.org/collaborate/workgroups/lsb/fhs


The Filesystem Hierarchy Standard is a well-worn industry-supported
system file naming structure.

:ref:`Ubuntu` and :ref:`Virtualenv` implement
a Filesystem Hierarchy.

:ref:`Docker` layers filesystem hierarchies with aufs and now
also btrfs subvolumes.


.. index:: JSON
.. _json:

JSON
~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/JSON
| Homepage: http://json.org/
| Docs: http://learnxinyminutes.com/docs/json/


JSON is an object representation in :ref:`Javascript` syntax
which is now supported by libraries for many language.

A list of objects with ``key`` and ``value`` attributes in JSON syntax:

.. code-block:: javascript

    [
    { "key": "language", "value": "Javascript" },
    { "key": "version", "value": 1 },
    { "key": "example", "value": true },
    ]

Machine-generated JSON is often not very readable, because it doesn't
contain extra spaces or newlines.
The :ref:`Python` JSON library contains a utility
for parsing and indenting ("prettifying") JSON from the commandline ::

    cat example.json | python -m json.tool


.. index:: JSONLD
.. index:: JSON-LD
.. _json-ld:

JSON-LD
~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/JSON-LD
| Homepage: http://json-ld.org
| Docs: http://json-ld.org/playground/

JSON-LD is a web standard for Linked Data in :ref:`JSON`.

An example from the JSON-LD Playground (`<http://goo.gl/xxZ410>`__):

.. code-block:: javascript

   {
      "@context": {
       "gr": "http://purl.org/goodrelations/v1#",
       "pto": "http://www.productontology.org/id/",
       "foaf": "http://xmlns.com/foaf/0.1/",
       "xsd": "http://www.w3.org/2001/XMLSchema#",
       "foaf:page": {
         "@type": "@id"
       },
       "gr:acceptedPaymentMethods": {
         "@type": "@id"
       },
       "gr:hasBusinessFunction": {
         "@type": "@id"
       },
       "gr:hasCurrencyValue": {
         "@type": "xsd:float"
       }
      },
      "@id": "http://example.org/cars/for-sale#tesla",
      "@type": "gr:Offering",
      "gr:name": "Used Tesla Roadster",
      "gr:description": "Need to sell fast and furiously",
      "gr:hasBusinessFunction": "gr:Sell",
      "gr:acceptedPaymentMethods": "gr:Cash",
      "gr:hasPriceSpecification": {
       "gr:hasCurrencyValue": "85000",
       "gr:hasCurrency": "USD"
      },
      "gr:includes": {
       "@type": [
         "gr:Individual",
         "pto:Vehicle"
       ],
       "gr:name": "Tesla Roadster",
       "foaf:page": "http://www.teslamotors.com/roadster"
      }
   }


.. index:: MessagePack
.. _msgpack:

MessagePack
~~~~~~~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/MessagePack
| Homepage: http://msgpack.org/


MessagePack is a data interchange format
with implementations in many languages.

:ref:`Salt`


.. index:: Vim
.. _vim:

Vim
====
| Wikipedia: `<https://en.wikipedia.org/wiki/Vim_(text_editor)>`__
| Homepage: http://www.vim.org/
| Docs: http://www.vim.org/docs.php
| Source: hg https://vim.googlecode.com/hg/


* https://github.com/scrooloose/nerdtree
* https://github.com/westurner/dotvim


.. index:: Vimium
.. _vimium:

Vimium
~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Vimium
| Homepage: https://vimium.github.io/
| Source: git https://github.com/philc/vimium
| ChromeExt: https://chrome.google.com/webstore/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb?hl=en


.. index:: Vimperator
.. _vimperator:

Vimperator
~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Vimperator
| Homepage: http://www.vimperator.org/
| Source: https://github.com/vimperator/vimperator-labs
| FirefoxExt: https://addons.mozilla.org/en-US/firefox/addon/vimperator/


.. index:: Wasavi
.. _wasavi:

Wasavi
~~~~~~~
| Homepage: http://appsweets.net/wasavi/
| Docs: http://appsweets.net/wasavi/
| Source: https://github.com/akahuku/wasavi


* https://chrome.google.com/webstore/detail/wasavi/dgogifpkoilgiofhhhodbodcfgomelhe
* https://addons.opera.com/en/extensions/details/wasavi/
* https://addons.mozilla.org/en-US/firefox/addon/wasavi/



*****

`^top^ <#>`__
