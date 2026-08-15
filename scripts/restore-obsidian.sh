#!/usr/bin/env bash
set -euo pipefail

# restore-obsidian.sh — re-materialize the Obsidian vault setup.
#
# Restores everything that a fresh `git clone` does NOT bring back:
#   1. restores notes/.obsidian/ from git if it's missing locally
#   2. (re)writes ~/.config/obsidian/user-flags.conf (always overwrites)
#   3. registers the vault and enables the CLI in ~/.config/obsidian/obsidian.json
#   4. launches Obsidian and verifies the CLI + plugins
#
# Idempotent and safe to re-run. Run from anywhere.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VAULT_PATH="$REPO_ROOT/notes"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/obsidian"
USER_FLAGS="$CONFIG_DIR/user-flags.conf"
OBSIDIAN_JSON="$CONFIG_DIR/obsidian.json"
CLI_SOCKET="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/.obsidian-cli.sock"

PLUGIN_IDS=(templater-obsidian dataview obsidian-tasks-plugin obsidian-spaced-repetition obsidian-excalidraw-plugin code-styler obsidian-kanban quickadd)

DRY_RUN=0
LAUNCH=1
PULL=0

usage() {
  cat <<EOF
Usage: $(basename "$0") [--dry-run] [--no-launch] [--pull]

Restores the Obsidian vault setup:
  1. restores notes/.obsidian/ from git if missing
  2. writes $CONFIG_DIR/user-flags.conf (overwrites)
  3. registers the vault and enables the CLI in obsidian.json
  4. launches Obsidian and verifies CLI + plugins

Options:
  --dry-run   report what would change, apply nothing
  --no-launch skip launching Obsidian and the CLI verification
  --pull      git pull --ff-only before restoring (ignore if it fails)
EOF
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --no-launch) LAUNCH=0 ;;
    --pull) PULL=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown option: $arg" >&2; usage >&2; exit 2 ;;
  esac
done

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
say()  { printf '\033[1;32m  +\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  !\033[0m %s\n' "$*" >&2; }

# --- preflight ---------------------------------------------------------------
if ! command -v git >/dev/null 2>&1; then
  echo "error: 'git' not found in PATH" >&2
  exit 1
fi
if ! command -v obsidian >/dev/null 2>&1; then
  echo "error: 'obsidian' not found in PATH" >&2
  echo "  install it first, e.g.  sudo pacman -S obsidian" >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "error: 'python3' not found in PATH" >&2
  exit 1
fi
if ! git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: $REPO_ROOT is not a git repository" >&2
  exit 1
fi
if ! git -C "$REPO_ROOT" ls-files notes/.obsidian | grep -q .; then
  echo "error: notes/.obsidian is not tracked in $REPO_ROOT (nothing to restore)" >&2
  exit 1
fi
[ "$DRY_RUN" -eq 1 ] && info "dry run: reporting what a restore would change"

# --- 0. optional pull ----------------------------------------------------------
if [ "$PULL" -eq 1 ]; then
  if [ "$DRY_RUN" -eq 1 ]; then
    info "would pull latest from origin"
  elif git -C "$REPO_ROOT" pull --ff-only >/dev/null 2>&1; then
    say "pulled latest from origin"
  else
    warn "could not pull (dirty tree or no remote); continuing with local state"
  fi
fi

# --- 1. vault config from git -------------------------------------------------
if [ -d "$VAULT_PATH/.obsidian" ]; then
  say "vault config present at notes/.obsidian (nothing to restore)"
else
  if [ "$DRY_RUN" -eq 1 ]; then
    info "would restore notes/.obsidian from git"
  else
    info "restoring notes/.obsidian from git"
    (cd "$REPO_ROOT" && git restore --source=HEAD --worktree -- notes/.obsidian)
    say "restored"
  fi
fi

# --- 2. user-flags.conf (always overwrite) ------------------------------------
if [ "$DRY_RUN" -eq 1 ]; then
  info "would (over)write user-flags.conf"
else
  info "writing user-flags.conf"
  mkdir -p "$CONFIG_DIR"
  cat > "$USER_FLAGS" <<'EOF'
# Obsidian reads this file through the Arch package wrapper.
--disable-gpu
--enable-wayland-ime
EOF
  say "written"
fi

# --- 3. register vault + enable CLI in obsidian.json ---------------------------
python3 - "$VAULT_PATH" "$OBSIDIAN_JSON" "$DRY_RUN" <<'PY'
import json, os, random, sys, time

vault_path, obsidian_json, dry_run = sys.argv[1], sys.argv[2], sys.argv[3] == "1"
vault_path = os.path.realpath(vault_path)

data = {}
if os.path.exists(obsidian_json):
    try:
        with open(obsidian_json) as f:
            data = json.load(f)
    except (OSError, json.JSONDecodeError):
        data = {}
data.setdefault("vaults", {})

match = next(
    (vid for vid, v in data["vaults"].items()
     if os.path.realpath(v.get("path", "")) == vault_path),
    None,
)
registered = match is not None
cli_on = bool(data.get("cli"))

if dry_run:
    if registered:
        print("  + vault already registered (open=%s)" % data["vaults"][match].get("open"))
    else:
        print("  ! vault NOT registered — would add")
    print("  + cli " + ("already on" if cli_on else "OFF — would enable"))
else:
    if not registered:
        match = "".join(random.choice("0123456789abcdef") for _ in range(16))
        data["vaults"][match] = {"path": vault_path}
        print("  + registered vault: %s" % vault_path)
    else:
        print("  + vault already registered")
    data["vaults"][match]["ts"] = int(time.time() * 1000)
    for vid, v in data["vaults"].items():
        v["open"] = (vid == match)
    data["cli"] = True
    tmp = obsidian_json + ".tmp"
    with open(tmp, "w") as f:
        json.dump(data, f, indent=2)
    os.replace(tmp, obsidian_json)
    print("  + cli enabled")
PY

# --- 4. launch + verify --------------------------------------------------------
if [ "$LAUNCH" -eq 1 ] && [ "$DRY_RUN" -eq 0 ]; then
  info "launching Obsidian"
  setsid obsidian >/dev/null 2>&1 &
  for _ in $(seq 1 30); do
    [ -S "$CLI_SOCKET" ] && break
    sleep 1
  done
  if [ -S "$CLI_SOCKET" ]; then
    if version="$(obsidian version 2>/dev/null)"; then
      say "CLI works: $version"
    else
      warn "CLI socket up but 'obsidian version' failed"
    fi
  else
    warn "CLI socket not ready after 30s"
  fi
fi

missing=()
for p in "${PLUGIN_IDS[@]}"; do
  if ! grep -q "\"$p\"" "$VAULT_PATH/.obsidian/community-plugins.json" 2>/dev/null; then
    missing+=("$p")
  fi
done
if [ "${#missing[@]}" -eq 0 ]; then
  say "all ${#PLUGIN_IDS[@]} plugins listed in community-plugins.json"
else
  warn "missing from community-plugins.json: ${missing[*]}"
fi