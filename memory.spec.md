# Memory Requirements

# 1. Normative Language

> ## a. Uppercase normative keywords are interpreted according to RFC 2119 and RFC 8174.

# 2. Scope

> ## a. This document defines the requirements for Memory.

# 3. Data Model

> ## a. Memory MUST store one recorded memory per row in a table named `memory`.

> ## b. The `memory` table MUST conform to the following column contract.

| Name | Type | Null | Default or generation | Meaning |
| --- | --- | --- | --- | --- |
| `id` | `bigint` | No | Generated identity | Primary key |
| `entity` | `entity_enum` | No | None | Actor recording the memory |
| `to_entity` | `entity_enum` | No | None | Target of the relation |
| `relation` | `relation_enum` | No | None | Action connecting `entity` to `to_entity` |
| `work` | `work_enum` | No | None | Work domain |
| `notes` | `text` | No | None | Recorded content |
| `notes_fts` | `tsvector` | No | Generated from `notes` | Full-text search value |
| `active` | `boolean` | No | `true` | Read visibility |
| `epoch` | `bigint` | No | Current Unix epoch | Recorded time |
| `embedding` | `vector(384)` | Yes | `null` | Semantic embedding |

# 4. Vocabulary

> ## a. Memory MUST use the following enum contracts.

| Type | Concern | Contract |
| --- | --- | --- |
| `entity_enum` | Purpose | Identifies an actor or system |
| `entity_enum` | Wire format | Values are case-sensitive |
| `relation_enum` | Purpose | Identifies the recorded action |
| `relation_enum` | Sentence shape | Values MUST support `entity relation to_entity` |
| `relation_enum` | Grammar | Values SHOULD be verbs |
| `work_enum` | Purpose | Identifies the work domain |
| `work_enum` | Domain | Values MUST describe reusable work domains |
| `invariant_enum` | Purpose | Represents a non-negotiable operating rule |
| `invariant_enum` | Form | Values MUST read as directives |
| `invariant_enum` | Positive form | Values MUST use the `DO_` prefix |
| `invariant_enum` | Negative form | Values MUST use the `DO_NOT_` prefix |

> ## b. Enum values MUST remain understandable without project-specific lore.

> ## c. Memory documentation MUST NOT describe the `memory` table as graph storage.

> ## d. Memory documentation MUST NOT describe the `memory` table as append-only storage.

# 5. New Memory RPC

> ## a. Memory MUST expose an RPC named `new_memory` that inserts one memory row.

> ## b. `new_memory` MUST accept the following input contract.

| Name | Type | Required | Meaning |
| --- | --- | --- | --- |
| `p_entity` | `entity_enum` | Yes | Recording actor |
| `p_to_entity` | `entity_enum` | Yes | Relation target |
| `p_relation` | `relation_enum` | Yes | Recorded action |
| `p_work` | `work_enum` | Yes | Work domain |
| `p_notes` | `text` | Yes | Recorded content |

> ## c. `new_memory` MUST return the following row contract.

| Name | Type |
| --- | --- |
| `id` | `bigint` |
| `epoch` | `bigint` |
| `entity` | `entity_enum` |
| `to_entity` | `entity_enum` |
| `relation` | `relation_enum` |
| `work` | `work_enum` |
| `notes` | `text` |
| `active` | `boolean` |

> ## d. `new_memory` MUST complete the insert before semantic embedding is available.

> ## e. `new_memory` MUST NOT accept `notes_fts`.

> ## f. Postgres MUST generate `notes_fts` from `notes`.

> ## g. `new_memory` MUST NOT require an embedding.

> ## h. The insert MUST NOT create a placeholder embedding.

# 6. Get Memory RPC

> ## a. Memory MUST expose an RPC named `get_memory` that returns recorded memory rows.

> ## b. `get_memory` MUST accept the following input contract.

| Name | Type | Required | Default | Meaning |
| --- | --- | --- | --- | --- |
| `p_entity` | `entity_enum` | No | `null` | Recording actor filter |
| `p_limit` | `integer` | No | `10` | Maximum returned rows |

> ## c. `get_memory` MUST return the row contract defined at 5.c.

> ## d. `get_memory` MUST apply the following behavior.

