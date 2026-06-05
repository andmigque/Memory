---- # grant_memory_access
----
---- > Authoritative execute and table grant posture for the Memory system.
---- > Apply AFTER the table, functions, and trigger exist.
---- **Why**
---- > The spec revokes direct RPC access from public, anon, and authenticated. That revoke
---- > also strips the default PUBLIC grant, which `service_role` relies on. `service_role`
---- > bypasses RLS but NOT function EXECUTE or base-table privileges, so the invoke-memory-embedding
---- > Edge Function (which calls in as `service_role` over PostgREST) must be re-granted its surface.
---- > A freshly migration-created table also does not inherit Supabase default table grants.

---- > Block direct enrichment RPCs from the public-facing roles.
REVOKE EXECUTE ON FUNCTION public.set_memory_embedding(bigint, text) FROM public, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.start_memory_embedding() FROM public, anon, authenticated;

---- > Re-grant the Edge Function surface to service_role: the single-row embed, the queue
---- > backfill, and both search RPCs are all invoked as service_role.
GRANT EXECUTE ON FUNCTION public.set_memory_embedding(bigint, text) TO service_role;
GRANT EXECUTE ON FUNCTION public.get_memory_embedding_queue(integer) TO service_role;
GRANT EXECUTE ON FUNCTION public.search_memory(text, extensions.vector, integer, integer) TO service_role;
GRANT EXECUTE ON FUNCTION public.search_memory_embedding(extensions.vector, real, integer) TO service_role;

---- > The Edge Function reads the memory table directly (remaining-count) and updates it via
---- > set_memory_embedding. A migration-created table grants nothing by default, so grant explicitly.
---- > DELETE is intentionally omitted; the restrictive delete policy denies it regardless.
GRANT SELECT, INSERT, UPDATE ON public.memory TO service_role;
GRANT USAGE, SELECT ON SEQUENCE public.memory_id_seq TO service_role;
