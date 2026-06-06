---
name: get-memory
description: MUST use to ground in the most recent memory before acting, when you want the latest activity or one entity's recent trail rather than a match by meaning. Returns the newest memory rows, newest first, with no query. Call it with no arguments to pull the latest across every entity, or pass an entity to scope to one actor. Triggers ground at session start, catch up, what happened recently, latest memory, most recent, recent activity, latest decisions, what has X done lately, recent trail, get memory, get_memory, Get-Memory.
---

# 🗂️ __Get Memory__

> Pull the most recent memories, newest first.
> Ground in what just happened before you act.

---

## 1. 🧭 _Quick Start_

Dot-source the script, then call it. With no arguments it returns the latest 10 across every entity.

```powershell
. ./scripts/Get-Memory.ps1
Get-Memory
Get-Memory -Entity 'Claude' -Limit 10
```

The function ships with this skill in `./scripts/Get-Memory.ps1`. It takes two optional parameters,
`-Entity` and `-Limit`, and returns the matching rows, newest first. Each row has `id`, `epoch`,
`entity`, `to_entity`, `relation`, `work`, `notes`, and `active`.

It needs these environment variables. Without them the call throws.

- `SUPABASE_URL_DEV` is the project URL.
- `SUPABASE_PUBLISHABLE` is the publishable key.
- `AGENT_SUPABASE_MEMORY_EMAIL` and `AGENT_SUPABASE_MEMORY_SECRET` are this agent's Supabase Auth login.

---

## 2. 🕒 _Latest First, Not by Meaning_

> This skill returns the newest rows in order. It does not rank by meaning.

Reach for `get-memory` when you want recent activity or one entity's recent trail: the last things
recorded, newest first. Reach for `search-memory` instead when you want rows that match a meaning,
wherever they sit in time.

##### 2.1 __Do This__
- `Get-Memory` to see the latest activity across every entity.
- `Get-Memory -Entity 'Architect' -Limit 5` to read one actor's recent trail.

##### 2.2 __Do Not Do This__
- Pass a sentence hoping for a semantic match. There is no query here. That is `search-memory`.

---

## 3. 🧭 _When to Get_

> Ground at the start, before you ask the user to catch you up.

##### 3.1 __Do This__
- At session start, pull the latest rows to learn what was just built, decided, and failed.
- When you need one entity's recent trail, scope with `-Entity`.

##### 3.2 __Do Not Do This__
- Ask the user to recap what the store already holds. Get the rows first.

---

## 4. 📥 _Read the Result, Do Not Recite It_

> A returned memory is context for you. It is not a script to read back.

##### 4.1 __Do This__
- Read the rows. Act on them. Say one line about what they change.

##### 4.2 __Do Not Do This__
- Paste the full notes back to the user. They did not ask for a transcript.

---

## 5. 🔑 _Auth_

> You read as yourself. The script signs in to Supabase Auth and runs under your own identity.

##### 5.1 __Do This__
- The script signs in with `AGENT_SUPABASE_MEMORY_EMAIL` and `AGENT_SUPABASE_MEMORY_SECRET`, then sends the publishable key plus your user JWT. RLS scopes what you can read.

##### 5.2 __Do Not Do This__
- Use the service role key. The client never holds it.
- Write any key into a file. Read them all from the environment.

---

## 🏁 _Closing_

> No query. The newest rows, in order.
> Use it to ground; use search-memory to match by meaning.
> Read the rows as context. Never recite them.
> Keep the key in the environment.
