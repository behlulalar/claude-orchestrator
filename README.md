# claude-orchestrator

A Claude Code skill: the main loop (Opus 5.5, medium effort) only **plans, briefs, supervises and verifies**.
Sub-agents (Haiku / Sonnet / Opus) do the real work, routed by domain (backend, frontend, UI, DB,
security, DevOps/server, prod hardening, tests, research, bulk) and difficulty, cheapest tier first.

Adapted from [avenoxai/avenoxskills `fable-orchestration`](https://github.com/avenoxai/avenoxskills/tree/main/skills/fable-orchestration).

## Install (all projects)

```bash
git clone https://github.com/behlulalar/claude-orchestrator.git
cd claude-orchestrator && ./install.sh
```

This copies the skill to `~/.claude/skills/orchestrator` and adds a short always-on pointer to `~/.claude/CLAUDE.md`.
Per-project instead: copy `skills/orchestrator` into `<project>/.claude/skills/`.

## What it enforces

- Explicit `model:` on every sub-agent call (no silent inheritance of the expensive model)
- Domain + difficulty routing table, escalate haiku -> sonnet -> opus on failure
- One owner per file, independent units in parallel
- Token rules: report caps, search-before-read, tests/logs stay out of the main context
- Risk-proportional verification; independent opus reviewer for high-risk changes
- Prod/server safety gates: agents prepare, the user approves anything touching live systems
