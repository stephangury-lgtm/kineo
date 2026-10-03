-- Keep repository migrations aligned with production hotfixes.
-- 1) A first-ever incorrect answer must not insert NULL correct_count.
-- 2) Student-facing corrections must not expose course/support labels.

create or replace function public.submit_quiz_answer(
  p_session_id uuid,
  p_question_id uuid,
  p_answer jsonb,
  p_response_time_ms integer default null
)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user_id uuid; v_question_type text; v_metadata jsonb; v_is_correct boolean:=false; v_xp integer:=0;
  v_attempt_count integer:=0; v_correct_count integer:=0; v_mastery integer:=0; v_expected text; v_given text;
begin
  if auth.uid() is null then raise exception 'Utilisateur non authentifié'; end if;
  select rs.user_id into v_user_id from public.revision_sessions rs
  where rs.id=p_session_id and rs.user_id=auth.uid() and rs.completed_at is null and rs.abandoned_at is null;
  if v_user_id is null then raise exception 'Session inexistante, terminée, abandonnée ou accès non autorisé'; end if;

  select q.type,coalesce(q.metadata,'{}'::jsonb) into v_question_type,v_metadata
  from public.revision_session_questions rsq join public.questions q on q.id=rsq.question_id
  where rsq.session_id=p_session_id and rsq.question_id=p_question_id and q.is_published=true and q.validation_status='published';
  if v_question_type is null then raise exception 'Cette question ne fait pas partie de cette session'; end if;
  if exists(select 1 from public.question_attempts qa where qa.session_id=p_session_id and qa.question_id=p_question_id and qa.user_id=v_user_id) then raise exception 'Cette question a déjà reçu une réponse'; end if;

  if v_question_type in ('mcq','true_false') or (v_question_type='clinical_case' and nullif(p_answer->>'option_id','') is not null) then
    select exists(select 1 from public.question_options qo where qo.question_id=p_question_id and qo.id::text=p_answer->>'option_id' and qo.is_correct=true) into v_is_correct;
  elsif v_question_type in ('fill_blank','short_answer','translation','clinical_case') then
    v_given:=public.normalize_quiz_text_v1(p_answer->>'text');
    v_expected:=public.normalize_quiz_text_v1(v_metadata->>'answer');
    v_is_correct:=v_given<>'' and (
      (v_expected<>'' and v_given=v_expected)
      or exists(
        select 1
        from pg_catalog.jsonb_array_elements_text(
          case when pg_catalog.jsonb_typeof(v_metadata->'accepted_answers')='array' then v_metadata->'accepted_answers' else '[]'::jsonb end
        ) a(value)
        where public.normalize_quiz_text_v1(a.value)=v_given
      )
    );
  elsif v_question_type='matching' then
    if pg_catalog.jsonb_typeof(v_metadata->'pairs')='array' and pg_catalog.jsonb_typeof(p_answer->'pairs')='array' then
      v_is_correct:=pg_catalog.jsonb_array_length(v_metadata->'pairs')=pg_catalog.jsonb_array_length(p_answer->'pairs') and (v_metadata->'pairs')@>(p_answer->'pairs') and (p_answer->'pairs')@>(v_metadata->'pairs');
    end if;
  else v_is_correct:=false;
  end if;

  if v_is_correct then
    v_xp:=case v_question_type when 'matching' then 15 when 'fill_blank' then 12 when 'short_answer' then 15 when 'translation' then 15 when 'clinical_case' then 20 else 10 end;
  end if;

  insert into public.question_attempts(user_id,question_id,session_id,answer,is_correct,response_time_ms,xp_earned)
  values(v_user_id,p_question_id,p_session_id,p_answer,v_is_correct,p_response_time_ms,v_xp);
  update public.revision_session_questions set answered_at=now() where session_id=p_session_id and question_id=p_question_id;

  select coalesce(attempt_count,0),coalesce(correct_count,0) into v_attempt_count,v_correct_count
  from public.user_question_mastery where user_id=v_user_id and question_id=p_question_id;
  v_attempt_count:=coalesce(v_attempt_count,0)+1;
  v_correct_count:=coalesce(v_correct_count,0);
  if v_is_correct then v_correct_count:=v_correct_count+1; end if;
  v_mastery:=least(4,floor((v_correct_count::numeric/v_attempt_count::numeric)*4)::integer);
  insert into public.user_question_mastery(user_id,question_id,mastery_score,attempt_count,correct_count,last_attempt_at,next_review_at)
  values(v_user_id,p_question_id,v_mastery,v_attempt_count,v_correct_count,now(),case when v_is_correct and v_mastery>=3 then now()+interval '7 days' when v_is_correct then now()+interval '3 days' else now()+interval '1 day' end)
  on conflict(user_id,question_id) do update set mastery_score=excluded.mastery_score,attempt_count=excluded.attempt_count,correct_count=excluded.correct_count,last_attempt_at=excluded.last_attempt_at,next_review_at=excluded.next_review_at;
  return pg_catalog.jsonb_build_object('correct',v_is_correct,'xp_earned',v_xp,'mastery_score',v_mastery,'question_type',v_question_type,'question_id',p_question_id,'session_id',p_session_id);
end;
$function$;

create or replace function public.submit_quiz_answer_v5(
  p_session_id uuid,
  p_question_id uuid,
  p_answer jsonb,
  p_response_time_ms integer default null
)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_result jsonb;
  v_explanation text;
begin
  v_result := public.submit_quiz_answer_v4(p_session_id,p_question_id,p_answer,p_response_time_ms);
  v_explanation := v_result #>> '{correction,explanation}';
  if v_explanation is not null then
    v_explanation := split_part(v_explanation,' — 📚 Source du cours :',1);
    v_explanation := split_part(v_explanation,' — 🔎 Référence externe :',1);
    v_result := jsonb_set(v_result,'{correction,explanation}',to_jsonb(nullif(btrim(v_explanation),'')),false);
  end if;
  return v_result;
end;
$function$;

revoke all on function public.submit_quiz_answer(uuid,uuid,jsonb,integer) from public, anon, authenticated;
grant execute on function public.submit_quiz_answer(uuid,uuid,jsonb,integer) to service_role;

revoke all on function public.submit_quiz_answer_v5(uuid,uuid,jsonb,integer) from public, anon;
grant execute on function public.submit_quiz_answer_v5(uuid,uuid,jsonb,integer) to authenticated, service_role;
