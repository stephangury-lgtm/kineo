-- Apply only after the frontend using get_curriculum_quiz_questions_v1 is deployed.
-- Restrict table AND per-column grants, including any inherited PUBLIC grants.
revoke select on public.curriculum_quiz_questions from public, anon, authenticated;
revoke select (id,topic_id,question_text,explanation,options,difficulty,source_label,
  display_order,validation_status,is_published,created_at,updated_at,question_type,
  accepted_answers,image_url,metadata)
  on public.curriculum_quiz_questions from public, anon, authenticated;
notify pgrst, 'reload schema';
