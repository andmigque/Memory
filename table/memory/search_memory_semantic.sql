---- # match_memory
----
---- > Semantic cosine search over active memory embeddings.
---- **Parameters**
---- - `vector`: __p_query_embedding__
----     - *384-dimensional query embedding.*
---- - `real`: __p_match_threshold__
----     - *minimum cosine similarity; defaults to 0.5.*
---- - `integer`: __p_match_count__
----     - *maximum returned rows; defaults to 20.*
---- **Returns**
---- - `TABLE`: *source, tick_stamp (text), entity, work, notes, and similarity score*
CREATE OR REPLACE FUNCTION public.match_memory(p_query_embedding extensions.vector, p_match_threshold real DEFAULT 0.5, p_match_count integer DEFAULT 20)
 RETURNS TABLE (
   source text,
   tick_stamp text,
   entity entity_enum,
   work work_enum,
   notes text,
   score real
 )
 LANGUAGE sql
 STABLE
 SET search_path TO 'public', 'extensions', 'pg_temp'
AS $function$
  select 'memory'::text,
         memory.tick_stamp::text,
         memory.entity,
         memory.work,
         memory.notes,
         (1 - (memory.embedding <=> p_query_embedding))::real as score
  from public.memory
  where memory.active = true
    and memory.embedding is not null
    and (1 - (memory.embedding <=> p_query_embedding)) > p_match_threshold
  order by memory.embedding <=> p_query_embedding
  limit p_match_count;
$function$;
