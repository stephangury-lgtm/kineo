import { supabase } from '../lib/supabase'

export type DuelMessage = { id: string; body: string; is_mine: boolean; sender_name: string; created_at: string }
export type DuelConversationData = { messages: DuelMessage[]; can_send: boolean }
export async function readDuelMessages(challengeId: string, programId: string): Promise<DuelConversationData> {
 const {data,error}=await supabase.rpc('read_friend_challenge_messages_v1',{p_challenge_id:challengeId,p_program_id:programId})
 if(error)throw error
 return data as DuelConversationData
}
export async function sendDuelMessage(challengeId: string, programId: string, body: string, requestId: string) {
 const {data,error}=await supabase.rpc('send_friend_challenge_message_v1',{
  p_challenge_id:challengeId,p_program_id:programId,p_body:body,p_request_id:requestId,
 })
 if(error)throw error
 return data as string
}
