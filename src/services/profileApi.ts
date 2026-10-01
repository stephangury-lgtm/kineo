import { supabase } from '../lib/supabase'

export type StudentProfile = {
  id: string
  first_name: string | null
  username: string | null
  avatar_url: string | null
  study_year: number | null
}

export async function getCurrentProfile() {
  const { data: userData, error: userError } = await supabase.auth.getUser()
  if (userError) throw userError
  const user = userData.user
  if (!user) return null

  const { data, error } = await supabase
    .from('profiles')
    .select('id, first_name, username, avatar_url, study_year')
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
    .select('id, first_name, username, avatar_url, study_year')
    .single()

  if (error) {
    if (error.code === '23505') throw new Error('Ce pseudo est déjà utilisé.')
    throw error
  }
  return data as StudentProfile
}

export async function uploadProfilePhoto(file: File) {
  const allowed = ['image/jpeg', 'image/png', 'image/webp']
  if (!allowed.includes(file.type)) throw new Error('Choisis une image JPEG, PNG ou WebP.')
  if (file.size > 5 * 1024 * 1024) throw new Error('La photo doit faire moins de 5 Mo.')

  const { data: userData, error: userError } = await supabase.auth.getUser()
  if (userError) throw userError
  const user = userData.user
  if (!user) throw new Error('Utilisateur non authentifié')

  const extension = file.type === 'image/png' ? 'png' : file.type === 'image/webp' ? 'webp' : 'jpg'
  const path = `${user.id}/avatar-${Date.now()}.${extension}`
  const { error: uploadError } = await supabase.storage.from('avatars').upload(path, file, {
    cacheControl: '3600',
    contentType: file.type,
    upsert: false,
  })
  if (uploadError) throw uploadError

  const { data: publicData } = supabase.storage.from('avatars').getPublicUrl(path)
  const avatarUrl = publicData.publicUrl
  const { error: updateError } = await supabase.from('profiles').update({ avatar_url: avatarUrl, updated_at: new Date().toISOString() }).eq('id', user.id)
  if (updateError) throw updateError
  window.dispatchEvent(new Event('kineo-profile-updated'))
  return avatarUrl
}
