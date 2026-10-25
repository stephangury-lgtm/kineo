-- Feedback 24 October: conservative wording aliases; safe to rerun.
-- No scores, publications, sources, or access policies are changed.
begin;
update public.questions
set metadata=jsonb_set(metadata,'{accepted_answers}',(select jsonb_agg(distinct a.value order by a.value) from jsonb_array_elements_text(metadata->'accepted_answers' || '["crispation","une crispation","patient crispé","le patient se crispe","tension du patient","retrait","un retrait","expression de gêne","grimace","une grimace"]'::jsonb) a(value)))
where id='49a764f4-82d5-4abd-b21e-b432bd3b53a4';
update public.questions
set metadata=jsonb_set(metadata,'{accepted_answers}',(select jsonb_agg(distinct a.value order by a.value) from jsonb_array_elements_text(metadata->'accepted_answers' || '["de manière progressive","progressif","progressive","graduellement","de façon graduelle","petit à petit","sans à-coups","en douceur","doucement","retour progressif"]'::jsonb) a(value)))
where id='dcca0028-46f1-4e73-a505-c11933fa33a7';
commit;
