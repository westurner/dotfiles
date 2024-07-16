#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
"""
clipboard2txt
"""
#from gi import pygtkcompat
#pygtkcompat.enable()
#pygtkcompat.enable_gtk(version='3.0')

from gi.repository import Gtk as gtk
import glib

import logging
import pathlib
import sys
import unittest

try:
    import pytest
except ImportError:
    pytest = NotImplemented()

__version__ = "0.0.1"

def clipboard2txt(destpath:str|pathlib.Path=None):
    """log clipboard events to a file or stdout

    Arguments:
        destpath:str|pathlib.Path=None (str): ...

    Keyword Arguments:
        destpath:str|pathlib.Path=None (str): ...

    Returns:
        str: ...

    Yields:
        str: ...

    Raises:
        Exception: ...
    """
    if destpath == '-':
        destpath = None

    clipboard = ClipboardParse(destpath=destpath)
    gtk.main()



class ClipboardParse:
    """
    Adapted from:
        - https://stackoverflow.com/a/21337063
    """
    def __init__(self, destpath=None):
        self.destpath = destpath
        self.log = logging.getLogger('clipboard-%s' % destpath)
        window = gtk.Window()
        window.set_title("clipboard2txt")
        window.resize(600,400)
        box = gtk.HBox(homogeneous = True, spacing = 2)
        self.buf = gtk.TextBuffer()
        textInput = gtk.TextView() # TODO: self.buf)
        self.lbl = gtk.Label()
        box.add(self.lbl)
        window.add(box)
        window.connect("destroy", gtk.main_quit)
        window.show_all()
        self.clipboard = gtk.Clipboard()
        self.clipboard.connect("owner-change", self.renderText)

    def renderText(self, clipboard, event):
        logmsg = 'C {0} | E {1}'.format(clipboard, event)
        self.log.info(logmsg)

        clipboard_text = self.clipboard.wait_for_text()
        self.lbl.set_text(clipboard_text)
        print(clipboard_text)
        self.log.debug(clipboard_text)
        if self.destpath is not None:
            with open(self.destpath,'w') as f:
                f.write(txt)
        return False

class Test_clipboard2txt(unittest.TestCase):

    def setUp(self):
        pass

    def test_clipboard2txt(self):
        pass

    def tearDown(self):
        pass


if pytest:
    #def test_clipboard2txt():
    @pytest.mark.parametrize('destpath', [
        [None],
        ['tmp.clipboard2txt.txt']
    ])
    def test_clipboard2txt(destpath=None):
        pass


    def test_main():
        """test the main(sys.argv) CLI function"""
        pass


    @pytest.mark.parametrize('argv', [
        None,
        [],
    ])
    def test_main(argv):
        """test the main(sys.argv) CLI function"""
        output = main(argv)
        assert False


def main(argv=None):
    """
    clipboard2txt main() function

    Keyword Arguments:
        argv (list): commandline arguments (e.g. sys.argv[1:])
    Returns:
        int:
    """
    import optparse

    prs = optparse.OptionParser(
        usage="%prog : args")

    prs.add_option('-p', '--path',
                   dest='destpath',
                   action='store',
                   default="-",
                   help='Path to log clipboard text to (Default: "-" (stdout))')

    prs.add_option('-v', '--verbose',
                   dest='verbose',
                   action='store_true',)
    prs.add_option('-q', '--quiet',
                   dest='quiet',
                   action='store_true',)
    prs.add_option('-t', '--test',
                   dest='run_tests',
                   action='store_true',)
    prs.add_option('--version',
                   dest='version',
                   action='store_true')



    argv = list(argv) if argv else []
    (opts, args) = prs.parse_args(args=argv)
    loglevel = logging.INFO
    if opts.verbose:
        loglevel = logging.DEBUG
    elif opts.quiet:
        loglevel = logging.ERROR
    logging.basicConfig(level=loglevel)
    log = logging.getLogger('main')
    log.debug('argv: %r', argv)
    log.debug('opts: %r', opts)
    log.debug('args: %r', args)
    if opts.version:
        print(__version__)

    if opts.run_tests:
        sys.argv = [sys.argv[0]] + args
        return unittest.main()
        # return subprocess.call(['pytest', '-v'] + args + [__file__])

    EX_OK = 0
    output = clipboard2txt(opts.destpath)
    return EX_OK


if __name__ == "__main__":
    sys.exit(main(argv=sys.argv[1:]))
