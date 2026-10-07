-- Progressive quiz enrichment batch 3
-- K3/K4 advanced clinical reasoning. Idempotent.

with q(id,chapter_id,lesson_id,question_text,explanation,difficulty,source_document) as (values
('77777777-71a0-4d01-9003-000000000001'::uuid,'fbaf3752-dcf7-430c-b3e7-fc99a6b65985'::uuid,'37785c3a-8d00-447e-a2f5-a07b13274498'::uuid,'Cas clinique — Après une entorse latérale de cheville de grade I-II, le patient tolère l’appui avec une douleur modérée en diminution. Quelle conduite est la plus cohérente ?','Pour un grade I-II, la HAS recommande une marche et une remise en charge progressives selon les symptômes.',4,'HAS 2025 — Entorse du ligament collatéral latéral de cheville'),
('77777777-71a0-4d01-9003-000000000002','fbaf3752-dcf7-430c-b3e7-fc99a6b65985','37785c3a-8d00-447e-a2f5-a07b13274498','Cas d’intégration — Une entorse de grade III vient d’être diagnostiquée. Quelle stratégie initiale correspond le mieux aux recommandations ?','Pour un grade III, une immobilisation courte, limitée à 10 jours maximum, doit être associée à une rééducation fonctionnelle débutée précocement.',5,'HAS 2025 — Entorse du ligament collatéral latéral de cheville'),
('77777777-71a0-4d01-9003-000000000003','b3cbebe1-dca5-4680-a8a6-754dbcd951bf','02cec8c4-85d0-41b3-a982-634a8cffe215','Cas clinique — Un patient BPCO termine son stage initial de réhabilitation respiratoire avec une amélioration fonctionnelle. Quelle suite favorise le maintien des bénéfices ?','Le maintien repose sur une activité physique personnalisée régulière intégrée à la vie quotidienne.',4,'HAS — Réhabilitation respiratoire BPCO'),
('77777777-71a0-4d01-9003-000000000004','b3cbebe1-dca5-4680-a8a6-754dbcd951bf','02cec8c4-85d0-41b3-a982-634a8cffe215','Cas d’intégration — Un patient a terminé sa réhabilitation depuis plusieurs mois mais a interrompu toute activité physique. Quel risque principal faut-il anticiper ?','Sans programme de maintien, les bénéfices de la réhabilitation peuvent disparaître en 6 à 12 mois.',5,'HAS — Réhabilitation respiratoire BPCO'),
('77777777-71a0-4d01-9003-000000000005','9ee42e6c-c340-4062-aa65-b95148ac208d','c026554b-3d0e-43cf-b61f-def383d664f6','Cas clinique — Après ligamentoplastie du LCA, l’amplitude progresse mais le genou reste mal contrôlé dans les tâches fonctionnelles. Quelle priorité est la plus cohérente ?','La rééducation secondaire vise notamment à obtenir un contrôle actif du genou permettant une bonne stabilité.',4,'HAS — Rééducation après ligamentoplastie du LCA'),
('77777777-71a0-4d01-9003-000000000006','9ee42e6c-c340-4062-aa65-b95148ac208d','c026554b-3d0e-43cf-b61f-def383d664f6','Cas d’intégration — Le genou opéré récupère, mais l’écart d’amplitude avec le côté controlatéral persiste. Comment orienter la rééducation ?','La récupération des amplitudes doit être appréciée par comparaison au côté controlatéral et intégrée aux autres objectifs fonctionnels.',5,'HAS — Rééducation après ligamentoplastie du LCA'),
('77777777-71a0-4d01-9003-000000000007','9ee42e6c-c340-4062-aa65-b95148ac208d','32ec41eb-5739-4503-8cba-96be35f7f0bc','Cas clinique — Un patient souhaite reprendre le sport après ligamentoplastie du LCA. Il n’a plus mal mais son genou reste instable. Quelle décision est la plus adaptée ?','L’absence de douleur seule ne suffit pas : la reprise suppose notamment un genou sec, stable et indolore avec récupération fonctionnelle et musculaire.',4,'HAS — Rééducation après ligamentoplastie du LCA'),
('77777777-71a0-4d01-9003-000000000008','9ee42e6c-c340-4062-aa65-b95148ac208d','32ec41eb-5739-4503-8cba-96be35f7f0bc','Cas d’intégration — Tous les critères cliniques semblent satisfaisants mais l’activité envisagée impose de fortes contraintes de cisaillement sur le transplant. Que faut-il faire ?','La reprise doit tenir compte des contraintes imposées au transplant et des consignes postopératoires, pas seulement des critères cliniques.',5,'HAS — Rééducation après ligamentoplastie du LCA'),
('77777777-71a0-4d01-9003-000000000009','a0019678-b482-481a-81f7-f27b6984d355','9d4497d4-7d6b-42a1-8010-e0cc4533726c','Cas clinique — Les objectifs initiaux sont atteints plus vite que prévu. Quelle démarche s’inscrit le mieux dans une stratégie thérapeutique adaptée ?','Les critères de progression permettent de réévaluer le niveau atteint et d’ajuster la stratégie en lien avec la personne et ses attentes.',4,'Ordre des masseurs-kinésithérapeutes — Référentiel de la profession'),
('77777777-71a0-4d01-9003-000000000010','a0019678-b482-481a-81f7-f27b6984d355','9d4497d4-7d6b-42a1-8010-e0cc4533726c','Cas d’intégration — Malgré une bonne observance, les résultats stagnent et les priorités fonctionnelles ont changé. Quelle réponse est la plus pertinente ?','Le référentiel prévoit de faire évoluer la stratégie thérapeutique lorsque cela est nécessaire.',5,'Ordre des masseurs-kinésithérapeutes — Référentiel de la profession')
)
insert into public.questions(id,chapter_id,lesson_id,type,question_text,explanation,difficulty,metadata,source,is_published,validation_status,source_document)
select id,chapter_id,lesson_id,'clinical_case',question_text,explanation,difficulty,
'{"enrichment_batch":"progressive_quiz_v3","difficulty_scale_version":"2026-10-v1"}'::jsonb,
source_document,false,'review',source_document from q on conflict(id) do nothing;

