-- Progressive quiz enrichment batch 5
-- IFSI S6 evidence-based decision + ES4 evidence-based project

insert into public.curriculum_quiz_questions
(id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,validation_status,is_published,question_type,accepted_answers,metadata)
values
('99999999-71a0-4d01-9005-000000000001','23b43d07-44a3-4c48-bf5b-3c3337f14587',
'Une étude est méthodologiquement solide, mais sa population diffère fortement de celle du patient pris en charge. Quelle attitude est la plus pertinente ?',
'Une preuve solide n’est pas automatiquement applicable : il faut aussi examiner la population, le contexte, les objectifs et les préférences de la personne.',
'[{"text":"Évaluer l’applicabilité avant de transposer le résultat","correct":true},{"text":"Appliquer mécaniquement le résultat","correct":false},{"text":"Ignorer les préférences du patient","correct":false},{"text":"Rejeter toute donnée scientifique","correct":false}]'::jsonb,
4,'Cochrane — Critical appraisal skills',971,'source_validated',true,'clinical_case','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v5","difficulty_scale_version":"2026-10-v1"}'::jsonb),
('99999999-71a0-4d01-9005-000000000002','23b43d07-44a3-4c48-bf5b-3c3337f14587',
'Cas d’intégration — Deux options sont soutenues par des preuves comparables, mais leurs contraintes et bénéfices ne correspondent pas aux mêmes priorités du patient. Que doit intégrer la décision ?',
'La décision fondée sur les preuves combine qualité des données, expertise professionnelle, caractéristiques de la situation et préférences de la personne.',
'[{"text":"Les preuves, l’expertise, le contexte et les préférences du patient","correct":true},{"text":"Uniquement la préférence du professionnel","correct":false},{"text":"Uniquement l’étude la plus récente","correct":false},{"text":"Uniquement le protocole local sans discussion","correct":false}]'::jsonb,
5,'Cochrane — Critical appraisal skills',972,'source_validated',true,'clinical_case','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v5","difficulty_scale_version":"2026-10-v1"}'::jsonb),
('99999999-71a0-4d01-9005-000000000003','23b43d07-44a3-4c48-bf5b-3c3337f14587',
'Pourquoi une décision clinique fondée sur les preuves doit-elle rester contextualisée ?',
'Parce qu’une preuve peut être valide mais peu pertinente si la population, le contexte ou les objectifs diffèrent de la situation réelle.',
'[{"text":"Parce que validité scientifique et applicabilité ne sont pas identiques","correct":true},{"text":"Parce que la méthode scientifique ne sert jamais en clinique","correct":false},{"text":"Parce que les préférences du patient remplacent toutes les preuves","correct":false},{"text":"Parce qu’une seule étude suffit toujours","correct":false}]'::jsonb,
4,'Cochrane — Critical appraisal skills',973,'source_validated',true,'mcq','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v5","difficulty_scale_version":"2026-10-v1"}'::jsonb),
('99999999-71a0-4d01-9005-000000000004','c4b79324-859b-49c8-bccc-b3a0929a4e07',
'Un estudiante reúne muchos artículos, pero varios no responden a la pregunta de su TFG. ¿Cuál es el principal problema metodológico?',
'Una búsqueda útil debe estar guiada por una pregunta concreta; acumular artículos no garantiza relevancia ni coherencia.',
'[{"text":"La búsqueda no está suficientemente alineada con la pregunta","correct":true},{"text":"Hay demasiadas referencias bibliográficas por definición","correct":false},{"text":"El TFG no necesita una pregunta clara","correct":false},{"text":"La cantidad de artículos sustituye al método","correct":false}]'::jsonb,
4,'UVic · Trabajo de Fin de Grado · 2026-2027',971,'source_validated',true,'clinical_case','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v5","difficulty_scale_version":"2026-10-v1"}'::jsonb),
('99999999-71a0-4d01-9005-000000000005','c4b79324-859b-49c8-bccc-b3a0929a4e07',
'Caso de integración — La pregunta del TFG es clara y la búsqueda es adecuada, pero el diseño elegido no permite responder realmente a la pregunta. ¿Qué debe revisarse?',
'El rigor metodológico exige coherencia entre pregunta, búsqueda, diseño, resultados y conclusiones.',
'[{"text":"La coherencia entre la pregunta y el diseño metodológico","correct":true},{"text":"Solo el formato de las referencias","correct":false},{"text":"Únicamente la duración de la defensa oral","correct":false},{"text":"Nada, si la búsqueda bibliográfica fue extensa","correct":false}]'::jsonb,
5,'UVic · Trabajo de Fin de Grado · 2026-2027',972,'source_validated',true,'clinical_case','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v5","difficulty_scale_version":"2026-10-v1"}'::jsonb),
('99999999-71a0-4d01-9005-000000000006','c4b79324-859b-49c8-bccc-b3a0929a4e07',
'¿Qué elemento distingue mejor un proyecto basado en evidencia de una simple recopilación de información?',
'El proyecto articula una pregunta definida, una búsqueda pertinente, un método justificado y unas conclusiones coherentes con los resultados.',
'[{"text":"La coherencia entre pregunta, evidencia, método y conclusiones","correct":true},{"text":"El número total de páginas","correct":false},{"text":"La cantidad máxima posible de artículos","correct":false},{"text":"La ausencia de límites metodológicos","correct":false}]'::jsonb,
4,'UVic · Trabajo de Fin de Grado · 2026-2027',973,'source_validated',true,'mcq','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v5","difficulty_scale_version":"2026-10-v1"}'::jsonb)
on conflict(id) do nothing;

select public.refresh_release_health_status_v1();
