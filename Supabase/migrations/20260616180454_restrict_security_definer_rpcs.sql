-- Lock down the two SECURITY DEFINER helper RPCs added by enhanced-thoughts.
--
-- enhanced-thoughts/schema.sql GRANTed brain_stats_aggregate and
-- get_thought_connections to authenticated + service_role, but did NOT revoke
-- the default PUBLIC execute. Because both are SECURITY DEFINER (they bypass
-- RLS), the anon role (anyone holding the public Supabase publishable/anon key)
-- could call them via /rest/v1/rpc and read brain stats + per-thought content
-- previews — defeating the service-role-only RLS on thoughts. Supabase linters
-- 0028 (anon) and 0029 (authenticated) flag this.
--
-- Restrict execution to service_role only: the open-brain-rest gateway connects
-- as service_role, so the dashboard is unaffected. Pure tightening (REVOKE only).

revoke execute on function public.brain_stats_aggregate(integer, boolean)
  from public, anon, authenticated;

revoke execute on function public.get_thought_connections(uuid, integer, boolean)
  from public, anon, authenticated;
