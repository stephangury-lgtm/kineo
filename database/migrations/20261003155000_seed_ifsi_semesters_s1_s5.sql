-- IFSI curriculum seed supplied by the user on 2026-10-03.
-- S6 intentionally left empty until the user provides its UE list.

with levels as (
  select id, code
  from public.academic_levels
  where program_id = 'ifsi-fr'
),
source(level_code, code, name, description, display_order) as (
  values
    ('S1','4.1','UE 4.1',null,1),
    ('S1','3.1','UE 3.1',null,2),
    ('S1','2.11','UE 2.11','Antalgiques, AINS, risques et dangers',3),
    ('S1','2.10','UE 2.10',null,4),
    ('S1','2.4','UE 2.4',null,5),
    ('S1','2.2','UE 2.2',null,6),
    ('S1','2.1','UE 2.1',null,7),
    ('S1','1.3','UE 1.3',null,8),
    ('S1','1.1','UE 1.1',null,9),

    ('S2','4.5','UE 4.5',null,1),
    ('S2','4.4','UE 4.4',null,2),
    ('S2','3.2','UE 3.2',null,3),
    ('S2','3.1','UE 3.1',null,4),
    ('S2','2.6','UE 2.6',null,5),
    ('S2','2.3','UE 2.3',null,6),
    ('S2','1.2','UE 1.2',null,7),
    ('S2','1.1','UE 1.1',null,8),

    ('S3','4.6','UE 4.6',null,1),
    ('S3','2.11','UE 2.11','Psychotropes',2),
    ('S3','2.8','UE 2.8',null,3),
    ('S3','2.5','UE 2.5',null,4),
    ('S3','1.2','UE 1.2',null,5),
    ('S3','ANGLAIS','Anglais',null,6),

    ('S4','SANTE_NUMERIQUE','Santé numérique',null,1),
    ('S4','4.5','UE 4.5',null,2),
    ('S4','4.4','UE 4.4',null,3),
    ('S4','4.3','UE 4.3',null,4),
    ('S4','3.5','UE 3.5',null,5),
    ('S4','3.4','UE 3.4',null,6),
    ('S4','2.7','UE 2.7',null,7),
    ('S4','1.3','UE 1.3',null,8),
    ('S4','ANGLAIS','Anglais',null,9),

    ('S5','4.7','UE 4.7',null,1),
    ('S5','3.3','UE 3.3',null,2),
    ('S5','2.11','UE 2.11','Amines',3),
    ('S5','2.9','UE 2.9',null,4),
    ('S5','ANGLAIS','Anglais',null,5)
)
insert into public.curriculum_units (
  program_id,
  academic_level_id,
  code,
  name,
  unit_type,
  description,
  display_order,
  content_language,
  translation_language,
  translation_mode,
  is_active,
  updated_at
)
select
  'ifsi-fr',
  l.id,
  s.code,
  s.name,
  'ue',
  s.description,
  s.display_order,
  'fr',
  null,
  'none',
  true,
  now()
from source s
join levels l on l.code = s.level_code
on conflict (academic_level_id, code) do update set
  name = excluded.name,
  unit_type = excluded.unit_type,
  description = excluded.description,
  display_order = excluded.display_order,
  content_language = excluded.content_language,
  translation_language = excluded.translation_language,
  translation_mode = excluded.translation_mode,
  is_active = true,
  updated_at = now();
