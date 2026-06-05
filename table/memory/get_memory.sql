---- # get_memory
----
---- > Returns the most recent thoughts recorded by a given entity, newest first.
---- **Parameters**
---- - `entity_enum`: __p_entity__
----     - *actor whose thoughts to fetch; null returns every entity*
---- - `integer`: __p_limit__
----     - *maximum rows to return; defaults to 10*
---- **Returns**
---- - `TABLE`: *memory rows with tick_stamp cast to text to survive JS Number precision past 2^53*
CREATE OR REPLACE FUNCTION public.get_memory(p_entity entity_enum DEFAULT NULL, p_limit integer DEFAULT 10)
 RETURNS TABLE (
   tick_stamp text,
   entity entity_enum,
   to_entity entity_enum,
   relation relation_enum,
   work work_enum,
   notes text,
   active boolean
 )
 LANGUAGE sql
 STABLE
 SET search_path TO 'public', 'pg_temp'
AS $function$
  SELECT tick_stamp::text, entity, to_entity, relation, work, notes, active
  FROM memory
  WHERE (p_entity IS NULL OR entity = p_entity)
    AND active = true
  ORDER BY tick_stamp DESC
  LIMIT p_limit;
$function$;
