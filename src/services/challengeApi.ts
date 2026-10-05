import { supabase } from '../lib/supabase'

export type FriendChallenge={id:string;program_id?:string;academic_level_id?:string|null;level_code?:string|null;status:'pending'|'accepted'|'in_progress'|'completed'|'declined'|'cancelled';direction:'sent'|'received';challenger_id:string;challenged_id:string;challenger_score:number|null;challenged_score:number|null;created_at:string;completed_at:string|null;my_session_id:string|null;has_played:boolean;opponent_has_played:boolean;opponent:{id:string;username:string|null;first_name:string|null;study_year:number|null;level:number|null;avatar_url:string|null}}
export type FriendChallengeFinish={completed:boolean;my_score:number|null;opponent_score:number|null;challenger_score:number|null;challenged_score:number|null}
export type CurriculumChallengeQuestion={id:string;question_text:string;options:{text:string}[];display_order:number}
export type CurriculumChallengeAnswerResult={correct:boolean;correct_answer:string|null;answered:number;completed_my_run:boolean;score:number|null;challenge_completed:boolean;new_badges?:unknown[]}
export type CurriculumChallengeAvailability={program_id:string;academic_level_id:string|null;level_code:string|null;validated_mcq:number;required_mcq:number;can_challenge:boolean}

export async function getFriendChallenges(){const{data,error}=await supabase.rpc('get_friend_challenges_v2');if(error)throw error;return(data??[])as FriendChallenge[]}
export async function createFriendChallenge(friendId:string){const{data,error}=await supabase.rpc('create_friend_challenge_v1',{p_friend_id:friendId});if(error)throw error;return data as string}
export async function respondFriendChallenge(challengeId:string,accept:boolean){const{data,error}=await supabase.rpc('respond_friend_challenge_v1',{p_challenge_id:challengeId,p_accept:accept});if(error)throw error;return data as string}
export async function cancelFriendChallenge(challengeId:string){const{data,error}=await supabase.rpc('cancel_friend_challenge_v1',{p_challenge_id:challengeId});if(error)throw error;return Boolean(data)}
export async function startFriendChallengeSession(challengeId:string){const{data,error}=await supabase.rpc('start_friend_challenge_session_v1',{p_challenge_id:challengeId});if(error)throw error;return data as string}
export async function finishFriendChallenge(challengeId:string,score:number){const{data,error}=await supabase.rpc('finish_friend_challenge_v1',{p_challenge_id:challengeId,p_score:score});if(error)throw error;return data as FriendChallengeFinish}

export async function getCurriculumFriendChallenges(programId:string){const{data,error}=await supabase.rpc('get_curriculum_friend_challenges_v1',{p_program_id:programId});if(error)throw error;return(data??[])as FriendChallenge[]}
export async function getCurriculumChallengeAvailability(programId:string){const{data,error}=await supabase.rpc('get_curriculum_challenge_availability_v1',{p_program_id:programId});if(error)throw error;return data as CurriculumChallengeAvailability}
export async function createCurriculumFriendChallenge(friendId:string,programId:string){const{data,error}=await supabase.rpc('create_curriculum_friend_challenge_v1',{p_friend_id:friendId,p_program_id:programId});if(error)throw error;return data as string}
export async function respondCurriculumFriendChallenge(challengeId:string,accept:boolean){const{data,error}=await supabase.rpc('respond_curriculum_friend_challenge_v1',{p_challenge_id:challengeId,p_accept:accept});if(error)throw error;return data as string}
export async function cancelCurriculumFriendChallenge(challengeId:string){const{data,error}=await supabase.rpc('cancel_curriculum_friend_challenge_v1',{p_challenge_id:challengeId});if(error)throw error;return Boolean(data)}
export async function getCurriculumFriendChallengeQuestions(challengeId:string){const{data,error}=await supabase.rpc('get_curriculum_friend_challenge_questions_v1',{p_challenge_id:challengeId});if(error)throw error;return(data??[])as CurriculumChallengeQuestion[]}
export async function submitCurriculumFriendChallengeAnswer(challengeId:string,questionId:string,answerText:string){const{data,error}=await supabase.rpc('submit_curriculum_friend_challenge_answer_v1',{p_challenge_id:challengeId,p_question_id:questionId,p_answer_text:answerText});if(error)throw error;return data as CurriculumChallengeAnswerResult}
