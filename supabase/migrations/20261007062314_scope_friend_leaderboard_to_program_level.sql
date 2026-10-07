create or replace function public.get_friend_leaderboard_v2(p_program_id text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_user_id uuid := auth.uid();
  v_level_id uuid;
  v_curriculum_version text;
  v_result jsonb;
begin
  if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;

  select pp.academic_level_id, coalesce(pp.curriculum_version,'default')
  into v_level_id, v_curriculum_version
  from public.profile_programs pp
  where pp.user_id=v_user_id and pp.program_id=p_program_id
  limit 1;

  if v_level_id is null then raise exception 'Cursus ou niveau introuvable'; end if;

  with people as (
    select v_user_id as user_id, true as is_me
    union
    select case when f.requester_id=v_user_id then f.addressee_id else f.requester_id end, false
    from public.friendships f
    where f.status='accepted'
      and (f.requester_id=v_user_id or f.addressee_id=v_user_id)
  ),
  eligible as (
    select p.user_id,p.is_me
    from people p
    join public.profile_programs pp
      on pp.user_id=p.user_id
     and pp.program_id=p_program_id
     and pp.academic_level_id=v_level_id
     and (
       p_program_id<>'ifsi-fr'
       or coalesce(pp.curriculum_version,'2009')=coalesce(v_curriculum_version,'2009')
     )
  ),
  legacy_activity as (
    select e.user_id,
      coalesce(sum(qa.xp_earned) filter(where qa.created_at>=date_trunc('week',now())),0)::int as weekly_xp,
      count(qa.id) filter(where qa.created_at>=date_trunc('week',now()))::int as weekly_answers
    from eligible e
    left join public.question_attempts qa on qa.user_id=e.user_id
    where p_program_id='kineo-fr'
    group by e.user_id
  ),
  curriculum_activity as (
    select e.user_id,
      coalesce(sum(cqa.xp_earned) filter(where cqa.created_at>=date_trunc('week',now())),0)::int as weekly_xp,
      count(cqa.id) filter(where cqa.created_at>=date_trunc('week',now()))::int as weekly_answers
    from eligible e
    left join public.curriculum_question_attempts cqa on cqa.user_id=e.user_id
    left join public.curriculum_topics ct on ct.id=cqa.topic_id
    left join public.curriculum_units cu on cu.id=ct.unit_id and cu.program_id=p_program_id
    where p_program_id<>'kineo-fr'
      and (cqa.id is null or cu.id is not null)
    group by e.user_id
  ),
  activity as (
    select * from legacy_activity
    union all
    select * from curriculum_activity
  ),
  ranked as (
    select pr.id,pr.username::text,pr.first_name,pr.avatar_url,pr.level,pr.xp,
      coalesce(a.weekly_xp,0) as weekly_xp,
      coalesce(a.weekly_answers,0) as weekly_answers,
      e.is_me,
      row_number() over(
        order by coalesce(a.weekly_xp,0) desc,
                 coalesce(a.weekly_answers,0) desc,
                 coalesce(pr.username::text,pr.first_name,'') asc
      )::int as rank
    from eligible e
    join public.profiles pr on pr.id=e.user_id
    left join activity a on a.user_id=e.user_id
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'id',id,'username',username,'first_name',first_name,'avatar_url',avatar_url,
    'level',level,'xp_total',xp,'weekly_xp',weekly_xp,'weekly_answers',weekly_answers,
    'is_me',is_me,'rank',rank
  ) order by rank),'[]'::jsonb)
  into v_result
  from ranked;

  return v_result;
end;
$function$;

revoke all on function public.get_friend_leaderboard_v2(text) from public;
revoke all on function public.get_friend_leaderboard_v2(text) from anon;
grant execute on function public.get_friend_leaderboard_v2(text) to authenticated;
