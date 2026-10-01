import { supabase } from '../lib/supabase'

export type CourseLibraryLesson = {
  id: string
  title: string
  slug: string
}

export type CourseLibraryDocument = {
  id: string
  title: string
  file_name: string | null
  mime_type: string | null
  file_size: number | null
  document_type: string
  validation_status: string
  processing_status: string
  source_url: string | null
  year: { number: number; name: string } | null
  subject: { id: string; name: string; slug: string; icon: string | null } | null
  chapter: { id: string; name: string; slug: string } | null
  question_count: number
  lessons: CourseLibraryLesson[]
  created_at: string | null
  updated_at: string | null
}

export async function getCourseLibraryV1() {
  const { data, error } = await supabase.rpc('get_course_library_v1')
  if (error) throw error
  return (data ?? []) as CourseLibraryDocument[]
}
