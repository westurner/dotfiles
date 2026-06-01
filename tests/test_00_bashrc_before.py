"""
test_00_bashrc_before.py

Tests for etc/bash/00-bashrc.before.sh
"""
import os
import re
import subprocess
from pathlib import Path
import pytest

DOTFILES_PATH = Path(__file__).parent.parent
BASHRC_BEFORE_SCRIPT = DOTFILES_PATH / "etc" / "bash" / "00-bashrc.before.sh"

@pytest.fixture(name="tmp_path")
def tmp_path_with_teardown(tmp_path_factory, request):
    safe_name = re.sub(r'\W', '_', request.node.name)
    path = tmp_path_factory.mktemp(safe_name)
    yield path

@pytest.fixture
def mock_env(tmp_path):
    env = os.environ.copy()
    env["HOME"] = str(tmp_path)
    env["__WRK"] = str(tmp_path / "-wrk")
    # Reset some dotfiles variables to test autodetection
    env.pop("__DOTFILES", None)
    env.pop("WORKON_HOME", None)
    return env

def run_bash_source(script, env, cmd=""):
    """Helper to source a script and run an optional command"""
    return subprocess.run(
        ["bash", "-c", f"source {script} ; {cmd}"],
        env=env,
        capture_output=True,
        text=True,
    )

def test_00_bashrc_before_dotfiles_reload_autodetect_dotfiles_link(mock_env, tmp_path):
    """
    Tests autodetection when 'HOME/-dotfiles' symlink is present.
    """
    # Create fake -dotfiles dir so the script finds it
    fake_dotfiles = tmp_path / "-dotfiles"
    fake_dotfiles.mkdir()
    fake_bash_dir = fake_dotfiles / "etc" / "bash"
    fake_bash_dir.mkdir(parents=True)
    
    # Touch dummy files so `source` doesn't fail
    for f in [
        "01-bashrc.lib.sh", "02-bashrc.platform.sh", "03-bashrc.darwin.sh",
        "04-bashrc.TERM.sh", "05-bashrc.dotfiles.sh", "06-bashrc.completion.sh",
        "07-bashrc.python.sh", "08-bashrc.conda.sh", "07-bashrc.virtualenvwrapper.sh",
        "08-bashrc.gcloud.sh", "10-bashrc.venv.sh", "11-bashrc.venv.pyramid.sh",
        "20-bashrc.editor.sh", "29-bashrc.vimpagers.sh", "30-bashrc.usrlog.sh",
        "30-bashrc.xlck.sh", "40-bashrc.aliases.sh", "42-bashrc.commands.sh",
        "50-bashrc.bashmarks.sh", "70-bashrc.repos.sh", "85-bashrc.agents.sh",
        "99-bashrc.after.sh"
    ]:
        (fake_bash_dir / f).write_text(f"echo 'sourced {f}'\n")
    
    # Add dummy `dotfiles_add_path`
    (fake_bash_dir / "05-bashrc.dotfiles.sh").write_text("dotfiles_add_path() { true; }\n")
    (fake_bash_dir / "02-bashrc.platform.sh").write_text("detect_platform() { true; }\n")

    result = run_bash_source(BASHRC_BEFORE_SCRIPT, mock_env, cmd="echo __DOTFILES=$__DOTFILES")
    
    assert result.returncode == 0
    assert str(fake_dotfiles) in result.stdout
    assert "sourced 01-bashrc.lib.sh" in result.stdout

