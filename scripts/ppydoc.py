#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
ppydoc
"""

import io
import logging
import re
import subprocess
import sys
import types
import unittest
import webbrowser


__version__ = "0.0.1"


# def ppydoc():
#     """mainfunc

#     Arguments:
#          (str): ...

#     Keyword Arguments:
#          (str): ...

#     Returns:
#         str: ...

#     Yields:
#         str: ...

#     Raises:
#         Exception: ...
#     """
#     pass


class Alias(str):
    pass


class IssueRegexer:
    def __init__(
        self,
        default_prefix="https://github.com/",
        default_org="python",
        default_repo="cpython",
        default_issues_url=None,
        pattern=None,
        flags=0,
    ):
        self.default_prefix = default_prefix
        self.default_org = default_org
        self.default_repo = default_repo
        self.default_issues_url = default_issues_url

        if pattern is None:
            pattern = r"([\w\.-]+/?[\w\.-]+)?#(\d+)\b"
        self.rgx = re.compile(pattern, flags)
        if default_issues_url is None:
            default_issues_url = f"{default_prefix}/{default_org}/{default_repo}"

    def match(string):
        return self.rgx.match(string)

    def findall(self, string):
        return self.rgx.findall(string)

    def build_url(self, n):
        return f"{self.default_issues_url}/{n}"


class TestIssueRegexer(unittest.TestCase):
    def test_regexer(self):
        text = (
            "##heading a/b\n 4z-org32_x/repo#123 four2niner three#234 #567\n"
            "43 five/six#1 s/e#"
        )
        expected = [
            ("4z-org32_x/repo", "123"),
            ("three", "234"),
            ("", "567"),
            ("five/six", "1"),
        ]

        regexer = IssueRegexer(
            default_issues_url="https://github.com/python/cpython/issues"
        )
        matches = regexer.findall(text)
        assert matches == expected


PYTHON_DOCS_PREFIX_EN = "https://docs.python.org/3/"
PYTHON_DOCS_URLS = dict(
    (
        ("contents", None),
        ("whatsnew", None),
        ("tutorial", None),
        ("library", None),
        ("reference", None),
        ("using", None),
        ("howto", None),
        ("reference", None),
        ("distributing", None),
        ("extending", None),
        ("c-api", None),
        ("capi", Alias("c-api")),
        ("faq", None),
        ("deprecations", None),
        ("py-modindex", None),
        ("modindex", Alias("py-modindex.html")),
        ("genindex", None),
        ("glossary", None),  # TODO: glossary.html#term-%s
        ("contents", None),
        ("bugs", None),
        ("datamodel", "https://docs.python.org/3/reference/datamodel.html"),
        ("grammar", "https://docs.python.org/3/reference/grammar.html"),
        ("devguide", "https://devguide.python.org"),
        ("packaging", "https://packaging.python.org"),
        ("pypa", "https://www.pypa.io/en/latest"),
        ("documenting", "https://devguide.python.org/documentation/help-documenting/"),
        ("docs/styleguide", "https://devguide.python.org/documentation/style-guide/"),
        ('cffi', 'https://cffi.readthedocs.io/en/stable/'),
        ("discuss", "https://discuss.python.org/"),
        ("src", "https://github.com/python/cpython"),
        ("cpython", "https://github.com/python/cpython"),
        ("python/cpython", "https://github.com/python/cpython"),
        ("issues", "https://github.com/python/cpython/issues"),
        (
            "issue",
            IssueRegexer(default_issues_url="https://github.com/python/cpython/issues"),
        ),
        ("pulls", "https://github.com/python/cpython/pulls"),
        ("projects", "https://github.com/python/cpython/projects"),
        ("project", "https://github.com/orgs/python/projects"),
    )
)


