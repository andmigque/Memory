---- # set_memory_embedding
----
---- > Stores a 384-dimensional embedding for one memory row.
---- **Parameters**
---- - `text`: __p_tick_stamp__
----     - *tick stamp as text to avoid JavaScript number precision loss.*
---- - `text`: __p_embedding__
----     - *JSON array string cast to vector(384).*
---- **Returns**
---- - `text`: *updated tick_stamp*
CREATE OR REPLACE FUNCTION public.set_memory_embedding(p_tick_stamp text, p_embedding text)
 RETURNS text
 LANGUAGE sql
 SET search_path TO 'public', 'extensions', 'pg_temp'
AS $function$
  update public.memory
  set embedding = p_embedding::extensions.vector(384)
  where tick_stamp = p_tick_stamp::bigint
  returning tick_stamp::text;
$function$;
