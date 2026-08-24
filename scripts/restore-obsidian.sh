#!/usr/bin/env bash
set -euo pipefail

# restore-obsidian.sh — re-materialize, verify, and back up the Obsidian vault.
#
# A fresh `git clone` does NOT bring back the vault setup, so this restores:
#   1. notes/.obsidian/ from git if it's missing (or always, with --force)
#   2. (re)writes ~/.config/obsidian/user-flags.conf (always overwrites)
#   3. registers the vault and enables the CLI in ~/.config/obsidian/obsidian.json
#   4. launches Obsidian, verifies the CLI + plugins, and trusts the vault
#
#   (the Obsidian theme is NOT restored — Omarchy manages it at the OS level;
#   apply it through Omarchy's theme settings when it's missing)
#
# Also supports:
#   --check   verify vault config, registration, CLI flag, and plugin installs;
#             touches nothing
#   --backup  commit the current vault state (notes/) to git; touches nothing else
#
# Idempotent and safe to re-run. Run from anywhere.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VAULT_PATH="$REPO_ROOT/notes"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/obsidian"
USER_FLAGS="$CONFIG_DIR/user-flags.conf"
OBSIDIAN_JSON="$CONFIG_DIR/obsidian.json"
CLI_SOCKET="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/.obsidian-cli.sock"

DRY_RUN=0
LAUNCH=1
PULL=0
TRUST=1
FORCE=0
CHECK=0
BACKUP=0

usage() {
  cat <<EOF
Usage: $(basename "$0") [--dry-run] [--no-launch] [--pull] [--no-trust] [--force] [--check] [--backup]

Restores the Obsidian vault setup:
  1. restores notes/.obsidian/ from git if missing (or always, with --force)
  2. writes $CONFIG_DIR/user-flags.conf (overwrites)
  3. registers the vault and enables the CLI in obsidian.json
  4. launches Obsidian, verifies CLI + plugins, and trusts the vault

Options:
  --dry-run   report what would change, apply nothing
  --no-launch skip launching Obsidian and the CLI verification
  --pull      git pull --ff-only before restoring (ignore if it fails)
  --no-trust  do not disable restricted mode / trust the vault
  --force     restore notes/.obsidian from git even if it already exists
  --check     verify vault config, registration, CLI, and plugin installs; change nothing
  --backup    commit the current vault state (notes/) to git; change nothing else
EOF
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --no-launch) LAUNCH=0 ;;
    --pull) PULL=1 ;;
    --no-trust) TRUST=0 ;;
    --force) FORCE=1 ;;
    --check) CHECK=1 ;;
    --backup) BACKUP=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown option: $arg" >&2; usage >&2; exit 2 ;;
  esac
done

if [ "$CHECK" -eq 1 ] && [ "$BACKUP" -eq 1 ]; then
  echo "error: --check and --backup are mutually exclusive" >&2
  exit 2
fi

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
say()  { printf '\033[1;32m  +\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  !\033[0m %s\n' "$*" >&2; }

# plugin_problems: print (space-separated) plugin ids listed in
# community-plugins.json whose install dir lacks manifest.json or main.js.
# community-plugins.json is the single source of truth for what to check.
plugin_problems() {
  python3 - "$VAULT_PATH" <<'PY'
import json, os, sys
base = os.path.join(sys.argv[1], ".obsidian")
with open(os.path.join(base, "community-plugins.json")) as f:
    ids = json.load(f)
missing = [pid for pid in ids
           if not (os.path.isfile(os.path.join(base, "plugins", pid, "manifest.json"))
                   and os.path.isfile(os.path.join(base, "plugins", pid, "main.js")))]
if missing:
    print(" ".join(missing))
PY
}

# configured_theme: print the cssTheme from appearance.json ("" if unset).
configured_theme() {
  python3 -c 'import json, sys
d = json.load(open(sys.argv[1]))
print(d.get("cssTheme", ""))' "$VAULT_PATH/.obsidian/appearance.json" 2>/dev/null || true
}

# check_vault: verify config presence, obsidian binary, vault registration + CLI
# flag in obsidian.json, and plugin installs. Touches nothing. Exits non-zero on
# any problem, so it can be used in scripts/CI.
check_vault() {
  local problems=0
  info "checking Obsidian vault setup (no changes made)"
  if [ -d "$VAULT_PATH/.obsidian" ]; then
    say "vault config present at notes/.obsidian"
  else
    warn "notes/.obsidian is missing — run the script without --check to restore it"
    problems=1
  fi
  if command -v obsidian >/dev/null 2>&1; then
    say "'obsidian' found in PATH"
  else
    warn "'obsidian' not found in PATH"
    problems=1
  fi
  if python3 - "$VAULT_PATH" "$OBSIDIAN_JSON" <<'PY'
import json, os, sys
vault_path = os.path.realpath(sys.argv[1])
try:
    with open(sys.argv[2]) as f:
        data = json.load(f)
except (OSError, json.JSONDecodeError):
    data = {}
vaults = data.get("vaults", {})
registered = any(os.path.realpath(v.get("path", "")) == vault_path for v in vaults.values())
cli_on = bool(data.get("cli"))
if not os.path.exists(sys.argv[2]):
    print("  ! obsidian.json not found at %s" % sys.argv[2])
if not registered:
    print("  ! vault not registered in obsidian.json")
if not cli_on:
    print("  ! Obsidian CLI not enabled (obsidian.json 'cli' flag)")
sys.exit(0 if (registered and cli_on) else 1)
PY
  then
    say "vault registered and CLI enabled in obsidian.json"
  else
    problems=1
  fi
  if [ -f "$VAULT_PATH/.obsidian/community-plugins.json" ]; then
    mapfile -t missing < <(plugin_problems)
    if [ "${#missing[@]}" -eq 0 ]; then
      say "all plugins in community-plugins.json are installed"
    else
      warn "plugins listed but not installed: ${missing[*]}"
      problems=1
    fi
  else
    warn "community-plugins.json missing"
    problems=1
  fi
  theme="$(configured_theme)"
  if [ -n "$theme" ] && [ ! -f "$VAULT_PATH/.obsidian/themes/$theme/theme.css" ]; then
    warn "theme '$theme' not installed — Omarchy manages themes; apply it in Omarchy's theme settings"
    problems=1
  elif [ -n "$theme" ]; then
    say "theme '$theme' present"
  fi
  if [ "$problems" -eq 0 ]; then
    say "all checks passed"
  else
    warn "problems found (see above); fix and re-run"
  fi
  return "$problems"
}

