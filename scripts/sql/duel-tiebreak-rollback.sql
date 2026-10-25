-- Disable the new entry points while retaining all recorded rounds.
revoke execute on function public.duel_tiebreak_v1(uuid,text,integer,text,boolean) from authenticated;
revoke execute on function public.get_duel_tiebreak_results_v1(text) from authenticated;
-- Restore the previous frontend release through the existing Cloudflare rollback workflow.
-- Use anatomy-source-figures-rollback.sql only if reverting the course illustrations too.
