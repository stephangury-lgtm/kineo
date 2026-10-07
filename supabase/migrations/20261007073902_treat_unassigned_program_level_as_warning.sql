create or replace function public.refresh_authenticated_contract_status_v1()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_payload jsonb;
begin
  with assignments as (
    select
      pp.user_id,
      pp.program_id,
      pp.academic_level_id,
      coalesce(pp.curriculum_version,'default') as curriculum_version,
      al.display_order as active_order
    from public.profile_programs pp
    left join public.academic_levels al on al.id=pp.academic_level_id
  ),
  assigned as (
    select * from assignments where academic_level_id is not null and active_order is not null
  ),
  expected_access as (
    select
      a.user_id,
      a.program_id,
      a.curriculum_version,
      a.active_order,
      count(u.id)::int as expected_units,
      count(u.id) filter(where al.display_order>a.active_order)::int as future_units_in_expected_set
    from assigned a
    join public.curriculum_units u
      on u.program_id=a.program_id
     and u.is_active=true
     and (
       a.program_id<>'ifsi-fr'
       or coalesce(u.curriculum_version,'2009')=coalesce(a.curriculum_version,'2009')
     )
    join public.academic_levels al on al.id=u.academic_level_id
    where al.display_order<=a.active_order
    group by a.user_id,a.program_id,a.curriculum_version,a.active_order
  ),
  missing_current_or_previous as (
    select a.user_id,a.program_id
    from assigned a
    where a.program_id<>'kineo-fr'
      and not exists (
        select 1
        from public.curriculum_units u
        join public.academic_levels al on al.id=u.academic_level_id
        where u.program_id=a.program_id
          and u.is_active=true
          and al.display_order<=a.active_order
          and (
            a.program_id<>'ifsi-fr'
            or coalesce(u.curriculum_version,'2009')=coalesce(a.curriculum_version,'2009')
          )
      )
  ),
  invalid_primary as (
    select user_id
    from public.profile_programs
    group by user_id
    having count(*) filter(where is_primary)<>1
  ),
  invalid_level_binding as (
    select pp.user_id,pp.program_id
    from public.profile_programs pp
    join public.academic_levels al on al.id=pp.academic_level_id
    where pp.academic_level_id is not null
      and al.program_id<>pp.program_id
  ),
  unassigned_levels as (
    select user_id,program_id
    from public.profile_programs
    where academic_level_id is null
  ),
  invalid_curriculum_version as (
    select pp.user_id,pp.program_id
    from public.profile_programs pp
    where pp.program_id='ifsi-fr'
      and coalesce(pp.curriculum_version,'') not in ('2009','2026')
  ),
  checks as (
    select
      (select count(*) from assignments)::int as assignment_count,
      (select count(*) from assigned)::int as assigned_level_count,
      (select count(*) from expected_access)::int as assignments_with_curriculum,
      (select count(*) from missing_current_or_previous)::int as missing_current_or_previous_content,
      (select count(*) from invalid_primary)::int as invalid_primary_program_count,
      (select count(*) from invalid_level_binding)::int as invalid_level_binding_count,
      (select count(*) from unassigned_levels)::int as unassigned_level_count,
      (select count(*) from invalid_curriculum_version)::int as invalid_ifsi_curriculum_version_count,
      (select coalesce(sum(future_units_in_expected_set),0) from expected_access)::int as future_units_leaking_into_expected_set
  )
  select jsonb_build_object(
    'ok',(
      missing_current_or_previous_content
      + invalid_primary_program_count
      + invalid_level_binding_count
      + invalid_ifsi_curriculum_version_count
      + future_units_leaking_into_expected_set
    )=0,
    'critical_count',(
      missing_current_or_previous_content
      + invalid_primary_program_count
      + invalid_level_binding_count
      + invalid_ifsi_curriculum_version_count
      + future_units_leaking_into_expected_set
    ),
    'warning_count',unassigned_level_count,
    'checks',jsonb_build_object(
      'assignment_count',assignment_count,
      'assigned_level_count',assigned_level_count,
      'assignments_with_curriculum',assignments_with_curriculum,
      'missing_current_or_previous_content',missing_current_or_previous_content,
      'invalid_primary_program_count',invalid_primary_program_count,
      'invalid_level_binding_count',invalid_level_binding_count,
      'unassigned_level_count',unassigned_level_count,
      'invalid_ifsi_curriculum_version_count',invalid_ifsi_curriculum_version_count,
      'future_units_leaking_into_expected_set',future_units_leaking_into_expected_set
    ),
    'generated_at',now()
  )
  into v_payload
  from checks;

  insert into public.authenticated_contract_status(id,payload,checked_at)
  values(1,v_payload,now())
  on conflict(id) do update set payload=excluded.payload,checked_at=excluded.checked_at;

  return v_payload;
end;
$function$;

revoke all on function public.refresh_authenticated_contract_status_v1() from public, anon, authenticated;

select public.refresh_authenticated_contract_status_v1();
