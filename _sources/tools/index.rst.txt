

.. index:: westurner/tools
.. index:: Tools
.. _tools:

================
Tools
================

| Docs: https://westurner.github.io/tools/
| Src: https://github.com/westurner/tools

See Also: https://westurner.github.io/wiki/projects#tools


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
| Docs: https://docs.continuum.io/anaconda/

Anaconda is a maintained distribution of :ref:`Conda`
packages for many languages; especially :ref:`Python`.

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


.. index:: BUILD
.. _build:

BUILD
~~~~~~
| Docs: https://pantsbuild.github.io/build_files.html
| Docs: https://pantsbuild.github.io/build_dictionary.html
| Docs: https://pantsbuild.github.io/options_reference.html

A ``BUILD`` file describes a :ref:`Pants Build` build.


.. index:: Cabal
.. _cabal:

Cabal
~~~~~~
| Homepage: https://www.haskell.org/cabal/
| Docs: https://hackage.haskell.org/
| Docs: https://www.haskell.org/cabal/users-guide/
| Docs: https://www.haskell.org/cabal/release/cabal-latest/doc/API/Cabal/

Cabal is a package manager for :ref:`Haskell` packages.

Hackage is the community Cabal package index: https://hackage.haskell.org/


.. index:: Conda Package
.. index:: Conda
.. _conda:

Conda
~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Conda_(package_manager)>`__
| Docs: https://conda.io/en/latest/
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
  *OR* a :ref:`VCS <vcs>` URI and revision; and/or custom ``build.sh`` or
  ``build.bat`` scripts.
* ``conda skeleton`` can automatically create conda recipes
  from ``PyPI`` (Python), ``CRAN`` (R), and ``CPAN`` (Perl)
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

- https://www.pydanny.com/building-conda-packages-for-multiple-operating-systems.html
- https://github.com/conda/conda-recipes/tree/master/cookiecutter
- https://binstar.org/pydanny/cookiecutter

.. code:: bash

    conda install -c pydanny cookiecutter   # OR pip install cookiecutter

The conda-forge custom channel packages are built with :ref:`continuous
integration` on multiple platforms:

* https://conda-forge.github.io/
* https://anaconda.org/conda-forge

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



See also: :ref:`Anaconda`, :ref:`conda-forge` (:ref:`conda-smithy`)


.. index:: conda-forge
.. _conda-forge:

conda-forge
~~~~~~~~~~~~~~~~~
| Homepage: https://conda-forge.github.io/
| Src: https://github.com/conda-forge
| Src: https://github.com/conda-forge/feedstocks
| Src: https://github.com/conda-forge/feedstocks/tree/master/feedstocks
| Src: https://github.com/conda-forge/staged-recipes
| DockerHub: https://hub.docker.com/r/condaforge/linux-anvil
| Docs: https://conda-forge.github.io/docs/
| Docs: https://conda-forge.github.io/docs/recipe.html

* https://conda-forge.github.io/#add_recipe

  * A. fork: https://github.com/conda-forge/staged-recipes

    * meta.yaml https://github.com/conda-forge/staged-recipes/blob/master/recipes/example/meta.yaml

  * B. conda-smithy

  * meta.yaml

    * Docs: numpy x.x: https://conda-forge.github.io/docs/meta.html#building-against-numpy

  * circle.yml

    * https://github.com/conda-forge/staged-recipes/blob/master/circle.yml

  * .travis.yml

    * https://github.com/conda-forge/staged-recipes/blob/master/.travis.yml

  * appveyor.yml

    * https://github.com/conda-forge/staged-recipes/blob/master/appveyor.yml

  * conda-forge.yml
  * run_docker_build.sh
    https://github.com/conda-forge/staged-recipes/blob/master/scripts/run_docker_build.sh
  * bootstrap-obvious-ci-and-miniconda.py
    https://github.com/conda-forge/conda-smithy/blob/master/bootstrap-obvious-ci-and-miniconda.py

.. code:: bash

    # create a conda package recipe from a pypi package
    cd $VIRTUAL_ENV/src
    conda skeleton pypi jupyterthemes
    ls -ld jupyterthemes/
    edit jupyterthemes/meta.yaml
    # - git repo tags || pypi releases

    # create a conda-forge feedstock from a conda recipe
    ## https://github.com/conda-forge/conda-smithy#making-a-new-feedstock
    cd $VIRTUAL_ENV/src
    ls -ld jupyterthemes
    conda-smithy init jupyterhemes
    ls jupyterthemes-feedstock/

    # build a conda-forge feedstock with docker
    # FROM condaforge/linux-anvil
    cat ./scripts/run_docker_build.sh
    ./scripts/run_docker_build.sh
    ./ci_support/run_docker_build.sh


.. index:: conda-smithy
.. _conda-smithy:

conda-smithy
~~~~~~~~~~~~~~
| Src: https://github.com/conda-forge/conda-smithy
| Docs: https://github.com/conda-forge/conda-smithy#making-a-new-feedstock


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
| Homepage: https://fedoraproject.org/wiki/DNF
| Homepage: https://fedoraproject.org/wiki/Features/DNF
| Src: git https://github.com/rpm-software-management/dnf
| Docs: https://dnf.readthedocs.io/en/latest/
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
* :ref:`dnf` supports **Delta** RPM packages (DRPM),
  which often significantly reduce the required amount of network
  transfer required to regularly retrieve and upgrade to
  the latest repository packages.


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
  stored in Gentoo :ref:`Portage`.
* :ref:`Portage` packages are built from ebuilds.
* The :ref:`emerge` :ref:`Portage` command installs ebuilds.


.. index:: emerge
.. _emerge:

emerge
~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Portage_(software)#Emerge>`__
| Homepage: https://wiki.gentoo.org/wiki/Portage#emerge
| Src: git https://github.com/gentoo/portage
| Docs: https://wiki.gentoo.org/wiki/Project:Package_Manager_Specification
| Docs: https://projects.gentoo.org/pms/6/pms.html

``emerge`` is the primary CLI tool used for installing
packages built from :ref:`ebuilds <ebuild>` [from :ref:`Portage`].


.. index:: fpm
.. _fpm:

fpm
~~~~~
| Wikipedia:
| Src: https://github.com/jordansissel/fpm
| Docs: https://github.com/jordansissel/fpm/wiki/
| Docs: https://github.com/jordansissel/fpm/wiki/PackageMakeInstall

fpm (*effing package management*) is a tool for building many types
of software packages from many other types of software packages
(e.g. :ref:`DEB`. :ref:`RPM`, :ref:`Python Packages`);
often more easily than working with the actual package manager.

* fpm package source types include: dir rpm gem python empty tar deb cpan npm osxpkg pear pkgin virtualenv zip.
* fpm target package types include: rpm deb solaris puppet dir osxpkg p5p puppet sh tar zip


.. index:: Brew
.. index:: Homebrew
.. _homebrew:

Homebrew
~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Homebrew_(package_management_software)>`__
| Homepage: https://brew.sh/
| Src: https://github.com/Homebrew/brew

Homebrew is a package manager (``brew``) for :ref:`OSX`.


.. index:: NPM
.. index:: Node Package Manager
.. _npm:

NPM
~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Npm_(software)>`__
| Homepage: https://www.npmjs.org/
| Src: https://github.com/npm/npm
| Docs: https://docs.npmjs.com/files/package.json#files

NPM is a :ref:`Javascript` package manager created for :ref:`Node.js`.

* an NPM package is defined by a ``package.json`` :ref:`JSON` file.
* NPM packages are installed with the ``npm`` CLI utility.
* :ref:`Bower` builds upon NPM.


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


.. index:: PEX
.. _pex:

PEX
~~~~~
| Homepage: https://pex.readthedocs.io/
| Src: https://github.com/pantsbuild/pex
| PyPI: https://pypi.python.org/pypi/pex
| Docs: https://pex.readthedocs.io/en/stable/

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
| Homepage: https://wiki.gentoo.org/wiki/Project:Portage
| Docs: https://wiki.gentoo.org/wiki/Project:Package_Manager_Specification
| Docs: https://projects.gentoo.org/pms/6/pms.html

Portage is a package management and repository system
written in :ref:`Python` initially just for :ref:`Gentoo` :ref:`Linux`.

* :ref:`Emerge` installs :ref:`ebuilds <ebuild>` from :ref:`portage`.


.. index:: Ports
.. _ports:

Ports
~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Ports_collection
| Homepage: https://www.freebsd.org/ports/


A Ports collection contains *Sources* (e.g. archived releases and patch
sets)
and :ref:`Makefiles <make>`
designed to compile software :ref:`packages`
for particular :ref:`operating systems <operating system>`
distributions' kernel and standard libraries
usually for a particular platform.


.. index:: RPM
.. _rpm:

RPM
~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/RPM_Package_Manager

RPM (*RPM Package Manager*, :ref:`RedHat` *Package Manager*)
is a :ref:`package` format and a set of commandline utilities
written in :ref:`C` and :ref:`Perl`.

* RPM packages can be installed with ``rpm``,
  :ref:`yum`, :ref:`dnf`.
* RPM pacage can be built with tools like ``rpmbuild`` and ``fpm``
* Python packages can be built into RPM packages with
  :ref:`setuptools' <setuptools>` ``bdist_rpm``, ``fpm``
* List contents of RPM packages (archives) with e.g. ``less`` and
  ``lesspipe``::

   less ~/path/to/local.rpm   # requires lesspipe to be configured

* RPM Packages are served by and retrieved from
  repositories by tools like :ref:`yum` and :ref:`dnf`:

  * Local: directories of :ref:`RPM` packages and metadata
  * Network: :ref:`HTTP <http->`, :ref:`HTTPS <https-->`, :ref:`RSYNC`, FTP
  * :ref:`dnf` supports **Delta** RPM packages (DRPM),
    which often significantly reduce the required amount of network
    transfer required to regularly retrieve and upgrade to
    the latest repository packages.

.. note:: There's not yet a :ref:`debtorrent` for
   :ref:`RPM`, :ref:`YUM`, :ref:`DNF`.


.. index:: Egg
.. index:: Python Egg
.. index:: Python Packages
.. _python packages:

Python Packages
~~~~~~~~~~~~~~~~~~~~~~~~
| Homepage: https://pypi.python.org/pypi
| Download: https://pypi.python.org/simple/
| Docs: https://packaging.python.org/en/latest/
| Docs: https://packaging.python.org/en/latest/current/
| Docs: https://packaging.python.org/en/latest/distributing/
| Docs: https://packaging.python.org/en/latest/peps.html
| Docs: https://packaging.python.org/en/latest/projects.html
| Docs: https://packaging.python.org/en/latest/specifications/
| Docs: https://pypaio.readthedocs.io/en/latest/roadmap/

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

.

* PyPA Tool Recommendations

  * | Docs: https://packaging.python.org/en/latest/current

* PyPA Python Package PEPs

  * | Docs: https://packaging.python.org/en/latest/peps.html

* PyPA Projects List

  * | Docs: https://packaging.python.org/en/latest/projects.html


.. note:: :ref:`JSON-LD-` for package metadata and environment build
   metadata could be helpful.

   - https://github.com/pypa/interoperability-peps/issues/31


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
| Src: https://github.com/pypa/setuptools
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
| Docs: https://pip.readthedocs.io/en/latest/
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
   https://legacy.python.org/dev/peps/pep-0476/#python-versions

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
| Src: https://github.com/pypa/pypi-legacy


PyPI-legacy is the original Python Package Index.
PyPI is now powered by :ref:`Warehouse`


.. index:: Warehouse
.. _warehouse:

Warehouse
++++++++++
| Homepage: https://warehouse.python.org/
| Src: https://github.com/pypa/warehouse
| Docs: https://warehouse.readthedocs.io/en/latest/


Warehouse is the "Next Generation Python Package Repository".

All packages uploaded to :ref:`PyPI` are also available from Warehouse.


.. index:: Devpi
.. _devpi:

Devpi
++++++++
| Homepage: https://doc.devpi.net/
| Src: https://github.com/devpi/devpi
| Issues: https://github.com/devpi/devpiissues
| PyPI: https://pypi.python.org/pypi/devpi-server
| PyPI: https://pypi.python.org/pypi/devpi-web
| PyPI: https://pypi.python.org/pypi/devpi-client
| Docs: https://doc.devpi.net/latest/

Devpi is a server and client solution for :ref:`Python package <python
packages>` mirroring, hosting, and testing.


.. index:: Python Wheel
.. index:: Wheel
.. _wheel:

Wheel
++++++
| Docs: https://legacy.python.org/dev/peps/pep-0427/
| Docs: https://wheel.readthedocs.io/en/latest/
| Src: https://github.com/pypa/wheel
| PyPI: https://pypi.python.org/pypi/wheel


* Wheel is a newer, PEP-based standard (``.whl``) with a different
  metadata format, the ability to specify (JSON) digital signatures
  for a package within the package, and a number
  of additional speed and platform-consistency advantages.
* Wheels can be uploaded to PyPI.
* Wheels are generally faster than traditional Python packages.

Packages available as wheels are listed at `<https://pythonwheels.com/>`__.


.. index:: Ruby Gem
.. index:: RubyGems
.. _rubygems:

RubyGems
~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/RubyGems
| Homepage: https://rubygems.org/
| Docs: https://guides.rubygems.org/
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
| Homepage: https://www.nongnu.org/cvs/
| Homepage: https://savannah.nongnu.org/projects/cvs
| Wikipedia: https://en.wikipedia.org/wiki/Concurrent_Versions_System
| Docs: https://www.nongnu.org/cvs/#documentation

CVS (``cvs``) is a centralized version control system (VCS) written in :ref:`C`.

CVS predates most/many other VCS.


.. index:: SVN
.. index:: Subversion
.. _subversion:

svn: Subversion
~~~~~~~~~~~~~~~~
| Homepage: https://subversion.apache.org/
| Wikipedia: https://en.wikipedia.org/wiki/Apache_Subversion
| Docs: https://subversion.apache.org/docs/
| Docs: https://subversion.apache.org/quick-start
| Src: svn https://svn.apache.org/repos/asf/subversion/trunk
| Src: https://github.com/apache/subversion

Apache Subversion (``svn``) is a centralized revision control system (VCS)
written in :ref:`C`.

To checkout a revision of a repository with ``svn``:

.. code:: bash

   svn co https://svn.apache.org/repos/asf/subversion/trunk subversion


.. index:: bzr
.. index:: Bazaar
.. _bazaar:

bzr: Bazaar
~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/GNU_Bazaar
| Homepage: https://bazaar.canonical.com/en/
| Homepage: https://launchpad.net/bzr
| Docs: http://doc.bazaar.canonical.com/en/
| Docs: http://doc.bazaar.canonical.com/latest/en/mini-tutorial/index.html
| Src: bzr lp:bzr

GNU Bazaar (``bzr``) is a distributed revision control system (DVCS, RCS, VCS)
written in :ref:`Python` and :ref:`C`.

https://launchpad.net hosts Bazaar repositories;
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
| Src: https://github.com/git/git
| Homepage: https://git-scm.com/
| Docs: https://git-scm.com/documentation
| Docs: https://git-scm.com/book/en/
| Docs: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
| Docs: https://github.com/skwp/git-workflows-book
| Docs: https://github.com/skwp/git-workflows-book#the-index
| Docs: https://learnxinyminutes.com/docs/git/
| Docs: https://learngitbranching.js.org/
| Docs: https://www.leshenko.net/p/ugit/
| Docs: https://github.com/westurner/dotfiles/blob/develop/etc/.gitconfig

Git (``git``) is an open source distributed version control system for tracking a branching
and merging repository of file revisions written in :ref:`C` (DVCS, VCS,
RCS).

To clone a repository with ``git``:

.. code:: bash

  git clone https://github.com/git/git
  cd ./git
  git status; git remote -av; git reflog;

  git help help; git help reflog


- :ref:`jj` auto-saves and is compatible with git


.. index:: GitFlow
.. _gitflow:

GitFlow
~~~~~~~~~
| Src: https://github.com/nvie/gitflow
| Docs: https://nvie.com/posts/a-successful-git-branching-model/
| Docs: https://github.com/nvie/gitflow/wiki
| Docs: https://github.com/nvie/gitflow/wiki/Command-Line-Arguments
| Docs: https://github.com/nvie/gitflow/wiki/Config-values

GitFlow is a named branch workflow for :ref:`git`
with ``master``, ``develop``, ``feature``, ``release``, ``hotfix``,
and ``support`` branches (``git flow``).

Gitflow branch names and prefixes are configured in ``.git/config``;
the defaults are:


.. table:: GitFlow Branch Names
   :class: table-striped table-responsive

   +--------------------+-------------------------------------------------------------------------------+
   | **Branch Name**    | **Description**                                                               |
   |                    | (and `Code Labels <https://westurner.github.io/wiki/workflow#code-labels>`__) |
   +--------------------+-------------------------------------------------------------------------------+
   | ``master``         | Stable trunk (latest release)                                                 |
   +--------------------+-------------------------------------------------------------------------------+
   | ``develop``        | Development main line                                                         |
   +--------------------+-------------------------------------------------------------------------------+
   | ``feature/<name>`` | New features for the next release (e.g. ``ENH``, ``PRF``)                     |
   +--------------------+-------------------------------------------------------------------------------+
   | ``release/<name>`` | In-progress release branches (e.g. ``RLS``)                                   |
   +--------------------+-------------------------------------------------------------------------------+
   | ``hotfix/<name>``  | Fixes to merge to both ``master`` and ``develop``                             |
   |                    | (e.g. ``BUG``, ``TST``, ``DOC``)                                              |
   +--------------------+-------------------------------------------------------------------------------+
   | ``support/<name>`` | "What is the 'support' branch?"                                               |
   |                    |                                                                               |
   |                    | https://github.com/nvie/gitflow/wiki/FAQ                                      |
   +--------------------+-------------------------------------------------------------------------------+

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

  ## release/0.1.0
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

GitFlow is a named branch workflow for :ref:`git`
with ``master``, ``develop``, ``feature``, ``release``, ``hotfix``,
and ``support`` branches (``git flow``).

HubFlow is a fork of :ref:`GitFlow`
that adds useful commands for working with :ref:`Git` and
GitHub **pull requests**.

HubFlow branch names and prefixes are configured in ``.git/config``;
the defaults are:


.. table:: HubFlow Branch Names
   :class: table-striped table-responsive

   +--------------------+-------------------------------------------------------------------------------+
   | **Branch Name**    | **Description**                                                               |
   |                    | (and `Code Labels <https://westurner.github.io/wiki/workflow#code-labels>`__) |
   +--------------------+-------------------------------------------------------------------------------+
   | ``master``         | Stable trunk (latest release)                                                 |
   +--------------------+-------------------------------------------------------------------------------+
   | ``develop``        | Development main line                                                         |
   +--------------------+-------------------------------------------------------------------------------+
   | ``feature/<name>`` | New features for the next release (e.g. ``ENH``, ``PRF``)                     |
   +--------------------+-------------------------------------------------------------------------------+
   | ``release/<name>`` | In-progress release branches (e.g. ``RLS``)                                   |
   +--------------------+-------------------------------------------------------------------------------+
   | ``hotfix/<name>``  | Fixes to merge to both ``master`` and ``develop``                             |
   |                    | (e.g. ``BUG``, ``TST``, ``DOC``)                                              |
   +--------------------+-------------------------------------------------------------------------------+

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

  ## release/0.1.0
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
.. _hg:
.. _mercurial:

