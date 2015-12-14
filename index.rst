

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

Anaconda is a maintained distribution of :ref:`Conda`
packages for many languages; especially :ref:`Python`.

* :ref:`Anaconda` maintains a working set of :ref:`Conda` packages
  for Python 2.6, 2.7, 3.3, and 3.4:
  http://docs.continuum.io/anaconda/pkg-docs.html


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
| Src: git git://anonscm.debian.org/git/apt/apt.git
| IRC: `<irc://irc.debian.org/debian-apt>`__


APT ("Advanced Packaging Tool") is the core of :ref:`Debian`
package management.

* An APT package repository serves :ref:`DEB` packages created with :ref:`Dpkg`.

* An APT package repository can be accessed from a local filesystem
  or over a network protocol ("apt transports") like HTTP, HTTPS, RSYNC, FTP,
  and BitTorrent (`debtorrent`).

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


.. index:: AUR
.. _aur:

AUR
~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Arch_Linux#Arch_User_Repository_.28AUR.29

AUR (:ref:`Arch` *User Repository*) contains :ref:`PKGBUILD`
packages which can be installed by :ref:`pacman`.


.. index:: Bower
.. _bower:

Bower
~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Bower_(software)>`__
| Homepage: https://www.bower.io/
| Src: https://github.com/bower/bower


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


.. index:: Conda Package
.. index:: Conda
.. _conda:

Conda
~~~~~~~
| Docs: http://conda.pydata.org/docs/
| Src: git https://github.com/conda/conda
| PyPI: https://pypi.python.org/pypi/conda

Conda is a package build, environment, and distribution system
written in :ref:`Python`
to install packages written in any language.

* Conda was originally created for the Anaconda Python Distribution,
  which installs packages written in :ref:`Python`,
  R,
  :ref:`Javascript`,
  :ref:`Ruby`,
  :ref:`C`,
  :ref:`Fortran`
* Conda packages are basically tar archives with build, and optional
  link/install and uninstall scripts.
* ``conda-build`` generates conda packages from conda recipes
  with a ``meta.yaml``, a ``build.sh``, and/or a ``build.bat``.
* Conda recipes reference and build from
  a source package URI
  *OR* a :ref:`vcs` URI and revision; and/or custom ``build.sh`` or
  ``build.bat`` scripts.
* ``conda skeleton`` can automatically create conda recipes
  from ``PyPI`` (Python), ``CRAN`` (R), and from ``CPAN`` (Perl)
* ``conda skeleton``-generated recipes can be updated
  with additional metadata, scripts, and source URIs
  (as separate patches or consecutive branch commits
  of e.g. a conda-recipes repository
  in order to get a diff of the skeleton recipe and the current recipe).
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
   conda create -n science --yes python readline conda-env

   # Python 3.X
   conda create -n science3 --yes python=3 readline conda-env

Work on a conda env:

.. code:: bash

   source activate exmpl2
   conda list
   source deactivate


``conda-env`` writes to and creates environments from ``environment.yml``
files which list conda and :ref:`pip` packages.

Work with conda envs and ``environment.yml`` files:

.. code:: bash

    # Install conda-env globally (in the "root" conda environment)
    conda install -n root conda-env

    # Create a conda environment with ``conda-create`` and install conda-env
    conda create -n science python=3 readline conda-env pip

    # Install some things with conda (and envs/science/bin/pip)
    # https://github.com/westurner/notebooks/blob/gh-pages/install.sh
    conda search pandas; conda info pandas
    conda install blaze dask bokeh odo \
                  sqlalchemy hdf5 h5py \
                  scikit-learn statsmodels \
                  beautiful-soup lxml html5lib pandas qgrid \
                  ipython-notebook
    pip install -e git+https://github.com/rdflib/rdflib@master#egg=rdflib
    pip install arrow sarge structlog

    # Export an environment.yml
    #source deactivate
    conda env export -n science | tee environment.yml

    # Create an environment from an environment.yml
    conda env create -n projectname -f ./environment.yml

To install a conda package from a custom channel:

- http://www.pydanny.com/building-conda-packages-for-multiple-operating-systems.html
- https://github.com/conda/conda-recipes/tree/master/cookiecutter
- https://binstar.org/pydanny/cookiecutter

.. code:: bash

    conda install -c pydanny cookiecutter   # OR pip install cookiecutter

Sources:

* https://github.com/conda
* https://github.com/conda/conda -- conda
* https://github.com/ContinuumIO/pycosat -- pycosat SAT solver
* https://github.com/conda/conda-env -- conda-env
  (the ``conda env`` command)
* https://github.com/conda/conda-build -- conda-build
  (the ``conda build`` command)
* https://github.com/conda/conda-recipes -- Community-maintained
  conda recipes (which users may build and
  :ref:`maintain <packages>` in https://binstar.org
  package repositories)

See also: :ref:`Anaconda`


.. index:: DEB
.. _deb:

DEB
~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Deb_(file_format)>`__


DEB is the :ref:`Debian` software package format.

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


.. index:: dnf
.. _dnf:

dnf
~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/DNF_(software)>`__
| Homepage: http://dnf.baseurl.org/
| Homepage: https://fedoraproject.org/wiki/Features/DNF
| Src: git https://github.com/rpm-software-management/dnf
| Docs: https://dnf.readthedocs.org/en/latest/
| Docs: https://github.com/rpm-software-management/dnf/wiki
| Docs: https://rpm-software-management.github.io/dnf-plugins-core/

dnf is a an open source package manager written in :ref:`Python`.

* dnf was introduced in :ref:`Fedora` 18.
* dnf is the default package manager in :ref:`Fedora` 22;
  replacing :ref:`yum`.

  * [ ] ``yum`` errors if TODO package is installed (* :ref:`salt`
    provider)
  * [ ] ``repoquery`` redirects with an error to ``dnf repoquery``
  * See ``dnf help`` (and ``man dnf``)

* dnf integrates with the Anaconda system installer.


.. index:: ebuild
.. _ebuild:

ebuild
~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Ebuild
| Homepage: https://wiki.gentoo.org/wiki/Ebuild
| Docs: https://devmanual.gentoo.org/quickstart/
| Docs: https://devmanual.gentoo.org/ebuild-writing/
| Docs: https://devmanual.gentoo.org/ebuild-writing/file-format/
| Docs: https://devmanual.gentoo.org/ebuild-writing/variables/
| Docs: https://devmanual.gentoo.org/ebuild-writing/use-conditional-code/
| Docs: https://wiki.gentoo.org/wiki/Submitting_ebuilds

ebuild is a software package definition format.

* ebuilds are like special :ref:`bash` scripts.
* ebuilds have ``USE`` flags for specifying build features.
* :ref:`Gentoo` is built from ebuild package definitions
  stored in the Gentoo Portage.
* :ref:`Portage` packages are built from ebuilds.
* The :ref:`emerge` :ref:`Portage` command installs ebuilds.


.. index:: emerge
.. _emerge:

emerge
~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Portage_(software)#Emerge>`__
| Homepage: https://wiki.gentoo.org/wiki/Portage#emerge
| Source: git https://github.com/gentoo/portage
| Docs: https://wiki.gentoo.org/wiki/Project:Package_Manager_Specification
| Docs: https://projects.gentoo.org/pms/6/pms.html

``emerge`` is the primary CLI tool used for installing
packages built from :ref:`ebuild <ebuilds>` [from :ref:`Portage`].


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
| Src: https://github.com/npm/npm


NPM is a :ref:`Javascript` package manager created for :ref:`Node.js`.

:ref:`Bower` builds on NPM.


.. index:: NuGet
.. _nuget:

NuGet
~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/NuGet
| Homepage: https://www.nuget.org/

NuGet is an open source package manager for :ref:`Windows`.

* Chocolatey maintains variously updated packages
  for various windows programs:
  https://chocolatey.org/

  + An example list of Chocolatey NuGet packages as a :ref:`PowerShell` script:
    https://gist.github.com/westurner/10950476



.. index:: pacman
.. _pacman:

pacman
~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Arch_Linux#Pacman
| Homepage: https://www.archlinux.org/pacman/
| Docs: https://wiki.archlinux.org/index.php/Pacman

Pacman is an open source package manager which installs
``.pkg.tar.xz`` files for :ref:`Arch` Linux.


.. index:: Pants
.. index:: Pants Build
.. _pants build:
.. _pants:

Pants Build
~~~~~~~~~~~
| Homepage: https://pantsbuild.github.io/
| Source: git https://github.com/pantsbuild/pants 
| Docs: https://pantsbuild.github.io/first_concepts.html
| Docs: https://pantsbuild.github.io/install.html
| Docs: https://pantsbuild.github.io/first_tutorial.html
| Docs: https://pantsbuild.github.io/JVMProjects.html
| Docs: https://pantsbuild.github.io/scala.html
| Docs: https://pantsbuild.github.io/python-readme.html
| Docs: https://pantsbuild.github.io/pex_design.html
| Docs: https://pantsbuild.github.io/build_files.html
| Docs: https://pantsbuild.github.io/build_dictionary.html
| Docs: https://pantsbuild.github.io/options_reference.html
| Docs: https://pantsbuild.github.io/export.html
| Docs: https://pantsbuild.github.io/internals.html
| Docs: https://pantsbuild.github.io/howto_contribute.html

Pants Build is a build tool for :ref:`JVM` [:ref:`Java`, :ref:`Scala`,
:ref:`Android`], :ref:`C++`, :ref:`Go`, :ref:`Haskell`, and :ref:`Python`
[:ref:`CPython`] software projects.

* A Pants ``BUILD`` file defines one or more build targets:

  + Pants can build *Deployable Bundles*, *Runnable Binaries*,
    *Importable Code*, *Tests*, and *Generated Code* (e.g.
    Java from :ref:`Thrift` ``.thrift`` definitions).
  + Pants can build :ref:`PEX` files (*Python EXecutables*);
    which are essentially executable ZIP files
    with inlined dependency sets.
  + Pants can build :ref:`DEX` files (:ref:`Android` *Dalvik Executables*)
  + https://pantsbuild.github.io/build_files.html
  + https://pantsbuild.github.io/build_dictionary.html
  + https://pantsbuild.github.io/options_reference.html

* A Pants ``pants.ini`` file in a top-level source directory
  defines options for binaries, tools, goals, tasks (sub-goals)

  + https://pantsbuild.github.io/setup_repo.html#configuring-with-pantsini
  + https://pantsbuild.github.io/options_reference.html

* :ref:`Vim` plugin for Pants Build ``BUILD`` syntax:
  https://github.com/pantsbuild/vim-pants
* :ref:`IntelliJ` plugin for Pants Build:
  https://github.com/pantsbuild/intellij-pants-plugin


.. index:: PEX
.. _pex:

PEX
~~~~~
| Homepage: https://pex.readthedocs.org/
| Source: https://github.com/pantsbuild/pex
| PyPI: https://pypi.python.org/pypi/pex
| Docs: https://pex.readthedocs.org/en/stable/

PEX (*Python Executable*) is a :ref:`ZIP`-based software package archive
format with an executable header.

* :ref:`Pants` creates PEX packages.


.. index:: PKGBUILD
.. _pkgbuild:

PKGBUILD
~~~~~~~~~~
| Homepage: https://wiki.archlinux.org/index.php/PKGBUILD
| Docs: https://www.archlinux.org/pacman/PKGBUILD.5.html
| Docs: https://wiki.archlinux.org/index.php/Makepkg
| Docs: https://wiki.archlinux.org/index.php/Creating_packages

PKGBUILD is a shell script containing the build information
for an :ref:`AUR` :ref:`Arch` :ref:`linux` software package.


.. index:: Portage
.. _portage:

Portage
~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Portage_(software)>`__
| Homepage: http://wiki.gentoo.org/wiki/Project:Portage
| Docs: https://wiki.gentoo.org/wiki/Project:Package_Manager_Specification
| Docs: https://projects.gentoo.org/pms/6/pms.html

Portage is a package management and repository system
written in :ref:`Python` initially just for :ref:`Gentoo` :ref:`Linux`.

* :ref:`Emerge` installs :ref:`ebuilds` from :ref:`portage`.


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

* RPM Package Repositories (:ref:`yum`, :ref:`dnf`):

  * Local: directories of packages and metadata
  * Network: HTTP, HTTPS, :ref:`RSYNC`, FTP


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

A :ref:`Python` Package is a collection of source code and package data files.

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

Distutils
+++++++++
| Docs: https://docs.python.org/2/distutils/
| Docs: https://docs.python.org/3/distutils/

Distutils is a collection of tools for common packaging needs.

* Distutils is included in the :ref:`Python` standard library.


.. index:: setuptools
.. _setuptools:

Setuptools
++++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Setuptools
| Docs: https://pythonhosted.org/setuptools/
| Src: hg https://bitbucket.org/pypa/setuptools
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
| Src: git https://github.com/pypa/pip
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
| Src: https://github.com/erikrose/peep
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
| Src: https://bitbucket.org/pypa/pypi


PyPI is the Python Package Index.


.. index:: Warehouse
.. _warehouse:

Warehouse
++++++++++
| Homepage: https://warehouse.python.org/
| Docs: https://warehouse.readthedocs.org/en/latest/
| Src: https://github.com/pypa/warehouse


Warehouse is the "Next Generation Python Package Repository".

All packages uploaded to :ref:`PyPI` are also available from Warehouse.


.. index:: Python Wheel
.. index:: Wheel
.. _wheel:

Wheel
++++++
| Docs: http://legacy.python.org/dev/peps/pep-0427/
| Docs: http://wheel.readthedocs.org/en/latest/
| Src: hg https://bitbucket.org/pypa/wheel/
| PyPI: https://pypi.python.org/pypi/wheel


* Wheel is a newer, PEP-based standard (``.whl``) with a different
  metadata format, the ability to specify (JSON) digital signatures
  for a package within the package, and a number
  of additional speed and platform-consistency advantages.
* Wheels can be uploaded to PyPI.
* Wheels are generally faster than traditional Python packages.

Packages available as wheels are listed at `<http://pythonwheels.com/>`__.


.. index:: Ruby Gem
.. index:: RubyGems
.. _rubygems:

RubyGems
~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/RubyGems
| Homepage: https://rubygems.org/
| Docs: http://guides.rubygems.org/
| Src: https://github.com/rubygems/rubygems

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
| Src: svn http://svn.apache.org/repos/asf/subversion/trunk

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
| Src: bzr lp:bzr

GNU Bazaar (``bzr``) is a distributed revision control system (DVCS, RCS, VCS)
written in :ref:`Python` and :ref:`C`.

http://launchpad.net hosts Bazaar repositories;
with special support from the ``bzr`` tool in the form of ``lp:`` URIs
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
| Src: git https://github.com/git/git


Git (``git``) is a distributed version control system for tracking a branching
and merging repository of file revisions written in :ref:`C` (DVCS, VCS,
RCS).

