---- # search_memory
----
---- > Reciprocal-rank fusion over full-text memory search and semantic vector search.
---- ---
---- **Parameters**
---- - `text`: __p_query__
----     - *websearch-syntax query string.*
---- - `vector`: __p_query_embedding__
----     - *384-dimensional query embedding.*
---- - `integer`: __p_match_count__
----     - *maximum returned rows; defaults to 20.*
---- - `integer`: __p_rrf_k__
----     - *reciprocal-rank fusion constant; defaults to 50.*
---- **Returns**
---- - `TABLE`: *source, tick_stamp (text), entity, work, notes, and fused score*
CREATE OR REPLACE FUNCTION public.search_memory(p_query text, p_query_embedding extensions.vector, p_match_count integer DEFAULT 20, p_rrf_k integer DEFAULT 50)
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
  with fts as (
    select memory.tick_stamp,
           row_number() over (
             order by ts_rank(memory.notes_fts, websearch_to_tsquery('english', p_query)) desc
           ) as rank
    from public.memory
    where memory.active = true
      and memory.notes_fts @@ websearch_to_tsquery('english', p_query)
  ),
  sem as (
    select memory.tick_stamp,
           row_number() over (order by memory.embedding <=> p_query_embedding) as rank
    from public.memory
    where memory.active = true
      and memory.embedding is not null
  ),
  fused as (
    select coalesce(fts.tick_stamp, sem.tick_stamp) as tick_stamp,
           coalesce(1.0 / (p_rrf_k + fts.rank), 0.0)
         + coalesce(1.0 / (p_rrf_k + sem.rank), 0.0) as score
    from fts
    full outer join sem on fts.tick_stamp = sem.tick_stamp
  )
  select 'memory'::text,
         memory.tick_stamp::text,
         memory.entity,
         memory.work,
         memory.notes,
         fused.score::real
  from fused
  join public.memory on memory.tick_stamp = fused.tick_stamp
  where memory.active = true
  order by fused.score desc, memory.tick_stamp desc
  limit p_match_count;
$function$;
