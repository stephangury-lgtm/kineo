# Leryko audit fixes — 14 October 2026

## Production status

The functional changes were merged in PR #11 and deployed to Cloudflare as commit `b948be0`. Authenticated production smoke checks passed in Chromium, Firefox and WebKit before the final answer-read revocation.

Both migrations are applied in production: `20261014190544` (atomic setup and safe quiz API) and `20261014193838` (raw-answer read revocation). Filenames match the actual migration history. The student-role SQL regression suite passed again after the revocation, with generated identities rolled back. Direct SELECT on the table, option corrections, accepted answers and matching metadata is denied to the authenticated role.

Local verification reported 38 browser passes, four Chromium-specific offline skips, three unit-test passes, successful TypeScript/build/source/security checks, and no vulnerabilities reported by npm audit. No audit test identities remain in production.

## Changes

- Atomic profile/curriculum setup supports IFSI S1/S2 and Spain ES1 and resumes partially configured accounts without changing their assigned curriculum.
- A student-scoped quiz RPC supplies prompts without correct options, accepted answers, explanations or matching solutions. Corrections and explanations come from the authorized answer submission.
- Curriculum question pools are paginated and topic IDs are batched, avoiding silent Data API truncation.
- Authentication keeps a slow-loading state and ignores late responses after logout. Profile errors offer retry.
- Publisher/support/privacy information is available before sign-in. Public contact details live in `src/config/publisher.ts` and can be edited there.
- Service-worker installation caches the shell and entry assets; deep routes fall back to that shell or a dedicated offline page. Cache writes clone the response before consumption and use `waitUntil`.
- Wrangler and Playwright are pinned to versions without vulnerabilities reported by npm audit at the time of verification. All browser workflows use the same Playwright version.

## Ordered rollout

1. Apply `audit_atomic_onboarding_and_safe_quiz_api` before deploying the frontend. It is compatible with the previous frontend. Production applied it on 14 October; the filename matches migration history.
2. Deploy this frontend through GitHub/Cloudflare. Verify the deployed commit and public information page, and run the authenticated production smoke workflow.
3. Apply `audit_revoke_curriculum_answer_reads` after the new frontend is verified. It revokes both table and column SELECT privileges, including PUBLIC inheritance. The old frontend must not be restored after this step without also updating its quiz readers to the safe API.

The final security migration intentionally has no data deletion. Keep the additive API and account setup fixes in place if a frontend rollback is needed.

## Validation

- TypeScript/Vite build, source invariants and build artifact budgets.
- Three unit tests for pagination, topic batching, failure propagation and empty input.
- Public and audit browser regressions on Chromium, WebKit and Firefox; offline tests are specific to Chromium.
- SQL assertions for first-year setup, retries, rollback of failed setup, curriculum locking, accessible-level filtering, answer redaction, explanation delivery, XP repetition and authenticated-role permissions.
- SQL tests use generated identities in a transaction and end with ROLLBACK. Never remove that rollback or execute the test body in autocommit.
- Eleven protected RPCs are probed as anonymous callers.

## Account-owner actions still required

- The credential-bearing push URL was removed from the local mirror. The previously exposed GitHub personal access token still needs to be revoked in GitHub settings; cleaning a URL cannot revoke it.
- Leaked-password protection remains an account setting. The available Supabase connector can migrate the database, but the CLI has no management login and the dashboard requests sign-in. Enable the option after signing in if the plan supports it; it is available on Pro and above.
- Publisher/support contact details are supplied by the owner. Retention periods and the full legal policy still need to be defined before public launch.
