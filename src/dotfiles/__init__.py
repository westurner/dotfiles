#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
pkgsetcomp module

"""


def __read_version_txt():
    """read VERSION.txt into __version__ and version"""
    try:
        import pkg_resources
        version = pkg_resources.resource_string(
            'dotfiles', 'VERSION.txt').rstrip()
        return version
    except:
        try:
            import os.path
            HERE = os.path.dirname(__file__)
            with open(os.path.join(HERE, 'VERSION.txt')) as f:
                version = f.read().strip()
            return version
        except:
            raise
        raise


global __version__
global version
version = __version__ = __read_version_txt()

# __ALL__ = ['pkgsetcomp', 'version', '__version__']
