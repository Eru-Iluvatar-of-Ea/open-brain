---
title: Capture Strategy — granularity, retention, corrective entries
chapter: capture-strategy
compiled: 2026-06-11
sources:
  - 2026-06-11--open-brain--memory-layer-sizing-retention--checkpoint--v1.md
---

# Capture Strategy

## Granularity is the quality lever

- One idea per entry. The embedding must represent one thing; a fuzzy multi-topic entry hurts retrieval more than thousands of clean atomic ones ever would.
- Volume is not the lever — capacity is unbounded and bigger generally helps (see memory-architecture). What goes in matters; how much doesn't.

## Retention policy: retain by default

- Do not apply 30-slot user-edits discipline (rationing, pruning for tidiness) to Open Brain. Wrong layer — the table is not a curated index, and unretrieved entries cost nothing.
- Deletion is the exception, reserved for: factually wrong entries (can surface and mislead — the only high-priority case), contradictions (both sides can surface and confuse retrieval), test rows, and optionally duplicates.
- Curation is about **correctness, not volume**.

## The corrective-entry pattern

- For an append-only layer, adding a corrective thought often beats deleting the wrong one: a well-phrased correction actively steers retrieval, where deletion only removes a data point. No delete tool exists yet, which makes this the default mechanism.
- In active use already: thought #8 ("exclude Obsidian — obsolete, do not reintroduce") and #9 ("Cursor uninstalled — do not recommend") override stale beliefs rather than removing them.
