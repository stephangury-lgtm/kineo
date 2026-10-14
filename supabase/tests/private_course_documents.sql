-- Exercise permissions using only a new fixture account, then roll back.
begin;
do $tests$
declare v_user uuid:=gen_random_uuid();v_doc uuid;v_result jsonb;v_rejected boolean;
begin
 if has_function_privilege('anon','public.get_course_document_v1(uuid)','execute') or
    has_function_privilege('anon','public.get_course_documents_v1()','execute') then raise exception 'Anonymous document API enabled'; end if;
 if (select public from storage.buckets where id='documents') then raise exception 'Course bucket must stay private'; end if;
 insert into auth.users(id,email,raw_user_meta_data,raw_app_meta_data)
 values(v_user,'course-test-'||v_user::text||'@example.invalid','{}','{}');
 perform set_config('request.jwt.claim.sub',v_user::text,true);
 execute 'set local role authenticated';
 v_result:=public.get_course_documents_v1();
 if jsonb_array_length(v_result)<>24 then raise exception 'Expected all 24 private course PDFs'; end if;
 select id into v_doc from public.course_documents where storage_path like 'courses/local-courses-2026-10/%' limit 1;
 v_result:=public.get_course_document_v1(v_doc);
 if v_result->>'storage_path' not like 'courses/local-courses-2026-10/%' then raise exception 'Document points outside private import'; end if;
 v_rejected:=false;
 begin perform public.get_course_document_v1(gen_random_uuid()); exception when others then v_rejected:=true; end;
 if not v_rejected then raise exception 'Unknown document accepted'; end if;
 -- An authenticated JWT with no current profile is not enough to obtain a URL.
 perform set_config('request.jwt.claim.sub',gen_random_uuid()::text,true);
 v_rejected:=false;
 begin perform public.get_course_documents_v1(); exception when others then v_rejected:=true; end;
 if not v_rejected then raise exception 'Missing account accepted'; end if;
 execute 'reset role';
end;
$tests$;
rollback;
