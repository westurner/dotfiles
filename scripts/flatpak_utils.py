#!/usr/bin/env python3
# PYTHON_ARGCOMPLETE_OK
import subprocess
import sys
import shutil
import argparse
import configparser
import os
import logging
import re

log = logging.getLogger(__name__)

_FLATPAK_DIRS_CACHE = None


def get_flatpak_dirs():
    global _FLATPAK_DIRS_CACHE
    if _FLATPAK_DIRS_CACHE is not None:
        return _FLATPAK_DIRS_CACHE
    try:
        res = subprocess.run(
            ["flatpak", "--installations"], capture_output=True, text=True
        )
        _FLATPAK_DIRS_CACHE = [p.strip() for p in res.stdout.split("\n") if p.strip()]
    except Exception:
        _FLATPAK_DIRS_CACHE = [
            "/var/lib/flatpak",
            os.path.expanduser("~/.local/share/flatpak"),
        ]
    return _FLATPAK_DIRS_CACHE


def get_extension_of(ref):
    dirs = get_flatpak_dirs()
    for d in dirs:
        meta_path = os.path.join(d, "runtime", ref, "active/metadata")
        if os.path.exists(meta_path):
            config = configparser.ConfigParser()
            config.read(meta_path)
            if config.has_section("ExtensionOf"):
                ext = config.get("ExtensionOf", "ref", fallback=None)
                if ext and ext.startswith("runtime/"):
                    ext = ext[8:]
                return ext
    return None


def check_flatpak_installed():
    """Checks if flatpak is available in the PATH."""
    if shutil.which("flatpak") is None:
        print("Error: 'flatpak' executable not found in PATH.")
        sys.exit(1)


def get_flatpak_data_text():
    """Executes flatpak list command and returns parsed text data."""
    log.debug("Fetching flatpak app and runtime list data")
    parsed_items = []

    for flatpak_type in ["app", "runtime"]:
        cmd = ["flatpak", "list", "--all", f"--{flatpak_type}", "--columns=ref,runtime"]
        try:
            result = subprocess.run(
                cmd, capture_output=True, text=True, check=True, env={"LANG": "C"}
            )
            # Remove any trailing newlines and split by line
            log.debug(f"Parsing flatpak {flatpak_type} data")
            lines = result.stdout.splitlines()
            if not lines or not lines[0]:
                continue

            start_index = 1 if lines[0].startswith("Ref") else 0

            for line in lines[start_index:]:
                parts = line.strip().split()
                if len(parts) >= 1:
                    parsed_items.append(
                        {
                            "ref": parts[0],
                            "type": flatpak_type,
                            "runtime": parts[1] if len(parts) > 1 else None,
                        }
                    )

        except subprocess.CalledProcessError as e:
            print(f"Error running flatpak command. Exit code: {e.returncode}")
            sys.exit(1)
        except Exception as e:
            print(f"An unexpected error occurred: {e}")
            sys.exit(1)

    return parsed_items


def organize_data(flatpak_items):
    """
    Organizes flatpak items into a dictionary mapping runtimes to dependent apps.
    """
    log.debug("Organizing parsed flatpak items")
    runtime_dependency_map = {}

    for item in flatpak_items:
        if item.get("type") == "runtime":
            ref = item.get("ref", "")
            if ref.startswith("runtime/"):
                runtime_id_str = ref[8:]
            else:
                runtime_id_str = ref
            runtime_dependency_map[runtime_id_str] = []

    for item in flatpak_items:
        if item.get("type") == "app":
            ref = item.get("ref", "")
            if ref.startswith("app/"):
                ref = ref[4:]

            ref_parts = ref.split("/")
            if len(ref_parts) >= 2:
                app_id = ref_parts[0]
            else:
                app_id = ref

            runtime_used = item.get("runtime")

            # flatpak app may use full runtime spec like org.gnome.Platform/x86_64/45
            if runtime_used and runtime_used != "-":
                if runtime_used in runtime_dependency_map:
                    runtime_dependency_map[runtime_used].append(app_id)
                else:
                    unknown_key = f"[Missing or Unknown: {runtime_used}]"
                    if unknown_key not in runtime_dependency_map:
                        runtime_dependency_map[unknown_key] = []
                    runtime_dependency_map[unknown_key].append(app_id)

    return runtime_dependency_map


