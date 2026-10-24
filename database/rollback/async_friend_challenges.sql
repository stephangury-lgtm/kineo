drop trigger if exists async_friend_result_notification on public.challenges;
drop trigger if exists async_curriculum_result_notification on public.curriculum_friend_challenges;
drop function if exists public.notify_async_friend_challenge_result_v1();

CREATE OR REPLACE FUNCTION public.finish_friend_challenge_v1(p_challenge_id uuid, p_score integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=auth.uid();
  v_challenge public.challenges%rowtype;
  v_session uuid;
  v_total integer;
  v_answered integer;
  v_correct integer;
  v_score integer;
  v_done boolean;
  v_was_completed boolean;
  v_my_score integer;
  v_opponent_score integer;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  select * into v_challenge from public.challenges where id=p_challenge_id for update;
  if v_challenge.id is null or (v_challenge.challenger_id<>v_uid and v_challenge.challenged_id<>v_uid) then raise exception 'Défi introuvable'; end if;
  if v_challenge.status not in ('in_progress','completed') then raise exception 'Ce défi ne peut pas être terminé'; end if;

  if (v_uid=v_challenge.challenger_id and v_challenge.challenger_score is not null)
     or (v_uid=v_challenge.challenged_id and v_challenge.challenged_score is not null) then
    v_my_score:=case when v_uid=v_challenge.challenger_id then v_challenge.challenger_score else v_challenge.challenged_score end;
    v_opponent_score:=case when v_uid=v_challenge.challenger_id then v_challenge.challenged_score else v_challenge.challenger_score end;
    return jsonb_build_object(
      'completed',v_challenge.status='completed',
      'my_score',v_my_score,
      'opponent_score',v_opponent_score,
      'challenger_score',v_challenge.challenger_score,
      'challenged_score',v_challenge.challenged_score
    );
  end if;

  select rs.id into v_session
  from public.revision_sessions rs
  where rs.challenge_id=p_challenge_id and rs.user_id=v_uid
  order by rs.started_at desc limit 1;
  if v_session is null then raise exception 'Session de défi introuvable'; end if;

  select count(*),count(*) filter(where rsq.answered_at is not null)
  into v_total,v_answered
  from public.revision_session_questions rsq
  where rsq.session_id=v_session;
  if v_total<>10 or v_answered<>10 then raise exception 'Le défi doit contenir 10 réponses validées'; end if;

  select count(*) filter(where qa.is_correct=true) into v_correct
  from public.question_attempts qa
  where qa.session_id=v_session and qa.user_id=v_uid;
  v_score:=round((coalesce(v_correct,0)::numeric/v_total::numeric)*100)::integer;

  if v_uid=v_challenge.challenger_id then
    update public.challenges set challenger_score=v_score where id=p_challenge_id;
  else
    update public.challenges set challenged_score=v_score where id=p_challenge_id;
  end if;

  select * into v_challenge from public.challenges where id=p_challenge_id;
  v_was_completed:=v_challenge.status='completed';
  v_done:=v_challenge.challenger_score is not null and v_challenge.challenged_score is not null;

  if v_done and not v_was_completed then
    update public.challenges set status='completed',completed_at=now() where id=p_challenge_id;
    insert into public.notifications(user_id,type,title,body,data)
    select u,'challenge_completed','Défi terminé 🏁','Les deux scores sont disponibles.',jsonb_build_object('challenge_id',p_challenge_id)
    from (values(v_challenge.challenger_id),(v_challenge.challenged_id)) x(u);
    select * into v_challenge from public.challenges where id=p_challenge_id;
  end if;

  v_my_score:=case when v_uid=v_challenge.challenger_id then v_challenge.challenger_score else v_challenge.challenged_score end;
  v_opponent_score:=case when v_uid=v_challenge.challenger_id then v_challenge.challenged_score else v_challenge.challenger_score end;

  return jsonb_build_object(
    'completed',v_challenge.status='completed',
    'my_score',v_my_score,
    'opponent_score',v_opponent_score,
    'challenger_score',v_challenge.challenger_score,
    'challenged_score',v_challenge.challenged_score
  );
end;
$function$;


CREATE OR REPLACE FUNCTION public.get_curriculum_friend_challenge_questions_v1(p_challenge_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=auth.uid(); v_result jsonb;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  if not exists(select 1 from public.curriculum_friend_challenges c where c.id=p_challenge_id and c.status in ('accepted','in_progress','completed') and (c.challenger_id=v_uid or c.challenged_id=v_uid)) then raise exception 'Défi indisponible'; end if;
  update public.curriculum_friend_challenges set status='in_progress' where id=p_challenge_id and status='accepted';
  select coalesce(jsonb_agg(jsonb_build_object('id',q.id,'question_text',q.question_text,'options',(select jsonb_agg(jsonb_build_object('text',o->>'text')) from jsonb_array_elements(q.options)o),'display_order',cq.display_order) order by cq.display_order),'[]'::jsonb) into v_result
  from public.curriculum_friend_challenge_questions cq join public.curriculum_quiz_questions q on q.id=cq.question_id
  where cq.challenge_id=p_challenge_id
    and q.is_published=true
    and q.validation_status='source_validated'
    and q.question_type='mcq'
    and not exists(select 1 from public.curriculum_friend_challenge_answers a where a.challenge_id=p_challenge_id and a.user_id=v_uid and a.question_id=q.id);
  return v_result;
end;
$function$;


CREATE OR REPLACE FUNCTION public.respond_friend_challenge_v1(p_challenge_id uuid, p_accept boolean)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=auth.uid();
  v_challenger uuid;
  v_status text:=case when p_accept then 'accepted' else 'declined' end;
  v_username text;
  v_count integer;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  select challenger_id into v_challenger
  from public.challenges
  where id=p_challenge_id and challenged_id=v_uid and status='pending';
  if v_challenger is null then raise exception 'Défi introuvable'; end if;

  if p_accept then
    select count(*) into v_count
    from public.challenge_questions cq
    join public.questions q on q.id=cq.question_id
    where cq.challenge_id=p_challenge_id
      and q.is_published=true and q.validation_status='published';
    if v_count<>10 then raise exception 'Ce défi ne contient pas 10 questions valides'; end if;
  end if;

  update public.challenges set status=v_status where id=p_challenge_id;

  select coalesce(username::text,first_name,'Ton ami') into v_username from public.profiles where id=v_uid;
  insert into public.notifications(user_id,type,title,body,data)
  values(
    v_challenger,
    case when p_accept then 'challenge_accepted' else 'challenge_declined' end,
    case when p_accept then 'Défi accepté' else 'Défi refusé' end,
    v_username||case when p_accept then ' a accepté ton défi.' else ' a refusé ton défi.' end,
    jsonb_build_object('challenge_id',p_challenge_id)
  );
  return v_status;
end;
$function$;


CREATE OR REPLACE FUNCTION public.start_friend_challenge_session_v1(p_challenge_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=auth.uid();
  v_challenge public.challenges%rowtype;
  v_session uuid;
  v_count integer;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  select * into v_challenge from public.challenges where id=p_challenge_id;
  if v_challenge.id is null or (v_challenge.challenger_id<>v_uid and v_challenge.challenged_id<>v_uid) then raise exception 'Défi introuvable'; end if;
  if v_challenge.status not in ('accepted','in_progress') then raise exception 'Ce défi ne peut pas encore être joué'; end if;

  select count(*) into v_count from public.challenge_questions cq join public.questions q on q.id=cq.question_id
  where cq.challenge_id=p_challenge_id and q.is_published=true and q.validation_status='published';
  if v_count<>10 then raise exception 'Ce défi ne contient pas 10 questions valides'; end if;

  select id into v_session from public.revision_sessions where challenge_id=p_challenge_id and user_id=v_uid order by started_at desc limit 1;
  if v_session is not null then return v_session; end if;

  insert into public.revision_sessions(user_id,mode,question_count,challenge_id) values(v_uid,'mix',10,p_challenge_id) returning id into v_session;
  insert into public.revision_session_questions(session_id,question_id,display_order)
  select v_session,cq.question_id,cq.display_order from public.challenge_questions cq join public.questions q on q.id=cq.question_id
  where cq.challenge_id=p_challenge_id and q.is_published=true and q.validation_status='published' order by cq.display_order;
  update public.challenges set status='in_progress' where id=p_challenge_id and status='accepted';
  return v_session;
end;
$function$;


CREATE OR REPLACE FUNCTION public.submit_curriculum_friend_challenge_answer_v1(p_challenge_id uuid, p_question_id uuid, p_answer_text text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=auth.uid(); v_row public.curriculum_friend_challenges%rowtype; v_options jsonb; v_correct_text text; v_correct boolean; v_answered integer; v_correct_count integer; v_score integer; v_done boolean; v_progress jsonb; v_badges jsonb;
begin
 if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
 select * into v_row from public.curriculum_friend_challenges where id=p_challenge_id for update;
 if v_row.id is null or v_row.status not in ('accepted','in_progress') or (v_row.challenger_id<>v_uid and v_row.challenged_id<>v_uid) then raise exception 'Défi indisponible'; end if;
 if not exists(select 1 from public.curriculum_friend_challenge_questions where challenge_id=p_challenge_id and question_id=p_question_id) then raise exception 'Question hors défi'; end if;
 if exists(select 1 from public.curriculum_friend_challenge_answers where challenge_id=p_challenge_id and user_id=v_uid and question_id=p_question_id) then raise exception 'Question déjà répondue'; end if;
 select options into v_options from public.curriculum_quiz_questions where id=p_question_id and is_published=true;
 select x->>'text' into v_correct_text from jsonb_array_elements(v_options)x where coalesce((x->>'correct')::boolean,false)=true limit 1;
 v_correct:=p_answer_text=v_correct_text;
 insert into public.curriculum_friend_challenge_answers(challenge_id,user_id,question_id,answer_text,is_correct) values(p_challenge_id,v_uid,p_question_id,p_answer_text,v_correct);
 select count(*),count(*) filter(where is_correct) into v_answered,v_correct_count from public.curriculum_friend_challenge_answers where challenge_id=p_challenge_id and user_id=v_uid;
 if v_answered>=10 then
   v_score:=v_correct_count*10;
   if v_uid=v_row.challenger_id then update public.curriculum_friend_challenges set challenger_score=v_score,status='in_progress' where id=p_challenge_id; else update public.curriculum_friend_challenges set challenged_score=v_score,status='in_progress' where id=p_challenge_id; end if;
   v_progress:=public.update_user_progress_v2(v_uid,30,current_date);
   select * into v_row from public.curriculum_friend_challenges where id=p_challenge_id;
   v_done:=v_row.challenger_score is not null and v_row.challenged_score is not null;
   if v_done then update public.curriculum_friend_challenges set status='completed',completed_at=now() where id=p_challenge_id; end if;
   v_badges:=public.check_and_award_badges_v2();
 end if;
 return jsonb_build_object('correct',v_correct,'correct_answer',v_correct_text,'answered',v_answered,'completed_my_run',v_answered>=10,'score',case when v_answered>=10 then v_score else null end,'challenge_completed',coalesce(v_done,false),'new_badges',coalesce(v_badges->'new_badges','[]'::jsonb));
end;$function$;
