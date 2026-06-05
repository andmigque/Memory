---- # convertto_memory_sentence
----
---- > Renders a memory row into the canonical sentence used for semantic embedding.
---- **Parameters**
---- - `entity_enum`: __p_entity__
---- - `relation_enum`: __p_relation__
---- - `entity_enum`: __p_to_entity__
---- - `work_enum`: __p_work__
---- - `text`: __p_notes__
---- **Returns**
---- - `text`: *entity relation target, work tag, and notes*
CREATE OR REPLACE FUNCTION public.convertto_memory_sentence(p_entity entity_enum, p_relation relation_enum, p_to_entity entity_enum, p_work work_enum, p_notes text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'public', 'pg_temp'
AS $function$
  select p_entity::text || ' ' || p_relation::text || ' ' || p_to_entity::text
      || ' [' || p_work::text || '] ' || p_notes;
$function$;