with o(question_id,a,b,c,d) as (values
('77777777-71a0-4d01-9003-000000000001'::uuid,'Autoriser une remise en charge progressive selon les symptômes','Imposer une immobilisation stricte prolongée','Interdire toute marche jusqu’à disparition complète de la douleur','Utiliser uniquement la cryothérapie'),
('77777777-71a0-4d01-9003-000000000002','Immobilisation courte puis rééducation fonctionnelle précoce','Immobilisation stricte plusieurs semaines sans rééducation','Cryothérapie seule','Reprise sportive immédiate'),
('77777777-71a0-4d01-9003-000000000003','Maintenir une activité physique personnalisée régulière','Arrêter l’activité une fois le stage terminé','Limiter l’activité à une séance mensuelle','Ne conserver que des exercices respiratoires passifs'),
('77777777-71a0-4d01-9003-000000000004','Une perte progressive des bénéfices acquis','Une amélioration spontanée durable','Une absence totale d’effet du déconditionnement','Une augmentation automatique de la tolérance à l’effort'),
('77777777-71a0-4d01-9003-000000000005','Renforcer le contrôle actif et la stabilité fonctionnelle','Se concentrer uniquement sur la souplesse','Arrêter la rééducation dès que l’amplitude augmente','Éviter toute tâche fonctionnelle'),
('77777777-71a0-4d01-9003-000000000006','Poursuivre la récupération d’amplitude en la comparant au côté controlatéral','Considérer toute amplitude comme suffisante dès que la douleur baisse','Ignorer le membre controlatéral','Reprendre le sport sans autre critère'),
('77777777-71a0-4d01-9003-000000000007','Reporter la reprise et poursuivre la récupération fonctionnelle','Autoriser la reprise car la douleur a disparu','Autoriser uniquement parce que le délai postopératoire est écoulé','Ignorer la stabilité si la force est correcte'),
('77777777-71a0-4d01-9003-000000000008','Adapter ou différer l’activité pour respecter les contraintes du transplant','Autoriser sans adaptation puisque le genou est indolore','Ignorer les consignes chirurgicales','Supprimer toute progression graduée'),
('77777777-71a0-4d01-9003-000000000009','Réévaluer les critères de progression et ajuster les objectifs','Maintenir exactement la même stratégie','Arrêter toute évaluation','Changer de technique sans réévaluer'),
('77777777-71a0-4d01-9003-000000000010','Réévaluer et faire évoluer la stratégie thérapeutique','Poursuivre à l’identique malgré la stagnation','Abandonner les objectifs fonctionnels','Modifier sans tenir compte des résultats')
)
insert into public.question_options(question_id,option_text,is_correct,display_order)
select question_id,v.txt,v.ok,v.ord from o cross join lateral(values(a,true,1),(b,false,2),(c,false,3),(d,false,4)) v(txt,ok,ord)
where not exists(select 1 from public.question_options x where x.question_id=o.question_id and x.display_order=v.ord);

