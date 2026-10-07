-- Progressive quiz enrichment batch 1
-- 4 IFSI + 4 Kineo Spain + 4 Kineo France K4 sourced questions.

insert into public.curriculum_quiz_questions
(id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,validation_status,is_published,question_type,accepted_answers,metadata)
values
('11111111-71a0-4d01-9001-000000000001','519130d7-c3d0-492e-8d5c-0db3fe362d66',
'Pourquoi une donnée clinique isolée doit-elle être interprétée avec prudence ?',
'Une donnée isolée prend son sens lorsqu’elle est mise en relation avec les autres observations, les informations rapportées, le contexte et les connaissances professionnelles.',
'[{"text":"Parce qu’elle doit être mise en relation avec les autres données de la situation","correct":true},{"text":"Parce qu’elle doit toujours être écartée","correct":false},{"text":"Parce qu’elle remplace le recueil clinique","correct":false},{"text":"Parce qu’elle suffit à rendre le jugement définitif","correct":false}]'::jsonb,
3,'Arrêté du 20 février 2026 · Annexe III · UE A.1',901,'source_validated',true,'mcq','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v1","difficulty_scale_version":"2026-10-v1"}'::jsonb),
('11111111-71a0-4d01-9001-000000000002','519130d7-c3d0-492e-8d5c-0db3fe362d66',
'Cas clinique — Un patient décrit une aggravation de sa gêne, alors que les premières constantes restent proches de celles du matin. Quelle démarche est la plus pertinente ?',
'Le raisonnement clinique ne se limite pas à une valeur isolée. Il faut intégrer la plainte, rechercher des données complémentaires, les mettre en relation et réévaluer la situation.',
'[{"text":"Reprendre le recueil, confronter les données et rechercher ce qui a changé","correct":true},{"text":"Ignorer la plainte car les constantes sont proches des précédentes","correct":false},{"text":"Conserver le jugement initial sans nouvelle analyse","correct":false},{"text":"Attendre systématiquement la relève suivante","correct":false}]'::jsonb,
4,'Arrêté du 20 février 2026 · Annexe III · UE A.1',902,'source_validated',true,'clinical_case','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v1","difficulty_scale_version":"2026-10-v1"}'::jsonb),
('11111111-71a0-4d01-9001-000000000003','519130d7-c3d0-492e-8d5c-0db3fe362d66',
'Cas clinique — Après une intervention, un critère d’évaluation s’améliore mais un nouveau risque apparaît. Quelle conduite correspond au raisonnement clinique attendu ?',
'Le jugement clinique et le projet de soins restent réévaluables. Une nouvelle donnée significative peut modifier les priorités et conduire à ajuster les interventions.',
'[{"text":"Réévaluer l’ensemble de la situation et ajuster les priorités","correct":true},{"text":"Conserver le projet inchangé puisque l’objectif initial s’améliore","correct":false},{"text":"Supprimer le nouveau risque de l’analyse","correct":false},{"text":"Considérer l’intervention comme définitivement validée","correct":false}]'::jsonb,
5,'Arrêté du 20 février 2026 · Annexe III · UE A.1',903,'source_validated',true,'clinical_case','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v1","difficulty_scale_version":"2026-10-v1"}'::jsonb),
('11111111-71a0-4d01-9001-000000000004','519130d7-c3d0-492e-8d5c-0db3fe362d66',
'Quel enchaînement décrit le mieux une démarche clinique complète ?',
'La démarche va du recueil de données à leur analyse, puis au jugement clinique, à la définition d’interventions et enfin à leur réévaluation.',
'[{"text":"Recueillir → analyser → juger → intervenir → réévaluer","correct":true},{"text":"Intervenir → conclure → recueillir","correct":false},{"text":"Juger → ignorer le contexte → intervenir","correct":false},{"text":"Recueillir → intervenir sans analyse → terminer","correct":false}]'::jsonb,
3,'Arrêté du 20 février 2026 · Annexe III · UE A.1',904,'source_validated',true,'mcq','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v1","difficulty_scale_version":"2026-10-v1"}'::jsonb),