# backup_vault: stage notes/ (respecting .gitignore) and commit as a manual
# backup snapshot — the repo's "fully manual" sync model.
backup_vault() {
  info "backing up vault state to git"
  if [ "$DRY_RUN" -eq 1 ]; then
    info "would stage notes/ and commit 'Backup Obsidian vault <timestamp>'"
    return 0
  fi
  git -C "$REPO_ROOT" add notes
  if git -C "$REPO_ROOT" diff --cached --quiet; then
    say "nothing to commit — vault state matches HEAD"
  else
    git -C "$REPO_ROOT" commit -m "Backup Obsidian vault $(date +%Y-%m-%d\ %H:%M)" >/dev/null
    say "committed vault state"
  fi
}

# --- preflight ---------------------------------------------------------------
if ! command -v git >/dev/null 2>&1; then
  echo "error: 'git' not found in PATH" >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "error: 'python3' not found in PATH" >&2
  exit 1
fi
if ! command -v obsidian >/dev/null 2>&1; then
  if [ "$CHECK" -eq 1 ] || [ "$BACKUP" -eq 1 ]; then
    warn "'obsidian' not found in PATH (not needed for this mode)"
  else
    echo "error: 'obsidian' not found in PATH" >&2
    echo "  install it first, e.g.  sudo pacman -S obsidian" >&2
    exit 1
  fi
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

# --- check / backup modes -----------------------------------------------------
if [ "$CHECK" -eq 1 ]; then
  check_vault
  exit "$?"
fi

if [ "$BACKUP" -eq 1 ]; then
  backup_vault
  exit 0
fi

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
if [ -d "$VAULT_PATH/.obsidian" ] && [ "$FORCE" -eq 0 ]; then
  say "vault config present at notes/.obsidian (nothing to restore)"
else
  if [ "$DRY_RUN" -eq 1 ]; then
    info "would restore notes/.obsidian from git"
  else
    info "restoring notes/.obsidian from git"
    (cd "$REPO_ROOT" && git restore --source=HEAD --worktree -- notes/.obsidian)
    say "restored (ignored files like workspace.json are left untouched)"
  fi
fi

# The Obsidian theme is OS-managed (Omarchy's own theme system), not in git —
# remind the user to apply it when the configured theme is missing.
theme="$(configured_theme)"
if [ -n "$theme" ] && [ ! -f "$VAULT_PATH/.obsidian/themes/$theme/theme.css" ]; then
  warn "theme '$theme' is not installed — apply it in Omarchy's theme settings (Omarchy manages themes)"
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
  OBS_PID=$!
  socket_ready=0
  for _ in $(seq 1 30); do
    if [ -S "$CLI_SOCKET" ]; then
      socket_ready=1
      break
    fi
    if ! kill -0 "$OBS_PID" 2>/dev/null; then
      warn "Obsidian process exited before the CLI socket appeared"
      break
    fi
    sleep 1
  done
  if [ "$socket_ready" -eq 1 ]; then
    if version="$(obsidian version 2>/dev/null)"; then
      say "CLI works: $version"
    else
      warn "CLI socket up but 'obsidian version' failed"
    fi
    if [ "$TRUST" -eq 1 ]; then
      # Strip ANSI colour codes, then extract the last bare on/off word.
      restrict_state="$(obsidian plugins:restrict 2>/dev/null \
        | sed 's/\x1b\[[0-9;]*m//g' \
        | grep -oiE '\b(on|off)\b' \
        | tail -n1 || true)"
      case "$restrict_state" in
        off)
          say "restricted mode off (vault already trusted)"
          ;;
        on)
          info "vault not trusted — disabling restricted mode"
          if obsidian plugins:restrict off >/dev/null 2>&1; then
            say "restricted mode off; plugins will load (app reloads)"
          else
            warn "could not disable restricted mode — enable plugins manually in Settings → Community plugins"
          fi
          ;;
        *)
          warn "could not read restricted mode (got: '$restrict_state'); check Settings → Community plugins"
          ;;
      esac
    fi
  else
    warn "CLI socket not ready after 30s"
  fi
fi

if [ "$DRY_RUN" -eq 1 ] && [ "$LAUNCH" -eq 1 ]; then
  if [ "$TRUST" -eq 1 ]; then
    info "would trust the vault (disable restricted mode) if needed"
  else
    info "would skip trusting the vault (--no-trust)"
  fi
fi

# --- plugins: verify every listed plugin is actually installed -----------------
missing=()
if [ -f "$VAULT_PATH/.obsidian/community-plugins.json" ]; then
  mapfile -t missing < <(plugin_problems)
fi
if [ "${#missing[@]}" -eq 0 ]; then
  say "all plugins in community-plugins.json are installed"
else
  warn "plugins listed but not installed: ${missing[*]}"
fi
