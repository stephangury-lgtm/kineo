update public.curriculum_quiz_questions q
set validation_status='source_validated',updated_at=now()
from public.curriculum_topics t,public.curriculum_units u
where q.topic_id=t.id
  and t.unit_id=u.id
  and u.program_id='ifsi-fr'
  and u.curriculum_version='2026'
  and q.is_published=true
  and q.validation_status='published'
  and coalesce(q.source_label,'')<>'';
