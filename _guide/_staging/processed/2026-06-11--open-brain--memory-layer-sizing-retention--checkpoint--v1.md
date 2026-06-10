---
title: Checkpoint — Memory layer sizing, retention, and the push/pull retrieval model
version: 1
date: 2026-06-11
owner: Peter Doolan
domain: open-brain
chapters: [capture-strategy (new), memory-architecture (new)]
doctype: checkpoint
tags: [open-brain, checkpoint, kb-staging]
summary: >
  Open Brain has no meaningful size ceiling and should grow unbounded;
  curation is about correctness, not volume. Layer 1 user-edits are pushed
  every turn; Open Brain is pulled on demand and only when the model
  chooses to call it.
---

# Checkpoint — Memory layer sizing, retention, and the push/pull retrieval model

## How it works

- Open Brain is pull-based: nothing loads automatically. Thoughts enter context only via a tool call, and only the top-k matches (default 10) above the similarity threshold (default 0.5) reach the model.
- Tool invocation is the model's judgment call per turn, not a reflex — it can be missed on turns where it would have helped. Client-dependent: Claude Desktop auto-selects well; ChatGPT needs explicit prompting initially.
- "Up to 10 results" is a ceiling, not a guarantee — queries with no matches above threshold return fewer or zero. Limit and threshold are adjustable per call.
- Size guidance: under ~25 entries search feels sparse; ~30 to low thousands is the long-term sweet spot; tens of thousands+ still fine (HNSW index built for it). No target number — the layer is designed to grow unbounded, and bigger generally improves retrieval.
- Irrelevant entries are not noise: similarity ranking means they never surface for unrelated queries. Capacity is never the limiting factor; relevance of what goes in is.

## How Peter uses it

- Two-layer split, deliberately drawn: Layer 1 user-edits (30-slot, pushed every turn, zero latency) holds cross-cutting must-never-miss rules; Open Brain (unbounded, pulled on demand, costs a tool round-trip) holds everything else. Thought #2's Amanda/Rivendell in-pocket-latency rationale is this line.
- Corrective-entry pattern already in use: thoughts #8 (Obsidian obsolete) and #9 (Cursor uninstalled) override stale beliefs rather than deleting them — the right pattern for an append-only layer.
- Current state: 46 thoughts (45 seeded 5/10–5/11 plus the e2e test row) — just past the sparse zone.

## Gotchas + limits

- Main trap: applying 30-slot user-edits discipline (rationing, pruning for tidiness) to Open Brain. Wrong layer — the table is not a curated index.
- Deletion priorities are narrow: factually wrong entries (can surface and mislead), contradictions (both sides can surface), test rows, optionally duplicates. Everything else: retain.
- A wrong entry edited without re-embedding is worse than a deleted one (silent drift — see update-handling checkpoint).
- Because retrieval is discretionary, anything that must fire on every turn cannot live in Open Brain — it belongs in Layer 1.

## Design rationale

- Adding a corrective thought beats deleting the wrong one: no delete tool exists yet, and a well-phrased correction actively steers retrieval where deletion only removes a data point.
- Capture granularity, not volume, is the quality lever: one idea per entry; a fuzzy multi-topic entry hurts retrieval more than thousands of clean atomic ones.

## Supersedes

- Corrects Peter's stated model that Open Brain is called "every time" with the ten most relevant — retrieval is conditional on the model choosing to call the tool, and 10 is a ceiling above threshold, not a fixed return.

## Open questions

- Whether "Peter" in the seeded thoughts vs the Eru/ryslipp account identity affects how "my" queries rank — flagged, unconfirmed.
