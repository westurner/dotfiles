#!/usr/bin/env python3

import subprocess
import re
import sys
import concurrent.futures
import shutil

def get_installed_runtimes():
    """
    Retrieves a list of installed Flatpak runtimes.
    Returns a list of dicts: {'id': app_id, 'branch': branch, 'arch': arch, 'origin': remote}
    """
    runtimes = []
    try:
        # We request specific columns to make parsing reliable: application ID, branch, architecture, and origin remote
        cmd = ["flatpak", "list", "--runtime", "--columns=application,branch,arch,origin"]
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)

        for line in result.stdout.strip().split('\n'):
            if not line:
                continue

            parts = line.split()
            # We expect exactly 4 columns. If fewer, skip (headers or malformed lines)
            if len(parts) >= 4:
                runtimes.append({
                    'id': parts[0],
                    'branch': parts[1],
                    'arch': parts[2],
                    'origin': parts[3]
                })
    except FileNotFoundError:
        print("Error: 'flatpak' command not found. Is Flatpak installed?")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print(f"Error listing flatpaks: {e}")
        sys.exit(1)

    return runtimes

def check_runtime_eol(runtime):
    """
    Checks the EOL status of a single runtime using 'flatpak remote-info'.
    Returns the runtime dict updated with 'eol_reason' (None if active/supported).
    """
    ref = f"{runtime['id']}//{runtime['branch']}"

    # We use remote-info to get the latest metadata from the remote server.
    # This ensures we see the EOL status even if the local installation hasn't been updated recently.
    cmd = ["flatpak", "remote-info", runtime['origin'], ref, "--arch=" + runtime['arch']]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode != 0:
            # If the remote info fails (e.g., remote unreachable or ref removed), return generic error
            return {**runtime, 'eol_reason': "Error: Could not query remote", 'is_eol': False}

        output = result.stdout

        # Regex to find the "End-of-life:" line in the output
        # Format is typically: "End-of-life: Some reason text"
        eol_match = re.search(r"^End-of-life:\s*(.*)$", output, re.MULTILINE)

        if eol_match:
            reason = eol_match.group(1).strip()
            return {**runtime, 'eol_reason': reason, 'is_eol': True}
        else:
            return {**runtime, 'eol_reason': None, 'is_eol': False}

    except Exception as e:
        return {**runtime, 'eol_reason': f"Script Error: {str(e)}", 'is_eol': False}

def print_table(data):
    """
    Pretty prints the results in a table.
    """
    if not data:
        print("No runtimes found.")
        return

    # Define headers and fixed widths
    headers = ["Runtime ID", "Branch", "Status", "Reason"]

    # Calculate column widths
    max_id = max(len(r['id']) for r in data)
    max_id = max(max_id, len(headers[0]))

    max_branch = max(len(r['branch']) for r in data)
    max_branch = max(max_branch, len(headers[1]))

    # Format string
    row_fmt = f"{{:<{max_id + 2}}} {{:<{max_branch + 2}}} {{:<10}} {{}}"

    print("-" * 80)
    print(row_fmt.format(*headers))
    print("-" * 80)

    for r in data:
        status = "EOL" if r['is_eol'] else "Active"
        reason = r['eol_reason'] if r['is_eol'] else ""

        # Colorize output if connected to a terminal
        if sys.stdout.isatty():
            if r['is_eol']:
                # Red for EOL
                status = f"\033[91m{status}\033[0m"
            else:
                # Green for Active
                status = f"\033[92m{status}\033[0m"

        print(row_fmt.format(r['id'], r['branch'], status, reason))

def main():
    print("Fetching installed runtimes list...")
    runtimes = get_installed_runtimes()

    if not runtimes:
        print("No Flatpak runtimes installed.")
        return

    print(f"Checking EOL status for {len(runtimes)} runtimes (this may take a moment)...")

    results = []

    # Use ThreadPoolExecutor to run remote-info queries in parallel
    # This significantly speeds up the process as network/process calls are the bottleneck
    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        future_to_runtime = {executor.submit(check_runtime_eol, r): r for r in runtimes}

        # Simple progress counter
        completed = 0
        for future in concurrent.futures.as_completed(future_to_runtime):
            data = future.result()
            results.append(data)
            completed += 1
            print(f"\rProgress: {completed}/{len(runtimes)}", end="", flush=True)

    print("\n")

    # Sort results: EOL first, then by ID
    results.sort(key=lambda x: (not x['is_eol'], x['id']))

    print_table(results)

if __name__ == "__main__":
    main()
