-- Prevent IFSI 2009/2026 and semester mixing in daily challenges and friend duels.

create or replace function public.get_curriculum_daily_challenge_v1(p_program_id text)
returns jsonb
language plpgsql
security definer
set search_path=''
as $$
declare
  v_uid uuid:=auth.uid();
  v_row public.curriculum_daily_challenge_attempts%rowtype;
  v_ids uuid[];
  v_questions jsonb;
  v_level_id uuid;
  v_version text;
  v_scope_count integer:=0;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  select pp.academic_level_id,coalesce(pp.curriculum_version,'default') into v_level_id,v_version
  from public.profile_programs pp where pp.user_id=v_uid and pp.program_id=p_program_id order by pp.is_primary desc limit 1;
  if v_level_id is null then raise exception 'Niveau de cursus non configuré'; end if;

  select * into v_row from public.curriculum_daily_challenge_attempts
  where user_id=v_uid and program_id=p_program_id and challenge_date=current_date;

  if v_row.id is not null and v_row.completed_at is null then
    select count(*) into v_scope_count
    from unnest(v_row.question_ids) x(question_id)
    join public.curriculum_quiz_questions q on q.id=x.question_id
    join public.curriculum_topics t on t.id=q.topic_id
    join public.curriculum_units u on u.id=t.unit_id
    where u.program_id=p_program_id and u.academic_level_id=v_level_id
      and coalesce(u.curriculum_version,'default')=v_version
      and u.is_active=true and t.is_active=true
      and q.is_published=true and q.validation_status='source_validated' and q.question_type='mcq';
    if v_scope_count<>coalesce(array_length(v_row.question_ids,1),0) then
      delete from public.curriculum_daily_challenge_attempts where id=v_row.id;
      v_row:=null;
    end if;
  end if;

  if v_row.id is null then
    select array_agg(id) into v_ids from (
      select q.id from public.curriculum_quiz_questions q
      join public.curriculum_topics t on t.id=q.topic_id
      join public.curriculum_units u on u.id=t.unit_id
      where u.program_id=p_program_id and u.academic_level_id=v_level_id
        and coalesce(u.curriculum_version,'default')=v_version
        and u.is_active=true and t.is_active=true
        and q.is_published=true and q.validation_status='source_validated' and q.question_type='mcq'
        and exists(select 1 from jsonb_array_elements(coalesce(q.options,'[]'::jsonb)) o where coalesce((o->>'correct')::boolean,false)=true)
      order by random() limit 5
    ) s;
    if coalesce(array_length(v_ids,1),0)<5 then raise exception 'Pas assez de QCM validés pour le challenge du jour dans ce niveau'; end if;
    insert into public.curriculum_daily_challenge_attempts(user_id,program_id,question_ids,total_questions)
    values(v_uid,p_program_id,v_ids,5) returning * into v_row;
  end if;

  select coalesce(jsonb_agg(jsonb_build_object('id',q.id,'question_text',q.question_text,
    'options',(select jsonb_agg(jsonb_build_object('text',o->>'text')) from jsonb_array_elements(q.options) o),
    'explanation',q.explanation,'display_order',s.ord) order by s.ord),'[]'::jsonb)
  into v_questions
  from unnest(v_row.question_ids) with ordinality s(id,ord)
  join public.curriculum_quiz_questions q on q.id=s.id;

  return jsonb_build_object('id',v_row.id,'completed',v_row.completed_at is not null,
    'correct_count',v_row.correct_count,'total_questions',v_row.total_questions,'questions',v_questions,
    'academic_level_id',v_level_id,'curriculum_version',v_version);
end;
$$;

