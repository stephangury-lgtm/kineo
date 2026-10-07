drop policy if exists curriculum_units_active_assignment_read on public.curriculum_units;

create policy curriculum_units_active_assignment_read
on public.curriculum_units
for select
to authenticated
using (
  is_active=true
  and (
    exists (
      select 1
      from public.profiles p
      where p.id=(select auth.uid())
        and p.role='admin'
    )
    or exists (
      select 1
      from public.profile_programs pp
      join public.academic_levels assigned_level on assigned_level.id=pp.academic_level_id
      join public.academic_levels target_level on target_level.id=curriculum_units.academic_level_id
      where pp.user_id=(select auth.uid())
        and pp.program_id=curriculum_units.program_id
        and assigned_level.program_id=curriculum_units.program_id
        and target_level.program_id=curriculum_units.program_id
        and target_level.display_order<=assigned_level.display_order
        and (
          curriculum_units.program_id<>'ifsi-fr'
          or coalesce(pp.curriculum_version,'2009')=coalesce(curriculum_units.curriculum_version,'2009')
        )
    )
  )
);
