update public.questions
set metadata=jsonb_set(coalesce(metadata,'{}'::jsonb),'{accepted_answers}',
  '["serrer les fesses","demander de serrer les fesses","contracter les fesses","demander de contracter les fesses","contraction des fessiers","contraction des fesses","demander la contraction des fesses"]'::jsonb,true),updated_at=now()
where id='4b2813a2-b769-4476-8239-e002f6f30749';

update public.questions
set question_text='Le tendon patellaire est recherché du côté inférieur de la patella.',
    explanation='Le repérage palpatoire du tendon patellaire se fait du côté inférieur de la patella.',
    updated_at=now()
where id='f2eccae5-9203-40d0-b4c4-66d5ac7734fb';

update public.questions
set question_text='La facette articulaire de la malléole latérale répond au talus.',
    explanation='La malléole latérale, formée par l’extrémité distale de la fibula, participe à la mortaise talo-crurale et sa facette articulaire répond au talus. La relation tibia-fibula distale relève de la syndesmose tibio-fibulaire.',
    metadata=jsonb_set(coalesce(metadata,'{}'::jsonb),'{answer}','"Vrai"'::jsonb,true),
    updated_at=now()
where id='5d4c5899-9893-4e75-aa80-d72084b6cb90';

update public.feedback set status='resolved' where id in (
'164f7ed0-3e9e-4e34-800e-26498a56086b',
'548297df-8f3b-42b3-8947-619258018f2a',
'a90a895f-d0ea-44ab-ab57-d4e29973715e',
'1e424217-6abf-4770-bedf-3c6c3cf2472f'
);
