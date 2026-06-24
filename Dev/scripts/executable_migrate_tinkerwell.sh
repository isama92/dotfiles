#!/usr/bin/env bash
#
# migrate_tinkerwell.sh
#
# Promote a newly downloaded Tinkerwell AppImage to be the active version:
#   - copies owner and permissions from the old AppImage onto the new one
#   - repoints the `tinkerwell` symlink to the new AppImage
#   - removes the old AppImage
#
# Usage:
#   migrate_tinkerwell.sh <old-version> <new-version> [install-dir]
#
# Example:
#   migrate_tinkerwell.sh 5.16.0 5.17.0
#
set -euo pipefail

INSTALL_DIR="${3:-/opt/tinkerwell}"
LINK_NAME="tinkerwell"

usage() {
    echo "Usage: $(basename "$0") <old-version> <new-version> [install-dir]" >&2
    echo "Example: $(basename "$0") 5.16.0 5.17.0" >&2
    exit 1
}

if [[ $# -lt 2 ]]; then
    usage
fi

OLD_VERSION="$1"
NEW_VERSION="$2"

OLD_FILE="${INSTALL_DIR}/Tinkerwell-${OLD_VERSION}.AppImage"
NEW_FILE="${INSTALL_DIR}/Tinkerwell-${NEW_VERSION}.AppImage"
LINK_PATH="${INSTALL_DIR}/${LINK_NAME}"

# Run privileged commands via sudo unless we are already root.
SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
    SUDO="sudo"
fi

if [[ ! -f "$OLD_FILE" ]]; then
    echo "Error: old AppImage not found: $OLD_FILE" >&2
    exit 1
fi

if [[ ! -f "$NEW_FILE" ]]; then
    echo "Error: new AppImage not found: $NEW_FILE" >&2
    exit 1
fi

# Capture ownership and permissions from the old AppImage.
owner="$(stat -c '%U:%G' "$OLD_FILE")"
perms="$(stat -c '%a' "$OLD_FILE")"

echo "Applying owner '${owner}' and permissions '${perms}' to ${NEW_FILE}"
$SUDO chown "$owner" "$NEW_FILE"
$SUDO chmod "$perms" "$NEW_FILE"

echo "Repointing ${LINK_PATH} -> ${NEW_FILE}"
$SUDO ln -sfn "$NEW_FILE" "$LINK_PATH"

echo "Removing old AppImage ${OLD_FILE}"
$SUDO rm -f "$OLD_FILE"

echo "Done. ${LINK_NAME} now points to Tinkerwell ${NEW_VERSION}."
