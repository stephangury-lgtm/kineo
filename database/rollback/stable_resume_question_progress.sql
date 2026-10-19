-- Apply only to undo this exact function version; no attempts or sessions are removed.
DO $guard$ BEGIN
 IF md5(pg_get_functiondef('public.get_quiz_questions_v4(uuid)'::regprocedure)) <> '11b2951ffb09938ddf1c9d644bc4cab1' THEN
  RAISE EXCEPTION 'Concurrent function change: rollback refused';
 END IF;
END $guard$;
CREATE OR REPLACE FUNCTION public.get_quiz_questions_v4(p_session_id uuid)
 RETURNS TABLE(id uuid, type text, question_text text, explanation text, difficulty integer, image_url text, metadata jsonb, question_options jsonb, display_order integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null then raise exception 'Utilisateur non authentifié'; end if;
  if not exists(
    select 1
    from public.revision_sessions rs
    where rs.id=p_session_id
      and rs.user_id=auth.uid()
      and rs.abandoned_at is null
  ) then
    raise exception 'Session inexistante, abandonnée ou accès non autorisé';
  end if;

  return query
  select
    q.id,
    q.type,
    q.question_text,
    null::text,
    q.difficulty,
    q.image_url,
    case
      when q.type='matching' then jsonb_build_object(
        'left_items',coalesce((
          select jsonb_agg(e.value->'left' order by e.ord)
          from jsonb_array_elements(coalesce(q.metadata->'pairs','[]'::jsonb)) with ordinality e(value,ord)
        ),'[]'::jsonb),
        'right_items',coalesce((
          select jsonb_agg(r.right_value order by random())
          from (
            select e.value->'right' right_value
            from jsonb_array_elements(coalesce(q.metadata->'pairs','[]'::jsonb)) e(value)
          ) r
        ),'[]'::jsonb)
      )
      else coalesce(q.metadata,'{}'::jsonb)-'answer'-'accepted_answers'-'correct_answer'-'is_correct'-'pairs'
    end,
    coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'id',qo.id,
          'option_text',qo.option_text,
          'display_order',qo.display_order
        )
        order by qo.display_order
      )
      from public.question_options qo
      where qo.question_id=q.id
    ),'[]'::jsonb),
    row_number() over(order by q.difficulty asc, rsq.display_order asc)::int
  from public.revision_session_questions rsq
  join public.questions q on q.id=rsq.question_id
  join public.revision_sessions rs on rs.id=rsq.session_id
  where rsq.session_id=p_session_id
    and rs.abandoned_at is null
    and rsq.answered_at is null
    and q.is_published=true
    and q.validation_status='published'
  order by q.difficulty asc, rsq.display_order asc;
end;
$function$;
