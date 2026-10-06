-- Optimize multi-curriculum RLS auth evaluation and add covering FK indexes
-- used by progress, daily challenges and friend challenges.

drop policy if exists "curriculum_daily_own_read" on public.curriculum_daily_challenge_attempts;
create policy "curriculum_daily_own_read"
on public.curriculum_daily_challenge_attempts
for select to authenticated
using (user_id = (select auth.uid()));

drop policy if exists "curriculum_friend_answers_own_read" on public.curriculum_friend_challenge_answers;
create policy "curriculum_friend_answers_own_read"
on public.curriculum_friend_challenge_answers
for select to authenticated
using (user_id = (select auth.uid()));

drop policy if exists "curriculum_friend_questions_participant_read" on public.curriculum_friend_challenge_questions;
create policy "curriculum_friend_questions_participant_read"
on public.curriculum_friend_challenge_questions
for select to authenticated
using (
  exists (
    select 1
    from public.curriculum_friend_challenges c
    where c.id = curriculum_friend_challenge_questions.challenge_id
      and (c.challenger_id = (select auth.uid()) or c.challenged_id = (select auth.uid()))
  )
);

drop policy if exists "curriculum_friend_participant_read" on public.curriculum_friend_challenges;
create policy "curriculum_friend_participant_read"
on public.curriculum_friend_challenges
for select to authenticated
using (challenger_id = (select auth.uid()) or challenged_id = (select auth.uid()));

drop policy if exists "curriculum_attempts_own_read" on public.curriculum_question_attempts;
create policy "curriculum_attempts_own_read"
on public.curriculum_question_attempts
for select to authenticated
using (user_id = (select auth.uid()));

drop policy if exists "curriculum_completions_own_read" on public.curriculum_topic_completions;
create policy "curriculum_completions_own_read"
on public.curriculum_topic_completions
for select to authenticated
using (user_id = (select auth.uid()));

create index if not exists idx_curriculum_daily_program_id
  on public.curriculum_daily_challenge_attempts(program_id);
create index if not exists idx_curriculum_friend_answers_question_id
  on public.curriculum_friend_challenge_answers(question_id);
create index if not exists idx_curriculum_friend_answers_user_id
  on public.curriculum_friend_challenge_answers(user_id);
create index if not exists idx_curriculum_friend_questions_question_id
  on public.curriculum_friend_challenge_questions(question_id);
create index if not exists idx_curriculum_friend_challenges_academic_level_id
  on public.curriculum_friend_challenges(academic_level_id);
create index if not exists idx_curriculum_friend_challenges_challenged_id
  on public.curriculum_friend_challenges(challenged_id);
create index if not exists idx_curriculum_attempts_question_id
  on public.curriculum_question_attempts(question_id);
create index if not exists idx_curriculum_attempts_topic_id
  on public.curriculum_question_attempts(topic_id);
create index if not exists idx_curriculum_completions_topic_id
  on public.curriculum_topic_completions(topic_id);
create index if not exists idx_profile_programs_academic_level_id
  on public.profile_programs(academic_level_id);
