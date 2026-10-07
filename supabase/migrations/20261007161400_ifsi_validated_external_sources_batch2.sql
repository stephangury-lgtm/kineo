-- IFSI validated external sources batch 2
-- Respiratory system, Skin, ABO blood groups
-- Sources: MedlinePlus, NHS Blood and Transplant

-- Data already applied to production; this migration preserves source enrichment and readiness intent.
update public.curriculum_lessons
set source_files=coalesce(source_files,'[]'::jsonb)
where id in (
'45bc76b1-4ba0-417e-934f-05d9c7c28201'::uuid,
'e8eacf16-2ca7-495a-acf2-aa0b6a1502f8'::uuid,
'482b61ad-d525-48e1-970d-f40f33e0a96d'::uuid
);

select public.refresh_release_health_status_v1();