| Concern | Requirement |
| --- | --- |
| Entity filter | A null `p_entity` returns rows for every entity |
| Visibility | Only rows where `active` is `true` are returned |
| Order | Rows are ordered by `epoch` descending and then `id` descending |
| Limit | No more than `p_limit` rows are returned |
| Execution | The function runs as the calling role so Row Level Security controls the result |

# 7. Search RPCs

> ## a. Memory MUST expose an RPC named `search_memory` for hybrid full-text and semantic search using reciprocal-rank fusion.

> ## b. `search_memory` MUST accept the following input contract.

| Name | Type | Required | Default |
| --- | --- | --- | --- |
| `p_query` | `text` | Yes | None |
| `p_query_embedding` | `vector` | Yes | None |
| `p_match_count` | `integer` | No | `20` |
| `p_rrf_k` | `integer` | No | `50` |

> ## c. Memory MUST expose an RPC named `search_memory_embedding` for semantic cosine search.

> ## d. `search_memory_embedding` MUST accept the following input contract.

| Name | Type | Required | Default |
| --- | --- | --- | --- |
| `p_query_embedding` | `vector` | Yes | None |
| `p_match_threshold` | `real` | No | `0.5` |
| `p_match_count` | `integer` | No | `20` |

> ## e. Search RPCs MUST return the following result contract.

| Name | Type |
| --- | --- |
| `source` | `text` |
| `id` | `bigint` |
| `epoch` | `bigint` |
| `entity` | `entity_enum` |
| `work` | `work_enum` |
| `notes` | `text` |
| `score` | `real` |

> ## f. Search RPCs MUST return only rows where `active` is `true`.

> ## g. Semantic search MUST exclude rows where `embedding` is null.

# 8. Edge Functions

> ## a. Memory MUST expose the following Edge Function contracts.

| Name | Audience | Execution | Operation |
| --- | --- | --- | --- |
| `search-memory` | User-facing | Calling user | Embed a query and call a search RPC |
| `get-memory` | User-facing | Calling user | Call `get_memory` |
| `update-memory` | Internal | `service_role` | Write embeddings |

> ## b. A caller of a user-facing Edge Function MUST present the publishable key on the `apikey` header.

> ## c. A caller of a user-facing Edge Function MUST present its user JWT on the `Authorization` header.

> ## d. A user-facing Edge Function MUST forward the caller's JWT to PostgREST.

> ## e. `search-memory` MUST support hybrid search through `search_memory`.

> ## f. `search-memory` MUST support semantic-only search through `search_memory_embedding`.

> ## g. `get-memory` MUST accept the optional inputs defined at 6.b.

> ## h. `get-memory` MUST forward its inputs to `get_memory`.

> ## i. `update-memory` MUST authorize the project secret key from the `apikey` header.

> ## j. `update-memory` MUST support the following action contract.

| Action | Input | Type | Required | Behavior |
| --- | --- | --- | --- | --- |
| `set_memory_embedding` | `id` | `bigint` | Yes | Identifies the memory row |
| `set_memory_embedding` | `sentence` | `text` | Yes | Supplies the text to embed |
| `update_memory_embedding_queue` | None | None | No | Drains `get_memory_embedding_queue` |

> ## k. `update-memory` MUST respond with status 401 when the project secret key is absent or invalid.

> ## l. `update-memory` MUST perform no action when authorization fails.

> ## m. User-facing clients MUST NOT require the project secret key.

# 9. Embedding Pipeline

> ## a. Memory MUST use the following embedding pipeline.

| Step | Component | Requirement |
| --- | --- | --- |
| 1 | `new_memory` | Insert the row without waiting for an embedding |
| 2 | Postgres | Generate `id` during the insert |
| 3 | Postgres | Generate `epoch` during the insert |
| 4 | Postgres | Generate `notes_fts` during the insert |
| 5 | `start_memory_embedding` | Run after the insert |
| 6 | `convertto_memory_sentence` | Render the canonical sentence |
| 7 | `start_memory_embedding` | Call `update-memory` with the row `id` |
| 8 | `start_memory_embedding` | Send the rendered sentence |
| 9 | `start_memory_embedding` | Present the project secret key on `apikey` |
| 10 | `update-memory` | Generate the embedding |
| 11 | `set_memory_embedding` | Store the embedding on the row |

> ## b. A newly inserted row MUST be available to direct retrieval before embedding completes.

> ## c. A newly inserted row MUST be available to full-text search before embedding completes.

