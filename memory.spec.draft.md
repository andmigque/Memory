# Memory Requirements Draft

Working draft of the specification rewrite. `memory.spec.md` remains the source of truth
until this draft is complete and replaces it.

The rewrite states each invariant at exactly one address. Sections cite addresses rather than
restating requirements, so a rule changes in one place.

Sections are settled one at a time. A section is settled only after review.

## Status

| Section | Title | State |
| --- | --- | --- |
| 1 | Normative Language | Pending review |
| 2 | Scope | Pending review |
| 3 | Documentation | Settled |
| 4 | Record | Settled |
| 5 | Vocabulary | Settled |
| 6 | Access | Pending |
| 7 | Enrichment | Pending |
| 8 | Capabilities | Pending |
| 9 | Boundaries | Pending |
| 10 | Grounding | Pending |
| 11 | Failure Capture | Pending |
| 12 | Portability | Pending |
| 13 | Deployment | Pending |
| 14 | Acceptance | Pending |

Generated State was folded into Record. Its time invariants are 4.4 through 4.8 and its
remaining content restated what the schema already enforces.

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
| 3.1 | MUST | Product described as a datastore that enables Continuous Agentic Improvement |
| 3.2 | SHOULD | At least 2 agents supported: Claude and Codex |
| 3.3 | SHOULD | Record relationships described as the semantic graph |
| 3.4 | MUST NOT | Record store described as graph storage |
| 3.5 | MUST NOT | Record store described as append-only storage |
| 3.6 | MUST NOT | Memory described as built-in agent memory |
| 3.7 | MUST NOT | Memory described as chat recollection |
| 3.8 | MUST NOT | Memory described as a remembered summary |
| 3.9 | MUST | Unimplemented behavior marked as planned |
| 3.10 | SHOULD | Statistics reproducible from a stored query artifact |
| 3.11 | SHOULD | Behavior changes documented in the same change |
| 3.12 | MUST | Every markdown element addressable by unique semver style address |
| 3.13 | MAY | Exact heading and blockquote conventions of the Markdown Writing Rules |
| 3.14 | MUST | Code documented using [Sharpdown](https://github.com/andmigque/Sharpdown) |

# 4. Record

| # | Rule | Invariant |
| --- | --- | --- |
| 4.1 | MUST | Notes contain a comprehensive account of the unique event that occurred |
| 4.2 | MUST | Block ability to delete records |
| 4.3 | MUST | Build interfaces that use the active column as a soft delete in lieu of hard deletes |
| 4.4 | MUST | Time created is immutable |
| 4.5 | MUST | Update the time updated column on every distinct row mutation |
| 4.6 | MUST | Auto populate time created in the datastore on first insert |
| 4.7 | MUST | Auto populate time updated in the datastore |
| 4.8 | MUST NOT | Time updated supplied by the caller |

# 5. Vocabulary

| # | Rule | Invariant |
| --- | --- | --- |
| 5.1 | MUST | Vocabulary words are sql Enums under `type/` |
| 5.2 | MAY | New work Enums added by Architect |
| 5.3 | MUST | Build a mechanism to detect drift |
| 5.4 | MUST | Build a mechanism to reconcile drift from production into the repository |
