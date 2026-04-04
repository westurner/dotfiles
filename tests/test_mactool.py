import builtins
import os
import sys
import io
import pytest
from unittest.mock import MagicMock
from scripts import mactool


@pytest.fixture
def mock_macfile(tmp_path, monkeypatch):
    """Fixture to provide a mocked .macvendors file and apply it to the mactool module."""
    monkeypatch.setenv("HOME", str(tmp_path))
    macfile = tmp_path / ".macvendors"
    macfile.write_text("00-0C-29,Vmware, Inc.\n00-11-22,Test Vendor\n")
    return macfile


def test_rand_hex_length():
    result = mactool.rand_hex(6)
    assert len(result) == 6
    for part in result:
        assert len(part) == 2
        int(part, 16)


def test_rand_vmware_format():
    mac = mactool.rand_vmware()
    parts = mac.split(":")
    assert len(parts) == 6

    v_vmware = "00:0C:29"
    assert mac.startswith(v_vmware)


def test_rand_global_format():
    mac = mactool.rand_global()
    parts = mac.split(":")
    assert len(parts) == 6
    for part in parts:
        assert len(part) == 2
        int(part, 16)


def test_format_line():
    line = "00-0C-29   (hex)   VMware, Inc."
    key, vendor = mactool.format_line(line)
    assert key == "00-0C-29"
    assert vendor == "Vmware, Inc."


@pytest.mark.parametrize(
    "prefix",
    [
        "00:0c:29",
        "00-0C-29",
        "00:11",  # 2 octets
    ],
)
def test_mac_from_prefix_valid(prefix):
    mac = mactool.mac_from_prefix(prefix)
    cleaned_prefix = prefix.replace("-", ":").upper()
    assert mac.startswith(cleaned_prefix)
    assert len(mac.split(":")) == 6


@pytest.mark.parametrize(
    "prefix",
    [
        "00:11:22:33:44:55:66",  # Too long
        "",  # Too short / empty
    ],
)
def test_mac_from_prefix_invalid(prefix):
    with pytest.raises(Exception):
        mactool.mac_from_prefix(prefix)


def test_mac_to_vendor_and_find_vendor(mock_macfile):
    # Test mac_to_vendor
    assert "Vmware, Inc." in mactool.mac_to_vendor("00:0c:29:aa:bb:cc")
    # Test find_vendor
    assert "00:0C:29" in mactool.find_vendor("vmware").upper()
    assert "00:11:22" in mactool.find_vendor("test vendor").upper()


def test_find_vendor_not_found(mock_macfile):
    assert mactool.find_vendor("nonexistent vendor") == ""


def test_mac_from_vendor(mock_macfile):
    mac = mactool.mac_from_vendor("vmware")
    assert mac.startswith("00:0C:29") or mac.startswith("00:0c:29".upper())
    assert len(mac.split(":")) == 6


def test_download_oui(mock_macfile, monkeypatch):
    # Patch urlopen to return a fake file object dynamically
    fake_response = io.BytesIO(
        b"00-0C-29   (hex)   VMware, Inc.\n"
        b"00-11-22   (hex)   Test Vendor\n"
        b"not a vendor line\n"
    )
    monkeypatch.setattr(mactool, "urlopen", lambda url: fake_response)

    mactool.download_oui()

    text = mock_macfile.read_text()
    assert "00-0C-29,Vmware, Inc." in text
    assert "00-11-22,Test Vendor" in text


def test_main_download(monkeypatch):
    # Use standard MagicMock to track function calls natively
    mock_download = MagicMock()
    monkeypatch.setattr(mactool, "download_oui", mock_download)
    monkeypatch.setattr(mactool, "find_vendor", lambda v, config=None: "00:0c:29")
    monkeypatch.setattr(mactool, "mac_to_vendor", lambda m, config=None: "Vmware, Inc.")
    monkeypatch.setattr(
        mactool, "mac_from_vendor", lambda v, config=None: "00:0C:29:AA:BB:CC"
    )
    monkeypatch.setattr(
        mactool, "mac_from_prefix", lambda p, config=None: "00:0C:29:AA:BB:CC"
    )

    # Patch sys.argv and invoke cleanly
    monkeypatch.setattr(sys, "argv", ["mactool.py", "-d"])

    # Run main
    mactool.main(["mactool.py", "-d"])

    # Verify mock was called
    mock_download.assert_called_once()


