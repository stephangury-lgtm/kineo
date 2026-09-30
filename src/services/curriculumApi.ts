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

export async function getCurriculumV2() {
  const { data, error } = await supabase.rpc('get_curriculum_v2')
  if (error) throw error
  return (data ?? []) as CurriculumYear[]
}

export async function startLessonQuizV2(lessonId: string, questionCount = 10) {
  const { data, error } = await supabase.rpc('start_lesson_quiz_v2', {
    p_lesson_id: lessonId,
    p_question_count: questionCount,
  })
  if (error) throw error
  return data as string
}
