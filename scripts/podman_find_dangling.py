#!/usr/bin/env python3
"""
podman_find_dangling -- find dangling images (that `podman prune [-a]` doesn't handle), and group them together and inspect
"""

import argparse
import contextlib
import io
import logging
import pprint
import subprocess
import sys

from typing import Callable

import pytest


def get_dangling_image_layers() -> None:
    logger = logging.getLogger("podman_find_dangling")
    # Get dangling image IDs
    logger.info("Running: podman images --filter 'dangling=true' --format '{{.ID}}'")
    img_ids = (
        subprocess.check_output(
            ["podman", "images", "--filter", "dangling=true", "--format", "{{.ID}}"]
        )
        .decode()
        .splitlines()
    )
    logger.debug(f"Found image IDs: {img_ids}")

    # Gather image layer info
    img_layers = []
    for img in img_ids:
        logger.info(
            f"Running: podman image inspect {img} --format '{{.Id}}: {{range .RootFS.Layers}}{{println .}}{{end}}'"
        )
        inspect = (
            subprocess.check_output(
                [
                    "podman",
                    "image",
                    "inspect",
                    img,
                    "--format",
                    "{{.Id}}: {{range .RootFS.Layers}}{{println .}}{{end}}",
                ]
            )
            .decode()
            .replace("\n", ",")
        )
        logger.debug(f"Image {img} inspect output: {inspect.strip()}")
        img_layers.append(inspect.strip())

    # Process and sort
    lines = []
    for entry in img_layers:
        if ":" in entry:
            imgid, layers = entry.split(":", 1)
            layers = layers.replace(",", " ").strip()
            lines.append((layers, imgid))
    lines.sort()

    trie = Trie()
    for layers, imgid in lines:
        trie.insert(layers, imgid)

    groups = trie.collect_groups(min_group_size=2)

    # Print each group, separated by '---'
    first = True
    for group in sorted(groups, key=lambda x: len(x), reverse=True):
        if not first:
            print("---")
        for layers, imgid in group:
            print(f"image={imgid}\n  layers={layers}\n")
        first = False


def longest_common_prefix(strings: list[str]) -> list[list[str]]:
    """
    Groups consecutive strings by their longest common prefix (tokenized by whitespace).
    Returns: list of groups (each group is a list of strings with the same prefix up to the first difference)
    """
    if not strings:
        return []
    groups = []
    current_group = [strings[0]]
    prev_tokens = strings[0].split()
    for s in strings[1:]:
        tokens = s.split()
        # Find common prefix
        prefix = []
        for a, b in zip(prev_tokens, tokens):
            if a == b:
                prefix.append(a)
            else:
                break
        if (
            prefix
            and prefix == prev_tokens[: len(prefix)]
            and prefix == tokens[: len(prefix)]
        ):
            current_group.append(s)
        else:
            groups.append(current_group)
            current_group = [s]
        prev_tokens = tokens
    groups.append(current_group)
    return groups


class TrieNode:
    def __init__(self) -> None:
        self.children: dict[str, TrieNode] = dict()
        self.values: list = []

    def __str__(self):
        return "TrieNode" + str(self.__dict__)

    def __repr__(self):
        return self.__str__()

    # __repr__ = __str__  # + " " + id(self)


class Trie:
    def __init__(self) -> None:
        self.root: TrieNode = TrieNode()

    def insert(self, key: str, value):
        node = self.root
        tokens = key.split()
        for token in tokens:
            if token not in node.children:
                node.children[token] = TrieNode()
            node = node.children[token]
        node.values.append((key, value))

    def collect_groups(self, min_group_size: int = 1) -> list[list[tuple]]:
        """
        Collects all groups of strings that share a prefix (min_group_size or more),
        including internal nodes (not just leaves).
        Returns: list of lists of strings
        """
        groups = []

        def dfs(node):
            # Gather all descendant strings
            all_descendants = list(node.values)
            for child in node.children.values():
                all_descendants.extend(dfs(child))
            if len(all_descendants) >= min_group_size:
                groups.append(list(all_descendants))
            return all_descendants

        dfs(self.root)
        return groups

    def __str__(self):
        return pprint.pformat(self.__dict__, indent=2)

    def __repr__(self):
        return self.__str__()


