---- # memory_needs_embedding
----
---- > Returns active memory rows that still need semantic embeddings.
---- **Parameters**
---- - `integer`: __p_limit__
----     - *maximum returned rows; defaults to 64.*
---- **Returns**
---- - `TABLE`: *tick_stamp (text) and rendered sentence*
CREATE OR REPLACE FUNCTION public.memory_needs_embedding(p_limit integer DEFAULT 64)
 RETURNS TABLE (
   tick_stamp text,
   sentence text
 )
 LANGUAGE sql
 STABLE
 SET search_path TO 'public', 'pg_temp'
AS $function$
  select memory.tick_stamp::text,
         public.memory_sentence(memory.entity, memory.relation, memory.to_entity, memory.work, memory.notes)
  from public.memory
  where memory.active = true
    and memory.embedding is null
  order by memory.tick_stamp desc
  limit p_limit;
$function$;