hg: Mercurial
~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Mercurial
| Homepage: https://www.mercurial-scm.org/
| Docs: https://www.mercurial-scm.org/guide
| Docs: https://book.mercurial-scm.org/
| Src: hg https://www.mercurial-scm.org/repo/hg
| Src: hg http://hg.intevation.org/mercurial

Mercurial (``hg``) is a distributed revision control system
written in :ref:`Python` and :ref:`C` (DVCS, VCS, RCS).

To clone a repository with ``hg``:

.. code:: bash

   hg clone https://www.mercurial-scm.org/repo/hg


.. index:: jujutsu
.. index:: jj
.. _jj:

jj: jujutsu
~~~~~~~~~~~~
| Src: https://github.com/martinvonz/jj
| Docs: https://martinvonz.github.io/jj/latest/
| Docs: https://martinvonz.github.io/jj/latest/cli-reference/

`jj` (jujutsu) is an open source :ref:`Version Control System` that works with
:ref:`git`.

- jj auto-saves changes

  From the jj docs > Concepts > Working Copy :
  https://martinvonz.github.io/jj/latest/working-copy/ :

     Unlike most other VCSs, Jujutsu will automatically create commits
     from the working-copy contents when they have changed. Most jj
     commands you run will commit the working-copy changes if they have
     changed. The resulting revision will replace the previous
     working-copy revision.


.. index:: GitHub
.. _github: 

GitHub
=======
| Wikipedia: https://en.wikipedia.org/wiki/GitHub
| Web: https://github.com/
| Src: https://github.com/github
| Docs: https://docs.github.com/en
| Docs: https://docs.github.com/en/get-started/quickstart/git-and-github-learning-resources
| Docs: https://docs.github.com/en/get-started/quickstart/github-glossary
| Docs: https://skills.github.com/
| Docs: https://github.com/skills
| Docs: **https://github.com/skills/introduction-to-github**
| Docs: https://github.com/skills/communicate-using-markdown
| StatusPage: https://www.githubstatus.com/

:ref:`Git` repos, Issues, Pull Requests, Wikis, Pages, Actions, Project Boards, Webhooks

- https://github.com/github/choosealicense.com
- https://docs.github.com/en/get-started/quickstart/hello-world
- https://docs.github.com/en/get-started/quickstart/github-flow
- :ref:`hubflow` is a fork of :ref:`gitflow` for use with GitHub Pull requests
- https://github.com/topics/awesome
- https://github.com/devspace/awesome-github-templates
- https://github.com/stevemao/github-issue-templates/blob/master/must-open-issue-before-pr/PULL_REQUEST_TEMPLATE.md
- https://github.com/stevemao/github-issue-templates/blob/master/checklist2/PULL_REQUEST_TEMPLATE.md
- https://github.com/abhisheknaiidu/awesome-github-profile-readme


.. index:: GitHub CI 
.. index:: GitHub Actions
.. _github-actions:

GitHub Actions
~~~~~~~~~~~~~~~
| Web: https://github.com/marketplace?type=actions
| Src: https://github.com/actions
| Src: https://github.com/actions/runner
| Src: https://github.com/actions/runner-images
| Src: https://github.com/actions/deploy-pages
| Src: https://github.com/actions/upload-pages-artifact
| Src: https://github.com/actions/upload-artifact
| Src: https://github.com/actions/upload-release-asset
| Src: https://github.com/softprops/action-gh-release
| Docs: https://docs.github.com/en/actions
| Docs: https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions
| Docs: https://docs.github.com/en/actions/quickstart#creating-your-first-workflow
| Docs: https://github.com/actions/starter-workflows


- Src: https://github.com/nektos/act

  - Run GitHub Actions locally; without GitHub Runner


.. index:: GitHub Classroom
.. _github-classroom:

GitHub Classroom
==================
| Web: https://classroom.github.com/
| Web: https://education.github.com/
| Docs: https://docs.github.com/en/education/manage-coursework-with-github-classroom/get-started-with-github-classroom/about-github-classroom#github-classroom-features

- :ref:`otter-grader` and :ref:`nbgrader` autograde :ref:`Jupyter` notebooks
  (in containers for safety)
  and can post grades to an LMS / LRS



.. index:: GitLab
.. _gitlab:

GitLab
========
| Wikipedia: https://en.wikipedia.org/wiki/GitLab
| Web: https://gitlab.com/
| Src: https://gitlab.com/gitlab-org
| Src: https://gitlab.com/gitlab-org/gitlab
| Issues: https://gitlab.com/groups/gitlab-org/-/issues
| Docs: https://docs.gitlab.com/
| Docs: https://docs.gitlab.com/ee/user/markdown.html#where-you-can-use-gitlab-flavored-markdown
| Docs: https://docs.gitlab.com/ee/install/install_methods.html
| Docs: https://about.gitlab.com/direction/maturity/#package
| Docs: https://about.gitlab.com/handbook/
| Docs: https://about.gitlab.com/handbook/markdown-guide/
| Docs: https://about.gitlab.com/company/kpis/
| Docs: https://about.gitlab.com/company/okrs/
| StatusPage: https://status.gitlab.com/

- GitLab is written in :ref:`Ruby`, :ref:`Go`, and :ref:`JS`.


.. index:: GitLab CI
.. _gitlab-ci:

GitLab CI
~~~~~~~~~~~~~~~
| Docs: https://docs.gitlab.com/ee/ci/yaml/
| Docs: https://about.gitlab.com/competition/github/

GitLab CI is an open source :ref:`Continuous Integration` system
which runs commands in containers per tasks defined in a build :ref:`YAML` file
on project events like `git push`, new Pull Request branch, new Issue.

- `gitlab-ci.yml`
- GitLab CI precedes :ref:`GitHub`. Travis-CI precedes GitLab CI and :ref:`GitHub Actions`. Bitten by Edgewall (Trac) precedes Travis CI.



.. index:: Gitea 
.. _gitea: 

Gitea
=======
| Wikipedia: https://en.wikipedia.org/wiki/Gitea
| Web: https://gitea.io/en-us/
| Src: https://github.com/go-gitea/gitea
| Docs: https://docs.gitea.io/en-us/
| Docs: https://try.gitea.io/api/swagger

Gitea is an open source project forge site written in :ref:`Go`;
with :ref:`Git` repositories (repos), *Wiki* repos, Issues, Pull Requests; and
:ref:`Continuous Integration` to run the build script (:ref:`YAML`) on events like `git push`, `new_issue`, and `new_pr`;

:ref:`Package` repositories for released build artifacts,
:ref:`Container` repository

- https://docs.gitea.io/en-us/usage/automatically-linked-references/

- https://docs.gitea.io/en-us/installation/install-with-docker-rootless/
- https://docs.gitea.io/en-us/administration/https-setup/#using-acme-default-lets-encrypt
- https://docs.gitea.io/en-us/installation/upgrade-from-gitea/
- https://docs.gitea.io/en-us/administration/command-line/
- https://docs.gitea.io/en-us/usage/repo-mirror/
- https://github.com/maxkratz/github2gitea-mirror
- https://docs.gitea.io/en-us/usage/packages/overview/#supported-package-managers
- https://docs.gitea.io/en-us/usage/packages/container/
- https://docs.gitea.io/en-us/usage/packages/conda/
- https://docs.gitea.io/en-us/usage/packages/pypi/
- https://docs.gitea.io/en-us/usage/packages/npm/
- https://docs.gitea.io/en-us/administration/external-renderers/#example-jupyter-notebook
- Gitea supports file-attachments in issues, pull requests, and releases (tagged git commits)
- Forgejo is a fork of Gitea, like Gitea is a fork of Gogs (which is a clone of GitHub)
  - https://github.com/topics/forgejo
  - https://codeberg.org/forgejo/forgejo


.. index:: Gitea Actions
.. _gitea actions:

Gitea Actions
~~~~~~~~~~~~~~~
- Src: https://github.com/go-gitea/gitea/tree/main/modules/actions
- Src: https://github.com/go-gitea/gitea/tree/main/services/actions
- Src: https://gitea.com/gitea/act_runner
- Docs: https://docs.gitea.io/en-us/usage/usage/actions/overview/
- Docs: https://docs.gitea.io/en-us/usage/usage/actions/quickstart/#set-up-runner
- Docs: https://docs.gitea.io/en-us/usage/usage/actions/comparison/ w/ :ref:`GitHub Actions`
- Docs: https://blog.gitea.io/2023/03/hacking-on-gitea-actions/



.. index:: Project Templates
.. _project templates:

Project Templates
===================