def print_results(runtime_map, search_str=None, exact_name=None):
    """Prints the organized data formatted nicely to the console."""
    if not runtime_map:
        print("No Flatpak runtimes or applications found (or parsing failed).")
        return

    print("=" * 60)
    print("Flatpak Runtimes and Dependent Applications")
    print("=" * 60)

    sorted_runtimes = sorted(runtime_map.keys())
    found_any = False

    for runtime in sorted_runtimes:
        if exact_name and runtime != exact_name:
            continue
        if search_str and search_str not in runtime:
            continue

        found_any = True
        if runtime.startswith("[Missing"):
            continue
        apps = runtime_map[runtime]
        app_count = len(apps)

        print(f"\n📦 Runtime: {runtime}")

        if app_count == 0:
            ext_of = get_extension_of(runtime)
            if ext_of:
                print(f"  🔗 Extension of: {ext_of}")
                if ext_of in runtime_map and runtime_map[ext_of]:
                    parent_apps = runtime_map[ext_of]
                    print(
                        f"   🔄 Transitive dependencies: {len(parent_apps)} via {ext_of!r}"
                    )
                    for app_id in sorted(parent_apps):
                        print(f"      - {app_id}")
                else:
                    print(
                        "  ❌ (No installed applications depend on the parent runtime either)"
                    )
            else:
                print("  ❌ (No installed applications depend on this runtime)")
        else:
            print(f"  ✅ Dependencies ({app_count}):")
            for app_id in sorted(apps):
                print(f"   🔸 {app_id}")

    if not found_any:
        print("\n  (No matching runtimes found)")

    print("\n" + "=" * 60)


import re


def get_unused_runtimes_native():
    """Returns a list of unused runtimes reported natively by flatpak uninstall --unused."""
    log.debug("Checking for unused runtimes")
    cmd = ["flatpak", "uninstall", "--unused"]
    try:
        result = subprocess.run(
            cmd, input="n\n", capture_output=True, text=True, env={"LANG": "C"}
        )
        runtimes = []
        for line in result.stdout.splitlines():
            m = re.match(r"^\s*\d+\.\s+(\S+)\s+(\S+)", line)
            if m:
                runtimes.append((m.group(1), m.group(2)))
        return runtimes
    except Exception:
        return []


def remove_unused_runtimes(auto_yes=False):
    log.info("Delegating unused runtime removal to flatpak natively...")
    cmd = ["flatpak", "uninstall", "--unused"]
    if auto_yes:
        cmd.append("-y")
    subprocess.run(cmd)


def get_host_nvidia_version():
    try:
        with open("/proc/driver/nvidia/version", "r") as f:
            content = f.read()
            m = re.search(r"Module\s+([\d\.]+)", content)
            if m:
                return m.group(1)
    except Exception:
        pass

    try:
        res = subprocess.run(
            ["nvidia-smi", "--query-gpu=driver_version", "--format=csv,noheader"],
            capture_output=True,
            text=True,
        )
        version = res.stdout.strip().split("\n")[0]
        if version:
            return version
    except Exception:
        pass

    return None


def parse_nvidia_version(ref):
    """Parses an NVIDIA runtime string into a tuple of ints, e.g. (570, 153, 2)."""
    m = re.search(r"nvidia-([\d\-]+)", ref)
    if m:
        ver_parts = m.group(1).split("-")
        try:
            return tuple(int(x) for x in ver_parts)
        except ValueError:
            pass
    return (0,)


def clean_old_nvidia_runtimes(auto_yes=False):
    log.info("Checking for old NVIDIA runtimes")
    host_version = get_host_nvidia_version()
    if not host_version:
        print("Could not determine host NVIDIA driver version.")
        return

    print(f"Detected host NVIDIA driver version: {host_version}")
    flatpak_ver = host_version.replace(".", "-")

    cmd = ["flatpak", "list", "--runtime", "--columns=ref"]
    res = subprocess.run(cmd, capture_output=True, text=True)

    to_remove = []
    regex = re.compile(r"nvidia-([\d\-]+)/")
    for line in res.stdout.split("\n"):
        ref = line.strip()
        m = regex.search(ref)
        if m:
            ver = m.group(1)
            if ver != flatpak_ver:
                to_remove.append(ref)

    if not to_remove:
        print(f"No old NVIDIA runtimes found. All match {host_version}.")
        return

    to_remove.sort(key=parse_nvidia_version)

    print(
        f"\nFound {len(to_remove)} old NVIDIA runtime(s) not matching {host_version}:"
    )
    for ref in to_remove:
        print(f"  flatpak uninstall {ref}")

    if not auto_yes:
        print(
            "\nDry run by default. To actually remove them, run the commands above manually or pass -y / --yes."
        )
    else:
        print("\nRemoving old NVIDIA runtimes...")
        for ref in to_remove:
            print(f"-- Uninstalling {ref}...")
            subprocess.run(["flatpak", "uninstall", "-y", ref])


