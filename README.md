# 🤖🧠 Memory

Memory is a datastore that enables *__Continuous Agentic Improvement__*.

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

Memory can track recurring writing characteristics across submissions, including punctuation habits, sentence structure, vocabulary, and formatting patterns.

The analysis can compare writers by normalizing punctuation frequency against document length:

```mermaid
xychart-beta
    title "Em-Dash Frequency by Writer"
    x-axis ["System", "Claude", "Grok", "Architect", "Qwen", "Codex"]
    y-axis "Per 1,000 Characters" 0 --> 1.1
    bar [1.052, 0.792, 0.630, 0.313, 0.248, 0.096]
```

### 🧬 Detect Writing Style Changes Over Time

Memory can compare a single writer against their own prior work and reveal abrupt changes that may indicate a new AI model, prompt, skill, or writing policy.

The following analysis grouped 650 Claude records into sequential windows and measured em-dash frequency against document length:

```mermaid
xychart-beta
    title "Claude Em-Dash Frequency Over Time"
    x-axis ["1-25", "151-175", "226-250", "451-475", "501-525", "576-600", "626-650"]
    y-axis "Per 1,000 Characters" 0 --> 4
    bar [0.120, 2.605, 3.656, 0.000, 0.027, 3.099, 0.233]
```

### 🔤 Count Polysyllabic Words

Memory can estimate vocabulary complexity by counting words with three or more syllables and normalizing the result against total word count.

The following analysis compares Claude against its own prior records:

```mermaid
xychart-beta
    title "Claude Polysyllabic Word Frequency Over Time"
    x-axis ["1-25", "26-50", "76-100", "151-175", "226-250", "376-400", "451-475", "501-525", "626-650"]
    y-axis "Percent of Words" 0 --> 35
    bar [17.84, 30.44, 32.17, 29.39, 17.59, 15.71, 14.73, 15.32, 15.60]
```

As Claude models became more capable, they used less complex vocabulary. Polysyllabic words fell from roughly 30–32% in earlier record windows to 15–17% in later windows. The smarter models communicated with simpler words.

Memory can also compare vocabulary complexity across writers:

```mermaid
xychart-beta
    title "Polysyllabic Word Frequency by Writer"
    x-axis ["Agent", "Grok", "Qwen", "Codex", "GPT", "Architect", "Claude", "System"]
    y-axis "Percent of Words" 0 --> 35
    bar [33.37, 33.22, 26.08, 25.31, 24.18, 22.37, 19.65, 17.13]
```

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

Successful outcomes preserve what worked. Glorious Failures preserve what failed.

When a tool fails, an implementation diverges, or reasoning repeatedly produces poor results, Memory captures why actions fail.
Each new session context initializes with a curated list of failures specific to the session. 

## 📚 Specification

See the [Memory Specification](./memory.spec.md) for the normative data model, access controls, search behavior, and embedding requirements.
