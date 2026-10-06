import { supabase } from '../lib/supabase'
import type { ProgramId } from '../curriculum/programs'
import { getAccessiblePrograms } from './programApi'
import type { CurriculumAnswerPayload,CurriculumAnswerResult,CurriculumQuestionType,CurriculumQuizOption } from './programCatalogApi'

export type FoundationMode='foundation'|'mix'
export type FoundationQuestion={
 id:string
 topic_id:string
 question_text:string
 explanation:string|null
 options:CurriculumQuizOption[]
 question_type:CurriculumQuestionType
 accepted_answers:unknown
 level_code:string
 level_order:number
}

type LevelRow={id:string;code:string;display_order:number}
type UnitRow={id:string;academic_level_id:string}
type TopicRow={id:string;unit_id:string}

type RawQuestion=Omit<FoundationQuestion,'level_code'|'level_order'>

function shuffle<T>(items:T[]){
 const copy=[...items]
 for(let i=copy.length-1;i>0;i--){const j=Math.floor(Math.random()*(i+1));[copy[i],copy[j]]=[copy[j],copy[i]]}
 return copy
}

function sampleByMode(pool:FoundationQuestion[],activeOrder:number,mode:FoundationMode,count:number){
 const current=shuffle(pool.filter(q=>q.level_order===activeOrder))
 const previous=shuffle(pool.filter(q=>q.level_order<activeOrder)).sort((a,b)=>b.level_order-a.level_order)
 if(mode==='foundation'&&previous.length){
  const priorCount=Math.min(Math.ceil(count*.7),previous.length)
  return shuffle([...previous.slice(0,priorCount),...current.slice(0,count-priorCount)]).slice(0,count)
 }
 if(previous.length){
  const currentCount=Math.min(Math.ceil(count*.6),current.length)
  return shuffle([...current.slice(0,currentCount),...previous.slice(0,count-currentCount)]).slice(0,count)
 }
 return current.slice(0,count)
}

export async function getFoundationQuestions(programId:ProgramId,mode:FoundationMode,count=10):Promise<FoundationQuestion[]>{
 const accesses=await getAccessiblePrograms()
 const access=accesses.find(item=>item.program_id===programId)
 if(!access?.academic_level_id) throw new Error('Niveau étudiant non défini.')

 const {data:active,error:activeError}=await supabase.from('academic_levels').select('id,code,display_order').eq('id',access.academic_level_id).single()
 if(activeError) throw activeError
 const activeLevel=active as LevelRow

 const {data:levels,error:levelError}=await supabase.from('academic_levels').select('id,code,display_order').eq('program_id',programId).lte('display_order',activeLevel.display_order).order('display_order')
 if(levelError) throw levelError
 const allowed=(levels??[]) as LevelRow[]
 const levelById=new Map(allowed.map(level=>[level.id,level]))
 if(!allowed.length)return []

 let unitQuery=supabase.from('curriculum_units').select('id,academic_level_id').eq('program_id',programId).eq('is_active',true).in('academic_level_id',allowed.map(level=>level.id))
 unitQuery=unitQuery.eq('curriculum_version',access.curriculum_version)
 const {data:units,error:unitError}=await unitQuery
 if(unitError) throw unitError
 const unitRows=(units??[]) as UnitRow[]
 if(!unitRows.length)return []
 const levelByUnit=new Map(unitRows.map(unit=>[unit.id,levelById.get(unit.academic_level_id)!]))

 const {data:topics,error:topicError}=await supabase.from('curriculum_topics').select('id,unit_id').eq('is_active',true).in('unit_id',unitRows.map(unit=>unit.id))
 if(topicError) throw topicError
 const topicRows=(topics??[]) as TopicRow[]
 if(!topicRows.length)return []
 const levelByTopic=new Map(topicRows.map(topic=>[topic.id,levelByUnit.get(topic.unit_id)!]))

 const {data:questions,error:questionError}=await supabase.from('curriculum_quiz_questions').select('id,topic_id,question_text,explanation,options,question_type,accepted_answers').eq('is_published',true).eq('validation_status','source_validated').in('topic_id',topicRows.map(topic=>topic.id)).in('question_type',['mcq','clinical_case','fill_blank'])
 if(questionError) throw questionError
 const pool=((questions??[]) as RawQuestion[]).map(question=>{
  const level=levelByTopic.get(question.topic_id)
  return {...question,level_code:level?.code??'?',level_order:level?.display_order??activeLevel.display_order}
 })
 return sampleByMode(pool,activeLevel.display_order,mode,count)
}

export async function submitFoundationAnswer(questionId:string,payload:CurriculumAnswerPayload):Promise<CurriculumAnswerResult>{
 const {data,error}=await supabase.rpc('submit_curriculum_topic_answer_v2',{p_question_id:questionId,p_answer:payload})
 if(error) throw error
 return data as CurriculumAnswerResult
}
