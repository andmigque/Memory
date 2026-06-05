# RULES.md

Project-specific rules for the Memory repository.

Memory is a `public.memory` table on Supabase with hybrid full-text + 384-dim `gte-small` vector
search, an async embedding trigger, and one Edge Function. `memory.spec.md` is the source of truth.

## Rules

1. **`memory.spec.md` is the source of truth; reconcile spec and code in the same change.**
   Violated when: SQL or the Edge Function changes behavior without the matching edit to `memory.spec.md`.

2. **SQL files are PowerShell Verb-Noun.** `<ApprovedVerb>_<noun>.sql`; run `Get-Verb` for the list.
   Violated when: a file in `table/` or `type/` leads with a non-verb (e.g. `memory_grants.sql`).

3. **The enums are shared with the thot system — extend, never recreate.** Use
   `ALTER TYPE ... ADD VALUE IF NOT EXISTS`.
   Violated when: a deploy runs `CREATE TYPE` for `entity_enum`, `relation_enum`, or `work_enum`.

4. **The Edge Function is private and gates on the service role key.** It is deployed
   `verify_jwt = false` and rejects any bearer token that is not the service role key. Every caller —
   client and trigger — presents `SUPABASE_SERVICE_ROLE_KEY_DEV`.
   Violated when: a caller uses the anon or publishable key, or the in-function gate is removed.

5. **Nothing hardcodes a project ref.** The trigger reads `SUPABASE_URL_DEV` and
   `SUPABASE_SERVICE_ROLE_KEY_DEV` from Vault — the same names the client reads from the environment.
   Violated when: a project URL, ref, or key literal appears in any SQL or function file.

6. **`service_role` keeps explicit grants after the revoke.** `grant_memory_access.sql` revokes the
   write RPCs from `public`/`anon`/`authenticated`, then grants the Edge Function's surface back to
   `service_role`.
   Violated when: the revoke ships without the matching `service_role` grants (the function then 500s
   "permission denied").

7. **Embed in small batches.** `update_memory_embedding_queue` with a large batch hits
   `WORKER_RESOURCE_LIMIT`; the per-insert trigger embeds one row and is the normal path.
   Violated when: a backfill call uses a batch large enough to exhaust the edge worker.

8. **`Set-StrictMode` lives in the `.ps1` file, not the shell.** Dot-source the script and call it.
   Violated when: `Set-StrictMode` appears in an ad-hoc shell command.