('22222222-71a0-4d01-9001-000000000001','540bcde7-1fd8-480b-8d67-53fe591af3b6',
'Durante ejercicio aeróbico, una persona puede hablar con normalidad y también cantar sin dificultad. Según la prueba del habla, ¿qué sugiere esto?',
'En la prueba del habla, una intensidad moderada suele permitir hablar pero dificulta cantar. Poder cantar con facilidad orienta a una intensidad menor.',
'[{"text":"La intensidad probablemente es inferior a moderada","correct":true},{"text":"La intensidad es necesariamente máxima","correct":false},{"text":"Debe detenerse siempre el ejercicio","correct":false},{"text":"La frecuencia respiratoria debe estar disminuyendo","correct":false}]'::jsonb,
3,'MedlinePlus — Ejercite su corazón',901,'source_validated',true,'mcq','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v1","difficulty_scale_version":"2026-10-v1"}'::jsonb),
('22222222-71a0-4d01-9001-000000000002','540bcde7-1fd8-480b-8d67-53fe591af3b6',
'Caso clínico — Durante una progresión de ejercicio, el pulso y la respiración aumentan de forma esperable, pero aparece dolor torácico. ¿Qué conducta es la más adecuada?',
'El aumento de pulso y respiración puede ser normal durante ejercicio aeróbico, pero un síntoma inhabitual como dolor torácico obliga a detener o reducir el esfuerzo y reevaluar.',
'[{"text":"Detener el esfuerzo y reevaluar la situación","correct":true},{"text":"Aumentar la intensidad para comprobar la tolerancia","correct":false},{"text":"Ignorar el dolor porque el pulso también aumentó","correct":false},{"text":"Mantener la carga hasta finalizar la serie","correct":false}]'::jsonb,
4,'MedlinePlus — Ejercite su corazón / Ejercicio y edad',902,'source_validated',true,'clinical_case','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v1","difficulty_scale_version":"2026-10-v1"}'::jsonb),
('22222222-71a0-4d01-9001-000000000003','540bcde7-1fd8-480b-8d67-53fe591af3b6',
'Caso de integración — Una persona pasa de poder hablar cómodamente a responder solo con palabras sueltas tras aumentar la carga. No presenta dolor, pero la respiración es muy acelerada. ¿Qué interpretación es la más prudente?',
'La prueba del habla ayuda a estimar la intensidad. Si hablar se vuelve muy difícil, la carga puede haber superado la intensidad moderada y conviene ajustar el esfuerzo según tolerancia y síntomas.',
'[{"text":"La intensidad probablemente ha aumentado demasiado y debe ajustarse","correct":true},{"text":"La intensidad sigue siendo necesariamente moderada","correct":false},{"text":"La respuesta demuestra una mejora inmediata de la capacidad aeróbica","correct":false},{"text":"La prueba del habla no aporta ninguna información","correct":false}]'::jsonb,
5,'MedlinePlus — Ejercite su corazón',903,'source_validated',true,'clinical_case','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v1","difficulty_scale_version":"2026-10-v1"}'::jsonb),
('22222222-71a0-4d01-9001-000000000004','540bcde7-1fd8-480b-8d67-53fe591af3b6',
'¿Qué combinación describe mejor una progresión segura del ejercicio aeróbico en este tema?',
'La progresión debe ser gradual, observando la tolerancia y los síntomas, y ajustando la intensidad si la respuesta deja de ser adecuada.',
'[{"text":"Progresión gradual + vigilancia de síntomas + ajuste según tolerancia","correct":true},{"text":"Aumento brusco de carga + ignorar síntomas","correct":false},{"text":"Mantener siempre la misma intensidad sin reevaluar","correct":false},{"text":"Buscar únicamente una frecuencia cardíaca más alta","correct":false}]'::jsonb,
3,'MedlinePlus — Ejercite su corazón / Ejercicio y edad',904,'source_validated',true,'mcq','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v1","difficulty_scale_version":"2026-10-v1"}'::jsonb)
on conflict (id) do nothing;

