-- Server-only retention state. No account is deleted by this migration.
-- pg_net stores outgoing Authorization headers until dispatch: keep its queue private.
revoke all on net.http_request_queue from public,anon,authenticated;
create schema if not exists retention;
revoke all on schema retention from public, anon, authenticated;
create table retention.notices (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null unique references auth.users(id) on delete cascade,
 anchor timestamptz not null,
 recipient text not null,
 state text not null default 'pending' check(state in ('pending','sending','sent','delivered','blocked','deleting')),
 started_at timestamptz,
 provider_id text,
 delivered_at timestamptz,
 delete_after timestamptz,
 hold_reason text,
 updated_at timestamptz not null default now()
);
alter table retention.notices enable row level security;
revoke all on retention.notices from public, anon, authenticated;
create table retention.worker (
 id boolean primary key default true check(id),
 lease uuid,
 lease_until timestamptz,
 last_run_at timestamptz,
 last_result jsonb
);
insert into retention.worker(id) values(true);
alter table retention.worker enable row level security;
revoke all on retention.worker from public, anon, authenticated;

create function retention.activity(p_user uuid) returns timestamptz
language sql stable security definer set search_path='' as $$
 select greatest(u.created_at,u.last_sign_in_at,p.last_seen_at,
   (select max(greatest(s.created_at,s.refreshed_at)) from auth.sessions s where s.user_id=u.id))
 from auth.users u left join public.profiles p on p.id=u.id where u.id=p_user;
$$;

create function retention.check_lease(p_lease uuid) returns void
language plpgsql security definer set search_path='' as $$
begin
 if not exists(select 1 from retention.worker where lease=p_lease and lease_until>now()) then
  raise exception 'Retention worker lease expired';
 end if;
end;
$$;

-- Activity wins until deletion has been claimed. Afterwards reject a late activity
-- update rather than allowing it to race binary cleanup and Auth deletion.
create function retention.cancel_on_activity() returns trigger
language plpgsql security definer set search_path='' as $$
begin
 if (tg_table_schema='public' and (new.last_seen_at is distinct from old.last_seen_at or new.role is distinct from old.role)) then
  if exists(select 1 from retention.notices where user_id=new.id and state='deleting') then
   raise exception 'Account deletion in progress';
  end if;
  delete from retention.notices where user_id=new.id;
 end if;
 return new;
end;
$$;
create trigger retention_profile_activity before update of last_seen_at,role on public.profiles
 for each row execute function retention.cancel_on_activity();

create function retention.cancel_on_auth_activity() returns trigger
language plpgsql security definer set search_path='' as $$
begin
 if new.last_sign_in_at is distinct from old.last_sign_in_at or new.email is distinct from old.email then
  if exists(select 1 from retention.notices where user_id=new.id and state='deleting') then
   raise exception 'Account deletion in progress';
  end if;
  delete from retention.notices where user_id=new.id;
 end if;
 return new;
end;
$$;
create trigger retention_auth_activity before update of last_sign_in_at,email on auth.users
 for each row execute function retention.cancel_on_auth_activity();

create function retention.cancel_on_session_activity() returns trigger
language plpgsql security definer set search_path='' as $$
begin
 if tg_op='INSERT' or new.refreshed_at is distinct from old.refreshed_at then
  perform 1 from auth.users where id=new.user_id for key share;
  if exists(select 1 from retention.notices where user_id=new.user_id and state='deleting') then
   raise exception 'Account deletion in progress';
  end if;
  delete from retention.notices where user_id=new.user_id;
 end if;
 return new;
end;
$$;
create trigger retention_session_activity before insert or update of refreshed_at on auth.sessions
 for each row execute function retention.cancel_on_session_activity();

