#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
pkgsetcomp module

"""


def __read_version_txt():
    """read VERSION.txt into __version__ and version"""
    import os.path
    SETUPPY_PATH = os.path.abspath(
        os.path.join(os.path.dirname(__file__), '..', '..'))
    with open(os.path.join(SETUPPY_PATH, 'VERSION.txt')) as f:
        version = f.read().strip()
    return version


global __version__
global version
version = __version__ = __read_version_txt()

# __ALL__ = ['pkgsetcomp', 'version', '__version__']
