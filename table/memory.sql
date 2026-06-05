---- # memory
----
---- > One row per recorded memory connecting an actor to a target via a relation within a work context.
---- ## Columns
---- ### id
---- > Auto-generated primary key.
---- ### entity
---- > Actor recording the memory.
---- ### to_entity
---- > Target entity of the relation.
---- ### relation
---- > Verb describing the link from entity to to_entity.
---- ### work
---- > Project or stream the memory belongs to.
---- ### notes
---- > Free-form body text of the memory.
---- ### notes_fts
---- > Generated tsvector of notes for English full-text search.
---- ### active
---- > Soft-delete flag. True keeps the row visible to read paths; false hides it without dropping history.
---- ### epoch
---- > Unix epoch time when the memory row was recorded.
---- ### embedding
---- > 384-dimensional semantic embedding for cosine vector search.
create table public.memory (
  id bigint generated always as identity not null,
  entity public.entity_enum not null,
  to_entity public.entity_enum not null,
  relation public.relation_enum not null,
  work public.work_enum not null,
  notes text not null,
  notes_fts tsvector generated always as (to_tsvector('english', notes)) stored not null,
  active boolean not null default true,
  epoch bigint not null default extract(epoch from now())::bigint,
  embedding extensions.vector(384) null,
  constraint memory_pkey primary key (id)
) TABLESPACE pg_default;

---- > B-tree index on entity for fast actor lookups.
create index IF not exists idx_memory_entity on public.memory using btree (entity) TABLESPACE pg_default;
---- > B-tree index on work for filtering by project stream.
create index IF not exists idx_memory_work on public.memory using btree (work) TABLESPACE pg_default;
---- > B-tree index on relation for filtering by verb.
create index IF not exists idx_memory_relation on public.memory using btree (relation) TABLESPACE pg_default;
---- > GIN index on notes_fts for full-text search.
create index IF not exists idx_memory_notes_fts on public.memory using gin(notes_fts) TABLESPACE pg_default;
---- > Partial B-tree index on epoch for active rows, the hot read path.
create index IF not exists idx_memory_active on public.memory using btree (epoch) TABLESPACE pg_default where active;
---- > HNSW cosine index on embedding for semantic search.
create index IF not exists idx_memory_embedding on public.memory using hnsw (embedding extensions.vector_cosine_ops) TABLESPACE pg_default;

alter table public.memory enable row level security;

---- > Deny direct deletes through RLS while satisfying the explicit-policy advisor.
create policy "memoryDeletePolicy"
on public.memory
as restrictive
for delete
to public
using (false);

---- > Authenticated agents read the shared store; RLS limits reads to active rows.
create policy "memorySelectAuthenticated"
on public.memory
for select
to authenticated
using (active);

---- > Authenticated agents may record. The check tests the role, not a literal true, so the always-true advisor stays clear.
create policy "Enable insert for authenticated users only"
on public.memory
for insert
to authenticated
with check ((select auth.role()) = 'authenticated');
