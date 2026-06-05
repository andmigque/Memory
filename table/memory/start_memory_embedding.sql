---- # start_memory_embedding
----
---- > Trigger-only worker that queues one active memory row for embedding through the invoke-memory-embedding Edge Function.
---- **Security**
---- > SECURITY DEFINER is required to read Vault and call pg_net from an insert trigger. The project URL and service role key are read from Vault (`SUPABASE_URL_DEV`, `SUPABASE_SERVICE_ROLE_KEY_DEV`) so nothing is hardcoded; these are the same names the client uses. The Edge Function gates on the service role key. Direct RPC execution is revoked from public, anon, and authenticated roles in grant_memory_access.sql.
CREATE OR REPLACE FUNCTION public.start_memory_embedding()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions', 'vault', 'pg_temp'
AS $function$
declare
  supabase_url text;
  service_role_key text;
begin
  if new.active then
    select decrypted_secret into supabase_url
    from vault.decrypted_secrets
    where name = 'SUPABASE_URL_DEV';

    select decrypted_secret into service_role_key
    from vault.decrypted_secrets
    where name = 'SUPABASE_SERVICE_ROLE_KEY_DEV';

    perform net.http_post(
      url := supabase_url || '/functions/v1/invoke-memory-embedding',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || service_role_key
      ),
      body := jsonb_build_object(
        'action', 'set_memory_embedding',
        'id', new.id,
        'sentence', public.convertto_memory_sentence(new.entity, new.relation, new.to_entity, new.work, new.notes)
      )
    );
  end if;

  return new;
end;
$function$;

CREATE OR REPLACE TRIGGER start_memory_embedding_after_insert
AFTER INSERT ON public.memory
FOR EACH ROW
EXECUTE FUNCTION public.start_memory_embedding();
