-- Ensure every IFSI 2026 semester has at least ten source-validated MCQs for same-level/same-version friend duels.
-- Idempotent by (topic_id, question_text): safe to replay on an already-enriched environment.

with seed(topic_id,question_text,explanation,options,difficulty,source_label) as (
  values
  ('96ae99f9-92bd-4e3a-9435-a8aafa3e3a04'::uuid,
   'Pourquoi repérer les déterminants sociaux lors d’une situation de soins ?',
   'Les conditions de vie peuvent influencer l’accès aux soins, l’adhésion et les vulnérabilités ; les repérer aide à adapter l’accompagnement.',
   '[{"text":"Pour comprendre les obstacles d’accès aux soins et adapter l’accompagnement","correct":true},{"text":"Pour remplacer l’évaluation clinique","correct":false},{"text":"Pour attribuer une cause unique à la maladie","correct":false},{"text":"Pour limiter la prise en charge au niveau de revenu","correct":false}]'::jsonb,
   2,'OMS – Déterminants sociaux de la santé'),
  ('5c147098-beaf-408f-8acf-765c10074a44'::uuid,
   'Avant un soin, quelle démarche respecte le consentement libre et éclairé ?',
   'L’information doit être adaptée et intelligible, la compréhension vérifiée et l’accord de la personne recherché avant le soin.',
   '[{"text":"Expliquer le soin avec des mots adaptés, vérifier la compréhension et rechercher l’accord","correct":true},{"text":"Réaliser d’abord le soin puis informer","correct":false},{"text":"Demander uniquement l’accord de la famille","correct":false},{"text":"Considérer l’absence de question comme un consentement","correct":false}]'::jsonb,
   2,'Code de déontologie des infirmiers – Légifrance'),
  ('d7c00f19-c96f-4835-a9f2-0c4a05ca49d8'::uuid,
   'Quelle action correspond le mieux à une démarche de promotion de la santé ?',
   'La promotion de la santé vise à renforcer les capacités des personnes et à agir sur leur environnement, avec leur participation.',
   '[{"text":"Construire avec la personne une action tenant compte de ses ressources et de son environnement","correct":true},{"text":"Se limiter à transmettre une consigne","correct":false},{"text":"Agir uniquement après l’apparition d’une maladie","correct":false},{"text":"Exclure l’environnement social de l’analyse","correct":false}]'::jsonb,
   2,'OMS – Charte d’Ottawa pour la promotion de la santé'),
  ('5d5b6066-f151-4ed3-bb79-bbf16b11d195'::uuid,
   'Quel élément doit être clarifié pendant un briefing avant l’activité ?',
   'Le briefing prépare l’action collective en partageant notamment objectifs, rôles et points de vigilance.',
   '[{"text":"Les objectifs, les rôles et les points de vigilance","correct":true},{"text":"Uniquement le résultat final attendu","correct":false},{"text":"Les erreurs individuelles à sanctionner","correct":false},{"text":"Seulement la durée de l’activité","correct":false}]'::jsonb,
   2,'HAS · Briefing et débriefing'),
  ('cc99edc8-367d-40ed-9f4a-51ab8e40b109'::uuid,
   'Pourquoi limiter les interruptions pendant la préparation et l’administration des médicaments ?',
   'Les interruptions de tâche augmentent le risque d’erreur lors de la préparation et de l’administration médicamenteuse.',
   '[{"text":"Parce qu’elles augmentent le risque d’erreur","correct":true},{"text":"Parce qu’elles annulent automatiquement la prescription","correct":false},{"text":"Pour éviter toute communication avec le patient","correct":false},{"text":"Pour réduire uniquement le temps de traçabilité","correct":false}]'::jsonb,
   2,'HAS · Interruptions de tâche'),
  ('f44da6bd-bc0e-46e7-be8a-f4ba591a08e5'::uuid,
   'Dans la traçabilité d’un signal de maltraitance, que faut-il privilégier ?',
   'Une traçabilité utile distingue les éléments factuels des interprétations et soutient une transmission professionnelle.',
   '[{"text":"Des éléments factuels distingués des interprétations","correct":true},{"text":"Des suppositions non vérifiées","correct":false},{"text":"Seulement l’avis général de l’équipe","correct":false},{"text":"Aucune trace écrite pour préserver la confidentialité","correct":false}]'::jsonb,
   2,'HAS · Bientraitance et gestion des signaux de maltraitance · mise à jour 2026'),
  ('b4cbd7d0-5db0-44b6-bde9-6de56cd8c5bd'::uuid,
   'Face à une suspicion de sepsis, quelle priorité ressort des recommandations ?',
   'Le sepsis est une urgence nécessitant une évaluation rapide et une orientation sans délai vers une prise en charge adaptée.',
   '[{"text":"Évaluer rapidement et orienter sans délai vers une prise en charge adaptée","correct":true},{"text":"Attendre l’évolution plusieurs heures avant d’alerter","correct":false},{"text":"Se fier uniquement à la température","correct":false},{"text":"Reporter la réévaluation après stabilisation spontanée","correct":false}]'::jsonb,
   2,'HAS · Prise en charge du sepsis · 2025'),
  ('d3d7dec6-932e-423a-8ec7-3c0b2fdd57ec'::uuid,
   'Après les premières mesures face à une urgence vitale intra-hospitalière, que faut-il faire jusqu’au relais spécialisé ?',
   'L’état de la personne et l’efficacité des premières mesures doivent être réévalués continuellement jusqu’au relais spécialisé.',
   '[{"text":"Réévaluer continuellement l’état du patient et l’efficacité des mesures","correct":true},{"text":"Arrêter la surveillance après avoir donné l’alerte","correct":false},{"text":"Attendre le relais sans nouvelle évaluation","correct":false},{"text":"Documenter uniquement en fin d’intervention","correct":false}]'::jsonb,
   2,'HAS · Urgence vitale intra-hospitalière · 2026'),
  ('574166ca-c966-4ef5-a1e9-b1f7286fcc03'::uuid,
   'Quel est l’objectif principal du débriefing après une simulation ?',
   'Le débriefing analyse les décisions et actions pour transformer l’expérience en apprentissage et améliorer les pratiques.',
   '[{"text":"Analyser les décisions et actions pour transformer l’expérience en apprentissage","correct":true},{"text":"Classer les participants selon leur performance","correct":false},{"text":"Sanctionner les erreurs commises pendant le scénario","correct":false},{"text":"Répéter immédiatement le scénario sans analyse","correct":false}]'::jsonb,
   2,'HAS · Simulation en santé · mise à jour 2025'),
  ('12ef11c6-978b-4b88-beaf-67c2904198e3'::uuid,
   'Quelle attitude montre une autonomie professionnelle sécurisée face à une situation dépassant ses limites ?',
   'L’autonomie professionnelle inclut la capacité à reconnaître ses limites, sécuriser la situation et solliciter l’aide adaptée.',
   '[{"text":"Reconnaître ses limites, sécuriser la situation et solliciter l’aide adaptée","correct":true},{"text":"Agir seul pour démontrer son autonomie","correct":false},{"text":"Reporter toute décision, même dans son champ de responsabilité","correct":false},{"text":"Ignorer le besoin d’escalade tant que la situation n’est pas critique","correct":false}]'::jsonb,
   2,'Ministère de la Santé — Formation en soins infirmiers 2026')
),
to_insert as (
  select s.*,
         coalesce((select max(q.display_order) from public.curriculum_quiz_questions q where q.topic_id=s.topic_id),0)
         + row_number() over(partition by s.topic_id order by s.question_text) as display_order
  from seed s
  where not exists (
    select 1 from public.curriculum_quiz_questions q
    where q.topic_id=s.topic_id and q.question_text=s.question_text
  )
)
insert into public.curriculum_quiz_questions(
  topic_id,question_text,explanation,options,difficulty,source_label,display_order,
  validation_status,is_published,question_type,accepted_answers,metadata
)
select topic_id,question_text,explanation,options,difficulty,source_label,display_order,
       'source_validated',true,'mcq','[]'::jsonb,'{}'::jsonb
from to_insert;
