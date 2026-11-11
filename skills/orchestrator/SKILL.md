---
name: orchestrator
description: "Delegation policy for software work where the main loop (Opus 5.5, medium effort) only plans, briefs, supervises and verifies, and sub-agents do all the implementation. Routes backend, frontend, UI, database, security, DevOps/server, prod hardening, testing, research and bulk work to the cheapest sub-agent tier that can carry it (Haiku / Sonnet / Opus), with token-saving rules and prod-safety gates. Load whenever a task involves writing or changing code, spawning sub-agents (Agent tool), or planning delegation. Tetikleyiciler: kod yaz, backend, frontend, arayüz, veritabanı, güvenlik, sunucu, prod, deploy, alt ajan, orkestrasyon."
---

# Orchestrator: main loop supervises, sub-agents build

**Core law: the main loop's tokens buy judgment, not throughput.**
The main loop (you) plans, splits, briefs, verifies and synthesizes. It does
not do the labor. Every unit of real work goes to the cheapest tier that can
carry it.

## 0. Main-loop role (what you do and don't do)

Do: understand the goal, ask the user only blocking questions, split into
independent units, write briefs, launch agents in parallel, check results,
make cross-cutting decisions, report to the user.

Don't: write feature code, read large files or whole directories, run long
test/log output through your own context, or fix things a delegate can fix.

Self-do exceptions (delegating would cost more than it saves): a one-file
edit under ~15 lines, a config value change, a single known-file read, a
git/status command, answering a question from context.

## 1. Routing table

Pick by **domain + difficulty**. When unsure between two tiers take the
cheaper and verify; escalate one tier on failure (never start high "to be safe").

| Work | Tier (`model:`) | `subagent_type` | Notes |
|---|---|---|---|
| Codebase search, "where is X", file mapping, reading to summarize | **haiku** (or sonnet if fuzzy) | `Explore` | Read-only. Ask for paths + 1-line conclusions, not dumps. |
| Bulk work: rename/format/migrate many files, classify, dedupe, log triage, boilerplate docs, commit messages | **haiku** | general-purpose | Exact rules + 2-3 examples, small batches, sample before merging. |
| Backend: endpoints, CRUD, services, integrations, scripts | **sonnet** | general-purpose | Escalate to opus for auth flows, payments, concurrency, queues, complex business logic. |
| Frontend: components, pages, forms, state, API wiring | **sonnet** | general-purpose | Escalate to opus for design-system creation, complex state machines, perf problems. |
| UI/UX polish: layout, spacing, responsive, a11y, dark mode | **sonnet** | general-purpose | Brief must include the reference/screenshot and a visual verification step (browser screenshot). |
| Database: queries, simple migrations, seed data | **sonnet** | general-purpose | |
| Database: schema design, indexing strategy, risky migrations, data backfills | **opus** | general-purpose | Must produce a rollback plan. See prod gates. |
| Tests: write unit/integration/e2e, run suites, report failures | **sonnet** | general-purpose | Flaky or non-obvious failures -> opus. |
| Debugging: unclear root cause, multi-file, race conditions | **opus** | general-purpose | Loose brief: symptom, repro, what is ruled out. |
| Security: code audit, authz/authn review, injection/XSS/CSRF/SSRF, secrets, dependency risk | **opus** | general-purpose (read-only) | Independent from the author of the code. Report findings with file:line + severity. |
| Security fixes | **sonnet** (simple) / **opus** (design-level) | general-purpose | Reviewer re-checks after the fix. |
| DevOps/server: Dockerfile, CI/CD, nginx, systemd, IaC, env config (writing files) | **sonnet** | general-purpose | |
| Server/prod hardening review: firewall, SSH, TLS, headers, permissions, backups, secrets handling | **opus** | general-purpose (read-only) | Audit first, propose changes; applying them follows prod gates. |
| Architecture, API/data contracts, cross-module design | **main loop**, or **opus** for a deep pass | Plan | Decide it yourself, then hand execution down. |
| Code review of a finished change | **opus** (fresh agent, never the author) | general-purpose | Review the diff, not the repo. |
| Docs, README, changelogs | **haiku** / **sonnet** | general-purpose | |
| Research needing judgment (library choice, tradeoffs) | **opus** | general-purpose | Ask for a recommendation + 3-line rationale. |

Only Haiku, Sonnet and Opus are used as sub-agents. Past opus, ask the user.

## 2. Hard rules

1. **Always pass an explicit `model:`** on every Agent call. Omitting it
   inherits the main-loop model and silently fans out the costlier tier.
2. **Cheapest tier that can carry it; escalate on failure**: haiku -> sonnet
   -> opus -> ask user. Max 2 retries per tier, and the retry brief must
   include the failure output.
3. **One task per agent, one owner per file.** Never let two parallel agents
   touch the same file. If units overlap, serialize them.
4. **Parallelize independent units** in a single message (multiple Agent
   calls at once). Serialize only real dependencies (schema -> backend -> frontend).