def guess_python_docs_url(query, domain_prefix=PYTHON_DOCS_PREFIX_EN):
    for path in PYTHON_DOCS_URLS:
        if query.startswith(path):
            urlprefix = PYTHON_DOCS_URLS[path]
            afterquery = query[len(path) :]
            if urlprefix is None:
                return domain_prefix + query
            elif isinstance(urlprefix, Alias):
                return domain_prefix + urlprefix + afterquery
            else:
                if isinstance(urlprefix, types.FunctionType):
                    urlprefix = urlprefix(query)
                    raise Exception(('urlprefix', urlprefix))
                return urlprefix + afterquery

    module = None
    method_rest = ""
    if query.startswith("collections.abc"):
        module = "collections.abc"
        method_rest = query.split(module, 1)[-1][1:]
        if not method_rest.startswith("collections.abc"):
            method_rest = "collections.abc." + method_rest
    elif "." in query:
        module, method_rest = query.split(".", 1)
    else:
        module = query

    if method_rest:
        method_rest = f"#{method_rest}"

    if hasattr(__builtins__, module):
        thing = getattr(__builtins__, module)
        if issubclass(thing, BaseException):
            return f"{domain_prefix}library/exceptions.html#{module}"
        elif getattr(thing, "__class__") == type and module != "object":
            return f"{domain_prefix}library/stdtypes.html#{module}"
        else:
            return f"{domain_prefix}library/functions.html#{module}"

    return f"{domain_prefix}library/{module}{method_rest}"


import unittest


class TestGuessPythonDocs(unittest.TestCase):
    query_urls = [
        ("contents", "https://docs.python.org/3/contents.html"),
        ("math", "https://docs.python.org/3/library/math"),
        ("math.sin", "https://docs.python.org/3/library/math#sin"),
        ("math#sin", "https://docs.python.org/3/library/math#sin"),
        ("library/math#sin", "https://docs.python.org/3/library/math#sin"),
        (
            "collections.abc#collections.abc.Container",
            "https://docs.python.org/3/library/collections.abc#collections.abc.Container",
        ),
        ("tutorial", "https://docs.python.org/3/tutorial"),
        ("reference", "https://docs.python.org/3/reference"),
        ("c-api", "https://docs.python.org/3/c-api"),
        ("capi", "https://docs.python.org/3/c-api"),
        ("dict", "https://docs.python.org/3/library/stdtypes.html#dict"),
        ("object", "https://docs.python.org/3/library/functions.html#object"),
        (
            "SyntaxError",
            "https://docs.python.org/3/library/exceptions.html#SyntaxError",
        ),
        ("grammar", "https://docs.python.org/3/reference/grammar.html"),
        ("discuss", "https://discuss.python.org/"),
        ("src", "https://github.com/python/cpython"),
        ("cpython", "https://github.com/python/cpython"),
        ("python/cpython", "https://github.com/python/cpython"),
        ("issues", "https://github.com/python/cpython/issues"),
        ("pulls", "https://github.com/python/cpython/pulls"),
        ("projects", "https://github.com/python/cpython/projects"),
        ("project", "https://github.com/orgs/python/projects"),
    ]

    def test_guess_python_docs_url(self):
        for query, expected in self.query_urls:
            with self.subTest(query=query):
                output = guess_python_docs_url(query)
                assert output == expected, dict(output=output, expected=expected)


def list_query_patterns(domain_prefix=PYTHON_DOCS_PREFIX_EN):
    patterns = []
    for path, urlprefix in PYTHON_DOCS_URLS.items():
        if urlprefix is None:
            expanded = domain_prefix + path
        elif isinstance(urlprefix, Alias):
            expanded = domain_prefix + urlprefix
        else:
            expanded = urlprefix
        patterns.append((path, expanded))
    patterns.append(('"module"', PYTHON_DOCS_PREFIX_EN + "library/ {module}"))
    return patterns


def print_query_patterns(patterns: list, file=None):
    for path, expanded in patterns:
        # print(f'- {path}  \n  {expanded}', file=file)
        print(f"- {path:12}\t{expanded}", file=file)


class Test_list_query_patterns(unittest.TestCase):
    def test_list_query_patterns(self):
        output = list_query_patterns()
        assert output

    def test_print_query_patterns(self):
        patterns = list_query_patterns()
        stdout = io.StringIO()
        print_query_patterns(patterns, file=stdout)


