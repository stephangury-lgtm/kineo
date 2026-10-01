import { supabase } from '../lib/supabase'

export type DashboardV2 = {
  profile?: { xp?: number; level?: number }
  level?: { current?: number; next?: number; xp_to_next?: number; progress_percent?: number }
  streak?: { current?: number; best?: number }
  mastery?: { overall_percent?: number; mastered?: number; fragile?: number; due?: number }
  activity?: { completed_sessions?: number; last_session?: unknown }
  badges?: { earned?: number; total?: number }
  daily?: { ready?: boolean; question_count?: number; completed?: boolean; status?: string }
  [key: string]: unknown
}

export type QuizOptionV3 = { id: string; option_text: string; display_order: number }
export type QuizQuestionV3 = {
  id: string
  type: string
  question_text: string
  difficulty: number
  image_url: string | null
  metadata: Record<string, unknown>
  question_options: QuizOptionV3[]
  display_order: number
}

export type UserStatsV2 = {
  period_days: number
  summary: {
    attempts: number; correct_answers: number; incorrect_answers: number; accuracy_percent: number
    avg_response_ms: number; completed_sessions: number; xp_total: number; level: number
    attempted_questions: number; mastered_questions: number; fragile_questions: number
    reviews_due: number; mastery_percent: number
  }
  daily_activity: Array<{ date: string; attempts: number; correct: number; accuracy_percent: number; xp: number }>
  subjects: Array<{
    id: string; name: string; year_number: number; published_questions: number; attempted_questions: number
    coverage_percent: number; attempts: number; accuracy_percent: number; mastery_percent: number
    mastered_questions: number; fragile_questions: number
  }>
  modes: Array<{ mode: string; sessions: number; questions: number; correct: number; accuracy_percent: number; xp: number }>
  weak_questions: Array<{ question_id: string; question_text: string; subject_name: string; accuracy_percent: number; mastery_percent: number }>
}

export type DailyChallengeStart = {
  challenge_id: string
  challenge_date: string
  session_id: string
  question_count: number
  answered_count: number
  remaining_count: number
  completed: boolean
  score: number | null
  xp_earned: number | null
  status: 'ready' | 'in_progress' | 'completed'
}

export type GamificationSummaryV2 = {
  xp_total: number
  level: {
    number: number
    name: string
    icon: string
    required_xp: number
    next_level: number | null
    next_name: string | null
    next_icon: string | null
    next_required_xp: number | null
    xp_to_next: number
    progress_percent: number
  }
  streak: { current: number; longest: number }
  badges: { earned: number; total: number }
}

export type BadgeProgressV2 = {
  id: string
  name: string
  description: string
  icon: string
  condition_type: string
  earned: boolean
  earned_at: string | null
  current_value: number
  target_value: number
  progress_percent: number
}

export type BadgesV2 = {
  badges: BadgeProgressV2[]
  stats: {
    completed_quizzes: number
    correct_answers: number
    current_streak: number
    daily_challenges: number
    daily_perfect: boolean
  }
}

export async function getDashboardV2() {
  const { data, error } = await supabase.rpc('get_user_dashboard_v2')
  if (error) throw error
  return data as DashboardV2
}

export async function getUserStatsV2(days = 30) {
  const { data, error } = await supabase.rpc('get_user_stats_v2', { p_days: days })
  if (error) throw error
  return data as UserStatsV2
}

export async function getGamificationSummaryV2() {
  const { data, error } = await supabase.rpc('get_gamification_summary_v2')
  if (error) throw error
  return data as GamificationSummaryV2
}

export async function getBadgesV2() {
  const { data, error } = await supabase.rpc('get_badges_v2')
  if (error) throw error
  return data as BadgesV2
}

export async function startSmartRevisionV2(questionCount = 10) {
  const { data, error } = await supabase.rpc('start_smart_revision_v2', { p_question_count: questionCount })
  if (error) throw error
  return data as string
}

export async function startDailyChallengeV2() {
  const { data, error } = await supabase.rpc('start_daily_challenge_v2', { p_challenge_date: new Date().toISOString().slice(0, 10) })
  if (error) throw error
  return data as DailyChallengeStart
}

export async function getQuizQuestionsV4(sessionId: string) {
  const { data, error } = await supabase.rpc('get_quiz_questions_v4', { p_session_id: sessionId })
  if (error) throw error
  return (data ?? []) as QuizQuestionV3[]
}

export async function submitQuizAnswerV3(params: { sessionId: string; questionId: string; answer: unknown; responseTimeMs: number }) {
  const { data, error } = await supabase.rpc('submit_quiz_answer_v3', {
    p_session_id: params.sessionId,
    p_question_id: params.questionId,
    p_answer: params.answer,
    p_response_time_ms: params.responseTimeMs,
  })
  if (error) throw error
  return data
}

export async function submitQuizAnswerV4(params: { sessionId: string; questionId: string; answer: unknown; responseTimeMs: number }) {
  const { data, error } = await supabase.rpc('submit_quiz_answer_v4', {
    p_session_id: params.sessionId,
    p_question_id: params.questionId,
    p_answer: params.answer,
    p_response_time_ms: params.responseTimeMs,
  })
  if (error) throw error
  return data
}

export async function finishQuizSessionV2(sessionId: string) {
  const { data, error } = await supabase.rpc('finish_quiz_session_v2', {
    p_session_id: sessionId,
    p_activity_date: new Date().toISOString().slice(0, 10),
  })
  if (error) throw error
  return data
}

export async function finishDailyChallengeV2(sessionId: string) {
  const { data, error } = await supabase.rpc('finish_daily_challenge_v2', {
    p_session_id: sessionId,
    p_activity_date: new Date().toISOString().slice(0, 10),
  })
  if (error) throw error
  return data
}
