---- # entity_enum
----
---- > Valid actors and systems that can record or receive a memory row.
---- > Case-sensitive on the wire.
CREATE TYPE public.entity_enum AS ENUM (
  'Architect',
  'Gemini',
  'Claude',
  'Grok',
  'GPT',
  'Human',
  'Self',
  'System',
  'Agent',
  'Codex',
  'Qwen'
);
