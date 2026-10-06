import { supabase } from '../lib/supabase'

export type FeedbackStatus='new'|'reviewed'|'resolved'
export type FeedbackItem={id:string;kind:'bug'|'content'|'suggestion';message:string;page_path:string|null;status:FeedbackStatus;created_at:string;user:{first_name:string|null;username:string|null;avatar_url:string|null}}
export type ClientErrorItem={id:string;message:string;component_stack:string|null;page_path:string|null;app_version:string|null;created_at:string;user:{first_name:string|null;username:string|null}}
export type QualitySummary={years:Array<{study_year:number;published_questions:number;unpublished_questions:number;visual_pending:number}>;quality:{published_total:number;published_without_source:number;published_incomplete_source:number;quarantined_quality:number;visual_quarantined:number};feedback:{new_feedback:number;reviewed_feedback:number;resolved_feedback:number};documents:{total:number;validated:number}}
export type VisualPoint={x:number;y:number;label?:string;radius?:number;key?:string}
export type VisualReview={anatomy_ok?:boolean;mobile_ok?:boolean;target_ok?:boolean;source_ok?:boolean;reviewed_at?:string;reviewed_by?:string}
export type ReviewQuestion={id:string;type:string;question_text:string;difficulty:number;validation_status:'archived'|'review'|'validated';is_published:boolean;year_number:number;subject_name:string;chapter_name:string;lesson_title:string;source_title:string|null;source_page:number|null;source_excerpt:string|null;quality_issue:string|null;visual_approved:boolean;visual_review?:VisualReview;visual_rebuild_batch?:string|null;image_url:string|null;hotspot:VisualPoint|null;label_targets:VisualPoint[]|null;option_count:number;correct_option_count:number}
export type ReviewQueue={can_publish?:boolean;counts:{review:number;validated:number;published:number;archived?:number;quarantined_visual:number;quality_issues:number};questions:ReviewQuestion[]}

async function rpc<T>(name:string,params?:Record<string,unknown>){const{data,error}=await supabase.rpc(name,params);if(error)throw error;return data as T}
export const getContentQualitySummary=()=>rpc<QualitySummary>('get_content_quality_summary_v1')
export const getFeedbackQueue=(status:FeedbackStatus|null=null,limit=100)=>rpc<FeedbackItem[]>('get_feedback_queue_v1',{p_status:status,p_limit:limit})
export const setFeedbackStatus=(id:string,status:FeedbackStatus)=>rpc<boolean>('set_feedback_status_v1',{p_feedback_id:id,p_status:status})
export const getClientErrorLogs=(limit=100)=>rpc<ClientErrorItem[]>('get_client_error_logs_v1',{p_limit:limit})
export const getContentReviewQueue=()=>rpc<ReviewQueue>('get_content_review_queue_v4')
export const canReviewVisuals=()=>rpc<boolean>('can_review_visuals_v1')
export const getVisualReviewQueue=()=>rpc<ReviewQueue>('get_visual_review_queue_v1')
export const setContentReviewStatus=(id:string,status:'draft'|'review'|'validated'|'published')=>rpc('set_content_review_status_v1',{p_kind:'question',p_id:id,p_status:status})
export const setVisualApproval=(id:string,approved:boolean)=>rpc<{question_id:string;visual_approved:boolean}>('set_visual_approval_v1',{p_question_id:id,p_approved:approved})
export const setVisualReview=(id:string,review:Required<Pick<VisualReview,'anatomy_ok'|'mobile_ok'|'target_ok'|'source_ok'>>)=>rpc<{question_id:string;visual_approved:boolean;visual_review:VisualReview}>('set_visual_review_v2',{p_question_id:id,p_anatomy_ok:review.anatomy_ok,p_mobile_ok:review.mobile_ok,p_target_ok:review.target_ok,p_source_ok:review.source_ok})
export const setVisualTarget=(id:string,x:number,y:number,targetIndex:number|null=null,radius:number|null=null)=>rpc<{question_id:string;hotspot:VisualPoint|null;label_targets:VisualPoint[]|null;visual_approved:boolean}>('set_visual_target_v1',{p_question_id:id,p_x:x,p_y:y,p_target_index:targetIndex,p_radius:radius})
