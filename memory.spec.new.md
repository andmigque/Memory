# Memory Specification

# 1. Specification

Memory is expected to evolve across schemas, clients, and deployment mechanisms. This document defines the durable contract at a level that survives those changes while preserving exact references for review and change control.

| # | Rule | Invariant | Status |
| --- | --- | --- | --- |
| 1.1 | MUST | Use normative keywords according to RFC 2119 and RFC 8174 | Approve |
| 1.2 | MUST | Limit this specification to Memory invariants | Approve |
| 1.3 | MUST | Set one address on each invariant | Approve |
| 1.4 | MUST | Use addresses in place of restating invariants | Approve |
| 1.5 | MUST | Open each invariant with an approved PowerShell verb | Approve |
| 1.6 | SHOULD | Set a unique semver style address on every markdown element | Approve |
| 1.7 | MUST | Use the names Supabase and Postgres | Approve |

# 2. Status

The status model defines the lifecycle vocabulary used by every invariant.

## 2.1 Deployment Status Vocabulary

This table defines the lifecycle states available to an invariant.

| Status | Meaning |
| --- | --- |
| Approve | Reviewed, agreed, and approved for deployment |
| Publish | Deployed to production |
| Register | Planned for a future deployment |
| Remove | Remove from all deployments |

# 3. Documentation

Documentation is the public interpretation layer for Memory. Because the product can be misclassified by looking only at its storage technology or agent integrations, its documentation must preserve the distinction between storage, semantic meaning, and agent behavior. Claims about the product should remain traceable to evidence so the description can evolve without becoming folklore.

| # | Rule | Invariant | Status |
| --- | --- | --- | --- |
| 3.1 | MUST | Publish the product as a datastore that enables Continuous Agentic Improvement | Publish |
| 3.2 | SHOULD | Publish support for at least 2 agents: Claude and Codex | Publish |
| 3.3 | SHOULD | Publish record relationships as the semantic graph | Publish |
| 3.4 | MUST | Unpublish the record store as graph storage | Remove |
| 3.5 | MUST | Unpublish the record store as append only storage | Remove |
| 3.6 | MUST | Unpublish Memory as built in agent memory | Remove |
| 3.7 | MUST | Unpublish Memory as chat recollection | Remove |
| 3.8 | MUST | Unpublish Memory as a remembered summary | Remove |
| 3.9 | SHOULD | Save the query artifact that produces each documented statistic | Register |
| 3.10 | SHOULD | Update documentation with behavior changes in the same change | Publish |
| 3.11 | MAY | Use the exact heading and blockquote conventions of the Markdown Writing Rules | Publish |
| 3.12 | MUST | Use [Sharpdown](https://github.com/andmigque/Sharpdown) to document code | Publish |
| 3.13 | MUST | Use the term full text search, not keyword search | Publish |

# 4. Record

The record is Memory's unit of continuity. Its value comes from preserving enough context for a future agent to understand not only what happened, but why it mattered, across model changes, application boundaries, and interrupted work.

| # | Rule | Invariant | Status |
| --- | --- | --- | --- |
| 4.1 | MUST | Write a comprehensive account of the unique event that occurred in notes | Publish |
| 4.2 | MUST | Block the ability to delete records | Publish |
| 4.3 | MUST | Use the active column as a soft delete in lieu of hard deletes | Register |
| 4.4 | MUST | Protect time created with immutability | Register |
| 4.5 | MUST | Update the time updated column on every distinct row mutation | Register |
| 4.6 | MUST | Set the time created column automatically in the datastore on first insert | Register |
| 4.7 | MUST | Set the time updated column automatically in the datastore | Register |
| 4.8 | MUST NOT | Receive a time updated value from the caller | Register |
| 4.9 | SHOULD | ConvertTo the full text search value from notes in the datastore on the record | Publish |
| 4.10 | SHOULD | ConvertTo embeddings asynchronously in the datastore on the record | Publish |
| 4.11 | MUST NOT | Write placeholder embeddings | Publish |
| 4.12 | MUST | Register vocabulary words as sql Enums under `type/` | Publish |
| 4.13 | MAY | Publish new work Enums as approved by Architect | Publish |
| 4.14 | MUST | Compare production against the repository | Register |
| 4.15 | MUST | Sync the repository from production | Register |
| 4.16 | MUST | New one record per call | Publish |
| 4.17 | MUST | Get records newest first | Publish |
| 4.18 | MUST | Find records by meaning | Publish |
| 4.19 | MUST | Merge full text and semantic ranking into one result | Publish |
| 4.20 | MUST | Limit the number of records returned | Publish |

# 5. Authentication

Authentication gives Memory a stable caller identity across different agents and clients. It establishes who is making a request without deciding what that caller is permitted to do.

| # | Rule | Invariant | Status |
| --- | --- | --- | --- |
| 5.1 | MUST | Confirm caller authentication as a Supabase Auth user | Publish |
| 5.2 | MUST | Deny requests carrying no valid session | Publish |

# 6. Authorization

Authorization protects the shared history from unauthorized or accidental change while allowing agents to participate in it. Enforcement belongs at the datastore boundary so every access path inherits the same controls.

| # | Rule | Invariant | Status |
| --- | --- | --- | --- |
| 6.1 | MUST | Grant create, read, and update operations | Register |
| 6.2 | SHOULD | Limit reads to active records | Publish |
| 6.3 | MUST | Enable row level security | Publish |
