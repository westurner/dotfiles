"""
test_setup_miniconda_sh
"""
import json
import os
import re
import subprocess
import tempfile
import textwrap
from pathlib import Path
from unittest.mock import patch

import pytest

SCRIPTS_PATH = Path(__file__).parent.parent / "scripts"
SETUP_MINICONDA_SH_PATH = str(SCRIPTS_PATH / "setup_miniconda.sh")


@pytest.fixture(name="tmp_path")
def tmp_path_with_teardown(tmp_path_factory, request):
    """
    Overrides the default `tmp_path` fixture to add logging and a teardown step
    that lists the directory contents.
    """
    safe_name = re.sub(r'\W', '_', request.node.name)
    path = tmp_path_factory.mktemp(safe_name)
    print(f"\n[new tmp_path] {path}")
    yield path
    print(f"\n[teardown] ls -altr {path}")
    subprocess.run(["ls", "-altr", str(path)])


@pytest.fixture
def mock_curl(tmp_path, mock_env):
    """
    Creates a fake `curl` executable in the PATH that intercepts network requests 
    using a dynamically generated JSON configuration.
    """
    curl_path = tmp_path / "curl"
    curl_script = textwrap.dedent("""\
        #!/usr/bin/env python3
        import sys, os, json
        
        config = os.environ.get('CURL_MOCK_CONFIG')
        if not config:
            sys.exit(0)
            
        with open(config) as f:
            mocks = json.load(f)
            
        urls = [arg for arg in sys.argv[1:] if arg.startswith('http')]
        if not urls:
            sys.exit(0)
            
        url = urls[0]
        out_file = None
        if '-o' in sys.argv:
            out_file = sys.argv[sys.argv.index('-o') + 1]
            
        for m_url, resp in mocks.items():
            if m_url in url:
                content = json.dumps(resp['body']) if isinstance(resp.get('body'), dict) else str(resp.get('body', ''))
                if out_file:
                    with open(out_file, 'w') as f:
                        f.write(content)
                else:
                    sys.stdout.write(content)
                sys.exit(resp.get('status', 0))
                
        sys.stderr.write(f"CURL MOCK Error: Response tracking not configured for mocked API -> {url}\\n")
        sys.exit(1)
    """)
    curl_path.write_text(curl_script)
    curl_path.chmod(0o755)
    
    # Prepend fake curl to path
    mock_env["PATH"] = f"{tmp_path}:{mock_env.get('PATH', '')}"
    
    def set_mocks(mocks_dict):
        config_file = tmp_path / "curl_mocks.json"
        config_file.write_text(json.dumps(mocks_dict))
        mock_env["CURL_MOCK_CONFIG"] = str(config_file)
        
    return set_mocks


@pytest.fixture
def mock_env():
    env = os.environ.copy()
    env["DRY_RUN"] = "1"
    env["__WRK"] = "/tmp/mock_wrk"
    env["SKIP_DOWNLOAD"] = "1"
    return env


@pytest.mark.parametrize("install_type, expected_prefix", [
    ("micromamba", "micromamba-"),
    ("miniforge", "Miniforge3-"),
    ("miniconda", "Miniconda3-"),
])
def test_conda_installer_get_filename(mock_env, install_type, expected_prefix):
    mock_env["INSTALL_TYPE"] = install_type
    result = subprocess.run(
        ["bash", "-c", f"source {SETUP_MINICONDA_SH_PATH} && conda_installer_get_filename 3"],
        env=mock_env,
        capture_output=True,
        text=True,
    )
    assert expected_prefix in result.stdout
    if install_type == "micromamba":
        assert ".tar.bz2" in result.stdout
    else:
        assert ".sh" in result.stdout


@pytest.mark.parametrize("install_type", ["miniconda", "miniforge", "micromamba"])
def test_conda_installer_download_dry_run(mock_env, tmp_path, install_type):
    mock_env["INSTALL_TYPE"] = install_type
    mock_env["DRY_RUN"] = "1"
    result = subprocess.run(
        ["bash", "-c", f"source {SETUP_MINICONDA_SH_PATH} && conda_installer_download 3 {tmp_path}"],
        env=mock_env,
        capture_output=True,
        text=True,
    )
    assert "+ curl -SL" in result.stderr
    assert str(tmp_path) in result.stdout


def test_conda_installer_download_with_curl_mocks(mock_env, mock_curl, tmp_path):
    """
    Tests downloading with intercepted hashes via our mock_curl setup
    """
    mock_env["INSTALL_TYPE"] = "miniforge"
    mock_env.pop("SKIP_DOWNLOAD", None)
    mock_env["DRY_RUN"] = "0"
    
    # Configure mock responses
    mock_curl({
        "github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh.sha256": {
            "status": 0,
            "body": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855  Miniforge3-Linux-x86_64.sh\n"
        },
        "github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh": {
            "status": 0,
            "body": "" # empty string body to match the simulated checksum
        }
    })

    result = subprocess.run(
        ["bash", "-c", f"source {SETUP_MINICONDA_SH_PATH} && conda_installer_download 3 {tmp_path}"],
        env=mock_env,
        capture_output=True,
        text=True,
    )
    
    # Let's see if our shell script correctly grabbed the hashes and bypassed true actual network downloads
    assert "INFO: Downloading SHA256 checksum file from" in result.stderr
    assert "Miniforge3-Linux-x86_64.sh: OK" in result.stderr or "Miniforge3-Linux-x86_64.sh: OK" in result.stdout
    assert "ERROR" not in result.stderr