> ## d. A newly inserted row MUST become available to semantic search after embedding completes.

> ## e. `update_memory_embedding_queue` MUST backfill rows whose embedding is null.

# 10. Access Control

> ## a. Every calling agent MUST authenticate as a Supabase Auth user.

> ## b. Memory MUST enforce the following access contract.

| Caller | Operation | Control | Result |
| --- | --- | --- | --- |
| Authenticated | Read active rows | Row Level Security | Allow |
| Authenticated | Insert rows | Row Level Security | Allow |
| Authenticated | Execute `new_memory` | Function grant | Allow |
| Authenticated | Execute `get_memory` | Function grant | Allow |
| Authenticated | Execute `search_memory` | Function grant | Allow |
| Authenticated | Execute `search_memory_embedding` | Function grant | Allow |
| Authenticated | Execute `set_memory_embedding` | Function grant | Deny |
| Unauthenticated | Read rows | Row Level Security | Deny |
| Unauthenticated | Insert rows | Row Level Security | Deny |
| Unauthenticated | Execute `set_memory_embedding` | Function grant | Deny |

# 11. Embedding Decision

> ## a. Semantic embedding MUST remain asynchronous enrichment rather than required insert data.

> ## b. The embedding alternatives are resolved as follows.

| Alternative | Decision | Reason |
| --- | --- | --- |
| Require embedding before insert | Rejected | Recording memory would depend on an external model call |
| Insert first and embed later | Selected | Recording memory remains available when semantic enrichment is delayed |
| Store a placeholder embedding | Rejected | Invalid semantic data would appear valid |

# 12. Deployment

> ## a. A valid deployment MUST satisfy the following ordered contract.

| Order | Artifact | Requirement |
| --- | --- | --- |
| 1 | `vector` | Enable the extension |
| 2 | `pg_net` | Enable the extension |
| 3 | `supabase_vault` | Enable the extension |
| 4 | Enum types | Add missing shared values without recreating existing types |
| 5 | `memory` | Apply the table definition |
| 6 | Memory functions | Apply the function definitions |
| 7 | Memory grants | Apply the grant definitions |
| 8 | `start_memory_embedding` | Apply the trigger definition |
| 9 | `search-memory` | Deploy with `verify_jwt` disabled because the function performs its own authorization |
| 10 | `get-memory` | Deploy with `verify_jwt` disabled because the function performs its own authorization |
| 11 | `update-memory` | Deploy with `verify_jwt` disabled because the function performs its own authorization |
| 12 | Project URL | Store the value required by `start_memory_embedding` in Vault |
| 13 | Project secret key | Store the value required by `start_memory_embedding` in Vault |
| 14 | Restored rows with null embeddings | Backfill through `update_memory_embedding_queue` |

# 13. Acceptance

> ## a. The specification MUST be verified against the following acceptance matrix.

| Contract | Verification | Expected result |
| --- | --- | --- |
| Data model | Inspect the `memory` table | The table matches 3.a and 3.b |
| Vocabulary | Inspect enum definitions | The types match 4.a and values satisfy 4.b |
| Documentation | Inspect descriptions of `memory` | The descriptions satisfy 4.c and 4.d |
| New memory | Call `new_memory` without an embedding | The row is inserted and the result matches 5.c |
| Generated search value | Call `new_memory` with `notes` | Postgres generates `notes_fts` |
| Placeholder prevention | Inspect the inserted row before enrichment | `embedding` is null |
| Direct retrieval | Call `get_memory` without arguments | The result matches 6.c and 6.d |
| Entity retrieval | Call `get_memory` with `p_entity` | Only active rows for that entity are returned |
| Hybrid search | Call `search-memory` in hybrid mode | The function runs as the caller and returns only RLS-visible rows |
| Semantic search | Search while a row has a null embedding | The row is excluded from semantic results |
| Authorized embedding | Call `set_memory_embedding` through `update-memory` with the project secret key | The embedding is stored |
| Unauthorized embedding | Call `update-memory` without the project secret key | The result satisfies 8.k and 8.l |
| Unauthenticated read | Attempt to read `memory` without authentication | Row Level Security denies the operation |
| Unauthenticated write | Attempt to insert into `memory` without authentication | Row Level Security denies the operation |
| Deployment | Inspect the deployed environment | The environment satisfies section 12 |
