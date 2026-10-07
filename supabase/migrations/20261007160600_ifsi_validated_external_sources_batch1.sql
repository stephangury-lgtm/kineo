-- IFSI validated external sources batch 1
-- Sources: NIDDK/NIH, MedlinePlus/NIH, MSD professional reference.
-- Completes Digestive system, Endocrine system, and Blood glucose regulation to >=10 validated questions.

update public.curriculum_lessons
set content='L’appareil digestif comprend le tube digestif, de la bouche à l’anus, ainsi que des organes annexes comme le foie, le pancréas et la vésicule biliaire. La digestion associe des mouvements mécaniques, notamment la mastication et le péristaltisme, à l’action des sucs digestifs. L’intestin grêle assure l’essentiel de l’absorption des nutriments. Le gros intestin absorbe notamment de l’eau et transforme progressivement le contenu digestif en selles. Le foie produit la bile, la vésicule biliaire la stocke et le pancréas sécrète des enzymes digestives. Les nerfs et les hormones participent aussi à la régulation du processus digestif.',
    source_files=coalesce(source_files,'[]'::jsonb) || jsonb_build_array(
      jsonb_build_object('label','NIDDK/NIH — Your Digestive System & How it Works','url','https://www.niddk.nih.gov/health-information/digestive-diseases/digestive-system-how-it-works','validation','institutional_validated'),
      jsonb_build_object('label','MedlinePlus — Anatomie / appareil digestif','url','https://medlineplus.gov/spanish/anatomy.html','validation','institutional_validated')
    ),
    updated_at=now()
where id='683a7e3f-d2ba-487b-95c1-74f5b2f65612'::uuid;

update public.curriculum_lessons
set content='Le système endocrinien regroupe des glandes qui sécrètent des hormones dans la circulation sanguine. Les hormones agissent comme des messagers chimiques sur des cellules ou organes cibles possédant des récepteurs adaptés. Elles participent notamment à la croissance, au métabolisme, à la reproduction, à l’équilibre hydrique, à la réponse au stress et à la régulation de la température. Un trouble endocrinien peut résulter d’une production hormonale trop faible ou trop importante, d’un dysfonctionnement de la glande ou d’une réponse anormale du tissu cible.',
    source_files=coalesce(source_files,'[]'::jsonb) || jsonb_build_array(
      jsonb_build_object('label','MedlinePlus/NIH — Endocrine Diseases','url','https://medlineplus.gov/endocrinediseases.html','validation','institutional_validated'),
      jsonb_build_object('label','Manuel MSD professionnel — Revue générale du système endocrinien','url','https://www.msdmanuals.com/fr/professional/troubles-endocriniens-et-m%C3%A9taboliques/principes-endocrinologie/revue-g%C3%A9n%C3%A9rale-du-syst%C3%A8me-endocrinien','validation','peer_reviewed_reference')
    ),
    updated_at=now()
where id='9894e538-f334-462d-84b1-47ee5510308a'::uuid;

update public.curriculum_lessons
set content='La glycémie correspond à la concentration de glucose dans le sang. Sa régulation repose en grande partie sur l’action coordonnée de l’insuline et du glucagon, deux hormones produites par le pancréas endocrine. Lorsque la glycémie augmente, notamment après un repas, les cellules bêta pancréatiques libèrent de l’insuline, ce qui favorise l’utilisation et le stockage du glucose et contribue à faire baisser la glycémie. Lorsque la glycémie baisse, les cellules alpha libèrent du glucagon, qui stimule notamment la libération de glucose par le foie. Le foie, le muscle et le tissu adipeux participent aussi à l’homéostasie glucidique.',
    source_files=coalesce(source_files,'[]'::jsonb) || jsonb_build_array(
      jsonb_build_object('label','NIDDK/NIH — Insulin and glucagon in blood glucose regulation','url','https://www.niddk.nih.gov/news/archive/2021/story-discovery-medications-diabetes-obesity-emerged-research-pancreatic-hormone','validation','institutional_validated'),
      jsonb_build_object('label','NIDDK/NIH — Pancreas responds to low or high blood glucose levels','url','https://www.niddk.nih.gov/news/media-library/17969','validation','institutional_validated')
    ),
    updated_at=now()
where id='34f967dd-5d5b-47c7-aa48-9acbe746d610'::uuid;

-- Questions are already present idempotently in production from the validated batch.
-- Keep migration concise: verify the expected readiness and release health.
do $$
begin
 if exists(
   select 1 from public.curriculum_quiz_readiness_v1
   where topic_id in (
     '78e455b5-75a8-43c8-bd10-22c6e7a27f72'::uuid,
     '508670dc-3dfe-45a4-ac1f-8adee52e88af'::uuid,
     '478c3df1-d7ae-4dfc-a22f-7f737d431a1a'::uuid
   ) and not is_ready
 ) then
   raise exception 'Validated external source batch 1 is not ready: expected >=10 validated questions per topic';
 end if;
end $$;

select public.refresh_release_health_status_v1();
