import { supabase } from '../lib/supabase'
import type { ProgramId } from '../curriculum/programs'
import { getAccessiblePrograms,type CurriculumVersion } from './programApi'

export type ProgramCatalogUnit={id:string;program_id:ProgramId;academic_level_id:string;code:string|null;name:string;unit_type:'subject'|'ue'|'module';description:string|null;icon:string|null;display_order:number;content_language:string;translation_language:string|null;translation_mode:'none'|'vocabulary'|'bilingual';curriculum_version:CurriculumVersion}
export type ProgramCatalogTopic={id:string;unit_id:string;name:string;slug:string;description:string|null;display_order:number;content_language:string;translation_language:string|null;translation_mode:'none'|'vocabulary'|'bilingual'}
export type CurriculumLesson={id:string;topic_id:string;title:string;summary:string|null;content:string;key_points:unknown;source_files:unknown;display_order:number;validation_status:string;is_published:boolean}
export type CurriculumQuizOption={text:string;correct:boolean}
export type CurriculumQuestionType='mcq'|'fill_blank'|'visual_hotspot'|'clinical_case'|'matching'
export type CurriculumHotspot={id:string;label?:string;x:number;y:number;correct?:boolean}
export type CurriculumMatchPair={left:string;right:string}
export type CurriculumQuizQuestion={id:string;topic_id:string;question_text:string;explanation:string|null;options:CurriculumQuizOption[];difficulty:number;source_label:string|null;display_order:number;question_type:CurriculumQuestionType;accepted_answers:unknown;image_url:string|null;metadata:unknown}
export type CurriculumAnswerPayload={text?:string;hotspot_id?:string;pairs?:CurriculumMatchPair[]}
export type CurriculumAnswerResult={correct:boolean;correct_answer?:string|null;correct_hotspot_id?:string|null;correct_pairs?:CurriculumMatchPair[];xp_earned?:number;topic_completed?:boolean;xp_total?:number;current_streak?:number;new_badges?:unknown}

export async function getProgramUnits(programId:ProgramId,levelId?:string,curriculumVersion?:CurriculumVersion){let query=supabase.from('curriculum_units').select('*').eq('program_id',programId).eq('is_active',true).order('display_order',{ascending:true});if(levelId)query=query.eq('academic_level_id',levelId);if(curriculumVersion)query=query.eq('curriculum_version',curriculumVersion);const{data,error}=await query;if(error)throw error;return(data??[])as ProgramCatalogUnit[]}
export async function getUnitTopics(unitId:string){const{data,error}=await supabase.from('curriculum_topics').select('*').eq('unit_id',unitId).eq('is_active',true).order('display_order',{ascending:true});if(error)throw error;return(data??[])as ProgramCatalogTopic[]}

export async function getTopic(topicId:string,programId:ProgramId,curriculumVersion?:CurriculumVersion){
 let query=supabase.from('curriculum_topics').select('*, curriculum_units!inner(program_id,academic_level_id,curriculum_version)').eq('id',topicId).eq('is_active',true).eq('curriculum_units.program_id',programId)
 if(curriculumVersion)query=query.eq('curriculum_units.curriculum_version',curriculumVersion)
 const{data,error}=await query.single();if(error)throw error
 const row=data as ProgramCatalogTopic&{curriculum_units:{program_id:ProgramId;academic_level_id:string;curriculum_version:CurriculumVersion}}
 const accesses=await getAccessiblePrograms();const access=accesses.find(item=>item.program_id===programId)
 if(!access?.academic_level_id)throw new Error('Niveau étudiant non défini.')
 if(curriculumVersion&&access.curriculum_version!==curriculumVersion)throw new Error('Ce chapitre n’appartient pas au référentiel actif.')
 const{data:levels,error:levelError}=await supabase.from('academic_levels').select('id,display_order').in('id',[access.academic_level_id,row.curriculum_units.academic_level_id]);if(levelError)throw levelError
 const activeOrder=levels?.find(level=>level.id===access.academic_level_id)?.display_order
 const targetOrder=levels?.find(level=>level.id===row.curriculum_units.academic_level_id)?.display_order
 if(activeOrder==null||targetOrder==null||targetOrder>activeOrder)throw new Error('Ce chapitre appartient à un niveau qui n’est pas encore débloqué.')
 const{curriculum_units:_,...topic}=row;return topic as ProgramCatalogTopic
}

export async function getTopicLessons(topicId:string){const{data,error}=await supabase.from('curriculum_lessons').select('*').eq('topic_id',topicId).eq('is_published',true).order('display_order',{ascending:true});if(error)throw error;return(data??[])as CurriculumLesson[]}
export async function getTopicQuiz(topicId:string){const{data,error}=await supabase.from('curriculum_quiz_questions').select('*').eq('topic_id',topicId).eq('is_published',true).eq('validation_status','source_validated').order('display_order',{ascending:true});if(error)throw error;return(data??[])as CurriculumQuizQuestion[]}
export async function submitCurriculumTopicAnswer(questionId:string,answer:CurriculumAnswerPayload){const{data,error}=await supabase.rpc('submit_curriculum_topic_answer_v2',{p_question_id:questionId,p_answer:answer});if(error)throw error;return data as CurriculumAnswerResult}
export async function getAcademicLevelId(programId:ProgramId,code:string){const{data,error}=await supabase.from('academic_levels').select('id').eq('program_id',programId).eq('code',code).single();if(error)throw error;return data.id as string}
