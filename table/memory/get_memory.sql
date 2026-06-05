---- # get_memory
----
---- > Returns the most recent memories recorded by a given entity, newest first.
---- **Parameters**
---- - `entity_enum`: __p_entity__
----     - *actor whose memories to fetch; null returns every entity*
---- - `integer`: __p_limit__
----     - *maximum rows to return; defaults to 10*
---- **Returns**
---- - `TABLE`: *memory rows*
CREATE OR REPLACE FUNCTION public.get_memory(p_entity entity_enum DEFAULT NULL, p_limit integer DEFAULT 10)
 RETURNS TABLE (
   id bigint,
   epoch bigint,
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
  SELECT id, epoch, entity, to_entity, relation, work, notes, active
  FROM memory
  WHERE (p_entity IS NULL OR entity = p_entity)
    AND active = true
  ORDER BY epoch DESC,
           id DESC
  LIMIT p_limit;
$function$;
