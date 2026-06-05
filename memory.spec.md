# Memory Requirements

The key words MUST, MUST NOT, SHOULD, SHOULD NOT, and MAY in this document are to be interpreted as described in RFC 2119 and RFC 8174 when, and only when, they appear in all capitals, as shown here.

## Scope

This document defines the current requirements for Memory's core enum vocabulary and memory row shape.

## Requirements

The system MUST store memories in a Postgres table named `public.memory`.

The `public.memory` table MUST represent one recorded memory per row.

The `public.memory` `CREATE TABLE` statement MUST declare an auto-generated primary key column named `id`.

The `public.memory` `CREATE TABLE` statement MUST declare a Unix epoch time column named `epoch`.

The `public.memory` `CREATE TABLE` statement MUST declare `entity`, `to_entity`, `relation`, `work`, `notes`, `notes_fts`, `active`, and `embedding`.

The `public.memory` `CREATE TABLE` statement MUST mark `entity`, `to_entity`, `relation`, `work`, `notes`, `notes_fts`, and `active` as not null.

The `embedding` column MAY be null while semantic embedding is pending.

The system MUST use `entity_enum` to identify actors and systems that can record or receive a memory row.

The `entity_enum` values MUST be case-sensitive on the wire.

The system MUST use `relation_enum` to identify the action performed by the recording entity.

The `relation_enum` values MUST support the sentence shape: `entity relation to_entity`.

The `relation_enum` values SHOULD be verbs.

The system MUST use `work_enum` to identify the work domain of a memory row.

The `work_enum` values MUST describe work domains, not project lore.

The system MUST use `invariant_enum` to represent non-negotiable operating rules as data.

The `invariant_enum` values MUST read as directives.

Positive invariant values MUST use the `DO_` prefix.

Negative invariant values MUST use the `DO_NOT_` prefix.

The system MUST NOT describe the `public.memory` table as graph-based unless graph storage or graph traversal behavior is added.

The system MUST NOT describe the `public.memory` table as append-only.

The system MUST expose an RPC function named `new_memory` for inserting a memory row.

The `new_memory` function MUST accept `entity`, `to_entity`, `relation`, `work`, and `notes` input values.

The `new_memory` function MUST insert the memory row before semantic embedding is required.

The system MAY generate embeddings after `new_memory` inserts the memory row.

The `new_memory` function MUST return the inserted row's `id`, `epoch`, `entity`, `to_entity`, `relation`, `work`, `notes`, and `active` values.

The `public.memory` `CREATE TABLE` statement MUST declare `notes_fts` as generated from `notes`.

The `new_memory` function MUST NOT accept `notes_fts` as an input value.

The `new_memory` function MUST rely on Postgres to populate `notes_fts`.

Semantic search MUST only use rows where `embedding` is not null.

## New Memory Flow

```mermaid
sequenceDiagram
    participant Caller
    participant NewMemory as new_memory
    participant Postgres
    participant Worker as Embedding Worker
    participant Model as Embedding Model

    Caller->>NewMemory: entity, to_entity, relation, work, notes
    NewMemory->>Postgres: insert memory row
    Postgres-->>Postgres: generate id, epoch, notes_fts
    Postgres-->>Worker: queue embedding work
    Worker->>Postgres: load inserted memory row
    Worker-->>Worker: render canonical memory sentence
    Worker->>Model: embed canonical memory sentence
    Model-->>Worker: embedding vector
    Worker->>Postgres: store embedding vector
```

The caller submits `entity`, `to_entity`, `relation`, `work`, and `notes`.

The `new_memory` function inserts the memory row immediately.

Postgres generates `id`, `epoch`, and `notes_fts` during insert.

After the memory row is inserted, the system queues semantic embedding asynchronously.

The embedding worker renders the canonical memory sentence from the inserted row.

The embedding worker sends the canonical memory sentence to an embedding model.

The embedding worker stores the returned vector in the memory row's `embedding` column.

The memory row is available for direct lookup and full-text search before embedding is complete.

The memory row is available for semantic search after embedding is complete.

## Alternatives

### Require Embedding Before Insert

The system could require every caller to generate an embedding before calling `new_memory`.

This means the caller must build the memory payload, build the sentence to embed, call an embedding model, wait for the returned vector, and then call `new_memory` with the same memory payload plus the embedding.

This keeps `embedding` non-null, but it makes the core memory insert depend on an external model call.

This alternative is not preferred because recording memory should not be blocked by semantic enrichment.

### Insert First, Embed Later

The system can insert the memory row first and generate the embedding later.

This means `new_memory` records the memory immediately, Postgres generates `notes_fts` immediately, and an embedding worker fills `embedding` after the row exists.

This alternative is preferred because `embedding` is asynchronous enrichment, not core memory data.

### Default Placeholder Embedding

The system could make `embedding` not null by storing a default placeholder vector.

This alternative is not preferred because a placeholder vector makes invalid semantic data look valid.

This alternative is not preferred because semantic search would need to detect and ignore placeholder embeddings.

## Acceptance Criteria

Given the `public.memory` table definition,
When the column list is reviewed,
Then `id` is the primary key
And `epoch` is present as Unix epoch time
And `notes_fts` is present as a generated column.

Given the enum SQL files,
When enum values are reviewed,
Then no enum value requires prior knowledge of AgentMemory, EdgeGrammar, ThotBot, or Optimus Sharp.

Given the `relation_enum` SQL file,
When each value is read in the shape `entity relation to_entity`,
Then each value reads as an action performed by the recording entity.

Given the `work_enum` SQL file,
When each value is reviewed,
Then each value names a reusable work domain.

Given project documentation for the core table,
When the table is described,
Then the description does not use graph, append-only, governance, compliance, or ledger language.

Given a caller has `entity`, `to_entity`, `relation`, `work`, and `notes`,
When `new_memory` is called,
Then the memory row is inserted.

Given a caller has not generated an embedding,
When `new_memory` is called,
Then the insert succeeds
And the insert does not create a placeholder embedding.

Given `new_memory` inserts a memory row,
When the function returns,
Then the result includes `id` and `epoch`.

Given a caller has `notes`,
When `new_memory` is called,
Then the caller does not provide `notes_fts`
And Postgres generates `notes_fts` from `notes`.
