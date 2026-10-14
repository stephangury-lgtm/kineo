-- Run in one transaction with the audit migrations, then ROLLBACK.
-- Fake identities are generated in this transaction, never existing accounts.
begin;
set local statement_timeout = '20s';
do $tests$
declare
  v_uid uuid;
  v_result jsonb;
  v_case record;
  v_topic uuid;
  v_future_topic uuid;
  v_question uuid;
  v_questions jsonb;
  v_rejected boolean;
begin
  if has_function_privilege('anon','public.setup_student_profile_v1(text,text,text,text)','execute')
    or has_function_privilege('anon','public.get_curriculum_quiz_questions_v1(uuid[])','execute')
    or has_function_privilege('anon','public.submit_curriculum_topic_answer_v3(uuid,jsonb)','execute') then
    raise exception 'Anonymous API execution is still granted';
  end if;
  if has_column_privilege('authenticated','public.curriculum_quiz_questions','options','select')
    or has_column_privilege('authenticated','public.curriculum_quiz_questions','accepted_answers','select')
    or has_column_privilege('authenticated','public.curriculum_quiz_questions','metadata','select') then
    raise exception 'Raw corrections are still readable';
  end if;

  for v_case in select * from (values
    ('ifsi-fr','S1',1),('ifsi-fr','S2',1),('kineo-es','ES1',1),('kineo-fr','K2',2)
  ) cases(program,level_code,year_number) loop
    v_uid := gen_random_uuid();
    insert into auth.users(id,email,raw_user_meta_data,raw_app_meta_data)
    values(v_uid,'audit-'||v_uid::text||'@example.invalid','{}','{}');
    perform set_config('request.jwt.claim.sub',v_uid::text,true);
    v_result := public.setup_student_profile_v1(v_case.program,v_case.level_code,'Audit','audit_'||substr(v_uid::text,1,8));
    if (v_result->>'study_year')::integer <> v_case.year_number then raise exception 'Wrong study year for %/%',v_case.program,v_case.level_code; end if;
    if not exists(select 1 from public.profile_programs pp join public.academic_levels al on al.id=pp.academic_level_id
      where pp.user_id=v_uid and pp.is_primary and pp.program_id=v_case.program and al.code=v_case.level_code) then
      raise exception 'Assignment missing after setup';
    end if;
    -- Retry is idempotent and profile editing accepts the first-year value.
    perform public.setup_student_profile_v1(v_case.program,v_case.level_code,'Audit','audit_'||substr(v_uid::text,1,8));
    perform public.update_study_profile_v1('Audit edited','audit_'||substr(v_uid::text,1,8),v_case.year_number);
    if (select count(*) from public.profile_programs where user_id=v_uid)<>1 then raise exception 'Duplicate assignment'; end if;
  end loop;

  v_uid := gen_random_uuid();
  insert into auth.users(id,email,raw_user_meta_data,raw_app_meta_data)
  values(v_uid,'audit-'||v_uid::text||'@example.invalid','{}','{}');
  perform set_config('request.jwt.claim.sub',v_uid::text,true);
  v_rejected := false;
  begin
    perform public.setup_student_profile_v1('ifsi-fr','S1','Must not persist','invalid username!');
  exception when others then v_rejected := true;
  end;
  if not v_rejected or exists(select 1 from public.profile_programs where user_id=v_uid)
    or exists(select 1 from public.profiles where id=v_uid and first_name='Must not persist') then
    raise exception 'Failed setup left partial state';
  end if;
  perform public.setup_student_profile_v1('ifsi-fr','S1','Audit','audit_'||substr(v_uid::text,1,8));
  v_rejected := false;
  begin
    perform public.setup_student_profile_v1('kineo-es','ES1','Must not persist','audit_'||substr(v_uid::text,1,8));
  exception when others then v_rejected := true;
  end;
  if not v_rejected then raise exception 'Setup changed the assigned curriculum'; end if;

  select t.id,q.id into v_topic,v_question from public.curriculum_topics t
    join public.curriculum_units u on u.id=t.unit_id
    join public.academic_levels al on al.id=u.academic_level_id
    join public.curriculum_quiz_questions q on q.topic_id=t.id
  where u.program_id='ifsi-fr' and u.curriculum_version='2009' and al.code='S1'
    and t.is_active and u.is_active and q.is_published and q.validation_status='source_validated' and q.question_type='mcq'
  limit 1;
  select t.id into v_future_topic from public.curriculum_topics t
    join public.curriculum_units u on u.id=t.unit_id
    join public.academic_levels al on al.id=u.academic_level_id
  where u.program_id='ifsi-fr' and al.code='S6' limit 1;
  if v_topic is null or v_question is null then raise exception 'Missing S1 test content'; end if;
  select jsonb_agg(to_jsonb(q)) into v_questions
    from public.get_curriculum_quiz_questions_v1(array[v_topic,v_future_topic]) q;
  if v_questions is null or jsonb_array_length(v_questions)=0 then raise exception 'Safe API returned no accessible questions'; end if;
  if exists(select 1 from jsonb_array_elements(v_questions) q
    where q->>'topic_id'=v_future_topic::text or q->'explanation'<>'null'::jsonb
      or q ? 'accepted_answers' or (q->'metadata') ? 'pairs'
      or exists(select 1 from jsonb_array_elements(q->'options') o where o ? 'correct')
      or exists(select 1 from jsonb_array_elements(coalesce(q->'metadata'->'hotspots','[]'::jsonb)) h where h ? 'correct')) then
    raise exception 'Safe API leaks future content or corrections';
  end if;
  v_result := public.submit_curriculum_topic_answer_v3(v_question,jsonb_build_object('text','__audit_wrong_answer__'));
  if not (v_result ? 'explanation') or nullif(v_result->>'explanation','') is null then raise exception 'Explanation not returned after submission'; end if;
  v_result := public.submit_curriculum_topic_answer_v3(v_question,jsonb_build_object('text','__audit_wrong_answer__'));
  if (v_result->>'xp_earned')::integer<>0 then raise exception 'Repeated answer awards XP'; end if;
  perform set_config('audit.test.uid',v_uid::text,true);
  perform set_config('audit.test.topic',v_topic::text,true);
end;
$tests$;

-- Prove the new API works with real student-role grants, not just postgres.
set local role authenticated;
do $student$
declare v_count integer; v_rejected boolean := false;
begin
  perform set_config('request.jwt.claim.sub',current_setting('audit.test.uid'),true);
  select count(*) into v_count from public.get_curriculum_quiz_questions_v1(array[current_setting('audit.test.topic')::uuid]);
  if v_count=0 then raise exception 'Student role cannot use safe API'; end if;
  begin
    perform options from public.curriculum_quiz_questions limit 1;
  exception when insufficient_privilege then v_rejected := true;
  end;
  if not v_rejected then raise exception 'Student role can still read raw answers'; end if;
end;
$student$;
reset role;
rollback;
select 'atomic setup, first years, idempotency, scope, answer hiding, XP and student-role permissions passed' as audit_test_result;
