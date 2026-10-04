-- A student account belongs to one curriculum. Existing historical secondary rows
-- are kept for rollback/audit, but authenticated users cannot activate or change them.

-- Backfill legacy Kineo accounts that predate profile_programs so existing users
-- keep their current K2-K5 path and are not sent back through onboarding.
insert into public.profile_programs(user_id,program_id,academic_level_id,is_primary,updated_at)
select p.id,'kineo-fr',al.id,true,now()
from public.profiles p
join public.academic_levels al
  on al.program_id='kineo-fr'
 and al.code=('K' || greatest(2,least(5,coalesce(p.study_year,2)))::text)
where not exists (
  select 1 from public.profile_programs pp
  where pp.user_id=p.id and pp.is_primary=true
)
and not exists (
  select 1 from public.profile_programs pp
  where pp.user_id=p.id and pp.program_id='kineo-fr'
);

create or replace function public.lock_student_curriculum_assignment()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    if exists (
      select 1
      from public.profile_programs existing
      where existing.user_id = new.user_id
    ) then
      raise exception 'student curriculum is already assigned';
    end if;
    new.is_primary := true;
    return new;
  end if;

  if new.user_id is distinct from old.user_id
     or new.program_id is distinct from old.program_id then
    raise exception 'student curriculum cannot be changed';
  end if;

  if old.is_primary is not true then
    raise exception 'historical secondary curriculum is locked';
  end if;

  new.is_primary := true;
  return new;
end;
$$;

drop trigger if exists trg_lock_student_curriculum_assignment on public.profile_programs;
create trigger trg_lock_student_curriculum_assignment
before insert or update on public.profile_programs
for each row execute function public.lock_student_curriculum_assignment();

drop policy if exists "profile_programs_delete_own" on public.profile_programs;
revoke delete on table public.profile_programs from authenticated;

-- Keep the existing ownership-based SELECT / INSERT / UPDATE RLS policies.
-- The trigger enforces immutability of the selected program while still allowing
-- the academic_level_id to evolve as the student advances in the same curriculum.
