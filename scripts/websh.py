#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
"""
web.sh
=======
web.sh is a cross-platform script (web) and API for launching a browser
(with x-www-browser (Linux, Unix), open (OSX), start (Windows),
or python -m webbrowser)

.. note:: This file is vendorable by just copying this file to
   a directory on ``$PATH`` (e.g. ``${__DOTFILES}/scripts/web``);
   it must not import from anything but the Python standard library.

"""

import collections
import distutils.spawn
import logging
import optparse
import os
import subprocess
import sys
try:
    import urlparse
except ImportError:
    import urllib.parse as urlparse
import webbrowser

log = logging.getLogger('websh')
log.setLevel(logging.INFO)


class WebBrowser(object):

    """
    Base class for WebBrowser CLI interaction (open_new_tab)
    """
    platforms = []

    def __init__(self, *args, **kwargs):
        if hasattr(self, 'setUp'):
            self.setUp(*args, **kwargs)
        self.clsmap = self.get_CLSMAP()

    @staticmethod
    def get_CLSMAP():
        clsmap = collections.OrderedDict()
        # classes = [cls for cls in dir() if cls.endswith('_WebBrowser')]
        classes = [
            Python_webbrowser_WebBrowser,
            X_www_WebBrowser,
            OSX_open_WebBrowser,
            Windows_start_WebBrowser,
            # Test_WebBrowser,
        ]
        for cls in classes:
            for platformstr in cls.platforms:
                x = clsmap.setdefault(platformstr, list())
                x.append(cls)
        return clsmap

    @classmethod
    def get_browser_cls(cls, platform=None):
        """
        Returns:
            WebBrowser: class with an open_new_tab classmethod (and .BIN set)
        """
        if platform is None:
            platform = sys.platform
        clsmap = cls.get_CLSMAP()
        platform_classes = clsmap.get(
            platform, clsmap.get(
                '*', (Python_webbrowser_WebBrowser,)))
        return platform_classes[0]

    def open_new_tab(self, url, **kwargs):
        """
        Open a new tab with a browser

        Args:
            url (str): url to open
        Keyword Arguments:
            kwargs (dict): kwargs
        """
        _url = self.expand_url(url)
        cmd = ('/path/to/executable', 'arg1', _url)
        log.info(('cmd', cmd))
        raise NotImplementedError("See: *_WebBrowser")

    @staticmethod
    def x_www_browser(urls, **kwargs):
        """
        Open a new tab in a WebBrowser with WebBrowser.open_new_tab
        like `x-www-browser`

        Args:
            urls (list): URLs to open
            Keyword Arguments:
                webbrowser (WebBrowser): WebBrowser class to open with
                Yields:
                    object: (open_new_tab(url) for url in urls)

        """
        webbrowser = kwargs.get('webbrowser')

        if not webbrowser:
            webbrowser = WebBrowser.get_browser_cls()

        for url in urls:
            try:
                yield webbrowser.open_new_tab(url)
            except Exception as e:
                log.exception(e)
                raise

    @classmethod
    def match_domain(cls, domainstr, suffix=False, matchset=None):
        """
        Match a string against a matchset, optionally with suffix matching.

        Args:
            domainstr (str): string to match against list
        Keyword Arguments:
            suffix (bool): match patterns as suffixes (if False, str.__cmp__)
            matchset (list or None): list of match patterns
                (default: cls.ALWAYS_HTTPS_DOMAINS)
        Returns:
            object or False: matching pattern or False
        """
        match = cls
        if matchset is None:
            matchset = cls.ALWAYS_HTTPS_DOMAINS
        if suffix:
            def matchfunc(x):
                return domainstr.endswith(x)
        else:
            def matchfunc(x):
                return domainstr == x
        for patternstr in matchset:
            if matchfunc(patternstr):
                match = patternstr
                break
        if match != cls:
            return match
        return False

    @classmethod
    def expand_url(cls, url):
        """
        Args:
            url (str): URL to expand
        Returns:
            str: expanded URL or url

        """
        _url = url.strip()
        full_url = 0j

        scheme, netloc, path, query, frag = urlparse.urlsplit(_url)
        log.debug((('url', _url), ('split', tuple(urlparse.urlsplit(_url)))))
        if not scheme:
            # paths that start with '//' should pass through (as with HTML)
            if _url.startswith('//'):
                full_url = _url
            else:
                # if urlsplit doesn't have a netloc, try path
                if not netloc:
                    # if we can recognize the domain, upgrade to https
                    if cls.match_domain(path):
                        full_url = "https://{0}".format(_url)
                    else:
                        if _url:
                            if _url[0] in ('.', '/'):
                                full_url = 'file://{0}'.format(
                                    os.path.abspath(_url))  # PWD
                            else:
                                full_url = "http://{0}".format(_url)
                        else:
                            full_url = _url
                elif cls.match_domain(netloc):
                    full_url = 'https://{0}'.format(_url)
                else:
                    full_url = 'http://{0}'.format(_url)
        else:
            if scheme == 'http':
                if cls.match_domain(netloc):
                    full_url = _url.replace('http:', 'https:', 1)
                else:
                    full_url = _url
            else:
                full_url = _url

        assert full_url != 0j
        if full_url is 0j:
            raise Exception(_url)
            # full_url = _url

        log.info((
            ('url', url),
            ('full_url', full_url)))
        return full_url

    ALWAYS_HTTPS_DOMAINS = {
        "wikipedia.org": 1,
        "en.wikipedia.org": 1,
        "github.com": 1,
        "github.io": 1,
        "bitbucket.org": 1,
        "google.com": 1,
    }


