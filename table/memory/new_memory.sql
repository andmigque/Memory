---- # new_memory
----
---- > Inserts a thought into the memory table and returns the new row with tick_stamp as text.
---- **Parameters**
---- - `entity_enum`: __p_entity__
----     - *actor recording the thought*
---- - `entity_enum`: __p_to_entity__
----     - *target of the relation*
---- - `relation_enum`: __p_relation__
----     - *verb connecting entity to to_entity*
---- - `work_enum`: __p_work__
----     - *project or stream the thought belongs to*
---- - `text`: __p_notes__
----     - *body of the thought*
---- **Returns**
---- - `TABLE`: *the inserted row with tick_stamp cast to text to survive JS Number precision past 2^53*
CREATE OR REPLACE FUNCTION public.new_memory(p_entity entity_enum, p_to_entity entity_enum, p_relation relation_enum, p_work work_enum, p_notes text)
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
 SET search_path TO 'public', 'pg_temp'
AS $function$
  WITH inserted AS (
    INSERT INTO memory (entity, to_entity, relation, work, notes)
    VALUES (p_entity, p_to_entity, p_relation, p_work, p_notes)
    RETURNING tick_stamp, entity, to_entity, relation, work, notes, active
  )
  SELECT tick_stamp::text, entity, to_entity, relation, work, notes, active
  FROM inserted;
$function$;
