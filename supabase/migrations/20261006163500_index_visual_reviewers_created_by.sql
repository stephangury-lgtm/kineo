-- Cover the remaining unindexed foreign key reported by the Supabase advisor.
create index if not exists idx_visual_reviewers_created_by
  on public.visual_reviewers(created_by);
