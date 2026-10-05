import { supabase } from '../lib/supabase'
import type { ProgramId } from '../curriculum/programs'

export type ProgramCatalogUnit={
 id:string
 program_id:ProgramId
 academic_level_id:string
 code:string|null
 name:string
 unit_type:'subject'|'ue'|'module'
 description:string|null
 icon:string|null
 display_order:number
 content_language:string
 translation_language:string|null
 translation_mode:'none'|'vocabulary'|'bilingual'
}

export type ProgramCatalogTopic={
 id:string
 unit_id:string
 name:string
 slug:string
 description:string|null
 display_order:number
 content_language:string
 translation_language:string|null
 translation_mode:'none'|'vocabulary'|'bilingual'
}

export type CurriculumLesson={
 id:string
 topic_id:string
 title:string
 summary:string|null
 content:string
 key_points:unknown
 source_files:unknown
 display_order:number
 validation_status:string
 is_published:boolean
}

export type CurriculumQuizOption={text:string;correct:boolean}
export type CurriculumQuestionType='mcq'|'fill_blank'|'visual_hotspot'|'clinical_case'
export type CurriculumHotspot={id:string;label?:string;x:number;y:number;correct?:boolean}
export type CurriculumQuizQuestion={
 id:string
 topic_id:string
 question_text:string
 explanation:string|null
 options:CurriculumQuizOption[]
 difficulty:number
 source_label:string|null
 display_order:number
 question_type:CurriculumQuestionType
 accepted_answers:unknown
 image_url:string|null
 metadata:unknown
}

export async function getProgramUnits(programId:ProgramId,levelId?:string){
 let query=supabase.from('curriculum_units').select('*').eq('program_id',programId).eq('is_active',true).order('display_order',{ascending:true})
 if(levelId) query=query.eq('academic_level_id',levelId)
 const {data,error}=await query
 if(error) throw error
 return (data??[]) as ProgramCatalogUnit[]
}

export async function getUnitTopics(unitId:string){
 const {data,error}=await supabase.from('curriculum_topics').select('*').eq('unit_id',unitId).eq('is_active',true).order('display_order',{ascending:true})
 if(error) throw error
 return (data??[]) as ProgramCatalogTopic[]
}

export async function getTopic(topicId:string){
 const {data,error}=await supabase.from('curriculum_topics').select('*').eq('id',topicId).eq('is_active',true).single()
 if(error) throw error
 return data as ProgramCatalogTopic
}

export async function getTopicLessons(topicId:string){
 const {data,error}=await supabase.from('curriculum_lessons').select('*').eq('topic_id',topicId).eq('is_published',true).order('display_order',{ascending:true})
 if(error) throw error
 return (data??[]) as CurriculumLesson[]
}

export async function getTopicQuiz(topicId:string){
 const {data,error}=await supabase.from('curriculum_quiz_questions').select('*').eq('topic_id',topicId).eq('is_published',true).order('display_order',{ascending:true})
 if(error) throw error
 return (data??[]) as CurriculumQuizQuestion[]
}

export async function getAcademicLevelId(programId:ProgramId,code:string){
 const {data,error}=await supabase.from('academic_levels').select('id').eq('program_id',programId).eq('code',code).single()
 if(error) throw error
 return data.id as string
}
