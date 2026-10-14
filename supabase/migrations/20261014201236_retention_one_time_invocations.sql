-- pg_net is platform-owned and may retain PUBLIC grants. Never put a reusable
-- credential in its request queue. Each invocation has one narrowly scoped ticket.
create table retention.invocations (
 token_hash text primary key,
 expires_at timestamptz not null
);
alter table retention.invocations enable row level security;
revoke all on retention.invocations from public,anon,authenticated;

create or replace function public.retention_worker_start_v1(p_token text) returns jsonb
language plpgsql security definer set search_path='' as $$
declare v_key text; v_from text; v_lease uuid:=gen_random_uuid();
begin
 if p_token is null or length(p_token)<>72 then return null; end if;
 delete from retention.invocations where token_hash=encode(sha256(convert_to(p_token,'UTF8')),'hex') and expires_at>now();
 if not found then return null; end if;
 update retention.worker set lease=v_lease,lease_until=now()+interval '10 minutes',last_run_at=now()
 where id and (lease_until is null or lease_until<now());
 if not found then return jsonb_build_object('busy',true); end if;
 select decrypted_secret into v_key from vault.decrypted_secrets
 where name in ('leryko_retention_resend_api_key','resend_api_key')
 order by (name='leryko_retention_resend_api_key') desc limit 1;
 select decrypted_secret into v_from from vault.decrypted_secrets
 where name in ('leryko_retention_from','kineo_inactivity_from')
 order by (name='leryko_retention_from') desc limit 1;
 return jsonb_build_object('lease',v_lease,'resend_key',v_key,'sender',v_from,
  'configured',coalesce(v_key,'')<>'' and coalesce(v_from,'')<>'');
end;
$$;

create or replace function retention.invoke_worker() returns bigint
language plpgsql security definer set search_path='' as $$
declare v_token text:=gen_random_uuid()::text||gen_random_uuid()::text; v_request bigint;
begin
 delete from retention.invocations where expires_at<now();
 insert into retention.invocations(token_hash,expires_at) values(encode(sha256(convert_to(v_token,'UTF8')),'hex'),now()+interval '2 minutes');
 select net.http_post(url:='https://kimtiyuytikyseuzmjbv.supabase.co/functions/v1/account-retention',
 headers:=jsonb_build_object('Content-Type','application/json','Authorization','Bearer '||v_token),
 body:='{}'::jsonb,timeout_milliseconds:=120000) into v_request;
 return v_request;
end;
$$;
-- Only remove the credential generated for the replaced implementation.
delete from vault.secrets where name='leryko_retention_worker_token';
revoke all on function public.retention_worker_start_v1(text) from public,anon,authenticated;
grant execute on function public.retention_worker_start_v1(text) to service_role;
revoke all on function retention.invoke_worker() from public,anon,authenticated;
