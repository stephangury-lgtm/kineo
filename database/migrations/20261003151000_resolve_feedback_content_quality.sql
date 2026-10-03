-- Stabilisation issue-driven du corpus K2.
-- Repérage par contenu/source plutôt que par UUID afin de rester rejouable.

update public.questions
set image_url='/quiz-assets/atlas-cheville.svg',
    metadata=coalesce(metadata,'{}'::jsonb)||jsonb_build_object(
      'stabilization_fix','replace_non_rendering_talus_visual',
      'stabilization_fix_at','2026-10-03',
      'visual_rebuild_needed',true
    )
where question_text='À quel os répond la face inférieure de l’épiphyse distale du tibia ?'
  and metadata->>'source_title'='CM6 Ostéologie et arthrologie de la cheville';

update public.questions
set image_url=null,
    metadata=coalesce(metadata,'{}'::jsonb)||jsonb_build_object(
      'stabilization_fix','remove_irrelevant_hip_visual',
      'stabilization_fix_at','2026-10-03',
      'visual_card',false,
      'visual_rebuild_needed',true
    )
where question_text='Quel muscle prend origine sur la face antérieure du sacrum S2, S3 et S4 ?'
  and metadata->>'source_title'='CM2 Myologie de la hanche';

update public.questions
set question_text='Sur quel relief osseux se termine le muscle iliaque, via le tendon commun de l’ilio-psoas ?',
    explanation='Le muscle iliaque rejoint le psoas majeur pour former l’ilio-psoas ; leur tendon commun se termine sur le petit trochanter du fémur.',
    metadata=coalesce(metadata,'{}'::jsonb)||jsonb_build_object(
      'stabilization_fix','clarify_iliacus_iliopsoas_wording',
      'stabilization_fix_at','2026-10-03'
    )
where question_text='Sur quel relief osseux se termine l’iliaque ?'
  and metadata->>'source_title'='CM2 Myologie de la hanche';

update public.questions
set question_text='Le grand psoas, constituant de l’ilio-psoas, passe sous le ligament inguinal.',
    explanation='Vrai : le grand psoas participe à l’ilio-psoas et passe sous le ligament inguinal avant sa terminaison fémorale.',
    metadata=coalesce(metadata,'{}'::jsonb)||jsonb_build_object(
      'stabilization_fix','clarify_psoas_iliopsoas_wording',
      'stabilization_fix_at','2026-10-03'
    )
where question_text='Le psoas passe sous le ligament inguinal.'
  and metadata->>'source_title'='CM2 Myologie de la hanche';

update public.questions
set is_published=false,
    validation_status='archived',
    metadata=coalesce(metadata,'{}'::jsonb)||jsonb_build_object(
      'stabilization_fix','archive_low_value_easy_question',
      'stabilization_fix_at','2026-10-03'
    )
where question_text='Quelle action digitale est attribuée au long extenseur de l’hallux ?'
  and metadata->>'source_title'='CM7 Myologie de la cheville';
