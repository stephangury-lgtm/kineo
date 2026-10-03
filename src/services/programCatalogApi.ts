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

export async function getProgramUnits(programId:ProgramId,levelId?:string){
 let query=supabase.from('curriculum_units').select('*').eq('program_id',programId).order('display_order',{ascending:true})
 if(levelId) query=query.eq('academic_level_id',levelId)
 const {data,error}=await query
 if(error) throw error
 return (data??[]) as ProgramCatalogUnit[]
}

export async function getUnitTopics(unitId:string){
 const {data,error}=await supabase.from('curriculum_topics').select('*').eq('unit_id',unitId).order('display_order',{ascending:true})
 if(error) throw error
 return (data??[]) as ProgramCatalogTopic[]
}

export async function getAcademicLevelId(programId:ProgramId,code:string){
 const {data,error}=await supabase.from('academic_levels').select('id').eq('program_id',programId).eq('code',code).single()
 if(error) throw error
 return data.id as string
}