To clone a repository with ``git``:

.. code:: bash

  git clone https://github.com/git/git


.. index:: GitFlow
.. _gitflow:

GitFlow
~~~~~~~~~
| Src: https://github.com/nvie/gitflow
| Docs: http://nvie.com/posts/a-successful-git-branching-model/
| Docs: https://github.com/nvie/gitflow/wiki
| Docs: https://github.com/nvie/gitflow/wiki/Command-Line-Arguments
| Docs: https://github.com/nvie/gitflow/wiki/Config-values

GitFlow is a named branch workflow for :ref:`git`
with ``master``, ``develop``, ``feature``, ``release``, ``hotfix``,
and ``support`` branches (``git flow``).

Gitflow branch names and prefixes are configured in ``.git/config``;
the defaults are:


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
| ``release/<name>`` | In-progress release branches (e.g. ``RLS``)                             |
+--------------------+-------------------------------------------------------------------------+
| ``hotfix/<name>``  | Fixes to merge to both ``master`` and ``develop``                       |
|                    | (e.g. ``BUG``, ``TST``, ``DOC``)                                        |
+--------------------+-------------------------------------------------------------------------+
| ``support/<name>`` | "What is the 'support' branch?"                                         |
|                    |                                                                         |
|                    | https://github.com/nvie/gitflow/wiki/FAQ                                |
+--------------------+-------------------------------------------------------------------------+

Creating a new release with :ref:`Git` and :ref:`GitFlow`:

.. code:: bash

  git clone ssh://git@github.com/westurner/dotfiles
  # git checkout master
  # git checkout -h
  # git help checkout (man git-checkout)
  # git flow [<cmd> -h]
  # git-flow [<cmd> -h]

  git flow init
  ## Update versiontag in .git/config to prefix release tags with 'v'
  git config --replace-all gitflow.prefix.versiontag v
  cat ./.git/config
  # [gitflow "prefix"]
  # feature = feature/
  # release = release/
  # hotfix = hotfix/
  # support = support/
  # versiontag = v
  #

  ## feature/ENH_print_hello_world
  git flow feature start ENH_print_hello_world
  #git commit, commit, commit
  git flow feature
  git flow feature finish ENH_print_hello_world   # ENH<TAB>

  ## release/v0.1.0
  git flow release start 0.1.0
  #git commit (e.g. update __version__, setup.py, release notes)
  git flow release finish 0.1.0
  git flow release finish 0.1.0
  git tag | grep 'v0.1.0'



.. index:: HubFlow
.. _hubflow:

HubFlow
~~~~~~~~~
| Src: https://github.com/datasift/gitflow
| Docs: https://datasift.github.io/gitflow/
| Docs: https://datasift.github.io/gitflow/IntroducingGitFlow.html
| Docs: https://datasift.github.io/gitflow/TheHubFlowTools.html
| Docs: https://datasift.github.io/gitflow/GitFlowForGitHub.html

HubFlow is a fork of :ref:`GitFlow`
that adds extremely useful commands for working with :ref:`Git` and
GitHub **pull requests**.

HubFlow branch names and prefixes are configured in ``.git/config``;
the defaults are as follows:


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
| ``release/<name>`` | In-progress release branches (e.g. ``RLS``)                             |
+--------------------+-------------------------------------------------------------------------+
| ``hotfix/<name>``  | Fixes to merge to both ``master`` and ``develop``                       |
|                    | (e.g. ``BUG``, ``TST``, ``DOC``)                                        |
+--------------------+-------------------------------------------------------------------------+

Creating a new release with :ref:`Git` and :ref:`HubFlow`:

.. code:: bash

  git clone ssh://git@github.com/westurner/dotfiles
  # git checkout master
  # git checkout -h
  # git help checkout (man git-checkout)
  # git hf [<cmd> -h]
  # git-hf [<cmd> -h]

  git hf init
  ## Update versiontag in .git/config to prefix release tags with 'v'
  git config --replace-all hubflow.prefix.versiontag v
  #cat .git/config # ...
  # [hubflow "prefix"]
  # feature = feature/
  # release = release/
  # hotfix = hotfix/
  # support = support/
  # versiontag = v
  #
  git hf update
  git hf pull
  git hf pull -h

  ## feature/ENH_print_hello_world
  git hf feature start ENH_print_hello_world
  #git commit, commit
  git hf pull
  git hf push
  #git commit, commit
  git hf feature finish ENH_print_hello_world   # ENH<TAB>

  ## release/v0.1.0
  git hf release start 0.1.0
  ## commit (e.g. update __version__, setup.py, release notes)
  git hf release finish 0.1.0
  git hf release finish 0.1.0
  git tag | grep 'v0.1.0'

The GitFlow HubFlow illustrations are very helpful for visualizing
and understanding any DVCS workflow:
`<https://datasift.github.io/gitflow/IntroducingGitFlow.html>`__.


.. figure:: https://datasift.github.io/gitflow/GitFlowMasterBranch.png
   :alt: GitFlow Release / Master Branch Merge Diagram
   :target:  https://datasift.github.io/gitflow/IntroducingGitFlow.html

.. figure:: https://datasift.github.io/gitflow/GitFlowHotfixBranch.png
   :alt: GitFlow Hotfix to Master and Develop Branches Merge Diagram
   :target:  https://datasift.github.io/gitflow/IntroducingGitFlow.html

.. figure::  https://datasift.github.io/gitflow/GitFlowWorkflowNoFork.png
   :alt: Numbered GitFlow Workflow Diagram
   :target:  https://datasift.github.io/gitflow/GitFlowForGitHub.html

.. index:: Hg
.. index:: Mercurial
.. _mercurial:

Mercurial
~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Mercurial
| Homepage: http://hg.selenic.org/
| Docs: http://mercurial.selenic.com/guide
| Docs: http://hgbook.red-bean.com/
| Src: hg http://selenic.com/hg
| Src: hg http://hg.intevation.org/mercurial/crew

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
| Docs: https://en.wikipedia.org/wiki/Markdown#Implementations
| Docs: http://learnxinyminutes.com/docs/markdown/
| Docs: https://guides.github.com/features/mastering-markdown/
| Docs: https://help.github.com/articles/github-flavored-markdown/
| Docs: https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet
| FileExt: ``.Md``
| FileExt: ``.md``

Markdown is a :ref:`Lightweight markup language`
which can be parsed and transformed to
valid :ref:`HTML-`.

* GitHub and BitBucket support Markdown
  in Issue Descriptions, Wiki Pages, and Comments
* :ref:`Jupyter Notebook` supports Markdown
  in Markdown cells


.. index:: CommonMark
.. _commonmark:

CommonMark
+++++++++++++
| Homepage: http://commonmark.org
| Standard: http://spec.commonmark.org/0.22/
| Source:  https://github.com/jgm/CommonMark

:ref:`CommonMark` is one effort to standardize :ref:`Markdown`.


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
valid :ref:`HTML-`.

* Wikipedia is built on MediaWiki,
  which supports MediaWiki Markup.


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
| Src: https://github.com/rdoc/rdoc
| Docs: http://docs.seattlerb.org/rdoc/
| Docs: https://raw.githubusercontent.com/rdoc/rdoc/master/ExampleRDoc.rdoc

RDoc is a tool and a
:ref:`Lightweight markup language`
for generating :ref:`HTML-` and command-line documentation
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

ReStructuredText (*ReST*, *RST*) is a
:ref:`Lightweight markup language` commonly used for
narrative documentation and inline Python, C, Java, etc. docstrings
which can be parsed, transformed, and published to
valid :ref:`HTML-`, ePub, LaTeX, PDF.

:ref:`Sphinx` is built on :ref:`Docutils`,
the primary implementation of ReStructuredText.

:ref:`Pandoc` also supports a form of ReStructuredText.

.. glossary::

   ReStructuredText Directive
      Actionable blocks of ReStructuredText

      | Docs: http://docutils.sourceforge.net/docs/ref/rst/directives.html

      ``include``, ``contents``, and ``index`` are all
      ReStructuredDirectives:

      .. code-block:: rest

          .. include:: goals.rst

          .. contents:: Table of Contents
           :depth: 3

           .. index:: Example 1
           .. index:: Sphinx +
           .. _example-1:

           Sphinx +1
           ==========
           This refs :ref:`example 1 <example-1>`.

           Similarly, an explicit link to this anchor `<#example-1>`__

           And an explicit link to this section `<#sphinx-1>`__
           (which is otherwise not found in the source text).


           .. index:: Example 2
           .. _example 2:

           Example 2
           ==========

           This links to :ref:`example-1` and :ref:`example 2`.

           (`<#example-1>`__, `<#example-2>`__)

           And this also links to `Example 2`_.

          .. include:: LICENSE

       .. note:: ``index`` is a :ref:`Sphinx` Directive,
           which will print an error to the console when building
           but will otherwise silently dropped
           by non-Sphinx ReStructuredText parsers
           like :ref:`Docutils` (GitHub) and :ref:`Pandoc`.

   ReStructuredText Role
      RestructuredText role extensions

      | Docs: http://docutils.sourceforge.net/docs/ref/rst/roles.html

      ``:ref:`` is a :ref:`Sphinx` RestructuredText Role:

      .. code-block:: rest

          A (between files) link to :ref:`example 2`.



.. index:: C
.. _c:

C
~~
| Wikipedia: `<https://en.wikipedia.org/wiki/C_(programming_language)>`__
| Docs: https://www.securecoding.cert.org/confluence/display/c/SEI+CERT+C+Coding+Standard
| Docs: https://cwe.mitre.org/top25/#CWE-120
| Docs: https://cwe.mitre.org/data/definitions/120.html#Demonstrative_Examples
| Docs: http://learnxinyminutes.com/docs/c/

C is a third-generation programming language which affords relatively
low-level machine access while providing helpful abstractions.

Every :ref:`Windows` kernel is written in C.

The GNU/:ref:`Linux` kernel is written in C
and often compiled by :ref:`GCC` or :ref:`Clang`
for a particular architecture (see: ``man uname``)

The :ref:`OSX` kernel is written in C.

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
* :ref:`BSD Libc <bsd-libc>`
* https://en.wikipedia.org/wiki/UClibc
* :ref:`Bionic`


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
| Src: https://en.wikipedia.org/wiki/GNU_C_Library

Glibc is the GNU :ref:`C` Library (:ref:`libc`).

Many :ref:`Linux` packages
and the :ref:`GNU/Linux <linux>` kernel build from Glibc.


.. index:: BSD Libc
.. _bsd-libc:

---------
BSD Libc
---------
| Wikipedia: https://en.wikipedia.org/wiki/C_standard_library#BSD_libc
| Src: https://svnweb.freebsd.org/base/head/lib/libc/
| Src: http://cvsweb.openbsd.org/cgi-bin/cvsweb/src/lib/libc/
| Src: http://www.opensource.apple.com/source/Libc/

BSD libc are a superset of :ref:`POSIX`.

:ref:`OSX` builds from BSD libc.

:ref:`Android` :ref:`Bionic` is a BSD libc.


.. index:: Bionic
.. _bionic:

-------
Bionic
-------
| Wikipedia:  `<https://en.wikipedia.org/wiki/Bionic_(software)>`__
| Src: git https://github.com/android/platform_bionic
| Docs: https://developer.android.com/tools/sdk/ndk/index.html

Bionic is the :ref:`Android` :ref:`libc`, which is a :ref:`BSD Libc
<bsd-libc>`.


.. index:: C++
.. _c++:

C++
~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/C++>`__
| Docs: http://learnxinyminutes.com/docs/c++/

C++ is a free and open source
third-generation programming language
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

Haskell is a free and open source
strongly statically typed purely functional
programming language.

:ref:`Cabal` is the Haskell package manager.

:ref:`Pandoc` is written in Haskell.


.. index:: Go
.. _go:

Go
~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Go_(programming_language)>`_
| Homepage: http://golang.org/
| Docs: http://golang.org/doc/
| Src: hg https://code.google.com/p/go/

Go is a free and open source
statically-typed :reF:`C`-based third generation language.


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


.. index:: JVM
.. _jvm:

JVM
+++++
| Wikipedia: https://en.wikipedia.org/wiki/Java_virtual_machine

A JVM ("Java Virtual Machine") runs :ref:`Java` code (classes and JARs).

* There are JVMs available for very many platforms
* Both the JRE and the JDK include a compiled JVM:

  + JRE -- Java Runtime Environment (End Users)
  + JDK -- Java Developer Kit (Developers)
* Java SE is an implementation specification
  with things like ``java.lang`` and ``java.io`` and ``java.net``
* There are now multiple Java SE Implementations:

  | Wikipedia: https://en.wikipedia.org/wiki/Java_Platform,_Standard_Edition
  | https://en.wikipedia.org/wiki/Java_(software_platform)#History

  + Oracle Java (was **Sun Java**)

    | Wikipedia: https://en.wikipedia.org/wiki/Java_Development_Kit
    | Download: http://www.oracle.com/technetwork/java/javase/
    | Download: http://www.oracle.com/technetwork/java/javase/downloads/
    | Download: https://www.java.com/en/download/
    | Docs: https://www.java.com/en/download/help/index_installing.xml?os=All+Platforms

  + OpenJDK (open source)

    | Wikipedia: https://en.wikipedia.org/wiki/OpenJDK
    | Homepage: http://openjdk.java.net/
    | Download: http://openjdk.java.net/install/
    | Src: http://hg.openjdk.java.net/
    | Docs: https://wiki.openjdk.java.net/
    | Docs: http://openjdk.java.net/guide/

    + IcedTea (open source)

      | Wikipedia: https://en.wikipedia.org/wiki/IcedTea

* Java EE ("Java Enterprise Edition") extends Java SE
  with a number of APIs for web services (``javax.servlet``,
  ``javax.transaction``)

  https://en.wikipedia.org/wiki/Java_Platform,_Enterprise_Edition


.. index:: Javascript
.. _Javascript:

JavaScript
~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/JavaScript
| Docs: https://en.wikipedia.org/wiki/ECMAScript
| Docs: http://learnxinyminutes.com/docs/javascript/

JavaScript is a free and open source
third-generation programming language
designed to run in an interpreter; now specified as *ECMAScript*.

All major web browsers support Javascript.

Client-side (web) applications can be written in Javascript.

Server-side (web) applications can be written in Javascript,
often with :ref:`Node.js`, :ref:`NPM`, and :ref:`Bower` packages.

.. note:: Java and JavaScript are two distinctly different languages
   and developer ecosystems.


.. index:: Node.js
.. _node.js:

Node.js
+++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Node.js
| Homepage: http://www.nodejs.org
| Src: https://github.com/joyent/node

Node.js is a free and open source
framework for :ref:`Javascript` applications
written in :ref:`C`, :ref:`C++`, and :ref:`Javascript`.