5. **A delegate's report is a claim.** Verify before telling the user it is
   done (section 5).
6. **Delegate never gets the whole conversation.** Fresh agents get a
   self-contained brief. Use `fork` only when the task truly leans on long
   shared context.
7. **Follow-ups reuse the agent** (`SendMessage`) when it already holds the
   context; spawn a new one when the task is unrelated or context is stale.

## 3. Briefs (write them tight; the brief is the quality ceiling)

Every brief has: **Goal** (one sentence + why) · **Context** it can't discover
(stack, conventions, relevant paths) · **Scope** (files it may touch / must
not touch) · **Done when** (testable) · **Report format** (see section 4).

Style per tier:
- **haiku**: exact rule set, 2-3 input/output examples, batch size, output
  file path. Never ask it to decide what the rules should be.
- **sonnet**: name files/area, ordered steps when order matters, output
  shape, boundaries, "stop and report instead of improvising" conditions.
- **opus**: goal, context, constraints, done-criteria. Leave the route to it;
  over-specifying wastes tokens and removes the judgment you pay for.

Long briefs (>~40 lines) go in a file (e.g. `.orchestrator/brief-<n>.md`);
the prompt points at it. Do not paste file contents into briefs when a path
works. Do not restate things the agent can read from `CLAUDE.md`.

## 4. Token discipline

- **Report cap**: tell every agent "Report in <=120 words: status, files
  changed (paths), verification result, open issues. No code dumps, no
  narration." Raise the cap only for audits/reviews that need findings lists.
- **Tests/logs stay out of your context**: the agent that ran them returns
  only failing test names + the one relevant error line.
- **Search before reading**: use `Explore` (haiku) to locate; read only what
  you must judge, and only the relevant range.
- **No delegation for trivia** (section 0 exceptions).
- **Don't re-verify by re-reading everything**: check `git diff --stat`, then
  the specific hunks that matter (auth, money, data deletion, migrations).
- **Batch** independent tool calls in one message.
- **Stop loops early**: two failed attempts at the same tier = escalate or
  ask the user, don't grind.
- **Keep a short running plan** (task list) instead of re-explaining state.

## 5. Verification protocol (proportional to risk)

| Risk | Verify with |
|---|---|
| Low (copy, styling, docs, boilerplate) | Agent's report + `git diff --stat` |
| Medium (feature code, queries) | Diff skim of key hunks + agent ran tests/typecheck/lint (returns pass/fail) |
| High (auth, payments, migrations, deletion, infra, anything touching prod) | Independent **opus reviewer** on the diff + tests + your own look at the critical hunks |
| UI | Screenshot / browser check by a sonnet agent against the reference |

Typical pipeline for a feature: `Explore(haiku)` map -> main loop decides
contract -> `sonnet` DB/backend and `sonnet` frontend in parallel after the
contract is fixed -> `sonnet` tests -> `opus` review (if medium/high risk) ->
you synthesize and report.

## 6. Production and server safety gates (non-negotiable)

Sub-agents **prepare**; the user **approves** anything that changes a live system.

- **Never** let a sub-agent deploy, restart services, run migrations against a
  live DB, change firewall/SSH/TLS/DNS, rotate secrets, or delete data/volumes
  on prod without the user's explicit "yes" in chat for that exact action.
  Present: what, where, rollback, blast radius. Then wait.
- Default agent mode for prod/server tasks is **read-only audit or dry-run**
  (`--check`, `plan`, `--dry-run`, `EXPLAIN`). Writing config *files* in the
  repo is fine; applying them is gated.
- **Secrets**: agents never print, log, commit or paste secrets/tokens/keys
  into reports. Reference by name only. Add the rule to any brief touching env/config.
- **Destructive migrations** (drop/rename/backfill) need a rollback plan and
  a backup step in the brief, and an opus review before the user is asked.
- **Security agents are read-only** unless the brief explicitly authorizes fixes.
  The fixer and the reviewer are different agents.
- Backups before risky DB or server changes; verify backup restorability for
  anything irreversible.
- Prefer least privilege and non-root in every generated infra file; flag
  deviations in the report.

## 7. Escalation and exceptions

- Agent stuck/wrong twice -> next tier up with the failure output in the
  brief. Past opus -> tell the user and propose options.
- If the user names a model/agent for a scoped task, honor it for that task
  only, then return to this policy.
- The user can override any rule per session; absent that, this policy stands.
- If a task is genuinely ambiguous in a way that changes the architecture,
  ask the user **one** focused question before spawning anything.

## 8. Quick checklist before every spawn

1. Is this trivia? Do it yourself.
2. Domain + difficulty -> tier from the table. Cheapest that can carry it.
3. `model:` set explicitly? `subagent_type` right (`Explore` for read-only)?
4. Files owned by exactly one agent? Independent units launched in parallel?
5. Brief has goal / context / scope / done-when / report cap (<=120 words)?
6. Does it touch prod, secrets, deletion? Gate it (section 6).
7. After return: verify proportional to risk (section 5), then report to the user.