# pytest-style tests

# Tests for Trie


def test_trienode_str_and_repr():
    node = TrieNode()
    node.values = ["foo", "bar"]
    node.children["x"] = TrieNode()
    s = str(node)
    assert "\n" in s or "{" in s  # pprint or dict
    # __repr__ is not set, but let's check if set
    if hasattr(node, "__repr__") and node.__repr__ is not object.__repr__:
        r = repr(node)
        assert "\n" in r or "{" in r


def test_trie_str_and_repr():
    trie = Trie()
    trie.insert("a b c", "a b c")
    trie.insert("a b d", "a b d")
    s = str(trie)
    assert "\n" in s or "{" in s
    if hasattr(trie, "__repr__") and trie.__repr__ is not object.__repr__:
        r = repr(trie)
        assert "\n" in r or "{" in r


def test_trie_basic() -> None:
    trie = Trie()
    data = ["a b c d", "a b c e", "a b d f", "x y z", "x y z", "x y w"]
    for s in data:
        trie.insert(s, s)
    groups = trie.collect_groups(min_group_size=1)
    # Each input string should appear in at least one group
    for s in data:
        assert any(s in [v for _, v in group] for group in groups)


def test_trie_grouping() -> None:
    trie = Trie()
    data = ["foo bar baz", "foo bar qux", "foo bar baz", "foo quux"]
    for s in data:
        trie.insert(s, s)
    groups = trie.collect_groups(min_group_size=2)
    # There should be a group containing both 'foo bar baz' and 'foo bar qux'
    assert any(
        "foo bar baz" in [v for _, v in g] and "foo bar qux" in [v for _, v in g]
        for g in groups
    )
    # There should be a group containing both 'foo bar baz' strings
    assert any([v for _, v in g].count("foo bar baz") == 2 for g in groups)


def trie_collect_groups(data: list[str]) -> list[list[str]]:
    trie = Trie()
    for s in data:
        trie.insert(s, s)
    groups = trie.collect_groups(min_group_size=1)
    return [[v for _, v in group] for group in groups]


@pytest.fixture(params=[longest_common_prefix, trie_collect_groups])
def group_func(request) -> Callable[[list[str]], list[list[str]]]:
    return request.param


def test_empty(group_func: Callable[[list[str]], list[list[str]]]) -> None:
    assert group_func([]) == []


def test_single(group_func: Callable[[list[str]], list[list[str]]]) -> None:
    data = ["a b c"]
    expected = [["a b c"]]
    result = group_func(data)
    assert any(sorted(g) == sorted(expected[0]) for g in result)


def test_grouping(group_func: Callable[[list[str]], list[list[str]]]) -> None:
    data = [
        "a b c d",
        "a b c e",
        "a b d f",
        "x y z",
        "x y z",
        "x y w",
    ]
    expected = [
        ["a b c d", "a b c e", "a b d f"],
        ["x y z", "x y z", "x y w"],
    ]
    result = group_func(data)
    for group in expected:
        assert any(sorted(g) == sorted(group) for g in result)
    flat = [item for group in result for item in group]
    for s in data:
        assert s in flat


def test_identical_prefix(group_func: Callable[[list[str]], list[list[str]]]) -> None:
    data = ["foo bar", "foo bar", "foo bar"]
    expected = [["foo bar", "foo bar", "foo bar"]]
    result = group_func(data)
    assert any(sorted(g) == sorted(expected[0]) for g in result)


