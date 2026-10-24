-- Two independent users, sequential visits, real authenticated RPCs. All fixtures roll back.
begin;
set local statement_timeout='50s';
do $test$
declare
 a uuid:=gen_random_uuid(); b uuid:=gen_random_uuid(); outsider uuid:=gen_random_uuid();
 duel uuid; session_a uuid; session_b uuid; level_id uuid; program text; v_question record;
 result jsonb; questions jsonb; rejected boolean; count_results integer;
begin
 insert into auth.users(id,email,raw_user_meta_data,raw_app_meta_data) values
 (a,'async-a-'||a||'@example.invalid','{}','{}'),
 (b,'async-b-'||b||'@example.invalid','{}','{}'),
 (outsider,'async-c-'||outsider||'@example.invalid','{}','{}');
 update public.profiles set study_year=2,first_name='Async test' where id in (a,b,outsider);

 -- France: A starts, submits and leaves before B accepts or starts a session.
 insert into public.challenges(challenger_id,challenged_id,status) values(a,b,'pending') returning id into duel;
 insert into public.challenge_questions(challenge_id,question_id,display_order)
 select duel,id,row_number() over(order by id) from (select id from public.questions where is_published and validation_status='published' limit 10) pool;
 insert into public.notifications(user_id,type,title,data) values(b,'challenge_received','Async test',jsonb_build_object('challenge_id',duel));
 perform set_config('request.jwt.claim.sub',a::text,true); execute 'set local role authenticated';
 session_a:=public.start_friend_challenge_session_v1(duel);
 if public.start_friend_challenge_session_v1(duel)<>session_a then raise exception 'Duplicate France session'; end if;
 rejected:=false;
 begin perform public.finish_friend_challenge_v1(duel,100); exception when others then rejected:=true; end;
 if not rejected then raise exception 'Incomplete France score accepted'; end if;
 execute 'reset role';
 update public.revision_session_questions set answered_at=now() where session_id=session_a;
 insert into public.question_attempts(user_id,question_id,session_id,is_correct) select a,question_id,session_a,true from public.revision_session_questions where session_id=session_a;
 update public.revision_sessions set completed_at=now() where id=session_a;
 execute 'set local role authenticated'; result:=public.finish_friend_challenge_v1(duel,0); execute 'reset role';
 if (result->>'my_score')::int<>100 or (result->>'completed')::boolean then raise exception 'France pending score not persisted'; end if;
 if (select status from public.challenges where id=duel)<>'pending' then raise exception 'France invitation consumed by sender'; end if;
 if exists(select 1 from public.notifications where type='challenge_completed' and data->>'challenge_id'=duel::text) then raise exception 'France result sent before B'; end if;
 perform set_config('request.jwt.claim.sub',outsider::text,true); execute 'set local role authenticated';
 rejected:=false; begin perform public.start_friend_challenge_session_v1(duel); exception when others then rejected:=true; end;
 if not rejected then raise exception 'Outsider joined France duel'; end if;
 execute 'reset role';
 perform set_config('request.jwt.claim.sub',b::text,true); execute 'set local role authenticated';
 rejected:=false; begin perform public.start_friend_challenge_session_v1(duel); exception when others then rejected:=true; end;
 if not rejected then raise exception 'Recipient played without consent'; end if;
 perform public.respond_friend_challenge_v1(duel,true);
 session_b:=public.start_friend_challenge_session_v1(duel); execute 'reset role';
 update public.revision_session_questions set answered_at=now() where session_id=session_b;
 insert into public.question_attempts(user_id,question_id,session_id,is_correct) select b,question_id,session_b,false from public.revision_session_questions where session_id=session_b;
 execute 'set local role authenticated'; result:=public.finish_friend_challenge_v1(duel,100); perform public.finish_friend_challenge_v1(duel,100); execute 'reset role';
 if not (result->>'completed')::boolean or (result->>'my_score')::int<>0 then raise exception 'France server score or completion incorrect'; end if;
 select count(*) into count_results from public.notifications where type='challenge_completed' and data->>'challenge_id'=duel::text;
 if count_results<>2 then raise exception 'France result notifications missing or duplicated'; end if;
 if not exists(select 1 from public.notifications where user_id=a and type='challenge_completed' and data->>'challenge_id'=duel::text and data->>'outcome'='win' and body like '%100%0%') then raise exception 'France personal result missing'; end if;
 if exists(select 1 from public.notifications where user_id=b and type='challenge_received' and data->>'challenge_id'=duel::text and read_at is null) then raise exception 'Old invitation not superseded'; end if;

 -- Spain and IFSI use the other quiz engine; B remains absent for all ten A answers.
 foreach program in array array['kineo-es','ifsi-fr'] loop
  select u.academic_level_id into level_id from public.curriculum_quiz_questions q
   join public.curriculum_topics t on t.id=q.topic_id join public.curriculum_units u on u.id=t.unit_id
   where u.program_id=program and q.is_published and q.validation_status='source_validated' and q.question_type='mcq'
   group by u.academic_level_id having count(*)>=10 limit 1;
  if level_id is null then raise exception 'Missing validated MCQ fixture for %',program; end if;
  insert into public.curriculum_friend_challenges(program_id,academic_level_id,challenger_id,challenged_id,status) values(program,level_id,a,b,'pending') returning id into duel;
  insert into public.curriculum_friend_challenge_questions(challenge_id,question_id,display_order)
  select duel,id,row_number() over(order by id) from (
   select q.id from public.curriculum_quiz_questions q join public.curriculum_topics t on t.id=q.topic_id join public.curriculum_units u on u.id=t.unit_id
   where u.program_id=program and u.academic_level_id=level_id and q.is_published and q.validation_status='source_validated' and q.question_type='mcq' limit 10
  ) pool;
  insert into public.notifications(user_id,type,title,data) values(b,'challenge_received','Async test',jsonb_build_object('curriculum_challenge_id',duel));
  perform set_config('request.jwt.claim.sub',outsider::text,true); execute 'set local role authenticated';
  rejected:=false; begin perform public.get_curriculum_friend_challenge_questions_v1(duel); exception when others then rejected:=true; end;
  if not rejected then raise exception 'Outsider read curriculum duel'; end if; execute 'reset role';
  perform set_config('request.jwt.claim.sub',b::text,true); execute 'set local role authenticated';
  rejected:=false; begin perform public.get_curriculum_friend_challenge_questions_v1(duel); exception when others then rejected:=true; end;
  if not rejected then raise exception 'Curriculum recipient played before consent'; end if; execute 'reset role';
  perform set_config('request.jwt.claim.sub',a::text,true); execute 'set local role authenticated';
  questions:=public.get_curriculum_friend_challenge_questions_v1(duel);
  if jsonb_array_length(questions)<>10 then raise exception 'Sender cannot start pending curriculum duel'; end if;
  if exists(select 1 from jsonb_array_elements(questions) item,jsonb_array_elements(item->'options') option where option ? 'correct') then raise exception 'Correct answers leaked'; end if;
  execute 'reset role';
  for v_question in select cq.question_id,(select o->>'text' from jsonb_array_elements(qq.options)o where coalesce((o->>'correct')::boolean,false) limit 1) as correct_text
   from public.curriculum_friend_challenge_questions cq join public.curriculum_quiz_questions qq on qq.id=cq.question_id where cq.challenge_id=duel order by cq.display_order loop
   execute 'set local role authenticated'; result:=public.submit_curriculum_friend_challenge_answer_v1(duel,v_question.question_id,v_question.correct_text); execute 'reset role';
  end loop;
  if (result->>'score')::int<>100 or (result->>'challenge_completed')::boolean then raise exception 'Curriculum sender score not retained'; end if;
  if (select status from public.curriculum_friend_challenges where id=duel)<>'pending' then raise exception 'Curriculum invitation consumed'; end if;
  if exists(select 1 from public.notifications where type='challenge_completed' and data->>'curriculum_challenge_id'=duel::text) then raise exception 'Premature curriculum result'; end if;
  perform set_config('request.jwt.claim.sub',b::text,true); execute 'set local role authenticated';
  perform public.respond_curriculum_friend_challenge_v1(duel,true); perform public.get_curriculum_friend_challenge_questions_v1(duel); execute 'reset role';
  for v_question in select question_id from public.curriculum_friend_challenge_questions where challenge_id=duel order by display_order loop
   execute 'set local role authenticated'; result:=public.submit_curriculum_friend_challenge_answer_v1(duel,v_question.question_id,'__wrong_fixture_answer__'); execute 'reset role';
  end loop;
  if not (result->>'challenge_completed')::boolean then raise exception 'Curriculum duel did not complete'; end if;
  select count(*) into count_results from public.notifications where type='challenge_completed' and data->>'curriculum_challenge_id'=duel::text;
  if count_results<>2 then raise exception 'Curriculum result notifications missing or duplicated'; end if;
  if not exists(select 1 from public.notifications where user_id=b and type='challenge_completed' and data->>'curriculum_challenge_id'=duel::text and data->>'outcome'='loss' and (data->>'my_score')::int=0 and (data->>'opponent_score')::int=100) then raise exception 'Curriculum personal result incorrect'; end if;
 end loop;
end;
$test$;
rollback;
