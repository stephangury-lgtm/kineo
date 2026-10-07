create table if not exists public.security_health_status(
  id smallint primary key check (id=1),
  payload jsonb not null,
  checked_at timestamptz not null default now()
);

alter table public.security_health_status enable row level security;

drop policy if exists security_health_public_read on public.security_health_status;
create policy security_health_public_read
on public.security_health_status
for select
to anon, authenticated
using (id=1);

revoke all on table public.security_health_status from public;
grant select on table public.security_health_status to anon, authenticated;

create or replace function public.refresh_security_health_status_v1()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare v_payload jsonb;
begin
  with definer as (
    select p.oid,p.proname,coalesce(array_to_string(p.proconfig,','),'') as config
    from pg_proc p
    join pg_namespace n on n.oid=p.pronamespace
    where n.nspname='public' and p.prosecdef
  ),
  checks as (
    select
      count(*)::int as total_security_definer,
      count(*) filter(where has_function_privilege('anon',oid,'EXECUTE'))::int as anon_security_definer_executable,
      count(*) filter(where config not like '%search_path=%')::int as unpinned_security_definer_search_path
    from definer
  )
  select jsonb_build_object(
    'ok',anon_security_definer_executable=0 and unpinned_security_definer_search_path=0,
    'critical_count',anon_security_definer_executable+unpinned_security_definer_search_path,
    'checks',jsonb_build_object(
      'total_security_definer',total_security_definer,
      'anon_security_definer_executable',anon_security_definer_executable,
      'unpinned_security_definer_search_path',unpinned_security_definer_search_path
    ),
    'generated_at',now()
  ) into v_payload
  from checks;

  insert into public.security_health_status(id,payload,checked_at)
  values(1,v_payload,now())
  on conflict(id) do update set payload=excluded.payload,checked_at=excluded.checked_at;

  return v_payload;
end;
$function$;

revoke all on function public.refresh_security_health_status_v1() from public, anon, authenticated;

select public.refresh_security_health_status_v1();

select cron.unschedule(jobid)
from cron.job
where jobname='kineo-security-health-30m';

select cron.schedule(
  'kineo-security-health-30m',
  '7,37 * * * *',
  $$select public.refresh_security_health_status_v1();$$
);
