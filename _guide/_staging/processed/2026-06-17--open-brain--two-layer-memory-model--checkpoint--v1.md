---
title: Checkpoint — The two-layer memory model (Open Brain connector vs project file-memory)
version: 1
date: 2026-06-17
owner: Peter Doolan
domain: open-brain
chapters: [memory-architecture]
doctype: checkpoint
tags: [open-brain, checkpoint, kb-staging]
summary: >
  Open Brain (account MCP connector, recall-only) and project file-memory
  (auto-loaded, local) are two separate layers that do not sync; how each is
  loaded, what each is for, and why the split exists.
---

# Checkpoint — The two-layer memory model

## How it works
- Two distinct layers. **Open Brain** = an account-level claude.ai MCP connector (server-side); its tools (`capture_thought`, `search_thoughts`, …) are available on every surface signed into the account, in every project directory.
- **Project file-memory** = `~/.claude/projects/<slug>/memory/` with a `MEMORY.md` index, auto-loaded into context at the start of every session — but only *in that project*.
- Open Brain is **recall-only**: never auto-loaded; its content enters context only on an explicit tool call. File-memory is **auto-loaded**: its facts silently shape every session in the project.
- The two layers **do not sync** — a fact in one is not in the other.
- Open Brain tool *schemas* are **deferred** (fetched on demand), so the per-session context cost of leaving the connector attached is near-zero and fixed — it does not scale with the number of tools the server exposes.
- Neither layer captures autonomously: Open Brain tools fire only on explicit calls; `auto-capture` is a behavioral protocol, not a hook.

## How Peter uses it
- Durable, behavior-shaping facts → file-memory (auto-applied, per-project). Cross-project / recall-from-anywhere decisions and ACT NOW items → Open Brain. Conceptual understanding → this guide.
- The `/session-close` skill routes a session's outputs across these sinks; `auto-capture` is the push path to Open Brain at session end.

## Gotchas + limits
- Because Open Brain is recall-only, a **behavioral preference placed there never auto-fires** — it silently does nothing. Such preferences belong in file-memory or CLAUDE.md.
- File-memory is per-project: closing a session in another project writes *that* project's memory, not Open-Brain's.
- A common misconception is that Open Brain auto-loads at session start; it does not.

## Design rationale
- Deferred schemas keep the connector cheap to leave attached on every surface and project.
- Splitting recall-only (searchable, account-wide) from auto-loaded (silent, local) lets each do one job; merging them would either bloat every session or bury cross-project recall.

## Supersedes
- none

## Open questions
- Whether to add a `SessionStart` hook that auto-pulls relevant Open Brain context at session start (does not exist today).
