-- Trigger inactivity reminder candidates only after 48 hours without activity.
-- Delivery remains disabled until the Resend API key and verified sender are configured.

create or replace function public.get_inactivity_email_candidates_v1()
returns table(
  user_id uuid,
  email text,
  first_name text,
  inactivity_anchor timestamptz,
  program_id text
)
language sql
security definer
set search_path=''
as $$
  select
    p.id,
    u.email::text,
    p.first_name,
    greatest(
      coalesce(p.last_seen_at, '-infinity'::timestamptz),
      coalesce(u.last_sign_in_at, '-infinity'::timestamptz),
      u.created_at
    ) as inactivity_anchor,
    pp.program_id
  from public.profiles p
  join auth.users u on u.id = p.id
  left join lateral (
    select x.program_id
    from public.profile_programs x
    where x.user_id = p.id
    order by x.is_primary desc, x.created_at asc
    limit 1
  ) pp on true
  where p.role = 'student'
    and u.email is not null
    and u.email_confirmed_at is not null
    and u.deleted_at is null
    and greatest(
      coalesce(p.last_seen_at, '-infinity'::timestamptz),
      coalesce(u.last_sign_in_at, '-infinity'::timestamptz),
      u.created_at
    ) <= now() - interval '48 hours'
    and not exists (
      select 1
      from public.inactivity_email_log l
      where l.user_id = p.id
        and l.inactivity_anchor = greatest(
          coalesce(p.last_seen_at, '-infinity'::timestamptz),
          coalesce(u.last_sign_in_at, '-infinity'::timestamptz),
          u.created_at
        )
        and l.status in ('queued','sent')
    );
$$;

revoke all on function public.get_inactivity_email_candidates_v1() from public, anon, authenticated;
grant execute on function public.get_inactivity_email_candidates_v1() to service_role;

comment on table public.inactivity_email_log is 'Journal anti-doublon des relances e-mail après 48 h d inactivité.';