@pytest.fixture(scope="session")
def installer_cache(pytestconfig):
    """Creates a persistent cache folder in .pytest_cache/d/installers"""
    return pytestconfig.cache.mkdir("installers")


@pytest.mark.parametrize("install_type, expected_filename", [
    ("micromamba", "micromamba-linux-64.tar.bz2"),
    ("miniforge", "Miniforge3-Linux-x86_64.sh"),
    ("miniconda", "Miniconda3-latest-Linux-x86_64.sh"),
])
def test_real_download_cached(mock_env, installer_cache, install_type, expected_filename):
    """
    Tests the actual download for both Miniconda and Miniforge, 
    but caches the installer across pytest runs to avoid re-downloading.
    """
    mock_env["INSTALL_TYPE"] = install_type
    mock_env.pop("SKIP_DOWNLOAD", None)
    mock_env["DRY_RUN"] = "0"
    
    expected_installer = installer_cache / expected_filename
    
    # Check if we already downloaded it in a previous pytest run
    if not expected_installer.exists():
        result = subprocess.run(
            ["bash", "-c", f"source {SETUP_MINICONDA_SH_PATH} && conda_installer_download 3 {installer_cache}"],
            env=mock_env,
            capture_output=True,
            text=True,
        )
        assert result.returncode == 0, f"Download failed: {result.stderr}"
    
    # Assert the file is successfully present in the cache
    assert expected_installer.exists()
    assert expected_installer.stat().st_size > 0


@pytest.mark.parametrize("install_type, expected_filename", [
    ("micromamba", "micromamba-linux-64.tar.bz2"),
    ("miniforge", "Miniforge3-Linux-x86_64.sh"),
    ("miniconda", "Miniconda3-latest-Linux-x86_64.sh"),
])
def test_real_install_and_run_commands(mock_env, installer_cache, tmp_path, install_type, expected_filename):
    """
    Tests the actual installation using the cached installer, 
    and verifies that python and pip work correctly inside the new environment.
    """
    mock_env["INSTALL_TYPE"] = install_type
    mock_env.pop("SKIP_DOWNLOAD", None)
    mock_env["DRY_RUN"] = "0"
    
    expected_installer = installer_cache / expected_filename
    
    # Ensure it's downloaded first (uses cache if available)
    if not expected_installer.exists():
        dl_res = subprocess.run(
            ["bash", "-c", f"source {SETUP_MINICONDA_SH_PATH} && conda_installer_download 3 {installer_cache}"],
            env=mock_env,
            capture_output=True,
            text=True,
        )
        assert dl_res.returncode == 0, f"Download failed: {dl_res.stderr}"

    install_prefix = tmp_path / "test_env"
    env_yml_path = tmp_path / "environment.yml"
    env_yml_path.write_text("dependencies:\n  - requests\n")
    
    # Perform the installation targetting the tmp_path isolation with param configurations
    install_res = subprocess.run(
        [
            "bash", "-c",
            f"source {SETUP_MINICONDA_SH_PATH} && conda_installer_install {expected_installer} {install_prefix} '3.11' 'six' {env_yml_path}"
        ],
        env=mock_env,
        capture_output=True,
        text=True,
    )
    assert install_res.returncode == 0, f"Install failed: {install_res.stderr}\n{install_res.stdout}"
    
    python_bin = install_prefix / "bin" / "python"
    assert python_bin.exists(), "Python binary was not created in the installation prefix"
    
    # Verify core tools and commands run successfully inside the cleanly installed environment
    test_commands = [
        [str(python_bin), "--version"],
        [str(python_bin), "-c", "import sys; assert sys.version_info >= (3, 11)"],
        [str(python_bin), "-m", "pip", "--version"],
        [str(python_bin), "-c", "import pip; print('pip imported successfully')"],
        [str(python_bin), "-c", "import conda; print('conda imported successfully')"],
        [str(python_bin), "-c", "import six; print('six imported successfully')"],
        [str(python_bin), "-c", "import requests; print('requests imported successfully')"],
    ]
    
    # Miniforge includes mamba by default, so we can verify it exists
    if install_type == "miniforge":
        mamba_bin = install_prefix / "bin" / "mamba"
        test_commands.extend([
            [str(python_bin), "-c", "import libmambapy; print('libmambapy imported successfully')"],
            [str(mamba_bin), "--version"],
        ])
    elif install_type == "micromamba":
        micromamba_bin = install_prefix / "bin" / "micromamba"
        test_commands.extend([
            [str(micromamba_bin), "--version"],
        ])
    
    for cmd in test_commands:
        cmd_res = subprocess.run(cmd, env=mock_env, capture_output=True, text=True)
        assert cmd_res.returncode == 0, f"Command '{' '.join(cmd)}' failed with error:\n{cmd_res.stderr}\nOutput:\n{cmd_res.stdout}"