def test_00_bashrc_before_dotfiles_reload_autodetect_dotfiles_src(mock_env, tmp_path):
    """
    Tests autodetection when 'WORKON_HOME/dotfiles/src/dotfiles' is present.
    """
    mock_env["WORKON_HOME"] = str(tmp_path / "-wrkpth")
    fake_src_dotfiles = tmp_path / "-wrkpth" / "dotfiles" / "src" / "dotfiles"
    fake_src_dotfiles.mkdir(parents=True)
    
    fake_bash_dir = fake_src_dotfiles / "etc" / "bash"
    fake_bash_dir.mkdir(parents=True)
    
    # Touch dummy files so `source` doesn't fail
    for f in ["01-bashrc.lib.sh", "02-bashrc.platform.sh", "03-bashrc.darwin.sh",
              "04-bashrc.TERM.sh", "05-bashrc.dotfiles.sh", "06-bashrc.completion.sh",
              "07-bashrc.python.sh", "08-bashrc.conda.sh", "07-bashrc.virtualenvwrapper.sh",
              "08-bashrc.gcloud.sh", "10-bashrc.venv.sh", "11-bashrc.venv.pyramid.sh",
              "20-bashrc.editor.sh", "29-bashrc.vimpagers.sh", "30-bashrc.usrlog.sh",
              "30-bashrc.xlck.sh", "40-bashrc.aliases.sh", "42-bashrc.commands.sh",
              "50-bashrc.bashmarks.sh", "70-bashrc.repos.sh", "85-bashrc.agents.sh",
              "99-bashrc.after.sh"]:
        (fake_bash_dir / f).touch()
    
    (fake_bash_dir / "05-bashrc.dotfiles.sh").write_text("dotfiles_add_path() { true; }\n")
    (fake_bash_dir / "02-bashrc.platform.sh").write_text("detect_platform() { true; }\n")

    result = run_bash_source(BASHRC_BEFORE_SCRIPT, mock_env, cmd="echo IS_SRC_DETECTED=$__DOTFILES")
    
    assert result.returncode == 0
    assert f"IS_SRC_DETECTED={fake_src_dotfiles}" in result.stdout

def test_00_bashrc_before_detect_platform_mac(mock_env, tmp_path):
    """
    Tests macOS path alteration inside `00-bashrc.before.sh`.
    """
    # Force mock DOTFILES location to use our fake files
    fake_dotfiles = tmp_path / "-dotfiles"
    fake_dotfiles.mkdir()
    mock_env["__DOTFILES"] = str(fake_dotfiles)
    
    fake_bash_dir = fake_dotfiles / "etc" / "bash"
    fake_bash_dir.mkdir(parents=True)
    for f in ["01-bashrc.lib.sh", "02-bashrc.platform.sh", "03-bashrc.darwin.sh",
              "04-bashrc.TERM.sh", "05-bashrc.dotfiles.sh", "06-bashrc.completion.sh",
              "07-bashrc.python.sh", "08-bashrc.conda.sh", "07-bashrc.virtualenvwrapper.sh",
              "08-bashrc.gcloud.sh", "10-bashrc.venv.sh", "11-bashrc.venv.pyramid.sh",
              "20-bashrc.editor.sh", "29-bashrc.vimpagers.sh", "30-bashrc.usrlog.sh",
              "30-bashrc.xlck.sh", "40-bashrc.aliases.sh", "42-bashrc.commands.sh",
              "50-bashrc.bashmarks.sh", "70-bashrc.repos.sh", "85-bashrc.agents.sh",
              "99-bashrc.after.sh"]:
        (fake_bash_dir / f).touch()
    
    # Mock detect_platform to set __IS_MAC
    (fake_bash_dir / "02-bashrc.platform.sh").write_text("detect_platform() { export __IS_MAC=1; }\n")
    (fake_bash_dir / "05-bashrc.dotfiles.sh").write_text("dotfiles_add_path() { true; }\n")
    
    mock_env["PATH"] = "/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

    result = run_bash_source(BASHRC_BEFORE_SCRIPT, mock_env, cmd="echo MODIFIED_PATH=$PATH")
    assert result.returncode == 0

    # Ensure python script path transformation happened properly
    assert "MODIFIED_PATH=/usr/sbin:/sbin:/bin:/usr/local/bin:/usr/bin" in result.stdout