.. index:: Jinja2
.. _jinja2:

Jinja2
~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Jinja_%28template_engine%29>`__
| Homepage: http://jinja.pocoo.org/
| Src: https://github.com/mitsuhiko/jinja2
| Docs: https://jinja2.readthedocs.org/en/latest/
| Docs: http://jinja.pocoo.org/docs/dev/

Jinja2 is a free and open source
templating engine written in :ref:`Python`.

:ref:`Sphinx` and :ref:`Salt` are two projects that utilize Jinja2.

.. index:: Perl
.. _perl:

Perl
~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Perl
| Homepage: http://www.perl.org/
| Project: http://dev.perl.org/perl5/
| Docs: http://www.perl.org/docs.html
| Src: git git://perl5.git.perl.org/perl.git

Perl is a free and open source,
dynamically typed, :ref:`C`-based third-generation
programming language.

Many of the :ref:`Debian` system management tools are or were originally
written in Perl.


.. index:: Python
.. _python:

Python
~~~~~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Python_(programming_language)>`_
| Homepage: https://www.python.org/
| Src: hg https://hg.python.org/cpython
| Docs: https://docs.python.org/2/
| Docs: https://docs.python.org/devguide/
| Docs: https://docs.python.org/devguide/documenting.html
| Docs: https://wiki.python.org/moin/PythonBooks
| Docs: http://www.onlineprogrammingbooks.com/python/
| Docs: https://www.reddit.com/r/learnpython/wiki/index
| Docs: https://www.reddit.com/r/learnpython/wiki/books
| Docs: https://www.quora.com/Python-programming-language-1/What-are-the-best-books-courses-for-learning-Python
| Docs: https://en.wikiversity.org/wiki/Python
| Docs: https://www.class-central.com/search?q=python
| Docs: http://learnxinyminutes.com/docs/python/

Python is a free and open source
dynamically-typed, :ref:`C`-based third-generation
programming language.

As a multi-paradigm language with support for functional
and object-oriented code,
Python is often utilized for system administration
and scientific software development.

* Many of the :ref:`RedHat` system management tools
  (e.g. the :ref:`Yum` and :ref:`dnf` package managers)
  are written in Python.

* Gentoo :ref:`Portage` package manager is written in Python.

* :ref:`Conda` package manager is written in Python.

* :ref:`IPython`, :ref:`Pip`, :ref:`Conda`,
  :ref:`Sphinx`, :ref:`Docutils`,
  :ref:`Mercurial`, :ref:`OpenStack`,
  :ref:`Libcloud`, :ref:`Salt`, :ref:`Tox`, :ref:`Virtualenv`,
  and :ref:`Virtualenvwrapper` are all written in Python.

* :ref:`PyPI` is the Python community index
  for sharing open source
  :ref:`python packages`. :ref:`Pip` installs from PyPI.

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
| Src: hg https://hg.python.org/cpython

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
| Homepage: http://cython.org/
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

SciPy Stack Docker Containers

| DockerHub: https://registry.hub.docker.com/u/ipython/ipython/
| DockerHub: https://registry.hub.docker.com/u/ipython/scipystack/
| DockerHub: https://registry.hub.docker.com/u/ipython/scipyserver/


.. index:: PyPy
.. _pypy:

PyPy
+++++
| Wikipedia: https://en.wikipedia.org/wiki/PyPy
| Homepage: http://pypy.org/
| Src: https://bitbucket.org/pypy/pypy
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


See also: :ref:`Anaconda`


.. index:: awesome-python-testing
.. _awesome-python-testing:

awesome-python-testing
++++++++++++++++++++++++
| Homepage: https://westurner.org/wiki/awesome-python-testing.html
| Src: https://github.com/westurner/wiki/blob/master/awesome-python-testing.rest


.. index:: Tox
.. _tox:

Tox
++++++++++++++
| Homepage: https://testrun.org/tox/
| Docs: https://tox.readthedocs.org/en/latest/
| Src: hg https://bitbucket.org/hpk42/tox
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
| Src: svn http://svn.ruby-lang.org/repos/ruby/trunk
| Docs: https://www.ruby-lang.org/en/documentation/
| Docs: http://learnxinyminutes.com/docs/ruby/

Ruby is a free and open source
dynamically-typed programming language.

:ref:`Vagrant` is written in Ruby.


.. index:: Rust
.. _rust:

Rust
~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Rust_(programming_language)>`__
| Homepage: http://www.rust-lang.org/
| Docs: https://doc.rust-lang.org/stable/
| Docs: https://doc.rust-lang.org/nightly/
| Docs: http://learnxinyminutes.com/docs/rust/
| Docs: https://doc.rust-lang.org/book/

Rust is a free and open source
strongly typed
multi-paradigm programming language.

* It's possible to "drop-in replace" :ref:`C` and :ref:`C++` modules
  with rust code
* Rust can call into :ref:`C` code
* Rust is similar to but much safer than :ref:`C` and :ref:`C++`
  ("memory safety")
* In terms of :ref:`C` compatibility and smart pointers/references
  ("memory safety"); :ref:`Go` and :ref:`Rust` have similar objectives.

  https://doc.rust-lang.org/book/ownership.html

  * https://en.wikipedia.org/wiki/Resource_Acquisition_Is_Initialization
  * https://en.wikipedia.org/wiki/Smart_pointer
  * https://doc.rust-lang.org/book/the-stack-and-the-heap.html

  * https://rust-lang.github.io/rlibc/rlibc/fn.memcpy.html

    .. code::

        pub unsafe extern fn memcpy(dest: *mut u8, src: *const u8, n: usize) -> *mut u8


.. index:: Scala
.. _scala:

Scala
~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Scala_(programming_language)>`__
| Homepage: http://scala-lang.org/
| Src: git https://github.com/scala/scala
| Twitter: https://twitter.com/scala_lang
| Docs: http://scala-lang.org/api/current/
| Docs: http://www.scala-lang.org/api/current/#scala.collection.mutable.LinkedHashMap
| Docs: http://learnxinyminutes.com/docs/scala/

Scala is a free and open source
object-oriented and functional
:ref:`programming language` which compiles to
:ref:`JVM` (and :ref:`LLVM`) bytecode.


.. index:: TypeScript
.. _typescript:

TypeScript
~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/TypeScript
| Homepage: http://www.typescriptlang.org/
| Source: git https://github.com/Microsoft/TypeScript
| NPM: https://www.npmjs.com/package/typescript
| NPMPkg: typescript
| Standard: https://github.com/Microsoft/TypeScript/blob/master/doc/spec.md
| FileExt: ``.ts``
| Docs: http://www.typescriptlang.org/Tutorial
| Docs: http://www.typescriptlang.org/Handbook
| Docs: http://learnxinyminutes.com/docs/typescript/

TypeScript is a free and open source :ref:`Programming Language`
developed as a superset of :ref:`Javascript` with optional
additional features like static typing and native object-oriented code.

* Angular 2 is written in :ref:`TypeScript`:
  https://github.com/angular/angular/blob/master/modules/angular2/angular2.ts


.. index:: WebAssembly
.. _webassembly:

WebAssembly
~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/WebAssembly
| Project: https://www.w3.org/community/webassembly/
| Source: https://github.com/WebAssembly
| FileExt: ``.wast``
| FileExt: ``.wasm``
| Docs: https://github.com/WebAssembly/design
| Docs: https://github.com/WebAssembly/design/blob/master/UseCases.md

WebAssembly (*wasm*) is a safe (sandboxed), efficient low-level
:ref:`programming language` (abstract syntax tree)
and binary format for the web.

* WebAssembly is initially derived from asm.js and PNaCL.
* WebAssembly is an industry-wide effort.


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
| Src: git `<ssh://gcc.gnu.org/git/gcc.git>`__


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
| Src: git http://llvm.org/git/llvm.git
| Docs: http://llvm.org/docs/
| Docs: http://llvm.org/docs/GettingStarted.html
| Docs: http://llvm.org/docs/ReleaseNotes.html
| Docs: http://llvm.org/ProjectsWithLLVM/

LLVM "*Low Level Virtual Machine*" is a reusable compiler infrastructure
with frontends for many languages.

* :ref:`Clang`
* :ref:`PyPy`



.. index:: Operating Systems
.. _operating systems:

Operating Systems
===================
| Wikipedia: https://en.wikipedia.org/wiki/Operating_system


.. index:: POSIX
.. _posix:

POSIX
~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/POSIX
| Docs: https://en.wikipedia.org/wiki/POSIX#POSIX-oriented_operating_systems

POSIX ("Portable Operating System Interface") is a set of standards
for :ref:`Shells`, :ref:`Operating Systems`, and APIs.


.. index:: GNU/Linux
.. index:: Linux
.. _linux:

Linux
~~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Linux
| Homepage: https://www.kernel.org/
| Docs: https://www.kernel.org/doc/
| Src: git https://github.com/torvalds/linux

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


.. index:: Arch
.. _arch:

Arch
++++++
| Wikipedia: `<https://en.wikipedia.org/wiki/Arch_Linux>`__
| Homepage: https://www.archlinux.org/
| Download: https://www.archlinux.org/download/
| Docs: https://wiki.archlinux.org/
| Docs: https://aur.archlinux.org/
| Docs: https://aur4.archlinux.org/
| Docs: https://wiki.archlinux.org/index.php/Arch_packaging_standards
| Docs: https://wiki.archlinux.org/index.php/Arch_User_Repository#AUR_4

Arch Linux
is a :ref:`Linux Distribution <linux-distributions>`
that is built from :ref:`AUR` packages.


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
| Src: https://launchpad.net/ubuntu
| Src: http://archive.ubuntu.com/
| Src: http://releases.ubuntu.com/
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
| DockerHub: https://hub.docker.com/_/fedora/
| Docs: https://docs.fedoraproject.org/en-US/index.html
| Docs: https://fedoraproject.org/wiki/Fedora_Project_Wiki
| Docs: https://fedoraproject.org/wiki/EPEL

Fedora
is a :ref:`Linux Distribution <linux-distributions>`
that is built from :ref:`RPM` packages.

.. index:: RedHat
.. index:: RedHat Enterprise Linux
.. index:: RHEL
.. _redhat:

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
which is derived from :ref:`RHEL <redhat>`.


.. index:: Scientific Linux
.. _scientific-linux:

Scientific Linux
-----------------
| Wikipedia: https://en.wikipedia.org/wiki/Scientific_Linux
| Homepage: https://en.wikipedia.org/wiki/Scientific_Linux

Scientific Linux is a :ref:`Linux Distribution <linux-distributions>`
that is built from :ref:`RPM` packages
which is derived from :ref:`CentOS`.
which is derived from :ref:`RHEL <redhat>`.

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
which is derived from :ref:`RHEL <redhat>`.


.. index:: Gentoo
.. _gentoo:

Gentoo
++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Gentoo
| Homepage: https://gentoo.org/
| Src: https://github.com/gentoo
| Src: git https://github.com/gentoo/portage
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
| Src: https://chromium.googlesource.com/ (``chromiumos*/``)

ChromiumOS is a :ref:`Linux Distribution <linux-distributions>`
built on :ref:`Portage`.


.. index:: Crouton
.. _crouton:

------------
Crouton
------------
| Src: https://github.com/dnschneid/crouton

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
| Src: https://github.com/coreos
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


.. index:: SteamOS
.. _steamos:

SteamOS
++++++++
| Wikipedia:
| Homepage: http://store.steampowered.com/steamos
| Download: http://store.steampowered.com/steamos/download
| Docs: http://store.steampowered.com/steamos/oem
| Docs: http://store.steampowered.com/steamos/buildyourown
| DistroWatch: http://distrowatch.com/table.php?distribution=steamos


SteamOS is a :ref:`Linux Distribution <linux-distributions>`
for gaming
based on :ref:`Debian`.

* SteamOS uses :ref:`Apt`, :ref:`Dpkg` and :ref:`DEB` :ref:`Packages`
* Steam Machines run SteamOS
* SteamOS runs Steam: https://en.wikipedia.org/wiki/Steam

  * https://en.wikipedia.org/wiki/Kerbal_Space_Program


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
| Src: https://android.googlesource.com/
| Src: https://github.com/android
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
| Src: https://www.apple.com/opensource/


OS X is a UNIX operating system based upon the Mach kernel from NeXTSTEP,
which was partially derived from NetBSD and FreeBSD.

OS X GUI support is built from XFree86/X.org :ref:`X11`.

OS X maintains forks of many POSIX BSD and GNU tools like ``bash``,
``readlink``, and ``find``.

:ref:`Homebrew` installs and maintains packages for OS X.

.. code-block:: bash

   uname; echo "Darwin"


.. index:: iOS
.. _iOS:

iOS
+++++
| Wikipedia: https://en.wikipedia.org/wiki/IOS
| Homepage: https://www.apple.com/ios/

iOS is a closed source
UNIX operating system based upon many components
of :ref:`OSX`
adapted for phones and then tablets.

* iOS powers iPhones and iPads
* You must have a Mac with :ref:`OSX` and XCode
  to develop and compile for iOS.


OSX Notes
++++++++++

* [ ] Create a fresh install :ref:`OSX` USB drive (16GB+)

  * http://osxdaily.com/2014/10/16/make-os-x-yosemite-boot-install-drive/
  * Docs: https://support.apple.com/en-us/HT201372

* https://github.com/westurner/dotfiles/blob/master/scripts/ ``setup_*.sh``

  * [ ] Manually update to latest versions (of zip, tar.gz, .dmg)
  * [ ] Port / wrap :ref:`shell <shells>` scripts
    to / with :term:`salt formulas`
    and parameters (per-subnet, group, machine, os; :term:`salt pillar`):

    + [ ] https://github.com/westurner/dotfiles/blob/master/scripts/setup_brew.sh  # :ref:`homebrew`
    + [ ] https://github.com/westurner/dotfiles/blob/master/scripts/setup_mavericks_python.sh  # :ref:`python`
    + [ ] https://github.com/westurner/dotfiles/blob/master/scripts/setup_chrome.sh  # :ref:`chrome`
    + [ ] https://github.com/westurner/dotfiles/blob/master/scripts/setup_chromium.sh # :ref:`chrome`
    + [ ] https://github.com/westurner/dotfiles/blob/master/scripts/setup_firefox.sh  # :ref:`firefox`
    + [ ] https://github.com/westurner/dotfiles/blob/master/scripts/setup_adobereader.sh  #  PDF forms, signatures, annotations
    + [ ] https://github.com/westurner/dotfiles/blob/master/scripts/setup_vlc.sh (`vlc`)
    + [ ] https://github.com/westurner/dotfiles/blob/master/scripts/setup_f.lux.sh (`f.lux`, `UBY`)
    + [ ] https://github.com/westurner/dotfiles/blob/master/scripts/setup_powerline_fonts.sh (`UBY`)
    + [ ] https://github.com/westurner/dotfiles/blob/master/scripts/setup_macvim.sh (:ref:`vim`)
    + [ ] https://github.com/westurner/dotfiles/blob/master/scripts/setup_miniconda.sh (:ref:`conda`)

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


