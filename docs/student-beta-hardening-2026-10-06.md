# Student beta hardening — 2026-10-06

## Build and runtime
- GitHub CI run #207 on commit `692c8875` completed successfully.
- Supabase PostgREST logs: no HTTP 500/502/503/504 found in the audited 24-hour window.
- PostgreSQL errors observed during the window were administration/migration/schema-probing errors or expected quality guard rejections, not identified student runtime 5xx failures.

## Security
- Sensitive user tables audited with RLS enabled.
- `feedback` and `inactivity_email_log` have no direct anon/authenticated table grants; access is mediated by controlled RPC/service-role workflows.
- Removed anonymous EXECUTE from authenticated `SECURITY DEFINER` RPCs and re-granted only to `authenticated` / `service_role` as appropriate.
- Follow-up audit: zero public `SECURITY DEFINER` functions retaining an `anon` ACL.

## Anatomy visual quarantine
- 64 visual exercises audited: 56 hotspot + 8 image/label exercises.
- 64/64 have an image, structural target data and complete source traceability (page + excerpt).
- Detected 32 visual exercises with `validation_status='archived'` but `is_published=true`.
- Enforced quarantine: archived visual exercises are now unpublished; follow-up count = 0 archived visuals still published.
- Distribution: 16 hip, 16 knee, 16 ankle, 16 foot.
- Human/device validation remains intentionally pending: anatomy/mobile/target review is not auto-approved.

## Mobile/PWA static hardening
- Existing safe-area support, `100dvh`, 16px form controls, service worker, manifest and 44px primary actions confirmed.
- Raised visual label chips and curriculum options to a 44px minimum touch target on mobile.
- Added mobile-safe sizing and overflow protection for fill-blank and matching controls.
- Raised `<summary>` touch target to 44px.

## Beta readiness status
Core student flows can continue toward beta with anatomy visual mode quarantined. The next remaining quality gate is real-device validation of the anatomy interactions before those 64 exercises are re-enabled.
