CREATE OR REPLACE FUNCTION public.get_curriculum_daily_challenge_v1(p_program_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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

  select pp.academic_level_id,coalesce(pp.curriculum_version,'default')
    into v_level_id,v_version
  from public.profile_programs pp
  where pp.user_id=v_uid and pp.program_id=p_program_id
  order by pp.is_primary desc
  limit 1;

  if v_level_id is null then
    raise exception 'Niveau de cursus non configuré';
  end if;

  select * into v_row
  from public.curriculum_daily_challenge_attempts
  where user_id=v_uid and program_id=p_program_id and challenge_date=current_date;

  if v_row.id is not null and v_row.completed_at is null then
    select count(*) into v_scope_count
    from unnest(v_row.question_ids) x(question_id)
    join public.curriculum_quiz_questions q on q.id=x.question_id
    join public.curriculum_topics t on t.id=q.topic_id
    join public.curriculum_units u on u.id=t.unit_id
    where u.program_id=p_program_id
      and u.academic_level_id=v_level_id
      and coalesce(u.curriculum_version,'default')=v_version
      and u.is_active=true and t.is_active=true
      and q.is_published=true and q.validation_status='source_validated'
      and q.question_type='mcq';

    if v_scope_count<>coalesce(array_length(v_row.question_ids,1),0) then
      delete from public.curriculum_daily_challenge_attempts where id=v_row.id;
      v_row:=null;
    end if;
  end if;

  if v_row.id is null then
    select array_agg(id) into v_ids from (
      select q.id
      from public.curriculum_quiz_questions q
      join public.curriculum_topics t on t.id=q.topic_id
      join public.curriculum_units u on u.id=t.unit_id
      where u.program_id=p_program_id
        and u.academic_level_id=v_level_id
        and coalesce(u.curriculum_version,'default')=v_version
        and u.is_active=true and t.is_active=true
        and q.is_published=true and q.validation_status='source_validated'
        and q.question_type='mcq'
        and exists(select 1 from jsonb_array_elements(coalesce(q.options,'[]'::jsonb)) o where coalesce((o->>'correct')::boolean,false)=true)
      order by random()
      limit 5
    ) s;
    if coalesce(array_length(v_ids,1),0)<5 then raise exception 'Pas assez de QCM validés pour le challenge du jour dans ce niveau'; end if;
    insert into public.curriculum_daily_challenge_attempts(user_id,program_id,question_ids,total_questions)
    values(v_uid,p_program_id,v_ids,5)
    returning * into v_row;
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
    'id',q.id,
    'question_text',q.question_text,
    'options',(select jsonb_agg(jsonb_build_object('text',o->>'text')) from jsonb_array_elements(q.options) o),
    'explanation',case when v_row.completed_at is not null then q.explanation else null end,
    'display_order',s.ord
  ) order by s.ord),'[]'::jsonb)
  into v_questions
  from unnest(v_row.question_ids) with ordinality s(id,ord)
  join public.curriculum_quiz_questions q on q.id=s.id;

  return jsonb_build_object(
    'id',v_row.id,
    'completed',v_row.completed_at is not null,
    'correct_count',v_row.correct_count,
    'total_questions',v_row.total_questions,
    'questions',v_questions,
    'academic_level_id',v_level_id,
    'curriculum_version',v_version
  );
end;
$function$;

revoke all on function public.get_curriculum_daily_challenge_v1(text) from public,anon;
grant execute on function public.get_curriculum_daily_challenge_v1(text) to authenticated;


