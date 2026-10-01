import { supabase } from '../lib/supabase'

export type CurriculumLesson = {
  id: string
  title: string
  slug: string
  summary: string | null
  image_url: string | null
  published_questions: number
  attempted_questions: number
  mastery_percent: number
  coverage_percent: number
}

export type CurriculumChapter = {
  id: string
  name: string
  slug: string
  description: string | null
  lesson_count: number
  published_questions: number
  lessons: CurriculumLesson[]
}

export type CurriculumSubject = {
  id: string
  name: string
  slug: string
  description: string | null
  icon: string | null
  chapter_count: number
  chapters: CurriculumChapter[]
}

export type CurriculumYear = {
  id: string
  number: number
  name: string
  description: string | null
  subjects: CurriculumSubject[]
}

export type LessonSourceDocument={
  title:string
  validation_status:string|null
  page_start:number|null
  page_end:number|null
}

export type LessonExternalSource={
  title?:string
  url?:string
  label?:string
}

export type LessonV2 = {
  id: string
  title: string
  slug: string
  summary: string | null
  content: string | null
  key_points: unknown[]
  sources: Array<string|LessonExternalSource>
  source_documents: LessonSourceDocument[]
  validation_status:string|null
  source_document:string|null
  image_url: string | null
  chapter: { id: string; name: string; slug: string }
  subject: { id: string; name: string; slug: string; icon: string | null }
  year: { number: number; name: string }
  question_count: number
  mastery_percent: number
}

export async function getCurriculumV2() {
  const { data, error } = await supabase.rpc('get_curriculum_v2')
  if (error) throw error
  return (data ?? []) as CurriculumYear[]
}

export async function getLessonV2(lessonId: string) {
  const { data, error } = await supabase.rpc('get_lesson_v2', { p_lesson_id: lessonId })
  if (error) throw error
  return data as LessonV2
}

export async function startLessonQuizV2(lessonId: string, questionCount = 10) {
  const { data, error } = await supabase.rpc('start_lesson_quiz_v2', {
    p_lesson_id: lessonId,
    p_question_count: questionCount,
  })
  if (error) throw error
  return data as string
}
