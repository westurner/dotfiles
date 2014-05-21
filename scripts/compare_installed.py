#!/usr/bin/env python
# encoding: utf-8
from __future__ import print_function
"""
given
 * a list of default packages
 * a list of installed packages
 * apt-cache dependency graph

find the minimal set of packages that would install everything installed

costs:
 * time to generate solution

benefits:
 * (un) mark manually installed packages that are already dependencies
 * cool application of graph algorithms

See Also:

 * apt-clone

References:

* http://unix.stackexchange.com/a/3624

"""

import collections
import subprocess
import os
import tempfile

here = os.path.join(os.path.dirname(__file__))

# MANIFEST_URL = (
# "http://mirror.pnl.gov/releases/12.04/ubuntu-12.04.4-desktop-i386.manifest"
# )
MANIFEST_URL = os.path.join(here, "testdata",
                            "ubuntu-12.04.4-desktop-i386.manifest")


def ensure_file(command, filename, overwrite=False, shell=False):
    print(command)
    if overwrite or not os.path.exists(filename):
        ret = subprocess.call(command, shell=shell)
        if ret:
            raise Exception(ret)


def read_lines(filename):
    with file(filename) as f:
        for line in f:
            _line = line.strip()
            if _line:
                yield _line


def get_package_lists(manifest_url=MANIFEST_URL, cache=False, output_dir=None):
    """
    Get list of installed packages and manifest packages

    Args:
        manifest_url (str): path or URL of a debian/ubuntu .manifest file
        cache (bool): whether to cache
    Returns:
        tuple of lists: (installed, manifest)

    adapted from: http://unix.stackexchange.com/a/3624
    """
    output1 = os.path.join(output_dir, 'installed.pkgs.txt')
    cmd1 = '''aptitude search '~i !~M' -F '%%p' | sort -u > %r''' % (
        output1)

    output2 = os.path.join(output_dir, 'manifest.pkgs.txt')
    cmd2 = '''(wget -qO - %r || cat %r) | pycut.py -f 0 | sort -u > %r''' % (
        manifest_url, manifest_url, output2)

    for cmd, outputfile in zip((cmd1, cmd2), (output1, output2)):
        if (cache and os.path.exists(outputfile)):
            continue
        ensure_file(cmd, outputfile, shell=True, overwrite=not(cache))

    installed = list(read_lines(output1))
    manifest = list(read_lines(output2))

    return installed, manifest


def import_apt():
    """
    import apt

    Returns:
        module: apt module
    """
    # 'least technical debt' solution
    # import apt_pkg
    try:
        import apt
    except ImportError:
        dist_packages = '/usr/lib/python2.7/dist-packages/'
        import sys
        import os
        import tempfile
        tmp_dirname = tempfile.mkdtemp()

        for modname in ('apt', 'apt_pkg.so'):
            module = os.path.join(dist_packages, modname)
            tmpdir_module = os.path.join(tmp_dirname, modname)
            os.symlink(module, tmpdir_module)

        sys.path.insert(0, tmp_dirname)
        import apt
        apt._tmp_dirname = tmp_dirname
    return apt


class PkgComparison(collections.namedtuple('PkgComparison', (
        'minimal',
        'also_installed',
        'uninstalled',
        'manifest',
        'installed'))):

    """
    A package comparison
    """

    def print_string(self):
        for x in self.minimal:
            print("min: %s" % x)
        for x in self.also_installed:
            print("als: %s" % x)
        for x in self.uninstalled:
            print("uni: %s" % x)

    def write_package_scripts(self, output_dir):
        minimal_sh = os.path.join(output_dir, 'minimal.pkgs.sh')
        also_installed_sh = os.path.join(output_dir, 'also_installed.pkgs.sh')
        uninstalled_sh = os.path.join(output_dir, 'minimal.pkgs.sh')
        with open(minimal_sh, 'w') as f:
            for pkgname in self.minimal:
                print("min: %s" % pkgname)
                f.write("apt-get install %s" % pkgname)
                f.write("\n")
        with open(also_installed_sh, 'w') as f:
            for pkgname in self.also_installed:
                print("als: %s" % pkgname)
                f.write("apt-get install %s" % pkgname)
                f.write("\n")
        with open(uninstalled_sh, 'w') as f:
            for pkgname in self.uninstalled:
                print("uni: %s" % pkgname)
                f.write("apt-get remove %s" % pkgname)
                f.write("\n")


