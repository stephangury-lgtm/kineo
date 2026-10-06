-- Scope multi-curriculum progress to the student's active level and curriculum version.
-- Prevents ES1-ES4 and IFSI 2009/2026 from being mixed in the same progress percentage.

create or replace function public.get_curriculum_progress_v1(p_program_id text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_uid uuid := auth.uid();
  v_level_id uuid;
  v_version text;
  v_topics integer := 0;
  v_completed integer := 0;
  v_questions integer := 0;
  v_answered integer := 0;
begin
  if v_uid is null then
    raise exception 'Utilisateur non authentifié';
  end if;

  select pp.academic_level_id, coalesce(pp.curriculum_version, 'default')
    into v_level_id, v_version
  from public.profile_programs pp
  where pp.user_id = v_uid
    and pp.program_id = p_program_id
  order by pp.is_primary desc, pp.updated_at desc
  limit 1;

  if v_level_id is null then
    return jsonb_build_object(
      'topics_total', 0,
      'topics_completed', 0,
      'questions_total', 0,
      'questions_answered', 0,
      'coverage_percent', 0,
      'completion_percent', 0,
      'academic_level_id', null,
      'curriculum_version', v_version
    );
  end if;

  select count(distinct t.id), count(distinct q.id)
    into v_topics, v_questions
  from public.curriculum_units u
  join public.curriculum_topics t
    on t.unit_id = u.id
   and t.is_active = true
  left join public.curriculum_quiz_questions q
    on q.topic_id = t.id
   and q.is_published = true
   and q.validation_status = 'source_validated'
  where u.program_id = p_program_id
    and u.academic_level_id = v_level_id
    and u.curriculum_version = v_version
    and u.is_active = true;

  select count(distinct c.topic_id)
    into v_completed
  from public.curriculum_topic_completions c
  join public.curriculum_topics t on t.id = c.topic_id
  join public.curriculum_units u on u.id = t.unit_id
  where c.user_id = v_uid
    and u.program_id = p_program_id
    and u.academic_level_id = v_level_id
    and u.curriculum_version = v_version
    and u.is_active = true
    and t.is_active = true;

  select count(distinct a.question_id)
    into v_answered
  from public.curriculum_question_attempts a
  join public.curriculum_quiz_questions q on q.id = a.question_id
  join public.curriculum_topics t on t.id = q.topic_id
  join public.curriculum_units u on u.id = t.unit_id
  where a.user_id = v_uid
    and u.program_id = p_program_id
    and u.academic_level_id = v_level_id
    and u.curriculum_version = v_version
    and u.is_active = true
    and t.is_active = true
    and q.is_published = true
    and q.validation_status = 'source_validated';

  return jsonb_build_object(
    'topics_total', v_topics,
    'topics_completed', v_completed,
    'questions_total', v_questions,
    'questions_answered', v_answered,
    'coverage_percent', case when v_questions = 0 then 0 else round(100.0 * v_answered / v_questions)::integer end,
    'completion_percent', case when v_topics = 0 then 0 else round(100.0 * v_completed / v_topics)::integer end,
    'academic_level_id', v_level_id,
    'curriculum_version', v_version
  );
end;
$function$;
