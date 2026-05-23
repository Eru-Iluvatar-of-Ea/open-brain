# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

All Supabase commands run from `Open-Brain/Supabase/`:

```bash
# Local stack
supabase start
supabase stop

# Develop function locally (hot reload, per_worker policy)
supabase functions serve open-brain-mcp

# Type-check / lint (run from Supabase/functions/)
deno check open-brain-mcp/index.ts
deno lint open-brain-mcp/index.ts

# Deploy to production
supabase functions deploy open-brain-mcp
```

Local secrets live in `Supabase/.env.local` (not committed). The VS Code Deno extension is scoped to `Supabase/functions/`.

## Architecture

Single Supabase Edge Function (`Supabase/functions/open-brain-mcp/index.ts`) that serves an MCP server over HTTP.

**Request flow:**
1. Hono app handles all routes — CORS preflight at `OPTIONS *`, everything else at `ALL *`
2. Auth: `x-brain-key` header or `?key=` query param checked against `MCP_ACCESS_KEY` env var
3. Claude Desktop workaround: missing `Accept: text/event-stream` header is patched onto the request before handing off to `StreamableHTTPTransport`
4. `@hono/mcp` `StreamableHTTPTransport` bridges Hono's request/response to the MCP SDK

**MCP tools registered:**
- `search` / `fetch` — read-only ChatGPT compatibility tools (search/fetch naming convention)
- `search_thoughts` — semantic search via `match_thoughts` Postgres RPC (pgvector)
- `list_thoughts` — recent thoughts with filters (type, topic, person, days)
- `thought_stats` — aggregate counts by type/topic/people
- `capture_thought` — write path: calls OpenRouter for embedding + metadata extraction in parallel, then `upsert_thought` RPC, then updates the embedding column

**External dependencies:**
- `SUPABASE_URL` + `SUPABASE_SERVICE_ROLE_KEY` — direct DB access via service role (bypasses RLS)
- `OPENROUTER_API_KEY` — embeddings via `openai/text-embedding-3-small`, metadata via `openai/gpt-4o-mini`
- `MCP_ACCESS_KEY` — custom auth key for all requests
- `OPEN_BRAIN_CITATION_BASE_URL` — optional base URL for thought citation links (defaults to `https://openbrain.local/thoughts`)

**Database schema (inferred from RPC calls):**
- `thoughts` table: `id`, `content`, `metadata` (JSONB with `type`, `topics`, `people`, `action_items`), `embedding` (vector), `created_at`, `updated_at`
- `match_thoughts(query_embedding, match_threshold, match_count, filter)` — pgvector similarity search RPC
- `upsert_thought(p_content, p_payload)` — dedup + insert RPC, returns `{ id }`

**Import map:** `deno.json` pins all npm deps. No lock file — versions are fixed in `deno.json` directly.

**Two-layer auth:** Every request must pass both Supabase JWT verification (`verify_jwt = true` in `config.toml`) and the custom `x-brain-key` header / `?key=` param check against `MCP_ACCESS_KEY`. Supabase handles JWT first; the function handles the key.

**`capture_thought` write path detail:** embedding and metadata are fetched in parallel via `Promise.all`, then `upsert_thought` RPC runs, and finally a separate `supabase.from("thoughts").update({ embedding })` call writes the vector. Two round-trips are required because the RPC doesn't accept the embedding column directly.

**Claude Desktop header workaround:** `StreamableHTTPTransport` requires `Accept: text/event-stream`. Claude Desktop connectors omit it, so the Hono handler reconstructs the raw `Request` with the header patched in before handing off to the transport (see the `duplex: "half"` comment at index.ts:540).
