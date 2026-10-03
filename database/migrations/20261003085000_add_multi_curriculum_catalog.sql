create table if not exists public.programs (
  id text primary key,
  name text not null,
  short_name text not null,
  country_code text not null,
  primary_language text not null,
  secondary_language text,
  level_kind text not null check (level_kind in ('year','semester')),
  status text not null default 'foundation' check (status in ('live','foundation')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.academic_levels (
  id uuid primary key default gen_random_uuid(),
  program_id text not null references public.programs(id) on delete cascade,
  code text not null,
  label text not null,
  level_number integer not null check (level_number > 0),
  display_order integer not null default 0,
  language text not null,
  secondary_language text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (program_id, code)
);

create table if not exists public.profile_programs (
  user_id uuid not null references public.profiles(id) on delete cascade,
  program_id text not null references public.programs(id) on delete cascade,
  academic_level_id uuid references public.academic_levels(id) on delete set null,
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, program_id)
);

alter table public.programs enable row level security;
alter table public.academic_levels enable row level security;
alter table public.profile_programs enable row level security;

grant select on table public.programs to authenticated;
grant select on table public.academic_levels to authenticated;
grant select, insert, update, delete on table public.profile_programs to authenticated;

grant all on table public.programs to service_role;
grant all on table public.academic_levels to service_role;
grant all on table public.profile_programs to service_role;

create policy "programs_authenticated_read"
on public.programs for select
to authenticated
using (is_active = true);

create policy "academic_levels_authenticated_read"
on public.academic_levels for select
to authenticated
using (is_active = true);

create policy "profile_programs_read_own"
on public.profile_programs for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "profile_programs_insert_own"
on public.profile_programs for insert
to authenticated
with check ((select auth.uid()) = user_id);

create policy "profile_programs_update_own"
on public.profile_programs for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "profile_programs_delete_own"
on public.profile_programs for delete
to authenticated
using ((select auth.uid()) = user_id);

insert into public.programs (id,name,short_name,country_code,primary_language,secondary_language,level_kind,status)
values
  ('kineo-fr','Kineo France','Kineo','FR','fr',null,'year','live'),
  ('kineo-es','Kineo España','Kineo España','ES','es','fr','year','foundation'),
  ('ifsi-fr','IFSI','IFSI','FR','fr',null,'semester','foundation')
on conflict (id) do update set
  name = excluded.name,
  short_name = excluded.short_name,
  country_code = excluded.country_code,
  primary_language = excluded.primary_language,
  secondary_language = excluded.secondary_language,
  level_kind = excluded.level_kind,
  status = excluded.status,
  updated_at = now();

insert into public.academic_levels (program_id,code,label,level_number,display_order,language,secondary_language)
values
  ('kineo-fr','K1','K1',1,1,'fr',null),
  ('kineo-fr','K2','K2',2,2,'fr',null),
  ('kineo-fr','K3','K3',3,3,'fr',null),
  ('kineo-fr','K4','K4',4,4,'fr',null),
  ('kineo-es','ES1','1re année',1,1,'es','fr'),
  ('kineo-es','ES2','2e année',2,2,'es','fr'),
  ('kineo-es','ES3','3e année',3,3,'es','fr'),
  ('kineo-es','ES4','4e année',4,4,'es','fr'),
  ('ifsi-fr','S1','Semestre 1',1,1,'fr',null),
  ('ifsi-fr','S2','Semestre 2',2,2,'fr',null),
  ('ifsi-fr','S3','Semestre 3',3,3,'fr',null),
  ('ifsi-fr','S4','Semestre 4',4,4,'fr',null),
  ('ifsi-fr','S5','Semestre 5',5,5,'fr',null),
  ('ifsi-fr','S6','Semestre 6',6,6,'fr',null)
on conflict (program_id, code) do update set
  label = excluded.label,
  level_number = excluded.level_number,
  display_order = excluded.display_order,
  language = excluded.language,
  secondary_language = excluded.secondary_language,
  is_active = true;
