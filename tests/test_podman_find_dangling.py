"""
test_podman_find_dangling
"""
import contextlib
import io
import logging
import pytest
import subprocess
import sys

import scripts.podman_find_dangling as pfd


def test_trienode_str_and_repr():
    node = pfd.TrieNode()
    node.values = ["foo", "bar"]
    node.children["x"] = pfd.TrieNode()
    s = str(node)
    assert "\n" in s or "{" in s
    if hasattr(node, "__repr__") and node.__repr__ is not object.__repr__:
        r = repr(node)
        assert "\n" in r or "{" in r


def test_trie_str_and_repr():
    trie = pfd.Trie()
    trie.insert("a b c", "a b c")
    trie.insert("a b d", "a b d")
    s = str(trie)
    assert "\n" in s or "{" in s


def test_trie_basic() -> None:
    trie = pfd.Trie()
    data = ["a b c d", "a b c e", "a b d f", "x y z", "x y z", "x y w"]
    for s in data:
        trie.insert(s, s)
    groups = trie.collect_groups(min_group_size=1)
    for s in data:
        assert any(s in [v for _, v in group] for group in groups)


def test_trie_grouping() -> None:
    trie = pfd.Trie()
    data = ["foo bar baz", "foo bar qux", "foo bar baz", "foo quux"]
    for s in data:
        trie.insert(s, s)
    groups = trie.collect_groups(min_group_size=2)
    assert any(
        "foo bar baz" in [v for _, v in g] and "foo bar qux" in [v for _, v in g]
        for g in groups
    )
    assert any([v for _, v in g].count("foo bar baz") == 2 for g in groups)


def trie_collect_groups(data: list[str]) -> list[list[str]]:
    trie = pfd.Trie()
    for s in data:
        trie.insert(s, s)
    groups = trie.collect_groups(min_group_size=1)
    return [[v for _, v in group] for group in groups]


@pytest.fixture(params=[pfd.longest_common_prefix, trie_collect_groups])
def group_func(request):
    return request.param


def test_empty(group_func) -> None:
    assert group_func([]) == []


def test_single(group_func) -> None:
    data = ["a b c"]
    expected = [["a b c"]]
    result = group_func(data)
    assert any(sorted(g) == sorted(expected[0]) for g in result)


def test_grouping(group_func) -> None:
    data = ["a b c d", "a b c e", "a b d f", "x y z", "x y z", "x y w"]
    expected = [["a b c d", "a b c e", "a b d f"], ["x y z", "x y z", "x y w"]]
    result = group_func(data)
    for group in expected:
        assert any(sorted(g) == sorted(group) for g in result)
    flat = [item for group in result for item in group]
    for s in data:
        assert s in flat


def test_identical_prefix(group_func) -> None:
    data = ["foo bar", "foo bar", "foo bar"]
    expected = [["foo bar", "foo bar", "foo bar"]]
    result = group_func(data)
    assert any(sorted(g) == sorted(expected[0]) for g in result)


def test_main_no_args(capsys):
    assert pfd.main([]) == 0
    out = capsys.readouterr().out
    assert "Show help for all commands" in out or "usage:" in out


def test_main_help_flags():
    for args in [["-h"], ["--help"]]:
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf), contextlib.redirect_stderr(buf):
            pfd.main(args)
        out = buf.getvalue()
        assert "Show help for all commands" in out or "usage:" in out


def test_main_help_all_flag(capsys):
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
    args, _ = parser.parse_known_args(["-v"])
    pfd.set_loglevel_from_args(args)
    args, _ = parser.parse_known_args(["-vv"])
    pfd.set_loglevel_from_args(args)
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
    assert pfd.main(["--test"]) == 0
    assert "pytest" in " ".join(called["args"])


def test_main_unknown_args(capsys):
    assert pfd.main(["--unknown"]) == 0
    out = capsys.readouterr().out
    assert "Show help for all commands" in out or "usage:" in out


def test_main_noop(capsys):
    assert pfd.main(["image"]) == 0
    out = capsys.readouterr().out
    assert "usage:" in out or "Show help for all commands" in out


def test_main_image_ls_cli(monkeypatch, capsys):
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

    monkeypatch.setattr(pfd.subprocess, "check_output", fake_check_output)
    assert pfd.main(["image", "ls"]) == 0
    out = capsys.readouterr().out
    assert "image=img1\n  layers=layerA layerB" in out
    assert "image=img2\n  layers=layerA layerC" in out


def test_main_no_dangling(monkeypatch, capsys):
    def fake_check_output(cmd, **kwargs):
        if cmd[:3] == ["podman", "images", "--filter"]:
            return b""
        raise RuntimeError(f"Unexpected command: {cmd}")

    monkeypatch.setattr(pfd.subprocess, "check_output", fake_check_output)
    assert pfd.main(["image", "ls"]) == 0
    out = capsys.readouterr().out
    assert "layers=" not in out


def test_main_image_ls_grouping(monkeypatch, capsys):
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

    monkeypatch.setattr(pfd.subprocess, "check_output", fake_check_output)
    assert pfd.main(["image", "ls"]) == 0
    out = capsys.readouterr().out
    assert "---" in out
    assert 'image=img1\n  layers=layerA layerB' in out
    assert 'image=img2\n  layers=layerA layerB' in out
    assert 'image=img3\n  layers=layerC layerD' in out


def test_main_return():
    assert pfd.main([]) == 0
    assert pfd.main(["--help-all"]) == 0
    assert pfd.main(["image"]) == 0
    assert pfd.main(["--unknown"]) == 0
