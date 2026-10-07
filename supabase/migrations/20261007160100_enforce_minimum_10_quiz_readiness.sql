-- Minimum 10-question readiness rule
-- Complete the two K4 subjects below the threshold and expose readiness audits.

with q(id,chapter_id,lesson_id,question_text,explanation,difficulty,source_title) as (values
('ccccccc1-71a0-4d01-9008-000000000001'::uuid,'011742db-2435-404a-ad05-49d0c1a9c4cf'::uuid,'0eeccaa5-6da6-4acd-91e1-277b32b62029'::uuid,
'Cas clinique — Une situation associe problème clinique, limitation fonctionnelle et difficulté sociale. Quelle organisation est la plus adaptée ?',
'La HAS recommande une approche pluriprofessionnelle intégrant les dimensions clinique, fonctionnelle, sociale et psychologique.',4,
'HAS — Manuel de certification des établissements de santé, version 2024'),
('ccccccc1-71a0-4d01-9008-000000000002','011742db-2435-404a-ad05-49d0c1a9c4cf','0eeccaa5-6da6-4acd-91e1-277b32b62029',
'Cas d’intégration — Plusieurs options de prise en charge sont possibles et leurs bénéfices diffèrent selon les priorités du patient. Quelle démarche est la plus cohérente ?',
'La concertation pluriprofessionnelle permet de discuter les indications et les alternatives de prise en charge afin d’argumenter la décision.',5,
'HAS — Manuel de certification des établissements de santé, version 2024'),
('ccccccc1-71a0-4d01-9008-000000000003','8837112d-8fe8-4216-88e6-129d43ff0743','f210f626-4520-409b-b0d5-5454fd4e0b01',
'Cas d’intégration — En fin de formation, un étudiant sait réaliser des techniques mais peine à réévaluer l’efficacité de ses choix. Quelle compétence doit-il particulièrement renforcer ?',
'Le référentiel attend du masseur-kinésithérapeute qu’il sache analyser, évaluer et faire évoluer sa pratique professionnelle.',5,
'Ministère de la Santé — Référentiel de formation MK (arrêté du 2 septembre 2015)')
)
insert into public.questions(id,chapter_id,lesson_id,type,question_text,explanation,difficulty,metadata,source,is_published,validation_status,source_document)
select id,chapter_id,lesson_id,'clinical_case',question_text,explanation,difficulty,
'{"enrichment_batch":"minimum_10_v1","difficulty_scale_version":"2026-10-v1"}'::jsonb,
source_title,false,'review',source_title
from q on conflict(id) do nothing;

with o(question_id,a,b,c,d) as (values
('ccccccc1-71a0-4d01-9008-000000000001'::uuid,'Coordonner une approche pluriprofessionnelle intégrant les différentes dimensions','Traiter uniquement le problème biomédical','Reporter toute coordination à la fin de la prise en charge','Ignorer les difficultés sociales tant que la fonction progresse'),
('ccccccc1-71a0-4d01-9008-000000000002','Discuter les alternatives avec les professionnels concernés avant de retenir la stratégie','Choisir automatiquement la première option disponible','Éviter la concertation pour gagner du temps','Ne considérer qu’un seul aspect de la situation'),
('ccccccc1-71a0-4d01-9008-000000000003','Analyser, évaluer et faire évoluer sa pratique professionnelle','Répéter les mêmes techniques sans réévaluation','Se limiter à l’exécution technique','Éviter toute remise en question après la prise en charge')
)
insert into public.question_options(question_id,option_text,is_correct,display_order)
select question_id,v.txt,v.ok,v.ord from o
cross join lateral(values(a,true,1),(b,false,2),(c,false,3),(d,false,4)) v(txt,ok,ord)
where not exists(select 1 from public.question_options x where x.question_id=o.question_id and x.display_order=v.ord);

with s(question_id,document_id,lesson_id,page_number,source_excerpt) as (values
('ccccccc1-71a0-4d01-9008-000000000001'::uuid,'d09c4432-2171-419f-9275-273d1a8da25d'::uuid,'0eeccaa5-6da6-4acd-91e1-277b32b62029'::uuid,67,'Approche pluriprofessionnelle associant la prise en charge clinique à celle des difficultés fonctionnelles, sociales et psychologiques.'),
('ccccccc1-71a0-4d01-9008-000000000002','d09c4432-2171-419f-9275-273d1a8da25d','0eeccaa5-6da6-4acd-91e1-277b32b62029',69,'Une concertation pluridisciplinaire et/ou pluriprofessionnelle permet de discuter les indications à visée diagnostique et thérapeutique.'),
('ccccccc1-71a0-4d01-9008-000000000003','397628ce-2273-4c15-9685-ed41bde0d0e1','f210f626-4520-409b-b0d5-5454fd4e0b01',105,'Analyser, évaluer et faire évoluer sa pratique professionnelle.')
)
insert into public.question_sources(question_id,document_id,lesson_id,page_number,source_excerpt)
select * from s
where not exists(select 1 from public.question_sources x where x.question_id=s.question_id and x.document_id=s.document_id and x.page_number=s.page_number);

update public.questions set is_published=true,validation_status='published',updated_at=now()
where id::text like 'ccccccc1-71a0-4d01-9008-%';

create or replace view public.curriculum_quiz_readiness_v1 as
select
  p.id as program_id,
  a.code as level_code,
  t.id as topic_id,
  t.name as topic_name,
  count(q.id) filter(where q.is_published and q.validation_status='source_validated')::int as question_count,
  greatest(10-count(q.id) filter(where q.is_published and q.validation_status='source_validated'),0)::int as missing_to_ready,
  (count(q.id) filter(where q.is_published and q.validation_status='source_validated')>=10) as is_ready
from public.curriculum_topics t
join public.curriculum_units u on u.id=t.unit_id
join public.academic_levels a on a.id=u.academic_level_id
join public.programs p on p.id=u.program_id
left join public.curriculum_quiz_questions q on q.topic_id=t.id
where t.is_active and u.is_active
group by p.id,a.code,a.display_order,t.id,t.name;

create or replace view public.legacy_subject_quiz_readiness_v1 as
select
  y.name as level_label,
  s.id as subject_id,
  s.name as subject_name,
  count(q.id) filter(where q.is_published)::int as question_count,
  greatest(10-count(q.id) filter(where q.is_published),0)::int as missing_to_ready,
  (count(q.id) filter(where q.is_published)>=10) as is_ready
from public.subjects s
join public.years y on y.id=s.year_id
left join public.chapters c on c.subject_id=s.id
left join public.questions q on q.chapter_id=c.id
where y.number between 2 and 4
group by y.number,y.name,s.id,s.name;

select public.refresh_release_health_status_v1();
