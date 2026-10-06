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
  v_html text;
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

  for r in
    select u.id as user_id,
           u.email,
           coalesce(nullif(p.first_name,''), 'toi') as first_name,
           p.last_seen_at as inactivity_anchor
    from auth.users u
    join public.profiles p on p.id = u.id
    where u.email is not null
      and u.email_confirmed_at is not null
      and u.deleted_at is null
      and p.last_seen_at is not null
      and p.last_seen_at <= now() - interval '24 hours'
      and not exists (
        select 1
        from public.inactivity_email_log l
        where l.user_id = u.id
          and l.inactivity_anchor = p.last_seen_at
      )
  loop
    v_html := '<!doctype html><html><body style="margin:0;background:#f5f7fb;font-family:-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Arial,sans-serif;color:#172033">'
      || '<div style="max-width:560px;margin:0 auto;padding:32px 16px">'
      || '<div style="background:#ffffff;border-radius:22px;padding:32px;box-shadow:0 12px 40px rgba(15,23,42,.08)">'
      || '<div style="display:flex;align-items:center;gap:12px;margin-bottom:26px">'
      || '<div style="width:44px;height:44px;border-radius:13px;background:#2563eb;color:#fff;font-size:24px;font-weight:800;line-height:44px;text-align:center">K</div>'
      || '<div><div style="font-size:20px;font-weight:800;letter-spacing:.2px">KINÉO</div><div style="font-size:12px;color:#64748b">Révise. Progresse.</div></div></div>'
      || '<h1 style="font-size:26px;line-height:1.2;margin:0 0 14px">On reprend, ' || replace(r.first_name,'<','&lt;') || ' ? 👋</h1>'
      || '<p style="font-size:16px;line-height:1.65;color:#475569;margin:0 0 22px">Cela fait un peu plus de 24 h que tu n''as pas ouvert KINÉO. Une courte session suffit pour reprendre ta progression, ton challenge du jour ou tes révisions.</p>'
      || '<a href="https://kineo.stephangury.workers.dev" style="display:inline-block;background:#2563eb;color:#ffffff;text-decoration:none;font-weight:800;padding:14px 22px;border-radius:12px">Reprendre mes révisions</a>'
      || '<p style="font-size:13px;line-height:1.5;color:#94a3b8;margin:28px 0 0">À bientôt dans KINÉO.</p>'
      || '</div></div></body></html>';

    select net.http_post(
      url := 'https://api.resend.com/emails',
      headers := jsonb_build_object(
        'Content-Type','application/json',
        'Authorization','Bearer ' || v_resend_key
      ),
      body := jsonb_build_object(
        'from', v_from,
        'to', jsonb_build_array(r.email),
        'subject', 'Tes révisions KINÉO t’attendent 👋',
        'html', v_html
      )
    ) into v_request_id;

    insert into public.inactivity_email_log(user_id,inactivity_anchor,provider_request_id,status)
    values(r.user_id,r.inactivity_anchor,v_request_id::text,'queued')
    on conflict (user_id,inactivity_anchor) do nothing;

    v_count := v_count + 1;
  end loop;

  return jsonb_build_object('configured', true, 'queued', v_count);
end;
$$;

revoke all on function public.queue_inactivity_reminders_v1() from public, anon, authenticated;

select cron.unschedule(jobid)
from cron.job
where jobname = 'kineo-inactivity-reminder-hourly';

select cron.schedule(
  'kineo-inactivity-reminder-hourly',
  '15 * * * *',
  $$select public.queue_inactivity_reminders_v1();$$
);
