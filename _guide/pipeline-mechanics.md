---
title: Pipeline Mechanics — capture, embeddings, search semantics, timestamps
chapter: pipeline-mechanics
compiled: 2026-06-11
sources:
  - 2026-06-11--open-brain--update-handling-append-only--checkpoint--v1.md
---

# Pipeline Mechanics

## How a thought moves through the system

- Capture (Slack `ingest-thought` or MCP `capture_thought`) runs two OpenRouter calls in parallel: embedding via `openai/text-embedding-3-small` (1536 dims) and metadata extraction via `openai/gpt-4o-mini` (type + topics + people). Result inserts into the `thoughts` table with pgvector.
- The embedding is generated from the content **at capture time** and stored alongside it. `match_thoughts()` compares query vectors against the stored embedding, never the text. Content and embedding are coupled; the embedding is a function of the exact captured text.
- Tool surface is three read (`search_thoughts`, `list_thoughts`, `thought_stats`), one write (`capture_thought`, insert-only).

## Embedding drift — the core hazard

- Editing `content` directly (Table Editor or naive SQL UPDATE) leaves the old embedding in place: the row displays new text but semantic search keeps matching the old meaning. Silent — nothing errors. Any content change must regenerate the embedding (see extending-the-system).

## Timestamps

- `created_at` is UTC. At UTC+10 (Murrumbateman), late-day captures land on the "previous" date in the database. Date filters (`days`, ranges) cut on UTC boundaries, not local time.

## Verified behavior

- End-to-end pipeline verified live (late May 2026 session): `capture_thought` → metadata auto-classified (type `observation`, topics `verification, test, memory`) → embedding generated → pgvector insert → retrieved via a paraphrased semantic query at 66.4% similarity, above the 0.5 default threshold. Test row marker: `obtest-e2e-20260530`, safe to delete.
- Slack-retry duplicates (function response >3s) are documented as harmless to search; identical rows can be deleted from the Table Editor if desired.
