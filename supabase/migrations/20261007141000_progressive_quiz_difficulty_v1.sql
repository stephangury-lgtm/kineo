-- Calibrate a shared five-level difficulty scale across all curricula
-- and serve Kineo legacy session questions from easier to harder.

update public.curriculum_quiz_questions
set difficulty = case
      when question_type = 'clinical_case' then least(5, difficulty + 2)
      when question_type in ('matching','visual_hotspot') then least(5, difficulty + 1)
      else difficulty
    end,
    metadata = coalesce(metadata,'{}'::jsonb) || '{"difficulty_scale_version":"2026-10-v1"}'::jsonb,
    updated_at = now()
where coalesce(metadata->>'difficulty_scale_version','') <> '2026-10-v1';

update public.questions
set difficulty = case
      when type = 'clinical_case' then least(5, difficulty + 2)
      when type in ('matching','hotspot','image','short_answer','translation') then least(5, difficulty + 1)
      else difficulty
    end,
    metadata = coalesce(metadata,'{}'::jsonb) || '{"difficulty_scale_version":"2026-10-v1"}'::jsonb,
    updated_at = now()
where coalesce(metadata->>'difficulty_scale_version','') <> '2026-10-v1';

create or replace function public.get_quiz_questions_v4(p_session_id uuid)
returns table(id uuid, type text, question_text text, explanation text, difficulty integer, image_url text, metadata jsonb, question_options jsonb, display_order integer)
language plpgsql
security definer
set search_path to ''
as $function$
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

select public.refresh_release_health_status_v1();
select public.refresh_security_health_status_v1();
