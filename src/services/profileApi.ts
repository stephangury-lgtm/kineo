import { supabase } from '../lib/supabase'

export type StudentProfile = {
  id: string
  first_name: string | null
  username: string | null
  study_year: number | null
}

export async function getCurrentProfile() {
  const { data: userData, error: userError } = await supabase.auth.getUser()
  if (userError) throw userError
  const user = userData.user
  if (!user) return null

  const { data, error } = await supabase
    .from('profiles')
    .select('id, first_name, username, study_year')
    .eq('id', user.id)
    .maybeSingle()

  if (error) throw error
  return data as StudentProfile | null
}

export async function updateStudyProfile(params: { firstName?: string; username?: string; studyYear: number }) {
  const { data: userData, error: userError } = await supabase.auth.getUser()
  if (userError) throw userError
  const user = userData.user
  if (!user) throw new Error('Utilisateur non authentifié')

  const username = params.username?.trim()
  if (username && !/^[a-zA-Z0-9._-]{3,24}$/.test(username)) {
    throw new Error('Le pseudo doit contenir 3 à 24 caractères : lettres, chiffres, point, tiret ou underscore.')
  }

  const payload: { study_year: number; first_name?: string; username?: string | null } = {
    study_year: params.studyYear,
    username: username || null,
  }
  const firstName = params.firstName?.trim()
  if (firstName) payload.first_name = firstName

  const { data, error } = await supabase
    .from('profiles')
    .update(payload)
    .eq('id', user.id)
    .select('id, first_name, username, study_year')
    .single()

  if (error) {
    if (error.code === '23505') throw new Error('Ce pseudo est déjà utilisé.')
    throw error
  }
  return data as StudentProfile
}
