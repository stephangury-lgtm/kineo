create table if not exists public.client_error_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  message text not null,
  component_stack text,
  page_path text,
  app_version text,
  created_at timestamptz not null default now()
);

alter table public.client_error_logs enable row level security;
revoke all on public.client_error_logs from anon, authenticated;

create index if not exists client_error_logs_user_created_idx
  on public.client_error_logs(user_id, created_at desc);
create index if not exists client_error_logs_created_idx
  on public.client_error_logs(created_at desc);

create or replace function public.report_client_error_v1(
  p_message text,
  p_component_stack text default null,
  p_page_path text default null,
  p_app_version text default null
)
returns uuid
language plpgsql
security definer
set search_path=''
as $$
declare
  v_uid uuid:=auth.uid();
  v_id uuid;
  v_recent integer;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  if length(trim(coalesce(p_message,'')))=0 then raise exception 'Message d’erreur vide'; end if;
  select count(*) into v_recent from public.client_error_logs
  where user_id=v_uid and created_at>=now()-interval '1 hour';
  if v_recent>=20 then return null; end if;

  insert into public.client_error_logs(user_id,message,component_stack,page_path,app_version)
  values(v_uid,left(trim(p_message),1000),left(nullif(p_component_stack,''),5000),left(nullif(p_page_path,''),500),left(nullif(p_app_version,''),100))
  returning id into v_id;
  return v_id;
end;
$$;

create or replace function public.get_client_error_logs_v1(p_limit integer default 100)
returns jsonb
language plpgsql
security definer
set search_path=''
as $$
declare v_result jsonb;
begin
  if auth.uid() is null or not public.is_admin() then raise exception 'Accès administrateur requis'; end if;
  p_limit:=least(200,greatest(1,coalesce(p_limit,100)));
  select coalesce(jsonb_agg(jsonb_build_object(
    'id',x.id,'message',x.message,'component_stack',x.component_stack,
    'page_path',x.page_path,'app_version',x.app_version,'created_at',x.created_at,
    'user',jsonb_build_object('first_name',x.first_name,'username',x.username)
  ) order by x.created_at desc),'[]'::jsonb)
  into v_result
  from (
    select e.*,p.first_name,p.username
    from public.client_error_logs e
    left join public.profiles p on p.id=e.user_id
    order by e.created_at desc
    limit p_limit
  ) x;
  return v_result;
end;
$$;

revoke all on function public.report_client_error_v1(text,text,text,text) from public,anon;
revoke all on function public.get_client_error_logs_v1(integer) from public,anon;
grant execute on function public.report_client_error_v1(text,text,text,text) to authenticated,service_role;
grant execute on function public.get_client_error_logs_v1(integer) to authenticated,service_role;
