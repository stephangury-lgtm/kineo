-- RLS does not protect TRUNCATE. Clients never need DDL-related table rights.
revoke truncate, references, trigger on all tables in schema public from public, anon, authenticated;
alter default privileges for role postgres in schema public revoke truncate, references, trigger on tables from public, anon, authenticated;
-- New RPCs must opt in to each client role explicitly.
alter default privileges for role postgres in schema public revoke execute on functions from public, anon, authenticated;

create schema if not exists app_security;
revoke all on schema app_security from public, anon, authenticated;
create table app_security.request_windows (
 user_id uuid not null references auth.users(id) on delete cascade,
 action text not null,
 window_start timestamptz not null,
 requests integer not null,
 primary key(user_id,action,window_start)
);
alter table app_security.request_windows enable row level security;
revoke all on app_security.request_windows from public, anon, authenticated;

-- Counts are incremented atomically, including when inserts arrive concurrently.
-- Only successful writes consume quota; rejected statements roll back their count.
create function app_security.limit_client_writes() returns trigger
language plpgsql security definer set search_path='' as $$
declare v_uid uuid:=auth.uid(); v_window timestamptz; v_count integer;
 v_seconds integer:=tg_argv[0]::integer; v_limit integer:=tg_argv[1]::integer;
begin
 if v_uid is null then return new; end if;
 if not exists(select 1 from public.profiles where id=v_uid) then
  raise exception 'Compte indisponible' using errcode='42501';
 end if;
 v_window:=to_timestamp(floor(extract(epoch from statement_timestamp())/v_seconds)*v_seconds);
 insert into app_security.request_windows as w(user_id,action,window_start,requests)
 values(v_uid,tg_table_name,v_window,1)
 on conflict(user_id,action,window_start) do update set requests=w.requests+1
 returning requests into v_count;
 if v_count>v_limit then raise exception 'Trop de demandes. Réessaie dans quelques instants.' using errcode='P0001'; end if;
 return new;
end; $$;
revoke all on function app_security.limit_client_writes() from public,anon,authenticated;
create trigger limit_revision_sessions before insert on public.revision_sessions for each row execute function app_security.limit_client_writes('60','20');
create trigger limit_friend_requests before insert on public.friendships for each row execute function app_security.limit_client_writes('3600','30');
create trigger limit_feedback before insert on public.feedback for each row execute function app_security.limit_client_writes('3600','30');
create trigger limit_client_errors before insert on public.client_error_logs for each row execute function app_security.limit_client_writes('3600','20');
create trigger limit_notes before insert or update on public.user_notes for each row execute function app_security.limit_client_writes('60','60');
create trigger limit_curriculum_answers before insert on public.curriculum_question_attempts for each row execute function app_security.limit_client_writes('60','240');

-- Operational counters contain no payload and are retained for at most two days.
select cron.schedule('leryko-security-counter-cleanup','25 3 * * *',
 $$delete from app_security.request_windows where window_start < now()-interval '1 day'$$);

create or replace function public.refresh_security_health_status_v1() returns jsonb
language plpgsql security definer set search_path='' as $$
declare v_payload jsonb; v_checks jsonb; v_count integer;
begin
 select jsonb_build_object(
  'anon_security_definer_executable',(select count(*) from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.prosecdef and has_function_privilege('anon',p.oid,'execute')),
  'unpinned_security_definer_search_path',(select count(*) from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.prosecdef and not exists(select 1 from unnest(p.proconfig) x where x like 'search_path=%')),
  'client_truncate_grants',(select count(*) from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and c.relkind in ('r','p') and (has_table_privilege('anon',c.oid,'truncate') or has_table_privilege('authenticated',c.oid,'truncate'))),
  'public_tables_without_rls',(select count(*) from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and c.relkind in ('r','p') and not c.relrowsecurity),
  'public_course_bucket',(select count(*) from storage.buckets where id='documents' and public)
 ) into v_checks;
 select sum(value::integer) into v_count from jsonb_each_text(v_checks);
 v_payload:=jsonb_build_object('ok',v_count=0,'critical_count',v_count,'checks',v_checks,'generated_at',now());
 insert into public.security_health_status(id,payload,checked_at) values(1,v_payload,now())
 on conflict(id) do update set payload=excluded.payload,checked_at=excluded.checked_at;
 return v_payload;
end; $$;
revoke all on function public.refresh_security_health_status_v1() from public,anon,authenticated;
select public.refresh_security_health_status_v1();
