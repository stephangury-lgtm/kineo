-- Limited visual QA access for named student reviewers. They can review/calibrate visuals, but cannot publish content.
create table if not exists public.visual_reviewers (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  created_by uuid null references public.profiles(id) on delete set null
);
alter table public.visual_reviewers enable row level security;
revoke all on public.visual_reviewers from anon, authenticated;

insert into public.visual_reviewers(user_id)
select p.id from public.profiles p
where lower(coalesce(p.username,'')) in ('esnetroh','mathoubalou')
on conflict (user_id) do nothing;

create or replace function public.can_review_visuals_v1()
returns boolean language sql stable security definer set search_path=''
as $$
  select auth.uid() is not null and (
    exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin')
    or exists(select 1 from public.visual_reviewers vr where vr.user_id=auth.uid())
  );
$$;

create or replace function public.get_visual_review_queue_v1()
returns jsonb language plpgsql stable security definer set search_path=''
as $$
declare v_result jsonb; v_can_publish boolean;
begin
  if auth.uid() is null or not public.can_review_visuals_v1() then raise exception 'Accès relecteur visuel requis'; end if;
  select exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin') into v_can_publish;
  with question_rows as (
    select q.id,q.type,q.question_text,q.difficulty,q.validation_status,q.is_published,q.metadata,q.image_url,q.created_at,
           y.number as year_number,s.name as subject_name,c.name as chapter_name,l.title as lesson_title,
           src.source_title,src.source_page,src.source_excerpt,
           (select count(*) from public.question_options qo where qo.question_id=q.id) as option_count,
           (select count(*) from public.question_options qo where qo.question_id=q.id and qo.is_correct) as correct_option_count
    from public.questions q
    join public.lessons l on l.id=q.lesson_id join public.chapters c on c.id=l.chapter_id
    join public.subjects s on s.id=c.subject_id join public.years y on y.id=s.year_id
    left join lateral (
      select cd.title as source_title,qs.page_number as source_page,qs.source_excerpt
      from public.question_sources qs join public.course_documents cd on cd.id=qs.document_id
      where qs.question_id=q.id order by qs.created_at asc,qs.id asc limit 1
    ) src on true
    where q.type in ('hotspot','image') and q.validation_status in ('archived','review','validated')
  )
  select jsonb_build_object(
    'can_publish',v_can_publish,
    'counts',jsonb_build_object(
      'review',count(*) filter(where validation_status='review'),
      'validated',count(*) filter(where validation_status='validated'),
      'published',0,
      'archived',count(*) filter(where validation_status='archived'),
      'quarantined_visual',count(*) filter(where validation_status in ('review','archived')),
      'quality_issues',count(*) filter(where metadata->>'quality_issue' is not null)
    ),
    'questions',coalesce(jsonb_agg(jsonb_build_object(
      'id',id,'type',type,'question_text',question_text,'difficulty',difficulty,'validation_status',validation_status,
      'is_published',is_published,'year_number',year_number,'subject_name',subject_name,'chapter_name',chapter_name,
      'lesson_title',lesson_title,'source_title',source_title,'source_page',source_page,'source_excerpt',source_excerpt,
      'quality_issue',metadata->>'quality_issue','visual_approved',coalesce((metadata->>'visual_approved')::boolean,false),
      'visual_review',coalesce(metadata->'visual_review','{}'::jsonb),'visual_rebuild_batch',metadata->>'visual_rebuild_batch',
      'image_url',image_url,'hotspot',case when type='hotspot' then coalesce(metadata->'hotspot_v2',metadata->'hotspot') else null end,
      'label_targets',case when type='image' then coalesce(metadata->'label_targets','[]'::jsonb) else null end,
      'option_count',option_count,'correct_option_count',correct_option_count
    ) order by year_number,subject_name,chapter_name,lesson_title,created_at),'[]'::jsonb)
  ) into v_result from question_rows;
  return v_result;
end;
$$;

create or replace function public.set_visual_review_v2(
  p_question_id uuid,
  p_anatomy_ok boolean,
  p_mobile_ok boolean,
  p_target_ok boolean,
  p_source_ok boolean
)
returns jsonb
language plpgsql
security definer
set search_path=''
as $$
declare
  v_type text; v_status text; v_image text;
  v_approved boolean := coalesce(p_anatomy_ok,false) and coalesce(p_mobile_ok,false) and coalesce(p_target_ok,false) and coalesce(p_source_ok,false);
  v_review jsonb;
