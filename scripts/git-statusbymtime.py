#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function

"""
git_statusbymtime
"""
import datetime
import json
import logging
import os
import subprocess
import sys
import unittest

log = logging.getLogger(__name__)


def parse_git_statusline(line):
    """

    Arguments:
        line (str): git status line to parse (``"?? path/to/file"``)

    Returns:
        dict: result object with at least these keys: path, status, mtime
    """
    data = {}
    try:
        # data["line"] = line
        status = line[:2]
        path = line[3:].rstrip()
        data["path"], data["status"] = path, status
        stat = os.stat(path) if os.path.exists(path) else None
        data["mtime"] = getattr(stat, "st_mtime", -1)
    except Exception as e:
        raise Exception(dict(data=data)) from e
    log.debug({'line': line, 'data': data})
    return data


def git_statusbymtime(args, fail_on_error=True, reverse=False):
    """git_statusbymtime

    Arguments:
        args (list): arguments to pass to git

    Keyword Arguments:
        fail_on_error (bool): default=True
        reverse (bool): ...

    Returns:
        list: results sorted by mtime
    """
    results = git_statusbymtime_cmd(args, fail_on_error=fail_on_error)
    results = sorted(results, key=lambda x: x["mtime"], reverse=reverse)
    return results


def git_statusbymtime_cmd(args, fail_on_error=True):
    git_status_cmd = ["git", "status", "-sb", *args]
    log.debug({"git_status_cmd": git_status_cmd})
    proc = subprocess.Popen(git_status_cmd, stdout=subprocess.PIPE, text=True)
    lines_iter = iter(proc.stdout)
    banner = next(lines_iter)
    for line in lines_iter:
        try:
            result = parse_git_statusline(line)
        except Exception as e:
            ctx = dict(cmd=git_status_cmd, proc=proc)  # , data=data)
            if fail_on_error:
                raise Exception(ctx) from e
        yield result


try:
    import pytest
except ImportError:
    pytest = None


if pytest:

    @pytest.mark.parametrize(
        "path,",
        [
            ["."],  # TODO
        ],
    )
    def test_git_statusbymtime(path):
        output = git_statusbymtime(path)
        assert output

    @pytest.mark.parametrize(
        "line,path,status",
        [
            ("?? path/to/the", "path/to/the", "??"),
        ],
    )
    def test_parse_git_statusline(line, path, status):
        output = parse_git_statusline(line)
        assert output
        assert output["path"] == path
        assert output["status"] == status


def main(argv=None):
    """
    git_statusbymtime main() function

    Keyword Arguments:
        argv (list): commandline arguments (e.g. sys.argv[1:])
    Returns:
        int:
    """
    import optparse

    prs = optparse.OptionParser(usage="%prog [-R] [<path>|.]")

    prs.add_option(
        "-R", "--reverse", dest="reverse", action="store_true", default=False
    )

    prs.add_option(
        "--jl", "--jsonlines", dest="jsonlines", action="store_true")

    prs.add_option(
        "--csv", dest="csv", action="store_true")

    prs.add_option(
        "--tsv", dest="tsv", action="store_true")

    prs.add_option(
        "-v",
        "--verbose",
        dest="verbose",
        action="store_true",
    )
    prs.add_option(
        "-q",
        "--quiet",
        dest="quiet",
        action="store_true",
    )
    prs.add_option(
        "-t",
        "--test",
        dest="run_tests",
        action="store_true",
    )

    argv = list(argv) if argv else []
    (opts, args) = prs.parse_args(args=argv)
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

    if opts.run_tests:
        sys.argv = [sys.argv[0]] + args
        # return unittest.main()
        return subprocess.call(["pytest", "-v"] + args + [__file__])

    EX_OK = 0
    results = git_statusbymtime(args, reverse=opts.reverse)
    for result in results:
        datestr = (
            datetime.datetime.fromtimestamp(float(result["mtime"])).isoformat(
                " ", "minutes"
            )
            if result["mtime"]
            else ""
        )
        if opts.jsonlines:
            print(json.dumps(((result["status"], result["path"], datestr))), end='')
            print(',')
        else:
            if not opts.csv or opts.tsv:
                opts.tsv = True
            if opts.csv:
                delim = ","
            elif opts.tsv:
                delim = "\t"
            print(delim.join((
                doublequote(result["status"]),
                doublequote(result["path"]),
                datestr)))
    return EX_OK


def doublequote(str_):
    return '"%s"' % str_.replace('"', '\"')

if __name__ == "__main__":
    sys.exit(main(argv=sys.argv[1:]))
