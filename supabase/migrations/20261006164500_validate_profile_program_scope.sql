-- Keep profile_programs internally coherent even if a client bypasses the UI.
-- Program identity remains immutable; levels must belong to the program and
-- curriculum versions are restricted to the program's supported values.

create or replace function public.lock_student_curriculum_assignment()
returns trigger
language plpgsql
set search_path to 'public'
as $function$
declare
  v_auth_uid uuid := auth.uid();
begin
  if new.academic_level_id is not null and not exists (
    select 1
    from public.academic_levels al
    where al.id = new.academic_level_id
      and al.program_id = new.program_id
  ) then
    raise exception 'academic level does not belong to assigned program';
  end if;

  if new.program_id = 'ifsi-fr' then
    if coalesce(new.curriculum_version,'2009') not in ('2009','2026') then
      raise exception 'invalid IFSI curriculum version';
    end if;
  elsif coalesce(new.curriculum_version,'default') <> 'default' then
    raise exception 'curriculum version must be default for this program';
  end if;

  if tg_op = 'INSERT' then
    if exists (select 1 from public.profile_programs existing where existing.user_id = new.user_id) then
      if v_auth_uid = new.user_id then
        raise exception 'student curriculum is already assigned';
      end if;
      new.is_primary := coalesce(new.is_primary,false);
      if new.is_primary then
        raise exception 'a secondary curriculum cannot replace the existing primary curriculum';
      end if;
      return new;
    end if;
    new.is_primary := true;
    return new;
  end if;

  if new.user_id is distinct from old.user_id or new.program_id is distinct from old.program_id then
    raise exception 'student curriculum cannot be changed';
  end if;

  if v_auth_uid = new.user_id and old.is_primary is not true then
    raise exception 'secondary curriculum assignment is managed by an administrator';
  end if;

  if old.is_primary then new.is_primary := true; else new.is_primary := false; end if;
  return new;
end;
$function$;