create or replace function public.submit_curriculum_daily_answer_v1(p_program_id text,p_question_id uuid,p_answer_text text)
returns jsonb
language plpgsql
security definer
set search_path=''
as $$
declare
  v_uid uuid:=auth.uid(); v_row public.curriculum_daily_challenge_attempts%rowtype;
  v_options jsonb; v_correct_text text; v_correct boolean; v_xp integer; v_now_count integer; v_progress jsonb; v_badges jsonb;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  select * into v_row from public.curriculum_daily_challenge_attempts
  where user_id=v_uid and program_id=p_program_id and challenge_date=current_date for update;
  if v_row.id is null or not (p_question_id=any(v_row.question_ids)) then raise exception 'Question hors challenge'; end if;
  if p_question_id=any(v_row.answered_ids) then raise exception 'Question déjà répondue'; end if;
  select options into v_options from public.curriculum_quiz_questions
  where id=p_question_id and is_published=true and validation_status='source_validated' and question_type='mcq';
  if v_options is null then raise exception 'Question du challenge indisponible'; end if;
  select x->>'text' into v_correct_text from jsonb_array_elements(v_options) x where coalesce((x->>'correct')::boolean,false)=true limit 1;
  v_correct:=p_answer_text=v_correct_text; v_xp:=case when v_correct then 12 else 2 end;
  insert into public.curriculum_question_attempts(user_id,question_id,topic_id,answer_text,is_correct,xp_earned)
  select v_uid,q.id,q.topic_id,p_answer_text,v_correct,v_xp from public.curriculum_quiz_questions q where q.id=p_question_id;
  update public.curriculum_daily_challenge_attempts
  set answered_ids=array_append(answered_ids,p_question_id),correct_count=correct_count+case when v_correct then 1 else 0 end,xp_earned=xp_earned+v_xp
  where id=v_row.id returning cardinality(answered_ids) into v_now_count;
  v_progress:=public.update_user_progress_v2(v_uid,v_xp,current_date);
  if v_now_count>=v_row.total_questions then
    update public.curriculum_daily_challenge_attempts set completed_at=coalesce(completed_at,now()),xp_earned=xp_earned+25 where id=v_row.id;
    v_progress:=public.update_user_progress_v2(v_uid,25,current_date);
  end if;
  v_badges:=public.check_and_award_badges_v2();
  return jsonb_build_object('correct',v_correct,'correct_answer',v_correct_text,'xp_earned',v_xp,'completed',v_now_count>=v_row.total_questions,'xp_total',v_progress->'xp_total','current_streak',v_progress->'current_streak','new_badges',v_badges->'new_badges');
end;
$$;

create or replace function public.get_curriculum_challenge_availability_v1(p_program_id text)
returns jsonb
language plpgsql
security definer
set search_path=''
as $$
declare v_uid uuid:=auth.uid(); v_level_id uuid; v_level_code text; v_version text; v_count integer:=0;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  select pp.academic_level_id,al.code,coalesce(pp.curriculum_version,'default') into v_level_id,v_level_code,v_version
  from public.profile_programs pp left join public.academic_levels al on al.id=pp.academic_level_id
  where pp.user_id=v_uid and pp.program_id=p_program_id order by pp.is_primary desc limit 1;
  if v_level_id is not null then
    select count(*) into v_count from public.curriculum_quiz_questions q
    join public.curriculum_topics t on t.id=q.topic_id join public.curriculum_units u on u.id=t.unit_id
    where u.program_id=p_program_id and u.academic_level_id=v_level_id and coalesce(u.curriculum_version,'default')=v_version
      and u.is_active=true and t.is_active=true and q.is_published=true and q.validation_status='source_validated'
      and q.question_type='mcq' and jsonb_array_length(q.options)>=2
      and exists(select 1 from jsonb_array_elements(q.options)o where coalesce((o->>'correct')::boolean,false)=true);
  end if;
  return jsonb_build_object('program_id',p_program_id,'academic_level_id',v_level_id,'level_code',v_level_code,
    'curriculum_version',v_version,'validated_mcq',v_count,'required_mcq',10,'can_challenge',v_level_id is not null and v_count>=10);
end;
$$;