create function retention.guard_storage() returns trigger
language plpgsql security definer set search_path='' as $$
begin
 perform 1 from auth.users u where new.owner=u.id or new.owner_id=u.id::text or
  (new.bucket_id='avatars' and split_part(new.name,'/',1)=u.id::text) for key share;
 if exists(select 1 from retention.notices n where n.state='deleting' and
  (new.owner_id=n.user_id::text or new.owner=n.user_id or
   (new.bucket_id='avatars' and split_part(new.name,'/',1)=n.user_id::text))) then
  raise exception 'Account deletion in progress';
 end if;
 return new;
end;
$$;
create trigger retention_storage_guard before insert or update on storage.objects
 for each row execute function retention.guard_storage();

create function public.retention_worker_start_v1(p_token text) returns jsonb
language plpgsql security definer set search_path='' as $$
declare v_token text; v_key text; v_from text; v_lease uuid:=gen_random_uuid();
begin
 select decrypted_secret into v_token from vault.decrypted_secrets where name='leryko_retention_worker_token';
 if v_token is null or p_token is null or length(p_token)<40 or p_token<>v_token then
  return null;
 end if;
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

create function public.retention_worker_finish_v1(p_lease uuid,p_result jsonb) returns void
language plpgsql security definer set search_path='' as $$
begin
 update retention.worker set lease=null,lease_until=null,last_result=p_result where lease=p_lease;
end;
$$;

create function public.retention_jobs_v1(p_lease uuid) returns jsonb
language plpgsql security definer set search_path='' as $$
begin
 perform retention.check_lease(p_lease);
 delete from retention.notices n where n.state<>'deleting' and
  (retention.activity(n.user_id)>n.anchor or not exists
   (select 1 from public.profiles p join auth.users u on u.id=p.id where p.id=n.user_id
    and p.role='student' and u.email=n.recipient and u.email_confirmed_at is not null and u.deleted_at is null));
 insert into retention.notices(user_id,anchor,recipient)
 select u.id,retention.activity(u.id),u.email from auth.users u join public.profiles p on p.id=u.id
 where p.role='student' and u.email_confirmed_at is not null and u.deleted_at is null
  and coalesce(u.is_anonymous,false)=false and coalesce(u.is_sso_user,false)=false
  and coalesce(u.raw_app_meta_data->>'retention_exempt','false')<>'true'
  and retention.activity(u.id)<=now()-interval '24 months'
  and not exists(select 1 from retention.notices n where n.user_id=u.id)
 order by retention.activity(u.id) limit 5 on conflict(user_id) do nothing;
 return coalesce((select jsonb_agg(to_jsonb(n)) from
  (select * from retention.notices where hold_reason is null and state<>'blocked'
   order by updated_at limit 10) n),'[]'::jsonb);
end;
$$;

create function public.retention_notice_result_v1(p_lease uuid,p_id uuid,p_event text,p_provider_id text default null)
returns jsonb language plpgsql security definer set search_path='' as $$
declare n retention.notices;
begin
 perform retention.check_lease(p_lease);
 select * into n from retention.notices where id=p_id for update;
 if not found then return null; end if;
 if n.state='deleting' or n.hold_reason is not null then return null; end if;
 if retention.activity(n.user_id)>n.anchor then delete from retention.notices where id=p_id; return null; end if;
 if p_event='sending' and n.state in ('pending','sending') then
  if n.started_at is not null and n.started_at<now()-interval '20 hours' then
   update retention.notices set state='blocked',hold_reason='send_confirmation_missing',updated_at=now() where id=p_id;
   return null;
  end if;
  update retention.notices set state='sending',started_at=coalesce(started_at,now()),updated_at=now() where id=p_id;
 elsif p_event='sent' and n.state='sending' and coalesce(p_provider_id,'')<>'' then
  update retention.notices set state='sent',provider_id=p_provider_id,updated_at=now() where id=p_id;
 elsif p_event='delivered' and n.state in ('sent','delivered') then
  update retention.notices set state='delivered',delivered_at=coalesce(delivered_at,now()),
   delete_after=coalesce(delete_after,now()+interval '30 days'),updated_at=now() where id=p_id;
 elsif p_event='blocked' then
  update retention.notices set state='blocked',hold_reason='email_delivery_failed',updated_at=now() where id=p_id;
 else raise exception 'Invalid retention transition'; end if;
 return (select to_jsonb(q) from retention.notices q where id=p_id);
