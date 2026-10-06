-- Student beta hardening: an archived visual exercise must never remain visible to students.
-- Real anatomy/mobile/target QA is still required before any reactivation.

update public.questions
set is_published = false,
    updated_at = now()
where type in ('hotspot','image')
  and validation_status = 'archived'
  and is_published = true;
