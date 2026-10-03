-- Curriculum challenge RPCs are client-facing but require an authenticated user.
-- Keep the existing auth.uid() checks and remove anonymous/PUBLIC execution.

revoke execute on function public.create_curriculum_friend_challenge_v1(uuid,text) from public, anon;
revoke execute on function public.get_curriculum_friend_challenges_v1(text) from public, anon;
revoke execute on function public.respond_curriculum_friend_challenge_v1(uuid,boolean) from public, anon;
revoke execute on function public.cancel_curriculum_friend_challenge_v1(uuid) from public, anon;
revoke execute on function public.get_curriculum_friend_challenge_questions_v1(uuid) from public, anon;
revoke execute on function public.submit_curriculum_friend_challenge_answer_v1(uuid,uuid,text) from public, anon;

grant execute on function public.create_curriculum_friend_challenge_v1(uuid,text) to authenticated;
grant execute on function public.get_curriculum_friend_challenges_v1(text) to authenticated;
grant execute on function public.respond_curriculum_friend_challenge_v1(uuid,boolean) to authenticated;
grant execute on function public.cancel_curriculum_friend_challenge_v1(uuid) to authenticated;
grant execute on function public.get_curriculum_friend_challenge_questions_v1(uuid) to authenticated;
grant execute on function public.submit_curriculum_friend_challenge_answer_v1(uuid,uuid,text) to authenticated;