end;
$$;

create function public.retention_claim_delete_v1(p_lease uuid,p_id uuid) returns jsonb
language plpgsql security definer set search_path='' as $$
declare n retention.notices; v_user uuid;
begin
 perform retention.check_lease(p_lease);
 select user_id into v_user from retention.notices where id=p_id;
 if v_user is null then return null; end if;
 perform 1 from auth.users where id=v_user for update;
 perform 1 from public.profiles where id=v_user for update;
 select * into n from retention.notices where id=p_id for update;
 if not found or n.hold_reason is not null then return null; end if;
 if not exists(select 1 from auth.users u join public.profiles p on p.id=u.id
  where u.id=v_user and p.role='student' and u.email=n.recipient and u.email_confirmed_at is not null
  and u.deleted_at is null and coalesce(u.raw_app_meta_data->>'retention_exempt','false')<>'true') then return null; end if;
 if n.state<>'deleting' then
  if n.state<>'delivered' or n.delivered_at is null or n.delete_after is null or n.delete_after>now()
    or retention.activity(v_user)>n.anchor or retention.activity(v_user)>now()-interval '24 months' then return null; end if;
 end if;
 if exists(select 1 from storage.objects o where (o.owner=v_user or o.owner_id=v_user::text)
   and (o.bucket_id<>'avatars' or split_part(o.name,'/',1)<>v_user::text)) then
  update retention.notices set hold_reason='shared_or_unexpected_storage',updated_at=now() where id=p_id;
  return null;
 end if;
 update retention.notices set state='deleting',updated_at=now() where id=p_id;
 -- Refresh tokens cannot be used after this point; the Auth API removes the identity.
 delete from auth.sessions where user_id=v_user;
 return jsonb_build_object('user_id',v_user,'avatars',coalesce((select jsonb_agg(name) from
  (select name from storage.objects where bucket_id='avatars' and split_part(name,'/',1)=v_user::text limit 100) o),'[]'::jsonb));
end;
$$;

-- Only the worker can call these wrappers. Internal helpers and state are private.
revoke all on all functions in schema retention from public,anon,authenticated;
revoke all on function public.retention_worker_start_v1(text),public.retention_worker_finish_v1(uuid,jsonb),
 public.retention_jobs_v1(uuid),public.retention_notice_result_v1(uuid,uuid,text,text),
 public.retention_claim_delete_v1(uuid,uuid) from public,anon,authenticated;
grant execute on function public.retention_worker_start_v1(text),public.retention_worker_finish_v1(uuid,jsonb),
 public.retention_jobs_v1(uuid),public.retention_notice_result_v1(uuid,uuid,text,text),
 public.retention_claim_delete_v1(uuid,uuid) to service_role;

-- The worker token never appears in source, job text, or client-visible settings.
do $$ begin
 if not exists(select 1 from vault.secrets where name='leryko_retention_worker_token') then
  perform vault.create_secret(gen_random_uuid()::text||gen_random_uuid()::text,'leryko_retention_worker_token');
 end if;
end $$;
create function retention.invoke_worker() returns bigint
language plpgsql security definer set search_path='' as $$
declare v_token text; v_request bigint;
begin
 select decrypted_secret into v_token from vault.decrypted_secrets where name='leryko_retention_worker_token';
 select net.http_post(url:='https://kimtiyuytikyseuzmjbv.supabase.co/functions/v1/account-retention',
 headers:=jsonb_build_object('Content-Type','application/json','Authorization','Bearer '||v_token),
 body:='{}'::jsonb,timeout_milliseconds:=120000) into v_request;
 return v_request;
end;
$$;
revoke all on function retention.invoke_worker() from public,anon,authenticated;
select cron.schedule('leryko-account-retention-daily','10 3 * * *','select retention.invoke_worker();');
