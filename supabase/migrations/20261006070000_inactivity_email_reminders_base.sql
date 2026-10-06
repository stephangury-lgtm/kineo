create extension if not exists pg_cron with schema pg_catalog;
create extension if not exists pg_net with schema extensions;

alter table public.profiles
  add column if not exists last_seen_at timestamptz;

update public.profiles p
set last_seen_at = coalesce(u.last_sign_in_at, u.created_at, now())
from auth.users u
where u.id = p.id and p.last_seen_at is null;

create table if not exists public.inactivity_email_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  inactivity_anchor timestamptz not null,
  queued_at timestamptz not null default now(),
  provider text not null default 'resend',
  provider_request_id text,
  status text not null default 'queued' check (status in ('queued','sent','failed','skipped')),
  error_message text,
  created_at timestamptz not null default now(),
  unique(user_id, inactivity_anchor)
);

alter table public.inactivity_email_log enable row level security;
revoke all on public.inactivity_email_log from anon, authenticated;

create or replace function public.touch_user_activity_v1()
returns timestamptz
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_now timestamptz := now();
begin
  if v_uid is null then
    raise exception 'Utilisateur non authentifié';
  end if;

  update public.profiles
  set last_seen_at = v_now,
      updated_at = v_now
  where id = v_uid;

  return v_now;
end;
$$;

revoke all on function public.touch_user_activity_v1() from public, anon;
grant execute on function public.touch_user_activity_v1() to authenticated;

comment on column public.profiles.last_seen_at is 'Dernière activité réelle observée dans l application; utilisée pour les relances d inactivité.';
comment on table public.inactivity_email_log is 'Journal anti-doublon des relances e-mail après 24 h d inactivité.';
