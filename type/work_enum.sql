---- # work_enum
----
---- > Bounded work domains.
---- > Work scopes the memory row so the same entity, relation, and target entity can mean different things in different streams.
---- > Case-sensitive on the wire.
CREATE TYPE public.work_enum AS ENUM (
  'Devops',
  'Infrastructure',
  'DataPlane',
  'Protocol',
  'Security',
  'Research',
  'Backend',
  'Plan',
  'Frontend',
  'Troubleshoot',
  'Schema',
  'Skill',
  'CodeQuality',
  'Configure',
  'UserExperience',
  'Prompt',
  'Memory',
  'Test'
);
