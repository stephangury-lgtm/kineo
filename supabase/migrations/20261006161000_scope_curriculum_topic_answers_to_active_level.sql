-- Enforce the student's active academic level and curriculum version when answering
-- a multi-curriculum topic question. Admin users keep cross-level test access.

create or replace function public.submit_curriculum_topic_answer_v2(p_question_id uuid, p_answer jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_uid uuid:=auth.uid();
  v_q public.curriculum_quiz_questions%rowtype;
  v_program_id text;
  v_level_id uuid;
  v_curriculum_version text;
  v_role text;
  v_correct boolean:=false;
  v_correct_text text;
  v_answer_text text:=coalesce(p_answer->>'text','');
  v_correct_hotspot text;
  v_expected_pairs jsonb:='[]'::jsonb;
  v_given_pairs jsonb:='[]'::jsonb;
  v_xp integer;
  v_total integer;
  v_answered integer;
  v_correct_total integer;
  v_completed boolean:=false;
  v_progress jsonb;
  v_badges jsonb;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;

  select q.* into v_q
  from public.curriculum_quiz_questions q
  where q.id=p_question_id and q.is_published=true and q.validation_status='source_validated';
  if v_q.id is null then raise exception 'Question indisponible'; end if;

  select u.program_id,u.academic_level_id,coalesce(u.curriculum_version,'default')
    into v_program_id,v_level_id,v_curriculum_version
  from public.curriculum_topics t
  join public.curriculum_units u on u.id=t.unit_id
  where t.id=v_q.topic_id and t.is_active=true and u.is_active=true;
  if v_program_id is null or v_level_id is null then raise exception 'Question hors cursus actif'; end if;

  select p.role into v_role from public.profiles p where p.id=v_uid;
  if coalesce(v_role,'')<>'admin' and not exists(
    select 1 from public.profile_programs pp
    where pp.user_id=v_uid
      and pp.program_id=v_program_id
      and pp.academic_level_id=v_level_id
      and coalesce(pp.curriculum_version,'default')=v_curriculum_version
  ) then raise exception 'Question hors niveau ou référentiel actif'; end if;

  if v_q.question_type in ('mcq','clinical_case') and jsonb_array_length(coalesce(v_q.options,'[]'::jsonb))>0 then
    select x->>'text' into v_correct_text
    from jsonb_array_elements(v_q.options) x
    where coalesce((x->>'correct')::boolean,false)=true limit 1;
    v_correct:=public.normalize_curriculum_answer_v1(v_answer_text)=public.normalize_curriculum_answer_v1(v_correct_text);
  elsif v_q.question_type='fill_blank' then
    select a.value #>> '{}' into v_correct_text
    from jsonb_array_elements(coalesce(v_q.accepted_answers,'[]'::jsonb)) a(value)
    where public.normalize_curriculum_answer_v1(a.value #>> '{}')=public.normalize_curriculum_answer_v1(v_answer_text)
    limit 1;
    v_correct:=v_correct_text is not null;
    if not v_correct then
      select a.value #>> '{}' into v_correct_text from jsonb_array_elements(coalesce(v_q.accepted_answers,'[]'::jsonb)) a(value) limit 1;
    end if;
  elsif v_q.question_type='visual_hotspot' then
    v_answer_text:=coalesce(p_answer->>'hotspot_id',p_answer->>'text','');
    select h->>'id' into v_correct_hotspot
    from jsonb_array_elements(coalesce(v_q.metadata->'hotspots','[]'::jsonb)) h
    where coalesce((h->>'correct')::boolean,false)=true limit 1;
    v_correct:=v_answer_text=v_correct_hotspot and v_correct_hotspot is not null;
  elsif v_q.question_type='matching' then
    v_expected_pairs:=coalesce(v_q.metadata->'pairs','[]'::jsonb);
    v_given_pairs:=coalesce(p_answer->'pairs','[]'::jsonb);
    v_correct:=jsonb_array_length(v_expected_pairs)>0
      and jsonb_array_length(v_expected_pairs)=jsonb_array_length(v_given_pairs)
      and not exists(
        select 1 from jsonb_array_elements(v_expected_pairs) e
        where not exists(
          select 1 from jsonb_array_elements(v_given_pairs) g
          where public.normalize_curriculum_answer_v1(g->>'left')=public.normalize_curriculum_answer_v1(e->>'left')
            and public.normalize_curriculum_answer_v1(g->>'right')=public.normalize_curriculum_answer_v1(e->>'right')
        )
      );
    v_answer_text:=v_given_pairs::text;
  else
    raise exception 'Format de question non pris en charge: %',v_q.question_type;
  end if;

  v_xp:=case when v_correct then 10 else 2 end;
  insert into public.curriculum_question_attempts(user_id,question_id,topic_id,answer_text,is_correct,xp_earned)
  values(v_uid,v_q.id,v_q.topic_id,coalesce(nullif(v_answer_text,''),p_answer::text),v_correct,v_xp);
  v_progress:=public.update_user_progress_v2(v_uid,v_xp,current_date);

  select count(*) into v_total
  from public.curriculum_quiz_questions
  where topic_id=v_q.topic_id and is_published=true and validation_status='source_validated';

  select count(distinct question_id),count(distinct question_id) filter(where is_correct=true)
    into v_answered,v_correct_total
  from public.curriculum_question_attempts
  where user_id=v_uid and topic_id=v_q.topic_id;

  if v_total>0 and v_answered>=v_total then
    insert into public.curriculum_topic_completions(user_id,topic_id,score_percent,xp_earned)
    values(v_uid,v_q.topic_id,round(100.0*v_correct_total/greatest(v_total,1))::integer,20)
    on conflict(user_id,topic_id) do nothing;
    if found then v_progress:=public.update_user_progress_v2(v_uid,20,current_date); end if;
    v_completed:=true;
  end if;

  v_badges:=public.check_and_award_badges_v2();
  return jsonb_build_object(
    'correct',v_correct,
    'correct_answer',v_correct_text,
    'correct_hotspot_id',v_correct_hotspot,
    'correct_pairs',v_expected_pairs,
    'xp_earned',v_xp,
    'topic_completed',v_completed,
    'xp_total',v_progress->'xp_total',
    'current_streak',v_progress->'current_streak',
    'new_badges',v_badges->'new_badges'
  );
end;
$function$;