def build_argument_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Find and group dangling podman images by layer prefix.",
        add_help=False,
    )
    parser.add_argument(
        "-h",
        "--help-all",
        action="store_true",
        help="Show help for all commands and subcommands and exit",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="count",
        default=0,
        help="Increase verbosity (can use multiple times)",
    )
    parser.add_argument(
        "-q",
        "--quiet",
        action="count",
        default=0,
        help="Decrease verbosity (can use multiple times)",
    )
    parser.add_argument(
        "--log-level",
        type=str,
        default=None,
        help="Set log level (e.g. DEBUG, INFO, WARNING, ERROR, CRITICAL)",
    )
    subparsers = parser.add_subparsers(dest="command")

    # image command
    image_parser = subparsers.add_parser(
        "image", help="Image operations", add_help=False
    )
    image_subparsers = image_parser.add_subparsers(dest="subcommand")

    # image ls subcommand
    ls_parser = image_subparsers.add_parser(
        "ls", help="List dangling images", add_help=False
    )
    ls_parser.set_defaults(list_dangling=True)

    return parser


# def print_help_clean(parser: argparse.ArgumentParser) -> None:
#     import io

#     buf = io.StringIO()
#     parser.print_help(file=buf)
#     help_text = buf.getvalue()
#     lines = help_text.splitlines()
#     # Remove 'options:' and '-h, --help' if it's the only argument
#     cleaned = []
#     skip_next = False
#     for i, line in enumerate(lines):
#         line_length = len(line)
#         if line.strip().lower() == "options:":
#             # Check if only -h, --help follows
#             if i + 1 < line_length and "-h, --help" in lines[i + 1]:
#                 # Only skip if it's the only option
#                 if i + 2 == line_length or not lines[i + 2].strip():
#                     skip_next = True
#                     continue
#         if skip_next:
#             skip_next = False
#             continue
#         cleaned.append(line)
#     print("\n".join(cleaned))


def print_all_help(parser: argparse.ArgumentParser) -> None:
    def print_help_clean(parser) -> None:
        parser.print_help()

    print_help_clean(parser)
    for action in parser._actions:
        if isinstance(action, argparse._SubParsersAction):
            for cmd, subparser in action.choices.items():
                print(f"\n## command:  {cmd}")
                print_help_clean(subparser)
                for subaction in subparser._actions:
                    if isinstance(subaction, argparse._SubParsersAction):
                        for subcmd, subsubparser in subaction.choices.items():
                            print(f"\n## command:  {cmd} {subcmd}")
                            print_help_clean(subsubparser)
    print()


def set_loglevel_from_args(args: argparse.Namespace) -> None:
    # Default is WARNING (30)
    if getattr(args, "log_level", None):
        level_name = args.log_level.upper()
        if hasattr(logging, level_name):
            level = getattr(logging, level_name)
        else:
            raise ValueError(f"Invalid log level: {args.log_level}")
    else:
        level = logging.WARNING
        if args.verbose:
            if args.verbose == 1:
                level = logging.INFO
            elif args.verbose >= 2:
                level = logging.DEBUG
        if args.quiet:
            if args.quiet == 1:
                level = logging.ERROR
            elif args.quiet >= 2:
                level = logging.CRITICAL
    logging.basicConfig(level=level)


import contextlib  # noqa: E402, F811
import io  # noqa: E402, F811
import sys  # noqa: E402, F811
# import types  # noqa: E402, F811

import pytest  # noqa: E402, F811

# import .podman_find_dangling as pfd
pfd = sys.modules[__name__]


def test_main_no_args(capsys):
    # Should print all help and exit 0
    assert pfd.main([]) == 0
    out = capsys.readouterr().out
    assert "Show help for all commands" in out or "usage:" in out


def test_main_help_flags():
    # Test -h and --help both print help_all
    for args in [["-h"], ["--help"]]:
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf), contextlib.redirect_stderr(buf):
            pfd.main(args)
        out = buf.getvalue()
        assert "Show help for all commands" in out or "usage:" in out


def test_main_help_all_flag(capsys):
    # Should print all help and exit 0
    assert pfd.main(["--help-all"]) == 0
    out = capsys.readouterr().out
    assert "Show help for all commands" in out or "usage:" in out


