-- Only generated example.invalid identities, all changes rolled back.
begin;
set local statement_timeout='30s';
do $tests$
declare
 v_old uuid:=gen_random_uuid(); v_resume uuid:=gen_random_uuid();
 v_recent uuid:=gen_random_uuid(); v_admin uuid:=gen_random_uuid(); v_exempt uuid:=gen_random_uuid();
 v_lease uuid:=gen_random_uuid(); v_id uuid; v_notice jsonb; v_jobs jsonb; v_rejected boolean;
 v_ticket text:=gen_random_uuid()::text||gen_random_uuid()::text;
 v_friendship uuid:=gen_random_uuid(); v_social_notice uuid:=gen_random_uuid(); v_unrelated_notice uuid:=gen_random_uuid();
begin
 if has_function_privilege('anon','public.retention_worker_start_v1(text)','execute') or
    has_function_privilege('authenticated','public.retention_claim_delete_v1(uuid,uuid)','execute') or
    has_schema_privilege('authenticated','retention','usage') then raise exception 'Retention exposed to students'; end if;
 if public.retention_worker_start_v1(repeat('x',72)) is not null then raise exception 'Bad worker token accepted'; end if;
 insert into retention.invocations(token_hash,expires_at) values(encode(sha256(convert_to(v_ticket,'UTF8')),'hex'),now()+interval '2 minutes');
 if public.retention_worker_start_v1(v_ticket) is null then raise exception 'Valid invocation refused'; end if;
 if public.retention_worker_start_v1(v_ticket) is not null then raise exception 'Invocation replay accepted'; end if;
 v_ticket:=gen_random_uuid()::text||gen_random_uuid()::text;
 insert into retention.invocations(token_hash,expires_at) values(encode(sha256(convert_to(v_ticket,'UTF8')),'hex'),now()-interval '1 second');
 if public.retention_worker_start_v1(v_ticket) is not null then raise exception 'Expired invocation accepted'; end if;
 update retention.worker set lease=v_lease,lease_until=now()+interval '10 minutes' where id;
 perform set_config('kineo.internal_update','on',true);
 insert into auth.users(id,email,created_at,last_sign_in_at,email_confirmed_at,raw_user_meta_data,raw_app_meta_data)
 select id,'retention-test-'||id::text||'@example.invalid',now()-interval '25 months',
  case when id=v_recent then now() else now()-interval '25 months' end,
  now()-interval '25 months','{}',case when id=v_exempt then '{"retention_exempt":true}'::jsonb else '{}'::jsonb end
 from unnest(array[v_old,v_resume,v_recent,v_admin,v_exempt]) id;
 insert into public.profiles(id,role,study_year,last_seen_at)
 select id,case when id=v_admin then 'admin' else 'student' end,2,now()-interval '25 months'
 from unnest(array[v_old,v_resume,v_recent,v_admin,v_exempt]) id
 on conflict(id) do update set last_seen_at=excluded.last_seen_at,role=excluded.role;
 v_jobs:=public.retention_jobs_v1(v_lease);
 if not exists(select 1 from retention.notices where user_id=v_old) or
    exists(select 1 from retention.notices where user_id in (v_recent,v_admin,v_exempt)) then raise exception 'Eligibility failed'; end if;
 select id into v_id from retention.notices where user_id=v_old;
 if public.retention_claim_delete_v1(v_lease,v_id) is not null then raise exception 'Unwarned account claimed'; end if;
 perform public.retention_notice_result_v1(v_lease,v_id,'sending');
 perform public.retention_notice_result_v1(v_lease,v_id,'sent','fixture-email');
 if public.retention_claim_delete_v1(v_lease,v_id) is not null then raise exception 'Sent email treated as delivered'; end if;
 v_notice:=public.retention_notice_result_v1(v_lease,v_id,'delivered');
 if (v_notice->>'delete_after')::timestamptz<now()+interval '30 days' then raise exception 'Grace period shortened'; end if;
 if public.retention_claim_delete_v1(v_lease,v_id) is not null then raise exception 'Grace period bypassed'; end if;

 -- Student activity cancels a notice, regardless of its delivery status.
 update public.profiles set last_seen_at=now() where id=v_resume;
 if exists(select 1 from retention.notices where user_id=v_resume) then raise exception 'Activity did not cancel'; end if;
 -- Refreshing a session also cancels the notice.
 update public.profiles set last_seen_at=now()-interval '25 months' where id=v_resume;
 perform public.retention_jobs_v1(v_lease);
 insert into auth.sessions(id,user_id,created_at,refreshed_at)
 values(gen_random_uuid(),v_resume,now(),now());
 if exists(select 1 from retention.notices where user_id=v_resume) then raise exception 'Session did not cancel'; end if;
 delete from auth.sessions where user_id=v_resume;
 perform public.retention_jobs_v1(v_lease);
 -- Shared/course files must be reviewed, not erased automatically.
 insert into storage.objects(bucket_id,name,owner_id) values('documents','retention-fixture-'||v_resume::text,v_resume::text);
 update retention.notices set state='delivered',delivered_at=now()-interval '31 days',delete_after=now()-interval '1 day'
 where user_id=v_resume;
 select id into v_id from retention.notices where user_id=v_resume;
 if public.retention_claim_delete_v1(v_lease,v_id) is not null then raise exception 'Shared file account claimed'; end if;
 if not exists(select 1 from retention.notices where id=v_id and hold_reason='shared_or_unexpected_storage') then raise exception 'Missing manual storage hold'; end if;
 select id into v_id from retention.notices where user_id=v_old;
 -- An uncertain send outside the provider idempotency window blocks further sends.
 update retention.notices set state='sending',started_at=now()-interval '21 hours' where id=v_id;
 v_notice:=public.retention_notice_result_v1(v_lease,v_id,'sending');
 if v_notice is not null or
    not exists(select 1 from retention.notices where id=v_id and state='blocked') then raise exception 'Uncertain send retried too late'; end if;
 update retention.notices set state='delivered',hold_reason=null,delivered_at=now()-interval '31 days',delete_after=now()-interval '1 day' where id=v_id;
 v_notice:=public.retention_claim_delete_v1(v_lease,v_id);
 if v_notice->>'user_id'<>v_old::text then raise exception 'Eligible deletion not claimed'; end if;
 v_rejected:=false;
 begin update public.profiles set last_seen_at=now() where id=v_old; exception when others then v_rejected:=true; end;
 if not v_rejected then raise exception 'Late profile activity raced deletion'; end if;
 v_rejected:=false;
 begin update auth.users set last_sign_in_at=now() where id=v_old; exception when others then v_rejected:=true; end;
 if not v_rejected then raise exception 'Late sign-in raced deletion'; end if;
 v_rejected:=false;
 begin insert into storage.objects(bucket_id,name,owner_id) values('avatars',v_old::text||'/late.jpg',v_old::text); exception when others then v_rejected:=true; end;
 if not v_rejected then raise exception 'Late avatar raced deletion'; end if;
 v_rejected:=false;
 begin insert into auth.sessions(id,user_id,created_at,refreshed_at) values(gen_random_uuid(),v_old,now(),now()); exception when others then v_rejected:=true; end;
 if not v_rejected then raise exception 'Late session raced deletion'; end if;
 -- Expired jobs cannot continue destructive work.
 update retention.worker set lease_until=now()-interval '1 second' where id;
 v_rejected:=false;
 begin perform public.retention_claim_delete_v1(v_lease,v_id); exception when others then v_rejected:=true; end;
 if not v_rejected then raise exception 'Expired lease accepted'; end if;
 -- Cascades also remove identifying notifications delivered to a different account.
 insert into public.friendships(id,requester_id,addressee_id,status) values(v_friendship,v_old,v_recent,'accepted');
 insert into public.notifications(id,user_id,type,title,body,data) values
  (v_social_notice,v_recent,'friend_accepted','Fixture','Fixture name',jsonb_build_object('friendship_id',v_friendship)),
  (v_unrelated_notice,v_recent,'level_up','Fixture','Unrelated','{}');
 delete from auth.users where id=v_old;
 if exists(select 1 from public.profiles where id=v_old) or
    exists(select 1 from retention.notices where user_id=v_old) or
    exists(select 1 from public.notifications where id=v_social_notice) then raise exception 'Account references survived deletion'; end if;
 if not exists(select 1 from public.notifications where id=v_unrelated_notice) then raise exception 'Unrelated notification deleted'; end if;
end;
$tests$;
rollback;
