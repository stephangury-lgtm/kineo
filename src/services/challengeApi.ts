import { supabase } from '../lib/supabase'

export type FriendChallenge = {
  id: string
  status: 'pending' | 'accepted' | 'in_progress' | 'completed' | 'declined' | 'cancelled'
  direction: 'sent' | 'received'
  challenger_id: string
  challenged_id: string
  challenger_score: number | null
  challenged_score: number | null
  created_at: string
  completed_at: string | null
  my_session_id: string | null
  has_played: boolean
  opponent_has_played: boolean
  opponent: {
    id: string
    username: string | null
    first_name: string | null
    study_year: number | null
    level: number | null
    avatar_url: string | null
  }
}

export async function getFriendChallenges() {
  const { data, error } = await supabase.rpc('get_friend_challenges_v2')
  if (error) throw error
  return (data ?? []) as FriendChallenge[]
}

export async function createFriendChallenge(friendId: string) {
  const { data, error } = await supabase.rpc('create_friend_challenge_v1', { p_friend_id: friendId })
  if (error) throw error
  return data as string
}

export async function respondFriendChallenge(challengeId: string, accept: boolean) {
  const { data, error } = await supabase.rpc('respond_friend_challenge_v1', { p_challenge_id: challengeId, p_accept: accept })
  if (error) throw error
  return data as string
}

export async function startFriendChallengeSession(challengeId: string) {
  const { data, error } = await supabase.rpc('start_friend_challenge_session_v1', { p_challenge_id: challengeId })
  if (error) throw error
  return data as string
}

export async function finishFriendChallenge(challengeId: string, score: number) {
  const { data, error } = await supabase.rpc('finish_friend_challenge_v1', { p_challenge_id: challengeId, p_score: score })
  if (error) throw error
  return data as { completed: boolean; challenger_score: number | null; challenged_score: number | null }
}
