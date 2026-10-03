create or replace function public.get_friend_challenges_v2()
returns jsonb
language sql
security definer
set search_path=''
as $function$
  with me as (select auth.uid() uid),
  rows as (
    select c.*,
      case when c.challenger_id = me.uid then c.challenged_id else c.challenger_id end as opponent_id,
      case when c.challenger_id = me.uid then 'sent' else 'received' end as direction,
      me.uid as me_id
    from public.challenges c cross join me
    where me.uid is not null and (c.challenger_id = me.uid or c.challenged_id = me.uid)
  ),
  enriched as (
    select r.*,
      myrs.id as my_session_id,
      myrs.completed_at as my_completed_at,
      opprs.completed_at as opponent_completed_at
    from rows r
    left join lateral (
      select rs.id, rs.completed_at
      from public.revision_sessions rs
      where rs.user_id = r.me_id
        and rs.challenge_id = r.id
        and rs.abandoned_at is null
      order by rs.started_at desc
      limit 1
    ) myrs on true
    left join lateral (
      select rs.completed_at
      from public.revision_sessions rs
      where rs.user_id = r.opponent_id
        and rs.challenge_id = r.id
        and rs.abandoned_at is null
      order by rs.started_at desc
      limit 1
    ) opprs on true
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'id', e.id,
    'status', e.status,
    'direction', e.direction,
    'challenger_id', e.challenger_id,
    'challenged_id', e.challenged_id,
    'challenger_score', e.challenger_score,
    'challenged_score', e.challenged_score,
    'created_at', e.created_at,
    'completed_at', e.completed_at,
    'my_session_id', e.my_session_id,
    'has_played', e.my_completed_at is not null,
    'opponent_has_played', e.opponent_completed_at is not null,
    'opponent', jsonb_build_object(
      'id', p.id,
      'username', p.username::text,
      'first_name', p.first_name,
      'study_year', p.study_year,
      'level', p.level,
      'avatar_url', p.avatar_url
    )
  ) order by e.created_at desc), '[]'::jsonb)
  from enriched e
  join public.profiles p on p.id = e.opponent_id;
$function$;

grant execute on function public.get_friend_challenges_v2() to authenticated;
