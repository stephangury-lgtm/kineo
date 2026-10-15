-- Test with actual client role, not merely a forged auth.uid() as postgres.
-- All fixtures and quota counters are rolled back.
begin;
set local statement_timeout='25s';
do $test$
declare a uuid:=gen_random_uuid(); b uuid:=gen_random_uuid(); l uuid; n uuid;
 s uuid; x uuid; rejected boolean; i integer; before_count integer;
begin
 if exists(select 1 from pg_class c join pg_namespace ns on ns.oid=c.relnamespace
  where ns.nspname='public' and c.relkind='r' and
   (has_table_privilege('anon',c.oid,'truncate') or has_table_privilege('authenticated',c.oid,'truncate')))
 then raise exception 'Client TRUNCATE privilege'; end if;
 insert into auth.users(id,email,raw_user_meta_data,raw_app_meta_data) values
 (a,'isolation-'||a||'@example.invalid','{}','{}'),(b,'isolation-'||b||'@example.invalid','{}','{}');
 select id into l from public.lessons where is_published limit 1;
 if l is null then raise exception 'Missing lesson fixture'; end if;
 insert into public.user_notes(user_id,lesson_id,content) values(b,l,'private B') returning id into n;
 insert into public.revision_sessions(user_id,mode,question_count) values(b,'mix',0) returning id into s;
 insert into public.notifications(user_id,type,title,body) values(b,'test','private B','private B') returning id into x;
 perform set_config('request.jwt.claim.sub',a::text,true);
 execute 'set local role authenticated';
 if exists(select 1 from public.profiles where id=b) or exists(select 1 from public.user_notes where id=n)
 or exists(select 1 from public.revision_sessions where id=s) or exists(select 1 from public.notifications where id=x)
 then raise exception 'Other account visible'; end if;
 update public.user_notes set content='tampered' where id=n;
 if found then raise exception 'Other account note changed'; end if;
 update public.notifications set read_at=now() where id=x;
 if found then raise exception 'Other account notification changed'; end if;
 rejected:=false;
 begin insert into public.user_notes(user_id,lesson_id,content) values(b,l,'forged');
 exception when insufficient_privilege then rejected:=true; end;
 if not rejected then raise exception 'Foreign owner insert accepted'; end if;
 rejected:=false;
 begin perform public.update_user_progress(a,1000000); exception when insufficient_privilege then rejected:=true; end;
 if not rejected then raise exception 'Direct XP grant available'; end if;
 rejected:=false;
 begin perform public.get_content_review_queue_v4(); exception when others then
  if sqlerrm not like '%administrateur%' then raise; end if; rejected:=true; end;
 if not rejected then raise exception 'Student can read admin review queue'; end if;
 rejected:=false;
 begin perform public.publish_lesson_bundle_v1(l); exception when others then
  if sqlerrm not like '%Admin access%' then raise; end if; rejected:=true; end;
 if not rejected then raise exception 'Student can publish'; end if;
 if public.get_revision_session_meta_v1(s) is not null then raise exception 'Foreign session metadata'; end if;
 -- The permitted path still works and cannot transfer ownership.
 perform public.save_lesson_note_v1(l,'private A');
 rejected:=false;
 begin update public.user_notes set user_id=b where user_id=a;
 exception when insufficient_privilege then rejected:=true; end;
 if not rejected then raise exception 'Owner reassignment accepted'; end if;
 -- RPC writes are limited; direct feedback writes must also be denied.
 for i in 1..30 loop perform public.submit_feedback_v1('bug','isolation test feedback','/test'); end loop;
 rejected:=false;
 begin perform public.submit_feedback_v1('bug','isolation test overflow','/test');
 exception when others then if sqlerrm not like '%Limite%' and sqlerrm not like '%Trop de demandes%' then raise; end if; rejected:=true; end;
 if not rejected then raise exception 'Feedback quota ignored'; end if;
 rejected:=false;
 begin insert into public.feedback(user_id,kind,message,page_path) values(a,'bug','direct overflow test','/test');
 exception when insufficient_privilege then rejected:=true;
 when others then if sqlerrm not like '%Trop de demandes%' then raise; end if; rejected:=true; end;
 if not rejected then raise exception 'Direct write bypassed feedback quota'; end if;
 execute 'reset role';
 if (select content from public.user_notes where id=n)<>'private B' then raise exception 'B changed'; end if;
end;
$test$;
rollback;
