import { supabase } from '../lib/supabase'

export type ReviewQuestion = {
  id: string
  type: string
  question_text: string
  explanation: string | null
  difficulty: number
  source: string | null
  source_document: string | null
  validation_status: 'draft' | 'review' | 'validated' | 'published' | 'archived'
  is_published: boolean
}

export type ReviewLesson = {
  id: string
  title: string
  summary: string | null
  content: string | null
  key_points: unknown[]
  sources: unknown[]
  validation_status: 'draft' | 'review' | 'validated' | 'published' | 'archived'
  is_published: boolean
  validated_at: string | null
  year_number: number
  subject_name: string
  chapter_name: string
  question_count: number
  review_questions: number
  validated_questions: number
  published_questions: number
  questions: ReviewQuestion[]
}

export type ContentReviewQueue = {
  lessons: ReviewLesson[]
  counts: { review: number; validated: number; published: number }
}

export async function getContentReviewQueue() {
  const { data, error } = await supabase.rpc('get_content_review_queue_v1')
  if (error) throw error
  return data as ContentReviewQueue
}

export async function setContentReviewStatus(kind: 'lesson' | 'question', id: string, status: 'draft' | 'review' | 'validated' | 'published') {
  const { data, error } = await supabase.rpc('set_content_review_status_v1', {
    p_kind: kind,
    p_id: id,
    p_status: status,
  })
  if (error) throw error
  return data
}

export async function publishLessonBundle(lessonId: string) {
  const { data, error } = await supabase.rpc('publish_lesson_bundle_v1', { p_lesson_id: lessonId })
  if (error) throw error
  return data
}
