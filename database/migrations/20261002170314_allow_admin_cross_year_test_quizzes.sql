-- Mirrors Supabase production migration 20261002170314_allow_admin_cross_year_test_quizzes
-- Admins may launch published lessons/subjects from any active study year for QA.
-- Regular students remain restricted to their active study year.

create or replace function public.start_lesson_quiz_v3_internal(
  p_user_id uuid,
  p_lesson_id uuid,
  p_question_count integer default 10
)
returns uuid
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_session_id uuid;
  v_available integer;
  v_count integer;
begin
  if p_user_id is null then raise exception 'Utilisateur non authentifié'; end if;
  if p_question_count is null or p_question_count < 1 or p_question_count > 50 then raise exception 'Nombre de questions invalide'; end if;

  if not exists(
    select 1
    from public.lessons l
    join public.chapters c on c.id = l.chapter_id
    join public.subjects s on s.id = c.subject_id
    join public.years y on y.id = s.year_id
    join public.profiles p on p.id = p_user_id
    where l.id = p_lesson_id
      and l.is_published = true
      and l.validation_status = 'published'
      and c.is_active = true
      and s.is_active = true
      and y.is_active = true
      and (y.number = p.study_year or p.role = 'admin')
  ) then
    raise exception 'Leçon indisponible pour ton année active';
  end if;

  select count(*) into v_available
  from public.questions q
  where q.lesson_id = p_lesson_id
    and q.is_published = true
    and q.validation_status = 'published'
    and q.type in ('mcq','true_false','fill_blank','matching','hotspot','image','short_answer','translation','clinical_case');

  if v_available = 0 then raise exception 'Aucune question validée disponible pour cette leçon'; end if;
  v_count := least(p_question_count, v_available);

  insert into public.revision_sessions(user_id,mode,question_count)
  values(p_user_id,'mix',v_count)
  returning id into v_session_id;

  with candidates as (
    select q.id,
      coalesce(uqm.mastery_percent,0) mastery_percent,
      coalesce(uqm.attempt_count,0) attempt_count,
      coalesce(uqm.correct_count,0) correct_count,
      uqm.last_attempt_at,
      uqm.next_review_at,
      coalesce(uqm.lapse_count,0) lapse_count,
      case
        when uqm.next_review_at is not null and uqm.next_review_at <= now() then 1
        when uqm.id is not null and coalesce(uqm.correct_count,0) < coalesce(uqm.attempt_count,0) then 2
        when uqm.id is not null and coalesce(uqm.mastery_percent,0) < 60 then 3
        when uqm.id is null then 4
        when uqm.id is not null and coalesce(uqm.mastery_percent,0) < 80 then 5
        else 6
      end priority_group,
      case when exists(
        select 1 from public.question_attempts qa
        where qa.user_id = p_user_id and qa.question_id = q.id and qa.created_at >= now() - interval '12 hours'
      ) then 1 else 0 end recent_penalty,
      case
        when uqm.next_review_at is not null and uqm.next_review_at <= now()
        then extract(epoch from(now() - uqm.next_review_at)) / 86400.0
        else 0
      end overdue_days
    from public.questions q
    left join public.user_question_mastery uqm on uqm.question_id = q.id and uqm.user_id = p_user_id
    where q.lesson_id = p_lesson_id
      and q.is_published = true
      and q.validation_status = 'published'
      and q.type in ('mcq','true_false','fill_blank','matching','hotspot','image','short_answer','translation','clinical_case')
  ), ranked as (
    select c.*,
      row_number() over(
        order by c.priority_group,c.recent_penalty,c.overdue_days desc,c.lapse_count desc,c.mastery_percent,c.last_attempt_at nulls first,random()
      ) rn
    from candidates c
  )
  insert into public.revision_session_questions(session_id,question_id,display_order)
  select v_session_id,r.id,r.rn::integer
  from ranked r
  where r.rn <= v_count
  order by r.rn;

  return v_session_id;
end;
$function$;

create or replace function public.start_subject_revision_v1(
  p_subject_id uuid,
  p_question_count integer default 10
)
returns uuid
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_user_id uuid := auth.uid();
  v_count integer := greatest(5,least(coalesce(p_question_count,10),30));
  v_session uuid;
  v_actual integer;
begin
  if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;

  if not exists(
    select 1
    from public.subjects s
    join public.years y on y.id = s.year_id
    join public.profiles p on p.id = v_user_id
    where s.id = p_subject_id
      and s.is_active = true
      and y.is_active = true
      and (y.number = p.study_year or p.role = 'admin')
  ) then
    raise exception 'Matière indisponible pour ton année';
  end if;

  insert into public.revision_sessions(user_id,mode,question_count,correct_count,xp_earned)
  values(v_user_id,'smart',v_count,0,0)
  returning id into v_session;

  with candidates as (
    select q.id,
      row_number() over(
        order by
          case
            when uqm.next_review_at is not null and uqm.next_review_at <= now() then 0
            when uqm.attempt_count > 0 and uqm.mastery_percent < 60 then 1
            when uqm.question_id is null or uqm.attempt_count = 0 then 2
            else 3
          end,
          coalesce(uqm.mastery_percent,0),
          coalesce(uqm.last_attempt_at,'1970-01-01'::timestamptz),
          random()
      ) rn
    from public.questions q
    join public.chapters c on c.id = q.chapter_id
    left join public.user_question_mastery uqm on uqm.question_id = q.id and uqm.user_id = v_user_id
    where c.subject_id = p_subject_id
      and c.is_active = true
      and q.is_published = true
      and q.validation_status = 'published'
      and q.type in ('mcq','true_false','fill_blank','matching','hotspot','image','short_answer','translation','clinical_case')
  ), picked as (
    select id,rn from candidates where rn <= v_count
  )
  insert into public.revision_session_questions(session_id,question_id,display_order)
  select v_session,id,rn::int from picked order by rn;

  select count(*) into v_actual
  from public.revision_session_questions
  where session_id = v_session;

  if v_actual = 0 then
    delete from public.revision_sessions where id = v_session;
    raise exception 'Aucune question validée disponible dans cette matière';
  end if;

  update public.revision_sessions set question_count = v_actual where id = v_session;
  return v_session;
end;
$function$;
