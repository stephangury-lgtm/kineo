-- The vastus medialis and vastus lateralis SVG files are byte-identical and cannot support reliable identification.
-- Keep both exercises quarantined until two distinct validated muscle visuals replace them.
update public.questions
set metadata = jsonb_set(
  jsonb_set(
    jsonb_set(
      jsonb_set(coalesce(metadata,'{}'::jsonb),'{visual_approved}','false'::jsonb,true),
      '{visual_review_required}','true'::jsonb,true
    ),
    '{hotspot_calibration_status}','"blocked_duplicate_asset"'::jsonb,true
  ),
  '{visual_review}',
  jsonb_build_object('anatomy_ok',false,'mobile_ok',false,'target_ok',false,'source_ok',true),
  true
),
is_published = false,
validation_status = 'archived',
updated_at = now()
where id in (
  '84afabea-a7f9-494b-b502-e83f53a75089'::uuid,
  'dbe66dfd-ce53-4d01-a3a5-963784bfed5e'::uuid
);
