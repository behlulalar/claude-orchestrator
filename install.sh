#!/usr/bin/env bash
# Installs the orchestrator skill globally (all projects) for Claude Code.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)/skills/orchestrator"
DEST="$HOME/.claude/skills/orchestrator"
mkdir -p "$HOME/.claude/skills"
rm -rf "$DEST"
cp -R "$SRC" "$DEST"
echo "Installed skill -> $DEST"
mkdir -p "$HOME/.cursor/skills" && rm -rf "$HOME/.cursor/skills/orchestrator" && cp -R "$SRC" "$HOME/.cursor/skills/orchestrator"
echo "Installed skill -> $HOME/.cursor/skills/orchestrator"

# Optional: make it always-on via the global CLAUDE.md
MARK="<!-- orchestrator-skill -->"
CM="$HOME/.claude/CLAUDE.md"
touch "$CM"
if ! grep -q "$MARK" "$CM"; then
  cat >> "$CM" <<'EOF'

<!-- orchestrator-skill -->
## Orchestration
Do small and medium tasks directly. Load the `orchestrator` skill only for large/parallel work or anything touching prod/servers.
<!-- /orchestrator-skill -->
EOF
  echo "Added always-on pointer to $CM"
fi
