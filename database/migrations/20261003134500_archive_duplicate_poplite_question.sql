update public.questions
set is_published = false,
    validation_status = 'archived',
    metadata = coalesce(metadata, '{}'::jsonb)
      || jsonb_build_object('archive_reason','duplicate_published_question','archived_at','2026-10-03')
where question_text = 'Le poplité est décrit comme intra-capsulaire et extra-articulaire.'
  and difficulty = 2
  and explanation = 'C’est le trajet indiqué dans La correction.'
  and is_published = true
  and validation_status = 'published';
