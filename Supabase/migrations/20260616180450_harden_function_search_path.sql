-- Harden mutable search_path on the three base functions.
--
-- Supabase linter 0011_function_search_path_mutable: a function with no fixed
-- search_path resolves unqualified names against the caller's path, which can
-- be hijacked. Pin an explicit path instead. Order matters: real schemas first,
-- pg_temp LAST so a temp object can't shadow public.thoughts at call time.
--
-- Function bodies are unchanged. They reference public.thoughts and the pgvector
-- `<=>` operator (which lives in the `extensions` schema here), both covered by
-- this path. Matches config.toml extra_search_path = ["public", "extensions"].
--
-- Idempotent: re-running just re-sets the same path.

alter function public.match_thoughts(vector, double precision, integer, jsonb)
  set search_path = public, extensions, pg_temp;

alter function public.upsert_thought(text, jsonb)
  set search_path = public, extensions, pg_temp;

alter function public.update_updated_at()
  set search_path = public, extensions, pg_temp;
