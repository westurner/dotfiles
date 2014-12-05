#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
dotfiles
"""

def __read_version_txt():
    """
    read VERSION.txt

    Returns:
        str: version string from the first line of ``VERSION.txt``
    """
    try:
        import pkg_resources
        version = pkg_resources.resource_string(
            'dotfiles', 'VERSION.txt').strip()
        return version
    except ImportError:
        try:
            import os.path, codecs
            HERE = os.path.dirname(__file__)
            with codecs.open(os.path.join(HERE, 'VERSION.txt'), 'utf8') as f:
                version = next(f).strip()
            return version
        except:
            raise
        raise


global __version__
global version
version = __version__ = __read_version_txt()

from dotfiles import cli, venv
__ALL__ = ['__main__', 'version', '__version__', 'venv', 'cli']
__main__ = cli.cli.main
