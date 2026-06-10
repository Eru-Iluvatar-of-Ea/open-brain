---
title: Extending the System — update/delete tools and build decisions
chapter: extending-the-system
compiled: 2026-06-11
sources:
  - 2026-06-11--open-brain--update-handling-append-only--checkpoint--v1.md
---

# Extending the System

## Why it ships append-only

- Append-only is intentional for a memory layer: vector retrieval surfaces the most similar rows, so stale duplicates don't degrade search the way they would a notes app. Updates were deliberately punted in the original design.
- Current edit path is the Supabase Table Editor only — manual, row-level, and exposed to the embedding-drift hazard (see pipeline-mechanics).

## Update tool pattern

- Follows the `capture_thought` shape, keyed by `id`:
  1. Find the thought (via `search_thoughts` or `list_thoughts`) to get its `id`.
  2. Re-run `getEmbedding(newContent)` — the same call the capture pipeline uses.
  3. Single call: `supabase.from("thoughts").update({ content, embedding, updated_at }).eq("id", id)`.
- A correct update is always two writes in one: new content AND a regenerated embedding. The schema's `updated_at` column exists for this and is currently unused.

## Delete tool pattern

- Simpler — no embedding to maintain: `supabase.from("thoughts").delete().eq("id", id)`.
- New tools register in `open-brain-mcp/index.ts` via `server.registerTool(name, {title, description, inputSchema}, handler)` — same structure as the four existing tools.

## Open build decisions

- `update_thought` / `delete_thought`: proposed, not yet built. Becomes worthwhile if correctness management (fixing wrong entries) gets frequent; until then the corrective-entry pattern covers most cases (see capture-strategy).
- Pending cleanup: test row `obtest-e2e-20260530` — options are leave it, delete via Table Editor, or build the delete tool and use it.
