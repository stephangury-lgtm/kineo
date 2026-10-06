-- Disable the legacy topic-answer RPC that predates active level/reference checks.
-- The application uses submit_curriculum_topic_answer_v2 exclusively.
revoke execute on function public.submit_curriculum_topic_answer_v1(uuid,text) from public;
revoke execute on function public.submit_curriculum_topic_answer_v1(uuid,text) from anon;
revoke execute on function public.submit_curriculum_topic_answer_v1(uuid,text) from authenticated;

grant execute on function public.submit_curriculum_topic_answer_v2(uuid,jsonb) to authenticated;
