with ranked as (
  select q.id,
         row_number() over (
           partition by q.chapter_id,q.type,lower(btrim(q.question_text))
           order by q.created_at asc,q.id
         ) as rn
  from public.questions q
  where q.is_published=true
    and q.validation_status='published'
)
update public.questions q
set is_published=false,
    validation_status='archived',
    metadata=coalesce(q.metadata,'{}'::jsonb)
      || jsonb_build_object(
        'stabilization_fix','archived_exact_duplicate',
        'stabilization_fix_at','2026-10-03'
      )
from ranked r
where q.id=r.id
  and r.rn>1
  and not exists (select 1 from public.question_attempts qa where qa.question_id=q.id)
  and not exists (select 1 from public.revision_session_questions rsq where rsq.question_id=q.id);
