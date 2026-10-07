-- Progressive quiz enrichment batch 2
-- K4 fall prevention + ES4 complex cases + IFSI S5 oncology

insert into public.questions
(id,chapter_id,lesson_id,type,question_text,explanation,difficulty,metadata,source,is_published,validation_status,source_document)
select * from (values
('44444444-71a0-4d01-9002-000000000001'::uuid,'9e5ff8aa-4d8b-44a0-b5b7-75ae59ac7ef2'::uuid,'32c0d921-58b6-43e2-a0eb-ee76cc432b8c'::uuid,'clinical_case',
'Cas clinique — Une personne âgée suit uniquement un renforcement des membres inférieurs mais reste instable lors des changements de direction. Quelle adaptation est la plus cohérente ?',
'La prévention des chutes repose sur plusieurs composantes complémentaires. Le renforcement seul ne couvre pas l’équilibre, la coordination et les situations fonctionnelles.',
4,'{"enrichment_batch":"progressive_quiz_v2","difficulty_scale_version":"2026-10-v1"}'::jsonb,
'HAS — Personnes âgées à risque de chute (2024), p.9',false,'review','HAS — Personnes âgées à risque de chute (2024), p.9'),
('44444444-71a0-4d01-9002-000000000002'::uuid,'9e5ff8aa-4d8b-44a0-b5b7-75ae59ac7ef2'::uuid,'32c0d921-58b6-43e2-a0eb-ee76cc432b8c'::uuid,'clinical_case',
'Cas d’intégration — Après trois mois, l’équilibre s’est amélioré mais la personne chute encore lors de situations de double tâche. Quelle démarche est la plus adaptée ?',
'La réévaluation régulière sert à ajuster le contenu du programme. Si une difficulté persiste en double tâche, celle-ci doit être retravaillée dans une progression adaptée.',
5,'{"enrichment_batch":"progressive_quiz_v2","difficulty_scale_version":"2026-10-v1"}'::jsonb,
'HAS — Personnes âgées à risque de chute (2024), p.9',false,'review','HAS — Personnes âgées à risque de chute (2024), p.9'),
('44444444-71a0-4d01-9002-000000000003'::uuid,'9e5ff8aa-4d8b-44a0-b5b7-75ae59ac7ef2'::uuid,'32c0d921-58b6-43e2-a0eb-ee76cc432b8c'::uuid,'mcq',
'Pourquoi la réévaluation périodique du programme d’APA est-elle importante ?',
'Elle permet de vérifier l’efficacité du programme et d’ajuster sa difficulté et ses composantes selon l’évolution des capacités et du risque.',
4,'{"enrichment_batch":"progressive_quiz_v2","difficulty_scale_version":"2026-10-v1"}'::jsonb,
'HAS — Personnes âgées à risque de chute (2024), p.9',false,'review','HAS — Personnes âgées à risque de chute (2024), p.9')
) v(id,chapter_id,lesson_id,type,question_text,explanation,difficulty,metadata,source,is_published,validation_status,source_document)
on conflict(id) do nothing;

insert into public.question_options(question_id,option_text,is_correct,display_order)
select * from (values
('44444444-71a0-4d01-9002-000000000001'::uuid,'Ajouter un travail d’équilibre, de coordination et de situations fonctionnelles',true,1),
('44444444-71a0-4d01-9002-000000000001'::uuid,'Supprimer tout travail de marche',false,2),
('44444444-71a0-4d01-9002-000000000001'::uuid,'Conserver uniquement le renforcement sans réévaluation',false,3),
('44444444-71a0-4d01-9002-000000000001'::uuid,'Arrêter toute activité physique',false,4),
('44444444-71a0-4d01-9002-000000000002'::uuid,'Réévaluer et intégrer davantage de situations de double tâche',true,1),
('44444444-71a0-4d01-9002-000000000002'::uuid,'Augmenter uniquement les charges de renforcement',false,2),
('44444444-71a0-4d01-9002-000000000002'::uuid,'Ignorer les chutes car l’équilibre statique s’améliore',false,3),
('44444444-71a0-4d01-9002-000000000002'::uuid,'Supprimer les exercices fonctionnels',false,4),
('44444444-71a0-4d01-9002-000000000003'::uuid,'Pour ajuster le programme selon son efficacité et l’évolution du risque',true,1),
('44444444-71a0-4d01-9002-000000000003'::uuid,'Pour remplacer toute observation clinique',false,2),
('44444444-71a0-4d01-9002-000000000003'::uuid,'Pour maintenir la même difficulté quel que soit le résultat',false,3),
('44444444-71a0-4d01-9002-000000000003'::uuid,'Uniquement pour compter les séances réalisées',false,4)
) v(question_id,option_text,is_correct,display_order)
where not exists(select 1 from public.question_options qo where qo.question_id=v.question_id and qo.display_order=v.display_order);

