#!/usr/bin/env bash
# Sync Psion the Fraying's raster images to and from Backblaze B2.
#
# Images are not tracked in git — see images/README.md and .gitignore. B2 is the durable
# copy; the local folder is the working copy your markdown reader renders from. This script
# moves files between the two and never touches anything git tracks.
#
#   ./Tools/sync_art.sh status       what differs between local and B2 (default)
#   ./Tools/sync_art.sh push         upload local images to B2
#   ./Tools/sync_art.sh pull         download images from B2 into the repo
#   ./Tools/sync_art.sh verify       compare every file by hash
#
# push and pull are DRY RUNS unless you add --yes:
#   ./Tools/sync_art.sh push --yes
#
# B2 file versioning is on, so a replaced or deleted object keeps its prior version
# and is recoverable from the B2 console.

set -euo pipefail

REMOTE="writing:haishuo-writing-images/psion-the-fraying"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERNS=(--include "*.png" --include "*.jpg" --include "*.jpeg" --include "*.webp" --include "*.gif")

action="${1:-status}"
confirm="${2:-}"
dry=(--dry-run)
[[ "$confirm" == "--yes" ]] && dry=()

command -v rclone >/dev/null || { echo "rclone not found. brew install rclone" >&2; exit 1; }
rclone lsd "${REMOTE%/elvandar}" >/dev/null 2>&1 || {
  echo "Cannot reach $REMOTE." >&2
  echo "Configure the 'writing' remote with: rclone config" >&2
  exit 1
}

cd "$REPO"

case "$action" in
  status)
    echo "Local vs B2 — files only on one side or differing:"
    rclone check "${PATTERNS[@]}" . "$REMOTE" --combined - 2>/dev/null | grep -v '^=' || echo "  (in sync)"
    ;;
  verify)
    rclone check "${PATTERNS[@]}" . "$REMOTE"
    ;;
  push)
    [[ ${#dry[@]} -gt 0 ]] && echo "DRY RUN — add --yes to apply."
    rclone copy "${dry[@]}" "${PATTERNS[@]}" --progress . "$REMOTE"
    ;;
  pull)
    [[ ${#dry[@]} -gt 0 ]] && echo "DRY RUN — add --yes to apply."
    rclone copy "${dry[@]}" "${PATTERNS[@]}" --progress "$REMOTE" .
    ;;
  *)
    echo "Usage: $0 {status|push|pull|verify} [--yes]" >&2
    exit 1
    ;;
esac
