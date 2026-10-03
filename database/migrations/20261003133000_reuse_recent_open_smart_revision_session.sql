create or replace function public.start_smart_revision_v2(p_question_count integer default 10)
returns uuid
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_uid uuid := auth.uid();
  v_existing uuid;
begin
  if v_uid is null then
    raise exception 'Utilisateur non authentifié';
  end if;

  if p_question_count is null or p_question_count < 1 or p_question_count > 50 then
    raise exception 'Nombre de questions invalide';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_uid::text, 0));

  select rs.id
  into v_existing
  from public.revision_sessions rs
  where rs.user_id = v_uid
    and rs.mode = 'smart'
    and rs.completed_at is null
    and rs.abandoned_at is null
    and rs.daily_challenge_id is null
    and rs.challenge_id is null
    and rs.started_at >= now() - interval '12 hours'
    and exists (
      select 1
      from public.revision_session_questions rsq
      where rsq.session_id = rs.id
        and rsq.answered_at is null
    )
  order by rs.started_at desc
  limit 1;

  if v_existing is not null then
    return v_existing;
  end if;

  return public.start_smart_revision_v5_internal(v_uid, p_question_count);
end;
$function$;

grant execute on function public.start_smart_revision_v2(integer) to authenticated;
