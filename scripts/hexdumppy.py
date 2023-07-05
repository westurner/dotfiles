#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function

"""
hexdumppy
"""
import itertools
import logging
import string
import sys
import unicodedata
import unittest

import pytest

__version__ = "0.0.1"


def hexdumppy(iterable, do_c=True, max_line_length=None):
    """hexdump in Python, with line lengths

    Arguments:
        pylargs (str): ...

    Keyword Arguments:
        pylargs (str): ...

    Returns:
        str: ...

    Yields:
        str: ...

    Raises:
        Exception: ...
    """
    if do_c:
        return hexdumppy_canonical_042(
            iterable, max_line_length=max_line_length
        )


def try_get_unicodedata_name(char):
    try:
        return unicodedata.name(char)
    except ValueError:
        return ""


def char_to_features(char):
    char_repr = repr(char)
    int_character_code = ord(char)
    int_character_code_str = str(int(int_character_code))
    hex_character_code_str = str(hex(int_character_code))
    cellwidth = max(
        len(char_repr),
        len(int_character_code_str),
        len(hex_character_code_str),
    )

    def count_consecutive_chars(s, char_to_check_for=" "):
        for i, char in enumerate(s):
            if char != char_to_check_for:
                break
        return i

    # TODO: readability / performance tradeoff of collections.NamedTuple and @dataclasses
    features = [
        int_character_code_str.rjust(cellwidth),
        hex_character_code_str.rjust(cellwidth),
        try_get_unicodedata_name(char),
    ]
    features.insert(
        0,
        (" " * count_consecutive_chars(features[0]) + char_repr[1:-1]).ljust(
            cellwidth
        ),
    )
    return (cellwidth, features)


def hexdumppy_canonical_04(iterable, max_line_length=79, field_delimiter="|"):
    field_delimiter_len = len(field_delimiter)
    for line in iterable:
        chars = []
        current_output_line_length = 0  # TODO = 1  # line_initial_continuation_character_or_regular_character
        row0, row1, row2 = [], [], []
        for character in line:
            cellwidth, character_thruple = char_to_features(character)

            # If the current output line is going to be too long, print it out
            if max_line_length is not None and (
                current_output_line_length + cellwidth + field_delimiter_len
                > max_line_length
            ):
                print(field_delimiter.join(row0))
                print(field_delimiter.join(row1))
                print(field_delimiter.join(row2))
                print("-" * current_output_line_length)
                row0 = [character_thruple[0]]
                row1 = [character_thruple[1]]
                row2 = [character_thruple[2]]
                current_output_line_length = cellwidth + field_delimiter_len
            else:
                row0.append(character_thruple[0])
                row1.append(character_thruple[1])
                row2.append(character_thruple[2])
                current_output_line_length += cellwidth + field_delimiter_len

        print(field_delimiter.join(row0))
        print(field_delimiter.join(row1))
        print(field_delimiter.join(row2))
        print("-" * current_output_line_length)


def hexdumppy_canonical_042(iterable, max_line_length=79, field_delimiter="|", character_thruple_field_count=4):
    field_delimiter_len = len(field_delimiter)
    for line in iterable:
        chars = []
        current_output_line_length = 0  # TODO = 1  # line_initial_continuation_character_or_regular_character
        rows = [list() for i in range(0, character_thruple_field_count)]
        for character in line:
            cellwidth, character_thruple = char_to_features(character)

            # If the current output line is going to be too long, print it out
            if max_line_length is not None and (
                current_output_line_length + cellwidth + field_delimiter_len
                > max_line_length
            ):
                for row in rows:
                    print(field_delimiter.join(row))
                print("-" * current_output_line_length)

                for i, value in enumerate(character_thruple):
                    rows[i].append(value)
                current_output_line_length = cellwidth + field_delimiter_len
            else:
                for i, value in enumerate(character_thruple):
                    rows[i].append(value)
                current_output_line_length += cellwidth + field_delimiter_len

        for row in rows:
            print(field_delimiter.join(row))
        print("-" * current_output_line_length)


def hexdumppy_canonical_05(iterable, max_line_length=79, field_delimiter="|"):
    field_delimiter_len = len(field_delimiter)
    for line in iterable:
        chars = []
        current_output_line_length = 0  # TODO = 1  # line_initial_continuation_character_or_regular_character
        row0, row1, row2 = [], [], []
        for character in line:
            cellwidth, character_thruple = char_to_features(character)

            # If the current output line is going to be too long, print it out
            if max_line_length is not None and (
                current_output_line_length + cellwidth + field_delimiter_len
                > max_line_length
            ):
                print(field_delimiter.join(row0))
                print(field_delimiter.join(row1))
                print(field_delimiter.join(row2))
                print(
                    ("-" * current_output_line_length - 4) + " ..."
                )  # FIXME: is this even covered by a test?
                row0 = [character_thruple[0]]
                row1 = [character_thruple[1]]
                row2 = [character_thruple[2]]
                current_output_line_length = cellwidth + field_delimiter_len
            else:
                row0.append(character_thruple[0])
                row1.append(character_thruple[1])
                row2.append(character_thruple[2])
                current_output_line_length += cellwidth + field_delimiter_len

        print(field_delimiter.join(row0))
        print(field_delimiter.join(row1))
        print(field_delimiter.join(row2))
        print("-" * current_output_line_length)


