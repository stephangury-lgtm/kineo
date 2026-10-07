create or replace function public.get_friend_challenges_v3()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_uid uuid := auth.uid();
  v_result jsonb;
begin
  if v_uid is null then
    raise exception 'Utilisateur non authentifié';
  end if;

  with rows as (
    select c.*,
      case when c.challenger_id=v_uid then c.challenged_id else c.challenger_id end as opponent_id,
      case when c.challenger_id=v_uid then 'sent' else 'received' end as direction
    from public.challenges c
    where c.challenger_id=v_uid or c.challenged_id=v_uid
  ),
  enriched as (
    select r.*,
      myrs.id as my_session_id,
      myrs.completed_at as my_completed_at,
      opprs.completed_at as opponent_completed_at
    from rows r
    left join lateral (
      select rs.id,rs.completed_at
      from public.revision_sessions rs
      where rs.user_id=v_uid
        and rs.challenge_id=r.id
        and rs.abandoned_at is null
      order by rs.started_at desc
      limit 1
    ) myrs on true
    left join lateral (
      select rs.completed_at
      from public.revision_sessions rs
      where rs.user_id=r.opponent_id
        and rs.challenge_id=r.id
        and rs.abandoned_at is null
      order by rs.started_at desc
      limit 1
    ) opprs on true
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'id',e.id,
    'status',e.status,
    'direction',e.direction,
    'challenger_id',e.challenger_id,
    'challenged_id',e.challenged_id,
    'challenger_score',e.challenger_score,
    'challenged_score',e.challenged_score,
    'created_at',e.created_at,
    'completed_at',e.completed_at,
    'my_session_id',e.my_session_id,
    'has_played',e.my_completed_at is not null,
    'opponent_has_played',e.opponent_completed_at is not null,
    'opponent',jsonb_build_object(
      'id',p.id,'username',p.username::text,'first_name',p.first_name,
      'study_year',p.study_year,'level',p.level,'avatar_url',p.avatar_url
    )
  ) order by e.created_at desc),'[]'::jsonb)
  into v_result
  from enriched e
  join public.profiles p on p.id=e.opponent_id;

  return v_result;
end;
$function$;

revoke all on function public.get_friend_challenges_v3() from public, anon;
grant execute on function public.get_friend_challenges_v3() to authenticated;