def test_main_log_level():
    parser = pfd.build_argument_parser()
    for levelname in ["debug", "INFO", "erroR", *logging._nameToLevel.keys()]:
        args, _ = parser.parse_known_args(["--log-level", levelname])
        pfd.set_loglevel_from_args(args)


def test_main_log_level_invalid():
    parser = pfd.build_argument_parser()
    args, _ = parser.parse_known_args(["--log-level", "NOTALEVEL"])
    with pytest.raises(ValueError):
        pfd.set_loglevel_from_args(args)


def test_main_verbose_quiet_levels():
    parser = pfd.build_argument_parser()
    # Test verbose
    args, _ = parser.parse_known_args(["-v"])
    pfd.set_loglevel_from_args(args)
    args, _ = parser.parse_known_args(["-vv"])
    pfd.set_loglevel_from_args(args)
    # Test quiet
    args, _ = parser.parse_known_args(["-q"])
    pfd.set_loglevel_from_args(args)
    args, _ = parser.parse_known_args(["-qq"])
    pfd.set_loglevel_from_args(args)


def test_main_test_flag(monkeypatch):
    called = {}

    def fake_call(args, cwd=None):
        called["args"] = args
        called["cwd"] = cwd
        return 0

    monkeypatch.setattr(pfd.subprocess, "call", fake_call)
    monkeypatch.setattr(
        pfd, "build_argument_parser", lambda: pfd.build_argument_parser()
    )
    # Should call subprocess.call with pytest args
    assert pfd.main(["--test"]) == 0
    assert "pytest" in " ".join(
        called["args"]
    ) or "--cov=podman_find_dangling" in " ".join(called["args"])


def test_main_unknown_args(monkeypatch, capsys):
    # Should not crash on unknown args, just print help
    assert pfd.main(["--unknown"]) == 0
    out = capsys.readouterr().out
    assert "Show help for all commands" in out or "usage:" in out


def test_main_noop(monkeypatch, capsys):
    # Should not crash if no known subcommand
    assert pfd.main(["image"]) == 0
    out = capsys.readouterr().out
    assert "usage:" in out or "Show help for all commands" in out


def test_main_image_ls(monkeypatch):
    # Patch subprocess.check_output to avoid running real podman
    def fake_check_output(cmd, **kwargs):
        if cmd[:3] == ["podman", "images", "--filter"]:
            return b"img1\nimg2\n"
        elif cmd[:3] == ["podman", "image", "inspect"]:
            img = cmd[3]
            if img == "img1":
                return b"img1: layerA,layerB,\n"
            else:
                return b"img2: layerA,layerC,\n"
        raise RuntimeError(f"Unexpected command: {cmd}")

    with pytest.raises(RuntimeError):
        fake_check_output([])

    import contextlib
    import io

    monkeypatch.setattr(subprocess, "check_output", fake_check_output)
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf), contextlib.redirect_stderr(buf):
        main(["image", "ls"])
    out = buf.getvalue()
    assert "layers=layerA layerB image=img1" in out
    assert "layers=layerA layerC image=img2" in out


def test_main_image_ls_cli(monkeypatch, capsys):
    # Patch subprocess.check_output to avoid running real podman
    def fake_check_output(cmd, **kwargs):
        if cmd[:3] == ["podman", "images", "--filter"]:
            return b"img1\nimg2\n"
        elif cmd[:3] == ["podman", "image", "inspect"]:
            img = cmd[3]
            if img == "img1":
                return b"img1: layerA,layerB,\n"
            else:
                return b"img2: layerA,layerC,\n"
        raise RuntimeError(f"Unexpected command: {cmd}")

    with pytest.raises(RuntimeError):
        fake_check_output([])

    monkeypatch.setattr(pfd.subprocess, "check_output", fake_check_output)
    assert pfd.main(["image", "ls"]) == 0
    out = capsys.readouterr().out
    assert "layers=layerA layerB image=img1" in out
    assert "layers=layerA layerC image=img2" in out


