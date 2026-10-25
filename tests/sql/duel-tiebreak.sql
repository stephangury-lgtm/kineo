begin;
do $test$
declare users uuid[];a uuid;b uuid; outsider uuid;program text;cid uuid;question_id uuid;level_id uuid;res jsonb;correct text;wrong text;first_question uuid;denied boolean;notices integer;
begin
 select array_agg(id) into users from(select id from public.profiles order by id limit 3)s;
 a:=users[1];b:=users[2];outsider:=users[3];
 if array_length(users,1)<3 then raise exception 'Three existing profiles are required for transaction-only fixtures'; end if;
 if exists(select 1 from public.friendships where(requester_id=a and addressee_id=b)or(requester_id=b and addressee_id=a)) then
  update public.friendships set status='accepted' where(requester_id=a and addressee_id=b)or(requester_id=b and addressee_id=a);
 else insert into public.friendships(requester_id,addressee_id,status)values(a,b,'accepted');end if;
 foreach program in array array['kineo-fr','kineo-es','ifsi-fr'] loop
  cid:=gen_random_uuid();question_id:=null;
  if program='kineo-fr' then
   select q.id into question_id from public.questions q join public.chapters c on c.id=q.chapter_id join public.subjects s on s.id=c.subject_id join public.years y on y.id=s.year_id where q.is_published and q.validation_status='published' and q.type='mcq' and y.number=2 limit 1;
   insert into public.challenges(id,challenger_id,challenged_id,status,challenger_score,challenged_score)values(cid,a,b,'completed',100,100);
   insert into public.challenge_questions(challenge_id,question_id,display_order)values(cid,question_id,1);
  else
   select q.id,u.academic_level_id into question_id,level_id from public.curriculum_quiz_questions q join public.curriculum_topics t on t.id=q.topic_id join public.curriculum_units u on u.id=t.unit_id where u.program_id=program and u.is_active and t.is_active and q.is_published and q.validation_status='source_validated' and q.question_type='mcq' order by q.created_at limit 1;
   insert into public.curriculum_friend_challenges(id,program_id,academic_level_id,challenger_id,challenged_id,status,challenger_score,challenged_score)values(cid,program,level_id,a,b,'completed',100,100);
   insert into public.curriculum_friend_challenge_questions(challenge_id,question_id,display_order)values(cid,question_id,1);
  end if;
  if question_id is null then raise exception 'Missing published fixture question for %',program;end if;
  perform set_config('request.jwt.claim.sub',a::text,true);
  res:=public.duel_tiebreak_v1(cid,program);
  if res->>'outcome'<>'waiting' or res->>'correct_answer' is not null or res->>'my_correct' is not null then raise exception 'Answer leaked before both participants play';end if;
  select r.correct_key,r.question_id into correct,first_question from duel_private.tiebreak_rounds r where r.challenge_id=cid;
  select o->>'id' into wrong from jsonb_array_elements(res->'options')o where o->>'id'<>correct limit 1;
  res:=public.duel_tiebreak_v1(cid,program,1,correct);
  if res->>'outcome'<>'waiting' or res->>'correct_answer' is not null or res->>'my_correct' is not null then raise exception 'First answer disclosed before opponent plays';end if;
  perform set_config('request.jwt.claim.sub',b::text,true);
  res:=public.duel_tiebreak_v1(cid,program,1,wrong);
  if res->>'outcome'<>'loss' or not(res->>'round_closed')::boolean then raise exception 'Second participant result incorrect';end if;
  select count(*) into notices from public.notifications where data->>'challenge_id'=cid::text;
  perform set_config('request.jwt.claim.sub',a::text,true);
  res:=public.duel_tiebreak_v1(cid,program,1,correct);
  if res->>'outcome'<>'win' then raise exception 'Winner result incorrect';end if;
  if notices<>(select count(*) from public.notifications where data->>'challenge_id'=cid::text)then raise exception 'Retry duplicated notifications';end if;
  denied:=false;begin perform public.duel_tiebreak_v1(cid,program,1,wrong);exception when others then denied:=true;end;
  if not denied then raise exception 'An answer could be changed after submission';end if;
  perform set_config('request.jwt.claim.sub',outsider::text,true);
  denied:=false;begin perform public.duel_tiebreak_v1(cid,program);exception when others then denied:=true;end;
  if not denied then raise exception 'Non-participant entered private duel';end if;
  if public.get_duel_tiebreak_results_v1(program)<>'[]'::jsonb then raise exception 'Non-participant saw private result';end if;
  delete from duel_private.tiebreak_rounds where challenge_id=cid;
  perform set_config('request.jwt.claim.sub',a::text,true);
  res:=public.duel_tiebreak_v1(cid,program);
  select r.correct_key,r.question_id into correct,first_question from duel_private.tiebreak_rounds r where r.challenge_id=cid;
  select o->>'id' into wrong from jsonb_array_elements(res->'options')o where o->>'id'<>correct limit 1;
  perform public.duel_tiebreak_v1(cid,program,1,wrong);
  perform set_config('request.jwt.claim.sub',b::text,true);
  res:=public.duel_tiebreak_v1(cid,program,1,wrong);
  if res->>'outcome'<>'draw' or not(res->>'can_next')::boolean then raise exception 'Identical outcomes must allow another round';end if;
  res:=public.duel_tiebreak_v1(cid,program,null,null,true);
  if(res->>'round')::integer<>2 then raise exception 'Next round did not start';end if;
  if exists(select 1 from duel_private.tiebreak_rounds r where r.challenge_id=cid and r.round=2 and r.question_id=first_question) then raise exception 'A question was repeated';end if;
  if has_function_privilege('anon','public.duel_tiebreak_v1(uuid,text,integer,text,boolean)','EXECUTE') then raise exception 'Anonymous endpoint access';end if;
 end loop;
end;$test$;
select 'All three curricula: private questions, asynchronous results, immutable answers, retries and new rounds verified' as result;
rollback;