def print_default_report():
    """Prints sorted list of runtimes and applications."""
    log.debug("Generating default report")
    cmd = ["flatpak", "list", "--all", "--columns=runtime,application,branch,version"]

    def cmdtostr(cmd):
        return f"$ {str.join(' ', cmd)}"

    log.info(cmdtostr(cmd))

    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, check=True, env={"LANG": "C"}
        )
        lines = result.stdout.splitlines()
        if not lines:
            print("No flatpaks installed.")
            return

        header = lines[0]
        data_lines = sorted(lines[1:])

        print(header)
        for line in data_lines:
            print(line)

    except subprocess.CalledProcessError as e:
        print(f"Error running flatpak command. Exit code: {e.returncode}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


COLORS = {
    "DEBUG": "\033[36m",  # Cyan
    "INFO": "\033[32m",  # Green
    "WARNING": "\033[33m",  # Yellow
    "ERROR": "\033[31m",  # Red
    "CRITICAL": "\033[1;31m",  # Bold Red
}
RESET = "\033[0m"


class ColorFormatter(logging.Formatter):
    def __init__(self, use_color=True, fmt=None):
        super().__init__(fmt=fmt)
        self.use_color = use_color

    def format(self, record):
        msg = super().format(record)
        if self.use_color:
            color = COLORS.get(record.levelname, "")
            if color:
                return f"{color}{msg}{RESET}"
        return msg


def setup_logging(args):
    """Configure logging based on CLI arguments."""
    level = logging.INFO
    if args.verbose:
        level = logging.DEBUG
    elif args.quiet:
        level = logging.WARNING
    if args.log_level:
        level_name = args.log_level.upper()
        level = getattr(logging, level_name, level)

    use_color = False
    if args.colors == "yes":
        use_color = True
    elif args.colors == "no":
        use_color = False
    else:
        # auto
        use_color = sys.stdout.isatty() and not os.environ.get("NO_COLOR")

    handler = logging.StreamHandler(sys.stderr)
    formatter = ColorFormatter(use_color=use_color, fmt="%(levelname)s: %(message)s")
    handler.setFormatter(formatter)

    root_log = logging.getLogger()
    root_log.setLevel(level)
    root_log.handlers = []
    root_log.addHandler(handler)


def get_parser():
    parser = argparse.ArgumentParser(
        description="List Flatpak runtimes and their dependent apps."
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Enable verbose DEBUG logging.",
    )
    parser.add_argument(
        "-q",
        "--quiet",
        action="store_true",
        help="Enable quiet WARNING logging.",
    )
    parser.add_argument(
        "--log-level",
        metavar="LEVEL",
        help="Set exact logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL).",
    )
    parser.add_argument(
        "--colors",
        choices=["yes", "no", "auto"],
        default="auto",
        help="Use colors in log outputs (default: auto). Use --colors=no or NO_COLOR=1 env var to disable.",
    )
    parser.add_argument(
        "--legacy-report",
        action="store_true",
        help="Print the legacy dependency map report.",
    )
    parser.add_argument(
        "--remove-unused",
        action="store_true",
        help="Interactively remove unused runtimes.",
    )
    parser.add_argument(
        "-y",
        "--yes",
        action="store_true",
        help="Automatically say yes to removing unused runtimes (requires --remove-unused).",
    )
    parser.add_argument(
        "--depends-on",
        metavar="STR",
        help="List everything that depends on runtimes matching the given substring.",
    )
    parser.add_argument(
        "--depends-on-exact",
        metavar="NAME",
        help="List everything that depends on a runtime with the exact given name.",
    )
    parser.add_argument(
        "--clean-nvidia",
        action="store_true",
        help="List old NVIDIA runtimes that do not match the host NVIDIA driver. Pass -y to uninstall them.",
    )
    return parser


def main():
    parser = get_parser()

    try:
        import argcomplete

        argcomplete.autocomplete(parser)
    except ImportError:
        pass

    args = parser.parse_args()

    setup_logging(args)
    log.debug(f"{sys.argv[1:]=}")
    log.debug(f"{args=}")
    log.debug("Arguments parsed and logging configured")

    check_flatpak_installed()

    search_str = args.depends_on
    exact_name = args.depends_on_exact

    # If any specific search option is provided, use the legacy report style to show dependencies
    force_legacy = bool(search_str or exact_name)

    if not args.remove_unused and not args.legacy_report and not force_legacy:
        log.info("Printing default report")
        print_default_report()

    log.debug("Getting flatpak data text")
    data = get_flatpak_data_text()

    log.debug("Organizing data")
    organized_data = organize_data(data)

    if (args.legacy_report or force_legacy) and not args.remove_unused:
        log.info("Printing legacy results report")
        print_results(organized_data, search_str=search_str, exact_name=exact_name)

    # Use native flatpak check
    log.info("Looking for unused runtimes natively")
    unused_runtimes = get_unused_runtimes_native()
    if unused_runtimes:
        print(f"\nFound {len(unused_runtimes)} unused runtime(s):")
        for rt_id, rt_branch in unused_runtimes:
            print(f"  {rt_id} (branch {rt_branch})")

        print("\nTo remove individually:")
        for rt_id, rt_branch in unused_runtimes:
            print(f"  flatpak uninstall {rt_id}//{rt_branch}")

        print("\nTo remove all unused runtimes:")
        print("  flatpak uninstall --unused")
    else:
        print("\nNo unused runtimes found.")

    if args.clean_nvidia:
        log.info("Cleaning up old NVIDIA runtimes")
        clean_old_nvidia_runtimes(auto_yes=args.yes)

    if args.remove_unused and unused_runtimes:
        log.info("Removing unused runtimes")
        remove_unused_runtimes(auto_yes=args.yes)


if __name__ == "__main__":
    main()