class X_www_WebBrowser(WebBrowser):
    platforms = ['linux']
    XWWWBIN = '/usr/bin/x-www-browser'
    BIN = XWWWBIN

    @classmethod
    def open_new_tab(cls, url, **kwargs):
        _url = cls.expand_url(url)
        cmd = (cls.BIN, _url)
        log.info(('cmd', cmd))
        log.info(('cmdstr', u'# %s' % ' '.join(cmd)))
        output = subprocess.check_output(cmd)  # TODO: remove , url)
        return (_url, output)


class OSX_open_WebBrowser(WebBrowser):
    platforms = ['darwin']
    OPENBIN = distutils.spawn.find_executable('open')
    BIN = OPENBIN

    @classmethod
    def open_new_tab(cls, url, **kwargs):
        _url = cls.expand_url(url)
        cmd = (cls.BIN, _url)
        log.info(('cmd', cmd))
        log.info(('cmdstr', u'# %s' % ' '.join(cmd)))
        output = subprocess.check_output(cmd)
        return (_url, output)


class Windows_start_WebBrowser(WebBrowser):
    platforms = ['win32']

    @classmethod
    def open_new_tab(cls, url, **kwargs):
        _url = cls.expand_url(url)
        cmd = ("start", "", _url)
        log.info(('cmd', cmd))
        log.info(('cmdstr', u'# %s' % ' '.join(cmd)))
        output = subprocess.check_output(cmd)
        return (_url, output)


class Python_webbrowser_WebBrowser(WebBrowser):
    platforms = ['*', 'linux']

    @classmethod
    def open_new_tab(cls, url, **kwargs):
        _url = cls.expand_url(url)
        if webbrowser:
            # show commands in the process tree
            cmd = (sys.executable, '-m', 'webbrowser', _url)
            log.info(('cmd', cmd))
            log.info(('cmdstr', u'# %s' % ' '.join(cmd)))
            output = subprocess.check_output(cmd)
            return _url, output
        raise ImportError('webbrowser')


import unittest


