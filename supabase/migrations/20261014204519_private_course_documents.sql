-- Serve existing, validated course PDFs through private Storage, never public URLs.
alter table public.course_documents add column if not exists file_sha256 text
 check(file_sha256 is null or file_sha256 ~ '^[a-f0-9]{64}$');
create or replace function public.get_course_document_v1(p_document_id uuid)
returns jsonb language plpgsql security definer set search_path='' as $$
declare v_doc jsonb;
begin
 if auth.uid() is null or not exists(select 1 from public.profiles where id=auth.uid()) then
  raise exception 'Utilisateur non authentifié';
 end if;
 select jsonb_build_object('id',d.id,'title',d.title,'file_name',d.file_name,
  'storage_path',d.storage_path,'mime_type',d.mime_type,'file_size',d.file_size)
 into v_doc from public.course_documents d
 where d.id=p_document_id and d.validation_status='validated' and d.mime_type='application/pdf'
  and exists(select 1 from storage.objects o where o.bucket_id='documents' and o.name=d.storage_path);
 if v_doc is null then raise exception 'Support indisponible'; end if;
 return v_doc;
end;
$$;
revoke all on function public.get_course_document_v1(uuid) from public,anon;
grant execute on function public.get_course_document_v1(uuid) to authenticated;

create or replace function public.get_course_documents_v1()
returns jsonb language plpgsql security definer set search_path='' as $$
begin
 if auth.uid() is null or not exists(select 1 from public.profiles where id=auth.uid()) then
  raise exception 'Utilisateur non authentifié';
 end if;
 return coalesce((select jsonb_agg(jsonb_build_object('id',d.id,'title',d.title,
  'file_name',d.file_name,'file_size',d.file_size) order by d.title)
 from public.course_documents d where d.validation_status='validated' and d.mime_type='application/pdf'
  and exists(select 1 from storage.objects o where o.bucket_id='documents' and o.name=d.storage_path)),'[]'::jsonb);
end;
$$;
revoke all on function public.get_course_documents_v1() from public,anon;
grant execute on function public.get_course_documents_v1() to authenticated;

-- Preserve the existing lesson API while adding stable document IDs and availability.
do $migration$
declare v_definition text; v_old text:='jsonb_build_object(''title'',cd.title,''validation_status'',cd.validation_status';
begin
 select pg_get_functiondef('public.get_lesson_v2(uuid)'::regprocedure) into v_definition;
 if position(v_old in v_definition)=0 then raise exception 'Lesson API changed: review document metadata patch'; end if;
 execute replace(v_definition,v_old,
  'jsonb_build_object(''id'',cd.id,''available'',(cd.validation_status=''validated'' and exists(select 1 from storage.objects o where o.bucket_id=''documents'' and o.name=cd.storage_path)),''title'',cd.title,''validation_status'',cd.validation_status');
end;
$migration$;
