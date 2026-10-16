-- Real database roles and RPCs, synthetic identities, all writes rolled back.
begin;
set local statement_timeout='30s';
do $tests$
declare p record; a uuid; b uuid; outsider uuid; friendship uuid; challenge uuid;
 lesson uuid; session_id uuid; topic uuid; q record; answer jsonb; result jsonb;
 rejected boolean; answered integer; xp_before integer;
begin
 for p in select * from (values('kineo-fr','K2'),('kineo-es','ES1'),('ifsi-fr','S1')) x(program,level_code) loop
  a:=gen_random_uuid(); b:=gen_random_uuid(); outsider:=gen_random_uuid();
  insert into auth.users(id,email,raw_user_meta_data,raw_app_meta_data)
  select id,'staging-'||id||'@example.invalid','{}','{}' from unnest(array[a,b,outsider]) id;
  perform set_config('request.jwt.claim.sub',a::text,true);
  execute 'set local role authenticated';
  perform public.setup_student_profile_v1(p.program,p.level_code,'Test A','test_'||substr(a::text,1,8));
  perform set_config('request.jwt.claim.sub',b::text,true);
  perform public.setup_student_profile_v1(p.program,p.level_code,'Test B','test_'||substr(b::text,1,8));
  perform set_config('request.jwt.claim.sub',a::text,true);
  friendship:=public.send_friend_request_v1(b);
  perform set_config('request.jwt.claim.sub',outsider::text,true);
  rejected:=false;
  begin perform public.respond_friend_request_v1(friendship,true); exception when others then rejected:=true; end;
  if not rejected then raise exception 'Outsider accepted invitation'; end if;
  perform set_config('request.jwt.claim.sub',b::text,true);
  if public.respond_friend_request_v1(friendship,true)<>'accepted' then raise exception 'Invitation not accepted'; end if;
  perform set_config('request.jwt.claim.sub',a::text,true);
  if p.program='kineo-fr' then
   challenge:=public.create_friend_challenge_v1(b);
   select l.id into lesson from public.lessons l join public.chapters c on c.id=l.chapter_id
   join public.subjects s on s.id=c.subject_id join public.years y on y.id=s.year_id where y.number=2 limit 1;
   perform public.save_lesson_note_v1(lesson,'Private synthetic note');
   perform public.toggle_lesson_favorite_v1(lesson);
   session_id:=public.start_lesson_quiz_v2(lesson,10);
   if public.get_active_revision_session_v1() is null then raise exception 'No resumable session'; end if;
   perform set_config('request.jwt.claim.sub',b::text,true);
   rejected:=false;
   begin perform public.get_quiz_questions_v4(session_id); exception when others then rejected:=true; end;
   if not rejected then raise exception 'Other account opened quiz'; end if;
   perform set_config('request.jwt.claim.sub',a::text,true);
   answered:=0;
   for q in select * from public.get_quiz_questions_v4(session_id) loop
    if q.explanation is not null or exists(select 1 from jsonb_array_elements(q.question_options) o where o ? 'is_correct') then raise exception 'France leaked corrections'; end if;
    answer:=jsonb_build_object('option_id',q.question_options->0->>'id');
    result:=public.submit_quiz_answer_v5(session_id,q.id,answer,1500);
    if nullif(result#>>'{correction,explanation}','') is null then raise exception 'Missing correction'; end if;
    answered:=answered+1;
   end loop;
   if answered<>10 then raise exception 'Wrong quiz length'; end if;
   result:=public.finish_quiz_session_v2(session_id,current_date);
   if (result->>'xp_earned')::integer<=0 or (result->>'current_streak')::integer<1 then raise exception 'Missing XP/streak'; end if;
   rejected:=false;
   begin perform public.finish_quiz_session_v2(session_id,current_date); exception when others then rejected:=true; end;
   if not rejected then raise exception 'Quiz finished twice'; end if;
  else
   challenge:=public.create_curriculum_friend_challenge_v1(b,p.program);
   perform set_config('request.jwt.claim.sub',outsider::text,true);
   rejected:=false;
   begin perform public.respond_curriculum_friend_challenge_v1(challenge,true); exception when others then rejected:=true; end;
   if not rejected then raise exception 'Outsider accepted challenge'; end if;
   perform set_config('request.jwt.claim.sub',b::text,true);
   if public.respond_curriculum_friend_challenge_v1(challenge,true)<>'accepted' then raise exception 'Challenge acceptance failed'; end if;
   perform set_config('request.jwt.claim.sub',a::text,true);
   select t.id into topic from public.curriculum_topics t join public.curriculum_units u on u.id=t.unit_id where u.program_id=p.program limit 1;
   answered:=0;
   for q in select * from public.get_curriculum_quiz_questions_v1(array[topic]) loop
    answer:=jsonb_build_object('text',q.options->0->>'text');
    result:=public.submit_curriculum_topic_answer_v3(q.id,answer);
    if (result->>'xp_earned')::integer<=0 then raise exception 'Missing curriculum XP'; end if;
    result:=public.submit_curriculum_topic_answer_v3(q.id,answer);
    if (result->>'xp_earned')::integer<>0 then raise exception 'Repeat curriculum XP'; end if;
    answered:=answered+1;
   end loop;
   if answered<1 then raise exception 'No curriculum questions'; end if;
   result:=public.get_curriculum_stats_v1(p.program,30);
   if result is null then raise exception 'Missing curriculum statistics'; end if;
  end if;
  if public.get_gamification_summary_v2() is null then raise exception 'Missing progress summary'; end if;
  execute 'reset role';
 end loop;
end;
$tests$;
rollback;
select 'three curricula: invitations, challenge creation, quiz grading, XP, streak, notes and ownership passed' as staging_result;
