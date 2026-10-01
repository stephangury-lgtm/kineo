import { supabase } from '../lib/supabase'

export type AtlasAttemptSummary = {
  area: string
  question_count: number
  correct_count: number
  accuracy_percent: number
  duration_ms: number
  best_accuracy_percent: number
  best_duration_ms: number
}

export type AtlasAreaStats = {
  area: string
  attempts: number
  best_accuracy_percent: number
  best_duration_ms: number
  last_played_at: string
}

export async function finishAtlasSessionV1(sessionId: string) {
  const { data, error } = await supabase.rpc('finish_atlas_session_v1', { p_session_id: sessionId })
  if (error) throw error
  return data as AtlasAttemptSummary
}

export async function getAtlasStatsV1() {
  const { data, error } = await supabase.rpc('get_atlas_stats_v1')
  if (error) throw error
  return (data ?? []) as AtlasAreaStats[]
}
