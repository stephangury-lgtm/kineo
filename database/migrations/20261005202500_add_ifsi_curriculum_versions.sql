-- Separate IFSI 2009 and 2026 curricula without duplicating the social/gamification program.
-- Existing IFSI content is explicitly assigned to the 2009 reference.

alter table public.profile_programs
  add column if not exists curriculum_version text not null default 'default';

alter table public.curriculum_units
  add column if not exists curriculum_version text not null default 'default';

update public.profile_programs
set curriculum_version = '2009'
where program_id = 'ifsi-fr'
  and curriculum_version = 'default';

update public.curriculum_units
set curriculum_version = '2009'
where program_id = 'ifsi-fr'
  and curriculum_version = 'default';

alter table public.curriculum_units
  drop constraint if exists curriculum_units_academic_level_id_code_key;

alter table public.curriculum_units
  add constraint curriculum_units_academic_level_id_code_version_key
  unique (academic_level_id, code, curriculum_version);

alter table public.profile_programs
  drop constraint if exists profile_programs_curriculum_version_check;

alter table public.profile_programs
  add constraint profile_programs_curriculum_version_check
  check (curriculum_version in ('default','2009','2026'));

alter table public.curriculum_units
  drop constraint if exists curriculum_units_curriculum_version_check;

alter table public.curriculum_units
  add constraint curriculum_units_curriculum_version_check
  check (curriculum_version in ('default','2009','2026'));

create index if not exists idx_curriculum_units_level_version
  on public.curriculum_units(academic_level_id,curriculum_version);

create index if not exists idx_profile_programs_program_version
  on public.profile_programs(program_id,curriculum_version);