class Test_WebBrowser(unittest.TestCase, WebBrowser):

    @staticmethod
    def open_new_tab(url, *args, **kwargs):
        _url = WebBrowser.expand_url(url)
        return ((_url, args, kwargs), _url)

    def setUp(self):
        self.urls = [
            'http://localhost',
            'http://localhost:8080',
            "wikipedia.org",
            "http://wikipedia.org",
            "en.wikipedia.org",
            "https://en.wikipedia.org",
        ]

    def test_expand_url(self):

        urls = [

            # ("",""), # '' is not True

            ("/", "file:///"),
            ("/path", "file:///path"),
            ("/test2.com", "file:///test2.com"),

            (".", "file://" + os.path.abspath('.')),
            ("./", "file://" + os.path.abspath("./")),
            ("./path?q#f", "file://" + os.path.abspath("./path?q#f")),

            ("path?q#f", "http://path?q#f"),
            ("example.org/path?q#f", "http://example.org/path?q#f"),

            ("//", "//"),
            ("//example.org", "//example.org"),
            ("//h/p?q#f", "//h/p?q#f"),
            ("//h/p?q#f/", "//h/p?q#f/"),

            ("http://h/p?q#f", "http://h/p?q#f"),
            ("https://h/p?q#f", "https://h/p?q#f"),
            ("file://path#fx", "file://path#fx"),

            # cls.ALWAYS_HTTPS_DOMAINS (TODO: match_domain)
            ("http://wikipedia.org",     "https://wikipedia.org"),
            ("wikipedia.org",            "https://wikipedia.org"),
            ("en.wikipedia.org",         "https://en.wikipedia.org"),
            ("https://en.wikipedia.org", "https://en.wikipedia.org"),
            # suffix=False
            ("other.xyz.wikipedia.org",  "http://other.xyz.wikipedia.org"),
            ("./en.wikipedia.org",  "file://" +
             os.path.abspath("./") +
             "/en.wikipedia.org"),
            # TODO: edge cases ?
        ]
        for url, expected_output in urls:
            output = WebBrowser.expand_url(url)
            print(output)
            self.assertTrue(output)
            self.assertEqual(output, expected_output)

    def test_x_www_browser(self):
        output = WebBrowser.x_www_browser(self.urls, webbrowser=Test_WebBrowser)
        print(output)
        for x in output:
            print(x)
            self.assertTrue(output)


def main(argv=None):
    prs = optparse.OptionParser(
        usage="%prog [-b|-x|-o|-s] [-v|-q] <url1> [<url_n>]",
        description=("Open paths or URIS as tabs in the "
                     "configured system default webbrowser"))

    prs.add_option('--webbrowser', '-b', dest='webbrowser',
                   help="Open with `python -m webbrowser`",
                   const=Python_webbrowser_WebBrowser,
                   action='store_const')
    prs.add_option('--x-www-browser', '-x', dest='webbrowser',
                   help="Open with `x-www-browser` (Linux, X)",
                   const=X_www_WebBrowser,
                   action='store_const')
    prs.add_option('--open', '-o', dest='webbrowser',
                   help="Open with `open` (OSX)",
                   const=OSX_open_WebBrowser,
                   action='store_const')
    prs.add_option('--start', '-s', dest='webbrowser',
                   help="Open with `start` (Windows)",
                   const=Windows_start_WebBrowser,
                   action='store_const')

    prs.add_option('-v', '--verbose',
                   dest='verbose',
                   action='store_true',)
    prs.add_option('-q', '--quiet',
                   dest='quiet',
                   action='store_true',)
    prs.add_option('-t', '--test',
                   dest='run_tests',
                   action='store_true',)

    argv = list(argv) if argv is not None else None
    (opts, args) = prs.parse_args(args=argv)

    loglevel = logging.INFO
    if opts.verbose:
        loglevel = logging.DEBUG
    elif opts.quiet:
        loglevel = logging.ERROR

    if loglevel == logging.DEBUG:
        logging.basicConfig(
            level=loglevel,
            format='%(asctime)s.%(msecs)03d %(name)-5s %(lineno)-4s %(levelname)-8s %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S')
    else:
        logging.basicConfig(
            level=loglevel,
            format='%(asctime)s.%(msecs)03d %(name)-5s %(levelname)-6s %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S')

    log.setLevel(loglevel)
    log.debug('argv: %r', argv)
    log.debug('opts: %r', opts)
    log.debug('args: %r', args)

    if opts.run_tests:
        sys.argv = [sys.argv[0]] + args
        import unittest
        sys.exit(unittest.main())

    if not len(args):
        prs.print_help()
        prs.exit(status=2, msg="Err: Specify one or more URLs to open\n")

    for output in WebBrowser.x_www_browser(args, webbrowser=opts.webbrowser):
        log.info(('result', output))

    return 0


if __name__ == "__main__":
    sys.exit(main(argv=sys.argv[1:]))
