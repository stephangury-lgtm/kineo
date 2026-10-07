create table if not exists public.release_health_status(
  id smallint primary key check (id=1),
  payload jsonb not null,
  checked_at timestamptz not null default now()
);

alter table public.release_health_status enable row level security;

drop policy if exists release_health_public_read on public.release_health_status;
create policy release_health_public_read
on public.release_health_status
for select
to anon, authenticated
using (id=1);

revoke all on table public.release_health_status from public;
grant select on table public.release_health_status to anon, authenticated;

create or replace function public.refresh_release_health_status_v1()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_payload jsonb;
begin
  with
  curriculum_questions as (
    select q.*, t.unit_id, u.program_id
    from public.curriculum_quiz_questions q
    left join public.curriculum_topics t on t.id=q.topic_id
    left join public.curriculum_units u on u.id=t.unit_id
    where q.is_published=true
  ),
  curriculum_lessons as (
    select l.*, t.unit_id, u.program_id
    from public.curriculum_lessons l
    left join public.curriculum_topics t on t.id=l.topic_id
    left join public.curriculum_units u on u.id=t.unit_id
    where l.is_published=true
  ),
  legacy_questions as (
    select q.* from public.questions q where q.is_published=true
  ),
  checks as (
    select
      (select count(*) from curriculum_questions where topic_id is null or unit_id is null or program_id is null)::int as orphan_curriculum_questions,
      (select count(*) from curriculum_questions where coalesce(validation_status,'')<>'source_validated')::int as unvalidated_curriculum_questions,
      (select count(*) from curriculum_questions where length(trim(coalesce(question_text,'')))=0)::int as empty_curriculum_questions,
      (select count(*) from curriculum_questions where length(trim(coalesce(source_label,'')))=0)::int as missing_curriculum_question_sources,
      (select count(*) from curriculum_questions where question_type='mcq' and (
        jsonb_typeof(options)<>'array'
        or jsonb_array_length(options)<2
        or (select count(*) from jsonb_array_elements(options) item where coalesce((item->>'correct')::boolean,false))<>1
      ))::int as invalid_curriculum_mcq,
      (select count(*) from curriculum_questions where question_type='fill_blank' and (
        jsonb_typeof(accepted_answers)<>'array' or jsonb_array_length(accepted_answers)=0
      ))::int as invalid_fill_blank,
      (select count(*) from curriculum_questions where question_type='visual_hotspot' and (
        length(trim(coalesce(image_url,'')))=0
        or jsonb_typeof(metadata->'hotspots')<>'array'
        or jsonb_array_length(coalesce(metadata->'hotspots','[]'::jsonb))=0
        or (select count(*) from jsonb_array_elements(coalesce(metadata->'hotspots','[]'::jsonb)) item where coalesce((item->>'correct')::boolean,false))<>1
      ))::int as invalid_visual_hotspot,
      (select count(*) from curriculum_lessons where topic_id is null or unit_id is null or program_id is null)::int as orphan_curriculum_lessons,
      (select count(*) from curriculum_lessons where coalesce(validation_status,'')<>'source_validated')::int as unvalidated_curriculum_lessons,
      (select count(*) from curriculum_lessons where length(trim(coalesce(title,'')))=0 or length(trim(coalesce(content,'')))=0)::int as empty_curriculum_lessons,
      (select count(*) from curriculum_lessons where source_files is null or source_files='[]'::jsonb or source_files='{}'::jsonb)::int as missing_curriculum_lesson_sources,
      (select count(*) from legacy_questions where length(trim(coalesce(question_text,'')))=0)::int as empty_legacy_questions,
      (select count(*) from legacy_questions q where q.type='mcq' and (
        select count(*) from public.question_options o where o.question_id=q.id and o.is_correct=true
      )<>1)::int as invalid_legacy_mcq,
      (select count(*) from curriculum_questions where length(trim(coalesce(explanation,'')))=0)::int as missing_curriculum_explanations,
      (select count(*) from legacy_questions where length(trim(coalesce(explanation,'')))=0)::int as missing_legacy_explanations,
      (select count(*) from curriculum_questions)::int as published_curriculum_questions,
      (select count(*) from curriculum_lessons)::int as published_curriculum_lessons,
      (select count(*) from legacy_questions)::int as published_legacy_questions
  )
  select jsonb_build_object(
    'ok',(
      orphan_curriculum_questions+unvalidated_curriculum_questions+empty_curriculum_questions+
      missing_curriculum_question_sources+invalid_curriculum_mcq+invalid_fill_blank+invalid_visual_hotspot+
      orphan_curriculum_lessons+unvalidated_curriculum_lessons+empty_curriculum_lessons+
      missing_curriculum_lesson_sources+empty_legacy_questions+invalid_legacy_mcq
    )=0,
    'critical_count',(
      orphan_curriculum_questions+unvalidated_curriculum_questions+empty_curriculum_questions+
      missing_curriculum_question_sources+invalid_curriculum_mcq+invalid_fill_blank+invalid_visual_hotspot+
      orphan_curriculum_lessons+unvalidated_curriculum_lessons+empty_curriculum_lessons+
      missing_curriculum_lesson_sources+empty_legacy_questions+invalid_legacy_mcq
    ),
    'warning_count',missing_curriculum_explanations+missing_legacy_explanations,
    'checks',jsonb_build_object(
      'orphan_curriculum_questions',orphan_curriculum_questions,
      'unvalidated_curriculum_questions',unvalidated_curriculum_questions,
      'empty_curriculum_questions',empty_curriculum_questions,
      'missing_curriculum_question_sources',missing_curriculum_question_sources,
      'invalid_curriculum_mcq',invalid_curriculum_mcq,
      'invalid_fill_blank',invalid_fill_blank,
      'invalid_visual_hotspot',invalid_visual_hotspot,
      'orphan_curriculum_lessons',orphan_curriculum_lessons,
      'unvalidated_curriculum_lessons',unvalidated_curriculum_lessons,
      'empty_curriculum_lessons',empty_curriculum_lessons,
      'missing_curriculum_lesson_sources',missing_curriculum_lesson_sources,
      'empty_legacy_questions',empty_legacy_questions,
      'invalid_legacy_mcq',invalid_legacy_mcq,
      'missing_curriculum_explanations',missing_curriculum_explanations,
      'missing_legacy_explanations',missing_legacy_explanations
    ),
    'published',jsonb_build_object(
      'curriculum_questions',published_curriculum_questions,
      'curriculum_lessons',published_curriculum_lessons,
      'legacy_questions',published_legacy_questions
    ),
    'generated_at',now()
  ) into v_payload
  from checks;

  insert into public.release_health_status(id,payload,checked_at)
  values(1,v_payload,now())
  on conflict(id) do update set payload=excluded.payload,checked_at=excluded.checked_at;

  return v_payload;
end;
$function$;

revoke all on function public.refresh_release_health_status_v1() from public, anon, authenticated;

select public.refresh_release_health_status_v1();

drop function if exists public.get_release_health_v1();

select cron.unschedule(jobid)
from cron.job
where jobname='kineo-release-health-30m';

select cron.schedule(
  'kineo-release-health-30m',
  '*/30 * * * *',
  $$select public.refresh_release_health_status_v1();$$
);
