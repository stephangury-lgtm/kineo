create or replace function public.refresh_security_health_status_v1()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_payload jsonb;
begin
  with definer as (
    select p.oid,p.proname,coalesce(array_to_string(p.proconfig,','),'') as config
    from pg_proc p
    join pg_namespace n on n.oid=p.pronamespace
    where n.nspname='public' and p.prosecdef
  ),
  deprecated as (
    select p.oid,p.proname
    from pg_proc p
    join pg_namespace n on n.oid=p.pronamespace
    where n.nspname='public'
      and (
        (p.proname='get_friend_leaderboard_v1' and pg_get_function_identity_arguments(p.oid)='')
        or (p.proname='get_friendships_v2' and pg_get_function_identity_arguments(p.oid)='')
        or (p.proname='get_friend_challenges_v2' and pg_get_function_identity_arguments(p.oid)='')
        or (p.proname='submit_quiz_answer_v4' and pg_get_function_identity_arguments(p.oid)='p_session_id uuid, p_question_id uuid, p_answer jsonb, p_response_time_ms integer')
      )
  ),
  checks as (
    select
      (select count(*) from definer)::int as total_security_definer,
      (select count(*) from definer where has_function_privilege('anon',oid,'EXECUTE'))::int as anon_security_definer_executable,
      (select count(*) from definer where config not like '%search_path=%')::int as unpinned_security_definer_search_path,
      (select count(*) from deprecated where has_function_privilege('authenticated',oid,'EXECUTE'))::int as deprecated_authenticated_rpcs
  )
  select jsonb_build_object(
    'ok',anon_security_definer_executable=0
         and unpinned_security_definer_search_path=0
         and deprecated_authenticated_rpcs=0,
    'critical_count',anon_security_definer_executable
                     + unpinned_security_definer_search_path
                     + deprecated_authenticated_rpcs,
    'checks',jsonb_build_object(
      'total_security_definer',total_security_definer,
      'anon_security_definer_executable',anon_security_definer_executable,
      'unpinned_security_definer_search_path',unpinned_security_definer_search_path,
      'deprecated_authenticated_rpcs',deprecated_authenticated_rpcs
    ),
    'generated_at',now()
  )
  into v_payload
  from checks;

  insert into public.security_health_status(id,payload,checked_at)
  values(1,v_payload,now())
  on conflict(id) do update set payload=excluded.payload,checked_at=excluded.checked_at;

  return v_payload;
end;
$function$;

revoke all on function public.refresh_security_health_status_v1() from public, anon, authenticated;

select public.refresh_security_health_status_v1();
