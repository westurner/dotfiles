#!/usr/bin/env python
# encoding: utf-8
from __future__ import print_function
"""
deb_scipy : symlink numpy and scipy in from debian packages
"""
import os
import sys
import logging

def apt_install_numpy_scipy():
    cmd = ('sudo','apt-get','install',
            'python-numpy',
            'python-scipy',
            'pyrhon-dateutil',
            'python-tz')
    subprocess.call(cmd)

def apt_install_matplotlib():
    cmd = ('sudo', 'apt-get', 'install',
            'python-matplotlib')
    subprocess.call(cmd)
    # creates:
    #   /usr/lib/pyshared/python2.7/matplotlib  (.so files)
    #   /usr/share/pyshared/matplotlib (.py files)
    #   /usr/share/pyshared/mpl_toolkits
    #   /usr/share/pyshared/pylab.py
    #   TODO: determine how to symlink these into a virtualenv

def pip_install_matplotlib(eggpath='matplotlib'):
    cmd = ('pip','install',eggpath)
    subprocess.call(cmd)

def deb_scipy(venv=None, aptget=False):
    """
    install numpy and scipy
    """

    if aptget:
        apt_install_numpy_scipy()

    if venv is None:
        venv = os.environ['VIRTUAL_ENV']

    sysver = '%d.%d' % (sys.version_info[:2])
    env = dict(
        VIRTUAL_ENV=venv,
        sys_shared="/usr/share/pyshared",
        sys_pkgs="/usr/lib/python%s/dist-packages" % sysver,
        site_pkgs=os.path.join(venv,
            'lib/python%s/site-packages' % sysver),
    )
    pkgs = ['numpy','scipy','dateutil','pytz']
    for pkg in pkgs:
        src=os.path.join(env['sys_pkgs'],pkg)
        dst=os.path.join(env['site_pkgs'],pkg)
        logging.info("symlinking from %r to %r" % (src,dst))
        os.remove(dst)
        # *nix only
        os.link(src, dst)


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

    deb_scipy()
    pip_install_matplotlib()

if __name__ == "__main__":
    main()


