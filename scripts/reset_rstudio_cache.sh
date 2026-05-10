#!/usr/bin/env bash
# Reset RStudio local project UI state when you see:
#   "Error while opening file - system error 2 (No such file or directory)"
# after renaming/moving this folder or opening stale "Recent" paths.
#
# Usage (from project root):
#   bash scripts/reset_rstudio_cache.sh
#
# Then quit RStudio completely and reopen CDS101_Project.Rproj.

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${ROOT}/.Rproj.user"

if [[ -d "${TARGET}" ]]; then
  rm -rf "${TARGET}"
  echo "Removed: ${TARGET}"
else
  echo "Nothing to remove (already absent): ${TARGET}"
fi

echo "Next: Quit RStudio (Cmd+Q), then open CDS101_Project.Rproj from this folder."
