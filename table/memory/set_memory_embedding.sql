---- # set_memory_embedding
----
---- > Stores a 384-dimensional embedding for one memory row.
---- **Parameters**
---- - `bigint`: __p_id__
----     - *memory row identifier.*
---- - `text`: __p_embedding__
----     - *JSON array string cast to vector(384).*
---- **Returns**
---- - `bigint`: *updated memory row identifier*
CREATE OR REPLACE FUNCTION public.set_memory_embedding(p_id bigint, p_embedding text)
 RETURNS bigint
 LANGUAGE sql
 SET search_path TO 'public', 'extensions', 'pg_temp'
AS $function$
  update public.memory
  set embedding = p_embedding::extensions.vector(384)
  where id = p_id
  returning id;
$function$;
