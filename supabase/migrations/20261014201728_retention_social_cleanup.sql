-- Notifications belonging to other students can contain the deleted user's name.
-- Remove only references to this user's relationships before FK cascades run.
create function retention.cleanup_social_references() returns trigger
language plpgsql security definer set search_path='' as $$
begin
 delete from public.notifications n where n.data->>'requester_id'=old.id::text
  or n.data->>'friendship_id' in
   (select f.id::text from public.friendships f where f.requester_id=old.id or f.addressee_id=old.id)
  or n.data->>'challenge_id' in
   (select c.id::text from public.challenges c where c.challenger_id=old.id or c.challenged_id=old.id)
  or n.data->>'curriculum_challenge_id' in
   (select c.id::text from public.curriculum_friend_challenges c where c.challenger_id=old.id or c.challenged_id=old.id);
 return old;
end;
$$;
revoke all on function retention.cleanup_social_references() from public,anon,authenticated;
create trigger retention_social_cleanup before delete on public.profiles
 for each row execute function retention.cleanup_social_references();