def hexdumppy_canonical_01(iterable):
    for line in iterable:
        chars = [char_to_features(char) for char in line]
        print("|".join(c[1][0] for c in chars))
        print("|".join(c[1][1] for c in chars))
        print("|".join(c[1][2] for c in chars))
        # for cellwidth, (r1, r2, r3) in chars:


import collections


def hexdumppy_canonical_03(iterable):
    for line in iterable:
        row1 = collections.deque()
        row2 = collections.deque()
        row3 = collections.deque()
        for char in line:
            char_repr = repr(char)
            int_character_code = ord(char)
            int_character_code_str = str(int(int_character_code))
            hex_character_code_str = str(hex(int_character_code))
            cellwidth = max(
                len(char_repr),
                len(int_character_code_str),
                len(hex_character_code_str),
            )
            row1.append(char_repr.rjust(cellwidth))
            row2.append(int_character_code_str.rjust(cellwidth))
            row3.append(hex_character_code_str.rjust(cellwidth))
        print("|".join(row1))
        print("|".join(row2))
        print("|".join(row3))


TEST_STRINGS = [
    # TODO: names 'one', 'string.printable', 'chr(0-255)'[
    ["123 ABC !?# αβγδε\n"],
    [string.printable],
    ["".join(chr(n) for n in range(256))],
    # Greek Symbols
    [
        "".join(
            chr(n)
            for n in itertools.chain(range(0x3B1, 0x3C2), range(0x3C3, 0x3C9))
        )
    ],
    [
        "".join(
            chr(n)
            for n in itertools.chain(range(0x391, 0x3A2), range(0x3A3, 0x3A9))
        )
    ],
]


@pytest.mark.parametrize(
    "args, iterable, expected_output",
    [
        ["-C", TEST_STRINGS[0], None],
        ["-C", TEST_STRINGS[1], None],
        ["-C", TEST_STRINGS[2], None],
        ["-C", TEST_STRINGS[3], None],
        ["-C", TEST_STRINGS[4], None],
    ],
)
def test_hexdumppy(args, iterable, expected_output, capsys):
    output = hexdumppy(iterable, args)
    assert output == expected_output
    captured_output = capsys.readouterr()
    assert captured_output.out == expected_output
    pass


@pytest.mark.parametrize(
    "argv, expected_output",
    [
        ["-C", None],
    ],
)
def test_main_C(argv, expected_output, capsys):
    """test the main(sys.argv) CLI function"""
    return_code = main(argv)
    assert return_code == 0
    captured_output = capsys.readouterr()
    assert captured_output.out == expected_output
    pass


@pytest.mark.parametrize(
    "argv",
    [
        None,
        [],
    ],
)
def test_main_no_args(argv):
    return_code = main(argv)
    assert return_code == 0
    pass


@pytest.mark.parametrize(
    "argv",
    [
        ["-h"],
        ["--help"],
    ],
)
def test_main(argv):
    with pytest.raises(SystemExit) as err:
        return_code = main(argv)
        assert err.value.code == 0
        assert return_code == 0
    pass


@pytest.mark.parametrize(
    "argv",
    [
        ["-v"],
    ],
)
def test_main_verbose(argv):
    return_code = main(argv)
    assert return_code == 0


@pytest.mark.parametrize(
    "argv",
    [
        ["--version"],
    ],
)
def test_main_verbose(argv):
    return_code = main(argv)
    assert return_code == 0
    pass


def main(argv=None):
    """
    hexdumppy main() function

    Keyword Arguments:
        argv (list): commandline arguments (e.g. sys.argv[1:])
    Returns:
        int:
    """

    import optparse

    prs = optparse.OptionParser(usage="%prog [-h][-v] [-C]")

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

    prs.add_option("--version", dest="version", action="store_true")

    prs.add_option("-C", "--canonical", dest="canonical", action="store_true")
    prs.add_option(
        "--wrap-lines",
        dest="wrap_lines",
        action="store",
        help="Wrap outputlines to n characters",
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
    if opts.version:
        print(__version__)

    if opts.run_tests:
        _sysargv = sys.argv.copy()
        sys.argv = [sys.argv[0]] + args
        # return unittest.main()
        import subprocess

        for arg in ["-h", "--help", "-v", "--version"]:
            if arg in _sysargv:
                args.insert(0, arg)
        args = ["pytest"] + args + [__file__]
        log.debug("pytest args: %r", args)
        return subprocess.call(args)

    if opts.wrap_lines:
        try:
            opts.wrap_lines = int(opts.wrap_lines)
        except ValueError as e:
            prs.error((e, "--wrap-lines expects an int"))

    EX_OK = 0
    if opts.canonical:
        output = hexdumppy(
            TEST_STRINGS[1]
            + ["\n"]
            + TEST_STRINGS[0]
            + ["\n"]
            + TEST_STRINGS[2]
            + ["\n"]
            + TEST_STRINGS[3]
            + ["\n"]
            + TEST_STRINGS[4],
            do_c=True,
            max_line_length=(opts.wrap_lines if opts.wrap_lines else None),
        )
    return EX_OK


if __name__ == "__main__":
    sys.exit(main(argv=sys.argv[1:]))
