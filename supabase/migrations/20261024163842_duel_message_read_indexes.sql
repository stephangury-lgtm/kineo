-- Cover the catalog FK and cache the caller identity once per RLS statement.
create index friend_messages_program_idx on public.friend_challenge_messages(program_id);
alter policy participants_read_completed_messages on public.friend_challenge_messages using (
 exists(select 1 from public.challenges c where c.id=challenge_id and c.status='completed' and c.challenger_score is not null and c.challenged_score is not null
 and (select auth.uid()) in(c.challenger_id,c.challenged_id) and sender_id in(c.challenger_id,c.challenged_id))
 or exists(select 1 from public.curriculum_friend_challenges c where c.id=curriculum_challenge_id and c.program_id=friend_challenge_messages.program_id
 and c.status='completed' and c.challenger_score is not null and c.challenged_score is not null
 and (select auth.uid()) in(c.challenger_id,c.challenged_id) and sender_id in(c.challenger_id,c.challenged_id))
);