.. index:: WSUS Offline Update
.. _wsus offline update:

WSUS Offline Update
++++++++++++++++++++++
| Homepage: http://www.wsusoffline.net/
| Download: http://download.wsusoffline.net/
| Src: svn https://svn.wsusoffline.net/svn/wsusoffline/trunk/
| Docs: http://www.wsusoffline.net/docs/

WSUS Offline Update is a free and open source
software tool for generating
offline :ref:`Windows` upgrade CDs / DVDs
containing the latest upgrades for Windows, Office, and .Net.


* Bandwidth costs: Windows Updates (WSUS) in GB * n_machines
  (see also: *Debtorrent*, :ref:`Packages`)
* "Slipstreaming" an installation ISO is one alternative way to avoid
  having to spend hours
  upgrading a factory reinstalled ("reformatted")
  :ref:`Windows` installation



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
* [ ] Run ``services.msc`` and log/prune unutilized services
  (e.g. workstation, server) and record changes made

  * https://en.wikipedia.org/wiki/Windows_service
  * http://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.win_service.html
  * http://docs.saltstack.com/en/latest/ref/states/providers.html#provider-service

------------------
Windows Dual Boot
------------------
* [ ] Windows MBR chain loads to partition GRUB (`Linux`_)
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
| Src: https://github.com/ansible/ansible

Ansible is a :ref:`Configuration Management` tool
written in :ref:`Python`
which runs idempotent Ansible Playbooks
written in :ref:`YAML`
for managing
one or more physical and virtual machines running various operating systems
over SSH.


.. index:: Cobbler
.. _cobbler:

Cobbler
~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Cobbler_(software)>`__
| Homepage: https://cobbler.github.io/
| Download: https://cobbler.github.io/downloads/2.6.x.html
| Src: git https://github.com/cobbler/cobbler
| Docs: https://cobbler.github.io/manuals/quickstart/
| Docs: https://cobbler.github.io/manuals/2.6.0/

Cobbler is a machine image configuration, repository mirroring,
and networked booting server with support for DNS, DHCP, TFTP, and PXE.

* Cobbler can template kickstart files for the :ref:`RedHat`
  Anaconda installer
* Cobbler can template :ref:`Debian` preseed files
* Cobbler can PXE boot an ISO over TFTP (and unattended install)

  * BusyBox, :ref:`SystemRescueCD`, :ref:`Clonezilla`

* Cobbler can manage a set of DNS and DHCP entries for physical systems
* Cobbler can batch mirror :ref:`RPM` and :ref:`DEB` repositories
  (see also: `apt-cacher-ng`, :ref:`nginx`)
* Cobbler-web is a Django WSGI application; usually configured with
  :ref:`Apache HTTPD` and mod_wsgi.

  * Cobbler-web delegates very many infrastructure privileges

See also: `crowbar`, :ref:`OpenStack` Ironic bare-metal deployment


.. index:: Gradle
.. _gradle:

Gradle
~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Gradle
| Homepage: http://www.gradle.org/
| Src: git https://github.com/gradle/gradle
| Download: http://gradle.org/downloads
| Docs: https://docs.gradle.org/current/release-notes
| Docs: https://docs.gradle.org/current/userguide/userguide.html
| Twitter: https://twitter.com/gradle

Gradle is a build tool for the :ref:`Java` :ref:`JVM`
which builds a directed acyclic graph (DAG).


.. index:: Grunt
.. _grunt:

Grunt
~~~~~~
| Homepage: http://gruntjs.com/
| Src: git https://github.com/gruntjs/grunt
| Docs: http://gruntjs.com/getting-started
| Docs: http://gruntjs.com/plugins
| Twitter: https://twitter.com/gruntjs

Grunt is a build tool written in :ref:`Javascript`
which builds a directed acyclic graph (DAG).


.. index:: Gulp
.. _gulp:

Gulp
~~~~~
| Homepage: http://gulpjs.com/
| Src: https://github.com/gulpjs/gulp
| Docs: https://github.com/gulpjs/gulp/blob/master/docs/
| Docs: https://github.com/gulpjs/gulp/blob/master/docs/getting-started.md
| Docs: http://gulpjs.com/plugins/
| Twitter: https://twitter.com/gulpjs

Gulp is a build tool written in :ref:`Javascript`
which builds a directed acyclic graph (DAG).


.. index:: Jake
.. _jake:

Jake
~~~~~
| Homepage: http://jakejs.com/
| Source: git https://github.com/jakejs/jake
| NPMPkg: jake
| NPM: https://www.npmjs.com/package/jake
| Docs: http://jakejs.com/docs

Jake is a :ref:`Javascript` build tool written in :ref:`Javascript`
(for :ref:`Node.js`) similar to :ref:`Make` or :ref:`Rake`.


.. index:: JuJu
.. _juju:

Juju
~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Juju_(software)>`__
| Homepage: https://jujucharms.com/
| Src:
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
| Src: git git://git.savannah.gnu.org/make.git


GNU Make is a classic, ubiquitous software build tool
designed for file-based source code compilation
which builds a directed acyclic graph (DAG).

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

osquery is a tool for reading and querying
many sources of system data
with SQL
for :ref:`OSX` and :ref:`Linux`.

* https://docs.saltstack.com/en/develop/ref/modules/all/salt.modules.osquery.html
* https://github.com/westurner/dotfiles/blob/develop/scripts/osquery-all.sh


Pants
~~~~~~
See: :ref:`Pants Build`


.. index:: Puppet
.. _puppet:

Puppet
~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Puppet_(software)>`__
| Homepage: https://puppetlabs.com/
| Docs: http://docs.puppetlabs.com/
| Docs: http://docs.puppetlabs.com/puppet/
| Src: git https://github.com/puppetlabs
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
| Src: git https://github.com/saltstack/salt
| Docs: https://docs.saltstack.com/en/latest/
| Docs: https://docs.saltstack.com/en/latest/salt-modindex.html
| Docs: https://docs.saltstack.com/en/latest/ref/states/all/index.html
| Docs: https://docs.saltstack.com/en/latest/ref/clients/index.html#python-api
| Docs: https://docs.saltstack.com/en/latest/topics/development/hacking.html
| Docs: https://docs.saltstack.com/en/latest/glossary.html
| Pypi: https://pypi.python.org/pypi/salt
| Twitter: https://twitter.com/SaltStackInc
| IRC: ``#salt``
| TcpPort: 4505 (salt zmq)
| TcpPort: 4506 (salt zmq)
| TcpPort: 22 (salt-ssh)


Salt is a :ref:`Configuration Management` system
written in :ref:`Python`
which runs Salt Formulas
written in :ref:`YAML`, :ref:`Jinja2`, :ref:`Python`
for managing
one or more physical and virtual machines running various operating systems.

Salt runs modules defined by states over a transport.
Salt transports include:

* :ref:`ZeroMQ` Transport (TCP, msgpack) (libzmq, (default)
* TCP Transport
* RAET: Reliable Asynchronous Event Transport (UDP, msgpack) (libsodium, libnacl)
* :term:`salt-ssh <salt ssh>` runs salt states over SSH

.. glossary::

   Salt Top File
      A Salt *Top File* (``top.sls``) defines the
      Root of a Salt Environment.

      The Top File contains:

      * YAML + Jinja2 (SLS)
      * References to :term:`Salt States` defined in :term:`Salt
        Formulas` (e.g. ``- docker``)
      * Jinja2 logic

        * ``{% if %}``
        * ``{% for x in iterable %}``
        * Conditional on :term:`Salt Grains`

   Salt Environment
      A Salt Environment is a
      folder of :term:`Salt States` with a ``top.sls`` :ref:`Salt Top File`.

      A :term:`Salt Master` and/or a (standalone) :term:`Salt Minion`
      maintain a Salt Environment.

   Salt Bootstrap
      The Salt Bootstrap script (``bootstrap-salt.sh``) is a shell script
      installer for a
      :term:`salt master` and/or :term:`salt minion`.

      Salt Bootstrap can install from source (``git``),
      from (mostly) Python packages served from e.g. :ref:`PyPI`, with
      :ref:`pip`, OS Packages (e.g. :ref:`deb`, :ref:`rpm`).

      * ``bootstrap-salt.sh -h``:
        https://github.com/saltstack/salt-bootstrap/blob/stable/bootstrap-salt.sh

   Salt Minion
      A Salt Minion is a
      daemon process which executes
      the :ref:`Salt Modules <salt module>` defined by
      :ref:`Salt States <salt state>` on the local machine.




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
      Salt states are
      graphs of nodes, edges, and attributes
      which are templated and compiled into
      ordered sequences of system configuration steps.

      * Salt states can be expressed as ``.sls`` :ref:`YAML` files
        (transformed by the ``sls`` :term:`Salt Renderer <salt renderers>`)
        parsed by ``salt.states.<state>.py``.

      Salt States files are processed as :ref:`Jinja2` templates (by default);
      they can access system-specific grains and pillar data at compile time.

   Salt Formulas
      Salt Formulas are reusable packages of salt states
      and example pillar configuration data.

      | Docs: http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html

      * https://github.com/saltstack-formulas
      * https://github.com/saltstack-formulas/salt-formula/blob/master/pillar.example#L136 #"salt_formulas"
      * https://github.com/westurner/cookiecutter-saltformula

   Salt Renderers
      A Salt Renderer is a transformation function
      (e.g. a templating engine (default: :ref:`Jinja2`))
      for transforming / preprocessing :term:`Salt States`,
      :term:`Salt Pillar` files, and really any text document.

      | Docs: http://docs.saltstack.com/en/develop/ref/renderers/

      * http://docs.saltstack.com/en/latest/ref/renderers/all/salt.renderers.jinja.html
      * Jinja + YAML, Mako + YAML, Wempy + YAML, Jinja + json, Mako + json, Wempy + json.

   Salt Pillar
      A Salt Pillar is composed of
      nested key value pillar
      over interface for storing and making available
      global and host-specific values for minions:
      values like hostnames, usernames, and keys.

      * Pillar configuration must be kept separate from states
        (e.g. users, keys) but works the same way.

      * In a master/minion configuration, minions do not have access to
        the whole pillar.

      | Docs: http://docs.saltstack.com/en/develop/ref/pillar/
      | Docs: http://docs.saltstack.com/en/develop/ref/pillar/all/#all-salt-pillars

      * https://github.com/saltstack-formulas/salt-formula/blob/master/pillar.example

   Salt Cloud
      Salt Cloud can provision cloud image, instance, and networking services
      with various cloud providers (:ref:`libcloud`):

      + Google Compute Engine (GCE) [KVM]
      + Amazon EC2 [Xen]
      + Rackspace Cloud [KVM]
      + OpenStack [https://wiki.openstack.org/wiki/HypervisorSupportMatrix]
      + Linux LXC (Cgroups)
      + KVM


* Salt output formats (``salt --out=pprint``, ``salt-call
  --out=pprint``, ``salt-call --help``)::

      grains
      highstate
      json
      key
      nested
      newline_values_only
      no_return
      overstatestage
      pprint
      quiet
      raw
      txt
      virt_query
      yaml

* A few examples of :ref:`salt` commandline usage in a :ref:`Makefile <make>`:
  https://github.com/westurner/provis/blob/master/Makefile
  (``make salt_<TAB>``)


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
| Src: https://github.com/docker/docker

Docker is an OS virtualization project written in :ref:`Go`
which utilizes :ref:`Linux` :ref:`LXC` Containers
to partition process workloads all running under one kernel.

.. glossary::

    Dockerfile
        A ``Dockerfile`` contains the instructions needed to
        create a docker image.

* Docker images build from a ``Dockerfile``
* A ``Dockerfile`` can subclass another Dockerfile (to add, remove, or
  change configuration)
* ``Dockerfile`` support a limited number of commands
* Docker is not intended to be a
  complete :ref:`configuration management system
  <configuration management>`
* Ideally, a Docker images requires minimal configuration once built
* Docker images can be hosted by https://hub.docker.com/
* ``docker run -it ubuntu/15.04`` downloads the image
  from https://registry.hub.docker.com/_/ubuntu/,
  creates a new instance (``docker ps``),
  and spawns a root :ref:`Shell <shells>` with
  a UUID name (by default).
* "Scheduling" [redundant] persistent containers that launch on boot
  is not in scope for :ref:`Docker`

:ref:`Kubernetes` is one project which uses Docker to
schedule redundant :ref:`LXC` containers (in "Pods").

:ref:`Salt` can install and manage docker, docker images and containers:

* https://github.com/saltstack-formulas/docker-formula
* https://docs.saltstack.com/en/latest/ref/states/all/salt.states.dockerio.html
* http://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.dockerio.html

https://github.com/veggiemonk/awesome-docker


.. index:: Kubernetes
.. _kubernetes:

Kubernetes
~~~~~~~~~~~
| Homepage: http://kubernetes.io/
| Src: https://github.com/GoogleCloudPlatform/kubernetes
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
| Src: https://github.com/mesosphere/kubernetes-mesos

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
| Src: git git://git.apache.org/libcloud.git
| Src: git https://github.com/apache/libcloud

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
| Src: git git://libvirt.org/libvirt-appdev-guide.git

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
| Src: https://github.com/lxc/lxc

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
| Src: https://github.com/lxc/lxd

LXD,
written in :ref:`Go`,
builds upon :ref:`LXC` to provide a system-wide daemon
and an :ref:`OpenStack` Nova hypervisor plugin.


.. index:: Mesos
.. _mesos:

Mesos
~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Apache_Mesos
| Homepage: https://mesos.apache.org/
| Src: git https://github.com/apache/mesos
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
| Src: https://github.com/mesosphere
| Q&A: https://stackoverflow.com/tags/mesosphere
| Twitter: https://twitter.com/mesosphere

* Apache :ref:`Mesos` is a core Mesosphere service


.. index:: OpenStack
.. _openstack:

OpenStack
~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/OpenStack
| Homepage: https://www.openstack.org/
| Src: https://git.openstack.org
| Src: https://github.com/openstack
| Q&A: https://stackoverflow.com/questions/tagged/openstack
| Docs: http://docs.openstack.org/
| Docs: https://wiki.openstack.org/
| Docs: https://wiki.openstack.org/wiki/Get_OpenStack
| Twitter: https://twitter.com/openstack

OpenStack is a platform of infrastructure services
for running a cloud datacenter (a *private* or a *public* cloud).

* OpenStack can be installed on one machine with enough RAM,
  or many thousands of machines.

* OpenStack **Keystone** -- cluster/grid/cloud-level
  token and user-service based
  authentication (authN) and authorization (authZ)
  as a service.

  * Src: git https://github.com/openstack/keystone
  * Wiki: https://wiki.openstack.org/wiki/Keystone

* OpenStack **Nova** implements a Hypervisor API
  which abstracts various :ref:`Virtualization` providers
  (e.g. :ref:`KVM`, :ref:`Docker`, :ref:`LXC`, :ref:`LXD`).

  * Src: git https://github.com/openstack/nova
  * Wiki: https://wiki.openstack.org/wiki/Nova
  * Docs: https://wiki.openstack.org/wiki/HypervisorSupportMatrix
  * Docs: http://docs.openstack.org/developer/nova/support-matrix.html

* OpenStack **Swift** -- redundant HTTP-based Object Storage
  as a service.

  * Src: git https://github.com/openstack/swift
  * Wiki: https://wiki.openstack.org/wiki/Swift
  * Docs: http://docs.openstack.org/developer/swift/
  * Docs: http://docs.openstack.org/developer/swift/overview_auth.html
  * Docs: http://docs.openstack.org/developer/swift/overview_object_versioning.html

* OpenStack **Neutron** (*Quantum*)-- software defined networking (SDN), VLAN,
  switch configuration, virtual and physical
  enterprise networking as a service.

  * Src: git https://github.com/openstack/neutron
  * Wiki: https://wiki.openstack.org/wiki/Neutron

* OpenStack **Designate** -- DNS as a service (Bind9, PowerDNS)
  integrated with OpenStack Keystone, Neutron, and Nova.

  * Src: git https://github.com/openstack/designate
  * Wiki: https://wiki.openstack.org/wiki/Designate

* OpenStack **Poppy** -- CDN as a service CDN vendor API

  * Src: git https://github.com/stackforge/poppy
  * Wiki: https://wiki.openstack.org/wiki/Poppy

* OpenStack **Horizon** -- web-based OpenStack Dashboard
  which is written in Django.

  * Src: git https://github.com/openstack/horizon
  * https://wiki.openstack.org/wiki/Horizon

OpenStack makes it possible for end-users to create a new virtual
machine from the available pool of resources.


``rdfs:seeAlso``: :ref:`openstack-devstack`, :ref:`Libcloud`


.. index:: OpenStack DevStack
.. _openstack-devstack:

OpenStack DevStack
~~~~~~~~~~~~~~~~~~
| Docs: http://docs.openstack.org/developer/devstack/
| Docs: http://docs.openstack.org/developer/devstack/overview.html
| Src: git https://github.com/openstack-dev/devstack
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
| Src: git https://github.com/mitchellh/packer

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

      - :ref:`VirtualBox`
      - :ref:`Docker`
      - :ref:`OpenStack`
      - GCE
      - EC2
      - VMware
      - QEMU (:ref:`KVM`, Xen)
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
| Src: git https://github.com/mitchellh/vagrant


Vagrant is a tool written in :ref:`Ruby`
for creating and managing virtual machine instances
with CPU, RAM, Storage, and Networking.

* Vagrant:

  * Works with a number of `Cloud` and
    :ref:`Virtualization` providers:

    * :ref:`VirtualBox`
    * AWS EC2
    * GCE
    * :ref:`OpenStack`

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

   vagrantfile
      vagrant script defining a team of one or more
      virtual machines and networks.

      create a vagrantfile::

         vagrant init [basebox]
         cat vagrantfile

      start virtual machines and networks defined in the vagrantfile::

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
| Src: svn svn://www.virtualbox.org/svn/vbox/trunk


Oracle VirtualBox is a platform virtualization package
for running one or more guest VMs (virtual machines) within a host system.

VirtualBox:

* runs on many platforms: :ref:`Linux`, OSX, Windows
* has support for full platform NX/AMD-v virtualization
* requires matching kernel modules

:ref:`Vagrant` scripts VirtualBox.


.. index:: Shells
.. _shells:

Shells
========

.. index:: Bash
.. _bash:

Bash
~~~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>`__
| Homepage: http://www.gnu.org/software/bash/
| Docs: https://www.gnu.org/software/bash/manual/
| Src: git git://git.savannah.gnu.org/bash.git

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
| Src: ftp ftp://ftp.gnu.org/gnu/readline/readline-6.3.tar.gz
| Pypi: https://pypi.python.org/pypi/gnureadline


