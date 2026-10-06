create or replace function public.submit_quiz_answer_v5(
  p_session_id uuid,
  p_question_id uuid,
  p_answer jsonb,
  p_response_time_ms integer default null
)
returns jsonb
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_result jsonb;
  v_explanation text;
begin
  if auth.uid() is null then
    raise exception 'Utilisateur non authentifié';
  end if;

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

revoke execute on function public.submit_quiz_answer_v5(uuid,uuid,jsonb,integer) from public, anon;
grant execute on function public.submit_quiz_answer_v5(uuid,uuid,jsonb,integer) to authenticated, service_role;
