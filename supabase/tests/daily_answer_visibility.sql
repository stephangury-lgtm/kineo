begin;
set local statement_timeout='25s';
do $test$
declare u uuid:=gen_random_uuid(); result jsonb; question jsonb; ignored jsonb;
begin
 insert into auth.users(id,email,raw_user_meta_data,raw_app_meta_data)
 values(u,'daily-security-'||u||'@example.invalid','{}','{}');
 perform set_config('request.jwt.claim.sub',u::text,true);
 execute 'set local role authenticated';
 perform public.setup_student_profile_v1('ifsi-fr','S1','Audit','daily_'||substr(u::text,1,8));
 result:=public.get_curriculum_daily_challenge_v1('ifsi-fr');
 if jsonb_array_length(result->'questions')<>5 then raise exception 'Missing daily questions'; end if;
 if exists(select 1 from jsonb_array_elements(result->'questions') q where q->'explanation'<>'null'::jsonb
  or exists(select 1 from jsonb_array_elements(q->'options') o where o ? 'correct')) then raise exception 'Daily challenge exposes explanations or corrections before submission'; end if;
 for question in select value from jsonb_array_elements(result->'questions') loop
  ignored:=public.submit_curriculum_daily_answer_v1('ifsi-fr',(question->>'id')::uuid,'__deliberately_wrong_fixture_answer__');
 end loop;
 result:=public.get_curriculum_daily_challenge_v1('ifsi-fr');
 if not (result->>'completed')::boolean then raise exception 'Daily challenge did not finish'; end if;
 if not exists(select 1 from jsonb_array_elements(result->'questions') q where nullif(q->>'explanation','') is not null) then raise exception 'Completed challenge lost explanations'; end if;
 execute 'reset role';
end;
$test$;
rollback;

