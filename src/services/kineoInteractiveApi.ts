import { supabase } from '../lib/supabase'
import type { QuizQuestionV3 } from './kineoApi'

export async function getQuizQuestionsV5(sessionId: string) {
  const { data, error } = await supabase.rpc('get_quiz_questions_v5', { p_session_id: sessionId })
  if (error) throw error
  return (data ?? []) as QuizQuestionV3[]
}

export async function submitQuizAnswerV5(params: { sessionId: string; questionId: string; answer: unknown; responseTimeMs: number }) {
  const { data, error } = await supabase.rpc('submit_quiz_answer_v5', {
    p_session_id: params.sessionId,
    p_question_id: params.questionId,
    p_answer: params.answer,
    p_response_time_ms: params.responseTimeMs,
  })
  if (error) throw error
  return data
}
