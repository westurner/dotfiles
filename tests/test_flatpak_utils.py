import pytest
import subprocess
import sys
import shutil
import importlib.util
from unittest.mock import patch, MagicMock

spec = importlib.util.spec_from_file_location(
    "flra", "scripts/flatpak_utils.py"
)
flra = importlib.util.module_from_spec(spec)
spec.loader.exec_module(flra)


@patch("shutil.which", return_value="/usr/bin/flatpak")
def test_check_flatpak_installed_success(mock_which):
    flra.check_flatpak_installed()
    mock_which.assert_called_once_with("flatpak")


@patch("shutil.which", return_value=None)
@patch("sys.exit")
def test_check_flatpak_installed_failure(mock_exit, mock_which):
    flra.check_flatpak_installed()
    mock_exit.assert_called_once_with(1)

@patch("subprocess.run")
def test_get_flatpak_data_text(mock_run):
    mock_app_result = MagicMock()
    mock_app_result.stdout = "Ref\truntime\norg.gnome.Terminal/x86_64/stable\torg.gnome.Platform/x86_64/45\n"
    
    mock_runtime_result = MagicMock()
    mock_runtime_result.stdout = "Ref\truntime\norg.gnome.Platform/x86_64/45\t\n"
    
    mock_run.side_effect = [mock_app_result, mock_runtime_result]

    data = flra.get_flatpak_data_text()
    assert len(data) == 2
    assert data[0]["ref"] == "org.gnome.Terminal/x86_64/stable"
    assert data[0]["type"] == "app"
    assert data[0]["runtime"] == "org.gnome.Platform/x86_64/45"
    assert data[1]["ref"] == "org.gnome.Platform/x86_64/45"
    assert data[1]["type"] == "runtime"


def test_organize_data():
    items = [
        {"ref": "org.gnome.Platform/x86_64/45", "type": "runtime", "runtime": None},
        {
            "ref": "org.gnome.Terminal/x86_64/stable",
            "type": "app",
            "runtime": "org.gnome.Platform/x86_64/45",
        },
        {"ref": "org.kde.Platform/x86_64/6", "type": "runtime", "runtime": None},
    ]
    organized = flra.organize_data(items)
    assert len(organized) == 2
    assert "org.gnome.Platform/x86_64/45" in organized
    assert "org.kde.Platform/x86_64/6" in organized
    assert organized["org.gnome.Platform/x86_64/45"] == ["org.gnome.Terminal"]
    assert organized["org.kde.Platform/x86_64/6"] == []


@patch("subprocess.run")
def test_get_unused_runtimes_native(mock_run):
    mock_result = MagicMock()
    mock_result.stdout = " 1.\torg.test\t23.08\n 2.\torg.test2\t45\n"
    mock_run.return_value = mock_result
    
    rts = flra.get_unused_runtimes_native()
    assert len(rts) == 2
    assert rts[0] == ("org.test", "23.08")
    assert rts[1] == ("org.test2", "45")


@patch("subprocess.run")
def test_remove_unused_runtimes(mock_run):
    flra.remove_unused_runtimes(auto_yes=True)
    mock_run.assert_called_once_with(["flatpak", "uninstall", "--unused", "-y"])


def test_print_results_depends_on(capsys):
    runtime_map = {
        "org.freedesktop.Platform.GL.nvidia-535-104-05/x86_64/1.4": [
            "org.gnome.Terminal"
        ],
        "org.gnome.Platform/x86_64/45": ["org.gnome.Terminal", "org.gnome.gedit"],
    }

    flra.print_results(runtime_map, search_str="org.freedesktop.Platform.GL.nvidia")
    captured = capsys.readouterr()

    assert (
        "Runtime: org.freedesktop.Platform.GL.nvidia-535-104-05/x86_64/1.4"
        in captured.out
    )
    assert "org.gnome.Terminal" in captured.out
    assert "Runtime: org.gnome.Platform/x86_64/45" not in captured.out
    assert "org.gnome.gedit" not in captured.out


def test_print_results_depends_on_exact(capsys):
    runtime_map = {
        "org.freedesktop.Platform.GL.nvidia/x86_64/1.4-390": ["org.test.App"],
        "org.freedesktop.Platform.GL.nvidia-535-104-05/x86_64/1.4": ["org.test.App2"],
    }

    flra.print_results(
        runtime_map, exact_name="org.freedesktop.Platform.GL.nvidia/x86_64/1.4-390"
    )
    captured = capsys.readouterr()

    assert "Runtime: org.freedesktop.Platform.GL.nvidia/x86_64/1.4-390" in captured.out
    assert "org.test.App" in captured.out
    assert (
        "Runtime: org.freedesktop.Platform.GL.nvidia-535-104-05/x86_64/1.4"
        not in captured.out
    )
    assert "org.test.App2" not in captured.out


def test_print_results_no_runtimes(capsys):
    runtime_map = {
        "org.gnome.Platform/x86_64/45": ["org.gnome.Terminal", "org.gnome.gedit"],
    }
    flra.print_results(runtime_map, search_str="nvidia")
    captured = capsys.readouterr()
    assert "(No matching runtimes found)" in captured.out

