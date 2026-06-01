"""
test_setup_kubectl_oc_sh.py
"""

import os
import re
import subprocess
from pathlib import Path

import pytest

SCRIPTS_PATH = Path(__file__).parent.parent / "scripts"
SETUP_SCRIPT_PATH = str(SCRIPTS_PATH / "setup_kubectl_oc.sh")


@pytest.fixture(name="tmp_path")
def tmp_path_with_teardown(tmp_path_factory, request):
    """
    Overrides the default `tmp_path` fixture to add a teardown step
    that lists the directory contents.
    """
    safe_name = re.sub(r"\W", "_", request.node.name)
    path = tmp_path_factory.mktemp(safe_name)
    print(f"\n[new tmp_path] {path}")
    yield path
    print(f"\n[teardown] ls -altr {path}")
    subprocess.run(["ls", "-altr", str(path)])


@pytest.fixture
def mock_env(tmp_path):
    env = os.environ.copy()
    env["HOME"] = str(tmp_path)
    return env


def run_bash(cmd, env):
    """Helper to source the script and run a bash command/function"""
    return subprocess.run(
        ["bash", "-c", f"source {SETUP_SCRIPT_PATH} && {cmd}"],
        env=env,
        capture_output=True,
        text=True,
    )


def test_parse_args_defaults(mock_env):
    result = run_bash("parse_args && echo $INSTALL_KUBECTL $INSTALL_OC", mock_env)
    assert result.returncode == 0
    assert "true true" in result.stdout.strip()


def test_parse_args_explicit_kubectl(mock_env):
    result = run_bash(
        "parse_args --kubectl --install-dir=/custom/bin && echo $INSTALL_KUBECTL $INSTALL_OC $BIN_DIR",
        mock_env,
    )
    assert result.returncode == 0
    assert "true false /custom/bin" in result.stdout.strip()


def test_parse_args_explicit_oc(mock_env):
    result = run_bash("parse_args --oc && echo $INSTALL_KUBECTL $INSTALL_OC", mock_env)
    assert result.returncode == 0
    assert "false true" in result.stdout.strip()


def test_parse_args_completions(mock_env):
    result = run_bash(
        "parse_args --shells=fish,bash --no-install-completions && echo $SHELLS_TO_INSTALL $INSTALL_COMPLETIONS",
        mock_env,
    )
    assert result.returncode == 0
    assert "fish,bash false" in result.stdout.strip()


def test_setup_env_k8s_offline(mock_env):
    mock_env["SKIP_REMOTE_CHECK_K8S_VERSION"] = "1"
    mock_env["K8S_VER"] = "v1.99.0"
    result = run_bash("setup_env_k8s && echo $K8S_URL", mock_env)
    assert result.returncode == 0
    assert "https://dl.k8s.io/release/v1.99.0/bin/linux/amd64" in result.stdout.strip()


def test_setup_env_oc_redhat_keys(mock_env):
    # Default key (v2)
    res_v2 = run_bash("setup_env_oc && echo $RED_HAT_GPG_FINGERPRINT", mock_env)
    assert "567E347AD0044ADE55BA8A5F199E2F91FD431D51" in res_v2.stdout

    # Optional key (v4)
    res_v4 = run_bash(
        "USE_REDHAT_KEY_V4=true setup_env_oc && echo $RED_HAT_GPG_FINGERPRINT", mock_env
    )
    assert "D246D6276AFEDF8F" in res_v4.stdout


def test_setup_kubectl_oc_shell_completion(mock_env, tmp_path):
    bashrc = tmp_path / ".bashrc"
    zshrc = tmp_path / ".zshrc"

    # Touch files so they exist
    bashrc.touch()
    zshrc.touch()

    mock_env["SHELLS_TO_INSTALL"] = "bash,zsh"
    result = run_bash("setup_kubectl_oc_shell_completion", mock_env)
    assert result.returncode == 0

    bash_content = bashrc.read_text()
    zsh_content = zshrc.read_text()

    zshrc.touch()

    mock_env["SHELLS_TO_INSTALL"] = "bash,zsh"
    result = run_bash("setup_kubectl_oc_shell_completion", mock_env)
    assert result.returncode == 0

    bash_content = bashrc.read_text()
    zsh_content = zshrc.read_text()

    assert "source <(kubectl completion bash)" in bash_content
    assert "source <(oc completion bash)" in bash_content
    assert "source <(kubectl completion zsh)" in zsh_content
    assert "source <(oc completion zsh)" in zsh_content
