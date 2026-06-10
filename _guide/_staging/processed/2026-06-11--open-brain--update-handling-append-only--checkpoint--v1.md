---
title: Checkpoint — Update handling and the append-only design
version: 1
date: 2026-06-11
owner: Peter Doolan
domain: open-brain
chapters: [extending-the-system (new), pipeline-mechanics (new)]
doctype: checkpoint
tags: [open-brain, checkpoint, kb-staging]
summary: >
  Why Open Brain is append-only, the embedding-drift trap when editing rows
  directly, the shape of a correct update/delete tool, and the verified
  end-to-end capture pipeline.
---

# Checkpoint — Update handling and the append-only design

## How it works

- Open Brain ships with four MCP tools: three read (`search_thoughts`, `list_thoughts`, `thought_stats`), one write (`capture_thought`) — insert-only. No update or delete tools exist.
- Each row stores `content` plus an `embedding vector(1536)` generated from that exact text at capture time; `match_thoughts()` compares query vectors against the stored embedding, never the text.
- A correct update is therefore always two steps: write new `content` AND regenerate the embedding from it. The schema's unused `updated_at` column is intended for this.
- Delete is simpler — no embedding to maintain: `.delete().eq("id", id)`.
- An update tool follows the `capture_thought` pattern keyed by `id`: find via search/list, re-run `getEmbedding(newContent)`, single `update()` call with content + embedding + `updated_at`.

## How Peter uses it

- Current edit path is the Supabase Table Editor only (manual, row-level).
- End-to-end pipeline verified live this session: `capture_thought` → metadata extraction (gpt-4o-mini classified type + topics) → embedding (text-embedding-3-small) → pgvector insert → retrieved via paraphrased semantic search at 66.4% similarity. Test row carries marker `obtest-e2e-20260530`, safe to delete.

## Gotchas + limits

- Embedding drift: editing `content` directly (Table Editor or naive SQL UPDATE) leaves the old embedding in place — the row displays new text but search matches the old meaning. Silent, no error.
- `created_at` is UTC; at UTC+10, late-day captures land on the "previous" date. Date filters (`days`, ranges) use UTC boundaries, not local time.
- The test row cannot be deleted from the AI side until a `delete_thought` tool exists.

## Design rationale

- Append-only is intentional for a memory layer: vector retrieval surfaces the most similar rows, so stale duplicates don't degrade search the way they would a notes app. Slack-retry duplicates are documented as harmless.

## Supersedes

- none

## Open questions

- Build `update_thought` / `delete_thought` tools in `open-brain-mcp/index.ts`? Offered, not yet decided.
- Cleanup of test row `obtest-e2e-20260530` pending (leave / Table Editor / delete tool).
