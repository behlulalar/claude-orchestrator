# claude-orchestrator

A lean Claude Code skill for delegating **only when it pays off**.

Delegation costs tokens (cold start, brief, report, verification) and adds round trips. So by default Claude
works directly. The skill kicks in for large/parallel work (3+ independent units on different files, >~10 files,
wide codebase search, bulk mechanical changes) and for anything touching prod/servers.

Adapted from [avenoxai/avenoxskills `fable-orchestration`](https://github.com/avenoxai/avenoxskills/tree/main/skills/fable-orchestration).

## Install (all projects)

```bash
git clone https://github.com/behlulalar/claude-orchestrator.git
cd claude-orchestrator && ./install.sh
```

Copies the skill to `~/.claude/skills/orchestrator` (and `~/.cursor/skills`) and adds a short pointer to `~/.claude/CLAUDE.md`.

## What it enforces

- Small/medium tasks: no sub-agents, no overhead
- Explicit `model:` on every sub-agent call (haiku / sonnet / opus), escalate one tier on failure
- One owner per file, independent units in parallel, report cap of 120 words
- Risk-proportional verification
- Prod/server safety gates: agents prepare, the user approves anything touching live systems
