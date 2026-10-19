-- Read-only daily resume lookup; preserves the separate daily completion/bonus path.
CREATE FUNCTION public.get_active_daily_revision_session_v1()
RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $function$
 SELECT jsonb_build_object('id',rs.id,'mode','daily','question_count',rs.question_count,
   'answered_count',(SELECT count(*) FROM public.revision_session_questions q WHERE q.session_id=rs.id AND q.answered_at IS NOT NULL),'started_at',rs.started_at)
 FROM public.revision_sessions rs
 JOIN public.daily_challenges dc ON dc.id=rs.daily_challenge_id
 JOIN public.profiles p ON p.id=rs.user_id
 WHERE rs.user_id=auth.uid() AND rs.completed_at IS NULL AND rs.abandoned_at IS NULL
 AND rs.challenge_id IS NULL AND dc.challenge_date=current_date AND dc.is_active
 AND dc.study_year=p.study_year
 AND NOT EXISTS(SELECT 1 FROM public.daily_challenge_attempts a WHERE a.user_id=rs.user_id AND a.challenge_id=dc.id)
 ORDER BY rs.started_at DESC LIMIT 1;
$function$;
REVOKE ALL ON FUNCTION public.get_active_daily_revision_session_v1() FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.get_active_daily_revision_session_v1() TO authenticated;
