#!/usr/bin/env bash
# Sync this project's raster images to and from Backblaze B2.
#
# Images are not tracked in git — see .gitignore. B2 is the durable copy; the folder
# on disk is the working copy your markdown reader renders from. This script moves
# files between the two and never touches anything git tracks.
#
#   ./sync_art.sh status       what differs between local and B2 (default)
#   ./sync_art.sh verify       compare every file by hash
#   ./sync_art.sh push         upload  — DRY RUN unless you add --yes
#   ./sync_art.sh pull         download — DRY RUN unless you add --yes
#
# B2 file versioning is on, so a replaced or deleted object keeps its prior version
# and stays recoverable from the B2 console.
#
# This script is identical across every writing project except PREFIX below.

set -euo pipefail

BUCKET="writing:haishuo-writing-images"
PREFIX="psion-the-fraying"
REMOTE="$BUCKET/$PREFIX"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERNS=(--include "*.png" --include "*.jpg" --include "*.jpeg" --include "*.webp" --include "*.gif")

action="${1:-status}"
dry=(--dry-run)
[[ "${2:-}" == "--yes" ]] && dry=()
# Expand $dry as ${dry[@]+...}: under `set -u`, macOS's stock bash 3.2 treats
# "${dry[@]}" on an empty array as an unbound variable and aborts. Bash >= 4.4
# does not, so this only bites on a Mac without a newer bash installed.

command -v rclone >/dev/null || { echo "rclone not found. brew install rclone" >&2; exit 1; }

# Check the BUCKET, not the prefix: a prefix with no objects yet does not exist in
# object storage, and probing it would fail on a project whose first image is still
# to come.
rclone lsjson --stat "$BUCKET" >/dev/null 2>&1 || rclone size "$BUCKET" >/dev/null 2>&1 || {
  echo "Cannot reach $BUCKET." >&2
  echo "Configure the 'writing' remote with: rclone config" >&2
  exit 1
}

cd "$REPO"

local_count=$(find . -path ./.git -prune -o -type f \
  \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' \) \
  -print 2>/dev/null | wc -l | tr -d ' ')
remote_count=$(rclone ls "$REMOTE" 2>/dev/null | wc -l | tr -d ' ')

case "$action" in
  status)
    echo "local: $local_count image(s)    B2 ($PREFIX): $remote_count object(s)"
    if [[ "$local_count" == "0" && "$remote_count" == "0" ]]; then
      echo "No images in this project yet. When there are, run: ./sync_art.sh push --yes"
      exit 0
    fi
    echo "Differences (files on one side only, or not matching):"
    rclone check "${PATTERNS[@]}" . "$REMOTE" --combined - 2>/dev/null | grep -v '^=' || echo "  (in sync)"
    ;;
  verify)
    if [[ "$local_count" == "0" && "$remote_count" == "0" ]]; then
      echo "Nothing to verify: no images locally and none in B2."
      exit 0
    fi
    rclone check "${PATTERNS[@]}" . "$REMOTE"
    ;;
  push)
    if [[ "$local_count" == "0" ]]; then echo "No local images to push."; exit 0; fi
    [[ ${#dry[@]} -gt 0 ]] && echo "DRY RUN — add --yes to apply."
    rclone copy ${dry[@]+"${dry[@]}"} "${PATTERNS[@]}" --progress . "$REMOTE"
    ;;
  pull)
    if [[ "$remote_count" == "0" ]]; then echo "Nothing in B2 under $PREFIX to pull."; exit 0; fi
    [[ ${#dry[@]} -gt 0 ]] && echo "DRY RUN — add --yes to apply."
    rclone copy ${dry[@]+"${dry[@]}"} "${PATTERNS[@]}" --progress "$REMOTE" .
    ;;
  *)
    echo "Usage: $0 {status|push|pull|verify} [--yes]" >&2
    exit 1
    ;;
esac
