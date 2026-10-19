-- Run with psql against an isolated staging database; the entire test is rolled back.
BEGIN;
\ir ../../supabase/migrations/20261019114426_stable_resume_question_progress.sql
DO $fixtures$ DECLARE u uuid:='ce190000-0000-4000-8000-000000000001'; s uuid:='ce190000-0000-4000-8000-000000000002'; BEGIN
INSERT INTO auth.users(id,instance_id,aud,role,email,raw_app_meta_data,raw_user_meta_data,created_at,updated_at) VALUES(u,'00000000-0000-0000-0000-000000000000','authenticated','authenticated','resume-ce19@example.invalid','{}','{}',now(),now());
UPDATE public.profiles SET study_year=2 WHERE id=u;
INSERT INTO public.revision_sessions(id,user_id,mode,question_count) VALUES(s,u,'smart',3);
INSERT INTO public.revision_session_questions(session_id,question_id,display_order)
SELECT s,q.id,row_number() over(order by q.difficulty,q.id)::int FROM (select id,difficulty from public.questions where is_published and validation_status='published' order by difficulty,id limit 3) q;
UPDATE public.revision_session_questions SET answered_at=now() WHERE session_id=s AND display_order=1;
END $fixtures$;
SELECT set_config('request.jwt.claim.sub','ce190000-0000-4000-8000-000000000001',true),set_config('request.jwt.claims','{"sub":"ce190000-0000-4000-8000-000000000001","role":"authenticated"}',true);
SET LOCAL ROLE authenticated;
DO $checks$ DECLARE ranks int[]; active jsonb; BEGIN
SELECT array_agg(display_order order by display_order) INTO ranks FROM public.get_quiz_questions_v4('ce190000-0000-4000-8000-000000000002');
IF ranks IS DISTINCT FROM ARRAY[2,3] THEN RAISE EXCEPTION 'Resume renumbered unanswered questions: %',ranks; END IF;
active:=public.get_active_revision_session_v1();
IF (active->>'answered_count')::int<>1 OR (active->>'question_count')::int<>3 THEN RAISE EXCEPTION 'Wrong active progress'; END IF;
IF EXISTS(SELECT 1 FROM public.get_quiz_questions_v4('ce190000-0000-4000-8000-000000000002') WHERE explanation IS NOT NULL OR metadata ?| ARRAY['answer','accepted_answers','correct_answer','is_correct','pairs'] OR jsonb_path_exists(question_options,'$[*].is_correct')) THEN RAISE EXCEPTION 'Answer leaked'; END IF;
END $checks$;
RESET ROLE;
UPDATE public.revision_session_questions SET answered_at=now() WHERE session_id='ce190000-0000-4000-8000-000000000002' AND display_order=2;
SET LOCAL ROLE authenticated;
DO $checks$ BEGIN
IF (SELECT array_agg(display_order) FROM public.get_quiz_questions_v4('ce190000-0000-4000-8000-000000000002')) IS DISTINCT FROM ARRAY[3] THEN RAISE EXCEPTION 'Second resume renumbered'; END IF;
END $checks$;
SELECT set_config('request.jwt.claim.sub','ce190000-0000-4000-8000-000000000099',true),set_config('request.jwt.claims','{"sub":"ce190000-0000-4000-8000-000000000099","role":"authenticated"}',true);
DO $checks$ DECLARE denied boolean:=false; BEGIN
BEGIN PERFORM public.get_quiz_questions_v4('ce190000-0000-4000-8000-000000000002'); EXCEPTION WHEN raise_exception THEN denied:=position('accès non autorisé' in SQLERRM)>0; END;
IF NOT denied THEN RAISE EXCEPTION 'Other owner not denied'; END IF;
END $checks$;
RESET ROLE;
SELECT set_config('request.jwt.claim.sub','ce190000-0000-4000-8000-000000000001',true),set_config('request.jwt.claims','{"sub":"ce190000-0000-4000-8000-000000000001","role":"authenticated"}',true);
UPDATE public.revision_sessions SET abandoned_at=now() WHERE id='ce190000-0000-4000-8000-000000000002';
SET LOCAL ROLE authenticated;
DO $checks$ DECLARE denied boolean:=false; BEGIN
BEGIN PERFORM public.get_quiz_questions_v4('ce190000-0000-4000-8000-000000000002'); EXCEPTION WHEN raise_exception THEN denied:=position('abandonnée' in SQLERRM)>0; END;
IF NOT denied THEN RAISE EXCEPTION 'Abandoned session not denied'; END IF;
END $checks$;
RESET ROLE;
SELECT true passed,5 checks;
ROLLBACK;
