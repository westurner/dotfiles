#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
"""
parse_inputrc -- parse an .inputrc file

.. note:: This probably only handles a subset of ``.inputrc`` syntax.

"""

import codecs
import collections
import functools
import json
import logging
import os
import sys

if sys.version_info.major > 2:
    unicode = str

log = logging.getLogger()

class TextFile_(object):

    def __init__(self, *args, **kwargs):
        kwargs.setdefault('encoding',
                          os.environ.get('PYTHONIOENCODING', 'utf8'))
        self.file = codecs.open(*args, **kwargs)

    def __iter__(self):
        """strip whitespace, drop lines starting with #, and drop empty lines
        """
        for line in self.file:
            if line is None:
                break
            line = line.lstrip()
            if line and not line[0] == '#':
                yield line.rstrip()

    def __enter__(self):
        return self

    def __exit__(self):
        self.file.close()
        return False


class OrderedDefaultDict(collections.OrderedDict):
    def __init__(self, default_factory=None, *a, **kw):
        self.default_factory = (
            default_factory if default_factory is not None else
            functools.partial(self.__class__, default_factory=self.__class__))
        collections.OrderedDict.__init__(self, *a, **kw)

    def __missing__(self, key):
        self[key] = value = self.default_factory()
        return value


class InputrcDict(OrderedDefaultDict):
    def to_str_iter(self):
        for mode, items in self.items():
            for subkey, subitems in items.items():
                for key, value in subitems.items():
                    yield unicode('\t').join((
                        unicode(x) for x in [mode, subkey, key, value]))

    def __str__(self):
        return u'\n'.join(self.to_str_iter())

    def to_json(self):
        return json.dumps(self, indent=2)



def parse_inputrc(filename=None):
    """parse a readline .inputrc file

    Keyword Arguments:
        filename (str or None): if None, defaults to ``~/.inputrc``

    Returns:
        InputrcDict: InputrcDict OrderedDict

    .. code:: python

        mode = {None, 'vi', 'emacs'}
        data = collection.OrderedDict()
        data[mode]['settings']['setting_name'] = 'setting_value'
        data[mode]['keybinds']['keyseq'] = 'command'

    """
    if filename is None:
        filename = os.path.expanduser(os.path.join('~', '.inputrc'))

    data = InputrcDict()
    mode = None  # emacs, vi
    modestack = [None]

    #inputrc = distutils.text_file.TextFile(filename)
    for line in TextFile_(filename):
        log.debug(line)
        if line[0:4] == 'set ':
            tokens = line[4:].split(None, 1)
            key, value = [x.strip() for x in tokens]
            log.debug(['set', key, value])
            data[mode]['settings'][key] = value
        elif line[0:8] == '$if mode':
            tokens = line[4:].split('=', 1)
            _, mode = [x.strip() for x in tokens]
            modestack.append(mode)
            log.debug(['mode', mode])
        elif len(modestack) > 1 and line[:6] == '$endif':
            modestack.pop()
            mode = modestack[-1]
            log.debug(['mode', mode])
        elif line[0] == '"':
            tokens = line.split(':', 1)
            key, value = [x.strip() for x in tokens]
            key = key.strip('"')
            log.debug([key, value])
            data[mode]['keybinds'][key] = value
    return data


import unittest


class Test_parse_inputrc(unittest.TestCase):

    def setUp(self):
        pass

    def test_parse_inputrc(self):
        if os.path.exists(os.path.expanduser("~/.inputrc")):
            output = parse_inputrc()
            print(output)

    def tearDown(self):
        pass


def main(argv=None):
    """
    parse_inputrc main function

    Keyword Arguments:
        argv (list): commandline arguments (e.g. sys.argv[1:])
    Returns:
        int: zero
    """
    import logging
    import optparse

    prs = optparse.OptionParser(usage="%prog : args")

    prs.add_option('-f', '--filename',
                   dest='filename',
                   action='store',
                   default=None,
                   help='Path to an .inputrc file')

    prs.add_option('-v', '--verbose',
                    dest='verbose',
                    action='store_true',)
    prs.add_option('-q', '--quiet',
                    dest='quiet',
                    action='store_true',)
    prs.add_option('-t', '--test',
                    dest='run_tests',
                    action='store_true',)


    (opts, args) = prs.parse_args(args=argv)
    loglevel = logging.INFO
    if opts.verbose:
        loglevel = logging.DEBUG
    elif opts.quiet:
        loglevel = logging.ERROR
    logging.basicConfig(level=loglevel)
    argv = list(argv) if argv else []
    log = logging.getLogger()
    log.debug('argv: %r', argv)
    log.debug('opts: %r', opts)
    log.debug('args: %r', args)

    if opts.run_tests:
        import sys
        sys.argv = [sys.argv[0]] + args
        import unittest
        return unittest.main()

    EX_OK = 0
    output = parse_inputrc(filename=None)
    print(output)
    return EX_OK


if __name__ == "__main__":
    import sys
    sys.exit(main(argv=sys.argv[1:]))
