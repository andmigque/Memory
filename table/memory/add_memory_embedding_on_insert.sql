---- # embed_memory_on_insert
----
---- > Trigger-only worker that queues one active memory row for embedding through the embed-memory Edge Function.
---- **Security**
---- > SECURITY DEFINER is required to read Vault and call pg_net from an insert trigger. Direct RPC execution is revoked from public, anon, and authenticated roles in the semantic-search migration.
CREATE OR REPLACE FUNCTION public.embed_memory_on_insert()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions', 'vault', 'pg_temp'
AS $function$
declare
  embed_memory_key text;
begin
  if new.active then
    select decrypted_secret into embed_memory_key
    from vault.decrypted_secrets
    where name = 'embed_memory_anon_key';

    perform net.http_post(
      url := 'https://nbzqdmaryftngegnnokk.supabase.co/functions/v1/embed-memory',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || embed_memory_key
      ),
      body := jsonb_build_object(
        'action', 'embed_one',
        'tickStamp', new.tick_stamp::text,
        'sentence', public.memory_sentence(new.entity, new.relation, new.to_entity, new.work, new.notes)
      )
    );
  end if;

  return new;
end;
$function$;
