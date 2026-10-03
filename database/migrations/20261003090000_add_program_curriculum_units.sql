create table if not exists public.curriculum_units (
  id uuid primary key default gen_random_uuid(),
  program_id text not null references public.programs(id) on delete cascade,
  academic_level_id uuid not null references public.academic_levels(id) on delete cascade,
  code text,
  name text not null,
  unit_type text not null default 'subject' check (unit_type in ('subject','ue','module')),
  description text,
  icon text,
  display_order integer not null default 0,
  content_language text not null,
  translation_language text,
  translation_mode text not null default 'none' check (translation_mode in ('none','vocabulary','bilingual')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (academic_level_id, code)
);

create table if not exists public.curriculum_topics (
  id uuid primary key default gen_random_uuid(),
  unit_id uuid not null references public.curriculum_units(id) on delete cascade,
  name text not null,
  slug text not null,
  description text,
  display_order integer not null default 0,
  content_language text not null,
  translation_language text,
  translation_mode text not null default 'none' check (translation_mode in ('none','vocabulary','bilingual')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (unit_id, slug)
);

alter table public.curriculum_units enable row level security;
alter table public.curriculum_topics enable row level security;

grant select on table public.curriculum_units to authenticated;
grant select on table public.curriculum_topics to authenticated;
grant all on table public.curriculum_units to service_role;
grant all on table public.curriculum_topics to service_role;

create policy "curriculum_units_authenticated_read"
on public.curriculum_units for select
to authenticated
using (is_active = true);

create policy "curriculum_topics_authenticated_read"
on public.curriculum_topics for select
to authenticated
using (is_active = true);

create index if not exists idx_curriculum_units_program_level
  on public.curriculum_units(program_id, academic_level_id, display_order);

create index if not exists idx_curriculum_topics_unit
  on public.curriculum_topics(unit_id, display_order);
