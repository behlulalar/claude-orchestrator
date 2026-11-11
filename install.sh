#!/usr/bin/env bash
# Installs the orchestrator skill globally (all projects) for Claude Code.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)/skills/orchestrator"
DEST="$HOME/.claude/skills/orchestrator"
mkdir -p "$HOME/.claude/skills"
rm -rf "$DEST"
cp -R "$SRC" "$DEST"
echo "Installed skill -> $DEST"

# Optional: make it always-on via the global CLAUDE.md
MARK="<!-- orchestrator-skill -->"
CM="$HOME/.claude/CLAUDE.md"
touch "$CM"
if ! grep -q "$MARK" "$CM"; then
  cat >> "$CM" <<'EOF'

<!-- orchestrator-skill -->
## Orchestration
For any task that involves writing/changing code, load the `orchestrator` skill first.
The main loop plans, briefs and verifies; sub-agents (explicit `model:` always) do the implementation.
<!-- /orchestrator-skill -->
EOF
  echo "Added always-on pointer to $CM"
fi