insert into public.questions
(id,chapter_id,lesson_id,type,question_text,explanation,difficulty,metadata,source,is_published,validation_status,source_document)
values
('33333333-71a0-4d01-9001-000000000001','a0019678-b482-481a-81f7-f27b6984d355','c6c214e5-1678-4d3f-a69e-0e9c4e374ce2','mcq','Quel enchaînement respecte le mieux la logique décrite pour établir un diagnostic kinésithérapique ?','Le raisonnement s’appuie d’abord sur l’évaluation, la mise en concordance avec les plaintes et l’analyse des risques, puis sur des hypothèses argumentées avant la formulation du diagnostic.',3,'{"enrichment_batch":"progressive_quiz_v1","difficulty_scale_version":"2026-10-v1"}'::jsonb,'Ordre MK — Référentiel de la profession, p.45',false,'review','Ordre MK — Référentiel de la profession, p.45'),
('33333333-71a0-4d01-9001-000000000002','a0019678-b482-481a-81f7-f27b6984d355','c6c214e5-1678-4d3f-a69e-0e9c4e374ce2','clinical_case','Cas clinique — Un patient présente une limitation fonctionnelle importante mais les tests analytiques sont peu perturbés. Quelle étape est prioritaire avant de conclure ?','Le diagnostic kinésithérapique doit mettre en concordance l’évaluation analytique et globale avec les plaintes et les capacités fonctionnelles de la personne.',4,'{"enrichment_batch":"progressive_quiz_v1","difficulty_scale_version":"2026-10-v1"}'::jsonb,'Ordre MK — Référentiel de la profession, p.45',false,'review','Ordre MK — Référentiel de la profession, p.45'),
('33333333-71a0-4d01-9001-000000000003','a0019678-b482-481a-81f7-f27b6984d355','c6c214e5-1678-4d3f-a69e-0e9c4e374ce2','clinical_case','Cas d’intégration — Après trois séances, une nouvelle limitation d’activité apparaît alors que le symptôme initial diminue. Que doit devenir le diagnostic kinésithérapique ?','Le diagnostic kinésithérapique n’est pas figé. Il doit être réévalué lorsque l’état, les capacités fonctionnelles ou les priorités de la personne évoluent.',5,'{"enrichment_batch":"progressive_quiz_v1","difficulty_scale_version":"2026-10-v1"}'::jsonb,'Ordre MK — Référentiel de la profession, p.45',false,'review','Ordre MK — Référentiel de la profession, p.45'),
('33333333-71a0-4d01-9001-000000000004','a0019678-b482-481a-81f7-f27b6984d355','c6c214e5-1678-4d3f-a69e-0e9c4e374ce2','clinical_case','Cas d’intégration — Les tests montrent une faiblesse, mais le patient ne rapporte aucune gêne dans ses activités habituelles. Quelle conclusion est la plus rigoureuse ?','Une anomalie analytique ne suffit pas à elle seule : le diagnostic kinésithérapique relie les résultats de l’évaluation aux plaintes, au mouvement et aux capacités fonctionnelles.',5,'{"enrichment_batch":"progressive_quiz_v1","difficulty_scale_version":"2026-10-v1"}'::jsonb,'Ordre MK — Référentiel de la profession, p.45',false,'review','Ordre MK — Référentiel de la profession, p.45')
on conflict (id) do nothing;

