-- Apply only after rolling the frontend back. Preserve all conversation data.
revoke execute on function public.read_friend_challenge_messages_v1(uuid,text) from authenticated;
revoke execute on function public.send_friend_challenge_message_v1(uuid,text,text,uuid) from authenticated;
-- No rows or tables are deleted; re-grant EXECUTE to re-enable after a fix.
