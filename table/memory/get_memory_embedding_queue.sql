---- # get_memory_embedding_queue
----
---- > Returns active memory rows that still need semantic embeddings.
---- **Parameters**
---- - `integer`: __p_limit__
----     - *maximum returned rows; defaults to 64.*
---- **Returns**
---- - `TABLE`: *id and rendered sentence*
CREATE OR REPLACE FUNCTION public.get_memory_embedding_queue(p_limit integer DEFAULT 64)
 RETURNS TABLE (
   id bigint,
   sentence text
 )
 LANGUAGE sql
 STABLE
 SET search_path TO 'public', 'pg_temp'
AS $function$
  select memory.id,
         public.convertto_memory_sentence(memory.entity, memory.relation, memory.to_entity, memory.work, memory.notes)
  from public.memory
  where memory.active = true
    and memory.embedding is null
  order by memory.epoch desc,
           memory.id desc
  limit p_limit;
$function$;
