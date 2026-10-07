create table if not exists public.business_health_status(
  id smallint primary key check (id=1),
  payload jsonb not null,
  checked_at timestamptz not null default now()
);

alter table public.business_health_status enable row level security;

drop policy if exists business_health_public_read on public.business_health_status;
create policy business_health_public_read
on public.business_health_status
for select
to anon, authenticated
using (id=1);

revoke all on table public.business_health_status from public;
grant select on table public.business_health_status to anon, authenticated;

create or replace function public.refresh_business_health_status_v1()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_payload jsonb;
begin
  with duplicate_programs as (
    select user_id,program_id,count(*) c
    from public.profile_programs
    group by user_id,program_id
    having count(*)>1
  ),
  multiple_primary as (
    select user_id,count(*) c
    from public.profile_programs
    where is_primary
    group by user_id
    having count(*)>1
  ),
  bad_challenges as (
    select c.id
    from public.curriculum_friend_challenges c
    left join public.profile_programs a on a.user_id=c.challenger_id and a.program_id=c.program_id
    left join public.profile_programs b on b.user_id=c.challenged_id and b.program_id=c.program_id
    where a.user_id is null or b.user_id is null
       or a.academic_level_id<>c.academic_level_id
       or b.academic_level_id<>c.academic_level_id
       or (
         c.program_id='ifsi-fr'
         and coalesce(a.curriculum_version,'2009')<>coalesce(b.curriculum_version,'2009')
       )
  ),
  bad_challenge_questions as (
    select cq.challenge_id,cq.question_id
    from public.curriculum_friend_challenge_questions cq
    join public.curriculum_friend_challenges c on c.id=cq.challenge_id
    left join public.curriculum_quiz_questions q on q.id=cq.question_id
    left join public.curriculum_topics t on t.id=q.topic_id
    left join public.curriculum_units u on u.id=t.unit_id
    where q.id is null or u.id is null
       or u.program_id<>c.program_id
       or u.academic_level_id<>c.academic_level_id
       or q.is_published<>true
       or q.validation_status<>'source_validated'
  ),
  bad_daily_questions as (
    select d.id,qid
    from public.curriculum_daily_challenge_attempts d
    join public.profile_programs pp on pp.user_id=d.user_id and pp.program_id=d.program_id
    cross join lateral unnest(d.question_ids) qid
    left join public.curriculum_quiz_questions q on q.id=qid
    left join public.curriculum_topics t on t.id=q.topic_id
    left join public.curriculum_units u on u.id=t.unit_id
    where q.id is null or u.id is null
       or u.program_id<>d.program_id
       or u.academic_level_id<>pp.academic_level_id
       or q.is_published<>true
       or q.validation_status<>'source_validated'
  ),
  checks as (
    select
      (select count(*) from duplicate_programs)::int as duplicate_profile_programs,
      (select count(*) from multiple_primary)::int as multiple_primary_programs,
      (select count(*) from bad_challenges)::int as invalid_friend_challenges,
      (select count(*) from bad_challenge_questions)::int as invalid_friend_challenge_questions,
      (select count(*) from bad_daily_questions)::int as invalid_daily_challenge_questions
  )
  select jsonb_build_object(
    'ok',(
      duplicate_profile_programs+multiple_primary_programs+
      invalid_friend_challenges+invalid_friend_challenge_questions+invalid_daily_challenge_questions
    )=0,
    'critical_count',(
      duplicate_profile_programs+multiple_primary_programs+
      invalid_friend_challenges+invalid_friend_challenge_questions+invalid_daily_challenge_questions
    ),
    'checks',jsonb_build_object(
      'duplicate_profile_programs',duplicate_profile_programs,
      'multiple_primary_programs',multiple_primary_programs,
      'invalid_friend_challenges',invalid_friend_challenges,
      'invalid_friend_challenge_questions',invalid_friend_challenge_questions,
      'invalid_daily_challenge_questions',invalid_daily_challenge_questions
    ),
    'generated_at',now()
  )
  into v_payload
  from checks;

  insert into public.business_health_status(id,payload,checked_at)
  values(1,v_payload,now())
  on conflict(id) do update set payload=excluded.payload,checked_at=excluded.checked_at;

  return v_payload;
end;
$function$;

revoke all on function public.refresh_business_health_status_v1() from public, anon, authenticated;

select public.refresh_business_health_status_v1();

select cron.unschedule(jobid)
from cron.job
where jobname='kineo-business-health-30m';

select cron.schedule(
  'kineo-business-health-30m',
  '17,47 * * * *',
  $$select public.refresh_business_health_status_v1();$$
);