insert into public.question_sources(question_id,document_id,lesson_id,page_number,source_excerpt)
select * from (values
('44444444-71a0-4d01-9002-000000000001'::uuid,'3d28ef9f-61c5-47e5-ad70-2b2f45a0a26a'::uuid,'32c0d921-58b6-43e2-a0eb-ee76cc432b8c'::uuid,9,'des exercices d’équilibre, d’habileté motrice et de coordination'),
('44444444-71a0-4d01-9002-000000000002'::uuid,'3d28ef9f-61c5-47e5-ad70-2b2f45a0a26a'::uuid,'32c0d921-58b6-43e2-a0eb-ee76cc432b8c'::uuid,9,'Au moins tous les 3 mois, le professionnel de l’APA doit évaluer l’efficacité du programme'),
('44444444-71a0-4d01-9002-000000000003'::uuid,'3d28ef9f-61c5-47e5-ad70-2b2f45a0a26a'::uuid,'32c0d921-58b6-43e2-a0eb-ee76cc432b8c'::uuid,9,'Au moins tous les 3 mois, le professionnel de l’APA doit évaluer l’efficacité du programme')
) v(question_id,document_id,lesson_id,page_number,source_excerpt)
where not exists(select 1 from public.question_sources qs where qs.question_id=v.question_id and qs.document_id=v.document_id and qs.page_number=v.page_number);

update public.questions set is_published=true,validation_status='published',updated_at=now()
where id in (
'44444444-71a0-4d01-9002-000000000001'::uuid,
'44444444-71a0-4d01-9002-000000000002'::uuid,
'44444444-71a0-4d01-9002-000000000003'::uuid
);

insert into public.curriculum_quiz_questions
(id,topic_id,question_text,explanation,options,difficulty,source_label,display_order,validation_status,is_published,question_type,accepted_answers,metadata)
values
('55555555-71a0-4d01-9002-000000000001','8c209c13-5d1f-4ab3-b1b3-313fd37d9483',
'Caso clínico — En un paciente con problemas respiratorios, de movilidad y apoyo social limitado, ¿qué debe hacerse antes de elegir una intervención?',
'En un caso complejo hay que priorizar problemas, identificar riesgos, definir objetivos funcionales y reconocer qué profesionales deben participar.',
'[{"text":"Priorizar problemas, riesgos y objetivos antes de decidir","correct":true},{"text":"Elegir una técnica aislada sin integrar el contexto","correct":false},{"text":"Tratar solo el primer dato encontrado","correct":false},{"text":"Esperar a tener todos los datos posibles sin priorizar","correct":false}]'::jsonb,
4,'UVic · Atención Clínica Integral · 2026-2027',901,'source_validated',true,'clinical_case','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v2","difficulty_scale_version":"2026-10-v1"}'::jsonb),
('55555555-71a0-4d01-9002-000000000002','8c209c13-5d1f-4ab3-b1b3-313fd37d9483',
'Caso de integración — Durante el seguimiento aparece un nuevo riesgo social que modifica la viabilidad del plan. ¿Qué respuesta es más adecuada?',
'La nueva información debe incorporarse al razonamiento y puede cambiar prioridades, coordinación y plan de atención.',
'[{"text":"Reevaluar prioridades y coordinar el plan con el equipo","correct":true},{"text":"Mantener el plan sin cambios","correct":false},{"text":"Ignorar el factor social porque no es físico","correct":false},{"text":"Eliminar la participación de otros profesionales","correct":false}]'::jsonb,
5,'UVic · Atención Clínica Integral · 2026-2027',902,'source_validated',true,'clinical_case','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v2","difficulty_scale_version":"2026-10-v1"}'::jsonb),
('55555555-71a0-4d01-9002-000000000003','8c209c13-5d1f-4ab3-b1b3-313fd37d9483',
'¿Cuál es la función principal del trabajo interdisciplinar en un caso complejo?',
'El equipo aporta información complementaria que debe integrarse en un plan coherente.',
'[{"text":"Integrar perspectivas complementarias en un plan coherente","correct":true},{"text":"Sustituir totalmente el razonamiento del fisioterapeuta","correct":false},{"text":"Acumular datos sin decidir prioridades","correct":false},{"text":"Evitar la reevaluación del caso","correct":false}]'::jsonb,
4,'UVic · Atención Clínica Integral · 2026-2027',903,'source_validated',true,'mcq','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v2","difficulty_scale_version":"2026-10-v1"}'::jsonb),