create or replace function public.create_curriculum_friend_challenge_v1(p_friend_id uuid,p_program_id text default 'ifsi-fr'::text)
returns uuid
language plpgsql
security definer
set search_path=''
as $$
declare
  v_uid uuid:=auth.uid(); v_id uuid; v_count integer; v_username text; v_program_name text;
  v_level_id uuid; v_friend_level_id uuid; v_version text; v_friend_version text; v_level_code text;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  if p_friend_id is null or p_friend_id=v_uid then raise exception 'Ami invalide'; end if;
  if not exists(select 1 from public.friendships f where f.status='accepted' and ((f.requester_id=v_uid and f.addressee_id=p_friend_id) or (f.requester_id=p_friend_id and f.addressee_id=v_uid))) then raise exception 'Cet utilisateur ne fait pas partie de tes amis'; end if;
  select pp.academic_level_id,coalesce(pp.curriculum_version,'default') into v_level_id,v_version from public.profile_programs pp where pp.user_id=v_uid and pp.program_id=p_program_id order by pp.is_primary desc limit 1;
  select pp.academic_level_id,coalesce(pp.curriculum_version,'default') into v_friend_level_id,v_friend_version from public.profile_programs pp where pp.user_id=p_friend_id and pp.program_id=p_program_id order by pp.is_primary desc limit 1;
  if v_level_id is null or v_friend_level_id is null then raise exception 'Les deux participants doivent avoir ce cursus attribué et un niveau sélectionné'; end if;
  if v_level_id<>v_friend_level_id then raise exception 'Les défis sont disponibles entre étudiants du même niveau'; end if;
  if v_version<>v_friend_version then raise exception 'Les défis sont disponibles entre étudiants du même référentiel'; end if;
  if exists(select 1 from public.curriculum_friend_challenges c where c.program_id=p_program_id and c.academic_level_id=v_level_id and c.status in ('pending','accepted','in_progress') and ((c.challenger_id=v_uid and c.challenged_id=p_friend_id) or (c.challenger_id=p_friend_id and c.challenged_id=v_uid))) then raise exception 'Un défi est déjà en cours avec cet ami'; end if;
  select count(*) into v_count from public.curriculum_quiz_questions q
  join public.curriculum_topics t on t.id=q.topic_id join public.curriculum_units u on u.id=t.unit_id
  where u.program_id=p_program_id and u.academic_level_id=v_level_id and coalesce(u.curriculum_version,'default')=v_version
    and u.is_active=true and t.is_active=true and q.is_published=true and q.validation_status='source_validated'
    and q.question_type='mcq' and jsonb_array_length(q.options)>=2
    and exists(select 1 from jsonb_array_elements(q.options)o where coalesce((o->>'correct')::boolean,false)=true);
  if v_count<10 then raise exception 'Pas assez de QCM validés pour créer un défi dans ce niveau'; end if;
  insert into public.curriculum_friend_challenges(program_id,academic_level_id,challenger_id,challenged_id) values(p_program_id,v_level_id,v_uid,p_friend_id) returning id into v_id;
  insert into public.curriculum_friend_challenge_questions(challenge_id,question_id,display_order)
  select v_id,id,row_number() over(order by random())::integer from (
    select q.id from public.curriculum_quiz_questions q
    join public.curriculum_topics t on t.id=q.topic_id join public.curriculum_units u on u.id=t.unit_id
    where u.program_id=p_program_id and u.academic_level_id=v_level_id and coalesce(u.curriculum_version,'default')=v_version
      and u.is_active=true and t.is_active=true and q.is_published=true and q.validation_status='source_validated'
      and q.question_type='mcq' and jsonb_array_length(q.options)>=2
      and exists(select 1 from jsonb_array_elements(q.options)o where coalesce((o->>'correct')::boolean,false)=true)
    order by random() limit 10
  ) s;
  select coalesce(p.username::text,p.first_name,'Un ami') into v_username from public.profiles p where p.id=v_uid;
  select coalesce(p.short_name,p.name,p_program_id) into v_program_name from public.programs p where p.id=p_program_id;
  select al.code into v_level_code from public.academic_levels al where al.id=v_level_id;
  insert into public.notifications(user_id,type,title,body,data)
  values(p_friend_id,'challenge_received','Nouveau défi ⚔️',v_username||' te défie sur 10 questions '||coalesce(v_program_name,p_program_id)||' · '||coalesce(v_level_code,'niveau sélectionné')||'.',jsonb_build_object('curriculum_challenge_id',v_id,'program_id',p_program_id,'academic_level_id',v_level_id,'curriculum_version',v_version));
  return v_id;
end;
$$;

revoke all on function public.get_curriculum_daily_challenge_v1(text) from public,anon;
revoke all on function public.submit_curriculum_daily_answer_v1(text,uuid,text) from public,anon;
revoke all on function public.get_curriculum_challenge_availability_v1(text) from public,anon;
revoke all on function public.create_curriculum_friend_challenge_v1(uuid,text) from public,anon;
grant execute on function public.get_curriculum_daily_challenge_v1(text) to authenticated,service_role;
grant execute on function public.submit_curriculum_daily_answer_v1(text,uuid,text) to authenticated,service_role;
grant execute on function public.get_curriculum_challenge_availability_v1(text) to authenticated,service_role;
grant execute on function public.create_curriculum_friend_challenge_v1(uuid,text) to authenticated,service_role;
