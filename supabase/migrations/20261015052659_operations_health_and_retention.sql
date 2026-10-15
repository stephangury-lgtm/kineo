create table app_security.operations_health_status(
 id smallint primary key check(id=1),
 payload jsonb not null,
 checked_at timestamptz not null default now()
);
alter table app_security.operations_health_status enable row level security;
revoke all on app_security.operations_health_status from public,anon,authenticated;

create function app_security.refresh_operations_health() returns jsonb
language plpgsql security definer set search_path='' as $$
declare v_checks jsonb; v_count integer; v_payload jsonb;
begin
 select jsonb_build_object(
 'retention_worker_stale',case when exists(select 1 from retention.worker where last_run_at>now()-interval '30 hours') then 0 else 1 end,
 'retention_worker_errors',coalesce((select (last_result->>'errors')::integer from retention.worker),0),
 'recent_cron_failures',(select count(*) from cron.job_run_details where start_time>now()-interval '1 hour' and status='failed'),
 'missing_course_objects',(select count(*) from public.course_documents d where d.storage_path like 'courses/local-courses-2026-10/%' and not exists(select 1 from storage.objects o where o.bucket_id='documents' and o.name=d.storage_path))
 ) into v_checks;
 select sum(value::integer) into v_count from jsonb_each_text(v_checks);
 v_payload:=jsonb_build_object('ok',v_count=0,'critical_count',v_count,'checks',v_checks,
  'retention_email_configured',coalesce((select (last_result->>'configured')::boolean from retention.worker),false),'generated_at',now());
 insert into app_security.operations_health_status(id,payload,checked_at) values(1,v_payload,now())
 on conflict(id) do update set payload=excluded.payload,checked_at=excluded.checked_at;
 return v_payload;
end; $$;
revoke all on function app_security.refresh_operations_health() from public,anon,authenticated;
select cron.schedule('leryko-operations-health-30m','12,42 * * * *',$$select app_security.refresh_operations_health()$$);
select app_security.refresh_operations_health();

-- Service-only RPC; no operational details or public grants.
create function public.check_operations_health_v1() returns boolean
language sql security invoker set search_path='' as $$
 select coalesce((select (payload->>'ok')::boolean and checked_at>now()-interval '90 minutes'
 from app_security.operations_health_status where id=1),false)
$$;
revoke all on function public.check_operations_health_v1() from public,anon,authenticated;
grant usage on schema app_security to service_role;
grant select on app_security.operations_health_status to service_role;
grant execute on function public.check_operations_health_v1() to service_role;
