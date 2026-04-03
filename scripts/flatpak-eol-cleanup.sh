#!/bin/bash
# flatpak-eol-cleanup.sh
#
# Detects EOL runtimes via 'flatpak upgrade' and uninstalls them if they are unused.
# Unpins them if necessary.
#
# Usage:
#   flatpak-eol-cleanup.sh [-h|--help] [-y]
#
# Options:
#   -h, --help   Print this help message
#   -y           Execute the cleanup commands (default is dry-run)

set -u

if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    sed -rn '2,/^[^#]/ { /^[^#]/d; s/^# ?//p; }' "$0"
    exit 0
fi

DRY_RUN=true
if [[ "${1:-}" == "-y" ]]; then
    DRY_RUN=false
fi

if ! command -v flatpak &> /dev/null; then
    echo "Error: flatpak command not found."
    exit 1
fi

echo "[*] checking for EOL runtimes..."
# Run flatpak upgrade non-interactively and capture output
# We send 'n' to avoid applying updates right now, we just want the info.
UPGRADE_OUT=$(echo "n" | flatpak upgrade 2>&1)

# Extract EOL info using grep and sed
# Line format: Info: runtime org.freedesktop.Sdk branch 23.08 is end-of-life
# We extract "runtime_name:branch"
EOL_LIST=$(echo "$UPGRADE_OUT" | grep "is end-of-life" | sed -nE 's/.*Info: runtime ([^ ]+) branch ([^ ]+) is end-of-life.*/\1:\2/p' | sort | uniq)

if [ -z "$EOL_LIST" ]; then
    echo "No EOL runtimes detected."
    exit 0
fi

# Get list of installed apps to check dependencies
# Format: app_id <tab> runtime_ref
# runtime_ref example: org.freedesktop.Platform/x86_64/23.08
INSTALLED_APPS=$(flatpak list --app --columns=application,runtime)

# Get list of pinned runtimes
PINNED_RUNTIMES=$(flatpak pin)

echo "[*] Found EOL runtimes. Analyzing usage..."

# Loop through each EOL runtime
for ENTRY in $EOL_LIST; do
    RUNTIME_NAME="${ENTRY%%:*}"
    RUNTIME_BRANCH="${ENTRY##*:}"
    
    echo "----------------------------------------------------------------"
    echo "Processing: $RUNTIME_NAME // $RUNTIME_BRANCH"
    
    USED_BY=""
    
    # Check if any installed app uses this runtime
    # We read INSTALLED_APPS line by line
    while IFS=$'\t' read -r APP_ID APP_RUNTIME_REF; do
        if [ -z "$APP_ID" ]; then continue; fi
        
        # Check if APP_RUNTIME_REF matches the EOL runtime
        # Pattern matching: Name/*/Branch
        if [[ "$APP_RUNTIME_REF" == "$RUNTIME_NAME/"*"/$RUNTIME_BRANCH" ]]; then
            USED_BY="${USED_BY} ${APP_ID}"
        fi
    done <<< "$INSTALLED_APPS"
    
    # Check if it is pinned
    MATCHED_PIN=""
    while read -r PIN_REF; do
        # PIN_REF example: runtime/org.freedesktop.Sdk/x86_64/23.08
        if [[ "$PIN_REF" == "runtime/$RUNTIME_NAME/"*"/$RUNTIME_BRANCH" ]]; then
            MATCHED_PIN="$PIN_REF"
        fi
    done <<< "$PINNED_RUNTIMES"

    # Action logic
    
    if [ -n "$MATCHED_PIN" ]; then
        echo "  -> Found PIN: $MATCHED_PIN"
        if [ "$DRY_RUN" = true ]; then
             echo "  [DRY RUN] Command: flatpak pin --remove $MATCHED_PIN"
        else
             echo "  -> Removing pin..."
             flatpak pin --remove "$MATCHED_PIN"
        fi
    fi

    if [ -n "$USED_BY" ]; then
        echo "  [!] Runtime is currently used by applications:$USED_BY"
        echo "  [!] SKIPPING uninstall to prevent breakage."
    else
        if [ "$DRY_RUN" = true ]; then
            echo "  [DRY RUN] Command: flatpak uninstall -y $RUNTIME_NAME//$RUNTIME_BRANCH"
        else
            echo "  -> Runtime appears unused. Uninstalling..."
            flatpak uninstall -y "$RUNTIME_NAME//$RUNTIME_BRANCH"
        fi
    fi
done

if [ "$DRY_RUN" = true ]; then
    echo "----------------------------------------------------------------"
    echo "[*] Dry run complete. Rerun with -y to execute changes."
fi

echo "----------------------------------------------------------------"
echo "[*] Done."
