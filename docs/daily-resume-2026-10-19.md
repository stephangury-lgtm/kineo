# Daily challenge resume

Leaving a France daily challenge before completion previously made the home screen offer a new session. A read-only RPC now finds today's own unfinished daily challenge, including zero answered questions. Home and the daily entry link preserve mode=daily and its original session ID, so completion still uses finish_daily_challenge_v2 and the daily bonus path.

The RPC returns only the caller's session/progress, never answers. Anonymous execution is revoked; completed, abandoned, expired, wrong-year and already rewarded challenges are excluded. Ordinary smart-session priority remains unchanged. Deployment order: install the additive migration, then publish the frontend. Frontend rollback remains compatible with the added unused RPC. To remove the RPC, first roll back the frontend, verify no caller remains, then drop only get_active_daily_revision_session_v1(); no learner data needs changing.

Validation: SQL fixture transaction rolled back (zero/one answer, ownership, abandoned/completed and anonymous identity), build, 33 unit tests, nine browser tests over Chromium/WebKit/Firefox with no retries, including daily completion and classic numbering. The initial unauthenticated test retained a fallback JWT claim; the fixture was corrected to clear both claim settings before the passing run.
