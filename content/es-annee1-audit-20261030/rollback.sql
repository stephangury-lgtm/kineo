BEGIN;
UPDATE public.curriculum_quiz_questions SET is_published=false,updated_at=now() WHERE metadata->>'batch'='es-a1-audit-20261030';
UPDATE public.curriculum_lessons SET is_published=false,updated_at=now() WHERE id::text LIKE 'f7301030-2026-4000-8002-%';
UPDATE public.curriculum_topics SET is_active=false,updated_at=now() WHERE id::text LIKE 'f7301030-2026-4000-8001-%';
DO $$ BEGIN IF EXISTS(SELECT 1 FROM public.curriculum_topics WHERE id::text LIKE 'f7301030-%' AND is_active) OR EXISTS(SELECT 1 FROM public.curriculum_quiz_questions WHERE metadata->>'batch'='es-a1-audit-20261030' AND is_published) OR EXISTS(SELECT 1 FROM public.curriculum_lessons WHERE id::text LIKE 'f7301030-%' AND is_published) THEN RAISE EXCEPTION 'Rollback failed'; END IF; END $$;
COMMIT;
