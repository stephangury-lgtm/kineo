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
declare v_payload jsonb;
begin
  select public.get_release_health_v1() into v_payload;

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
