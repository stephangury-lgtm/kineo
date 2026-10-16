begin;
set local statement_timeout='30s';
do $tests$
declare p record; a uuid; b uuid; participant uuid; friendship uuid; challenge uuid;
 session_id uuid; q record; question jsonb; result jsonb; before_xp integer; rejected boolean;
begin
 for p in select * from (values('kineo-fr','K2'),('kineo-es','ES1'),('ifsi-fr','S1')) x(program,level_code) loop
  a:=gen_random_uuid();b:=gen_random_uuid();
  insert into auth.users(id,email,raw_user_meta_data,raw_app_meta_data)
  select id,'duel-'||id||'@example.invalid','{}','{}' from unnest(array[a,b]) id;
  execute 'set local role authenticated';
  foreach participant in array array[a,b] loop
   perform set_config('request.jwt.claim.sub',participant::text,true);
   perform public.setup_student_profile_v1(p.program,p.level_code,'Duel test','duel_'||substr(participant::text,1,8));
  end loop;
  perform set_config('request.jwt.claim.sub',a::text,true);
  friendship:=public.send_friend_request_v1(b);
  perform set_config('request.jwt.claim.sub',b::text,true);
  perform public.respond_friend_request_v1(friendship,true);
  perform set_config('request.jwt.claim.sub',a::text,true);
  if p.program='kineo-fr' then
   challenge:=public.create_friend_challenge_v1(b);
   perform set_config('request.jwt.claim.sub',b::text,true);
   perform public.respond_friend_challenge_v1(challenge,true);
  else
   challenge:=public.create_curriculum_friend_challenge_v1(b,p.program);
   perform set_config('request.jwt.claim.sub',b::text,true);
   perform public.respond_curriculum_friend_challenge_v1(challenge,true);
  end if;
  foreach participant in array array[a,b] loop
   perform set_config('request.jwt.claim.sub',participant::text,true);
   if p.program='kineo-fr' then
    session_id:=public.start_friend_challenge_session_v1(challenge);
    for q in select * from public.get_quiz_questions_v4(session_id) loop
     perform public.submit_quiz_answer_v5(session_id,q.id,jsonb_build_object('option_id',q.question_options->0->>'id'),1000);
    end loop;
    perform public.finish_quiz_session_v2(session_id,current_date);
    result:=public.finish_friend_challenge_v1(challenge,0);
    if (result->>'my_score')::integer<>100 then raise exception 'Server did not calculate France score'; end if;
   else
    for question in select value from jsonb_array_elements(public.get_curriculum_friend_challenge_questions_v1(challenge)) loop
     result:=public.submit_curriculum_friend_challenge_answer_v1(challenge,(question->>'id')::uuid,question#>>'{options,0,text}');
    end loop;
    if (result->>'score')::integer<>100 then raise exception 'Wrong curriculum score'; end if;
   end if;
  end loop;
  if p.program='kineo-fr' then
   if not (result->>'completed')::boolean then raise exception 'France duel not completed'; end if;
   select xp into before_xp from public.profiles where id=b;
   perform public.finish_friend_challenge_v1(challenge,1000000);
   if (select xp from public.profiles where id=b)<>before_xp then raise exception 'Repeated duel XP'; end if;
  else
   if not (result->>'challenge_completed')::boolean then raise exception 'Curriculum duel not completed'; end if;
   rejected:=false;
   begin perform public.submit_curriculum_friend_challenge_answer_v1(challenge,(question->>'id')::uuid,'forged'); exception when others then rejected:=true; end;
   if not rejected then raise exception 'Completed duel accepts another answer'; end if;
  end if;
  execute 'reset role';
 end loop;
end;
$tests$;
rollback;
select 'complete two-player duels passed for France, Spain and IFSI' as result;
