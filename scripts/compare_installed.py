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


# from: http://unix.stackexchange.com/a/3624

aptitude search '~i !~M' | cut -d" " -f4 | sort -u > currentlyinstalled.txt
MANIFEST_URL="http://mirror.pnl.gov/releases/12.04/ubuntu-12.04.2-desktop-i386.manifest"
wget -qO - ${MANIFEST_URL} | cut -d" " -f1 | sort -u > defaultinstalled.txt
comm -23 currentlyinstalled.txt defaultinstalled.txt
"""

import collections
import subprocess
import os
import tempfile

MANIFEST_URL = "http://mirror.pnl.gov/releases/12.04/ubuntu-12.04.2-desktop-i386.manifest"

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

    adapted from: http://unix.stackexchange.com/a/3624
    """


    output1 = os.path.join(output_dir, 'currentlyinstalled.txt')
    cmd1 = '''aptitude search '~i !~M' -F '%%p' | sort -u > %r''' % (
        output1)

    output2 = os.path.join(output_dir, 'defaultinstalled.txt')
    cmd2 = '''wget -qO - %r | cut -d" " -f1 | sort -u > %r''' % (
        manifest_url, output2)

    if not cache or not all(os.path.exists(p) for p in (output1, output2)):
        ensure_file(cmd1, output1, shell=True)
        ensure_file(cmd2, output2, shell=True)

    installed = list(read_lines(output1))
    default = list(read_lines(output2))


    return installed, default


def create_package_list(default, installed):
    default = default
    installed = installed
    uninstalled = [x for x in default if x not in installed]

    # == comm -23
    also_installed = [x for x in installed if x not in default]

    # 'easiest' solution
    # print "apt-get remove -y %s" % (' '.join(uninstalled))
    # print "apt-get install -y %s" % (' '.join(also_installed))

    # >>> why isn't this good enough?
    # <<< why manually install dependencies that may change?
    # <<< better to select the minimal graph/set/covering
    # <<< though apt-get will just re-compute these dependencies again
    # <<< "i swear i didn't manually install [...]"

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

    apt_cache = apt.Cache()

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

    depends = collections.defaultdict(list)
    visited = {}
    for pkgname in also_installed:
        visit_graph(apt_cache, pkgname, depends, visited)

    minimal = [x for x in also_installed if x not in depends]

    return minimal, also_installed, uninstalled


def pkg_graph():
    """
    mainfunc
    """
    pass

import unittest
import shutil


class Test_pkg_graph(unittest.TestCase):
    def setUp(self):
        self.output_dir = tempfile.mkdtemp(prefix='compare_paths_')

    def tearDown(self):
        shutil.rmtree(self.output_dir)

    def test_get_package_lists(self):
        installed, default = get_package_lists(
            cache=True,
            output_dir=self.output_dir)
        assert isinstance(installed, list)
        assert isinstance(default, list)

    def test_pkg_graph(self):
        installed, default = get_package_lists(
            cache=True,
            output_dir=self.output_dir)
        (minimal, also_installed, uninstalled) = (
            create_package_list(default, installed))
        for x in minimal:
            print("min: %s" % x)
        for x in also_installed:
            print("als: %s" % x)
        for x in uninstalled:
            print("uni: %s" % x)
        # raise Exception()


def main():
    import optparse
    import logging

    prs = optparse.OptionParser(usage="./%prog : args")

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

    pkg_graph()

if __name__ == "__main__":
    main()