def test_main_random(monkeypatch, capsys):
    monkeypatch.setattr(mactool, "rand_global", lambda: "11:22:33:44:55:66")
    monkeypatch.setattr(
        mactool, "mac_from_vendor", lambda v, config=None: "AA:BB:CC:DD:EE:FF"
    )
    monkeypatch.setattr(
        mactool, "mac_from_prefix", lambda p, config=None: "00:11:22:AA:BB:CC"
    )

    # Test pure random
    monkeypatch.setattr(sys, "argv", ["mactool.py", "-r"])
    mactool.main(["mactool.py", "-r"])
    assert "11:22:33:44:55:66" in capsys.readouterr().out

    # Test random with vendor
    monkeypatch.setattr(sys, "argv", ["mactool.py", "-v", "vmware", "-r"])
    mactool.main(["mactool.py", "-v", "vmware", "-r"])
    assert "AA:BB:CC:DD:EE:FF" in capsys.readouterr().out

    # Test random with mac prefix
    monkeypatch.setattr(sys, "argv", ["mactool.py", "-m", "00:11:22", "-r"])
    mactool.main(["mactool.py", "-m", "00:11:22", "-r"])
    assert "00:11:22:AA:BB:CC" in capsys.readouterr().out


def test_main_random_vendor_not_found(mock_macfile, monkeypatch):
    """Test the equivalent of `mactool.py -v 00:21 -r` which fails if vendor is not found."""
    monkeypatch.setattr(sys, "argv", ["mactool.py", "-v", "00:21", "-r"])
    with pytest.raises(ValueError, match="There were no matches for vendor=00:21"):
        mactool.main(["mactool.py", "-v", "00:21", "-r"])


def test_mac_to_vendor_not_found(mock_macfile):
    with pytest.raises(ValueError, match="There were no matches"):
        mactool.mac_to_vendor("99:99:99")


def test_main_argv_none(monkeypatch, capsys):
    monkeypatch.setattr(sys, "argv", ["mactool.py", "-m", "00:0c:29", "-r"])
    monkeypatch.setattr(
        mactool, "mac_from_prefix", lambda p, config=None: "00:0C:29:AA:BB:CC"
    )
    mactool.main()
    assert "00:0C:29:AA:BB:CC" in capsys.readouterr().out


def test_main_find_vendor(monkeypatch, capsys):
    monkeypatch.setattr(
        mactool, "find_vendor", lambda v, config=None: "00:0C:29,Vmware, Inc."
    )
    mactool.main(["mactool.py", "-v", "vmware"])
    assert "00:0C:29,Vmware, Inc." in capsys.readouterr().out


def test_main_mac_to_vendor(monkeypatch, capsys):
    monkeypatch.setattr(mactool, "mac_to_vendor", lambda m, config=None: "Vmware, Inc.")
    mactool.main(["mactool.py", "-m", "00:0C:29:AA:BB:CC"])
    assert "Vmware, Inc." in capsys.readouterr().out


def test_main_stdall(monkeypatch, capsys):
    monkeypatch.setattr(
        sys, "stdin", io.StringIO("00:0C:29:AA:BB:CC\n00:11:22:33:44:55\n")
    )
    monkeypatch.setattr(mactool, "mac_to_vendor", lambda m, config=None: "Test Vendor")
    mactool.main(["mactool.py", "-a"])
    out = capsys.readouterr().out
    assert "00:0C:29:AA:BB:CC -> Test Vendor" in out
    assert "00:11:22:33:44:55 -> Test Vendor" in out


def test_argcomplete_import_error(monkeypatch):
    original_import = __import__

    def mock_import(name, *args, **kwargs):
        if name == "argcomplete":
            raise ImportError("Fake ImportError for argcomplete")
        return original_import(name, *args, **kwargs)

    monkeypatch.setattr(builtins, "__import__", mock_import)
    mactool.main(["mactool.py", "-m", "00:0C:29", "-r"])


def test_mac_to_vendor_no_macfile(tmp_path, monkeypatch):
    config = mactool.Config(macfile=str(tmp_path / "missing"))
    with pytest.raises(FileNotFoundError):
        mactool.mac_to_vendor("00:00:00", config)

def test_find_vendor_no_macfile(tmp_path, monkeypatch):
    config = mactool.Config(macfile=str(tmp_path / "missing"))
    with pytest.raises(FileNotFoundError):
        mactool.find_vendor("vmware", config)

def test_setup_logging_levels(monkeypatch, capsys):
    from argparse import Namespace
    # Test quiet
    mactool.setup_logging(Namespace(quiet=True))
    assert mactool.logging.getLogger().level == mactool.logging.ERROR
    # Test verbose
    mactool.setup_logging(Namespace(verbose=True))
    assert mactool.logging.getLogger().level == mactool.logging.DEBUG
    # Test loglevel int
    mactool.setup_logging(Namespace(loglevel="30"))
    assert mactool.logging.getLogger().level == 30
    # Test loglevel str
    mactool.setup_logging(Namespace(loglevel="warning"))
    assert mactool.logging.getLogger().level == mactool.logging.WARNING
