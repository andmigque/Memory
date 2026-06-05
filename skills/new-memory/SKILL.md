---
name: new-memory
description: MUST use to record a memory so the next session starts warm. Record at a milestone, a decision you made, a correction you took, a failure you own, or a pattern worth carrying forward. Writes one row through the new_memory RPC. Triggers record a memory, save a memory, remember this, log a decision, capture a failure, note a correction, write to the memory store, new memory, new_memory, New-Memory.
---

# 📝 __New Memory__

> Record what you learned so the next session does not start cold.
> One call. Five fields. The row is a sentence.

---

## 1. 🧭 _Quick Start_

Dot-source the script, then record a memory with the five fields.

```powershell
. ./scripts/New-Memory.ps1
New-Memory -Entity 'Claude' -ToEntity 'Architect' -Relation 'Fixes' -Work 'Security' `
  -Notes 'Hardened the embedding function to reject any caller that is not the service role key.'
```

The function ships with this skill in `./scripts/New-Memory.ps1`. It returns the inserted row,
including its `id` and `epoch`.

It needs these environment variables. Without them the call throws.

- `SUPABASE_URL_DEV` is the project URL.
- `SUPABASE_PUBLISHABLE` is the publishable key.
- `AGENT_SUPABASE_MEMORY_EMAIL` and `AGENT_SUPABASE_MEMORY_SECRET` are this agent's Supabase Auth login.

---

## 2. 🧩 _A Memory Is a Sentence_

> Read left to right, the five fields form one sentence: entity, relation, to_entity, work, notes.

`Claude Fixes Architect [Security] hardened the embedding function ...`

- `Entity` is the actor.
- `Relation` is the verb.
- `ToEntity` is the target.
- `Work` is the domain.
- `Notes` is the body that completes the sentence.

`Entity`, `Relation`, and `Work` are controlled vocabularies. The server rejects a value that is not
in the set, and the error lists the valid ones.

---

## 3. ✍️ _Notes Complete the Sentence_

> The first word of `Notes` continues the sentence. It does not repeat the verb.

##### 3.1 __Do This__
- `-Relation 'Implements' -Notes 'a constant-time check on the bearer token.'`

##### 3.2 __Do Not Do This__
- `-Relation 'Implements' -Notes 'Implemented a constant-time check.'`
- That stutters. The sentence already said the verb.

---

## 4. 🕒 _When to Record_

> Record at the moment worth carrying forward, not at the end of everything.

##### 4.1 __Do This__
- A decision and the reason for it.
- A correction you received and applied.
- A failure you own and dissected.
- A pattern you will want next time.

##### 4.2 __Do Not Do This__
- Save an empty or vacuous note. If full-text search could never find it later, it is not worth a row.

---

## 5. 🔥 _Record the Failure, Do Not Bury It_

> The owned failure is the most valuable row in the store. Write it richly.

A failure you own is not `Feedback`. `Feedback` is a correction someone hands you. An owned failure is
an act you perform on yourself: you name the failure, trace its shape, and keep it where the next
session will find it. That act has its own verb.

##### 5.1 __Do This__
- `New-Memory -Entity 'Claude' -ToEntity 'Self' -Relation 'GloriousFailures' -Work 'Cognition' -Notes 'Acted on a grep hit instead of reading the file end to end, and stated the wrong behavior.'`

##### 5.2 __Do Not Do This__
- Leave the failure out because it is unflattering. A buried failure teaches no one. De-shaming the
  failure is the point.

---

## 6. 🔑 _Auth_

> You record as yourself. The script signs in to Supabase Auth and writes under your own identity.

##### 6.1 __Do This__
- The script signs in with `AGENT_SUPABASE_MEMORY_EMAIL` and `AGENT_SUPABASE_MEMORY_SECRET`, then sends the publishable key plus your user JWT. RLS scopes the write to you.

##### 6.2 __Do Not Do This__
- Use the service role key. The client never holds it.
- Write any key into a file. Read them all from the environment.

---

## 🏁 _Closing_

> Five fields, one sentence.
> Notes complete the verb, never repeat it.
> Record decisions, corrections, and owned failures.
> Keep the key in the environment.
