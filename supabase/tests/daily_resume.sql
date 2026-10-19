BEGIN;
INSERT INTO auth.users(id,instance_id,aud,role,email,raw_app_meta_data,raw_user_meta_data,created_at,updated_at)
VALUES('ce200000-0000-4000-8000-000000000001','00000000-0000-0000-0000-000000000000','authenticated','authenticated','daily-resume-ce20@example.invalid','{}','{}',now(),now());
UPDATE public.profiles SET study_year=2 WHERE id='ce200000-0000-4000-8000-000000000001';
SELECT set_config('request.jwt.claim.sub','ce200000-0000-4000-8000-000000000001',true),set_config('request.jwt.claims','{"sub":"ce200000-0000-4000-8000-000000000001","role":"authenticated"}',true);
SET LOCAL ROLE authenticated;
SELECT public.start_daily_challenge_v2();
DO $check$ DECLARE a jsonb; BEGIN
a:=public.get_active_daily_revision_session_v1();
IF a IS NULL OR a->>'mode'<>'daily' OR (a->>'answered_count')::int<>0 THEN RAISE EXCEPTION 'Zero-answer daily resume missing'; END IF;
END $check$;
RESET ROLE;
UPDATE public.revision_session_questions SET answered_at=now() WHERE session_id=(public.get_active_daily_revision_session_v1()->>'id')::uuid AND display_order=1;
SET LOCAL ROLE authenticated;
DO $check$ BEGIN
IF (public.get_active_daily_revision_session_v1()->>'answered_count')::int<>1 THEN RAISE EXCEPTION 'Daily progress missing'; END IF;
END $check$;
RESET ROLE;
UPDATE public.revision_sessions SET abandoned_at=now() WHERE user_id='ce200000-0000-4000-8000-000000000001';
SET LOCAL ROLE authenticated;
DO $check$ BEGIN IF public.get_active_daily_revision_session_v1() IS NOT NULL THEN RAISE EXCEPTION 'Abandoned exposed'; END IF; END $check$;
RESET ROLE;
UPDATE public.revision_sessions SET abandoned_at=null,completed_at=now() WHERE user_id='ce200000-0000-4000-8000-000000000001';
SET LOCAL ROLE authenticated;
DO $check$ BEGIN IF public.get_active_daily_revision_session_v1() IS NOT NULL THEN RAISE EXCEPTION 'Completed exposed'; END IF; END $check$;
RESET ROLE;
UPDATE public.revision_sessions SET completed_at=null WHERE user_id='ce200000-0000-4000-8000-000000000001';
SELECT set_config('request.jwt.claim.sub','ce200000-0000-4000-8000-000000000099',true);
SET LOCAL ROLE authenticated;
DO $check$ BEGIN IF public.get_active_daily_revision_session_v1() IS NOT NULL THEN RAISE EXCEPTION 'Other owner exposed'; END IF; END $check$;
RESET ROLE;
SELECT set_config('request.jwt.claim.sub','',true),set_config('request.jwt.claims','{}',true);
SET LOCAL ROLE authenticated;
DO $check$ BEGIN IF public.get_active_daily_revision_session_v1() IS NOT NULL THEN RAISE EXCEPTION 'Unauthenticated exposed'; END IF; END $check$;
RESET ROLE;
ROLLBACK;
