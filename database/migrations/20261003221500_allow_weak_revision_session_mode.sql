-- Allow the targeted weak-points revision mode created by start_weak_revision_v1.
-- The RPC already used mode='weak', but revision_sessions_mode_check did not allow it.

alter table public.revision_sessions
  drop constraint if exists revision_sessions_mode_check;

alter table public.revision_sessions
  add constraint revision_sessions_mode_check
  check (
    mode = any (
      array[
        'smart'::text,
        'mix'::text,
        'mcq'::text,
        'true_false'::text,
        'fill_blank'::text,
        'matching'::text,
        'visual'::text,
        'clinical_case'::text,
        'translation'::text,
        'exam'::text,
        'daily'::text,
        'weak'::text
      ]
    )
  );
