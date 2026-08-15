#!/usr/bin/env bash
set -euo pipefail

# backup.sh — continuous backup of the go-learning repo.
#
# Commits any uncommitted changes and pushes to origin. Safe to run on a
# schedule (systemd timer) or manually; no-ops cleanly when there is nothing
# to do. Respects .gitignore, so generated/ignored files are never committed.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "backup: $REPO_ROOT is not a git repository" >&2
  exit 1
fi

git add -A

if git diff --cached --quiet; then
  echo "backup: no changes, skipping commit"
else
  git commit -m "Automated backup $(date '+%Y-%m-%d %H:%M')"
fi

if ! git push origin master; then
  echo "backup: push failed (remote may have diverged)" >&2
  exit 1
fi