('66666666-71a0-4d01-9002-000000000001','bb754d30-2e5b-4e67-affd-22a60f80b73d',
'Dans la démarche générale en oncologie, pourquoi la preuve histologique est-elle importante avant d’organiser la suite de la prise en charge ?',
'Le support associe la preuve histologique à la démarche diagnostique avant le bilan d’extension et la discussion thérapeutique.',
'[{"text":"Elle confirme la nature tumorale avant de structurer bilan et stratégie","correct":true},{"text":"Elle remplace le bilan d’extension","correct":false},{"text":"Elle évite toute discussion en RCP","correct":false},{"text":"Elle constitue uniquement un examen de surveillance","correct":false}]'::jsonb,
3,'Support IFSI fourni · Généralités en oncologie',901,'source_validated',true,'mcq','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v2","difficulty_scale_version":"2026-10-v1"}'::jsonb),
('66666666-71a0-4d01-9002-000000000002','bb754d30-2e5b-4e67-affd-22a60f80b73d',
'Cas clinique — Une tumeur est confirmée histologiquement mais son extension n’est pas encore connue. Quelle étape est logique avant de définir la stratégie thérapeutique ?',
'Le bilan d’extension permet de préciser l’étendue de la maladie et alimente ensuite la discussion thérapeutique, notamment en RCP.',
'[{"text":"Réaliser le bilan d’extension","correct":true},{"text":"Passer directement à la surveillance","correct":false},{"text":"Ignorer le stade tumoral","correct":false},{"text":"Supprimer toute discussion pluridisciplinaire","correct":false}]'::jsonb,
4,'Support IFSI fourni · Généralités en oncologie',902,'source_validated',true,'clinical_case','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v2","difficulty_scale_version":"2026-10-v1"}'::jsonb),
('66666666-71a0-4d01-9002-000000000003','bb754d30-2e5b-4e67-affd-22a60f80b73d',
'Cas d’intégration — Après traitement, la maladie est stabilisée mais le patient présente des besoins persistants liés aux effets secondaires et à la qualité de vie. Quelle dimension reste essentielle ?',
'La prise en charge oncologique ne s’arrête pas au traitement antitumoral : surveillance et soins de support restent nécessaires selon les besoins.',
'[{"text":"Associer surveillance et soins de support adaptés","correct":true},{"text":"Arrêter toute prise en charge dès la fin du traitement","correct":false},{"text":"Ne surveiller que la classification TNM","correct":false},{"text":"Exclure les symptômes liés aux traitements","correct":false}]'::jsonb,
5,'Support IFSI fourni · Généralités en oncologie',903,'source_validated',true,'clinical_case','[]'::jsonb,'{"enrichment_batch":"progressive_quiz_v2","difficulty_scale_version":"2026-10-v1"}'::jsonb)
on conflict(id) do nothing;

select public.refresh_release_health_status_v1();