begin
  if auth.uid() is null or not public.can_review_visuals_v1() then raise exception 'Accès relecteur visuel requis'; end if;
  select q.type,q.validation_status,q.image_url into v_type,v_status,v_image from public.questions q where q.id=p_question_id for update;
  if not found then raise exception 'Question introuvable'; end if;
  if v_type not in ('hotspot','image') then raise exception 'Cette question n’est pas un exercice visuel'; end if;
  if v_status='published' then raise exception 'Repasse la question en revue avant de modifier sa validation visuelle'; end if;
  if nullif(btrim(coalesce(v_image,'')),'') is null then raise exception 'Aucune image associée à cet exercice'; end if;
  v_review:=jsonb_build_object(
    'anatomy_ok',coalesce(p_anatomy_ok,false),
    'mobile_ok',coalesce(p_mobile_ok,false),
    'target_ok',coalesce(p_target_ok,false),
    'source_ok',coalesce(p_source_ok,false),
    'reviewed_at',now(),
    'reviewed_by',auth.uid()
  );
  update public.questions
  set metadata=jsonb_set(jsonb_set(coalesce(metadata,'{}'::jsonb),'{visual_review}',v_review,true),'{visual_approved}',to_jsonb(v_approved),true),updated_at=now()
  where id=p_question_id;
  return jsonb_build_object('question_id',p_question_id,'visual_approved',v_approved,'visual_review',v_review);
end;
$$;

create or replace function public.set_visual_target_v1(
  p_question_id uuid,
  p_x numeric,
  p_y numeric,
  p_target_index integer default null,
  p_radius numeric default null
)
returns jsonb
language plpgsql
security definer
set search_path=''
as $$
declare
  v_type text; v_status text; v_metadata jsonb; v_len integer; v_radius numeric; v_path text[];
begin
  if auth.uid() is null or not public.can_review_visuals_v1() then raise exception 'Accès relecteur visuel requis'; end if;
  if p_x < 0 or p_x > 100 or p_y < 0 or p_y > 100 then raise exception 'Coordonnées hors cadre'; end if;
  select q.type,q.validation_status,coalesce(q.metadata,'{}'::jsonb) into v_type,v_status,v_metadata from public.questions q where q.id=p_question_id for update;
  if not found then raise exception 'Question introuvable'; end if;
  if v_type not in ('hotspot','image') then raise exception 'Cette question n’est pas un exercice visuel'; end if;
  if v_status='published' then raise exception 'Repasse la question en revue avant de calibrer sa cible'; end if;
  if v_type='hotspot' then
    if v_metadata->'hotspot' is null then raise exception 'Hotspot absent'; end if;
    v_radius:=coalesce(p_radius,(v_metadata->'hotspot'->>'radius')::numeric,12);
    if v_radius < 6 or v_radius > 30 then raise exception 'Rayon hors limites'; end if;
    v_metadata:=jsonb_set(v_metadata,'{hotspot,x}',to_jsonb(round(p_x,2)),true);
    v_metadata:=jsonb_set(v_metadata,'{hotspot,y}',to_jsonb(round(p_y,2)),true);
    v_metadata:=jsonb_set(v_metadata,'{hotspot,radius}',to_jsonb(round(v_radius,2)),true);
  else
    v_len:=jsonb_array_length(coalesce(v_metadata->'label_targets','[]'::jsonb));
    if p_target_index is null or p_target_index < 0 or p_target_index >= v_len then raise exception 'Étiquette cible invalide'; end if;
    v_radius:=coalesce(p_radius,(v_metadata->'label_targets'->p_target_index->>'radius')::numeric,12);
    if v_radius < 6 or v_radius > 30 then raise exception 'Rayon hors limites'; end if;
    v_path:=array['label_targets',p_target_index::text,'x']; v_metadata:=jsonb_set(v_metadata,v_path,to_jsonb(round(p_x,2)),true);
    v_path:=array['label_targets',p_target_index::text,'y']; v_metadata:=jsonb_set(v_metadata,v_path,to_jsonb(round(p_y,2)),true);
    v_path:=array['label_targets',p_target_index::text,'radius']; v_metadata:=jsonb_set(v_metadata,v_path,to_jsonb(round(v_radius,2)),true);
  end if;
  v_metadata:=jsonb_set(v_metadata,'{visual_approved}','false'::jsonb,true);
  v_metadata:=jsonb_set(v_metadata,'{visual_review,target_ok}','false'::jsonb,true);
  v_metadata:=jsonb_set(v_metadata,'{visual_target_calibrated_at}',to_jsonb(now()),true);
  v_metadata:=jsonb_set(v_metadata,'{visual_target_calibrated_by}',to_jsonb(auth.uid()),true);
  update public.questions set metadata=v_metadata,updated_at=now() where id=p_question_id;
  return jsonb_build_object('question_id',p_question_id,'hotspot',v_metadata->'hotspot','label_targets',v_metadata->'label_targets','visual_approved',false);
end;
$$;

-- Publication/status transitions remain protected by admin-only set_content_review_status_v1.
revoke all on function public.can_review_visuals_v1() from public,anon;
revoke all on function public.get_visual_review_queue_v1() from public,anon;
revoke all on function public.set_visual_review_v2(uuid,boolean,boolean,boolean,boolean) from public,anon;
revoke all on function public.set_visual_target_v1(uuid,numeric,numeric,integer,numeric) from public,anon;
grant execute on function public.can_review_visuals_v1() to authenticated,service_role;
grant execute on function public.get_visual_review_queue_v1() to authenticated,service_role;
grant execute on function public.set_visual_review_v2(uuid,boolean,boolean,boolean,boolean) to authenticated,service_role;
grant execute on function public.set_visual_target_v1(uuid,numeric,numeric,integer,numeric) to authenticated,service_role;
