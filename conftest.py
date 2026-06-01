import os
import datetime
from pathlib import Path
import pytest

def build_timestamp(datetimeobj: datetime.datetime) -> str:
    """Create a dated directory string

    Returns:
        str: "{epoch_utc}-{iso8601_datetime_local_timezone}" 
    """
    if datetimeobj.tzinfo is None:
        # If naive, assume it represents local time and inject system local timezone
        now_local = datetimeobj.astimezone()
    else:
        # Convert an aware datetime into the system local timezone
        now_local = datetimeobj.astimezone()
        
    epoch = int(now_local.timestamp())
    timestamp_localtz = now_local.strftime("%Y-%m-%dT%H-%M-%S%z")
    return f"{epoch}-{timestamp_localtz}"


def pytest_configure(config: pytest.Config) -> None:
    """Configures pytest to save reports and coverage to a timestamped directory.

    Pytest runs this function
    after command-line options have been parsed and all plugins are loaded,
    but before any test collection or execution begins.

    If the `SKIP_PYTEST_REPLOG` environment variable is set, this function yields
    control to the wrapper script. Otherwise, it dynamically overrides pytest
    report paths (JUnit XML, HTML, and coverage data) to use a newly created
    timestamped directory in the `reports/` folder.

    Args:
        config (pytest.Config): The pytest configuration object.
    """
    # Disable the conftest automatic report directory generation 
    # if we are running via the run_tests.sh wrapper
    if os.environ.get("SKIP_PYTEST_REPLOG"):
        return

    timestamp = build_timestamp(datetime.datetime.now()) 
    report_dir = Path("reports") / timestamp
    
    # Store on config to use in pytest_unconfigure for symlinking
    config._report_dir = report_dir
    
    # Create the directory
    report_dir.mkdir(parents=True, exist_ok=True)
    
    # 1. Update JUnit XML path (if --junitxml is used)
    if not config.option.xmlpath:
        config.option.xmlpath = str(report_dir / "pytest-results.xml")
    
    # 2. Update pytest-html report path (if using pytest-html)
    if config.pluginmanager.hasplugin("html"):
        if hasattr(config.option, 'htmlpath') and not config.option.htmlpath:
            config.option.htmlpath = str(report_dir / "report.html")
            
    # 3. Update coverage data/report paths (requires pytest-cov)
    if config.pluginmanager.hasplugin("pytest_cov"):
        # This points the .coverage data file to the dated directory
        os.environ["COVERAGE_FILE"] = str(report_dir / ".coverage")
        
        # Modify the coverage report arguments to output XML/HTML into the dated dir
        if hasattr(config.option, 'cov_report'):
            new_cov_reports = {}
            for report_type, _ in config.option.cov_report.items():
                if report_type == "html":
                    new_cov_reports["html"] = str(report_dir / "htmlcov")
                elif report_type == "xml":
                    new_cov_reports["xml"] = str(report_dir / "cov.xml")
                else:
                    new_cov_reports[report_type] = _
            config.option.cov_report = new_cov_reports

    print(f"\n---> Saving Pytest reports to: {report_dir}\n")

def pytest_unconfigure(config: pytest.Config) -> None:
    """Creates a symlink to the latest timestamped report directory after tests run.
    
    Pytest runs this function
    at the very end of the test session before pytest exits,
    regardless of whether tests passed, failed, or were interrupted.

    If the `SKIP_PYTEST_REPLOG` environment variable is set, this function yields
    control to the wrapper script. Otherwise, it updates the `reports/latest`
    symlink to point to the directory created in `pytest_configure`.

    Args:
        config (pytest.Config): The pytest configuration object.
    """
    # Skip if wrapper script is managing everything
    if os.environ.get("SKIP_PYTEST_REPLOG"):
        return

    report_dir = getattr(config, "_report_dir", None)
    if report_dir and report_dir.exists():
        latest_link = Path("reports") / "latest"
        if latest_link.is_symlink() or latest_link.exists():
            latest_link.unlink()
        latest_link.symlink_to(report_dir.name)

        # Write to SQLite DB to log this run securely via built-in sqlite3
        import sqlite3
        db_path = os.environ.get("PYTEST_REPLOG_DB", "reports/pytest_replog.db")
        Path(db_path).parent.mkdir(parents=True, exist_ok=True)
        try:
            conn = sqlite3.connect(db_path)
            conn.execute('''
                CREATE TABLE IF NOT EXISTS test_runs (
                    epoch INTEGER,
                    timestamp TEXT,
                    out_dir TEXT,
                    exit_code INTEGER
                )
            ''')
            # Extract epoch and timestamp from the report directory name
            parts = report_dir.name.split("-", 1)
            epoch_val = int(parts[0]) if parts[0].isdigit() else 0
            ts_val = parts[1] if len(parts) > 1 else ""

            # Attempt to gather exit code from pytest session
            exit_code = getattr(config, "session", None)
            if exit_code and hasattr(exit_code, "exitstatus"):
                exit_code = int(exit_code.exitstatus)
            else:
                exit_code = None

            conn.execute(
                "INSERT INTO test_runs (epoch, timestamp, out_dir, exit_code) VALUES (?, ?, ?, ?)",
                (epoch_val, ts_val, str(report_dir), exit_code)
            )
            conn.commit()
            conn.close()
        except Exception as e:
            print(f"Failed to log run to sqlite database at {db_path}: {e}")
