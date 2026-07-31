# Memory Requirements Draft

Working draft of the specification rewrite. `memory.spec.md` remains the source of truth
until this draft is complete and replaces it.

The rewrite states each invariant at exactly one address. Sections cite addresses rather than
restating requirements, so a rule changes in one place.

Every invariant reads as a sentence and opens with an approved PowerShell verb.

Memory is committed to Supabase and Postgres. Naming either is not an implementation leak.
Naming a credential, a flag, a file path, or a function is.

Sections are settled one at a time. A section is settled only after review.

## Status

| Section | Title | State |
| --- | --- | --- |
| 1 | Normative Language | Pending review |
| 2 | Scope | Pending review |
| 3 | Documentation | Settled |
| 4 | Record | Settled |
| 5 | Authentication | Settled |
| 6 | Authorization | Settled |
| 7 | Capabilities | Pending |
| 8 | Boundaries | Pending |
| 9 | Portability | Pending |
| 10 | Deployment | Pending |
| 11 | Acceptance | Pending |

Generated State, Semantic Enrichment and Vocabulary were all folded into Record. Generated
state is the record time columns. Enrichment produces a value derived from notes and stored
on the record. The vocabulary is the record.

Grounding and Failure Capture are not sections of this specification. They describe what an
agent must do with Memory rather than what Memory is and guarantees, so they belong in
AGENTS.md. The product-side remainder, covering the artifacts Memory ships and the
guarantees they carry, is still to be placed.

## Temporal framing

Use MUST NOT for an act that has never occurred. Use MUST with a removal verb for a state
that already exists. Forbidding what is already published is temporally incorrect, because
the obligation is to remove it rather than to refrain from writing it.

# 1. Normative Language

Pending review. Carried unchanged from `memory.spec.md` section 1.

| # | Rule | Invariant |
| --- | --- | --- |
| 1.1 | MUST | Normative keywords interpreted according to RFC 2119 and RFC 8174 |

# 2. Scope

Pending review. Carried unchanged from `memory.spec.md` section 2.

| # | Rule | Invariant |
| --- | --- | --- |
| 2.1 | MUST | Requirements for Memory defined by this document |

# 3. Documentation

| # | Rule | Invariant |
| --- | --- | --- |
| 3.1 | MUST | Publish the product as a datastore that enables Continuous Agentic Improvement |
| 3.2 | SHOULD | Publish support for at least 2 agents: Claude and Codex |
| 3.3 | SHOULD | Publish record relationships as the semantic graph |
| 3.4 | MUST | Unpublish the record store as graph storage |
| 3.5 | MUST | Unpublish the record store as append only storage |
| 3.6 | MUST | Unpublish Memory as built in agent memory |
| 3.7 | MUST | Unpublish Memory as chat recollection |
| 3.8 | MUST | Unpublish Memory as a remembered summary |
| 3.9 | MUST | Publish unimplemented behavior as planned |
| 3.10 | SHOULD | Save the query artifact that produces each documented statistic |
| 3.11 | SHOULD | Update documentation with behavior changes in the same change |
| 3.12 | MUST | Set a unique semver style address on every markdown element |
| 3.13 | MAY | Use the exact heading and blockquote conventions of the Markdown Writing Rules |
| 3.14 | MUST | Use [Sharpdown](https://github.com/andmigque/Sharpdown) to document code |
| 3.15 | MUST | Use the term full text search, not keyword search |

# 4. Record

| # | Rule | Invariant |
| --- | --- | --- |
| 4.1 | MUST | Write a comprehensive account of the unique event that occurred in notes |
| 4.2 | MUST | Block the ability to delete records |
| 4.3 | MUST | Build interfaces that use the active column as a soft delete in lieu of hard deletes |
| 4.4 | MUST | Lock time created after first insert |
| 4.5 | MUST | Update the time updated column on every distinct row mutation |
| 4.6 | MUST | Set the time created column automatically in the datastore on first insert |
| 4.7 | MUST | Set the time updated column automatically in the datastore |
| 4.8 | MUST NOT | Receive a time updated value from the caller |
| 4.9 | SHOULD | Build the full text search value from notes in the datastore on the record |
| 4.10 | SHOULD | Build embeddings asynchronously in the datastore on the record |
| 4.11 | MUST NOT | Write placeholder embeddings |
| 4.12 | MUST | Register vocabulary words as sql Enums under `type/` |
| 4.13 | MAY | Publish new work Enums as approved by Architect |
| 4.14 | MUST | Build a mechanism to detect drift |
| 4.15 | MUST | Build a mechanism to reconcile drift from production into the repository |

# 5. Authentication

| # | Rule | Invariant |
| --- | --- | --- |
| 5.1 | MUST | Confirm caller authentication as a Supabase Auth user |
| 5.2 | MUST | Deny requests carrying no valid session |

# 6. Authorization

| # | Rule | Invariant |
| --- | --- | --- |
| 6.1 | MUST | Grant create, read, and update operations |
| 6.2 | SHOULD | Limit reads to active records |
| 6.3 | MUST | Enable row level security |