* :ref:`cookiecutter` (Python, [...])
* :ref:`yeoman` (JS, [...])
* :ref:`jinja2` (:ref:`salt`, :ref:`ansible`
  :ref:`configuration management`


.. index:: Exemplar Projects
.. _exemplar projects:

Exemplar Projects
~~~~~~~~~~~~~~~~~~~~~~
* https://www.python.org/dev/peps/

  | "PEP 0 -- Index of Python Enhancement Proposals (PEPs)"

  * https://www.python.org/dev/peps/pep-0012/

    | "PEP 0012 -- Sample :ref:`reStructuredText` PEP Template" (:ref:`Python`)

* https://github.com/ipython/ipython/wiki/IPEPs:-IPython-Enhancement-Proposals

  | "IPEPs: IPython Enhancement Proposals"

  * https://github.com/ipython/ipython/wiki/IPEP-0%3A-IPEP-Template

    | "IPEP 0: IPEP Template" (:ref:`IPython`, :ref:`Jupyter`)

  * https://github.com/jupyter/roadmap

* github.com/westurner/wiki: a GitHub Sphinx Wiki

  | Home: https://westurner.github.io/wiki/
  | Wiki: https://github.com/westurner/wiki/wiki
  | Src: https://github.com/westurner/wiki
  | Src: https://github.com/westurner/wiki.wiki.git
  | Issues: https://github.com/westurner/wiki/issues

  .. code:: bash

      make help
      # - build    the docs w/ sphinx
      # - push     to both branches
      # - gh-pages from eg _build/html, _build/singlehtml
      make docs push gh-pages

* github.com/rdfjs/rdfjs.org: a GitHub Project

  | Home: https://github.com/rdfjs/rdfjs.org
  | Wiki: https://github.com/rdfjs/rdfjs.org/wiki
  | Src: https://github.com/rdfjs/rdfjs.org
  | Src: https://github.com/rdfjs/rdfjs.org.wiki.git
  | Issues: https://github.com/rdfjs/rdfjs.org/issues

  * https://github.com/rdfjs/rdfjs.org/wiki/Meetings

seeAlso:

* https://wrdrd.github.io/docs/consulting/software-development#agile
* https://wrdrd.github.io/docs/consulting/team-building#the-same-page


.. index:: cookiecutter
.. _cookiecutter:

cookiecutter
~~~~~~~~~~~~~
| Homepage: https://github.com/audreyr/cookiecutter
| Src: git https://github.com/audreyr/cookiecutter
| PyPI: https://pypi.python.org/pypi/cookiecutter
| Docs: https://cookiecutter.readthedocs.io/en/latest/
| Docs: https://cookiecutter.readthedocs.io/en/latest/usage.html
| Docs: https://cookiecutter.readthedocs.io/en/latest/tutorials.html#create-your-very-own-cookiecutter

Cookiecutter creates projects (files and directories) from
project templates written in :ref:`Jinja2`
for projects written in :ref:`Python` and other languages.

* https://cookiecutter.readthedocs.io/en/latest/readme.html#available-cookiecutters

  List of Cookiecutter generators

* https://github.com/audreyr/cookiecutter-pypackage

  Cookiecutter template for a :ref:`Python Package <Python packages>`
  (e.g. ``setup.py``, ``docs/``, ``README.rst``)

* https://github.com/pydanny/cookiecutter-django

  Cookiecutter template for a Django project
  w/ Bootstrap, AngularJS, :ref:`Docker`,

  * see also: https://github.com/xenith/django-base-template

* https://github.com/pydanny/cookiecutter-djangopackage

  Cookiecutter template for reusable Django packages (**installable
  apps**).

* https://github.com/openstack-dev/cookiecutter

  Cookiecutter template for :ref:`OpenStack`
  :ref:`Python Package <Python packages>`
  projects
  (\* :ref:`pip` \*, pbr, tox, :ref:`sphinx`)

* https://github.com/openstack-dev/specs-cookiecutter

  Cookiecutter template for :ref:`OpenStack` specs projects
  (pbr, tox, :ref:`sphinx`)




.. index:: yeoman
.. _yeoman:

yeoman
~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Yeoman_(computing)>`__
| Homepage: https://yeoman.io/
| Src: git https://github.com/yeoman/yeoman
| Src: https://github.com/yeoman
| NPM: https://www.npmjs.com/package/yo
| NPMPkg: ``yo``
| Docs: https://yeoman.io/learning/
| Docs: https://yeoman.io/codelab/
| Docs: https://yeoman.io/authoring
| Docs: https://yeoman.io/learning/resources.html

* https://github.com/yeoman/generator-generator

  Generate a Yeoman generator (``./authoring``).

* https://yeoman.io/generators/

  List of Yeoman generators

  * https://github.com/yeoman/generator-angular

    AngularJS 1 Yeoman generator (:ref:`bower`, karma tests,
    :ref:`CoffeeScript`, :ref:`TypeScript` )

  * https://github.com/diegonetto/generator-ionic

    Apache Cordova mobile app w/ Ionic (AngularJS 1, :ref:`grunt`)

  * https://stackoverflow.com/questions/29649578/available-yeoman-generator-for-angular-2

    AngularJS 2 Yeoman generators (:ref:`TypeScript`)

  * https://github.com/kriasoft/react-starter-kit

    React.js, Express, Flux, ES6+, JSX, Babel, PostCSS, Webpack, BrowserSync
    (:ref:`Node.js`)

  * https://github.com/yeoman/generator-polymer

    Polymer Web Components (:ref:`gulp`)



.. index: Languages
.. _languages:

Languages
=======================


.. index: Programming Languages
.. _programming languages:
.. _programming language:

Programming Languages
~~~~~~~~~~~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Programming_language
| WikipediaCategory: https://en.wikipedia.org/wiki/Category:Programming_languages
| WikipediaCategory: https://en.wikipedia.org/wiki/Category:Programming_language_classification


* https://en.wikipedia.org/wiki/Von_Neumann_programming_languages
* https://en.wikipedia.org/wiki/Von_Neumann_architecture#Mitigations

  * https://en.wikipedia.org/wiki/NX_bit


.. contents:
   :local:


.. index:: Programming Paradigms
.. _programming paradigms:

Programming Paradigms
~~~~~~~~~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Programming_paradigm
| WikipediaCategory: https://en.wikipedia.org/wiki/Category:Programming_paradigms

* https://en.wikipedia.org/wiki/Comparison_of_programming_paradigms



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
| Homepage: https://www.bbcode.org/
| Docs: https://www.bbcode.org/reference.php
| Docs: https://www.bbcode.org/examples/

BBCode is a :ref:`Lightweight markup language`
often used by bulletin boards and forums.


.. index:: Markdown
.. _markdown:

Markdown
++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Markdown
| Homepage: https://daringfireball.net/projects/markdown/
| Standard: https://daringfireball.net/projects/markdown/syntax
| Docs: https://www.w3.org/community/markdown/wiki/MarkdownImplementations
| Docs: https://en.wikipedia.org/wiki/Markdown#Implementations
| Docs: https://learnxinyminutes.com/docs/markdown/
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
| Homepage: https://commonmark.org
| Standard: https://spec.commonmark.org/0.29/
| Src: https://github.com/commonmark/commonmark-spec

:ref:`CommonMark` is one effort to standardize :ref:`Markdown`.



.. index:: MyST Markdown
.. index:: MyST
.. _myst:
.. _myst markdown:

MyST Markdown
++++++++++++++
| Src: https://github.com/executablebooks/MyST-Parser
| Src: https://github.com/executablebooks/MyST-NB
| Docs: https://myst-parser.readthedocs.io/en/latest/
| Docs:  https://myst-nb.readthedocs.io/en/latest/

MyST Markdown is :ref:`CommonMark` :ref:`Markdown` with support
for :ref:`Sphinx` roles and directives.

- :ref:`jupyter-book` builds HTML, LaTeX, and PDF books
  from MyST Markdown, :ref:`ReStructuredText`, and :ref:`Jupyter` notebooks
  in the sequence listed in `_toc.yml`.


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
| Docs: https://www.sphinx-doc.org/rest.html

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
| Docs: https://learnxinyminutes.com/docs/c/

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
| Docs: https://sourceware.org/glibc/wiki/HomePage
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
| Src: https://cvsweb.openbsd.org/cgi-bin/cvsweb/src/lib/libc/
| Src: https://opensource.apple.com/source/Libc/

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
| Docs: https://learnxinyminutes.com/docs/c++/

C++ is a free and open source
third-generation programming language
which adds object orientation and a standard library to :ref:`C`.

* C++ is an ISO specification: C++98, C++03, C++11 (C++0x), C++14, [ C++17 ]
* There are many template libraries for C++:
  https://en.wikipedia.org/wiki/List_of_C%2B%2B_template_libraries


.. index:: Standard Template Library
.. _standard template library:

Standard Template Library
++++++++++++++++++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Standard_Template_Library


.. index:: libstdc++
.. _libstdc++:

-----------
libstdc++
-----------
| Src: https://gcc.gnu.org/git/?p=gcc.git;a=tree;f=libstdc%2B%2B-v3
| Src: https://github.com/gcc-mirror/gcc/tree/master/libstdc%2B%2B-v3
| Docs: https://gcc.gnu.org/onlinedocs/libstdc++/

libstdc++ is the
free and open source
GNU :ref:`C++` :ref:`Standard Template Library`.

- :ref:`GCC` (:ref:`G++`) typically builds with libstdc++.


-------------
libc++
-------------
| Homepage: https://libcxx.llvm.org/
| Src: https://github.com/llvm/llvm-project/tree/master/libcxx/
| Docs: https://libcxx.llvm.org/docs/

libc++ (libcxx) is the
free and open source
:ref:`LLVM`
:ref:`C++` :ref:`Standard Template Library`.

- :ref:`Clang` (:ref:`clang++`) typically builds with libc++ (libcxx).


.. index:: Microsoft STL
.. _microsoft stl:

---------------
Microsoft STL
---------------
| Src: https://github.com/microsoft/STL

Microsoft STL is Microsoft's
free and open source
implementation of the :ref:`C++`
:ref:`Standard Template Library`.

* Microsoft Visual C++ typically builds with the Microsoft STL.


.. index:: Boost
.. _boost:

Boost
+++++++
| Wikipedia: `<https://en.wikipedia.org/wiki/Boost_(C%2B%2B_libraries)>`__
| Homepage: https://www.boost.org/
| Src: https://github.com/boostorg/boost
| Docs: https://www.boost.org/doc/
| Docs: https://www.boost.org/doc/libs/release/
| Docs: https://www.boost.org/doc/libs/release/more/getting_started/
| Docs: https://www.boost.org/doc/libs/release/libs/python/doc/html/

Boost is a free and open source
set of :ref:`C++` libraries for doing lots of things in C++.


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
| Docs: https://learnxinyminutes.com/docs/haskell/
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
| Homepage: https://go.dev/
| Src: https://github.com/golang/go
| Docs: https://go.dev/doc/
| Docs: https://go.dev/doc/effective_go
| Docs: https://go.dev/security/fuzz/
| Docs: https://pkg.go.dev/
| Docs: https://pkg.go.dev/std
| Docs: https://pkg.go.dev/testing
| LearnXinYMinutes: https://learnxinyminutes.com/docs/go/

Go is a free and open source
statically-typed :ref:`C`-based third generation language.

- Go binaries may be compiled without a libc; may make direct kernel syscalls on the platform or platforms they're compiled for.
  - https://github.com/goplus/libc
- Better Go Playground
  https://goplay.tools/


.. index:: Java
.. _Java:

Java
~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Java_(programming_language)>`__
| Docs: http://javadocs.org/
| Docs: https://learnxinyminutes.com/docs/java/


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
    | Download: https://www.oracle.com/technetwork/java/javase/
    | Download: https://www.oracle.com/technetwork/java/javase/downloads/
    | Download: https://www.java.com/en/download/
    | Docs: https://www.java.com/en/download/help/index_installing.xml?os=All+Platforms

  + OpenJDK (open source)

    | Wikipedia: https://en.wikipedia.org/wiki/OpenJDK
    | Homepage: https://openjdk.java.net/
    | Download: https://openjdk.java.net/install/
    | Src: https://hg.openjdk.java.net/
    | Docs: https://wiki.openjdk.java.net/
    | Docs: https://openjdk.java.net/guide/

    + IcedTea (open source)

      | Wikipedia: https://en.wikipedia.org/wiki/IcedTea

* Java EE ("Java Enterprise Edition") extends Java SE
  with a number of APIs for web services (``javax.servlet``,
  ``javax.transaction``)

  https://en.wikipedia.org/wiki/Java_Platform,_Enterprise_Edition


.. index:: Javascript
.. _js:
.. _javascript:

Javascript
~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/JavaScript
| Docs: https://learnxinyminutes.com/docs/javascript/

Javascript (JS) is a free and open source
third-generation programming language
designed to run in an interpreter; now specified as :ref:`ECMAScript`.

All major web browsers support Javascript.

Client-side (web) applications can be written in Javascript.

Server-side (web) applications can be written in Javascript,
often with :ref:`Node.js`, :ref:`NPM`, and :ref:`Bower` packages.

.. note:: Java and JavaScript are two distinctly different languages
   and developer ecosystems.


.. index:: ECMAScript
.. _ecmascript:

ECMAScript
+++++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/ECMAScript
| Homepage: https://www.ecma-international.org/ecma-262/
| Src: https://github.com/tc39/ecma262#ecmascript
| Spec: https://www.ecma-international.org/ecma-262/
| Spec: https://tc39.github.io/ecma262/
| Spec: https://tc39.es/ecma262/

ECMAScript (ES) is an evolving, formally-specified,
weakly-typed scripting language
from which :ref:`Javascript` and ActionScript are derived.

- There are multiple versions of ECMAScript (ES):

  - ES1 -- ES1997
  - ES2 -- ES1998
  - ES3 -- ES1999
  - ES5 -- ES2009
  - ES6 -- ES2015
  - ES7 -- ES2016
  - ES8 -- ES2017
  - ES9 -- ES2018
  - ES10 -- ES2019
  - ES.Next

- :ref:`Babel` compiles ECMAScript (ES6+) to Javascript.
- Some browsers support various versions (ES7) of ECMAScript.

  - https://en.wikipedia.org/wiki/List_of_ECMAScript_engines

- :ref:`Firefox` is built upon the SpiderMonkey ECMAScript engine.
- Google :ref:`Chrome`,
  :ref:`Node.JS`,
  and the latest Microsoft :ref:`Edge`
  are built upon the V8 ECMAEscript engine.


.. index:: Babel
.. _babel:

Babel
++++++
| Wikipedia: `<https://en.wikipedia.org/wiki/Babel_(compiler)>`__
| Homepage: https://babeljs.io/
| Src: https://github.com/babel/babel
| Docs: https://babeljs.io/docs/en/

Babel is a :ref:`Javascript` (:ref:`ECMAScript`) compiler that transforms
ES6 (ES2015) and beyond into browser-compatible JS.

- :ref:`ReactJS` developers commonly compile ES6+
  and :ref:`JSX` to JS with Babel.


.. index:: Node.js
.. _nodejs:
.. _node.js:

Node.js
+++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Node.js
| Homepage: https://nodejs.org/
| Src: https://github.com/joyent/node
| Docs: https://nodejs.org/en/docs/
| Docs: https://nodejs.org/api/

Node.js is a free and open source
framework for :ref:`Javascript` applications
written in :ref:`C`, :ref:`C++`, and :ref:`Javascript`.



.. index:: Jinja2
.. _jinja2:

Jinja2
~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Jinja_%28template_engine%29>`__
| Homepage: https://palletsprojects.com/p/jinja/
| Src: https://github.com/pallets/jinja
| Docs: https://jinja2.readthedocs.io/en/latest/
| Docs: https://jinja.palletsprojects.com/

Jinja2 is a free and open source
templating engine written in :ref:`Python`.

:ref:`Sphinx` and :ref:`Salt` are two projects that utilize Jinja2.

.. index:: Perl
.. _perl:

Perl
~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Perl
| Homepage: https://www.perl.org/
| Project: https://dev.perl.org/perl5/
| Docs: https://www.perl.org/docs.html
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
| Src: git https://github.com/python/cpython
| Src: git https://github.com/python/peps
| Docs: https://docs.python.org/2/
| Docs: https://docs.python.org/3/
| Docs: https://docs.python.org/devguide/
| Docs: https://docs.python.org/devguide/documenting.html
| Docs: https://wiki.python.org/moin/PythonBooks
| Docs: https://www.onlineprogrammingbooks.com/python/
| Docs: https://www.reddit.com/r/learnpython/wiki/index
| Docs: https://www.reddit.com/r/learnpython/wiki/books
| Docs: https://www.quora.com/Python-programming-language-1/What-are-the-best-books-courses-for-learning-Python
| Docs: https://en.wikiversity.org/wiki/Python
| Docs: https://www.class-central.com/search?q=python
| Docs: https://learnxinyminutes.com/docs/python/
| Awesome: https://github.com/vinta/awesome-python

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

* The Gentoo :ref:`Portage` package manager is written in Python.

* The :ref:`Conda` package manager is written in Python.

* :ref:`IPython`, :ref:`Pip`, :ref:`Conda`,
  :ref:`Sphinx`, :ref:`Docutils`,
  :ref:`Mercurial`, :ref:`OpenStack`,
  :ref:`Libcloud`, :ref:`Salt`, 
  :ref:`Ansible`, 
  :ref:`Tox`, :ref:`Virtualenv`,
  and :ref:`Virtualenvwrapper` are all written in Python.

* :ref:`PyPI` is the Python community index
  for sharing open source
  :ref:`python packages`. :ref:`Pip` installs from PyPI.

The Python community is generously supported by a number of sponsors
and the Python Infrastructure Team:

* https://www.python.org/psf/sponsorship/
* https://www.python.org/psf/members/#sponsor-members
* https://infra.psf.io/

  * https://github.com/python/psf-salt

* https://packaging.python.org/

  * https://github.com/pypa/packaging.python.org



.. index:: CPython
.. _cpython:

CPython
++++++++
| Wikipedia: `<https://en.wikipedia.org/wiki/Python_(programming_language)>`_
| Homepage: https://www.python.org/
| Docs: https://docs.python.org/
| Docs: https://docs.python.org/devguide/
| Docs: https://docs.python.org/devguide/documenting.html
| Docs: https://learnxinyminutes.com/docs/python/
| Src: hg https://hg.python.org/cpython

CPython is the reference :ref:`Python` language implementation written in
:ref:`C`.

* https://github.com/python/cpython/blob/master/Grammar/python.gram

CPython can interface with other :ref:`C` libraries
through a number of interfaces:

* Python C-API: https://docs.python.org/3/c-api/
* :ref:`CFFI`
  | Docs: https://cffi.readthedocs.io/en/latest/

* :ref:`Cython`

There are other implementations of Python:

* :ref:`Stackless Python`
* :ref:`Jython`
* :ref:`PyPy`
* :ref:`RustPython`


.. index:: Cython
.. _cython:

Cython
++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Cython
| Homepage: https://cython.org/
| PyPI: https://pypi.python.org/pypi/Cython
| Docs: https://docs.cython.org/
| Docs: https://docs.cython.org/src/userguide/language_basics.html

Cython is a superset of :ref:`CPython` which adds static type definitions;
making :ref:`CPython` code faster, in many cases.


.. index:: NumPy
.. _numpy:

NumPy
++++++
| Wikipedia: https://en.wikipedia.org/wiki/NumPy
| Homepage: https://www.numpy.org/
| Src: https://github.com/numpy/numpy
| Docs: https://docs.scipy.org/doc/numpy/

NumPy is a library of array-based mathematical functions
implemented in :ref:`C` and :ref:`Python`.

* https://nbviewer.jupyter.org/github/jrjohansson/scientific-python-lectures/blob/master/Lecture-2-Numpy.ipynb
* https://scipy-lectures.github.io/intro/numpy/index.html
* https://scipy-lectures.github.io/advanced/advanced_numpy/index.html

NumPy and other languages:

* https://docs.scipy.org/doc/numpy/user/numpy-for-matlab-users.html
* https://github.com/ipython/ipython/wiki/Extensions-Index


.. index:: SciPy
.. _scipy:

SciPy
++++++++
| Wikipedia: https://en.wikipedia.org/wiki/SciPy
| Homepage: https://scipy.org/
| Src: https://github.com/scipy/scipy
| Docs: https://www.scipy.org/docs.html
| Docs: https://docs.scipy.org/doc/scipy/reference/
| Docs: https://www.scipy.org/install.html

SciPy is a set of science and engineering libraries
for :ref:`Python`, primarily written in :ref:`C`.

* https://nbviewer.jupyter.org/github/jrjohansson/scientific-python-lectures/blob/master/Lecture-3-Scipy.ipynb
* https://scipy-lectures.github.io/intro/scipy.html

* The :ref:`SciPy Stack <scipystack>` specification
  includes the SciPy package and its dependencies.


.. index:: SciPy Stack
.. _scipystack:

SciPy Stack
+++++++++++++
| Docs: https://www.scipy.org/stackspec.html
| Docs: https://www.scipy.org/install.html

Python Distributions

* :ref:`Sage Math` (:ref:`SageMathCloud`)
* Enthought Canopy
* Python(x,y)
* WinPython
* Pyzo
* :ref:`Anaconda` (:ref:`Conda`, :ref:`Wakari`)


.. index:: Scipy Stack Docker Containers
.. _scipy stack docker containers:

SciPy Stack Docker Containers
+++++++++++++++++++++++++++++++


.. index:: Jupyter Docker Stacks
.. _jupyter docker stacks:

-----------------------------
Jupyter Docker Stacks
-----------------------------
| Src: https://github.com/jupyter/docker-stacks
| DockerHub: https://hub.docker.com/r/ipython/ipython/
| DockerHub: https://hub.docker.com/r/jupyter/
| DockerHub: https://hub.docker.com/r/jupyter/datascience-notebook/
| DockerHub: https://hub.docker.com/r/jupyter/tmpnb/


* :ref:`Jupyter` and :ref:`Scipystack` :ref:`Docker` containers:

  * https://hub.docker.com/r/jupyter/datascience-notebook/

    * https://github.com/jupyter/docker-stacks/tree/master/datascience-notebook#docker-options
    * :ref:`conda`

  * https://github.com/jupyter/tmpnb#using-jupyterdocker-stacks-images

See also:

+ :ref:`Docker`
+ https://wrdrd.github.io/docs/consulting/data-science#reproducibility


.. index:: PyPy
.. _pypy:

PyPy
+++++
| Wikipedia: https://en.wikipedia.org/wiki/PyPy
| Homepage: https://pypy.org/
| Src: https://bitbucket.org/pypy/pypy
| Docs: http://buildbot.pypy.org/waterfall
| Docs: https://pypy.readthedocs.io/en/latest/
| Docs: https://pypy.readthedocs.io/en/latest/introduction.html

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
| Docs: https://pypy.org/numpydonate.html


.. index:: Python 3
.. _python3:

Python 3
++++++++++
| Docs: https://docs.python.org/3/
| Docs: https://docs.python.org/3/howto/pyporting.html
| Docs: https://docs.python.org/3/howto/cporting.html
| Docs: https://learnxinyminutes.com/docs/python3/


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
* https://six.readthedocs.io/
* https://pypi.python.org/pypi/nine
* https://github.com/nandoflorestan/nine/blob/master/nine/__init__.py
* https://pypi.python.org/pypi/future
* https://python-future.org/


See also: :ref:`Anaconda`


.. index:: awesome-python-testing
.. _awesome-python-testing:

awesome-python-testing
++++++++++++++++++++++++
| Homepage: https://westurner.github.io/wiki/awesome-python-testing.html
| Src: https://github.com/westurner/wiki/blob/master/awesome-python-testing.rest


.. index:: Tox
.. _tox:

Tox
++++++++++++++
| Homepage: https://testrun.org/tox/
| Docs: https://tox.readthedocs.io/en/latest/
| Src: https://github.com/tox-dev/tox
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
| Src: https://github.com/ruby/ruby
| Docs: https://www.ruby-lang.org/en/documentation/
| Docs: https://learnxinyminutes.com/docs/ruby/

Ruby is a free and open source
dynamically-typed programming language.

:ref:`Vagrant` is written in Ruby.


.. index:: Rust
.. _rust:

Rust
~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Rust_(programming_language)>`__
| Homepage: https://www.rust-lang.org/
| Docs: https://doc.rust-lang.org/stable/
| Docs: https://doc.rust-lang.org/nightly/
| Docs: https://learnxinyminutes.com/docs/rust/
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
| Homepage: https://scala-lang.org/
| Src: git https://github.com/scala/scala
| Twitter: https://twitter.com/scala_lang
| Docs: https://scala-lang.org/api/current/
| Docs: https://scala-lang.org/api/current/#scala.collection.mutable.LinkedHashMap
| Docs: https://learnxinyminutes.com/docs/scala/

Scala is a free and open source
object-oriented and functional
:ref:`programming language` which compiles to
:ref:`JVM` (and :ref:`LLVM`) bytecode.


.. index:: TypeScript
.. _typescript:

TypeScript
~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/TypeScript
| Homepage: https://www.typescriptlang.org/
| Src: https://github.com/Microsoft/TypeScript
| NPM: https://www.npmjs.com/package/typescript
| NPMPkg: typescript
| Standard: https://github.com/Microsoft/TypeScript/blob/master/doc/spec.md
| FileExt: ``.ts``
| Docs: https://www.typescriptlang.org/Tutorial
| Docs: https://www.typescriptlang.org/Handbook
| Docs: https://learnxinyminutes.com/docs/typescript/

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
| Src: https://github.com/WebAssembly
| FileExt: ``.wast``
| FileExt: ``.wasm``
| Docs: https://github.com/WebAssembly/design
| Docs: https://github.com/WebAssembly/design/blob/master/UseCases.md

WebAssembly (*wasm*) is a safe (sandboxed), efficient low-level
:ref:`programming language` (abstract syntax tree)
and binary format for the web.

* WebAssembly is initially derived from asm.js and PNaCL.
* WebAssembly is an industry-wide effort.
* :ref:`LLVM` can generate WebAssembly from e.g. :ref:`C` and :ref:`C++`
  code.


.. index:: YAML
.. _yaml:

YAML
~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/YAML
| Homepage: https://yaml.org
| Docs: https://learnxinyminutes.com/docs/yaml/


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
| Wikipedia: https://en.wikipedia.org/wiki/Compiler
| WikipediaCategory: https://en.wikipedia.org/wiki/Category:Compilers

* History of compiler construction

  https://en.wikipedia.org/wiki/History_of_compiler_construction



.. index:: Interpreters
.. _interpreters:

Interpreter
~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Interpreter_(computing)>`__
| WikipediaCategory: `<https://en.wikipedia.org/wiki/Category:Interpreters_(computing)>`__

* https://en.wikipedia.org/wiki/List_of_command-line_interpreters
* https://en.wikipedia.org/wiki/List_of_command-line_interpreters#Operating_system_shells
* https://en.wikipedia.org/wiki/List_of_command-line_interpreters#Programming
* https://en.wikipedia.org/wiki/List_of_command-line_interpreters#Programming_languages

* A programming :ref:`language` interpreter interprets
  instructions without an ahead-of-time compilation step.
* A programming language interpreter is generally compiled ahead-of-time.
* A programming language interpreter implements a version of
  a programming language specification.
* Command :ref:`Shells` (e.g. :ref:`Bash`, :ref:`ZSH`) are
  programming language interpreters.
* Scripting :ref:`Languages` (e.g. :ref:`PERL`, :ref:`Ruby`, :ref:`Python`)
  are interpreted or interpret-able languages.
* Interpreted languages can often also be compiled ahead-of-time
  (e.g. with build optimizations).


.. index:: Source-to-Source Compiler
.. _source-to-source compiler:

Source-to-Source compiler
~~~~~~~~~~~~~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Source-to-source_compiler
| WikipediaCategory: https://en.wikipedia.org/wiki/Category:Source-to-source_compilers

.. contents:
   :local:


.. index:: ROSE
.. _rose:

ROSE
++++++
| Wikipedia: `<https://en.wikipedia.org/wiki/ROSE_(compiler_framework)>`__
| Homepage: http://rosecompiler.org/
| Src: git https://github.com/rose-compiler/rose
| Docs: http://rosecompiler.org/?page_id=11
| Docs: http://rosecompiler.org/ROSE_Tutorial/ROSE-Tutorial.pdf
| Docs: http://www.rosecompiler.org/ROSE_HTML_Reference/
| Docs: http://wiki.rosecompiler.org/


* http://rosecompiler.org/ROSE_Tutorial/ROSE-Tutorial.pdf


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
| Homepage: https://clang.llvm.org/
| Src: git https://github.com/llvm/llvm-project
| Docs: https://clang.llvm.org/docs/
| Docs: https://clang.llvm.org/docs/UsersManual.html

Clang is a compiler front end for :ref:`C`, :ref:`C++`, and Objective C/++.
Clang is part of the :ref:`LLVM` project.


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

- There are now GCC frontends for many languages, including
  :ref:`C++`, :ref:`Fortran`, :ref:`Java`, and :ref:`Go`.
- The :ref:`C++` GCC frontend binary is called ``g++``.


.. index:: GNU Linker
.. index:: ld
.. _ld:

GNU Linker
~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Linker_(computing)#GNU_linker>`__

The GNU Linker is the GNU implementation of the ``ld`` command
for linking object files and libraries.


.. index:: LLVM
.. _llvm:

LLVM
~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/LLVM
| Homepage: https://llvm.org/
| Src: git https://github.com/llvm/llvm-project
| Docs: https://llvm.org/docs/
| Docs: https://llvm.org/docs/GettingStarted.html
| Docs: https://llvm.org/docs/ReleaseNotes.html
| Docs: https://llvm.org/ProjectsWithLLVM/

LLVM "*Low Level Virtual Machine*" is a reusable compiler infrastructure
with frontends for many languages.

* :ref:`Clang` is an LLVM frontend for C-based languages like
  :ref:`C`, :ref:`C++`, :ref:`CUDA`, and :ref:`OpenCL`.
- There is a :ref:`WASM` LLVM backend:
  LLVM can produce :ref:`WebAssembly` binaries.
- The :ref:`C++` LLVM frontend binary is called ``clang++``.



.. index:: Operating Systems
.. _operating systems:

Operating Systems
===================
| Wikipedia: https://en.wikipedia.org/wiki/Operating_system
| WikipediaCategory: https://en.wikipedia.org/wiki/Category:Operating_systems
| WikipediaCategory: https://en.wikipedia.org/wiki/Category:Operating_system_technology

* History of operating systems

  https://en.wikipedia.org/wiki/History_of_operating_systems

  * Timeline of operating systems

    https://en.wikipedia.org/wiki/Timeline_of_operating_systems

    * List of operating systems

      https://en.wikipedia.org/wiki/List_of_operating_systems

* Comparison of operating systems

  https://en.wikipedia.org/wiki/Comparison_of_operating_systems

  * https://distrowatch.com/

* https://en.wikipedia.org/wiki/List_of_important_publications_in_computer_science#Operating_systems


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
| DockerHub: https://hub.docker.com/_/debian/
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
| Homepage: https://ubuntu.com/
| Src: https://launchpad.net/ubuntu
| Src: http://archive.ubuntu.com/
| Src: http://releases.ubuntu.com/
| Download: https://ubuntu.com/download
| DockerHub: https://hub.docker.com/_/ubuntu/
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
| DockerHub: https://hub.docker.com/_/centos/

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
| Homepage: https://www.oracle.com/linux

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

* https://hub.docker.com/search?q=gentoo (Stage 3 + Portage)


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
| Wikipedia: https://en.wikipedia.org/wiki/MacOS
| Homepage: https://www.apple.com/osx
| Homepage: https://www.apple.com/macos/
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

* https://www.howtogeek.com/187410/how-to-install-and-dual-boot-linux-on-a-mac/
* https://www.rodsbooks.com/refind/installing.html#osx




.. index:: Windows
.. _windows:

Windows
~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Microsoft_Windows
| Homepage: https://www.microsoft.com/en-us/windows/
| Docs: https://www.microsoft.com/enable/products/docs/
| Docs:

Microsoft Windows is a NT-kernel based operating system.

* There used to be a POSIX compatibility mode.
* Chocolatey maintains a set of :ref:`NuGet` packages for Windows.


.. index:: Windows Subsystem for Linux
.. index:: WSL
.. _wsl:
.. _windows subsystem for linux:

Windows Subsystem for Linux
++++++++++++++++++++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux
| Homepage: https://docs.microsoft.com/en-us/windows/wsl
| Source: https://github.com/Microsoft/WSL

Windows Subsystem for Linux (*WSL*) is a binary compatibility layer
which allows many Linux programs to be run on Windows 10+.

    The Windows Subsystem for Linux lets developers run a GNU/Linux
    environment -- including most command-line tools, utilities, and
    applications -- directly on Windows, unmodified, without the
    overhead of a virtual machine.

- Windows Subsystem for Linux is not a complete :ref:`virtualization`
  solution; but it does allow you to run e.g. :ref:`Ubuntu`
  or :ref:`Fedora` (and thus e.g. :ref:`Bash`) on a Windows machine.
- :ref:`Docker` for Windows is one alternative to Windows Subsystem for
  Linux.


.. index:: Windows Sysinternals
.. _windows sysinternals:

Windows Sysinternals
+++++++++++++++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Sysinternals
| Homepage: https://technet.microsoft.com/en-us/sysinternals
| Download: https://technet.microsoft.com/en-us/sysinternals/bb842062
| Download: https://live.sysinternals.com/
| Docs: https://technet.microsoft.com/en-us/sysinternals/bb545027
| Docs: https://blogs.technet.microsoft.com/sysinternals/

Windows Sysinternals is a group of tools for working with
:ref:`Windows`.

* | Download: https://technet.microsoft.com/en-us/sysinternals/bb842062

  * File & Disk: https://technet.microsoft.com/en-us/sysinternals/bb545046
  * Networking: https://technet.microsoft.com/en-us/sysinternals/bb795532
  * Process: https://technet.microsoft.com/en-us/sysinternals/bb795533

    * Process Explorer:

      https://technet.microsoft.com/en-us/sysinternals/processexplorer

      * You can replace Task Manager (``taskman.exe``)
        with Process Explorer (``procexp.exe``)
        in many versions of Windows (e.g. so that ``ctrl-alt-delete``
        launches ``procexp.exe``
      * ``Win+R`` launches the run dialog

        .. code::

            ## Win+R commands
            C:/           # open explorer to 'C:/'
            %UserProfile% # open the user profile env var directory
            cmd[.exe]     # open a command prompt
            calc          # calculator
            control       # control panel
            services.msc  # services management
            compmgmt.msc  # computer management
            eventvwr.msc  # event viewer
            Wupdmgr       # windows update manager

        * https://www.pcsteps.com/1675-run-command-complete-list-windows/

      * `<https://en.wikipedia.org/wiki/PATH_(variable)#DOS.2C_OS.2F2.2C_and_Windows>`__

        + ``%PATH%`` determines which commands you can run without typing
          a full absolute path. (Some programs will not run if other
          programs are not in a directory included in
          a user's current ``%PATH%`` variable)

          + The ``%PATH%`` variable is determined by key value pairs in
            the Windows Registry and can be set for:

            + The current prompt (with ``SET PATH=C:/additionalpath;%PATH%``)
            + A user
            + The machine

            https://stackoverflow.com/questions/8358265/how-to-update-path-variable-permanently-from-cmd-windows


  * Security: https://technet.microsoft.com/en-us/sysinternals/bb795534
  * System Information: https://technet.microsoft.com/en-us/sysinternals/bb795535
  * Miscellaneous: https://technet.microsoft.com/en-us/sysinternals/bb842059


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

* [ ] Install salt: https://docs.saltstack.com/en/latest/topics/installation/windows.html

* ``<Win>+R`` (Start > Run)
* [ ] Run ``services.msc`` and log/prune unutilized services
  (e.g. workstation, server) and record changes made

  * https://en.wikipedia.org/wiki/Windows_service
  * https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.win_service.html
  * https://docs.saltstack.com/en/latest/ref/states/providers.html#provider-service

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
| Homepage: https://ansible.com/
| Src: https://github.com/ansible/ansible
| Docs: https://docs.ansible.com/
| Docs: https://docs.ansible.com/ansible/latest/
| Docs: https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html
| Docs: https://docs.ansible.com/ansible/latest/modules/list_of_all_modules.html
| Docs: https://docs.ansible.com/ansible/latest/reference_appendices/galaxy.html
| Docs: https://github.com/ansible/molecule
| Learnxinyminutes: https://learnxinyminutes.com/docs/ansible/

Ansible is a :ref:`Configuration Management` tool
written in :ref:`Python`
which runs idempotent Ansible Playbooks
written in :ref:`YAML` markup with :ref:`Jinja2` variables
for managing
one or more physical and virtual machines running various operating systems
over SSH.


.. index:: Cobbler
.. _cobbler:

Cobbler
~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Cobbler_(software)>`__
| Homepage: https://cobbler.github.io/
| Download: https://cobbler.github.io/downloads/2.8.x.html
| Src: git https://github.com/cobbler/cobbler
| Docs: https://cobbler.github.io/manuals/quickstart/
| Docs: https://cobbler.github.io/manuals/2.8.0/

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


.. index:: JuJu
.. _juju:

Juju
~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Juju_(software)>`__
| Homepage: https://jaas.ai/
| Src: https://github.com/juju/juju
| Docs: https://jaas.ai/docs
| Docs: https://jaas.ai/search?type=charm
| TcpPort: 8001

Juju is a :ref:`Configuration Management` tool
written in :ref:`Python`
which runs Juju Charms
written in :ref:`Python`
on one or more systems over SSH,
for managing
one or more physical and virtual machines running :ref:`Ubuntu`.

* https://github.com/juju/juju/issues/470


.. index:: osquery
.. _osquery:

osquery
~~~~~~~~
| Homepage: https://osquery.io/
| Src: https://github.com/facebook/osquery
| Docs: https://osquery.io/docs/tables/
| Docs: https://osquery.readthedocs.io/en/stable/

osquery is a tool for reading and querying
many sources of system data
with SQL
for :ref:`OSX` and :ref:`Linux`.

* https://docs.saltstack.com/en/develop/ref/modules/all/salt.modules.osquery.html
* https://github.com/westurner/dotfiles/blob/develop/scripts/osquery-all.sh


.. index:: Puppet
.. _puppet:

Puppet
~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Puppet_(software)>`__
| Homepage: https://puppetlabs.com/
| Docs: https://puppet.com/docs
| Docs: https://puppet.com/docs/puppet/
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
| Homepage: https://www.saltstack.com
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



.. index:: Software Build Tools
.. index:: Build Automation Tools
.. _software build tools:
.. _build automation tools:

Build Automation Tools
=======================
| Wikipedia: https://en.wikipedia.org/wiki/Build_automation

- https://en.wikipedia.org/wiki/List_of_build_automation_software


.. index:: Autotools
.. _autoconf:
.. _automake:
.. _autotools:

GNU Autotools
~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/GNU_Autotools
| Homepage: https://www.gnu.org/software/automake/
| Homepage: https://www.gnu.org/software/automake/
| Docs: https://www.gnu.org/software/autoconf/manual/autoconf.html
| Docs: https://www.gnu.org/software/automake/manual/automake.html
| Docs: https://www.gnu.org/software/automake/manual/automake.html#Standard-Configuration-Variables

GNU Autotools (*GNU Build System*) are a set of tools for
software build automation: autoconf, automake, libtool, and gnulib.

- The traditional ``./configure --help; make; make install``
  build workflow comes from the GNU Build System.
- Autoconf uses a ``configure.ac`` configure *include* file
  in generating a ``configure`` script that checks
  for platform and software dependencies and caches
  the results in a ``config.status`` script,
  which generates ``config.h`` C header file that caches the results
- Automake uses a ``Makefile.am`` to generate a
  ``Makefile.in`` makefile *include* file
  that generates a :ref:`GNU Make` ``Makefile``
- GNU Coding Standards define a number of standard configuration
  variables: ``CC``, ``CFLAGS``, ``CXX``, ``CXXFLAGS``, ``LDFLAGS``,
  ``CPPFLAGS`` which tools such as :ref:`GNU Make` automatically
  add to e.g. :ref:`GCC` (and :ref:`ld`) build program arguments

.. code:: bash

    $ # autoconf  # configure.ac -> ./configure
    $ ./configure --help
    $ ./configure --prefix=/usr/local --with-this-or-that
    make


.. index:: Bake
.. _bake:

Bake
~~~~~~
| Src: https://github.com/kennethreitz/bake

Bake is a free and open source software build automation tool
similar in form and function to :ref:`Make`.

- Bake uses ``Bakefile`` files to describe builds.
- Bakefiles can contain e.g. :ref:`Bash` and :ref:`Python` scripts
  (instead of :ref:`Make` syntax)



.. index:: BUILD
.. _build:

BUILD
~~~~~~~
A number of tools use (incompatible)
``BUILD`` files to describe software builds:

- Google :ref:`Blaze`
- :ref:`Bazel`
- Twitter :ref:`Pants Build`


.. index:: Google Blaze
.. index:: Blaze
.. _google blaze:
.. _blaze:

Blaze
~~~~~~~
Blaze is an internal software build automation tool developed by Google.

- Blaze was the first build tool to use :ref:`BUILD` files.
- :ref:`Bazel` is an open source rewrite of Blaze.


.. index:: Bazel
.. _bazel:

Bazel
~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Bazel_(software)>`__
| Homepage: https://bazel.build/
| Src: https://github.com/bazelbuild/bazel
| Docs: https://docs.bazel.build/
| Docs: https://docs.bazel.build/versions/1.2.0/build-ref.html

Bazel is a free and open source software build automation tool
developed as a rewrite of Google :ref:`Blaze`.

- A ``WORKSPACE`` or ``WORKSPACE.bazel``  file indicates the root of a
  Bazel workspace.
- Bazel uses :ref:`BUILD` (or ``BUILD.bazel``) files to describe builds.
- :ref:`Buck` was released before :ref:`Bazel` was open-sourced.


.. index:: BuckBuild
.. index:: Buck
.. _buck:

Buck
~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Buck_(software)>`__
| Homepage: https://buck.build/
| Src: https://github.com/facebook/buck
| Docs: https://buck.build/setup/getting_started.html
| Docs: https://buck.build/about/overview.html

- Buck uses ``BUCK`` files to describe builds.


.. index:: CMake
.. _cmake:

CMake
~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/CMake
| Homepage: https://cmake.org/
| Src: https://gitlab.kitware.com/cmake/cmake
| Docs: https://cmake.org/cmake/help/latest/
| Docs: https://cmake.org/cmake/help/latest/guide/tutorial/

CMake is a free and open source software build automation tool.

- CMake generates build configurations for a number of tools:
  Unix Makefiles, Ninja, Visual Studio


.. index:: Gradle
.. _gradle:

Gradle
~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Gradle
| Homepage: https://gradle.org/
| Src: git https://github.com/gradle/gradle
| Download: https://gradle.org/downloads
| Docs: https://docs.gradle.org/current/release-notes
| Docs: https://docs.gradle.org/current/userguide/userguide.html
| Twitter: https://twitter.com/gradle

Gradle is a build tool for the :ref:`Java` :ref:`JVM`
which builds a directed acyclic graph (DAG).


.. index:: Grunt
.. _grunt:

Grunt
~~~~~~
| Homepage: https://gruntjs.com/
| Src: git https://github.com/gruntjs/grunt
| Docs: https://gruntjs.com/getting-started
| Docs: https://gruntjs.com/plugins
| Twitter: https://twitter.com/gruntjs

Grunt is a build tool written in :ref:`Javascript`
which builds a directed acyclic graph (DAG).


.. index:: Gulp
.. _gulp:

Gulp
~~~~~
| Homepage: https://gulpjs.com/
| Src: https://github.com/gulpjs/gulp
| Docs: https://github.com/gulpjs/gulp/blob/master/docs/
| Docs: https://github.com/gulpjs/gulp/blob/master/docs/getting-started.md
| Docs: https://gulpjs.com/plugins/
| Twitter: https://twitter.com/gulpjs

Gulp is a build tool written in :ref:`Javascript`
which builds a directed acyclic graph (DAG).


.. index:: Jake
.. _jake:

Jake
~~~~~
| Homepage: https://jakejs.com/
| Src: git https://github.com/jakejs/jake
| NPMPkg: jake
| NPM: https://www.npmjs.com/package/jake
| Docs: https://jakejs.com/docs-page.html

Jake is a :ref:`Javascript` build tool written in :ref:`Javascript`
(for :ref:`Node.js`) similar to :ref:`Make` or :ref:`Rake`.


.. index:: Make
.. _make:

Make
~~~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Make_(software)>`_
| Homepage:  https://www.gnu.org/software/make/
| Project: https://savannah.gnu.org/projects/make/
| Src: git git://git.savannah.gnu.org/make.git
| Docs:  https://www.gnu.org/software/make/manual/make.html


GNU Make is a classic, ubiquitous software build automation tool
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


.. index:: Pants
.. index:: Pants Build
.. _pants build:
.. _pants:

Pants Build
~~~~~~~~~~~
| Homepage: https://pantsbuild.github.io/
| Src: git https://github.com/pantsbuild/pants
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
:ref:`Android`], :ref:`C++`, :ref:`Go`, :ref:`Haskell`, :ref:`Node`,
and :ref:`Python`
[:ref:`CPython`] software projects.

* A Pants :ref:`BUILD` file defines one or more build targets:

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
| Docs: https://www.freedesktop.org/wiki/Software/systemd/ControlGroupInterface/
| Docs: https://docs.fedoraproject.org/en-US/Fedora/17/html-single/Resource_Management_Guide/index.html#sec-How_Control_Groups_Are_Organized
| Docs: https://wiki.archlinux.org/index.php/Cgroups

Cgroups are a :ref:`Linux` mechanism for containerizing
groups of processes and resources.

* https://chimeracoder.github.io/docker-without-docker/#1

  * ``systemd-nspawn``, ``systemd-cgroup``
  * ``machinectl``, ``systemctl``, ``journalctl``,


.. index:: libcontainer
.. _libcontainer:

libcontainer
~~~~~~~~~~~~~
| Homepage: https://www.opencontainers.org/
| Src: https://github.com/docker/libcontainer
| Src: https://github.com/opencontainers/runc/tree/master/libcontainer

libcontainer is a library built by :ref:`Docker` to replace :ref:`LXC`.

  Libcontainer provides a native :ref:`Go` implementation for creating
  containers with namespaces, :ref:`cgroups`, capabilities, and filesystem
  access controls.

  -- https://github.com/opencontainers/runc/tree/master/libcontainer

- libcontainer is now developed as part of
  :ref:`OCI` :ref:`runC`.



.. index:: OCI
.. index:: Open Container Initiative
.. _open container initiative:
.. _oci:

Open Container Initiative
~~~~~~~~~~~~~~~~~~~~~~~~~~
| Homepage: https://www.opencontainers.org/
| Docs: https://www.opencontainers.org/about
| Src: https://github.com/opencontainers
| Twitter: https://twitter.com/oci_org

The Open Container Initiative (*OCI*) is a Linux Foundation
collaborative project dedicated to developing a working, portable
software container specification.


.. index:: runC
.. _runc:

runC
~~~~~~
| Homepage: https://www.opencontainers.org/
| Src: https://github.com/opencontainers/runc

runC is a container abstraction

  runc is a CLI tool for spawning and running containers according to
  the :ref:`OCI` specification.

- runC builds upon the :ref:`libcontainer` abstraction
  and the :ref:`OCI` container specification.
- runC works on :ref:`Linux`, :ref:`OSX`, and :ref:`Windows`.
- runC containers do not require a daemon process.
- runC containers can run as e.g. a systemd service unit.


.. index:: Docker
.. _docker:

Docker
~~~~~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Docker_(software)>`_
| Homepage: https://www.docker.com/
| Src: https://github.com/docker/docker
| Docs: https://docs.docker.com/
| Awesome: https://github.com/veggiemonk/awesome-docker

Docker is an OS virtualization project written in :ref:`Go`
which utilizes :ref:`Linux` containers -- first :ref:`LXC`
now :ref:`libcontainer` / :ref:`runC` --
to partition process workloads across one or more host systems.

.. glossary::

    Dockerfile
        A ``Dockerfile`` contains the instructions needed to
        create a docker image.

    Docker container
        A Docker container is an instance of a :term:`Docker Image`
        with configuration.

    Docker API
        The Docker API is an interface of management commands for
        provisioning and managing containers.

        :term:`Docker Machine`, :term:`Docker Swarm`, and
        :term:`Docker Universal Control Plane` all implement the Docker
        API; so the ``docker`` client works equally well with each
        implementation.

    Docker Machine
        Docker Machine is the container management application
        which implements the :term:`Docker API`.

    Docker Swarm
        Docker Swarm is a cluster management system for Docker
        containers hosted on one or more :term:`Docker Machines <Docker
        Machine>`

    Docker Universal Control Plane
        Docker Universal Control Plane is an enterprise-grade cluster
        management solution with a web dashboard and external authentication
        which implements the :term:`Docker API`.

    Docker Compose
        Docker Compose is a Python application for defining and managing
        services (:term:`Docker containers <docker container>`) and
        networks with a ``docker-compose.yml`` :ref:`YAML` configuration
        file.

    Docker Image
        A Docker Image is an archived container filesystem with
        configuration which is usually defined by a :term:`Dockerfile`.

    Docker Hub
        Docker Hub is a cloud-based registry service for
        :term:`Docker Images <Docker Image>`.

    Docker Cloud
        Docker Cloud is the hosting service offered by Docker.


* Docker images build from a :term:`Dockerfile`
* A ``Dockerfile`` can subclass another Dockerfile (to add, remove, or
  change configuration)
* ``Dockerfile`` support a limited number of commands
* Docker is not intended to be a
  complete :ref:`configuration management system
  <configuration management>`
* Ideally, a Docker image requires minimal configuration once built
* Docker images can be hosted by https://hub.docker.com/
* ``docker run -it ubuntu/16.04`` downloads the image
  from https://hub.docker.com/_/ubuntu/,
  creates a new instance (``docker ps``),
  and spawns a root :ref:`Shell <shells>` with
  a UUID name (by default).
* There are a number of ways to "Schedule" [redundant]
  persistent containers that launch on boot
  with :ref:`Docker`

  - Docker Swarm is the Docker-native way to run a cluster of
    containers. To a client app, Docker Swarm looks just like Docker
    Machine because it implements the Docker API.
  - :ref:`Kubernetes` is one project which uses Docker to
    schedule redundant, optionally geodistributed,
    :ref:`LXC` containers (in "Pods").

:ref:`Salt` can install and manage docker, docker images and containers:

* https://github.com/saltstack-formulas/docker-formula
* https://docs.saltstack.com/en/latest/ref/states/all/salt.states.dockerio.html
* https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.dockerio.html



.. index:: CNCF
.. index:: Cloud Native Computing Foundation
.. _cloud native computing foundation:
.. _cncf:

Cloud Native Computing Foundation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Linux_Foundation#Cloud_Native_Computing_Foundation

The Cloud Native Computing Foundation (*CNCF*) is a foundation
for cloud and container industry collaboration.

- :ref:`Kubernetes` is now a CNCF project.


.. index:: Kubernetes
.. _kubernetes:

Kubernetes
~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Kubernetes
| Homepage: https://kubernetes.io/
| Src: https://github.com/GoogleCloudPlatform/kubernetes
| Docs: https://kubernetes.io/gettingstarted/
| Docs: https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/getting-started-guides/docker.md
| Docs: https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/getting-started-guides/vagrant.md
| Docs: https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/getting-started-guides/coreos.md
| Docs: https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/getting-started-guides/mesos.md
| Q&A: https://stackoverflow.com/questions/tagged/kubernetes
| Twitter: https://twitter.com/kubernetesio
| Awesome: https://github.com/ramitsurana/awesome-kubernetes

Kubernetes (*k8s*) is a highly-available distributed cluster scheduler
which works with groups of :ref:`Docker` containers
called Pods.

- Google donated Kubernetes to the :ref:`CNCF`.


.. index:: k3s
.. _k3s:

k3s
~~~~
| Homepage: https://k3s.io/
| Src: https://github.com/rancher/k3s
| Docs: https://rancher.com/docs/k3s/latest/en/

k3s is a lightweight :ref:`Kubernetes` distribution
which runs on x86-64, ARM6, ARM7; only requires 512Mb of RAM;
and is distributed as a single :ref:`Go` binary.

- You've heard of k8s? This is k8s - 5.


.. index:: KVM
.. _KVM:

KVM
~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Kernel-based_Virtual_Machine
| Homepage: https://www.linux-kvm.org/
| Docs: https://www.linux-kvm.org/page/Documents

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
| Docs: https://libcloud.readthedocs.io/en/latest/
| Docs: https://libcloud.readthedocs.io/en/latest/supported_providers.html
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
| Docs: https://docs.openstack.org/
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

  * Src: https://github.com/openstack/keystone
  * Wiki: https://wiki.openstack.org/wiki/Keystone

* OpenStack **Nova** implements a Hypervisor API
  which abstracts various :ref:`Virtualization` providers
  (e.g. :ref:`KVM`, :ref:`Docker`, :ref:`LXC`, :ref:`LXD`).

  * Src: https://github.com/openstack/nova
  * Wiki: https://wiki.openstack.org/wiki/Nova
  * Docs: https://wiki.openstack.org/wiki/HypervisorSupportMatrix
  * Docs: https://docs.openstack.org/nova/latest/user/support-matrix.html

* OpenStack **Swift** -- redundant HTTP-based Object Storage
  as a service.

  * Src: https://github.com/openstack/swift
  * Wiki: https://wiki.openstack.org/wiki/Swift
  * Docs: https://docs.openstack.org/swift/latest/
  * Docs: https://docs.openstack.org/swift/latest/overview_auth.html
  * Docs: https://docs.openstack.org/swift/latest/overview_object_versioning.html

* OpenStack **Neutron** (*Quantum*)-- software defined networking (SDN), VLAN,
  switch configuration, virtual and physical
  enterprise networking as a service.

  * Src: https://github.com/openstack/neutron
  * Wiki: https://wiki.openstack.org/wiki/Neutron

* OpenStack **Designate** -- DNS as a service (Bind9, PowerDNS)
  integrated with OpenStack Keystone, Neutron, and Nova.

  * Src: https://github.com/openstack/designate
  * Wiki: https://wiki.openstack.org/wiki/Designate

* OpenStack **Poppy** -- CDN as a service CDN vendor API

  * Src: https://github.com/stackforge/poppy
  * Wiki: https://wiki.openstack.org/wiki/Poppy

* OpenStack **Horizon** -- web-based OpenStack Dashboard
  which is written in Django.

  * Src: https://github.com/openstack/horizon
  * https://wiki.openstack.org/wiki/Horizon

OpenStack makes it possible for end-users to create a new virtual
machine from the available pool of resources.


``rdfs:seeAlso``: :ref:`openstack-devstack`, :ref:`Libcloud`


.. index:: OpenStack DevStack
.. _openstack-devstack:

OpenStack DevStack
~~~~~~~~~~~~~~~~~~
| Src: https://github.com/openstack-dev/devstack
| Docs: https://docs.openstack.org/devstack/latest/
| Docs: https://docs.openstack.org/devstack/latest/overview.html
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
* https://anvil.readthedocs.io/en/latest/topics/summary.html


.. index:: Packer
.. _packer:

Packer
~~~~~~~~~~~~~~~~~
| Homepage: https://www.packer.io/
| Src: https://github.com/hashicorp/packer
| Docs: https://www.packer.io/docs
| Docs: https://www.packer.io/docs/basics/terminology.html

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
      - https://www.packer.io/docs/templates/builders.html

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
| Docs: https://www.vagrantup.com/docs/
| Src: https://github.com/hashicorp/vagrant


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
| Wikipedia: https://en.wikipedia.org/wiki/Unix_shell


.. index:: Bash
.. _bash:

Bash
~~~~~~~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>`__
| Homepage: https://www.gnu.org/software/bash/
| Src: git git://git.savannah.gnu.org/bash.git
| Docs: https://www.gnu.org/software/bash/manual/
| LearnXinYMinutes: https://learnxinyminutes.com/docs/bash/
| Awesome: https://github.com/awesome-lists/awesome-bash

GNU Bash, the Bourne-again shell, is an open source command-line program
written in :ref:`C`
for running commands in a text-based terminal.

A few commands to try when learning to shell with Bash:

.. code-block:: bash

   echo $SHELL; echo "$SHELL"; echo "${SHELL}"
   type bash
   bash --help
   help help
   help type
   apropos bash
   info bash
   man bash

   man man
   info info  # [down arrow] and then [enter] to select, or 'n' for next

* Bash works with unix command outputs and return codes:
  a program returns nonzero when there is an error:

  .. code:: bash

     true;  echo $?  # 0
     false; echo $?  # 1
     echo "Hello" && echo " World!"  # Hello World!
     false || echo "World!"          # World!

* Functions: Bash supports functions with arguments that can
  print to standard out and/or return an integer return code:

  .. code:: bash

     function add_a {
        echo "$1 + $2 = $(( $1 + $2 ))"
     }
     add_b () {
        echo "$1 + $2 = $(( $1 + $2 ))"
     }
     add_xy () {
        echo "$x + $y = $(( $x + $y ))"
     }
     add_a 3 5       # "3 + 5 = 8"
     add_b 3 5       # "3 + 5 = 8"

     x=3 y=5 add_xy  # "3 + 5 = 8"
     x=3; y=5;
     add_xy          # "3 + 5 = 8"

     output=$(add_a 3 5)
     echo "${output}"

     help test
     help [
     help [[
     help return

     test "$(add_a 3 5)" == "3 + 5 = 8" && echo 'OK'

     test_add_a () {
        if [[ "$(add_a 3 5)" == "3 + 5 = 8" ]]; then
            echo 'OK'
            return 0
        else
            echo 'Test failed'
            return 1
        fi
     }
     test_add_a

     help trap
     help exit

* Portability: sh (sh, bash, dash, zsh) shell scripts are mostly
  compatible; though bash supports some features that other shells do
  not.
* Logging: You can configure bash to print commands and arguments
  as bash executes scripts:

  .. code:: bash

     set -x  # print commands and arguments
     set -v  # print source

Bash reads various configuration files at startup time:

.. code:: bash

   /etc/profile
   /etc/bash.bashrc
   /etc/profile.d/*.sh
   ${HOME}/.profile        /etc/skel/.profile   # PATH=+$HOME/bin  # umask
   ${HOME}/.bash_profile   # empty. preempts .profile
   ${HOME}/.bashrc

Bash and various :ref:`Operating Systems`:

- Linux: Bash is almost always installed as the default shell on Linux
  boxes.
- Mac:

  - MacOS includes Bash 3.2.
  - You can ``brew install bash`` to get
    a more recent version. (:ref:`homebrew`)

- Windows:

  - :ref:`Windows Subsystem for Linux` (WSL) installs Linux
    distributions which include bash.
  - You can also install bash on Windows by installing git
    with ``choco install git -y`` (:ref:`Chocolatey`)
  - You can also install bash on Windows by installing
    MSYS2 (Mingw) or Cygwin with ``choco install msys2`` or ``choco install
    cygwin``

While Bash is ubiquitous,
shell scripts are loose with quoting; which makes shell scripts flexible
but **dangerous** and thus often avoided in favor of other
languages:

.. code:: bash

    ## Shell script quoting example 1:

    # This prints a newline
    echo $(echo "-e a\nb")

    # This prints "-e a\nb"
    echo "$(echo "-e a\nb")"

This isn't an issue with e.g. :ref:`Python` (a popular language that's
also useful for system administration).

.. code:: python

    import subprocess
    print(subprocess.check_output(['echo', "-e a\nb"])
    print(subprocess.check_output('echo "-e a\nb"', shell=True))

    # Though, note that Python subprocess shell=True is a security risk:
    # - avoid shell=True
    # - pass the command as a list of already-tokenized arguments
    # - use something like sarge (or ansible) instead of shell=True

:ref:`IPython` is one of many alternatives to Bash.


.. index:: Readline
.. _readline:

Readline
~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/GNU_Readline
| Homepage: https://tiswww.case.edu/php/chet/readline/rltop.html
| Docs: https://tiswww.case.edu/php/chet/readline/readline.html
| Docs: https://tiswww.case.edu/php/chet/readline/history.html
| Docs: https://tiswww.case.edu/php/chet/readline/rluserman.html
| Src: ftp ftp://ftp.gnu.org/gnu/readline/readline-8.0.tar.gz
| Pypi: https://pypi.python.org/pypi/gnureadline


.. index:: IPython
.. index:: ipython
.. _ipython:

IPython
~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/IPython
| Homepage: https://ipython.org/
| Src: git https://github.com/ipython/ipython
| DockerHub: https://hub.docker.com/repos/ipython/
| Docs: https://ipython.readthedocs.io/en/stable/
| Docs: https://ipython.readthedocs.io/en/stable/interactive/
| Docs: https://ipython.readthedocs.io/en/stable/parallel/
| Docs: https://github.com/ipython/ipython/wiki/Extensions-Index
| Docs: https://github.com/jupyter/jupyter/wiki/Jupyter-kernels
| Docs: https://github.com/ipython/ipython/wiki/Install:-Docker

IPython is an interactive REPL and distributed computation framework
written in :ref:`Python`.

.. code:: bash

    ## Formatting expression output with the Python interpreter
    1 + 1
    x = 1+1
    print("1 + 1 = 2")
    print('1 + 1 = %d' % (x))
    print('1 + 1 = {0}'.format(x))   # Python 2.7+
    print('1 + 1 = {x}'.format(x=x)) # Python 2.7+
    print(f'1 + 1 = {x}')            # Python 3.6+
    print(f'{1 + 1 = }')             # Python 3.8+

    ## IPython
    !ipython --help                # run `$SHELL -c 'ipython --help'`
    !python -m IPython --help      # run `ipython --help`

    ?                              # print IPython help within IPython

    %lsmagic
    %<tab>                         # list magic commands and aliases
    %paste?                        # help for the %paste magic command
    %logstart?                     # help for the %logstart magic command
    %logstart -o logoutput.log.py  # log input and output to a file

    import json
    json?                          # print(json.__doc__)
    json??                         # print(inspect.getsource(json))

    ## IPython shell
    !cat ./README.rst; echo $PWD   # run shell commands
    lines = !ls -al                # capture shell command output
    print(lines[0:])
    %run -i -t example.py          # run a script with timing info,
                                   # in the local namespace
    %run -d example.py             # run a script with pdb
    %pdb on                        # automatically run pdb on Exception

- If a kernel is not specified,
  IPython uses the ``ipykernel`` Jupyter kernel.
- To use other kernels with IPython, you must install `jupyter_console`
  and a kernel:

  .. code:: bash

    pip install jupyter_console  # conda install -y jupyter_console

    ipython console --kernel python  # ipykernel
    jupyter console --kernel python  # ipykernel
    # <Ctrl-D> | <Ctrl-C> | "exit()"

    pip install bash_kernel  # conda install -y bash_kernel
    jupyter console --kernel bash
    # "exit"

    conda install -y -c conda-forge xeus-cling
    jupyter console --kernel xcpp11
    # <Ctrl-D> (<Ctrl-Z> on Windows)

    conda install -y nodejs; npm install -g ijavascript; ijsinstall
    jupyter console --kernel javascript
    # <Ctrl-D>

    conda install -y nodejs; npm install -g jp-babel; jp-babel-install
    jupyter console --kernel babel
    # <Ctrl-D>

    conda install -y nodejs; npm install -g itypescript; its --install=local
    jupyter console --kernel typescript
    # <Ctrl-D>

    jupyter kernelspec list

- There are very many Jupyter kernels:
  https://github.com/jupyter/jupyter/wiki/Jupyter-kernels
- :ref:`Jupyter Notebook` and :ref:`Jupyter Lab` are built atop IPython:
  a Jupyter notebook file is a :ref:`JSON` file with an `.ipynb` extension
  which contains inputs and text and binary outputs.


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
| Homepage: https://www.zsh.org/
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
| Homepage: https://hisham.hm/htop/
| Src: https://github.com/hishamhm/htop

Htop is a commandline task manager; like ``top`` extended.


.. index:: Pyline
.. _pyline:

Pyline
~~~~~~~~
| Homepage: https://github.com/westurner/pyline
| Docs: https://pyline.readthedocs.io/en/latest/
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



.. index:: Web Shells
.. _web shells:

Web Shells
=============

.. index:: IPython Notebook
.. index:: IPython notebook
.. _ipython notebook:

IPython Notebook
~~~~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/IPython#Notebook
| Src: https://github.com/ipython/ipython/tree/3.x/IPython/html
| Docs: http://ipython.readthedocs.io/en/stable/notebook/
| Docs: http://ipython.readthedocs.io/en/stable/notebook/notebook.html
| Docs: http://ipython.readthedocs.io/en/stable/notebook/nbformat.html
| Docs: http://ipython.readthedocs.io/en/stable/notebook/nbconvert.html
| Docs: http://ipython.readthedocs.io/en/stable/notebook/public_server.html
| Docs: http://ipython.readthedocs.io/en/stable/notebook/security.html
| Docs: https://github.com/ipython/ipython/wiki/A-gallery-of-interesting-IPython-Notebooks

:ref:`IPython` Notebook (now :ref:`Jupyter Notebook`)
is an open source web-based shell
written in :ref:`Python` and :ref:`Javascript`
for interactive and literate computing with IPython notebooks
composed of raw, markdown, or code **input**
and plaintext- or rich- **output** cells.

* An IPython notebook (``.ipynb``) is a
  :ref:`JSON-` document containing input and output
  for a linear sequence of cells;
  which can be exported to many output formats
  (e.g. :ref:`HTML-`, RST, LaTeX, PDF);
  and edited through the web with
  IPython Notebook.
* IPython Notebook is a webapp written on :ref:`tornado`,
  an asynchronous web application framework for Python.
  
  * seeAlso: westurner/brw (2007-))

* IPython Notebook supports :ref:`Markdown` syntax for comment cells.

  * :ref:`MyST Markdown` is a :ref:`commonmark` :ref:`Markdown` syntax
    (which can also be used to express entire Jupyter notebooks)

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

   Jupyter Notebook runs Python notebooks with :ref:`ipykernel`,
   the :ref:`IPython` :ref:`Python` kernel from :ref:`IPython Notebook`



.. index:: Jupyter kernels
.. _jupyter kernels:

Jupyter kernels
++++++++++++++++
| Src: https://github.com/ipython/ipykernel
| Docs: https://ipython.readthedocs.io/en/stable/install/kernel_install.html


.. index:: ipykernel
.. _ipykernel:

ipykernel
++++++++++
| Src: https://ipython.readthedocs.io/en/stable/install/kernel_install.html

.. index:: ipython_nose
.. _ipython_nose:

ipython_nose
++++++++++++++
| Src: git https://github.com/taavi/ipython_nose


ipython_nose is an extension for :ref:`IPython Notebook`
(and likely :ref:`Jupyter Notebook`)
for discovering and running test functions
starting with ``test_``
(and unittest.TestCase test classes with names containing ``Test``)
with `Nose <https://westurner.github.io/wiki/awesome-python-testing#nose>`__.

* ipython_nose is not (yet?) uploaded to PyPI
* to install ipython_nose from GitHub (with :ref:`Pip` and :ref:`Git`):

.. code:: bash

   pip install -e git+https://github.com/taavi/ipython_nose#egg=ipython_nose


See also:

* TDD: Test Driven Development
  https://wrdrd.github.io/docs/consulting/software-development#test-driven-development
* **Refactoring** and **Reproducibility**

  * https://wrdrd.github.io/docs/consulting/software-development#refactoring
  * https://wrdrd.github.io/docs/consulting/data-science#reproducibility


.. index:: nosebook
.. _nosebook:

nosebook
~~~~~~~~~~
| Src: https://github.com/bollwyvl/nosebook

nosebook is a tool for finding and running tests in :ref:`nbformat`
:ref:`IPython Notebooks <ipython notebooks>`
and :ref:`Jupyter Notebooks <jupyter notebook>`
with ``nose``.

See also:

* https://westurner.github.io/wiki/awesome-python-testing#nose


.. index:: Jupyter
.. index:: Project Jupyter
.. _jupyter:

Jupyter
~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/IPython#Project_Jupyter
| Homepage: http://jupyter.org/
| Src: https://github.com/jupyter/
| DockerHub: https://hub.docker.com/repos/jupyter/
| Docs: https://jupyter.readthedocs.io/en/latest/
| Awesome: https://github.com/markusschanta/awesome-jupyter
| **Awesome:** https://github.com/quobit/awesome-python-in-education#jupyter



Project Jupyter expands upon
components like :ref:`IPython` and :ref:`IPython Notebook`
to provide a multi-user web-based shell
for many languages (:ref:`Python`, :ref:`Ruby`, :ref:`Java`,
:ref:`Haskell`, Julia, R).


.. table:: IPython Jupyter comparison (adapted from http://jupyter.org)
   :class: table-striped table-responsive

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
| Wikipedia: https://en.wikipedia.org/wiki/Jupyter#Notebook
| Src: https://github.com/jupyter/notebook
| CondaPkg: ``notebook``
| FileExt: ``.ipynb``
| Docs: https://jupyter-notebook.readthedocs.io/en/stable/

:ref:`Jupyter` Notebook
is an open source shell webapp
written in :ref:`Python` and :ref:`Javascript`
for interactive and literate computing with Jupyter notebooks
composed of raw, markdown, or code **input**
and plaintext- or rich- **output** cells.

* ``.ipynb`` files are Jupyter Notebooks saved as 
  :ref:`JSON-` documents .
* An Jupyter notebook is a
  document containing {meta, input, and output} records
  for a linear sequence of cells;
  which can be exported to many output formats
  (e.g. :ref:`HTML-`, RST, LaTeX, PDF, Python, :ref:`MyST Markdown`);
  and edited through the web with
  Jupyter Notebook.
* Jupyter Notebook is a webapp written on :ref:`tornado`,
  an asynchronous web application framework for Python.
  
  * seeAlso: westurner/brw (2007-))

* Jupyter Notebook supports :ref:`Markdown` syntax for comment cells.

  * :ref:`MyST Markdown` is a :ref:`commonmark` :ref:`Markdown` syntax
    (which can also be used to express entire Jupyter notebooks)

* Jupyter Notebook supports more than 40 different Jupyter kernels for
  other languages:

  https://github.com/ipython/ipython/wiki/Jupyter-kernels-for-other-languages

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

.. note:: :ref:`JupyterLab` (a mostly-rewrite)
   adds e.g. tabs and undo (and a new extension API)
   to :ref:`Jupyter Notebook`.


.. index:: JupyterLab
.. _jupyterlab:

JupyterLab
+++++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Project_Jupyter#JupyterLab
| Src: https://github.com/jupyterlab/jupyterlab
| CondaPkg: ``jupyterlab``
| Docs: https://jupyterlab.readthedocs.io/en/stable/
| Docs: https://jupyterlab.readthedocs.io/en/stable/user/extensions.html
| Docs: https://jupyterlab.readthedocs.io/en/stable/developer/extension_dev.html
| Awesome: https://github.com/mauhai/awesome-jupyterlab

JupyterLab is an open-source web-based tabbed :ref:`IDE <IDE>`
written in :ref:`Python`, :ref:`Javascript`, and :ref:`TypeScript` 
for working with
:ref:`<jupyter notebooks> Jupyter Notebook`, terminals, text editing, undo, extensions.

- You can edit Jupyter notebooks with JupyterLab.
- Installing JupyterLab also installs :ref:`Jupyter Notebook`.
  (which doesn't support tabs or the new extension API)
- A few UI differences between JupyterLab and Jupyter Notebook:

  - JupyterLab has tabbed editing: you can open files, notebooks,
    and terminals in tabs
  - JupyterLab has a sidebar with a file selector pane

- Installing JupyterLab does not install any :ref:`scipystack`
  or other packages.


.. index:: JupyterLab (install)

Install JupyterLab
+++++++++++++++++++++

Install JupyterLab With :ref:`pip`:

.. code:: bash

   python -m pip install jupyterlab

Install JupyterLab with :ref:`conda`:

.. code:: bash

   conda install -c conda-forge -y jupyterlab


.. index:: Hosting JupyterLab
.. index:: JupyterLab (hosting)
.. _hosting jupyterlab:

Hosting JupyterLab
+++++++++++++++++++
You can host JupyterLab yourself:

- :ref:`JupyterHub`

  - "Zero to JupyterHub with :ref:`Kubernetes`"
    https://zero-to-jupyterhub.readthedocs.io/en/latest/
  - JupyterHub **Spawners** create new instances of JupyterLab (within containers, VMs,
    a shell)

    - https://jupyterhub.readthedocs.io/en/stable/reference/spawners.html
    - https://github.com/jupyterhub/jupyterhub/wiki/Spawners

  - JupyterHub **Authenticators** check names and credentials
    from a file, PAM, Single Sign On APIs

    - https://jupyterhub.readthedocs.io/en/stable/reference/authenticators.html
    - https://github.com/jupyterhub/jupyterhub/wiki/Authenticators

- :ref:`BinderHub` runs containers with :ref:`repo2docker`

  - https://binderhub.readthedocs.io/en/latest/zero-to-binderhub/
  - :ref:`mybinder.org` is powered by :ref:`BinderHub`



.. index:: Hosted JupyterLab
.. index:: JupyterLab (hosted)
.. _hosted jupyterlab:

Hosted JupyterLab
+++++++++++++++++++
There are many providers of hosted :ref:`JupyterLab`
and :ref:`Jupyter Notebook`;
where they run Jupyter in a shell or a VM on their servers for you 
and you connect over your internet connection.

- https://github.com/markusschanta/awesome-jupyter#hosted-notebook-solutions
- :ref:`Cocalc`
- :ref:`Google AI Platform` has hosted JupyterLab Notebooks.
- :ref:`Google Colab` is a fork of :ref:`Jupyter Notebook`.
- :ref:`GitHub Codespaces` (:ref:`VSCode`)
- :ref:`ml-workspace` -- https://github.com/ml-tooling/ml-workspace
  (:ref:`VSCode`)
- :ref:`MyBinder.org`


.. index:: JupyterHub
.. _jupyterhub:

JupyterHub
++++++++++++
| Src: https://github.com/jupyter/jupyterhub
| Docs: https://jupyterhub.readthedocs.io/en/latest/
| Docs: https://github.com/jupyter/jupyterhub/wiki
| Docs: https://github.com/jupyter/jupyterhub/wiki/Authenticators
| Docs: https://github.com/jupyter/jupyterhub/wiki/Spawners

JupyterHub makes it easy to serve :ref:`Jupyter Notebook`
and/or :ref:`Jupyter Lab` for multiple users on one or more servers.

- JupyterHub spawns individual
  Jupyter Notebook / JupyterLab server instances
  for logged-in users.
- JupyterHub enables users to log-in with Authenticator backends:
  system users, LDAP, SSO, OAuth (e.g. Google accounts)
- If so configured, JupyterHub can launch additional servers
  to serve one or more Notebook/Lab :ref:`Docker` containers
  and then shut those down when they're idle
  or, for example, when a course session is complete.


.. index:: nbconvert
.. _nbconvert:

nbconvert
+++++++++++
| Src: https://github.com/jupyter/nbconvert
| Docs: https://nbconvert.readthedocs.io/en/latest/

nbconvert is the code that converts (transforms) an ``.ipynb`` notebook
(:ref:`nbformat` :ref:`JSON <json->`) file
into an output representation (e.g. :ref:`HTML`,
HTML slides (:ref:`reveal.js`), :ref:`LaTeX`, PDF, ePub, Mobi).

* nbconvert is included with :ref:`Jupyter Notebook` and
  :ref:`JupyterLab`

  .. code:: bash

    pip install nbconvert
    # pip install -e git+https://github.com/jupyter/nbconvert@master#egg=nbconvert

    jupyter nbconvert --to html mynotebook.ipynb


.. index:: reveal.js
.. _reveal.js:

----------
reveal.js
----------
| Src: https://github.com/hakimel/reveal.js

reveal.js is a :ref:`Javascript` and :ref:`HTML` library
for slide presentations served from an HTML file.

- Reveal.js slides can be in a 1-dimensional or a 2-dimensional arrangement.
- You can generate reveal.js slides from Jupyter notebooks in two ways:
  with ``nbconvert --to slides`` or with the GUI:
  "File" > "Export Notebok As..." > "Export Notebook to reveal.js
  slides"

  .. code:: bash

      jupyter nbconvert --to slides mynotebook.ipynb

  .. note:: Presentation content that doesn't fit on a slide is hidden
     and unscrollable: *only put a slide worth of data in each cell
     for a Jupyter reveal.js presentation*.

     Alternatives to presenting notebooks as reveal.js slides:

     - Increase the browser font size (Jupyter Notebook)
     - "View" > "Presentation Mode" (JupyterLab)
     - Select a keyboard shortcut set
       use the "Select Cell Below" / "Select Cell Above"
       keyboard shortcuts to highlight cells and scroll them into view

       - Press "<Escape>"
       - Press "j" to "Select Cell Below"
       - Press "k" to "Select Cell Above"

- The :ref:`RISE` extension also generates reveal.js slides.


.. index:: RISE
.. _rise:

------
RISE
------
| Src: https://github.com/damianavila/RISE
| Docs: https://rise.readthedocs.io/en/latest/

RISE is a :ref:`Jupyter Notebook` and :ref:`JupyterLab` extension
that generates live :ref:`reveal.js` presentations from Jupyter
notebooks.

- Install the RISE extension
- Click the RISE button to generate a *live* :ref:`reveal.js`
  slide presentation wherein you can execute cells
  on the slides with "Ctrl-Enter" and "Shift-Enter"
  just like you can in the Notebook interface.


.. index:: nbformat
.. _nbformat:

nbformat
++++++++++
| Src: https://github.com/jupyter/nbformat
| Docs: https://nbformat.readthedocs.io/en/latest/
| Docs: https://nbformat.readthedocs.io/en/latest/format_description.html#backward-compatible-changes

The :ref:`Jupyter notebook` (``.ipynb``) format is a versioned
:ref:`JSON <json->` format for storing metadata and input/output sequences.

Usually, when the nbformat changes, notebooks are silently upgraded to the
new version on the next save.

.. note:: nbformat v3 and above add a **kernelspec** attribute to the
   nbformat :ref:`JSON <json->`, because ``.ipynb`` files can now contain
   code for languages other than :ref:`Python`.

* nbformat does not specify any schema for the user-supplied
  metadata dict (TODO: :ref:`nbmeta`),
  so JSON that conforms to an externally
  managed :ref:`JSON-LD <json-ld->` ``@context``
  would work.


.. index:: nbgrader
.. _nbgrader:

nbgrader
++++++++
| Src: https://github.com/jupyter/nbgrader
| Docs: https://nbgrader.readthedocs.io/en/stable/
| Docs: https://nbgrader.readthedocs.io/en/stable/user_guide/
| Docs: https://nbgrader.readthedocs.io/en/latest/
| Docs: https://nbgrader.readthedocs.io/en/latest/user_guide/
| Docs: https://nbgrader.readthedocs.io/en/latest/command_line_tools/

nbgrader is a solution for centrally receiving and grading :ref:`Jupyter
notebooks <jupyter notebook>`.

- You mark notebook cells as TODO

See also:

* :ref:`CoCalc` Course management
* https://wrdrd.github.io/docs/consulting/education-technology#jupyter-and-tdd

  * :ref:`jupyter and tdd`


.. index:: nbviewer
.. _nbviewer:

nbviewer
+++++++++++
| Homepage: https://nbviewer.jupyter.org
| Src: git https://github.com/jupyter/nbviewer
| Dockerfile: https://github.com/jupyter/nbviewer/blob/master/Dockerfile

(``nbviewer``)
is an application for serving read-only
versions of Jupyter notebooks from HTTP URLs.

- When you enter a URL, GitHub ``username``,
  GitHub ``username/repo``, or Gist ID
  into the text box at
  https://nbviewer.jupyter.org/ and click 'Go!' (or press Enter),
  nbviewer nbconverts the notebook to HTML or shows a file browser
  and branch/tag selector
  for the git repo.
- You do not need to look up the raw GitHub URL for the notebook,
  because nbviewer automatically rewrites the GitHub /blob/ file URL
  to a raw.githubusercontent.com URL.

- GitHub now also renders static ``.ipynb`` files, CSV, SVG, and PDF.
  However, GitHub does not execute any JS in the notebook due
  to security concerns (XSS)
- GitLab renders Jupyter notebooks with JS.


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

.. code::

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

.. code::

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

.. code::

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


.. index:: jupyter_contrib_nbextensions
.. _jupyter_contrib_nbextensions:

jupyter_contrib_nbextensions
++++++++++++++++++++++++++++++
| Src: https://github.com/ipython-contrib/jupyter_contrib_nbextensions
| Docs: https://github.com/ipython-contrib/jupyter_contrib_nbextensions#1-install-the-python-package
| CondaPkg: ``jupyter_contrib_nbextensions``

- https://github.com/ipython-contrib/jupyter_contrib_nbextensions#pip
- https://github.com/ipython-contrib/jupyter_contrib_nbextensions#conda



.. index:: NBPresent
.. _nbpresent:

NBPresent
++++++++++++
| Src: https://github.com/Anaconda-Platform/nbpresent
| Docs: https://docs.continuum.io/anaconda/jupyter-notebook-extensions#notebook-present

    remix your :ref:`Jupyter Notebooks <jupyter notebook>`
    as interactive slideshows



.. index:: Anaconda Jupyter Notebook Extensions
.. _anaconda jupyter notebook extensions:

Anaconda Jupyter Notebook Extensions
+++++++++++++++++++++++++++++++++++++++
| Src: https://github.com/Anaconda-Platform/anaconda-nb-extensions
| Docs: https://docs.continuum.io/anaconda/jupyter-notebook-extensions

* :ref:`Conda` environments, :ref:`Anaconda`, :ref:`Jupyter Notebook`


.. index:: CoCalc
.. index:: SageMathCloud
.. _cocalc:
.. _sagemathcloud:

CoCalc
~~~~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/CoCalc
| Homepage: https://cocalc.com/
| Src: https://github.com/sagemathinc/cocalc
| Src: https://github.com/sagemathinc/cocalc-docker
| ChromeExt: https://chrome.google.com/webstore/detail/cocalc/eocdndagganmilahaiclppjigemcinmb
| Docs: https://doc.cocalc.com/
| Docs: https://doc.cocalc.com/teaching-instructors.html
| Docs: https://doc.cocalc.com/teaching-students.html

* https://cocalc.com/
* Interactive Worksheets
* Course Management: Assignments, Handouts, :ref:`nbgrader`
* :ref:`LaTeX` Editor
* :ref:`Jupyter Notebook`
* Linux Terminal
* :ref:`Sage Math`


.. index:: Google Colab
.. index:: Colab
.. _colab:
.. _google colab:

Google Colab
~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Project_Jupyter#Colaboratory
| Homepage: https://colab.research.google.com/
| Src: https://github.com/googlecolab
| Docs: https://research.google.com/colaboratory/faq.html
| Awesome: https://github.com/firmai/awesome-google-colab

Google Colab is a hosted :ref:`Jupyter Notebook` system.

- Colab has a number of packages installed in the default environment.
  If you want additional packages, you need to ``!pip install`` them
  once when you first open the notebook.
- Colab is forked from a previous version of Jupyter Notebook,
  and so does not have some newer Jupyter Notebook
  or any Jupyter Lab features.
- :ref:`ipywidgets` are not yet implemented on Colab.
- Colab saves to Google Drive.
- Colab instances are free and can use some GPU time if needed.
- There is a Colab Pro.
- Google AI Platform Notebooks hosts :ref:`JupyterLab` notebooks:
  https://cloud.google.com/ai-platform-notebooks


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
  | Docs: https://westurner.github.io/dotfiles/
  | Docs: https://westurner.github.io/dotfiles/usage#bash

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
| Docs: https://westurner.github.io/dotfiles/usage#vim



.. index:: Venv
.. _venv:

Venv
~~~~~

| Docs: https://westurner.github.io/dotfiles/venv
| Docs: https://westurner.github.io/dotfiles/dotfiles.venv
| Src: https://github.com/westurner/dotfiles/blob/develop/src/dotfiles/venv/
| Src: https://github.com/westurner/dotfiles/blob/develop/etc/bash/10-bashrc.venv.sh

Venv is a tool for making working with :ref:`Virtualenv`,
:ref:`Virtualenvwrapper`, :ref:`Bash`, :ref:`ZSH`, :ref:`Vim`,
and :ref:`IPython` within a project context very easy.

Venv defines standard :ref:`fhs` and :ref:`Python` paths,
environment variables,
and aliases
for routinizing workflow.

.. table:: Venv paths and cdaliases
   :class: table-striped table-responsive

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
| Homepage: https://virtualenv.pypa.io/en/latest/
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
| Docs: https://virtualenvwrapper.readthedocs.io/en/latest/
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
| Homepage: https://www.gnome.org/
| Docs: https://help.gnome.org/
| Src: https://git.gnome.org/browse/


* https://wiki.gnome.org/GnomeLove


.. index:: i3wm
.. _i3wm:

i3wm
~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/I3_(window_manager)>`__
| Homepage: https://i3wm.org/
| Download: https://i3wm.org/downloads/
| Docs: https://i3wm.org/docs/
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
| Homepage: https://www.qt.io/
| Docs: https://doc.qt.io/
| Docs: https://doc.qt.io/qt-5/qtexamplesandtutorials.html
| Docs: https://www.qt.io/contribute/
| Docs: https://wiki.qt.io/Main_Page
| Docs: https://wiki.qt.io/Get_the_Source
| Src: git https://code.qt.io/cgit/

Qt is a Graphical User Interface toolkit for
developing applications with
Android, iOS, :ref:`OSX`, Windows, Embedded :ref:`Linux`, and :ref:`X11`.


.. index:: Wayland
.. _wayland:

Wayland
~~~~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Wayland_(display_server_protocol)>`_
| Homepage: https://wayland.freedesktop.org/
| Src: https://gitlab.freedesktop.org/wayland/wayland


Wayland is a display server protocol for GUI window management.

Wayland is an alternative to :ref:`X11` servers like XFree86 and X.org.

The reference Wayland implementation, Weston, is written in :ref:`C`.


.. index:: X Window System
.. index:: X11
.. _x11:

X11
~~~~
| Wikipedia: https://en.wikipedia.org/wiki/X_Window_System
| Homepage: https://www.x.org/
| Docs: https://www.x.org/wiki/Documentation/
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

How to open Chrome (and Firefox) DevTools:

* Right-click > "Inspect Element"
* Linux: ``<ctrl><shift>i``
* OSX: ``<option><command>i``

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
| Homepage: https://microsoft.com/ie

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
| Homepage: https://www.opera.com/
| Download: https://www.opera.com/computer/windows
| Download: https://www.opera.com/computer/mac
| Download: https://www.opera.com/computer/linux
| Download: https://www.opera.com/computer/beta
| Download: https://www.opera.com/mobile
| AndroidApp: https://play.google.com/store/apps/details?id=com.opera.browser
| AndroidApp: https://play.google.com/store/apps/details?id=com.opera.mini.native
| AndroidApp: https://play.google.com/store/apps/details?id=com.opera.max.global #Proxy Compression
| iOSApp: https://itunes.apple.com/app/id363729560 #Opera Mini
| iOSApp: https://itunes.apple.com/app/id674024845 #Opera Coast
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
| Download: https://webkit.org/build-archives/
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
| Homepage: https://www.chromevox.com/
| ChromeExt: https://chrome.google.com/webstore/detail/chromevox/kgejglhpjiefppelpmljglcjbhoiplfn


.. index:: Dark Reader
.. _dark reader:

Dark Reader
++++++++++++
| Src: https://github.com/darkreader/darkreader
| Homepage: https://darkreader.org/
| ChromeExt: https://chrome.google.com/webstore/detail/dark-reader/eimadpbcbfnmbkopoojfekhnkhdbieeh
| FirefoxExt: https://addons.mozilla.org/en-US/firefox/addon/darkreader/
| SafariExt: https://darkreader.org/safari
| EdgeExt: https://microsoftedge.microsoft.com/addons/detail/ifoakfbpdcdoeenechcleahebpibofpc
| Twitter: https://twitter.com/darkreaderapp


.. index:: Deluminate
.. _deluminate:

Deluminate
+++++++++++
| Homepage: https://deluminate.github.io/
| Src: https://github.com/abstiles/deluminate
| ChromeExt: https://chrome.google.com/webstore/detail/deluminate/iebboopaeangfpceklajfohhbpkkfiaa


.. index:: GitHub Dark Theme
.. _github dark theme:

GitHub Dark Theme
++++++++++++++++++
| Docs:  https://poychang.github.io/github-dark-theme/
| Src: https://github.com/poychang/github-dark-theme
| ChromeExt: https://chrome.google.com/webstore/detail/github-dark-theme/odkdlljoangmamjilkamahebpkgpeacp
| FirefoxExt: https://addons.mozilla.org/addon/github-dark-theme/


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


.. index:: ShadowFox
.. _shadowfox:

ShadowFox
+++++++++
| Src: https://github.com/overdodactyl/ShadowFox
| Homepage: https://overdodactyl.github.io/ShadowFox/
| Docs: https://github.com/overdodactyl/ShadowFox/wiki


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


.. index:: Facebook Container
.. _facebook container:

Facebook Container
+++++++++++++++++++
| Src: https://github.com/mozilla/contain-facebook
| FirefoxExt: https://addons.mozilla.org/en-US/firefox/addon/facebook-container/



.. index:: Firefox Multi-Account Containers
.. _firefox multi-account containers:

Firefox Multi-Account Containers
+++++++++++++++++++++++++++++++++
| Src: https://github.com/mozilla/multi-account-containers/
| FirefoxExt: https://addons.mozilla.org/en-US/firefox/addon/multi-account-containers/


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
| Wikipedia: https://en.wikipedia.org/wiki/HTTPS_Everywhere
| Homepage: https://www.eff.org/https-everywhere
| Src: https://github.com/EFForg/https-everywhere
| ChromeExt: https://chrome.google.com/webstore/detail/gcbommkclmclpchllfjekcdonpmejbdp
| FirefoxXPI: https://www.eff.org/files/https-everywhere-latest.xpi
| FirefoxAndroidXPI: https://www.eff.org/files/https-everywhere-android.xpi
| Twitter: https://twitter.com/HTTPSEverywhere

HTTPS Everywhere is a browser extension that forces the browser
to only connect over HTTPS to sites listed in its database.


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
   curl -Ls "https://api.github.com/repos/${_repo}/releases" > ./releases.json
   cat releases.json \
       | grep browser_download_url \
       | pyline 'w and w[1][1:-1]' \
       | pyline --regex \
           '.*download/(.*)/(uBlock.(firefox.xpi|chromium.zip))$' \
           'rgx and rgx.group(1,2)'



.. index:: uBlock Origin
.. _ublock origin:

uBlock Origin
++++++++++++++
| Src: https://github.com/gorhill/uBlock
| ChromeExt: https://chrome.google.com/webstore/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm
| FirefoxExt: https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/
| EdgeExt: https://microsoftedge.microsoft.com/addons/detail/odfafepnkmbhccpbejgmiehpchacaeak
| SafariExt: 


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


.. index:: OpenLink Structured Data Sniffer
.. _openlink structured data sniffer:

OpenLink Structured Data Sniffer
++++++++++++++++++++++++++++++++++
| Src:  https://github.com/openlink/structured-data-sniffer
| Homepage:  http://osds.openlinksw.com/
| ChromeExt:  https://chrome.google.com/webstore/detail/openlink-structured-data/egdaiaihbdoiibopledjahjaihbmjhdj?hl=en
| FirefoxExt:  https://addons.mozilla.org/en-US/firefox/addon/openlink-structured-data-sniff/
| EdgeExtDoc:  http://osds.openlinksw.com/#DownloadEdge

- :ref:`JSON-LD`, :ref:`Microdata`, :ref:`RDFa`, :ref:`Turtle`


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
  * https://citationstyles.org/

* Zotero can export a collection of resources' bibliographic metadata
  as RDF
* There are a number of plugins and integrations with Zotero:

  https://www.zotero.org/support/plugins


.. index:: Zotero and Schema.org RDFa
.. _zotero and schema.org RDFa:

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

.. index:: better-onetab
.. _better-onetab:

better-onetab
++++++++++++++
| Src:  https://github.com/cnwangjie/better-onetab
| ChromeExt: https://chrome.google.com/webstore/detail/better-onetab/eookhngofldnbnidjlbkeecljkfpmfpg


.. index:: FoxyTab
.. _foxytab:

FoxyTab
++++++++
| FirefoxExt:  https://addons.mozilla.org/en-US/firefox/addon/foxytab/
| Support:  https://github.com/erosman/support/issues


.. index:: OneTab
.. _onetab:

OneTab
+++++++
| Homepage: https://www.one-tab.com/
| ChromeExt: https://chrome.google.com/webstore/detail/onetab/chphlpgkkbolifaimnlloiipkdnihall
| FirefoxExt: https://addons.mozilla.org/en-US/firefox/addon/onetab/
| FirefoxXPI: https://addons.mozilla.org/firefox/downloads/latest/525044/addon-525044-latest.xpi

* https://github.com/Greduan/chrome-ext-tabulator
* :ref:`better-onetab`


.. index:: Snipe
.. _snipe:

Snipe
+++++++
| Homepage: https://joe.sh/snipe
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
| Homepage: https://piro.sakura.ne.jp/xul/_treestyletab.html.en
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
| Homepage: https://getfirebug.com/
| FirefoxExt: https://addons.mozilla.org/en-us/firefox/addon/firebug/
| FirefoxXPI: https://addons.mozilla.org/firefox/downloads/latest/1843/addon-1843-latest.xpi
| ChromeExt: https://chrome.google.com/extensions/detail/bmagokdooijbeehmkpknfglimnifench

* https://getfirebug.com/firebuglite
* https://getfirebug.com/wiki/index.php/Firebug_Extensions


.. index:: FireLogger
.. _firelogger:

FireLogger
++++++++++++
| Homepage: https://firelogger.binaryage.com/
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


.. index:: Preact Devtools
.. _preact devtools

Preact Devtools
++++++++++++++++
| Src:  https://github.com/preactjs/preact-devtools
| Homepage: https://preactjs.github.io/preact-devtools/
| ChromeExt: https://chrome.google.com/webstore/detail/preact-developer-tools/ilcajpmogmhpliinlbcdebhbcanbghmd
| FirefoxExt:  https://addons.mozilla.org/en-US/firefox/addon/preact-devtools/
| EdgeExt: https://microsoftedge.microsoft.com/addons/detail/hdkhobcafnfejjieimdkmjaiihkjpmhk


.. index:: React Developer Tools
.. _react developer tools:

React Developer Tools
++++++++++++++++++++++
| ChromeExt: https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi


.. index:: Refined Github
.. _refined github:

Refined Github
+++++++++++++++
| Src: https://github.com/sindresorhus/refined-github
| ChromeExt: https://chrome.google.com/webstore/detail/refined-github/hlepfoohegkhhmjieoechaddaejaokhf
| FirefoxExt: https://addons.mozilla.org/en-US/firefox/addon/refined-github-/


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
| Homepage: https://chrispederick.com/work/web-developer/
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
| FirefoxExt: https://addons.mozilla.org/en-US/firefox/addon/vimium-ff/
| SafariExt: https://github.com/televator-apps/vimari

Vimium is a Chrome Extension which adds :ref:`vim`-like functionality.


.. table:: Vimium shortcuts
   :class: table-striped table-responsive

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
* Vimperator stopped working after Firefox 57

.. index:: Wasavi
.. _wasavi:

Wasavi
+++++++
| Homepage: https://appsweets.net/wasavi/
| Src: https://github.com/akahuku/wasavi
| ChromeExt: https://chrome.google.com/webstore/detail/wasavi/dgogifpkoilgiofhhhodbodcfgomelhe
| OperaExt: https://addons.opera.com/en/extensions/details/wasavi/
| FirefoxExt: https://addons.mozilla.org/en-US/firefox/addon/wasavi/
| Docs: https://appsweets.net/wasavi/

Wasavi converts the focused ``textarea`` to an in-page editor with
:ref:`vim`-like functionality.


.. index:: Web Servers
.. _web servers:

Web Servers
============
| https://en.wikipedia.org/wiki/Web_server


.. index:: ACME
.. _acme:

ACME
~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Automated_Certificate_Management_Environment


.. index:: LetsEncrypt
.. _letsencrypt:

LetsEncrypt
++++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Let%27s_Encrypt
| Homepage: https://letsencrypt.org/
| Src: https://github.com/letsencrypt
| Src: https://github.com/certbot/certbot
| Docs: https://letsencrypt.org/docs/
| Docs: https://letsencrypt.org/docs/ct-logs/

- List of LetEncrypt ACME clients:
  https://letsencrypt.org/docs/client-options/


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



.. index:: BusyBox HTTPD
.. _busybox httpd:

BusyBox HTTPD
~~~~~~~~~~~~~~
| Docs: https://busybox.net/downloads/BusyBox.html#httpd

.. code:: bash

   busybox httpd --help
   busybox httpd -p 8082 

See also: :ref:`python http.server`


.. index:: Caddy
.. _caddy:

Caddy
~~~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Caddy_(web_server)>`__
| Src: https://github.com/caddyserver/caddy
| Docs: https://caddyserver.com/docs/


.. index:: Netcat
.. _netcat:

Netcat web server
~~~~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Netcat
| 

.. code:: bash

   # Serve a file over HTTP then close
   { printf 'HTTP/1.0 200 OK\r\nContent-Length: %d\r\n\r\n' "$(wc -c < some.file)"; cat some.file; } | nc -l 8082

   # Serve the date over HTTP then start another server
   while true ; do nc -l -p 8082 -c 'echo -e "HTTP/1.1 200 OK\n\n $(date -Is)"'; done &

   # Make an HTTP request with netcat
   printf "GET / HTTP/1.0\r\nHost: localhost\r\n\r\n" | nc localhost 8082

   # Make an HTTP request with curl
   curl localhost:8082
   curl -v localhost:8082

   # Make an HTTP request with wget
   wget -O - localhost:8082
   wget -d -O - localhost:8082


.. code:: python

   from urllib.request import urlopen
   resp = urlopen("http://localhost:8082")
   assert resp.code == 200
   assert resp.headers.get_content_type() == 'text/plain'
   body = resp.read()
   print(body)


.. index:: ncat
.. _ncat:

ncat
+++++
| Wikipedia: https://en.wikipedia.org/wiki/Netcat#ncat


.. code:: bash

   nc --help
   ncat --help


.. index:: Nginx
.. _nginx:

Nginx
~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Nginx
| Homepage: https://nginx.org/
| Download: https://nginx.org/en/download.html
| Src: https://github.com/nginx/nginx
| Docs: https://nginx.org/en/docs/
| Twitter: https://twitter.com/nginxorg

Nginx is a scriptable, lightweight `HTTP` server
written in :ref:`C`.



.. index:: Python http.server
.. _python http.server:

Python http.server
+++++++++++++++++++
| Src: https://github.com/python/cpython/blob/master/Lib/http/server.py
| Docs: https://docs.python.org/3/library/http.server.html
| Docs: https://docs.python.org/3/library/http.server.html#http.server.CGIHTTPRequestHandler

.. code:: bash

   python -m http.server --help
   python -m http.server --directory . 8082
   python -m http.server --directory . --cgi 8082


See also: :ref:`pgs`


.. index:: Tengine
.. _tengine:

Tengine
~~~~~~~~~
| Wikipedia: https://zh.wikipedia.org/wiki/Tengine
| Homepage: https://tengine.taobao.org/
| Src: git https://github.com/alibaba/tengine
| Download: https://tengine.taobao.org/download.html
| Docs: https://tengine.taobao.org/documentation.html

Tengine is a fork of :ref:`Nginx` with many useful
modules and features bundled in.

* https://tengine.taobao.org/document/http_ssl.html
* https://tengine.taobao.org/document/http_upstream_check.html
* https://tengine.taobao.org/document/http_reqstat.html



.. index:: Traefik
.. _traefik:

Traefik
~~~~~~~~~
| Src: https://github.com/traefik/traefik
| Homepage: https://traefik.io/traefik/
| Docs: https://doc.traefik.io/traefik/
| Docs: https://doc.traefik.io/traefik/https/acme/
| Docs: https://doc.traefik.io/traefik/user-guides/docker-compose/acme-tls/
| Docs: https://doc.traefik.io/traefik/reference/dynamic-configuration/docker/

- Load Balancing, API Gateway (config, stats), :ref:`Kubernetes
  Ingress`, :ref:`ACME`/:ref:`LetsEncrypt`


.. index:: Kubernetes Ingress
.. _kubernetes ingress:

Kubernetes Ingress
~~~~~~~~~~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Kubernetes
| Docs: https://kubernetes.io/docs/concepts/services-networking/ingress/
| Docs: https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/


.. index:: Documentation
.. _documentation-tools:

Documentation Tools
=====================
| Docs: https://wrdrd.github.io/docs/consulting/education-technology#publishing


.. index:: Docutils
.. _docutils:

Docutils
~~~~~~~~~~~~~~~~~~~
| Homepage: http://docutils.sourceforge.net
| PyPI: https://pypi.python.org/pypi/docutils
| Docs: http://docutils.sourceforge.net/docs/
| Docs: http://docutils.sourceforge.net/rst.html
| Docs: http://docutils.sourceforge.net/docs/ref/doctree.html
| Docs: https://docutils.readthedocs.io/en/sphinx-docs/
| Docs: https://docutils.readthedocs.io/en/sphinx-docs/ref/rst/restructuredtext.html
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
| Homepage: https://pandoc.org/
| Docs: https://pandoc.org/README.html
| Docs: https://pandoc.org/releases.html
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

  * https://westurner.github.io/tools/index

    https://westurner.github.io/tools/index.html

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
| Src: git https://github.com/sphinx-doc/sphinx
| Pypi: https://pypi.python.org/pypi/Sphinx
| Docs: https://www.sphinx-doc.org/contents.html
| Docs: https://www.sphinx-doc.org/markup/code.html
| Docs: https://www.sphinx-doc.org/en/stable/markup/inline.html#ref-role
| Docs: https://pygments.org/docs/lexers/
| Docs: https://thomas-cokelaer.info/tutorials/sphinx/rest_syntax.html
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

    https://westurner.github.io/tools/


    * RawGit:

      dev/test: https://rawgit.com/westurner/tools/gh-pages/index.html

      CDN: https://cdn.rawgit.com/westurner/tools/gh-pages/index.html

  * Output: *ReadTheDocs*:

    https://<projectname>.readthedocs.io/en/<version>/

    https://read-the-docs.readthedocs.io/en/latest/


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

      See: `Sphinx Builders <https://www.sphinx-doc.org/builders.html>`_

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

      See: `Sphinx Directives <https://sphinx-doc.org/rest.html#directives>`_

   Sphinx Role
      Sphinx extensions of :ref:`Docutils` :ref:`RestructuredText` roles

      Most other ReStructured

      .. code-block:: rest

            .. _anchor-name:

            A link to :ref:`anchor <anchor-name>`.


.. index:: jupyter-book
.. _jupyter-book:

jupyter-book
+++++++++++++
| Src: https://github.com/executablebooks/jupyter-book
| Docs: https://jupyterbook.org/

- :ref:`MyST Markdown` (Sphinx roles and directives in :ref:`Markdown`)


.. index:: nbsphinx
.. _nbsphinx:

nbsphinx
+++++++++
| Src: https://github.com/spatialaudio/nbsphinx
| Docs: http://nbsphinx.readthedocs.io/


.. index:: Tinkerer
.. _tinkerer:

Tinkerer
+++++++++
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
| DistroWatch: https://distrowatch.com/table.php?distribution=clonezilla
| Homepage: https://clonezilla.org/
| Src: git https://github.com/stevenshiau/clonezilla
| Docs: https://clonezilla.org/clonezilla-live.php
| Docs: https://clonezilla.org/clonezilla-SE/
| Docs: https://clonezilla.org/related-links/

Clonezilla is an open source :ref:`Linux` distribution
which is bootable from a CD/DVD/USB (a LiveCD, LiveDVD, LiveUSB)
or PXE
which contains a number of tools
for disk imaging, disk cloning, filesystem backup and recovery;
and a server :ref:`Linux` distribution for serving disk images
to one or more computers over a LAN.

* Clonezilla contains :ref:`FSArchiver`, :ref:`partclone`,
  :ref:`partimage`, and :ref:`rsync`.
* Clonezilla can backup and restore very many (if not most) filesystems.
* Clonezilla supports MBR, GPT, and uEFI.
* Clonezilla can restore a networked multicast group (e.g. lab)
  of machines to a system image (saving TCP overhead when sharing
  the same multi-gigabyte / terabyte image to zero or more machines);
  and boot them with PXE and/or Wake-on-Lan.

  * :ref:`bup`, :ref:`debtorrent`

* Clonezilla can backup to disk, ssh, samba, NFS, WebDAV
* drbl-winroll helps with restoring :ref:`windows` images
* :ref:`SystemRescueCD` also contains :ref:`partimage`.
* :ref:`Cobbler` also supports PXE boot from images.


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
| Homepage: https://www.fsarchiver.org/
| Src:  https://sourceforge.net/projects/fsarchiver/files/fsarchiver-src/
| Download: https://sourceforge.net/projects/fsarchiver/files/fsarchiver-bin/
| Docs: https://www.fsarchiver.org/QuickStart
| Docs: https://www.fsarchiver.org/Live-backup
| Docs: https://www.fsarchiver.org/Attributes#SELinux_.28Security_Enhanced_Linux.29
| Docs: https://www.fsarchiver.org/Fsarchiver_vs_partimage
| Docs: https://www.sysresccd.org/Sysresccd-manual-en_LVM_Making-consistent-backups-with-LVM

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
| Homepage: https://partclone.org/
| Project: https://sourceforge.net/projects/partclone/
| Download: https://partclone.org/download/
| Src: git https://github.com/Thomas-Tsai/partclone
| Docs: https://partclone.org/help/
| Docs: https://partclone.org/usage/
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
| Src: https://sourceforge.net/projects/partimage/files/stable/
| Docs: http://www.partimage.org/Partimage-manual
| Docs: http://www.partimage.org/Supported-Filesystems

Partimage is an open source utility for making complete
sector-for-sector compressed backups of partitions
over the network or to a local device.

* :ref:`Clonezilla` includes :ref:`partimage`.
* SystemRescueCD includes :ref:`partimage` and :ref:`rsync`.
* partimage does not support EXT4 or BTRFS;
  for EXT4 and BTRFS support, see :ref:`fsarchiver`.


.. index:: rclone
.. _rclone:

rclone
~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Rclone
| Src: https://github.com/rclone/rclone
| Homepage: https://rclone.org/
| Docs: https://rclone.org/

Rclone is an open source utility for managing files on cloud storages
like local disk, SFTP, WebDAV, Dropbox, and Google Drive.

- Rclone supports very many cloud storages


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
| Homepage: https://rsnapshot.org/
| Download: https://rsnapshot.org/download.html
| Download: https://rsnapshot.org/downloads/
| Src: git https://github.com/rsnapshot/rsnapshot
| Docs: https://rsnapshot.org/faq.html
| Docs: https://wiki.archlinux.org/index.php/Rsnapshot
| Docs: https://linux.die.net/man/1/rsnapshot

rsnapshot is an open source incremental file directory backup utility
built with :ref:`rsync`.



.. index:: rdiff-backup
.. _rdiff-backup:

rdiff-backup
~~~~~~~~~~~~~
| Homepage: https://nongnu.org/rdiff-backup/
| Download: https://download.savannah.gnu.org/releases/rdiff-backup/
| Project: https://savannah.nongnu.org/projects/rdiff-backup
| Src: svn svn://svn.savannah.nongnu.org/rdiff-backup/
| Docs: https://nongnu.org/rdiff-backup/rdiff-backup.1.html
| Docs: https://nongnu.org/rdiff-backup/docs.html
| Docs: https://nongnu.org/rdiff-backup/examples.html

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
| Project: https://sourceforge.net/projects/systemrescuecd/
| DistroWatch: https://distrowatch.com/table.php?distribution=systemrescue
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
| Docs: https://wrdrd.github.io/docs/consulting/knowledge-engineering#web-standards
| Docs: https://wrdrd.github.io/docs/consulting/knowledge-engineering#semantic-web-standards


.. index:: Cascading Style Sheets
.. index:: CSS
.. _css-:

CSS
~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Cascading_Style_Sheets
| Docs: https://wrdrd.github.io/docs/consulting/knowledge-engineering#css

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
| Website: https://wiki.linuxfoundation.org/lsb/fhs

The Filesystem Hierarchy Standard (*FHS*) is a well-worn industry-supported
system file naming structure.

* :ref:`Linux` distributions like
  :ref:`Ubuntu` and :ref:`Fedora` implement
  a Filesystem Hierarchy.

* Likewise, :ref:`virtualenv` and :ref:`Venv` implement
  a filesystem hierarchy:

  | Docs: https://westurner.github.io/dotfiles/venv#venv-paths

* :ref:`Docker` (and many LiveCDs) layer filesystem hierarchies
  with e.g. UnionFS, AUFS, and BTRFS filesystems.


.. index:: HTTP
.. _http-:

HTTP
~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/HTTP
| Docs: https://wrdrd.github.io/docs/consulting/knowledge-engineering#http
| Docs: https://wrdrd.github.io/docs/consulting/knowledge-engineering#http2


.. index:: HTTPS
.. _https--:

HTTPS
++++++
| Wikipedia: https://en.wikipedia.org/wiki/HTTPS
| Docs: https://wrdrd.github.io/docs/consulting/knowledge-engineering#https


.. index:: HTML
.. _html-:

HTML
~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/HTML
| Docs: https://wrdrd.github.io/docs/consulting/knowledge-engineering#html5


.. index:: JSON
.. _json-:

JSON
~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/JSON
| Homepage: https://json.org/
| Spec: https://www.ecma-international.org/publications/standards/Ecma-404.htm
| Docs: https://learnxinyminutes.com/docs/json/


JSON is an object representation in :ref:`Javascript` syntax
which is now supported by libraries written in many languages.

A list of objects with ``key`` and ``value`` attributes in JSON syntax:

.. code-block:: javascript

    [
    { "key": "language", "value": "Javascript" },
    { "key": "version", "value": 1 },
    { "key": "example", "value": true }
    ]

Machine-generated JSON is often not very readable, because it doesn't
contain extra spaces or newlines.
The :ref:`Python` JSON library contains a utility
for parsing and indenting ("prettifying") JSON from the commandline ::

    cat example.json | python -m json.tool

* See also:
  https://wrdrd.github.io/docs/consulting/knowledge-engineering#json


.. index:: JSON5
.. _json5:

JSON5
~~~~~~
| Wikipedia:
| Homepage: https://json5.org/
| Src: https://github.com/json5/json5
| Speci: https://spec.json5.org/

JSON5 is JSON extended with support for a number of additional features:
comments, trailing commas, IEEE 754 +/- infinity and NaN, hexadecimal
numbers, leading and trailing decimal points, single-quoted strings,
multiline strings, and escaped characters.

- Regular JSON libraries do not support JSON5.


.. code:: javascript

    {
    // comment
    key:   [0, +1, 2., .3, NaN, +inf, -inf, 0xF, 'thing1', "thing2"],
    "str": "this is a \
    multi-line string", // trailing comma
    }


.. index:: JSON-lines
.. _json-lines:

JSON-lines
~~~~~~~~~~~
| Homepage: http://jsonlines.org/

JSON-lines (newline-delimited JSON) is an informal spec
for line-based processing of JSON e.g. for streaming records
and unix pipes.


.. code:: javascript

    {"key": "red", "value": 1}
    {"key": "green", "value": 2}


.. index:: JSONLD
.. index:: JSON-LD
.. _json-ld-:

JSON-LD
~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/JSON-LD
| Homepage: https://json-ld.org
| Docs: https://json-ld.org/playground/
| Docs: https://wrdrd.github.io/docs/consulting/knowledge-engineering#json-ld

JSON-LD is a web standard for **Linked Data** in :ref:`JSON <json->`.

An example from the *JSON-LD Playground* (`<https://goo.gl/xxZ410>`__):

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
| Homepage: https://msgpack.org/


MessagePack (*msgpack*) is a data interchange format
with implementations in many languages.

* :ref:`MsgPack` is a `Distributed Computing Protocol`
  https://wrdrd.github.io/docs/consulting/knowledge-engineering#distributed-computing-protocols
* :ref:`Salt` serializes messages with :ref:`MsgPack` by default.


.. index:: Text Editors
.. _text-editors:

Text Editors
=============
| Wikipedia: https://en.wikipedia.org/wiki/Text_editor
| Wikipedia: https://en.wikipedia.org/wiki/Source_code_editor
| WikipediaCategory: https://en.wikipedia.org/wiki/Category:Free_text_editors

- A text editor may be a *source code editor*
  or have some :ref:`IDE` features
  like syntax highlighting or syntax checking
  for :ref:`Programming Languages`.
- Most :ref:`IDEs` are source code text editors.

- https://en.wikipedia.org/wiki/Comparison_of_text_editors
- https://en.wikipedia.org/wiki/List_of_text_editors


.. index:: Gedit
.. _gedit:

Gedit
~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Gedit
| Homepage: https://wiki.gnome.org/Apps/Gedit
| Src: git https://gitlab.gnome.org/GNOME/gedit/

Gedit is an open source text editor written in
:ref:`C` and :ref:`Python` (:ref:`GTK`, GtkSourceView, and :ref:`Gnome`)
that's available for :ref:`Linux`, :ref:`OSX`, and :ref:`Windows`).

- Gedit supports tabbed editing.
- Gedit plugins are written in :ref:`Python`.
- Gedit is the default :ref:`Gnome` text editor;
  where it's called "Text Editor".


.. index:: Notepad++
.. _notepadplusplus:

Notepad++
~~~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Notepad%2B%2B
| Homepage: https://notepad-plus-plus.org/
| Src: https://github.com/notepad-plus-plus/notepad-plus-plus
| Docs: https://notepad-plus-plus.org/online-help/
| ChocolateyPackage: https://chocolatey.org/packages/notepadplusplus

Notepad++ is an open source text editor written in :ref:`C++`
for :ref:`Windows` which has tabbed editing.

- Notepad++ supports tabbed editing.
- Notepad++ plugins are written in :ref:`C` or :ref:`C++`:

  - https://github.com/notepad-plus-plus/nppPluginList
  - https://github.com/notepad-plus-plus/nppPluginList/blob/master/src/pl.x64.json

- npppythonscript is a plugin that enables scripting
  Notepad++ with :ref:`Python`

  - http://npppythonscript.sourceforge.net/

- Notepad++ was the most used editor according to a 2015 Stack OVerflow
  survey.


.. index:: IDEs
.. index:: Integrated Development Environments
.. _ide:
.. _ides:

IDEs
======
| Wikipedia: https://en.wikipedia.org/wiki/Integrated_development_environment
| WikipediaCategory: https://en.wikipedia.org/wiki/Category:Integrated_development_environments

An IDE (*Integrated Development Environment*) is a software tool
for developing software.

- Most IDEs are source code :ref:`Text Editors`.
- Some IDEs are visual development tools for various types of
  not code trees and graphs.
- IDEs have a concept of a project,
  which may be defined in a config file
  in the current working directory
  or otherwise selected through the GUI.
- An IDE has some sort of language server that understands
  the source code at a deeper level than syntax
  in order to do cool things like code completion and
  code refactorings
  like renaming a method in every file in the project.
- https://en.wikipedia.org/wiki/Comparison_of_integrated_development_environments


.. index:: Emacs
.. index:: GNU Emacs
.. _gnu emacs:
.. _emacs:

Emacs
~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/GNU_Emacs
| Homepage: https://www.gnu.org/software/emacs/
| Src: git https://git.savannah.gnu.org/cgit/emacs.git
| Docs: https://www.gnu.org/software/emacs/documentation.html

GNU Emacs is an open source text editor
written in Emacs :ref:`Lisp` and :ref:`C`
that's available for :ref:`Linux`, :ref:`OSX`, and :ref:`Windows`.

- Emacs pinky is allegedly a result of the default emacs
  ``Control`` key keybindings
  https://en.wikipedia.org/wiki/Emacs#Emacs_pinky
- :ref:`Spacemacs` uses the ``Space`` key instead of
  the ``Control`` key.


.. index:: Spacemacs
.. _spacemacs:

Spacemacs
+++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Spacemacs
| Homepage: https://wwww.spacemacs.org/
| Src: https://github.com/syl20bnr/spacemacs
| Docs: https://www.spacemacs.org/doc/DOCUMENTATION
| Docs: https://wwww.spacemacs.org/doc/QUICK_START

Print help:

.. code::

    SPC h SPC


.. index:: org-mode
.. _org-mode:

org-mode
+++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Org-mode
| Homepage: https://orgmode.org/
| Src: git https://code.orgmode.org/bzg/org-mode
| Docs: https://orgmode.org/#docs
| Docs: https://orgmode.org/org.html
| Docs: https://orgmode.org/org.html#Introduction

Org-mode is an open source document editing mode originally
written in :ref:`Emacs Lisp`
for :ref:`Emacs`
that's now available in some form for a number of editors
including :ref:`Vim`.

- Org-mode makes it really easy to work with outlines
  in plain text documents.
- The org-mode wikipedia page lists a number of org-mode
  implementations for other editors.


.. index:: org-babel
.. _org-babel:

org-babel
++++++++++
| Wikipedia: https://en.wikipedia.org/wiki/Org-mode#Org-babel
| Homepage: https://orgmode.org/worg/org-contrib/babel/
| Src: git https://code.orgmode.org/bzg/org-mode
| Docs: https://orgmode.org/manual/Working-with-source-code.html

- Babel makes it possible to execute source code in
  org-mode
- Babel is also the name of an :ref:`ECMAScript` compiler
- :ref:`Jupyter Notebook` with :ref:`Jupytext` and/or
  emacs and vim plugins for working with Jupyter
  are similar to Babel org-mode.



.. index:: VSCode
.. _vscode:

VSCode
~~~~~~~~
| Wikipedia: https://en.wikipedia.org/wiki/Visual_Studio_Code
| Homepage: https://code.visualstudio.com/
| Src: https://github.com/Microsoft/vscode
| Download: https://code.visualstudio.com/Download
| ChocolateyPkg: https://chocolatey.org/packages/vscode
| Docs: https://code.visualstudio.com/docs/getstarted/tips-and-tricks
| Docs: https://code.visualstudio.com/docs/getstarted/keybindings

VSCode (*Visual Studio Code*) is an open source programmer's text editor
written in :ref:`TypeScript`, :ref:`Javascript`, and :ref:`CSS`
that's available for :ref:`Windows`, :ref:`Mac`, and :ref:`Linux`.

* VSCode extensions are written in :ref:`Javascript`.
* VSCode has collaborative editing features with multiple cursors.
* VSCode and MS Visual Studio are different projects.
* VSCode supports many of the Visual Studio keyboard shortcuts.
* There is an official :ref:`Vim` extension for :ref:`VSCode`.
* In VSCode, ``Ctrl+Space`` opens the
  context-sensitive Intellisense Code Completion
* In VScode, ``Ctrl-p`` opens the quick open dialogue
* IN VScode, ``Ctrl-Shift-p`` opens the command palette
  (which lists "all available commands based on your current context")

You can install VSCode by downloading from the Download page
or with :ref:`Chocolatey`:

.. code::

  choco install vscode


.. index:: VScode Flatpak
.. _vscode flatpak:

VSCode Flatpak
~~~~~~~~~~~~~~~
| Flatpak: https://flathub.org/apps/com.visualstudio.code
| Src: https://github.com/flathub/com.visualstudio.code



.. index:: Vim
.. _vim:

Vim
~~~~
| Wikipedia: `<https://en.wikipedia.org/wiki/Vim_(text_editor)>`__
| Homepage: https://www.vim.org/
| Docs: https://www.vim.org/docs.php
| Docs: https://learnxinyminutes.com/docs/vim/
| Src: git https://github.com/vim/vim

ViM (VI-iMproved) is an open source text editor written in :ref:`C`
that's available on very many platforms.

* Vim help can be accessed with ``:help`` and ``:help help``
  (Press ``<esc>``, Type ``:help help``, Press Enter)
* Vi is almost always installed on Linux and BSD boxes.
* Vi is often included with :ref:`Busybox`.
* Vi and Vim are installed with :ref:`OSX`.
* Vi and Vim are installed by default with many :ref:`Linux
  Distributions`
* Vim runs in a terminal, over SSH, and with a GUI window manager
  (Gvim, Macvim)
* Vim configuration is written in the vim language.
* Vim reads a few vimrc configuration files in sequence (``:help vimrc``)
* GVim is Vim for :ref:`Gnome` window manager
* GVim reads a few vimrc configuration files in sequence (``:help gvimrc``)
* MacVim is Vim for :ref:`OSX`
* One way to write changes and exit vim: ``:wq!``
  (Press ``<esc>``, Type ``:wq!``, Press Enter)
* There are many plugins for vim.
* NERDTree is an example of a vim plugin:
  https://github.com/scrooloose/nerdtree (``:help nerdtree``)
* :ref:`SpaceVim` and :ref:`westurner/dotvim` include the NERDtree plugin
* Vim keyboard shortcuts are calling mappings.
* Vim mappings are defined in a vimrc file.
* Examples of vim mappings:
  ``\e`` opens NERDTree, ``\E`` opens NERDTree to the current file
* Vim mappings can be defined for different vim modes:
  ``:map \e`` (command mode), ``:imap \e`` (insert mode) (``:help modes``)
* Press ``i`` or ``a`` while in command mode to enter
  insert or append mode (``:help vim-modes``)
* Press ``<Esc>`` to return to command mode

:ref:`Browser extensions` with vim-style keyboard shortcuts:

* :ref:`Vimium` (Chrome)
* :ref:`Vimperator` (Firefox)
* :ref:`Wasavi` (Chrome, Opera, Firefox)

A number of web apps support vim-style keyboard shortcuts
like ``j`` and ``k`` for up and down:

- GMail (``?`` for help)
- Facebook (``?`` for help)
- Twitter (``?`` for help)


.. index:: neovim
.. neovim:

neovim
++++++++
| Web:  https://neovim.io/
| Src: https://github.com/neovim/neovim
| Docs:  https://neovim.io/doc/
| Docs:  https://neovim.io/doc/user/

Neovim is an open source programmer's editor and :ref:`IDE`
which is a rewrite of :ref:`Vim`.

- Neovim supports :ref:`lua` and :ref:`vimscript` for scripting and
  plugins.
- Neovim does not run in a terminal like :ref:`vim`; neovim is GUI only
  like :ref:`gvim` and :ref:`macvim`.
- Neovim has a builtin :ref:`LSP` client,
  so neovim can use the same LSP language servers as :ref:`vscode`
  for code introspection and analysis.


.. index:: westurner/dotvim
.. _westurner-dotvim:

westurner/dotvim
++++++++++++++++++
| Docs: https://westurner.github.io/dotfiles/usage/#vim
| Src: https://github.com/westurner/dotvim
| Src: https://github.com/westurner/dotvim/blob/master/Makefile
| Src: https://github.com/westurner/dotvim/blob/master/vimrc
| Src: https://github.com/westurner/dotvim/blob/master/vimrc.full.bundles.vimrc
| Src: https://github.com/westurner/dotvim/blob/master/vimrc.tinyvim.bundles.vimrc

westurner/dotvim is a set of plugins and configuration defaults for :ref:`Vim`.


.. index:: SpaceVim
.. _spacevim:

SpaceVim
+++++++++++++
| Homepage: https://spacevim.org/
| Src: https://github.com/SpaceVim/SpaceVim
| Docs: https://spacevim.org/documentation/
| Docs: https://spacevim.org/documentation/#general-key-bindings

SpaceVim is a set of plugins, configuration defaults, and keybindings
for :ref:`Vim`.

- :ref:`Spacemacs` is like SpaceVim for :ref:`Emacs`


.. index:: WRD R&D Documentation
.. _wrdrd documentation:

WRD R&D Documentation
======================
| Docs: https://wrdrd.github.io/docs/
| Docs: https://wrdrd.github.io/docs/tools/
| Src: git https://github.com/wrdrd/docs


*****

`^top^ <#>`__
