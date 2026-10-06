-- Normalize the legacy S2-S4 lesson status after confirming every published lesson has source_files.
update public.curriculum_lessons l
set validation_status = 'source_validated',
    updated_at = now()
from public.curriculum_topics t
join public.curriculum_units u on u.id = t.unit_id
join public.academic_levels al on al.id = u.academic_level_id
where l.topic_id = t.id
  and u.program_id = 'ifsi-fr'
  and u.curriculum_version = '2026'
  and al.code in ('S2','S3','S4')
  and l.is_published = true
  and l.validation_status = 'published'
  and jsonb_array_length(coalesce(l.source_files,'[]'::jsonb)) > 0;