def test_main_module_guard(monkeypatch):
    # Simulate running as __main__
    monkeypatch.setattr(sys, "argv", ["podman_find_dangling.py", "--help-all"])
    # Should not raise
    import importlib

    importlib.reload(pfd)


# def test_run_module_with_dash_m(tmp_path):
#     result = subprocess.run([
#         sys.executable, '-m', 'podman_find_dangling', '--help-all'
#     ], cwd=tmp_path, capture_output=True, text=True)
#     assert result.returncode == 0
#     assert 'Show help for all commands' in result.stdout or 'usage:' in result.stdout


def test_main_no_dangling(monkeypatch, capsys):
    # Simulate no dangling images
    def fake_check_output(cmd, **kwargs):
        if cmd[:3] == ["podman", "images", "--filter"]:
            return b""
        # elif cmd[:3] == ['podman', 'image', 'inspect']:
        #     return b''
        raise RuntimeError(f"Unexpected command: {cmd}")

    with pytest.raises(RuntimeError):
        fake_check_output([])

    monkeypatch.setattr(pfd.subprocess, "check_output", fake_check_output)
    assert pfd.main(["image", "ls"]) == 0
    out = capsys.readouterr().out
    assert "layers=" not in out  # No output expected


def test_main_image_ls_grouping(monkeypatch, capsys):
    # Simulate images with same layers (to cover group separator logic)
    def fake_check_output(cmd, **kwargs):
        if cmd[:3] == ["podman", "images", "--filter"]:
            return b"img1\nimg2\nimg3\n"
        elif cmd[:3] == ["podman", "image", "inspect"]:
            img = cmd[3]
            if img == "img1":
                return b"img1: layerA,layerB,\n"
            elif img == "img2":
                return b"img2: layerA,layerB,\n"
            else:
                return b"img3: layerC,layerD,\n"
        raise RuntimeError(f"Unexpected command: {cmd}")

    with pytest.raises(RuntimeError):
        fake_check_output([])

    monkeypatch.setattr(pfd.subprocess, "check_output", fake_check_output)
    assert pfd.main(["image", "ls"]) == 0
    out = capsys.readouterr().out
    # Should print group separator '---' between groups
    assert "---" in out
    assert "layers=layerA layerB image=img1" in out
    assert "layers=layerA layerB image=img2" in out
    assert "layers=layerC layerD image=img3" in out


def test_main_return(monkeypatch):
    # Should always return 0
    assert pfd.main([]) == 0
    assert pfd.main(["--help-all"]) == 0
    assert pfd.main(["image"]) == 0
    assert pfd.main(["image", "ls"]) == 0
    assert pfd.main(["--unknown"]) == 0


def main(argv=None) -> int:
    import os
    import subprocess

    argv = [] if argv is None else argv

    if "--test" in argv:
        cwd = os.path.dirname(__file__)
        filename = os.path.basename(__file__)
        default_args = ["-v", "--cov=.", "--cov-report=term-missing"]

        args_after = argv[argv.index("--test") + 1 :]
        argv.remove("--test")

        pytest_args = [*default_args, *args_after, filename]
        print(("pytest_args", pytest_args))

        print(f"cd {cwd}; " + " ".join(["pytest", *pytest_args]))
        subprocess.call(["pytest", *pytest_args], cwd=cwd)
        return 0

    parser = build_argument_parser()

    if len(argv) == 0:
        print_all_help(parser)
        return 0

    args, remaining = parser.parse_known_args(argv)
    if remaining:
        print_all_help(parser)
        return 0

    # Print help if a command is given without a required subcommand
    if args.command == "image" and not getattr(args, "subcommand", None):
        print_all_help(parser)
        return 0

    if getattr(args, "help_all", False):
        print_all_help(parser)
        return 0

    set_loglevel_from_args(args)

    if getattr(args, "list_dangling", False):
        get_dangling_image_layers()

    return 0


if __name__ == "__main__":
    main(__import__("sys").argv[1:])