class Test_ppydoc(unittest.TestCase):
    def test_ppydoc(self):
        pass

    main_args = [
        # None,
        # [],
        ["-h"],
        ["--help"],
    ]

    def test_main_help(self):
        """test the main(sys.argv) CLI function"""
        for args in self.main_args:
            with self.subTest(args=args):
                with self.assertRaises(SystemExit) as exc:
                    captured = sys.stdout = io.StringIO()
                    output = main([__file__] + args)
                sys.stdout = sys.__stdout__
                assert exc.exception.code == 0, ("exc", dir(exc))
                output = captured.getvalue()
                assert "--help" in output, dict(output=output)

    TODO_args = [
        # None,
        # [],
    ]

    def test_main_TODO(self):
        """test the main(sys.argv) CLI function"""
        for query, expected_url in TestGuessPythonDocs.query_urls:
            with self.subTest(query=query):
                captured = sys.stdout = io.StringIO()
                argv = [query]
                output = main(argv)
                sys.stdout = sys.__stdout__
                output = captured.getvalue()
                assert (
                    output[:-1] == f"{expected_url}\n### Guessed url:\n {expected_url}"
                ), dict(output=output, expected_url=expected_url)


def main(argv=None):
    """
    ppydoc main() function

    Keyword Arguments:
        argv (list): commandline arguments (e.g. sys.argv[1:])
    Returns:
        int:
    """
    import argparse

    prs = argparse.ArgumentParser(
        usage="%(prog)s [-h][-v] [-o] <query>",
        description=(
            """Guess the URL to the python docs for the given query

math.sin -> https://docs.python.org/3/library/math#sin\n"""
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    prs.add_argument("-o", "--open", dest="open_in_browser", action="store_true")
    prs.add_argument(
        "-n", "--new-window", dest="open_in_new_window", action="store_true"
    )
    prs.add_argument("-t", "--new-tab", dest="open_in_new_tab", action="store_true")

    prs.add_argument(
        "-l",
        "--list",
        dest="list_query_patterns",
        action="store_true",
        help="List supported query patterns",
    )

    prs.add_argument(
        "-v",
        "--verbose",
        dest="verbose",
        action="store_true",
    )
    prs.add_argument(
        "-q",
        "--quiet",
        dest="quiet",
        action="store_true",
    )
    prs.add_argument(
        "--test",
        dest="run_tests",
        action="store_true",
    )
    prs.add_argument("--version", dest="version", action="store_true")

    argv = list(argv) if argv else []
    (opts, args) = prs.parse_known_args(args=argv)
    loglevel = logging.INFO
    if opts.verbose:
        loglevel = logging.DEBUG
    elif opts.quiet:
        loglevel = logging.ERROR
    logging.basicConfig(level=loglevel)
    log = logging.getLogger("main")
    log.debug("argv: %r", argv)
    log.debug("opts: %r", opts)
    log.debug("args: %r", args)
    if opts.version:
        print(__version__)

    if opts.run_tests:
        sys.argv = [sys.argv[0]] + args
        return unittest.main(verbosity=2)
        # import subprocess
        # return subprocess.call(['pytest', '-v', '-l'] + args + [__file__])

    if opts.list_query_patterns:
        print_query_patterns(list_query_patterns())
        return 0

    if not argv or not args:
        prs.print_help()
        print("")
        prs.error("a query must be specified")

    query = args[0]

    url = guess_python_docs_url(query)
    print(url)

    pydoc_output = subprocess.call(
        ("pydoc", query), env=dict(PAGER="", TERM="dumb")
    )  # TODO: NotImplemented
    print("### Guessed url:\n", url)

    if opts.open_in_browser:
        webbrowser.open(url)
    if opts.open_in_new_window:
        webbrowser.new_window(url)
    if opts.open_in_new_tab:
        webbrowser.new_tab(url)

    EX_OK = 0
    return EX_OK


__main__ = main


if __name__ == "__main__":
    sys.exit(main(argv=sys.argv[1:]))
