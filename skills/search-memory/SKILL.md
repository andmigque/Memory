---
name: search-memory
description: MUST use to ground the current task in past memory before acting. Run it at the start of any non-trivial task, and whenever the work needs a prior decision, an earlier failure, or context that is not already in this session. Runs a semantic search over the agent memory data plane and returns the closest memories. Triggers ground first, recall, remember, prior context, past decision, earlier work, what do I know about, have we done this before, search memory, semantic search, vector search, find a memory, Search-Memory.
---

# 🔎 __Search Memory__

> Run a semantic search over the agent memory data plane.
> Search before you redo work. Search before you guess at context.

---

## 1. 🧭 _Quick Start_

Dot-source the script, then call it with a plain sentence.

```powershell
. ./scripts/Search-Memory.ps1
Search-Memory -Query 'how does embedding trigger authentication'
```

The function ships with this skill in `./scripts/Search-Memory.ps1`. It takes one parameter, `-Query`,
and returns the matching rows, best match first. Each row has `score`, `id`, `entity`, `work`, and `notes`.

It needs two environment variables. Without them the call throws.

- `SUPABASE_URL_DEV` is the project URL.
- `SUPABASE_SERVICE_ROLE_KEY_DEV` is the service role key.

---

## 2. 🧠 _Search by Meaning, Not Keywords_

> The search ranks by meaning. Write a sentence that means what you want.

The query is embedded and matched against the meaning of each memory. A string of distinctive words
scores low, even when those exact words sit in a row. Keywords are not the tool.

##### 2.1 __Do This__
- `Search-Memory -Query 'the architect was frustrated by repeated mistakes'`

##### 2.2 __Do Not Do This__
- `Search-Memory -Query 'pineapple lighthouse frustrated'`
- That is token soup. The meaning is empty, so the ranking is poor.

---

## 3. 🕒 _When to Search_

> Search before you act, not after you are stuck.

##### 3.1 __Do This__
- Before redoing work, search for whether it was already done.
- When the user points at context you do not have, search for it.

##### 3.2 __Do Not Do This__
- Skip the search and guess. The answer is often already in the store.

---

## 4. 📥 _Read the Result, Do Not Recite It_

> A returned memory is context for you. It is not a script to read back.

##### 4.1 __Do This__
- Read the rows. Act on them. Say one line about what they change.

##### 4.2 __Do Not Do This__
- Paste the full notes back to the user. They did not ask for a transcript.

---

## 5. 🔑 _Auth_

> The function is private. It sends the service role key on every call.

##### 5.1 __Do This__
- Let the function read the key from `$env:SUPABASE_SERVICE_ROLE_KEY_DEV`.

##### 5.2 __Do Not Do This__
- Use the publishable key. It is not a JWT, so the call returns 401.
- Write the URL or the key into a file. Read both from the environment.

---

## 🏁 _Closing_

> Give it a sentence, not keywords.
> Search before you redo work.
> Read the rows as context. Never recite them.
> Keep the key in the environment.
