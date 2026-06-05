---- # start_memory_embedding
----
---- > Trigger-only worker that queues one active memory row for embedding through the update-memory Edge Function.
---- **Security**
---- > SECURITY DEFINER is required to read Vault and call pg_net from an insert trigger. The project URL and the secret API key are read from Vault (`SUPABASE_URL_DEV`, `SUPABASE_SECRET_KEY_DEV`) so nothing is hardcoded. The secret key is sent on the `apikey` header, never `Authorization` -- the new Supabase secret keys are not JWTs. update-memory authorizes on that key and runs as service_role.
CREATE OR REPLACE FUNCTION public.start_memory_embedding()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions', 'vault', 'pg_temp'
AS $function$
declare
  supabase_url text;
  secret_key text;
begin
  if new.active then
    select decrypted_secret into supabase_url
    from vault.decrypted_secrets
    where name = 'SUPABASE_URL_DEV';

    select decrypted_secret into secret_key
    from vault.decrypted_secrets
    where name = 'SUPABASE_SECRET_KEY_DEV';

    perform net.http_post(
      url := supabase_url || '/functions/v1/update-memory',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'apikey', secret_key
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
