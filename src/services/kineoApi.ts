import { supabase } from '../lib/supabase'

export type DashboardV2={profile?:{xp?:number;level?:number};level?:{current?:number;next?:number;xp_to_next?:number;progress_percent?:number};streak?:{current?:number;best?:number};mastery?:{overall_percent?:number;mastered?:number;fragile?:number;due?:number};activity?:{completed_sessions?:number;last_session?:unknown};badges?:{earned?:number;total?:number};daily?:{ready?:boolean;question_count?:number;completed?:boolean;status?:string};[key:string]:unknown}
export type RevisionModeAvailability={total_questions:number;visual_questions:number;weak_questions:number;can_visual:boolean;can_weak:boolean;can_exam:boolean}
export type ActiveRevisionSession={id:string;mode:string;question_count:number;answered_count:number;started_at:string}
export type RevisionSessionMeta={id:string;mode:string;question_count:number;correct_count:number;xp_earned:number;started_at:string;completed_at:string|null;elapsed_seconds:number}
export type RevisionHistoryItem=RevisionSessionMeta&{score_percent:number;duration_seconds:number}
export type SessionReviewItem={display_order:number;question_id:string;question_type:string;question_text:string;explanation:string|null;image_url:string|null;subject_name:string;is_correct:boolean;user_answer_display:string|null;correct_answer_display:string|null;response_time_ms:number|null;source_title:string|null;source_page:number|null}
export type QuizOptionV3={id:string;option_text:string;display_order:number}
export type QuizQuestionV3={id:string;type:string;question_text:string;difficulty:number;image_url:string|null;metadata:Record<string,unknown>;question_options:QuizOptionV3[];display_order:number}
export type UserStatsV2={period_days:number;study_year?:number;summary:{attempts:number;correct_answers:number;incorrect_answers:number;accuracy_percent:number;avg_response_ms:number;completed_sessions:number;xp_total:number;level:number;attempted_questions:number;mastered_questions:number;fragile_questions:number;reviews_due:number;mastery_percent:number};daily_activity:Array<{date:string;attempts:number;correct:number;accuracy_percent:number;xp:number}>;subjects:Array<{id:string;name:string;year_number:number;published_questions:number;attempted_questions:number;coverage_percent:number;attempts:number;accuracy_percent:number;mastery_percent:number;mastered_questions:number;fragile_questions:number}>;modes:Array<{mode:string;sessions:number;questions:number;correct:number;accuracy_percent:number;xp:number}>;weak_questions:Array<{question_id:string;question_text:string;subject_name:string;accuracy_percent:number;mastery_percent:number}>}
export type StudyPriorityItem={subject_id:string;name:string;icon:string|null;published_questions:number;attempted_questions:number;coverage_percent:number;mastery_percent:number;fragile_questions:number;due_questions:number;reason:string}
export type StudyPrioritiesV1={study_year:number|null;items:StudyPriorityItem[]}
export type DailyChallengeStart={challenge_id:string;challenge_date:string;session_id:string;question_count:number;answered_count:number;remaining_count:number;completed:boolean;score:number|null;xp_earned:number|null;status:'ready'|'in_progress'|'completed'}
export type GamificationSummaryV2={xp_total:number;level:{number:number;name:string;icon:string;required_xp:number;next_level:number|null;next_name:string|null;next_icon:string|null;next_required_xp:number|null;xp_to_next:number;progress_percent:number};streak:{current:number;longest:number};badges:{earned:number;total:number}}
export type BadgeProgressV2={id:string;name:string;description:string;icon:string;condition_type:string;earned:boolean;earned_at:string|null;current_value:number;target_value:number;progress_percent:number}
export type BadgesV2={badges:BadgeProgressV2[];stats:{completed_quizzes:number;correct_answers:number;current_streak:number;daily_challenges:number;daily_perfect:boolean}}

async function rpc<T>(name:string,params?:Record<string,unknown>){const {data,error}=await supabase.rpc(name,params);if(error)throw error;return data as T}
export const getDashboardV2=()=>rpc<DashboardV2>('get_user_dashboard_v3')
export const getRevisionModeAvailabilityV1=()=>rpc<RevisionModeAvailability>('get_revision_mode_availability_v1')
export const getStudyPrioritiesV1=()=>rpc<StudyPrioritiesV1>('get_study_priorities_v1')
export const getActiveRevisionSessionV1=()=>rpc<ActiveRevisionSession|null>('get_active_revision_session_v1')
export const abandonRevisionSessionV1=(sessionId:string)=>rpc<boolean>('abandon_revision_session_v1',{p_session_id:sessionId})
export const getRevisionSessionMetaV1=(sessionId:string)=>rpc<RevisionSessionMeta>('get_revision_session_meta_v1',{p_session_id:sessionId})
export const getRecentRevisionSessionsV1=async(limit=20)=>(await rpc<RevisionHistoryItem[]>('get_recent_revision_sessions_v1',{p_limit:limit}))??[]
export const getRevisionSessionReviewV2=async(sessionId:string)=>(await rpc<SessionReviewItem[]>('get_revision_session_review_v2',{p_session_id:sessionId}))??[]
export const startMistakeRetryV1=(sessionId:string)=>rpc<string>('start_mistake_retry_v1',{p_source_session_id:sessionId})
export const getUserStatsV2=(days=30)=>rpc<UserStatsV2>('get_user_stats_v3',{p_days:days})
export const getGamificationSummaryV2=()=>rpc<GamificationSummaryV2>('get_gamification_summary_v2')
export const getBadgesV2=()=>rpc<BadgesV2>('get_badges_v2')
export const startSmartRevisionV2=(questionCount=10)=>rpc<string>('start_smart_revision_v2',{p_question_count:questionCount})
export const startSubjectRevisionV1=(subjectId:string,questionCount=10)=>rpc<string>('start_subject_revision_v1',{p_subject_id:subjectId,p_question_count:questionCount})
export const startVisualRevisionV1=(questionCount=10)=>rpc<string>('start_visual_revision_v1',{p_question_count:questionCount})
export const startWeakRevisionV1=(questionCount=10)=>rpc<string>('start_weak_revision_v1',{p_question_count:questionCount})
export const startMockExamV1=(questionCount=20)=>rpc<string>('start_mock_exam_v1',{p_question_count:questionCount})
export const startDailyChallengeV2=()=>rpc<DailyChallengeStart>('start_daily_challenge_v2')
export const getQuizQuestionsV4=async(sessionId:string)=>(await rpc<QuizQuestionV3[]>('get_quiz_questions_v4',{p_session_id:sessionId}))??[]
export const submitQuizAnswerV3=(params:{sessionId:string;questionId:string;answer:unknown;responseTimeMs:number})=>rpc('submit_quiz_answer_v4',{p_session_id:params.sessionId,p_question_id:params.questionId,p_answer:params.answer,p_response_time_ms:params.responseTimeMs})
export const finishQuizSessionV2=(sessionId:string)=>rpc('finish_quiz_session_v2',{p_session_id:sessionId})
export const finishDailyChallengeV2=(sessionId:string)=>rpc('finish_daily_challenge_v2',{p_session_id:sessionId})
