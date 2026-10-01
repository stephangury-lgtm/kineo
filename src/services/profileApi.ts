import { supabase } from '../lib/supabase'

export type StudentProfile = {
  id: string
  first_name: string | null
  study_year: number | null
  role: 'student' | 'admin'
}

export async function getCurrentProfile() {
  const { data: userData, error: userError } = await supabase.auth.getUser()
  if (userError) throw userError
  const user = userData.user
  if (!user) return null

  const { data, error } = await supabase
    .from('profiles')
    .select('id, first_name, study_year, role')
    .eq('id', user.id)
    .maybeSingle()

  if (error) throw error
  return data as StudentProfile | null
}

export async function updateStudyProfile(params: { firstName?: string; studyYear: number }) {
  const { data: userData, error: userError } = await supabase.auth.getUser()
  if (userError) throw userError
  const user = userData.user
  if (!user) throw new Error('Utilisateur non authentifié')

  const payload: { study_year: number; first_name?: string } = { study_year: params.studyYear }
  const firstName = params.firstName?.trim()
  if (firstName) payload.first_name = firstName

  const { data, error } = await supabase
    .from('profiles')
    .update(payload)
    .eq('id', user.id)
    .select('id, first_name, study_year, role')
    .single()

  if (error) throw error
  return data as StudentProfile
}
