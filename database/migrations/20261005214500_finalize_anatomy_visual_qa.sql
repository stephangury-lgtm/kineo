-- Finalize anatomy V2 visual QA after live asset inspection.
-- Keeps all canonical interactive exercises archived until real mobile touch QA is completed.
-- Two quadriceps hotspots remain blocked because no reliable muscle visual is available yet.

update public.questions
set image_url = case id
  when 'a941abf6-4a21-4160-bd30-6441bc58b559'::uuid then '/quiz-assets/ifmk/knee-patella.svg'
  when '70b438cc-a951-46a1-9c5e-85ea7b0e964c'::uuid then '/quiz-assets/ifmk/knee-lca.svg'
  when '248dc932-81a1-41e1-8e62-ed98dfe36f61'::uuid then '/quiz-assets/ifmk/knee-lcp.svg'
  when '1df0c7e3-c7e2-47c3-aaed-c839b9e64db8'::uuid then '/quiz-assets/ifmk/hip-gluteal.svg'
  else image_url
end,
metadata = case id
  when 'a941abf6-4a21-4160-bd30-6441bc58b559'::uuid then jsonb_set(jsonb_set(metadata,'{target_visual_v2}','"ifmk/knee-patella.svg"'::jsonb,true),'{hotspot_v2}','{"x":50,"y":50,"radius":8,"label":"Patella"}'::jsonb,true)
  when '70b438cc-a951-46a1-9c5e-85ea7b0e964c'::uuid then jsonb_set(jsonb_set(metadata,'{target_visual_v2}','"ifmk/knee-lca.svg"'::jsonb,true),'{hotspot_v2}','{"x":57.2,"y":70.7,"radius":5,"label":"LCA"}'::jsonb,true)
  when '248dc932-81a1-41e1-8e62-ed98dfe36f61'::uuid then jsonb_set(jsonb_set(metadata,'{target_visual_v2}','"ifmk/knee-lcp.svg"'::jsonb,true),'{hotspot_v2}','{"x":45.3,"y":57.6,"radius":5,"label":"LCP"}'::jsonb,true)
  when '1df0c7e3-c7e2-47c3-aaed-c839b9e64db8'::uuid then jsonb_set(jsonb_set(metadata,'{target_visual_v2}','"ifmk/hip-gluteal.svg"'::jsonb,true),'{hotspot_v2}','{"x":51.6,"y":75.6,"radius":6,"label":"Petit glutéal"}'::jsonb,true)
  when 'a1c6b7ed-1b0c-468a-af55-62a23e30d53f'::uuid then jsonb_set(metadata,'{hotspot_v2}','{"x":79.5,"y":58.5,"radius":5,"label":"Malléole latérale"}'::jsonb,true)
  when '2a98bf72-f145-47ac-82da-f26eb0af2b8e'::uuid then jsonb_set(metadata,'{hotspot_v2}','{"x":74.7,"y":54.7,"radius":6,"label":"TP"}'::jsonb,true)
  when '266bc643-cd63-42cb-9809-c15c72bc6738'::uuid then jsonb_set(metadata,'{hotspot_v2}','{"x":68.6,"y":54.7,"radius":5,"label":"LFH"}'::jsonb,true)
  when '6d379291-94da-4268-b9e9-9143bd0edb67'::uuid then jsonb_set(metadata,'{hotspot_v2}','{"x":82.8,"y":91.1,"radius":4,"label":"C1"}'::jsonb,true)
  when '7fc44dbb-24b7-44e5-b9f9-ac76e9f3687e'::uuid then jsonb_set(metadata,'{hotspot_v2}','{"x":87.7,"y":89.3,"radius":4,"label":"C2"}'::jsonb,true)
  when '935ffac2-4b2d-47cd-a0bd-0a072c5e2855'::uuid then jsonb_set(metadata,'{hotspot_v2}','{"x":89.8,"y":87.0,"radius":4,"label":"C3"}'::jsonb,true)
  else metadata
end,
updated_at = now()
where id in (
  'a941abf6-4a21-4160-bd30-6441bc58b559','70b438cc-a951-46a1-9c5e-85ea7b0e964c',
  '248dc932-81a1-41e1-8e62-ed98dfe36f61','1df0c7e3-c7e2-47c3-aaed-c839b9e64db8',
  'a1c6b7ed-1b0c-468a-af55-62a23e30d53f','2a98bf72-f145-47ac-82da-f26eb0af2b8e',
  '266bc643-cd63-42cb-9809-c15c72bc6738','6d379291-94da-4268-b9e9-9143bd0edb67',
  '7fc44dbb-24b7-44e5-b9f9-ac76e9f3687e','935ffac2-4b2d-47cd-a0bd-0a072c5e2855'
);

update public.questions
set metadata = jsonb_set(
  jsonb_set(metadata,'{visual_review_required}','false'::jsonb,true),
  '{hotspot_calibration_status}','"visual_qa_pass"'::jsonb,true
), updated_at = now()
where coalesce((metadata->>'canonical_visual_exercise')::boolean,false)
  and id not in (
    '84afabea-a7f9-494b-b502-e83f53a75089'::uuid,
    'dbe66dfd-ce53-4d01-a3a5-963784bfed5e'::uuid
  );

update public.questions
set metadata = jsonb_set(
  jsonb_set(metadata,'{visual_review_required}','true'::jsonb,true),
  '{hotspot_calibration_status}','"blocked_asset"'::jsonb,true
), updated_at = now()
where id in (
  '84afabea-a7f9-494b-b502-e83f53a75089'::uuid,
  'dbe66dfd-ce53-4d01-a3a5-963784bfed5e'::uuid
);
