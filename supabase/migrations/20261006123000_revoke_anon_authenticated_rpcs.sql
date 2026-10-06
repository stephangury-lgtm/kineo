-- Student beta hardening: authenticated/security-definer RPCs must not be executable by anon.
-- The functions themselves keep their existing auth / ownership checks.

do $$
begin
  revoke execute on function public.get_content_review_queue_v4() from public, anon;
  revoke execute on function public.get_curriculum_progress_v1(text) from public, anon;
  revoke execute on function public.get_friendships_v3(text) from public, anon;
  revoke execute on function public.notify_badge_earned_v1() from public, anon;
  revoke execute on function public.notify_level_up_v1() from public, anon;
  revoke execute on function public.notify_streak_milestone_v1() from public, anon;
  revoke execute on function public.search_students_v3(text,text) from public, anon;
  revoke execute on function public.submit_curriculum_daily_answer_v1(text,uuid,text) from public, anon;
  revoke execute on function public.submit_curriculum_topic_answer_v1(uuid,text) from public, anon;

  grant execute on function public.get_content_review_queue_v4() to authenticated, service_role;
  grant execute on function public.get_curriculum_progress_v1(text) to authenticated, service_role;
  grant execute on function public.get_friendships_v3(text) to authenticated, service_role;
  grant execute on function public.notify_badge_earned_v1() to authenticated, service_role;
  grant execute on function public.notify_level_up_v1() to authenticated, service_role;
  grant execute on function public.notify_streak_milestone_v1() to authenticated, service_role;
  grant execute on function public.search_students_v3(text,text) to authenticated, service_role;
  grant execute on function public.submit_curriculum_daily_answer_v1(text,uuid,text) to authenticated, service_role;
  grant execute on function public.submit_curriculum_topic_answer_v1(uuid,text) to authenticated, service_role;
end $$;
