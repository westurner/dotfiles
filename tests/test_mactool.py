import os
import tempfile
import io
import sys
import types
import builtins
import pytest
from scripts import mactool


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
    assert mac.startswith(mactool._V_VMWARE)


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


def test_mac_from_prefix_valid():
    prefix = "00:0c:29"
    mac = mactool.mac_from_prefix(prefix)
    assert mac.startswith("00:0C:29") or mac.startswith("00:0c:29".upper())
    assert len(mac.split(":")) == 6


def test_mac_from_prefix_invalid():
    with pytest.raises(Exception):
        mactool.mac_from_prefix("00:0c")


def test_mac_to_vendor_and_find_vendor(tmp_path, monkeypatch):
    # Create a fake .macvendors file
    macfile = tmp_path / ".macvendors"
    macfile.write_text("00-0C-29,Vmware, Inc.\n00-11-22,Test Vendor\n")
    monkeypatch.setattr(mactool, "_MACFILE", str(macfile))
    # Test mac_to_vendor
    assert "Vmware, Inc." in mactool.mac_to_vendor("00:0c:29:aa:bb:cc")
    # Test find_vendor
    assert "00:0c:29" in mactool.find_vendor("vmware")
    assert "00:11:22" in mactool.find_vendor("test vendor")


def test_mac_from_vendor(tmp_path, monkeypatch):
    macfile = tmp_path / ".macvendors"
    macfile.write_text("00-0C-29,Vmware, Inc.\n00-11-22,Test Vendor\n")
    monkeypatch.setattr(mactool, "_MACFILE", str(macfile))
    mac = mactool.mac_from_vendor("vmware")
    assert mac.startswith("00:0C:29") or mac.startswith("00:0c:29".upper())
    assert len(mac.split(":")) == 6


def test_download_oui(monkeypatch, tmp_path):
    # Patch urlopen to return fake lines
    class FakeFile:
        def __iter__(self):
            return iter(
                [
                    b"00-0C-29   (hex)   VMware, Inc.\n",
                    b"00-11-22   (hex)   Test Vendor\n",
                    b"not a vendor line\n",
                ]
            )

    monkeypatch.setattr(mactool, "urlopen", lambda url: FakeFile())
    macfile = tmp_path / ".macvendors"
    monkeypatch.setattr(mactool, "_MACFILE", str(macfile))
    mactool.download_oui()
    text = macfile.read_text()
    assert "00-0C-29,Vmware, Inc." in text
    assert "00-11-22,Test Vendor" in text


def test_main_download(monkeypatch, tmp_path):
    # Patch download_oui to track call
    called = {}
    monkeypatch.setattr(
        mactool, "download_oui", lambda: called.setdefault("download", True)
    )
    monkeypatch.setattr(mactool, "find_vendor", lambda v: "00:0c:29")
    monkeypatch.setattr(mactool, "mac_to_vendor", lambda m: "Vmware, Inc.")
    monkeypatch.setattr(mactool, "mac_from_vendor", lambda v: "00:0C:29:AA:BB:CC")
    monkeypatch.setattr(mactool, "mac_from_prefix", lambda p: "00:0C:29:AA:BB:CC")

    # Patch OptionParser
    class DummyOptions:
        download = True
        vendor = None
        rand = False
        mac = None
        stdall = False

    class DummyParser:
        def parse_args(self):
            return DummyOptions(), []

        def add_option(self, *a, **k):
            pass

    monkeypatch.setattr(mactool, "OptionParser", lambda *a, **k: DummyParser())
    # Patch sys.argv
    monkeypatch.setattr(sys, "argv", ["mactool.py", "-d"])
    # Run main
    import importlib

    importlib.reload(mactool)
    assert called.get("download")
