---- # grant_memory_access
----
---- > Authoritative grant posture for the Memory system. Apply AFTER the table, functions, policies, and trigger exist.
---- **Model**
---- > Agents authenticate as Supabase Auth users and call as the `authenticated` role; Row Level Security
---- > scopes what they read and write. Embedding writes are server-only: the `update-memory` Edge Function
---- > authorizes on the project secret key and runs as `service_role`. No client holds the secret key.

---- > Authenticated agents record and search. RLS governs the rows; these grants open the surface.
GRANT EXECUTE ON FUNCTION public.new_memory(entity_enum, entity_enum, relation_enum, work_enum, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.search_memory(text, extensions.vector, integer, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.search_memory_embedding(extensions.vector, real, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_memory(entity_enum, integer) TO authenticated;
GRANT SELECT, INSERT ON public.memory TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.memory_id_seq TO authenticated;

---- > Embedding writes are not reachable by public-facing roles. Only update-memory (service_role) writes them.
REVOKE EXECUTE ON FUNCTION public.set_memory_embedding(bigint, text) FROM public, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.start_memory_embedding() FROM public, anon, authenticated;

---- > The update-memory Edge Function calls in with the secret key as service_role; grant it the write surface.
GRANT EXECUTE ON FUNCTION public.set_memory_embedding(bigint, text) TO service_role;
GRANT EXECUTE ON FUNCTION public.get_memory_embedding_queue(integer) TO service_role;
GRANT SELECT, UPDATE ON public.memory TO service_role;
