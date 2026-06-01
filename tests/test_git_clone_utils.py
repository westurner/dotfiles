import os
import subprocess
from pathlib import Path

# Pytest script to trigger the built-in inline Bash test suites
# for the git cloning utilities in /scripts/

SCRIPTS_DIR = Path(__file__).parent.parent / "scripts"


def run_bash_test(script_name, env_var):
    script_path = SCRIPTS_DIR / script_name

    # Assert script exists before running
    assert script_path.exists(), f"Could not find {script_name} at {script_path}"

    env = os.environ.copy()
    env[env_var] = "true"

    # Use bash to load the script (since they are bash scripts)
    result = subprocess.run(
        ["bash", str(script_path)],
        env=env,
        capture_output=True,
        text=True,
    )

    # Ensure exit code is 0 (success)
    assert result.returncode == 0, (
        f"Test {script_name} failed with exit code {result.returncode}:\n{result.stdout}\n{result.stderr}"
    )

    # Ensure the bash test script actually reported "passed!"
    assert "passed!" in result.stdout.lower(), (
        f"Did not find 'passed' keyword in output:\n{result.stdout}"
    )


def test_git_clone_utils():
    run_bash_test("_git-clone-utils.sh", "RUN_TESTS_GIT_CLONE_UTILS")


def test_git_clone_and_remote_upstream():
    run_bash_test(
        "git-clone-and-remote-upstream.sh", "RUN_TESTS_GIT_CLONE_AND_REMOTE_UPSTREAM"
    )


def test_git_fork_and_update_remotes():
    run_bash_test(
        "git-fork-and-update-remotes.sh", "RUN_TESTS_GIT_FORK_AND_UPDATE_REMOTES"
    )


def test_git_clone_pages():
    run_bash_test("git-clone-pages.sh", "RUN_TESTS_GIT_CLONE_PAGES")