with s(question_id,document_id,lesson_id,page_number,source_excerpt) as (values
('77777777-71a0-4d01-9003-000000000001'::uuid,'9cb25739-83c5-4dff-81f4-f2d663dcff56'::uuid,'37785c3a-8d00-447e-a2f5-a07b13274498'::uuid,17,'Grade I-II : marche et remise en charge progressives selon les symptômes.'),
('77777777-71a0-4d01-9003-000000000002','9cb25739-83c5-4dff-81f4-f2d663dcff56','37785c3a-8d00-447e-a2f5-a07b13274498',17,'Grade III : immobilisation de 10 jours maximum associée à une rééducation fonctionnelle.'),
('77777777-71a0-4d01-9003-000000000003','0605b8be-6e58-40c3-8288-a4900d29ef55','02cec8c4-85d0-41b3-a982-634a8cffe215',3,'Pour un maintien à long terme : activité physique personnalisée 3 à 5 fois par semaine, intégrée dans la vie quotidienne.'),
('77777777-71a0-4d01-9003-000000000004','0605b8be-6e58-40c3-8288-a4900d29ef55','02cec8c4-85d0-41b3-a982-634a8cffe215',3,'Sans programme de maintien des acquis, les bénéfices disparaissent en 6 à 12 mois.'),
('77777777-71a0-4d01-9003-000000000005','c8bf22cd-55a0-4ffa-b3cf-1f207090f822','c026554b-3d0e-43cf-b61f-def383d664f6',7,'La rééducation secondaire suit principalement 5 objectifs, dont obtenir un contrôle actif du genou afin d’avoir une bonne stabilité.'),
('77777777-71a0-4d01-9003-000000000006','c8bf22cd-55a0-4ffa-b3cf-1f207090f822','c026554b-3d0e-43cf-b61f-def383d664f6',7,'Restaurer les amplitudes articulaires par rapport au côté controlatéral.'),
('77777777-71a0-4d01-9003-000000000007','c8bf22cd-55a0-4ffa-b3cf-1f207090f822','32ec41eb-5739-4503-8cba-96be35f7f0bc',7,'Reprise possible si le genou est sec, stable et indolore, la mobilité fonctionnelle et la force musculaire récupérée.'),
('77777777-71a0-4d01-9003-000000000008','c8bf22cd-55a0-4ffa-b3cf-1f207090f822','32ec41eb-5739-4503-8cba-96be35f7f0bc',7,'Les activités reprises ne sollicitent pas le transplant en cisaillement.'),
('77777777-71a0-4d01-9003-000000000009','5c4337e2-41f3-492f-8bd8-3d01c45e9495','9d4497d4-7d6b-42a1-8010-e0cc4533726c',45,'C3D. Identifier des critères de progression des niveaux atteints par la personne en lien avec la personne et ses attentes.'),
('77777777-71a0-4d01-9003-000000000010','5c4337e2-41f3-492f-8bd8-3d01c45e9495','9d4497d4-7d6b-42a1-8010-e0cc4533726c',45,'C3H. Faire évoluer la stratégie thérapeutique kinésithérapique si nécessaire.')
)
insert into public.question_sources(question_id,document_id,lesson_id,page_number,source_excerpt)
select * from s where not exists(select 1 from public.question_sources x where x.question_id=s.question_id and x.document_id=s.document_id and x.page_number=s.page_number);

update public.questions set is_published=true,validation_status='published',updated_at=now()
where id::text like '77777777-71a0-4d01-9003-%';

select public.refresh_release_health_status_v1();
