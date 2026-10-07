revoke execute on function public.get_friend_leaderboard_v1() from authenticated;
revoke execute on function public.get_friendships_v2() from authenticated;
revoke execute on function public.get_friend_challenges_v2() from authenticated;
revoke execute on function public.submit_quiz_answer_v4(uuid,uuid,jsonb,integer) from authenticated;
