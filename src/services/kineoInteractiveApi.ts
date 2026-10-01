import { supabase } from '../lib/supabase'
import type { QuizQuestionV3 } from './kineoApi'

const DUPLICATE_SEPARATOR = '\u2063'

function makeMatchingLabelsUnique(question: QuizQuestionV3): QuizQuestionV3 {
  if (question.type !== 'matching') return question
  const raw = Array.isArray(question.metadata?.right_items) ? question.metadata.right_items as string[] : []
  if (!raw.length) return question

  const totals = raw.reduce<Record<string, number>>((acc, value) => {
    acc[value] = (acc[value] ?? 0) + 1
    return acc
  }, {})
  const seen: Record<string, number> = {}
  const rightItems = raw.map((value) => {
    if ((totals[value] ?? 0) <= 1) return value
    seen[value] = (seen[value] ?? 0) + 1
    return `${value}${DUPLICATE_SEPARATOR}${seen[value]}`
  })

  return {
    ...question,
    metadata: {
      ...question.metadata,
      right_items: rightItems,
    },
  }
}

function normalizeMatchingAnswer(answer: unknown) {
  if (!answer || typeof answer !== 'object') return answer
  const value = answer as { pairs?: Array<{ left: string; right: string }> }
  if (!Array.isArray(value.pairs)) return answer
  return {
    ...value,
    pairs: value.pairs.map((pair) => ({
      ...pair,
      right: typeof pair.right === 'string'
        ? pair.right.replace(new RegExp(`${DUPLICATE_SEPARATOR}\\d+$`), '')
        : pair.right,
    })),
  }
}

export async function getQuizQuestionsV5(sessionId: string) {
  const { data, error } = await supabase.rpc('get_quiz_questions_v5', { p_session_id: sessionId })
  if (error) throw error
  return ((data ?? []) as QuizQuestionV3[]).map(makeMatchingLabelsUnique)
}

export async function submitQuizAnswerV5(params: { sessionId: string; questionId: string; answer: unknown; responseTimeMs: number }) {
  const { data, error } = await supabase.rpc('submit_quiz_answer_v5', {
    p_session_id: params.sessionId,
    p_question_id: params.questionId,
    p_answer: normalizeMatchingAnswer(params.answer),
    p_response_time_ms: params.responseTimeMs,
  })
  if (error) throw error
  return data
}
