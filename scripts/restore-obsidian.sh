#!/usr/bin/env bash
set -euo pipefail

# restore-obsidian.sh — book-close vault restore
# Restores notes/.obsidian from git, writes user-flags, registers vault.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VAULT="$REPO_ROOT/notes"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/obsidian"
USER_FLAGS="$CONFIG_DIR/user-flags.conf"
OBSIDIAN_JSON="$CONFIG_DIR/obsidian.json"

[[ "$*" == *"--check"* ]] && { echo "check: use --check to verify vault (not implemented in minimal)"; exit 0; }
[[ "$*" == *"--backup"* ]] && { git -C "$REPO_ROOT" add notes && git -C "$REPO_ROOT" diff --cached --quiet || git -C "$REPO_ROOT" commit -m "Backup vault $(date +%Y-%m-%d)"; exit 0; }

# 1. vault config
if [[ ! -d "$VAULT/.obsidian" ]]; then
  echo "restoring notes/.obsidian from git"
  (cd "$REPO_ROOT" && git restore --source=HEAD --worktree -- notes/.obsidian)
fi

# 2. user-flags
mkdir -p "$CONFIG_DIR"
cat > "$USER_FLAGS" <<'EOF'
--disable-gpu
--enable-wayland-ime
EOF

# 3. register vault + enable CLI
python3 - "$VAULT" "$OBSIDIAN_JSON" <<'PY'
import json, os, random, sys, time
vault, cfg = sys.argv[1], sys.argv[2]
vault = os.path.realpath(vault)
data = {}
if os.path.exists(cfg):
  try:
    data = json.load(open(cfg))
  except: data = {}
data.setdefault("vaults", {})
vid = next((k for k,v in data["vaults"].items() if os.path.realpath(v.get("path",""))==vault), None)
if not vid:
  vid = "".join(random.choice("0123456789abcdef") for _ in range(16))
  data["vaults"][vid] = {"path": vault}
data["vaults"][vid]["ts"] = int(time.time()*1000)
for k in data["vaults"]: data["vaults"][k]["open"] = (k==vid)
data["cli"] = True
open(cfg+".tmp","w").write(json.dumps(data, indent=2))
os.replace(cfg+".tmp", cfg)
print("vault registered, cli enabled")
PY

echo "Restore complete."
