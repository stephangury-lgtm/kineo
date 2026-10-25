-- Feedback 24 October: conservative wording aliases; safe to rerun.
-- No scores, publications, sources, or access policies are changed.
begin;
update public.questions
set metadata=jsonb_set(metadata,'{accepted_answers}',(select jsonb_agg(distinct a.value order by a.value) from jsonb_array_elements_text(metadata->'accepted_answers' || '["crispation","une crispation","patient crispé","le patient se crispe","tension du patient","retrait","un retrait","expression de gêne","grimace","une grimace"]'::jsonb) a(value)))
where id='49a764f4-82d5-4abd-b21e-b432bd3b53a4';
update public.questions
set metadata=jsonb_set(metadata,'{accepted_answers}',(select jsonb_agg(distinct a.value order by a.value) from jsonb_array_elements_text(metadata->'accepted_answers' || '["de manière progressive","progressif","progressive","graduellement","de façon graduelle","petit à petit","sans à-coups","en douceur","doucement","retour progressif"]'::jsonb) a(value)))
where id='dcca0028-46f1-4e73-a505-c11933fa33a7';
-- Retire only the two incomplete October 2 duels; keep scores and sessions.
update public.challenges c set status='cancelled'
where c.id in ('619ae26c-60c5-4ebf-a89d-33cdf254fd44','2965dd07-eabb-4513-8c93-8039a5582571')
  and c.status='in_progress'
  and (select count(*) from public.challenge_questions cq join public.questions q on q.id=cq.question_id where cq.challenge_id=c.id and q.is_published and q.validation_status='published')<>10;
commit;