.. index:: IPython
.. index:: ipython
.. _ipython:

IPython
~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/IPython
| Homepage: http://ipython.org/
| Src: git https://github.com/ipython/ipython
| DockerHub: https://registry.hub.docker.com/repos/ipython/
| Docs: http://ipython.org/ipython-doc/stable/
| Docs: http://ipython.org/ipython-doc/stable/interactive/
| Docs: http://ipython.org/ipython-doc/stable/notebook/
| Docs: http://ipython.org/ipython-doc/stable/parallel/
| Docs: https://github.com/ipython/ipython/wiki/Extensions-Index
| Docs: https://github.com/ipython/ipython/wiki/IPython-kernels-for-other-languages
| Docs: https://github.com/ipython/ipython/wiki/Install:-Docker
| Docs: https://github.com/ipython/ipython/wiki/A-gallery-of-interesting-IPython-Notebooks

IPython is an interactive REPL and distributed computation framework
written in :ref:`Python`.

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


.. index:: IPython Notebook
.. index:: IPython notebook
.. _ipython notebook:

IPython Notebook
++++++++++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/IPython#Notebook
| Src: https://github.com/ipython/ipython/tree/3.x/IPython/html
| Docs: http://ipython.org/ipython-doc/stable/notebook/
| Docs: http://ipython.org/ipython-doc/stable/notebook/notebook.html
| Docs: http://ipython.org/ipython-doc/stable/notebook/nbformat.html
| Docs: http://ipython.org/ipython-doc/stable/notebook/nbconvert.html
| Docs: http://ipython.org/ipython-doc/stable/notebook/public_server.html
| Docs: http://ipython.org/ipython-doc/stable/notebook/security.html

:ref:`IPython` Notebook is a web-based shell for interactive
and literate computing with IPython notebooks.

* An IPython notebook (``.ipynb``) is a
  :ref:`JSON-` document containing input and output
  for a linear sequence of cells;
  which can be exported to many output formats
  (e.g. :ref:`HTML-`, RST, LaTeX, PDF);
  and edited through the web with
  IPython Notebook.
* IPython Notebook supports :ref:`Markdown` syntax for comment cells.
* IPython Notebook supports more than 40 different IPython kernels for
  other languages:

  https://github.com/ipython/ipython/wiki/IPython-kernels-for-other-languages

* IPython Notebook development has now moved to :ref:`Jupyter` Notebook;
  which supports IPython kernels (and defaults to the :ref:`IPython`
  :ref:`CPython` :ref:`2 <python>`
  or :ref:`3 <python3>` kernel).

To start IPython Notebook (assuming the ``_SRC`` variable
as defined in :ref:`Venv`):

.. code:: bash

   pip install ipython[notebook]
   # pip install -e git+https://github.com/ipython/ipython@rel-3.2.1#egg=ipython
   # https://github.com/ipython/ipython/releases

   mkdir $_SRC/notebooks; cd $_SRC/notebooks
   ipython notebook

   ipython notebook --notebook-dir="${_SRC}/notebooks"

   # With HTTPS (TLS/SSL)
   ipython notebook \
    --ip=127.0.0.1 \
    --certfile=mycert.pem \
    --keyfile=privkey.pem \
    --port=8888 \
    --browser=web  # (optional) westurner/dotfiles/scripts/web

    # List supported options
    ipython notebook --help


.. warning:: IPython Notebook runs code and shell commands as
    the user the process is running as, on a remote or local machine.

    Reproducible :ref:`SciPy Stack <scipystack>`
    IPython Notebook / :ref:`Jupyter Notebook` servers
    implement best practices like process isolation and privilege separation
    with e.g. :ref:`Docker` and/or :ref:`Jupyter` Hub.

.. note:: IPython Notebook is now :ref:`Jupyter Notebook`.

   Jupyter Notebook runs Python notebooks with the :ref:`IPython`
   :ref:`CPython` kernel (from :ref:`IPython Notebook`).


.. index:: ipython_nose
.. _ipython_nose:

--------------
ipython_nose
--------------
| Src: git https://github.com/taavi/ipython_nose


ipython_nose is an extension for :ref:`IPython Notebook`
(and likely :ref:`Jupyter Notebook`)
for discovering and running test functions
starting with ``test_``
(and unittest.TestCase test classes with names containing ``Test``)
with `Nose <https://westurner.org/wiki/awesome-python-testing#nose>`__.

* ipython_nose is not (yet?) uploaded to PyPI
* to install ipython_nose from GitHub (with :ref:`Pip` and :ref:`Git`):

.. code:: bash

   pip install -e git+https://github.com/taavi/ipython_nose#egg=ipython_nose


.. index:: Jupyter
.. index:: Project Jupyter
.. _jupyter:

Jupyter
~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/IPython#Project_Jupyter
| Homepage: http://jupyter.org/
| Src: https://github.com/jupyter/
| Src: git https://github.com/jupyter/notebook
| Src: git https://github.com/jupyter/jupyterhub
| Src: https://registry.hub.docker.com/u/jupyter/tmpnb/
| DockerHub: https://registry.hub.docker.com/repos/ipython/
| DockerHub: https://registry.hub.docker.com/repos/jupyter/
| Docs: https://github.com/ipython/ipython/wiki/Install:-Docker
| Docs: https://github.com/ipython/ipython/wiki/IPython-kernels-for-other-languages
| Docs: https://github.com/jupyter/jupyter/blob/master/docs/source/index.rst
| Docs: https://github.com/jupyter/jupyterhub/wiki
| Docs: https://github.com/jupyter/jupyterhub/wiki/Authenticators
| Docs: https://github.com/jupyter/jupyterhub/wiki/Spawners

Project Jupyter expands upon
components like :ref:`IPython` and :ref:`IPython Notebook`
to provide a multi-user web-based shell
for many languages (:ref:`Python`, :ref:`Ruby`, :ref:`Java`,
:ref:`Haskell`, Julia, R).


