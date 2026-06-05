---- # new_memory
----
---- > Inserts a memory row and returns the new row.
---- **Parameters**
---- - `entity_enum`: __p_entity__
----     - *actor recording the memory*
---- - `entity_enum`: __p_to_entity__
----     - *target of the relation*
---- - `relation_enum`: __p_relation__
----     - *verb connecting entity to to_entity*
---- - `work_enum`: __p_work__
----     - *project or stream the memory belongs to*
---- - `text`: __p_notes__
----     - *body of the memory*
---- **Returns**
---- - `TABLE`: *the inserted row*
CREATE OR REPLACE FUNCTION public.new_memory(p_entity entity_enum, p_to_entity entity_enum, p_relation relation_enum, p_work work_enum, p_notes text)
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
 SET search_path TO 'public', 'pg_temp'
AS $function$
  WITH inserted AS (
    INSERT INTO memory (entity, to_entity, relation, work, notes)
    VALUES (p_entity, p_to_entity, p_relation, p_work, p_notes)
    RETURNING id, epoch, entity, to_entity, relation, work, notes, active
  )
  SELECT id, epoch, entity, to_entity, relation, work, notes, active
  FROM inserted;
$function$;
