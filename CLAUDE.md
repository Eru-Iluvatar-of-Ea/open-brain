# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

All Supabase commands run from `Open-Brain/Supabase/`:

```bash
# Local stack
supabase start
supabase stop

# Develop function locally (hot reload)
supabase functions serve open-brain-mcp

# Deploy to production
supabase functions deploy open-brain-mcp
```

The VS Code Deno extension is scoped to `Supabase/functions/` — run `deno lint` or `deno check` from there if needed.

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

**JWT:** `verify_jwt = true` in `config.toml` — Supabase JWT verification is on in addition to the custom `x-brain-key` check.
