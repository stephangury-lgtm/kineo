-- Student beta scaling: dashboard, session resume and history filter by user.
create index if not exists idx_revision_sessions_user_started_at
  on public.revision_sessions(user_id, started_at desc);
