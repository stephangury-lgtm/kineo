drop function if exists public.touch_last_seen_v1();

create index if not exists profiles_last_seen_at_idx
  on public.profiles(last_seen_at);

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
    ) <= now() - interval '24 hours'
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

create or replace function public.queue_inactivity_reminders_v1()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_resend_key text;
  v_from text;
  v_request_id bigint;
  v_count integer := 0;
  r record;
begin
  select decrypted_secret into v_resend_key
  from vault.decrypted_secrets
  where name = 'resend_api_key'
  limit 1;

  select decrypted_secret into v_from
  from vault.decrypted_secrets
  where name = 'kineo_inactivity_from'
  limit 1;

  if coalesce(v_resend_key,'') = '' or coalesce(v_from,'') = '' then
    return jsonb_build_object('configured', false, 'queued', 0);
  end if;

  for r in select * from public.get_inactivity_email_candidates_v1()
  loop
    select net.http_post(
      url := 'https://api.resend.com/emails',
      headers := jsonb_build_object(
        'Content-Type','application/json',
        'Authorization','Bearer ' || v_resend_key
      ),
      body := jsonb_build_object(
        'from', v_from,
        'to', jsonb_build_array(r.email),
        'template', jsonb_build_object(
          'id', 'kineo-inactivity-24h',
          'variables', jsonb_build_object(
            'USER_NAME', coalesce(nullif(r.first_name,''), 'à toi'),
            'APP_URL', 'https://kineo.stephangury.workers.dev'
          )
        )
      )
    ) into v_request_id;

    insert into public.inactivity_email_log(user_id,inactivity_anchor,provider_request_id,status)
    values(r.user_id,r.inactivity_anchor,v_request_id::text,'queued')
    on conflict (user_id,inactivity_anchor) do nothing;

    if found then v_count := v_count + 1; end if;
  end loop;

  return jsonb_build_object('configured', true, 'queued', v_count);
end;
$$;

revoke all on function public.queue_inactivity_reminders_v1() from public, anon, authenticated;
