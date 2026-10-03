create or replace function public.get_curriculum_v2()
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_user_id uuid:=auth.uid();
  v_result jsonb;
begin
  if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;

  with lesson_stats as (
    select l.id as lesson_id,
      count(q.id)::integer as published_questions,
      count(uqm.question_id) filter(where uqm.attempt_count>0)::integer as attempted_questions,
      coalesce(round(avg(uqm.mastery_percent))::integer,0) as mastery_percent,
      (select count(*)::integer from public.lesson_sources lsrc where lsrc.lesson_id=l.id) as source_document_count,
      exists(
        select 1
        from public.lesson_sources lsrc
        join public.course_documents cd on cd.id=lsrc.document_id
        where lsrc.lesson_id=l.id and cd.validation_status='validated'
      ) as has_validated_source
    from public.lessons l
    left join public.questions q on q.lesson_id=l.id
      and q.is_published=true
      and q.validation_status='published'
      and q.type in ('mcq','true_false','fill_blank','matching','hotspot','image','short_answer','translation','clinical_case')
    left join public.user_question_mastery uqm on uqm.question_id=q.id and uqm.user_id=v_user_id
    where l.is_published=true and l.validation_status='published'
    group by l.id
  ), lesson_rows as (
    select l.id,l.chapter_id,l.title,l.slug,l.summary,l.image_url,l.display_order,
      coalesce(ls.published_questions,0) as published_questions,
      coalesce(ls.attempted_questions,0) as attempted_questions,
      coalesce(ls.mastery_percent,0) as mastery_percent,
      coalesce(ls.source_document_count,0) as source_document_count,
      coalesce(ls.has_validated_source,false) as has_validated_source
    from public.lessons l
    left join lesson_stats ls on ls.lesson_id=l.id
    where l.is_published=true and l.validation_status='published'
  ), chapter_rows as (
    select c.id,c.subject_id,c.name,c.slug,c.description,c.display_order,
      coalesce((
        select jsonb_agg(jsonb_build_object(
          'id',lr.id,'title',lr.title,'slug',lr.slug,'summary',lr.summary,'image_url',lr.image_url,
          'published_questions',lr.published_questions,
          'attempted_questions',lr.attempted_questions,
          'mastery_percent',lr.mastery_percent,
          'coverage_percent',case when lr.published_questions=0 then 0 else round(100.0*lr.attempted_questions/lr.published_questions)::integer end,
          'source_document_count',lr.source_document_count,
          'has_validated_source',lr.has_validated_source
        ) order by lr.display_order,lr.title)
        from lesson_rows lr where lr.chapter_id=c.id
      ),'[]'::jsonb) as lessons,
      (select count(*) from lesson_rows lr where lr.chapter_id=c.id)::integer as lesson_count,
      (select count(q.id)
       from public.questions q
       where q.chapter_id=c.id
         and q.is_published=true
         and q.validation_status='published'
         and q.type in ('mcq','true_false','fill_blank','matching','hotspot','image','short_answer','translation','clinical_case'))::integer as published_questions
    from public.chapters c
    where c.is_active=true
  ), subject_rows as (
    select s.id,s.year_id,s.name,s.slug,s.description,s.icon,s.display_order,
      coalesce((
        select jsonb_agg(jsonb_build_object(
          'id',cr.id,'name',cr.name,'slug',cr.slug,'description',cr.description,
          'lesson_count',cr.lesson_count,'published_questions',cr.published_questions,'lessons',cr.lessons
        ) order by cr.display_order,cr.name)
        from chapter_rows cr
        where cr.subject_id=s.id and (cr.lesson_count>0 or cr.published_questions>0)
      ),'[]'::jsonb) as chapters,
      (select count(*) from chapter_rows cr where cr.subject_id=s.id and (cr.lesson_count>0 or cr.published_questions>0))::integer as chapter_count
    from public.subjects s
    where s.is_active=true
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'id',y.id,'number',y.number,'name',y.name,'description',y.description,
    'subjects',coalesce((
      select jsonb_agg(jsonb_build_object(
        'id',sr.id,'name',sr.name,'slug',sr.slug,'description',sr.description,
        'icon',sr.icon,'chapter_count',sr.chapter_count,'chapters',sr.chapters
      ) order by sr.display_order,sr.name)
      from subject_rows sr
      where sr.year_id=y.id and sr.chapter_count>0
    ),'[]'::jsonb)
  ) order by y.number),'[]'::jsonb)
  into v_result
  from public.years y
  where y.is_active=true;

  return v_result;
end;
$function$;