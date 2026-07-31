# Memory Requirements Draft

Working draft of the specification rewrite. `memory.spec.md` remains the source of truth
until this draft is complete and replaces it.

The rewrite states each invariant at exactly one address. Sections cite addresses rather than
restating requirements, so a rule changes in one place.

Every invariant reads as a sentence and opens with an approved PowerShell verb.

Memory is committed to Supabase and Postgres. Naming either is not an implementation leak.
Naming a credential, a flag, a file path, or a function is.

Sections are settled one at a time. A section is settled only after review.

## Status vocabulary

Status uses verbs already in use. No new words are coined for it.

| Status | Meaning |
| --- | --- |
| Publish | Requirement is in force and the behavior exists |
| Register | Requirement is entered but the behavior does not exist yet |
| Unpublish | Requirement was withdrawn |

## Section status

| Section | Title | State |
| --- | --- | --- |
| 1 | Normative Language | Settled |
| 2 | Scope | Settled |
| 3 | Documentation | Settled |
| 4 | Record | Settled |
| 5 | Authentication | Settled |
| 6 | Authorization | Settled |

Boundaries dissolved. Every invariant it would have carried is authentication, authorization,
or an edge function binding.

Portability, Deployment and Acceptance are excluded. A specification states what must be
true. Deployment states how to make it true, which is a procedure and belongs to the build
file and the SQL. Acceptance would restate the document, because every invariant here is
atomic and passes or fails on its own, so the invariants are already the conformance
criteria.

Generated State, Semantic Enrichment, Vocabulary and Capabilities were all folded into
Record. Generated
state is the record time columns. Enrichment produces a value derived from notes and stored
on the record. The vocabulary is the record. The capabilities are record operations.

Record will later be subdivided so its groups carry their own addresses, with 4.1 covering
notes, 4.2 removal and status, 4.3 time, 4.4 derived values, 4.5 vocabulary, 4.6 drift and
4.7 operations. The flat numbering holds until those groups are settled.

Grounding and Failure Capture are not sections of this specification. They describe what an
agent must do with Memory rather than what Memory is and guarantees, so they belong in
AGENTS.md. The product-side remainder, covering the artifacts Memory ships and the
guarantees they carry, is still to be placed.

## Temporal framing

Use MUST NOT for an act that has never occurred. Use MUST with a removal verb for a state
that already exists. Forbidding what is already published is temporally incorrect, because
the obligation is to remove it rather than to refrain from writing it.

# 1. Normative Language

| # | Rule | Status | Invariant |
| --- | --- | --- | --- |
| 1.1 | MUST | Publish | Use normative keywords according to RFC 2119 and RFC 8174 |

# 2. Scope

| # | Rule | Status | Invariant |
| --- | --- | --- | --- |
| 2.1 | MUST | Publish | Limit this document to the requirements for Memory |
| 2.2 | MUST | Publish | Confirm conformance when every MUST is satisfied |

# 3. Documentation

| # | Rule | Status | Invariant |
| --- | --- | --- | --- |
| 3.1 | MUST | Publish | Publish the product as a datastore that enables Continuous Agentic Improvement |
| 3.2 | SHOULD | Publish | Publish support for at least 2 agents: Claude and Codex |
| 3.3 | SHOULD | Publish | Publish record relationships as the semantic graph |
| 3.4 | MUST | Publish | Unpublish the record store as graph storage |
| 3.5 | MUST | Publish | Unpublish the record store as append only storage |
| 3.6 | MUST | Publish | Unpublish Memory as built in agent memory |
| 3.7 | MUST | Publish | Unpublish Memory as chat recollection |
| 3.8 | MUST | Publish | Unpublish Memory as a remembered summary |
| 3.9 | SHOULD | Register | Save the query artifact that produces each documented statistic |
| 3.10 | SHOULD | Publish | Update documentation with behavior changes in the same change |
| 3.11 | MUST | Publish | Set a unique semver style address on every markdown element |
| 3.12 | MAY | Publish | Use the exact heading and blockquote conventions of the Markdown Writing Rules |
| 3.13 | MUST | Publish | Use [Sharpdown](https://github.com/andmigque/Sharpdown) to document code |
| 3.14 | MUST | Publish | Use the term full text search, not keyword search |

# 4. Record

| # | Rule | Status | Invariant |
| --- | --- | --- | --- |
| 4.1 | MUST | Publish | Write a comprehensive account of the unique event that occurred in notes |
| 4.2 | MUST | Publish | Block the ability to delete records |
| 4.3 | MUST | Register | Build interfaces that use the active column as a soft delete in lieu of hard deletes |
| 4.4 | MUST | Register | Lock time created after first insert |
| 4.5 | MUST | Register | Update the time updated column on every distinct row mutation |
| 4.6 | MUST | Register | Set the time created column automatically in the datastore on first insert |
| 4.7 | MUST | Register | Set the time updated column automatically in the datastore |
| 4.8 | MUST NOT | Register | Receive a time updated value from the caller |
| 4.9 | SHOULD | Publish | Build the full text search value from notes in the datastore on the record |
| 4.10 | SHOULD | Publish | Build embeddings asynchronously in the datastore on the record |
| 4.11 | MUST NOT | Publish | Write placeholder embeddings |
| 4.12 | MUST | Publish | Register vocabulary words as sql Enums under `type/` |
| 4.13 | MAY | Publish | Publish new work Enums as approved by Architect |
| 4.14 | MUST | Register | Build a mechanism to detect drift |
| 4.15 | MUST | Register | Build a mechanism to reconcile drift from production into the repository |
| 4.16 | MUST | Publish | New one record per call |
| 4.17 | MUST | Publish | Get records newest first |
| 4.18 | MUST | Publish | Find records by meaning |
| 4.19 | MUST | Publish | Merge full text and semantic ranking into one result |
| 4.20 | MUST | Publish | Limit the number of records returned |

# 5. Authentication

| # | Rule | Status | Invariant |
| --- | --- | --- | --- |
| 5.1 | MUST | Publish | Confirm caller authentication as a Supabase Auth user |
| 5.2 | MUST | Publish | Deny requests carrying no valid session |

# 6. Authorization

| # | Rule | Status | Invariant |
| --- | --- | --- | --- |
| 6.1 | MUST | Register | Grant create, read, and update operations |
| 6.2 | SHOULD | Publish | Limit reads to active records |
| 6.3 | MUST | Publish | Enable row level security |
