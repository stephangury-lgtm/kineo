create or replace function public.get_content_review_queue_v4()
 returns jsonb
 language plpgsql
 stable security definer
 set search_path to ''
as $function$
declare v_result jsonb;
begin
  if auth.uid() is null or not public.is_admin() then
    raise exception 'Accès administrateur requis';
  end if;

  with question_rows as (
    select q.id,q.type,q.question_text,q.difficulty,q.validation_status,q.is_published,q.metadata,q.image_url,q.created_at,
           y.number as year_number,s.name as subject_name,c.name as chapter_name,l.title as lesson_title,
           src.source_title,src.source_page,src.source_excerpt,
           (select count(*) from public.question_options qo where qo.question_id=q.id) as option_count,
           (select count(*) from public.question_options qo where qo.question_id=q.id and qo.is_correct) as correct_option_count
    from public.questions q
    join public.lessons l on l.id=q.lesson_id
    join public.chapters c on c.id=l.chapter_id
    join public.subjects s on s.id=c.subject_id
    join public.years y on y.id=s.year_id
    left join lateral (
      select cd.title as source_title,qs.page_number as source_page,qs.source_excerpt
      from public.question_sources qs
      join public.course_documents cd on cd.id=qs.document_id
      where qs.question_id=q.id
      order by qs.created_at asc,qs.id asc
      limit 1
    ) src on true
    where q.validation_status in ('review','validated','published','archived')
  )
  select jsonb_build_object(
    'counts',jsonb_build_object(
      'review',count(*) filter(where validation_status='review'),
      'validated',count(*) filter(where validation_status='validated'),
      'published',count(*) filter(where validation_status='published'),
      'archived',count(*) filter(where validation_status='archived' and type in ('hotspot','image')),
      'quarantined_visual',count(*) filter(where validation_status in ('review','archived') and type in ('hotspot','image')),
      'quality_issues',count(*) filter(where metadata->>'quality_issue' is not null)
    ),
    'questions',coalesce(jsonb_agg(jsonb_build_object(
      'id',id,'type',type,'question_text',question_text,'difficulty',difficulty,
      'validation_status',validation_status,'is_published',is_published,
      'year_number',year_number,'subject_name',subject_name,'chapter_name',chapter_name,'lesson_title',lesson_title,
      'source_title',source_title,'source_page',source_page,'source_excerpt',source_excerpt,
      'quality_issue',metadata->>'quality_issue',
      'visual_approved',coalesce((metadata->>'visual_approved')::boolean,false),
      'visual_review',coalesce(metadata->'visual_review','{}'::jsonb),
      'visual_rebuild_batch',metadata->>'visual_rebuild_batch',
      'image_url',image_url,
      'hotspot',case when type='hotspot' then coalesce(metadata->'hotspot_v2',metadata->'hotspot') else null end,
      'label_targets',case when type='image' then coalesce(metadata->'label_targets','[]'::jsonb) else null end,
      'option_count',option_count,'correct_option_count',correct_option_count
    ) order by case when validation_status='archived' then 0 else 1 end,year_number,subject_name,chapter_name,lesson_title,created_at)
      filter(where validation_status in ('archived','review','validated')),'[]'::jsonb)
  ) into v_result
  from question_rows;

  return v_result;
end;
$function$;
