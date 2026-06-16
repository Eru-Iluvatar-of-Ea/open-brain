-- Re-harden function search_path after enhanced-thoughts.
--
-- schemas/enhanced-thoughts/schema.sql re-creates public.upsert_thought and
-- creates public.search_thoughts_text WITHOUT a pinned search_path. Applying
-- it re-triggers Supabase linter 0011 (mutable search_path) on both — and the
-- upsert_thought re-create silently drops the pin set in migration
-- 20260616180450. Re-pin both so the security advisor stays clean.
--
-- Both function bodies already schema-qualify public.thoughts, so this is a
-- security-hygiene change only; behavior is unchanged. Idempotent.

alter function public.upsert_thought(text, jsonb)
  set search_path = public, extensions, pg_temp;

alter function public.search_thoughts_text(text, integer, jsonb, integer)
  set search_path = public, extensions, pg_temp;
