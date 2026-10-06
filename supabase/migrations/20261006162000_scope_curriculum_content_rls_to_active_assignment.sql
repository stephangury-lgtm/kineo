-- Restrict multi-curriculum reads to the authenticated student's active assignment.
-- Admin users retain cross-level access for QA/testing.

drop policy if exists "curriculum_units_authenticated_read" on public.curriculum_units;
drop policy if exists "curriculum_topics_authenticated_read" on public.curriculum_topics;
drop policy if exists "curriculum lessons readable" on public.curriculum_lessons;
drop policy if exists "curriculum quiz readable" on public.curriculum_quiz_questions;

create policy "curriculum_units_active_assignment_read"
on public.curriculum_units
for select
to authenticated
using (
  is_active = true
  and (
    exists (
      select 1
      from public.profiles p
      where p.id = (select auth.uid())
        and p.role = 'admin'
    )
    or exists (
      select 1
      from public.profile_programs pp
      where pp.user_id = (select auth.uid())
        and pp.program_id = curriculum_units.program_id
        and pp.academic_level_id = curriculum_units.academic_level_id
        and coalesce(pp.curriculum_version,'default') = coalesce(curriculum_units.curriculum_version,'default')
    )
  )
);

create policy "curriculum_topics_active_assignment_read"
on public.curriculum_topics
for select
to authenticated
using (
  is_active = true
  and exists (
    select 1
    from public.curriculum_units u
    where u.id = curriculum_topics.unit_id
  )
);

create policy "curriculum_lessons_active_assignment_read"
on public.curriculum_lessons
for select
to authenticated
using (
  is_published = true
  and exists (
    select 1
    from public.curriculum_topics t
    where t.id = curriculum_lessons.topic_id
  )
);

create policy "curriculum_quiz_active_assignment_read"
on public.curriculum_quiz_questions
for select
to authenticated
using (
  is_published = true
  and validation_status = 'source_validated'
  and exists (
    select 1
    from public.curriculum_topics t
    where t.id = curriculum_quiz_questions.topic_id
  )
);