.. table:: IPython Jupyter comparison (adapted from http://jupyter.org)
   :name: IPython Jupyter comparison

   +-------------------------------+-------------------------------------------------------------+
   | :ref:`IPython`                | :ref:`Jupyter`                                              |
   +-------------------------------+-------------------------------------------------------------+
   | - Interactive Python shell    | - Rich REPL Protocol                                        |
   | - Python kernel for Jupyter   | - :ref:`Jupyter Notebook` (format, environment, conversion) |
   | - Interactive Parallel Python | - JupyterHub (multi-user notebook server)                   |
   |                               | - JupyterHub authenticators (MediaWiki OAuth, GitHub OAuth) |
   |                               | - JupyterHub spawners (Docker, Sudo, Remote, Docker Swarm)  |
   +-------------------------------+-------------------------------------------------------------+


.. index:: Jupyter Notebook
.. _jupyter notebook:

Jupyter Notebook
+++++++++++++++++++
| Src: https://github.com/jupyter/notebook

:ref:`Jupyter` Notebook is the latest :ref:`IPython Notebook`.

   The Jupyter HTML Notebook is a web-based notebook environment
   for interactive computing.

.. warning:: Jupyter Notebook runs code and shell commands as
   the user the process is running as, on a remote or local machine.

   Reproducible :ref:`SciPy Stack <scipystack>`
   IPython Notebook / :ref:`Jupyter Notebook` servers
   implement best practices like process isolation and privilege separation
   with e.g. :ref:`Docker` and/or :ref:`Jupyter` Hub.


.. index:: Jupyter Drive
.. _jupyter drive:

Jupyter Drive
++++++++++++++++++++++++++
| Src: git https://github.com/jupyter/jupyter-drive

Jupyter Drive adds support to :ref:`Jupyter Notebook`
for reading and writing :ref:`nbformat` notebook ``.ipynb``
files to and from Google Drive.

Realtime collaborative features (e.g. with `Operational Transformation`)
are next.


.. index:: nbconvert
.. _nbconvert:

nbconvert
+++++++++++
| Docs: http://ipython.org/ipython-doc/stable/notebook/nbconvert.html
|

nbconvert is the code that converts (transforms) an ``.ipynb`` notebook
(:ref:`nbformat` :ref:`JSON <json->`) file
( into an output representation (e.g. HTML,
slides (reveal.js), LaTeX, PDF, ePub, Mobi).

* nbconvert is included with :ref:`IPython`
* nbconvert is part of :ref:`Project Jupyter<jupyter>`

  .. code:: bash

    pip install nbconvert
    # pip install -e git+https://github.com/jupyter/nbconvert@master#egg=nbconvert

    ipython nbconvert --to html mynotebook.ipynb
    jupyter nbconvert --to html mynotebook.ipynb


* reveal.js is an HTML presentation framework
  for slides in a 1D or 2D arrangement.

  Presentation content that doesn't fit on the slide is hidden
  and unscrollable (*only put a slide worth of data in each cell
  for a Jupyter reveal.js presentation*).

  .. code:: bash

    jupyter nbconvert --to slides mynotebook.ipynb

  https://github.com/hakimel/reveal.js
* RISE does live reveal.js notebook presentations

  https://github.com/damianavila/RISE


.. index:: nbformat
.. _nbformat:

nbformat
++++++++++
| Docs: http://ipython.org/ipython-doc/dev/notebook/nbformat.html
| Docs: https://nbformat.readthedocs.org/en/latest/
| Docs: https://nbformat.readthedocs.org/en/latest/format_description.html#backward-compatible-changes

The :ref:`Jupyter notebook` (``.ipynb``) format is a versioned
:ref:`JSON <json->` format for storing metadata and input/output sequences.

Usually, when the nbformat changes, notebooks are silently upgraded to the
new version on the next save.

.. note:: nbformat v3 and above add a **kernelspec** attribute to the
   nbformat :ref:`JSON <json->`, because ``.ipynb`` files can now contain
   code for languages other than :ref:`Python`.

nbformat does not specify any schema for the user-supplied
metadata dict (TODO) that can be edited
so, JSON that conforms to an externally
managed :ref:`JSON-LD <json-ld->` ``@context``
would work.


.. index:: nbviewer
.. _nbviewer:

nbviewer
+++++++++++
| Homepage: http://nbviewer.ipython.org
| Src: git https://github.com/jupyter/nbviewer
| Dockerfile: https://github.com/jupyter/nbviewer/blob/master/Dockerfile

:ref:`Jupyter Notebook` Viewer (``nbviewer``)
is an application for serving read-only
versions of ``.ipynb`` files which have HTTP URLs.

GitHub now also renders static ``.ipynb`` files, CSV, SVG, and PDF.


.. index:: runipy
.. _runipy:

runipy
+++++++
| Src: git https://github.com/paulgb/runipy
| PyPI: https://pypi.python.org/pypi/runipy

runipy runs :ref:`Jupyter notebooks <jupyter notebook>`
from a :ref:`Shell <shells>` commandline, generates
`HTML` reports,
and can write errors to stderr.

:ref:`Jupyter notebook <Jupyter Notebook>` *manual* test review process:

.. code:: python

    # - run Jupyter Notebook server
    !jupyter notebook
    # - Browser
    #     - navigate to / upload / drag and drop the notebook
            !web http://localhost:8888   # or https://
    #     - (optional) click 'TODO Restart Kernel'
    #     - (optional) click 'Cell' > 'All Output' > 'Clear'
    #     - click 'Cell' > 'Run All'
    #     - [wait] <Jupyter Kernel runs notebook>
    #     - visually seek for the first ERRoring cell (scroll)
    #     - review the notebook
            for (i, o) in notebook_cells:
                human.manually_review((i, o))
    # - Compare the files on disk with the most recent commit (HEAD)
    !git status && git diff
    !git diff mynotebook.ipynb
    # - Commit the changes
    !git-add-commit "TST: mynotebook: tests for #123" ./mynotebook.ipynb


:ref:`Jupyter notebook <Jupyter Notebook>` TODO review process:

.. code:: python

   # - run Jupyter Notebook server
   !jupyter notebook
   # - Browser
   #     - navigate to / upload / drag and drop the notebook
           !web http://localhost:8888   # or https://
   #     - (optional) click 'TODO Restart Kernel'
   #     - (optional) click 'Cell' > 'All Output' > 'Clear'
   #     - click 'Cell' > 'Run All'
   #     - [wait] <Jupyter Kernel runs notebook>
   #     - visually seek for the first ERRoring cell (scroll)
   #     - review the notebook
           for (i, o) in notebook_cells:
               human.manually_review((i, o))
   # - Compare the files on disk with the most recent commit (HEAD)
   !git status && git diff
   !git diff mynotebook.ipynb
   # - Commit the changes
   !git-add-commit "TST: mynotebook: tests for #123" ./mynotebook.ipynb


:ref:`Jupyter notebook <Jupyter Notebook>` runipy review process:

.. code:: python

    # - runipy the Jupyter notebook
    !runipy mynotebook.ipynb
    # - review stdout and stderr from runipy
    # - review in browser (optional; recommended)
    #     - navigate to the converted HTML
            !web ./mynotebook.ipynb.html
    #     - visually seek for the first WEEoring cell (scroll)
    #     - review the notebook
            for (i, o) in notebook_cells:
                human.manually_review((i, o))
    # - Compare the files on disk with the most recent commit (HEAD)
    !git status && git diff
    !git diff mynotebook.ipynb*
    # - Commit the changes
    !git-add-commit "TST: mynotebook: tests for #123" ./mynotebook.ipynb*

* An example of runipy usage in a :ref:`Makefile <Make>`:
  https://github.com/westurner/notebooks/blob/gh-pages/Makefile




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
| Src: git git://git.code.sf.net/p/zsh/code


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
| Src: git git://git.savannah.gnu.org/gawk.git

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
| Src: git git://git.savannah.gnu.org/grep.git

Grep is a commandline utility for pattern-based text matching.


.. index:: Htop
.. _htop:

Htop
~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Htop
| Homepage: http://hisham.hm/htop/
| Src: git http://hisham.hm/htop/

Htop is a commandline task manager; like ``top`` extended.


.. index:: Pyline
.. _pyline:

Pyline
~~~~~~~~
| Homepage: https://github.com/westurner/pyline
| Docs: https://pyline.readthedocs.org/en/latest/
| Src: git https://github.com/westurner/pyline
| Pypi: https://pypi.python.org/pypi/pyline

Pyline is an `open source`
:ref:`POSIX` command-line utility
for streaming line-based processing in :ref:`Python`
with regex and output transform features similar to
:ref:`grep`, :ref:`sed`, and :ref:`awk`.

* Pyline can generate quoted CSV, :ref:`JSON <json->`, HTML, etc.


.. index:: Pyrpo
.. _pyrpo:

Pyrpo
~~~~~~
| Homepage: https://github.com/westurner/pyrpo
| Src: git https://github.com/westurner/pyrpo
| Pypi: https://pypi.python.org/pypi/pyrpo

Pyrpo is an `open source`
:ref:`POSIX` command-line utility
for locating and generating reports
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
| Src: git git.savannah.gnu.org/sed.git

GNU Sed is an `open source`
:ref:`POSIX` command-line utility for transforming text.

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

Dotfiles are userspace :ref:`shell <shells>`
configuration in files that are often prefixed with "dot"
(e.g. ``~/.bashrc`` for :ref:`Bash`)

* https://dotfiles.github.io/
* westurner/dotfiles

  | Src: git https://github.com/westurner/dotfiles
  | Src: https://github.com/westurner/dotfiles/blob/master/etc/.bashrc
  | Docs: https://westurner.org/dotfiles/
  | Docs: https://westurner.org/dotfiles/usage#bash

  Features

  + [x] Linear ``etc/bash`` and ``etc/zsh`` (``/etc/bash``) load sequence
  + [x] :ref:`make` ``Makefile`` to log
    the whole load sequence and grep out docs
  + [x] :ref:`HubFlow` :ref:`git` branches
  + [x] :ref:`venv`, :ref:`virtualenv`, :ref:`virtualenvwrapper`
  + [x] oh-my-zsh
  + [-] bash-it


.. index:: Dotvim
.. _dotvim:

Dotvim
~~~~~~~~
Dotvim is a conjunction / contraction of :ref:`Dotfiles` and :ref:`Vim`
(in reference to a ``~/.vim/`` directory and/or a ``~/.vimrc``).

| Src: git https://github.com/westurner/dotvim
| Src: https://github.com/westurner/dotvim/blob/master/vimrc
| Src: https://github.com/westurner/dotvim/blob/master/vimrc.full.bundles.vimrc
| Src: https://github.com/westurner/dotvim/blob/master/vimrc.tinyvim.bundles.vimrc
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

Venv defines standard :ref:`fhs` and :ref:`Python` paths,
environment variables,
and aliases
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
| Src: git https://github.com/pypa/virtualenv
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
| Src: hg https://bitbucket.org/dhellmann/virtualenvwrapper
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
.. _window managers:

Window Managers
================
| Wikipedia: https://en.wikipedia.org/wiki/Window_manager
| Docs: https://wiki.archlinux.org/index.php/Window_manager


.. index:: Compiz
.. _compiz:

Compiz
~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Compiz
| Homepage: https://launchpad.net/compiz
| Docs: http://wiki.compiz.org/
| Src: bzr branch lp:compiz


Compiz is a window compositing layer for :ref:`X11` which adds
lots of cool and productivity-enhancing visual capabilities.

Compiz works with :ref:`Gnome`, :ref:`KDE`, and :ref:`Qt` applications.


.. index:: f.lux
.. _f.lux:

f.lux
~~~~~~
| Homepage: https://justgetflux.com/
| Download: https://justgetflux.com/dlmac.html
| Download: https://justgetflux.com/dlwin.html
| Src: git https://github.com/Kilian/f.lux-indicator-applet
| Docs: https://justgetflux.com/linux.html
| Docs: https://justgetflux.com/ios.html
| Docs: https://justgetflux.com/research.html

f.lux is a userspace utility for gradually adjusting
the blue color channel throughout the day;
or as needed.

* A similar effect can be accomplished with the :ref:`X11` ``xgamma``
  command (e.g. for :ref:`Linux` platforms where the latest f.lux
  is not yet available). A few keybindings from an :ref:`i3wm` configuration
  `here <https://github.com/westurner/dotfiles/blob/0514992283af/etc/i3/config#L105>`_:

  .. code::

      # [...] #L105
      set $xgamma_reset    xgamma -gamma 1.0
      set $xgamma_soft     xgamma -bgamma 0.6 -ggamma 0.9 -rgamma 0.9
      set $xgamma_soft_red xgamma -bgamma 0.4 -ggamma 0.6 -rgamma 0.9
      # [...] #L200
      ## Start, stop, and reset xflux
      #  <alt> [         -- start xflux
      bindsym $mod+bracketleft    exec --no-startup-id $xflux_start
      #  <alt> ]         -- stop xflux
      bindsym $mod+bracketright   exec --no-startup-id $xflux_stop
      #  <alt><shift> ]  -- reset gamma to 1.0
      bindsym $mod+Shift+bracketright  exec --no-startup-id $xgamma_reset
      #  <alt><shift> [  -- xgamma -bgamma 0.6 -ggamma 0.9 -rgamma 0.9
      bindsym $mod+Shift+bracketleft exec --no-startup-id $xgamma_soft
      #  <alt><shift> \  -- xgamma -bgamma -0.4 -ggamma 0.4 -rgamma 0.9
      bindsym $mod+Shift+p exec --no-startup-id $xgamma_soft_red


.. index:: Gnome
.. _gnome:

Gnome
~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/GNOME
| Homepage: http://www.gnome.org/
| Docs: https://help.gnome.org/
| Src: https://git.gnome.org/browse/


* https://wiki.gnome.org/GnomeLove


.. index:: i3wm
.. _i3wm:

i3wm
~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/I3_(window_manager)>`__
| Homepage: http://i3wm.org/
| Download: http://i3wm.org/downloads/
| Docs: http://i3wm.org/docs/
| Src: git git://code.i3wm.org/i3

i3wm is a tiling window manager for :ref:`X11` (:ref:`Linux`)
with extremely-configurable :ref:`Vim`-like keyboard shortcuts.

i3wm works with :ref:`Gnome`, :ref:`KDE`, and :ref:`Qt` applications.

* An example open source i3wm ``i3/config`` :ref:`dotfile <dotfiles>`:
  https://github.com/westurner/dotfiles/blob/master/etc/i3/config


.. index:: KDE
.. _kde:

KDE
~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/KDE
| Homepage: https://www.kde.org/
| Docs: https://docs.kde.org/
| Docs: https://www.kde.org/documentation/
| Src: https://techbase.kde.org/Getting_Started/Sources
| Src: https://techbase.kde.org/Getting_Started/Sources/Subversion
| Src: https://techbase.kde.org/Development/Git
| Src: https://projects.kde.org/projects


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
| Src:


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
| Src: git git://anongit.freedesktop.org/git/xorg/


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

.. index:: Blink
.. _blink:

Blink
~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Blink_(layout_engine)>`__
| Homepage: https://www.chromium.org/blink
| Src: https://src.chromium.org/viewvc/blink/trunk/
| Src: git https://chromium.googlesource.com/chromium/blink/
| Docs: https://www.chromium.org/blink#TOC-Subpage-Listing
| Docs: https://www.chromium.org/blink/developer-faq

Blink is a :ref:`web browser <browsers>` layout engine
written in :ref:`C++` which was forked from :ref:`WebKit`.

* Blink now powers :ref:`Chrome` and :ref:`Chromium` (Desktop, Mobile),
  :ref:`Opera`,
  Amazon Silk,
  :ref:`Android` WebView 4.4+,
  and :ref:`Qt` WebEngine


.. index:: Chrome
.. _chrome:

Chrome
~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Google_Chrome 
| Homepage: https://www.google.com/chrome/
| Download: https://www.google.com/chrome/browser/desktop/
| Download: https://www.google.com/chrome/browser/mobile/
| AndroidApp: https://play.google.com/store/apps/details?id=com.android.chrome
| AndroidAppBeta: https://play.google.com/store/apps/details?id=com.chrome.beta
| iOSApp: https://itunes.apple.com/us/app/chrome-web-browser-by-google/id535886823
| Docs: https://developer.chrome.com
| Docs: https://developer.chrome.com/extensions/devguide

Google Chrome is a Web Browser built from
the open source :ref:`Chromium` browser.

* Google Chrome is now based on :ref:`Blink`.
* Google Chrome was based on :ref:`WebKit`.
* Google Chrome includes and updates Adobe Flash, pdf.js

See also: :ref:`ChromeOS`.


.. index:: Chromium
.. _chromium:

Chromium
~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Chromium_(web_browser)>`__
| Homepage: https://www.chromium.org/Home
| Src: git https://chromium.googlesource.com/chromium/src
| Src: https://chromium.googlesource.com/chromium/src.git
| Docs: https://www.chromium.org/developers
| Docs: https://www.chromium.org/developers/coding-style

The Chromium Projects include the :ref:`Chromium` Browser
and :ref:`chromiumos`.

* Chromium Projects are written in :ref:`C++11 <c++>`, :ref:`C`,
  IDL, :ref:`Jinja2`, :ref:`Python`, :ref:`Javascript`, :ref:`HTML-`,
  and :ref:`CSS-`.
* :ref:`Chrome` and :ref:`ChromeOS` build from :ref:`Chromium`
  project sources.


.. index:: Chrome DevTools
.. _chrome-devtools:

Chrome DevTools
++++++++++++++++
| Homepage: https://developer.chrome.com/devtools
| Docs: https://developer.chrome.com/devtools

* Right-click > "Inspect Element"
* OSX: ``<option>`` + ``<command>`` + ``i``

DevTools Emulation

* Resize Window to iPhone, iPad, Nexus, Galaxy (landscape / portrait)
* Emulates touch events
* https://developers.google.com/web/fundamentals/tools/devices/browseremulation?hl=en


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
* `Tiësto`_ (Dark Chrome Theme)
* See also: :ref:`f.lux`


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

* `AngularJS Batarang`_
* `FireBug`_ (see: `Chrome DevTools`_)
* `FireLogger for Chrome`_
* `JSONView`_
* `ng-inspector for AngularJS`_
* `Postman`_
* `React Developer Tools`_
* `Responsive Web Design Tester`_
* `Requirify`_
* `Web Developer`_
* `Window Resizer`_

**Vim**

* `Vimium`_
* `Wasavi`_


.. index:: pbm
.. _pbm:

pbm
++++
| Src: git https://github.com/westurner/pbm
| PyPI: https://pypi.python.org/pypi/pbm
| Warehouse: https://warehouse.python.org/project/pbm

* backup and organize
  { :ref:`Chrome` , :ref:`Chromium` }
  ``Bookmarks`` :ref:`JSON <JSON->`
  in an offline batch
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
| Src: hg https://bitbucket.org/westurner/wandroid

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
* `ng-inspector for AngularJS`_
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


.. index:: Internet Explorer
.. _internet explorer:

Internet Explorer
~~~~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/?title=Internet_Explorer
| Homepage: http://microsoft.com/ie

Internet Explorer is the web browser included with :ref:`Windows`.

See also: :ref:`Microsoft Edge`


.. index:: Microsoft Edge
.. _microsoft edge:

Microsoft Edge
~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Microsoft_Edge

Microsoft Edge will be replacing :ref:`Internet Explorer`.


.. index:: Opera
.. _opera:

Opera
~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Opera_(web_browser)>`__
| Homepage: http://www.opera.com/
| Download: http://www.opera.com/computer/windows
| Download: http://www.opera.com/computer/mac
| Download: http://www.opera.com/computer/linux
| Download: http://www.opera.com/computer/beta
| Download: http://www.opera.com/mobile
| AndroidApp: https://play.google.com/store/apps/details?id=com.opera.browser
| AndroidApp: https://play.google.com/store/apps/details?id=com.opera.mini.native
| AndroidApp: https://play.google.com/store/apps/details?id=com.opera.max.global #Proxy Compression
| iOSApp: https://itunes.apple.com/app/id363729560 #Opera Mini
| iOSApp: https://itunes.apple.com/app/id674024845 #Opera Coast
| WinMoApp: http://www.windowsphone.com/en-us/store/app/opera-mini-beta/b3bf000a-e004-4ecb-a8fb-9fc817cdab90
| Src: https://github.com/operasoftware

Opera is a multi-platform :ref:`web browser <browsers>` written in :ref:`C++`.

* Opera is now based on :ref:`Blink`.
* Opera was based on :ref:`WebKit`.
* Opera developed and open sourced celery:
  a distributed task worker composed workflow process API
  written in :ref:`Python`; with support for many
  message browsers:
  https://github.com/celery


.. index:: Safari
.. _safari:

Safari
~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Safari_(web_browser)>`__
| Homepage: https://developer.apple.com/safari/
| Src:
| Docs: https://developer.apple.com/safari/resources/
| Docs: https://developer.apple.com/library/safari/navigation/
| Docs: https://developer.apple.com/library/safari/documentation/Tools/Conceptual/SafariExtensionGuide/Introduction/Introduction.html
| Docs: https://developer.apple.com/library/safari/documentation/AppleApplications/Conceptual/Safari_Developer_Guide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40007874

Safari is the web browser included with :ref:`OSX`.

* Safari is derived from and supports :ref:`WebKit`


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

**Development**

* `ng-inspector for AngularJS`_



.. index:: Safari iOS
.. _safari ios:

Safari iOS
~~~~~~~~~~~~~~~

* `Pocket`_


.. index:: WebKit
.. _webkit:

WebKit
~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/WebKit
| Homepage: https://www.webkit.org/
| Download: http://nightly.webkit.org/
| Src: https://github.com/WebKit/webkit
| Docs: https://www.webkit.org/coding/coding-style.html
| Docs: https://trac.webkit.org/wiki

WebKit is an open source :ref:`web browser <browsers>`
written in :ref:`C++`.

* WebKit powers :ref:`Safari`


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
| Src: https://github.com/abstiles/deluminate
| ChromeExt: https://chrome.google.com/webstore/detail/deluminate/iebboopaeangfpceklajfohhbpkkfiaa


.. index:: High Contrast
.. _high contrast:

High Contrast
++++++++++++++
| ChromeExt: https://chrome.google.com/webstore/detail/high-contrast/djcfdncoelnlbldjfhinnjlhdjlikmph


.. index:: NASA Night Launch
.. _nasa night launch:

NASA Night Launch
++++++++++++++++++
| FirefoxExt: https://addons.mozilla.org/en-us/firefox/addon/nasa-night-launch/
| FirefoxXPI: https://addons.mozilla.org/firefox/downloads/latest/4908/addon-4908-latest.xpi


.. index:: Spectrum
.. _spectrum:

Spectrum
+++++++++
| Src: https://github.com/lvivski/spectrum
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


.. index:: Tiësto
.. _tiesto:

Tiësto
++++++++
| ChromeExt: https://chrome.google.com/webstore/detail/ti%C3%ABsto/mnmeobddjkkgkglnogihcaejaleikhdh

The Tiësto Chrome Theme is a Dark Theme for Chrome.


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
| Src: https://www.ghostery.com/en/download
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
| Src: https://github.com/EFForg/https-everywhere
| ChromeExt: https://chrome.google.com/webstore/detail/gcbommkclmclpchllfjekcdonpmejbdp
| FirefoxXPI: https://www.eff.org/files/https-everywhere-latest.xpi
| FirefoxAndroidXPI: https://www.eff.org/files/https-everywhere-android.xpi
| Twitter: https://twitter.com/HTTPSEverywhere

.. index:: uBlock
.. _ublock:

uBlock
++++++++
| Homepage: https://www.ublock.org/
| Src: https://github.com/chrisaljoudi/ublock
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
| Src: https://github.com/hypothesis/h
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
| Src: https://github.com/josephschmitt/Snipe
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

.. index:: AngularJS Batarang
.. _angularjs-batarang:

AngularJS Batarang
+++++++++++++++++++
| Src: https://github.com/spalger/angularjs-batarang
| ChromeExt: https://chrome.google.com/webstore/detail/angularjs-batarang-stable/niopocochgahfkiccpjmmpchncjoapek

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
| Src: https://github.com/binaryage/firelogger
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
| Src: https://github.com/MattSkala/chrome-firelogger
| ChromeExt: https://chrome.google.com/webstore/detail/firelogger-for-chrome/hmagilfopmdjkeomnjpchokglfdfjfeh

See: `FireLogger`_


.. index:: JSONView
.. _jsonview:

JSONView
+++++++++
| Src: https://github.com/gildas-lormeau/JSONView-for-Chrome
| ChromeExt: https://chrome.google.com/webstore/detail/jsonview/chklaanhfefbnpoihckbnefhakgolnmc


.. index:: ng-inspector for AngularJS
.. index:: AngularJS ng-inspector
.. _ng-inspector-angularjs:

ng-inspector for AngularJS
+++++++++++++++++++++++++++
| Homepage: http://ng-inspector.org/
| Src: https://github.com/rev087/ng-inspector
| ChromeExt: https://chrome.google.com/webstore/detail/ng-inspector-for-angularj/aadgmnobpdmgmigaicncghmmoeflnamj
| FirefoxXPI: http://ng-inspector.org/ng-inspector.xpi
| SafariExt: http://ng-inspector.org/ng-inspector.safariextz


.. index:: Postman
.. _postman:

Postman
++++++++
| Src: https://github.com/a85/POSTMan-Chrome-Extension
| ChromeExt: https://chrome.google.com/webstore/detail/postman-rest-client/fdmmgilgnpjigdojojpjoooidkmcomcm
| Twitter: https://twitter.com/postmanclient


.. index:: React Developer Tools
.. _react developer tools:

React Developer Tools
++++++++++++++++++++++
| ChromeExt: https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi


.. index:: Responsive Web Design Tester
.. _responsive-web-design-tester:

Responsive Web Design Tester
+++++++++++++++++++++++++++++
| ChromeExt: https://chrome.google.com/webstore/detail/responsive-web-design-tes/objclahbaimlfnbjdeobicmmlnbhamkg
| Homepage: https://www.esolutions.se/

See also: :ref:`Chrome DevTools <chrome-devtools>` Emulation


.. index:: Requirify
.. _requirify:

Requirify
+++++++++++
| Homepage: https://wzrd.in/
| Src: https://github.com/mathisonian/requirify
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
| Src: https://github.com/chrispederick/web-developer/
| FirefoxExt: https://addons.mozilla.org/en-us/firefox/addon/web-developer/
| FirefoxXPI: https://addons.mozilla.org/firefox/downloads/latest/60/addon-60-latest.xpi

Web Developer Extension, originally just for Firefox, adds many
useful developer tools and bookmarklets in a structured menu.


.. index:: Window Resizer
.. _window-resizer:

Window Resizer
++++++++++++++++
| ChromeExt: https://chrome.google.com/webstore/detail/window-resizer/kkelicaakdanhinjdeammmilcgefonfh

See also: :ref:`Chrome DevTools <chrome-devtools>` Emulation



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
| Src: git https://github.com/philc/vimium
| ChromeExt: https://chrome.google.com/webstore/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb

Vimium is a Chrome Extension which adds :ref:`vim`-like functionality.


+-----------------------------------------+---------------------+
| **function**                            | **vimium shortcut** |
+-----------------------------------------+---------------------+
|  help                                   | ``?``               |
+-----------------------------------------+---------------------+
|  jump to link in current/New tab        | ``f`` / ``F``       |
+-----------------------------------------+---------------------+
|  copy link to clipboard                 | ``yf``              |
+-----------------------------------------+---------------------+
|  open clipboard link in current/New tab | ``p`` / ``P``       |
+-----------------------------------------+---------------------+
|  ...                                    |                     |
+-----------------------------------------+---------------------+


.. index:: Vimperator
.. _vimperator:

Vimperator
+++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Vimperator
| Homepage: http://www.vimperator.org/
| Src: https://github.com/vimperator/vimperator-labs
| FirefoxExt: https://addons.mozilla.org/en-US/firefox/addon/vimperator/

Vimperator connects a JS shell with VIM command interpretation
to the Firefox API, with :ref:`vim`-like functionality.

* ``vimperatorrc`` can configure settings in ``about:config``


.. index:: Wasavi
.. _wasavi:

Wasavi
+++++++
| Homepage: http://appsweets.net/wasavi/
| Src: https://github.com/akahuku/wasavi
| ChromeExt: https://chrome.google.com/webstore/detail/wasavi/dgogifpkoilgiofhhhodbodcfgomelhe
| OperaExt: https://addons.opera.com/en/extensions/details/wasavi/
| FirefoxExt: https://addons.mozilla.org/en-US/firefox/addon/wasavi/
| Docs: http://appsweets.net/wasavi/

Wasavi converts the focused ``textarea`` to an in-page editor with
:ref:`vim`-like functionality.


.. index:: Web Servers
.. _web servers:

Web Servers
============
| https://en.wikipedia.org/wiki/Web_server


.. index:: Apache HTTPD
.. _apache httpd:

Apache HTTPD
~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Apache_HTTP_Server
| Homepage: https://httpd.apache.org/
| Download: https://httpd.apache.org/download.cgi
| Docs: https://httpd.apache.org/docs/2.4/

Apache HTTPD is a scriptable, industry-mainstay `HTTP`
server written in :ref:`C` and :ref:`C++`.


.. index:: Nginx
.. _nginx:

Nginx
~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Nginx
| Homepage: http://nginx.org/
| Download: http://nginx.org/en/download.html
| Src: hg http://hg.nginx.org/nginx
| Docs: http://nginx.org/en/docs/
| Twitter: https://twitter.com/nginxorg

Nginx is a scriptable, lightweight `HTTP` server
written in :ref:`C`.


.. index:: Tengine
.. _tengine:

Tengine
~~~~~~~~~
| Wikipedia: https://zh.wikipedia.org/wiki/Tengine
| Homepage: http://tengine.taobao.org/
| Src: git https://github.com/alibaba/tengine
| Download: http://tengine.taobao.org/download.html
| Docs: http://tengine.taobao.org/documentation.html

Tengine is a fork of :ref:`Nginx` with many useful
modules and features bundled in.

* http://tengine.taobao.org/document/http_ssl.html
* http://tengine.taobao.org/document/http_upstream_check.html
* http://tengine.taobao.org/document/http_reqstat.html


.. index:: Documentation
.. _documentation-tools:

Documentation Tools
=====================
| Docs: https://wrdrd.com/docs/consulting/education-technology#publishing


.. index:: Docutils
.. _docutils:

Docutils
~~~~~~~~~~~~~~~~~~~
| Homepage: http://docutils.sourceforge.net
| PyPI: https://pypi.python.org/pypi/docutils
| Docs: http://docutils.sourceforge.net/docs/
| Docs: http://docutils.sourceforge.net/rst.html
| Docs: http://docutils.sourceforge.net/docs/ref/doctree.html
| Src: svn http://svn.code.sf.net/p/docutils/code/trunk

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


.. index:: pgs
.. _pgs:

Pgs
~~~~
| Src: https://github.com/westurner/pgs
| PyPI: https://pypi.python.org/pypi/pgs

pgs is an open source web application
written in :ref:`Python`
for serving static files from a :ref:`git` branch,
or from the local filesystem.

.. code:: bash

   pgs -p "${_WRD}/_build/html" -r gh-pages -H localhost -P 8082

* pgs is written with the one-file Bottle web framework
* compared to ``python -m SimpleHTTPServer localhost:8000`` /
  ``python3 -m http.server localhost:8000``
  pgs has WSGI,
  the ability to read from a Git branch
  without real :ref:`git` bindings,
  and caching HTTP headers based on
  Git or filesystem mtimes.
* pgs does something like :ref:`Nginx` ``try_files $.html``

  * https://westurner.org/tools/index

    https://westurner.org/tools/index.html

    * :ref:`Sphinx` can also generate links without ``.html`` extensions
      with the ``html_link_suffix`` ``conf.py`` configuration setting.

      https://github.com/westurner/tools/blob/master/conf.py :

      .. code:: python

        # Suffix for generated links to HTML files.
        # The default is whatever html_file_suffix is set to;
        # it can be set differently (e.g. to support different web server setups).
        html_link_suffix = ''


    * Many web analytics tools support rules for deduplicating
      ``<name>.html`` and ``<name>`` (which GitHub Pages always
      supports).


.. index:: Sphinx
.. _sphinx:

Sphinx
~~~~~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Sphinx_(documentation_generator)>`_
| Homepage: https://pypi.python.org/pypi/Sphinx
| Src: hg https://bitbucket.org/birkenfeld/sphinx/
| Pypi: https://pypi.python.org/pypi/Sphinx
| Docs: http://sphinx-doc.org/contents.html
| Docs: http://sphinx-doc.org/markup/code.html
| Docs: http://pygments.org/docs/lexers/
| Docs: http://thomas-cokelaer.info/tutorials/sphinx/rest_syntax.html
| Docs: https://github.com/yoloseem/awesome-sphinxdoc


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

  * Input:

    .. code:: bash

      _indexrst="$WORKON_HOME/src/westurner/tools/index.rst"
      e $_indexrst

      # with westurner/dotfiles.venv
      mkvirtualenv westurner
      we westurner tools; mkdir -p $_SRC
      git clone ssh://git@github.com/westurner/tools
      cdw; e index.rst    # ew index.rst

    https://github.com/westurner/tools/blob/master/index.rst

    https://raw.githubusercontent.com/westurner/tools/master/index.rst



  * Output:

    .. code:: bash

      cd $_WRD                        # cdwrd; cdw
      git status; make <tab>          # gitw status; makew <tab>
      make html singlehtml            # make docs
      web ./_build/html/index.html    # make open

      make gh-pages       # ghp-import -n -p ./_build/html/ -b gh-pages
      make push           # gitw push <origin> <destbranch>

    https://github.com/westurner/tools/blob/gh-pages/index.html

    https://westurner.org/tools/


    * RawGit:

      dev/test: https://rawgit.com/westurner/tools/gh-pages/index.html

      CDN: https://cdn.rawgit.com/westurner/tools/gh-pages/index.html

  * Output: *ReadTheDocs*:

    https://<projectname>.readthedocs.org/en/<version>/

    https://read-the-docs.readthedocs.org/en/latest/


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

            A link to :ref:`anchor <anchor-name>`.


.. index:: Tinkerer
.. _tinkerer:

Tinkerer
~~~~~~~~~
| Homepage: http://tinkerer.me/
| Src: https://github.com/vladris/tinkerer
| Docs: http://tinkerer.me/pages/documentation.html

Tinkerer is a very simple static blogging website generation tool
written in :ref:`Python` which extends :ref:`Sphinx`
and generates :ref:`HTML-` from :ref:`ReStructuredText`.

Static HTML pages generated with Tinkerer do not require
a serverside application, and can be easily hosted with GitHub Pages
or any other web hosting service.

* https://github.com/westurner/westurner.github.io/tree/source
  (``Makefile``, ``conf.py``)


.. index:: Backup Tools
.. _backup tools:

Backup Tools
==============

* https://en.wikipedia.org/wiki/Disk_cloning
* https://en.wikipedia.org/wiki/Disk_image#Virtualization
* https://en.wikipedia.org/wiki/List_of_archive_formats
* https://en.wikipedia.org/wiki/List_of_backup_software
* https://en.wikipedia.org/wiki/List_of_disk_cloning_software
* https://en.wikipedia.org/wiki/List_of_data_recovery_software
* https://en.wikipedia.org/wiki/Comparison_of_file_archivers
* https://en.wikipedia.org/wiki/Comparison_of_online_backup_services
* https://en.wikipedia.org/wiki/Comparison_of_file_synchronization_software


.. index:: Backup Ninja
.. _backup ninja:

Backup Ninja
~~~~~~~~~~~~~~
| Homepage: https://labs.riseup.net/code/projects/backupninja
| Src: git git://labs.riseup.net/backupninja.git
| Docs: https://labs.riseup.net/code/projects/backupninja/wiki
| Docs: https://labs.riseup.net/code/projects/backupninja/wiki/Usage

Backup Ninja is an open source backup utility
written in
``/etc/backup.d``

* BackupNinja supports :ref:`rdiff-backup`, :ref:`Duplicity`,
  and :ref:`rsync`.
* BackupNinja can create and burn CD/DVD images.
* BackupNinja can backup a number of relational databases
  (MySQL, PostgreSQL), maildirs, SVN repositories, Trac instances,
  and LDAP.

.. index:: Bup
.. _bup-:

bup
~~~~~~~~~~
| Homepage: https://bup.github.io/
| Src: git https://github.com/bup/bup
| Docs: https://github.com/bup/bup/blob/master/README.md
| Docs: https://bup.github.io/man.html
| Docs: https://github.com/bup/bup/blob/master/DESIGN

Bup (*backup*) is a backup system based on :ref:`git` packfiles
and rolling checksums.

    [Bup is a very] efficient backup system
    based on the `git packfile` format,
    providing fast incremental saves
    and global deduplication
    (among and within files, including virtual machine images).

* AFAIU, like :ref:`git`, Bup does not preserve file permissions,
  Access Control Lists, or extended attributes
  (though some archive formats and snapshot images do).


.. index:: Clonezilla
.. _clonezilla:

Clonezilla
~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Clonezilla
| DistroWatch: http://distrowatch.com/table.php?distribution=clonezilla

Clonezilla is an open source :ref:`Linux` distribution
which is bootable from a CD/DVD/USB (a LiveCD, LiveDVD, LiveUSB)
or PXE
which contains a number of tools
for disk imaging, disk cloning, filesystem backup and recovery;
and a server :ref:`Linux` distribution for serving disk images
to one or more computers over a LAN.

* Clonezilla contains :ref:`FSArchiver`, :ref:`partclone`,
  :ref:`partimage`, and :ref:`rsync`.
* :ref:`SystemRescueCD` also contains :ref:`partimage`.


.. index:: Duplicity
.. _duplicity:

Duplicity
~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Duplicity_(software)>`__
| Homepage: http://duplicity.nongnu.org/
| Docs: http://duplicity.nongnu.org/docs.html
| Docs: http://duplicity.nongnu.org/duplicity.1.html
| Docs: https://help.ubuntu.com/community/DuplicityBackupHowto
| Docs: https://wiki.archlinux.org/index.php/Duplicity

Duplicity is an open source incremental file directory backup utility
with GnuPG encryption, signatures, versions, and
a number of actions for redundantly storing backups.

* Duplicity can push offsite backups to/over a number of
  protocols and services (e.g. SSH/SCP/SFTP,
  S3, Google Cloud Storage, Rackspace Cloudfiles (OpenStack Swift)).
* Duplicity stores data with tar archives and :ref:`rdiff`
* :ref:`rdiff-backup` is similar to :ref:`duplicity`.


.. index:: FSArchiver
.. _fsarchiver:

FSArchiver
~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/FSArchiver
| Homepage: http://www.fsarchiver.org/
| Src:  http://sourceforge.net/projects/fsarchiver/files/fsarchiver-src/
| Download: http://sourceforge.net/projects/fsarchiver/files/fsarchiver-bin/
| Docs: http://www.fsarchiver.org/QuickStart
| Docs: http://www.fsarchiver.org/Live-backup
| Docs: http://www.fsarchiver.org/Attributes#SELinux_.28Security_Enhanced_Linux.29
| Docs: http://www.fsarchiver.org/Fsarchiver_vs_partimage
| Docs: http://www.sysresccd.org/Sysresccd-manual-en_LVM_Making-consistent-backups-with-LVM

FSAchiver is an open source filesystem backup (*disk cloning*) utility
which can preserve file permissions, labels, and extended attributes.

* FSArchiver can backup a filesysmet to a new or within an existing
  filesystem.
* FSArchiver has special support for LVM.
* FSArchiver supports password-based encryption.


.. index:: partclone
.. _partclone:

partclone
~~~~~~~~~~~~
| Homepage: http://partclone.org/
| Project: http://sourceforge.net/projects/partclone/
| Download: http://partclone.org/download/
| Src: git https://github.com/Thomas-Tsai/partclone
| Docs: http://partclone.org/help/
| Docs: http://partclone.org/usage/
| Docs: https://github.com/Thomas-Tsai/partclone/wiki

partclone is an open source utility for making
compressed backups of the used blocks of partitions
with each specific filesystem driver.

* :ref:`partclone` is similar to :ref:`partimage`.
* :ref:`Clonezilla` includes :ref:`partclone`.


.. index:: partimage
.. _partimage:

partimage
~~~~~~~~~~~
| Homepage: http://www.partimage.org/Main_Page
| Download: http://www.partimage.org/Download
| Src: http://sourceforge.net/projects/partimage/files/stable/
| Docs: http://www.partimage.org/Partimage-manual
| Docs: http://www.partimage.org/Supported-Filesystems

Partimage is an open source utility for making complete
sector-for-sector compressed backups of partitions
over the network or to a local device.

* :ref:`Clonezilla` includes :ref:`partimage`.
* SystemRescueCD includes :ref:`partimage` and :ref:`rsync`.
* partimage does not support EXT4 or BTRFS;
  for EXT4 and BTRFS support, see :ref:`fsarchiver`.


.. index:: rsync
.. _rsync:

rsync
~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Rsync
| Homepage: https://rsync.samba.org/
| Src: git git://git.samba.org/rsync.git
| Download: https://rsync.samba.org/download.html
| Docs: https://rsync.samba.org/examples.html

rsync is an open-source file backup utility
which can be used to make incremental backups
using file deltas over the network or the local system.

* rsync may appear to be stalled when it is actually
  calculating the full set of initial
  relative differences in order to minimize
  the amount of data transfer.

.. note:: rsync does not preserve file permissions by default.

   To preserve file permissions with rsync:

   .. code:: bash

        man rsync

        rsync -a    # rsync -rlptgoD
          rsync -r  # recursive (traverse into directories)
          rsync -l  # copy symlinks as links
          rsync -p  # preserve file permissions
          rsync -t  # preserve modification times
          rsync -g  # preserve group
          rsync -o  # preserve owner (requires superuser)
          rsync -D  # rsync --devices --specials
            rsync --devices   # preserve device files (requires superuser)
            rsync --specials  # preserve special files
        rsync -A  # preserve file ACLs
        rsync -X  # preserve file extended attributes

        rsync -aAX  # rsync -a -A -X

        rsync -v  # verbose
        rsync -P  # rsync --partial --progress
          rsync --partial     # keep partially downloaded files
          rsync --progress    # show *per-file* progress and xfer speed


.. note:: rsync is picky about paths and trailing slashes.

    .. code:: bash

        # setUp
        mkdir -p A/one B/one  # TODO
        echo 'A' > A/one; echo 'B' > B/one
        # tests
        rsync A B
        rsync A B/  --> B/A
        rsync A/ B
        rsync A/ B/


.. index:: rdiff
.. _rdiff:

rdiff
+++++++
| Wikipedia: https://en.wikipedia.org/wiki/Rsync#rdiff

rdiff is the open source relative delta algorithm of :ref:`rsync`.

* :ref:`rdiff-backup` is built on :ref:`rdiff`.
* :ref:`duplicity` is built on :ref:`rdiff`


.. index:: rsnapshot
.. _rsnapshot:

rsnapshot
+++++++++++
| Homepage: http://rsnapshot.org/
| Download: http://rsnapshot.org/download.html
| Download: http://rsnapshot.org/downloads/
| Src: git https://github.com/rsnapshot/rsnapshot
| Docs: http://rsnapshot.org/faq.html
| Docs: https://wiki.archlinux.org/index.php/Rsnapshot
| Docs: http://linux.die.net/man/1/rsnapshot

rsnapshot is an open source incremental file directory backup utility
built with :ref:`rsync`.



.. index:: rdiff-backup
.. _rdiff-backup:

rdiff-backup
~~~~~~~~~~~~~
| Homepage: http://www.nongnu.org/rdiff-backup/
| Download: http://download.savannah.gnu.org/releases/rdiff-backup/
| Project: https://savannah.nongnu.org/projects/rdiff-backup
| Src: svn svn://svn.savannah.nongnu.org/rdiff-backup/
| Docs: http://www.nongnu.org/rdiff-backup/rdiff-backup.1.html
| Docs: http://www.nongnu.org/rdiff-backup/docs.html
| Docs: http://www.nongnu.org/rdiff-backup/examples.html

rdiff-backup is an open source incremental file directory backup utility.

* Like :ref:`rsync`, rdiff-backup transmits file deltas
  instead of entire files.
* Unlike :ref:`rsync`, rdiff-backup manages reverting
  to previous revisions.


.. index:: SystemRescueCD
.. _systemrescuecd:

SystemRescueCD
~~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/SystemRescueCD
| Homepage: http://www.sysresccd.org/SystemRescueCd_Homepage
| Download: http://www.sysresccd.org/Download
| Project: http://sourceforge.net/projects/systemrescuecd/
| DistroWatch: http://distrowatch.com/table.php?distribution=systemrescue
| Docs: http://www.sysresccd.org/Online-Manual-EN

SystemRescueCD is a :ref:`Linux` distribution which is
bootable from a CD/DVD/USB (a LiveCD)
which contains a number of helpful utilities
for system maintenance.

* SystemRescueCD includes :ref:`partimage` and :ref:`rsync`.


.. index:: Standards
.. _standards:

Standards
============
| Docs: https://wrdrd.com/docs/consulting/knowledge-engineering#web-standards
| Docs: https://wrdrd.com/docs/consulting/knowledge-engineering#semantic-web-standards


.. index:: Cascading Style Sheets
.. index:: CSS
.. _css-:

CSS
~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Cascading_Style_Sheets
| Docs: https://wrdrd.com/docs/consulting/knowledge-engineering#css

CSS (*Cascading Style Sheets*) define the presentational
aspects of :ref:`HTML-` and a number of mobile and desktop
web framworks.

* CSS is designed to ensure separation of data and presentation.
  With javascript, the separation is then data, code, and presentation.




.. index:: Filesystem Hierarchy Standard
.. _fhs:

Filesystem Hierarchy Standard
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
| Website: http://www.linuxfoundation.org/collaborate/workgroups/lsb/fhs

The Filesystem Hierarchy Standard (*FHS*) is a well-worn industry-supported
system file naming structure.

* :ref:`Linux` distributions like
  :ref:`Ubuntu` and :ref:`Fedora` implement
  a Filesystem Hierarchy.

* Likewise, :ref:`virtualenv` and :ref:`Venv` implement
  a filesystem hierarchy:

  | Docs: https://westurner.org/dotfiles/venv#venv-paths

* :ref:`Docker` (and many LiveCDs) layer filesystem hierarchies
  with e.g. UnionFS, AUFS, and BTRFS filesystems.


.. index:: HTTP
.. _http-:

HTTP
~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/HTTP
| Docs: https://wrdrd.com/docs/consulting/knowledge-engineering#http
| Docs: https://wrdrd.com/docs/consulting/knowledge-engineering#http2


.. index:: HTTPS
.. _https--:

HTTPS
++++++
| Wikipedia: https://en.wikipedia.org/wiki/HTTPS
| Docs: https://wrdrd.com/docs/consulting/knowledge-engineering#https


.. index:: HTML
.. _html-:

HTML
~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/HTML
| Docs: https://wrdrd.com/docs/consulting/knowledge-engineering#html5


.. index:: JSON
.. _json-:

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

* See also:
  https://wrdrd.com/docs/consulting/knowledge-engineering#json


.. index:: JSONLD
.. index:: JSON-LD
.. _json-ld-:

JSON-LD
~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/JSON-LD
| Homepage: http://json-ld.org
| Docs: http://json-ld.org/playground/
| Docs: https://wrdrd.com/docs/consulting/knowledge-engineering#json-ld

JSON-LD is a web standard for **Linked Data** in :ref:`JSON <json->`.

An example from the *JSON-LD Playground* (`<http://goo.gl/xxZ410>`__):

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


MessagePack (*msgpack*) is a data interchange format
with implementations in many languages.

* :ref:`MsgPack` is a `Distributed Computing Protocol`
  https://wrdrd.com/docs/consulting/knowledge-engineering#distributed-computing-protocols
* :ref:`Salt` serializes messages with :ref:`MsgPack` by default.


.. index:: Vim
.. _vim:

Vim
====
| Wikipedia: `<https://en.wikipedia.org/wiki/Vim_(text_editor)>`__
| Homepage: http://www.vim.org/
| Docs: http://www.vim.org/docs.php
| Src: hg https://vim.googlecode.com/hg/


* https://github.com/scrooloose/nerdtree
* https://github.com/westurner/dotvim

Vim browser extensions:

* :ref:`Vimium` (Chrome)
* :ref:`Vimperator` (Firefox)
* :ref:`Wasavi` (Chrome, Opera, Firefox)

*****

`^top^ <#>`__
