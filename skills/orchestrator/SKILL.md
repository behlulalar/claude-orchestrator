---
name: orchestrator
description: "Lean delegation policy. Use ONLY for large or parallel work (many independent units, wide codebase search, bulk edits) or anything touching prod/servers. Skip for small and medium tasks: do them directly. Tetikleyiciler: alt ajan, orkestrasyon, paralel iş, toplu işlem, prod, deploy, sunucu."
---

# Orchestrator (lean)

Delegation costs tokens (cold start, brief, report, verification). Delegate only when it pays off.

## When NOT to delegate (default)
Do it yourself if the task is a single feature/fix, touches <= ~5 files, or you already hold the context. No skill overhead, no sub-agents.

## What counts as "large / parallel"
Delegate only if at least one holds:
- 3+ units that don't depend on each other's output and touch different files (e.g. DB + API + UI after the contract is fixed)
- The work would read/edit more than ~10 files, or search a codebase you can't map in a few greps
- The same mechanical change repeated across many files/items
If units depend on each other (schema -> backend -> frontend), run them in sequence, or just do them yourself.

## When to delegate
- 3+ independent units that can run in parallel
- Wide search across a big codebase (`Explore`, haiku, ask for paths + 1-line conclusions)
- Bulk mechanical work (rename/migrate/format many files): haiku with exact rules + 2 examples
- Independent security review of auth/payments/migrations: fresh opus, read-only, different from the author

## Rules
1. Always set `model:` explicitly (haiku / sonnet / opus). Never inherit.
2. Cheapest tier that can do it; escalate one tier on failure with the error in the brief. Max 2 tries per tier.
3. One owner per file. Launch independent units in one message.
4. Brief = goal, context the agent can't discover, files in/out of scope, done-when. Point to paths, don't paste contents.
5. Report cap: "<=120 words: status, files changed, verification result, open issues."
6. Verify proportionally: low risk -> `git diff --stat`; medium -> key hunks + tests pass; high (auth, money, migrations, deletion, infra) -> opus review of the diff.

## Prod safety gates (non-negotiable)
Agents prepare; the user approves anything that changes a live system.
- No deploys, restarts, live migrations, firewall/SSH/TLS/DNS changes, secret rotation or data deletion without an explicit "yes" in chat for that exact action (state what, where, rollback, blast radius).
- Prod/server tasks default to read-only audit or dry-run.
- Never print or commit secrets; reference by name.
- Destructive migrations need a backup step and rollback plan.