def compare_package_lists(manifest, installed):
    """
    Args:
        default (iterable): names of packages listed in a given MANIFEST
        installed (iterable): names of packages installed locally

    Returns:
        tuple of lists: (minimal, also_installed, uninstalled)
    """

    uninstalled = [x for x in manifest if x not in installed]

    # == comm -23
    also_installed = [x for x in installed if x not in manifest]

    # 'easiest' solution
    # print "apt-get remove -y %s" % (' '.join(uninstalled))
    # print "apt-get install -y %s" % (' '.join(also_installed))

    # >>> why isn't this good enough?
    # <<< why manually install dependencies that may change?
    # <<< better to select the minimal graph/set/covering
    # <<< though apt-get will just re-compute these dependencies again
    # <<< "i swear i didn't manually install [...]"

    # stack = collections.dequeue()
    def visit_graph(apt_cache, pkgname, depends, visited):
        try:
            pkg = apt_cache[pkgname]
        except KeyError as e:
            print(e)  # TODO
            return

        for pkgset in pkg.installedDependencies:
            for pkg in pkgset:
                depends[pkg.name].append(pkgname)
                if pkgname not in visited:
                    visited[pkgname] = True
                    visit_graph(apt_cache, pkg.name, depends, visited)
                # stack.push( pkg['name'] )

    try:
        apt = import_apt()
        apt_cache = apt.Cache()

        depends = collections.defaultdict(list)
        visited = {}
        for pkgname in also_installed:
            visit_graph(apt_cache, pkgname, depends, visited)

        # TODO: more optimal covering
        minimal = [x for x in also_installed if x not in depends]
    finally:
        tmp_dir = getattr(apt, '_tmp_dirname')
        if tmp_dir and os.path.exists(tmp_dir):
            shutil.rmtree(apt._tmp_dirname)

    return PkgComparison(
        minimal,
        also_installed,
        uninstalled,
        manifest,
        installed)


import unittest
import shutil


class Test_compare_installed(unittest.TestCase):

    def setUp(self):
        self.output_dir = tempfile.mkdtemp(prefix='compare_paths_')

    def tearDown(self):
        shutil.rmtree(self.output_dir)

    def test_get_package_lists(self):
        installed, manifest = get_package_lists(
            output_dir=self.output_dir)
        assert isinstance(installed, list)
        assert isinstance(manifest, list)
        self.assertTrue(len(installed))
        self.assertTrue(len(manifest))

    def test_compare_installed(self):
        manifest = ['orange', 'carrot', 'corn']
        installed = ['apple', 'orange', 'peach']

        comparison = compare_package_lists(manifest, installed)

        comparison.print_string()

        self.assertEqual(comparison.uninstalled, ['carrot', 'corn'])
        self.assertEqual(comparison.installed, installed)
        self.assertEqual(comparison.manifest, manifest)
        self.assertEqual(comparison.also_installed, ['apple', 'peach'])

        # self.assertEqual(comparison.minimal, ['...'])

        comparison.write_package_scripts(self.output_dir)

        # raise Exception()

    def test_compare_live_system(self):
        comparison = compare_installed_packages_with_manifest(
            MANIFEST_URL,
            self.output_dir)

        self.assertTrue(len(comparison.manifest))
        self.assertTrue(len(comparison.installed))

        # self.assertTrue(len(comparison.also_installed))
        # self.assertTrue(len(comparison.minimal))
        # self.assertTrue(len(comparison.uninstalled))


def compare_installed_packages_with_manifest(manifest_url, output_dir):
    installed, default = get_package_lists(
        manifest_url=manifest_url,
        cache=True,
        output_dir=output_dir)

    comparison = compare_package_lists(default, installed)

    comparison.print_string()

    comparison.write_package_scripts(output_dir=output_dir)

    return comparison


def main():
    import optparse
    import logging

    prs = optparse.OptionParser(usage="./%prog : [-o <path>] [-m <path/URL>]")

    prs.add_option('-m', '--manifest',
                   dest='manifest',
                   action='store',
                   help='PATH or URL to a debian/ubuntu .manifest',
                   default=MANIFEST_URL)

    prs.add_option('-o', '--output-dir',
                   dest='output_dir',
                   action='store',
                   help="Directory in which to store package lists",
                   default='.')

    prs.add_option('-v', '--verbose',
                   dest='verbose',
                   action='store_true',)
    prs.add_option('-q', '--quiet',
                   dest='quiet',
                   action='store_true',)
    prs.add_option('-t', '--test',
                   dest='run_tests',
                   action='store_true',)

    (opts, args) = prs.parse_args()

    if not opts.quiet:
        logging.basicConfig()

        if opts.verbose:
            logging.getLogger().setLevel(logging.DEBUG)

    if opts.run_tests:
        import sys
        sys.argv = [sys.argv[0]] + args
        import unittest
        exit(unittest.main())

    compare_installed_packages_with_manifest(
        opts.manifest, opts.output_dir)

if __name__ == "__main__":
    main()