insert into public.question_options(question_id,option_text,is_correct,display_order)
select * from (values
('33333333-71a0-4d01-9001-000000000001'::uuid,'Évaluation → concordance avec les plaintes → risques → hypothèses → diagnostic',true,1),
('33333333-71a0-4d01-9001-000000000001'::uuid,'Diagnostic → traitement → évaluation',false,2),
('33333333-71a0-4d01-9001-000000000001'::uuid,'Technique → hypothèse → plainte',false,3),
('33333333-71a0-4d01-9001-000000000001'::uuid,'Imagerie seule → diagnostic définitif',false,4),
('33333333-71a0-4d01-9001-000000000002'::uuid,'Mettre en relation les tests avec les plaintes et la fonction',true,1),
('33333333-71a0-4d01-9001-000000000002'::uuid,'Retenir uniquement les tests analytiques',false,2),
('33333333-71a0-4d01-9001-000000000002'::uuid,'Choisir un protocole sans autre analyse',false,3),
('33333333-71a0-4d01-9001-000000000002'::uuid,'Écarter la limitation fonctionnelle',false,4),
('33333333-71a0-4d01-9001-000000000003'::uuid,'Le réévaluer et ajuster les objectifs selon la nouvelle situation',true,1),
('33333333-71a0-4d01-9001-000000000003'::uuid,'Le conserver inchangé puisque le symptôme initial diminue',false,2),
('33333333-71a0-4d01-9001-000000000003'::uuid,'Supprimer la nouvelle limitation de l’analyse',false,3),
('33333333-71a0-4d01-9001-000000000003'::uuid,'Arrêter toute réévaluation',false,4),
('33333333-71a0-4d01-9001-000000000004'::uuid,'Interpréter la faiblesse dans le contexte fonctionnel avant de conclure',true,1),
('33333333-71a0-4d01-9001-000000000004'::uuid,'Conclure automatiquement à une incapacité majeure',false,2),
('33333333-71a0-4d01-9001-000000000004'::uuid,'Ignorer les activités du patient',false,3),
('33333333-71a0-4d01-9001-000000000004'::uuid,'Remplacer l’évaluation globale par le seul test de force',false,4)
) v(question_id,option_text,is_correct,display_order)
where not exists(select 1 from public.question_options qo where qo.question_id=v.question_id and qo.display_order=v.display_order);

insert into public.question_sources(question_id,document_id,lesson_id,page_number,source_excerpt)
select * from (values
('33333333-71a0-4d01-9001-000000000001'::uuid,'5c4337e2-41f3-492f-8bd8-3d01c45e9495'::uuid,'c6c214e5-1678-4d3f-a69e-0e9c4e374ce2'::uuid,45,'C2C. Faire des hypothèses sur la nature et l’étendue des dysfonctions de la personne.'),
('33333333-71a0-4d01-9001-000000000002'::uuid,'5c4337e2-41f3-492f-8bd8-3d01c45e9495'::uuid,'c6c214e5-1678-4d3f-a69e-0e9c4e374ce2'::uuid,45,'C2A. Mettre en concordance les résultats de l’évaluation clinique kinésithérapique avec les plaintes du patient.'),
('33333333-71a0-4d01-9001-000000000003'::uuid,'5c4337e2-41f3-492f-8bd8-3d01c45e9495'::uuid,'c6c214e5-1678-4d3f-a69e-0e9c4e374ce2'::uuid,45,'C2C. Faire des hypothèses sur la nature et l’étendue des dysfonctions de la personne.'),
('33333333-71a0-4d01-9001-000000000004'::uuid,'5c4337e2-41f3-492f-8bd8-3d01c45e9495'::uuid,'c6c214e5-1678-4d3f-a69e-0e9c4e374ce2'::uuid,45,'C2A. Mettre en concordance les résultats de l’évaluation clinique kinésithérapique avec les plaintes du patient.')
) v(question_id,document_id,lesson_id,page_number,source_excerpt)
where not exists(select 1 from public.question_sources qs where qs.question_id=v.question_id and qs.document_id=v.document_id and qs.page_number=v.page_number);

update public.questions
set is_published=true,validation_status='published',updated_at=now()
where id in (
'33333333-71a0-4d01-9001-000000000001'::uuid,
'33333333-71a0-4d01-9001-000000000002'::uuid,
'33333333-71a0-4d01-9001-000000000003'::uuid,
'33333333-71a0-4d01-9001-000000000004'::uuid
);

select public.refresh_release_health_status_v1();
