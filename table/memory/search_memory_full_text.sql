---- # find_memory_by_fts
----
---- > Single-argument full-text search across memory and todo notes.
---- > Returns ranked hits with full notes, score-desc, newest-first within tie.
----
---- **Parameters**
---- - `text`: __p_query__
----     - *websearch-syntax query string. Supports AND, OR, quoted phrases.*
----
---- **Returns**
---- - `TABLE`: *source, tick_stamp (text), entity, work, notes, score*
----
---- **Notes**
---- > No limit. Callers paginate with their own LIMIT clause.
---- > Always returns full notes. Excerpt mode lives in search_memory if needed.
---- > tick_stamp cast to text to survive JS Number precision past 2^53.
CREATE OR REPLACE FUNCTION public.find_memory_by_fts(p_query text)
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
 SET search_path TO 'public', 'pg_temp'
AS $function$
  WITH parsed AS (
    SELECT websearch_to_tsquery('english', p_query) AS tsquery
  )
  SELECT 'memory'::text,
         memory.tick_stamp::text,
         memory.entity,
         memory.work,
         memory.notes,
         ts_rank(memory.notes_fts, parsed.tsquery)
  FROM public.memory, parsed
  WHERE memory.notes_fts @@ parsed.tsquery
    AND memory.active = true
  UNION ALL
  SELECT 'todo'::text,
         todo.tick_stamp::text,
         todo.assigned_entity,
         todo.work,
         todo.notes,
         ts_rank(todo.notes_fts, parsed.tsquery)
  FROM public.todo, parsed
  WHERE todo.notes_fts @@ parsed.tsquery
  ORDER BY 6 DESC, 2 DESC;
$function$;
