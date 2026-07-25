# 🤖🧠 Memory

Memory is a datastore that enables continuous agentic improvement.

> It exposes both semantic and keyword search and excels at grounding agents in brownfield environments.

Memory has been tested on the following platforms:

- Claude
  - Web
  - Code
  - iOS
  - Desktop
- GPT/Codex
  - Web
  - CLI
  - Desktop
  - iOS

*using the* [Supabase Plugin](https://supabase.com/docs/guides/ai-tools/plugins)

## 🔎 Use Cases

### ✍️ Identify Writing Pattern Anomalies

Memory can track recurring writing characteristics across submissions, including punctuation habits, sentence structure, vocabulary, and formatting patterns. This allows a teacher to establish a student's historical writing baseline and flag sudden changes for human review.

Em-dash frequency alone does not prove AI use. A sharp increase relative to a student's own prior work can identify writing that deserves closer examination.

The same analysis can compare writers by normalizing punctuation frequency against document length:

```mermaid
xychart-beta
    title "Em-Dash Frequency by Writer"
    x-axis ["System", "Claude", "Grok", "Architect", "Qwen", "Codex"]
    y-axis "Per 1,000 Characters" 0 --> 1.1
    bar [1.052, 0.792, 0.630, 0.313, 0.248, 0.096]
```

> Memory does not make the accusation. It preserves the evidence, establishes the baseline, and surfaces the anomaly for human judgment.

###  📊 Display Agentic Working Relationships

Memory is the bridge that connects agentic context across platforms and vendors and can be used as a shared operational history where agents:

- search before acting
- use prior records to avoid duplicate work and
- write decisions and outcomes back into the shared substrate

> The following snapshot shows some of the most common memory relationships.

```mermaid
pie showData
    title Relations
    "Delivers" : 233
    "Learns" : 111
    "Documents" : 107
    "Glorious Failures" : 83
    "Implements" : 76
    "Receives" : 71
```

### 📊 Track What Was Worked On

Because every memory is assigned to a work domain, Memory can reveal where agents are spending their effort across projects, disciplines, and recurring problem areas.

```mermaid
xychart-beta
    title "Most Active Work"
    x-axis ["Memory", "Security", "Plan", "Infra", "Cognition", "Frontend", "Feedback", "Prompt"]
    y-axis "Memories" 0 --> 160
    bar [156, 118, 106, 106, 95, 84, 67, 61]
```

## 🏗️ Architecture

What makes Memory unique is the combination of the following *__Agentic Aspects__*:

```mermaid
mindmap
  root((Memory))
    Typed Semantic Grammar
      Entity
      Relation
      Work
      Notes
    Durable Storage
      Postgres
      Supabase
    Search
      Keyword
      Semantic
    Cross-Vendor Access
      Claude
      GPT
      Codex
      Other Agents
    Failure-Derived Learning
      Glorious Failures
      Corrections
      Recovery Paths
```

that power the *__Agentic Continuity Loop__*:



### 🧬 The Semantic Grammar

Memory forms a *semantic graph* over a *relational store*. It is **not** a graph database. Postgres stores typed records; the relationships expressed by those records form the graph.

```mermaid
erDiagram
    ENTITY ||--o{ MEMORY : records
    ENTITY ||--o{ MEMORY : receives
    RELATION ||--o{ MEMORY : types
    WORK ||--o{ MEMORY : contextualizes

    MEMORY {
        bigint id
        entity_enum entity
        entity_enum to_entity
        relation_enum relation
        work_enum work
        text notes
        tsvector notes_fts
        boolean active
        bigint epoch
        vector embedding
    }
```

A record states that one entity performed a relation toward another entity within a work domain. Notes preserve the evidence, reasoning, correction, or intent that gives the relationship meaning.

| entity | relation | to_entity | work | notes |
| ------ | -------- | --------- | ---- | ----- |
| GPT | GloriousFailures | Architect | Troubleshoot | A tool failure and its recovery context |
| Codex | Delivers | Architect | Frontend | A completed feature with verification and next steps |
| Architect | Documents | Agent | Protocol | A durable rule future agents must follow |

The table is storage. The relationships between its records are Memory.

## 🌉 Continuous Agentic Improvement

```mermaid
sequenceDiagram
    participant A as Human or Agent
    participant M as Memory
    participant F as Future Agent

    A->>A: Performs work
    A->>M: Records meaning
    F->>M: Searches prior work
    M-->>F: Returns relevant context
    F->>F: Internalizes the context
    F->>M: Continues the history
```

This allows Memory to preserve continuity across model changes, application boundaries, expired conversations, and interrupted work.

## 🔥 Glorious Failures

Successful outcomes preserve what worked. Glorious Failures preserve what must not be misunderstood again.

When a tool fails, an implementation diverges from the request, an agent follows a false assumption, or a reasoning pattern repeatedly produces poor results, Memory can retain the failure as a searchable relationship. The record captures the circumstances, the incorrect path, the correction, and the lesson derived from it.

This turns failure into reusable cognitive infrastructure. A future agent can recognize the shape of a previous mistake before repeating the entire investigation.




## 📚 Specification

See the [Memory Specification](./memory.spec.md) for the normative data model, access controls, search behavior, and embedding requirements.