import { supabase } from '../lib/supabase'

export type FeedbackStatus='new'|'reviewed'|'resolved'
export type FeedbackItem={id:string;kind:'bug'|'content'|'suggestion';message:string;page_path:string|null;status:FeedbackStatus;created_at:string;user:{first_name:string|null;username:string|null;avatar_url:string|null}}
export type QualitySummary={years:Array<{study_year:number;published_questions:number;unpublished_questions:number;visual_pending:number}>;quality:{published_total:number;published_without_source:number;published_incomplete_source:number;quarantined_quality:number;visual_quarantined:number};feedback:{new_feedback:number;reviewed_feedback:number;resolved_feedback:number};documents:{total:number;validated:number}}

async function rpc<T>(name:string,params?:Record<string,unknown>){const{data,error}=await supabase.rpc(name,params);if(error)throw error;return data as T}
export const getContentQualitySummary=()=>rpc<QualitySummary>('get_content_quality_summary_v1')
export const getFeedbackQueue=(status:FeedbackStatus|null=null,limit=100)=>rpc<FeedbackItem[]>('get_feedback_queue_v1',{p_status:status,p_limit:limit})
export const setFeedbackStatus=(id:string,status:FeedbackStatus)=>rpc<boolean>('set_feedback_status_v1',{p_feedback_id:id,p_status:status})
