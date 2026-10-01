import { supabase } from '../lib/supabase'

export type FeedbackKind='bug'|'content'|'suggestion'

export async function submitFeedback(kind:FeedbackKind,message:string,pagePath:string){
 const {data,error}=await supabase.rpc('submit_feedback_v1',{p_kind:kind,p_message:message,p_page_path:pagePath})
 if(error)throw error
 return data as string
}
