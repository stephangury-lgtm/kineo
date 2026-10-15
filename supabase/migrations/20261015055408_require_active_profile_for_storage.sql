-- JWT signatures can outlive account deletion. Re-check the current account.
-- Restrictive policies compose with the existing per-bucket/owner policies.
create policy storage_requires_current_profile on storage.objects
as restrictive for all to authenticated
using(exists(select 1 from public.profiles p where p.id=(select auth.uid())))
with check(exists(select 1 from public.profiles p where p.id=(select auth.uid())));

-- PostgREST executes this before table and RPC requests, including definers.
-- SECURITY INVOKER uses the existing own-profile SELECT policy.
create function public.require_current_profile_v1() returns void
language plpgsql security invoker set search_path='' as $$
begin
 if current_user='authenticated' and not exists(select 1 from public.profiles p where p.id=(select auth.uid())) then
  raise exception 'Compte indisponible' using errcode='42501';
 end if;
end; $$;
revoke all on function public.require_current_profile_v1() from public;
grant execute on function public.require_current_profile_v1() to anon,authenticated,service_role;
-- Never silently replace another project's security hook on restoration.
do $$ begin
 if exists(select 1 from pg_db_role_setting s join pg_roles r on r.oid=s.setrole
  cross join lateral unnest(s.setconfig) config where r.rolname='authenticator'
  and config like 'pgrst.db_pre_request=%' and config<>'pgrst.db_pre_request=public.require_current_profile_v1')
 then raise exception 'Existing pre-request hook must be reviewed before replacement'; end if;
end; $$;
alter role authenticator set pgrst.db_pre_request='public.require_current_profile_v1';
notify pgrst,'reload config';
notify pgrst,'reload schema';

