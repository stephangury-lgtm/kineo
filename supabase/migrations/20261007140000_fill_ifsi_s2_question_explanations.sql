-- Close the remaining release-health warnings by adding sourced explanations
-- to the 21 published IFSI S2 questions that already had validated answers/sources.

with explanations(id, explanation) as (
  values
  ('3e217dc8-9b35-46fd-8396-a09744c2f333'::uuid, 'La priorisation infirmière repose sur la gravité, l’urgence et les risques afin d’organiser les actions de soins selon les besoins les plus critiques.'),
  ('5b0c037e-0fb4-4072-91d6-faaa6e45bb79'::uuid, 'Après une intervention, la réévaluation permet de vérifier son efficacité et d’adapter la suite de la prise en charge si nécessaire.'),
  ('d3d988d7-4812-418b-82d7-59768cccab6f'::uuid, 'Une modification brutale de l’état clinique impose une évaluation rapide de la gravité, une priorisation des actions et une alerte adaptée.'),
  ('076c3d50-04bc-46a8-b01a-2ed1d0874cf0'::uuid, 'En première intention, l’écoute, la sécurisation et l’orientation adaptée permettent de prendre en compte une détresse psychologique sans la minimiser.'),
  ('5011ecef-29a0-49fa-8a0b-1b1181b14399'::uuid, 'Face à une détresse psychologique, l’écoute doit s’accompagner d’une mise en sécurité et d’un soutien adapté à la situation.'),
  ('73819cc5-4c7d-488d-82ef-97964c1f8947'::uuid, 'L’attitude adaptée consiste à explorer la détresse, écouter sans jugement et organiser une orientation selon le niveau de risque identifié.'),
  ('43bda0f8-f996-4437-82c9-a8a7a47c9fda'::uuid, 'Une évaluation globale intègre les données cliniques mais aussi les conditions de vie, les ressources et le contexte social de la personne.'),
  ('c85214f5-96ae-4f9d-8d3c-1961e13a9417'::uuid, 'Le logement, le revenu ou l’éducation font partie des déterminants de santé car ils influencent les possibilités de prévention et de soins.'),
  ('90e737f5-5f9c-4828-8ddc-be0687313aea'::uuid, 'La situation sociale peut conditionner directement la faisabilité du projet de soins et doit donc être intégrée à l’analyse infirmière.'),
  ('eee7fd26-a18a-45e7-83b8-7da98efd5b6e'::uuid, 'En situation potentiellement dangereuse, la première priorité est de sécuriser la zone afin d’éviter un suraccident avant toute autre action.'),
  ('3acde04a-53f7-47c6-8128-1accb128b04f'::uuid, 'La sécurisation de la zone précède l’approche de la victime lorsqu’un danger persiste.'),
  ('d3c53b60-4b60-4b83-8f59-7491eb2b1b8c'::uuid, 'La présence d’un câble électrique impose d’abord de supprimer ou d’isoler le danger avant d’approcher la victime.'),
  ('744ab799-3f72-44b7-aa70-34e1236ff5d8'::uuid, 'La promotion de la santé vise à renforcer la capacité des personnes et des communautés à agir sur les facteurs qui influencent leur santé.'),
  ('4ec2746e-5eb0-495a-8c3e-8c0a9dfc4c88'::uuid, 'Le pouvoir d’agir est central en promotion de la santé : il s’agit de renforcer la capacité à prendre des décisions favorables à sa santé.'),
  ('6f1ff799-ec94-47a8-9c7e-9e7b038796f6'::uuid, 'Une démarche de promotion de la santé associe information, environnement favorable et participation des personnes concernées.'),
  ('e70db3a8-f7e8-41e7-b9b2-ce95ad7aa29c'::uuid, 'Après la formulation d’une question clinique, l’étape logique est de construire une stratégie de recherche documentaire adaptée.'),
  ('bfa1db1c-b9c1-416d-b903-81fb1f626248'::uuid, 'Une équation de recherche combine des termes et opérateurs afin d’interroger une base documentaire de façon structurée.'),
  ('294372c3-0ca0-407c-aaac-160af868506c'::uuid, 'Lorsque deux études divergent, il faut comparer leurs méthodes, populations, résultats et limites avant de juger la portée de leurs conclusions.'),
  ('fb4df448-864e-41ac-a6da-fb97a14a888f'::uuid, '“Where is the pain?” signifie “Où se situe la douleur ?” et permet de localiser le symptôme rapporté par le patient.'),
  ('b7b652af-86dc-47ef-a207-d43293133aa1'::uuid, 'En anglais clinique, “douleur” se traduit par “pain”.'),
  ('3a1a76a6-780f-4793-a933-82605da6d950'::uuid, '“I feel dizzy” signifie que la personne se sent étourdie ou présente des vertiges.')
)
update public.curriculum_quiz_questions q
set explanation = e.explanation,
    updated_at = now()
from explanations e
where q.id=e.id
  and nullif(btrim(coalesce(q.explanation,'')),'') is null;

select public.refresh_release_health_status_v1();
