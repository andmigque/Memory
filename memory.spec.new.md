# Memory Specification

# 1. Specification

| # | Rule | Status | Invariant |
| --- | --- | --- | --- |
| 1.1 | MUST | Publish | Use normative keywords according to RFC 2119 and RFC 8174 |
| 1.2 | MUST | Publish | Limit this specification to Memory invariants |
| 1.3 | MUST | Publish | State each invariant at one address |
| 1.4 | MUST | Publish | Cite addresses in place of restating invariants |
| 1.5 | MUST | Publish | Open each invariant with an approved PowerShell verb |
| 1.6 | MUST | Publish | Set a unique semver style address on every markdown element |
| 1.7 | MUST | Publish | Name Supabase and Postgres |
| 1.8 | MUST NOT | Publish | Name a credential, flag, file path, or function |
| 1.9 | MUST | Publish | Confirm conformance when every MUST is satisfied |

# 2. Status

The following are approved status verbs.

| Status | Meaning |
| --- | --- |
| Approve | Reviewed and agreed |
| Publish | In force and the behavior exists |
| Register | Entered but the behavior does not exist yet |
| Unpublish | Withdrawn |

| # | Rule | Status | Invariant |
| --- | --- | --- | --- |
| 2.1 | MUST | Publish | Approve a section after review |
| 2.2 | MUST | Publish | Set Publish, Register or Unpublish on each invariant |
| 2.3 | MAY | Publish | Approve a section holding registered invariants |

| Section | Title | Status |
| --- | --- | --- |
| 1 | Specification | Approve |
| 2 | Status | Approve |
| 3 | Documentation | Approve |
| 4 | Record | Approve |
| 5 | Authentication | Approve |
| 6 | Authorization | Approve |

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
| 3.11 | MAY | Publish | Use the exact heading and blockquote conventions of the Markdown Writing Rules |
| 3.12 | MUST | Publish | Use [Sharpdown](https://github.com/andmigque/Sharpdown) to document code |
| 3.13 | MUST | Publish | Use the term full text search, not keyword search |

# 4. Record

| # | Rule | Status | Invariant |
| --- | --- | --- | --- |
| 4.1 | MUST | Publish | Write a comprehensive account of the unique event that occurred in notes |
| 4.2 | MUST | Publish | Block the ability to delete records |
| 4.3 | MUST | Register | Use the active column as a soft delete in lieu of hard deletes |
| 4.4 | MUST | Register | Protect time created with immutability |
| 4.5 | MUST | Register | Update the time updated column on every distinct row mutation |
| 4.6 | MUST | Register | Set the time created column automatically in the datastore on first insert |
| 4.7 | MUST | Register | Set the time updated column automatically in the datastore |
| 4.8 | MUST NOT | Register | Receive a time updated value from the caller |
| 4.9 | SHOULD | Publish | ConvertTo the full text search value from notes in the datastore on the record |
| 4.10 | SHOULD | Publish | ConvertTo embeddings asynchronously in the datastore on the record |
| 4.11 | MUST NOT | Publish | Write placeholder embeddings |
| 4.12 | MUST | Publish | Register vocabulary words as sql Enums under `type/` |
| 4.13 | MAY | Publish | Publish new work Enums as approved by Architect |
| 4.14 | MUST | Register | Compare production against the repository |
| 4.15 | MUST | Register | Sync the repository from production |
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
