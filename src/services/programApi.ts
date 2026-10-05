import { supabase } from '../lib/supabase'
import type { ProgramId } from '../curriculum/programs'

export type CurriculumVersion='default'|'2009'|'2026'

export type ProgramCatalogRow={
 id:string
 name:string
 short_name:string
 country_code:string
 primary_language:string
 secondary_language:string|null
 level_kind:'year'|'semester'
 status:'live'|'foundation'
 academic_levels:Array<{
  id:string
  code:string
  label:string
  level_number:number
  display_order:number
  language:string
  secondary_language:string|null
 }>
}

export type PrimaryProgram={program_id:ProgramId;academic_level_id:string|null;level_code:string|null;curriculum_version:CurriculumVersion}
export type AccessibleProgram=PrimaryProgram&{is_primary:boolean}

export async function getProgramCatalog(){
 const {data,error}=await supabase
  .from('programs')
  .select('id,name,short_name,country_code,primary_language,secondary_language,level_kind,status,academic_levels(id,code,label,level_number,display_order,language,secondary_language)')
  .eq('is_active',true)
  .order('name')
 if(error) throw error
 return ((data??[]) as ProgramCatalogRow[]).map(program=>({...program,academic_levels:[...(program.academic_levels??[])].sort((a,b)=>a.display_order-b.display_order)}))
}

export async function getAccessiblePrograms():Promise<AccessibleProgram[]>{
 const {data:{user},error:userError}=await supabase.auth.getUser()
 if(userError) throw userError
 if(!user) return []
 const {data,error}=await supabase
  .from('profile_programs')
  .select('program_id,academic_level_id,is_primary,curriculum_version,academic_levels(code)')
  .eq('user_id',user.id)
  .order('is_primary',{ascending:false})
 if(error) throw error
 return (data??[]).map(row=>{
  const relation=row.academic_levels as {code?:string}|null
  return {
   program_id:row.program_id as ProgramId,
   academic_level_id:row.academic_level_id,
   level_code:relation?.code??null,
   curriculum_version:(row.curriculum_version??'default') as CurriculumVersion,
   is_primary:Boolean(row.is_primary)
  }
 })
}

export async function getPrimaryProgram():Promise<PrimaryProgram|null>{
 const programs=await getAccessiblePrograms()
 const primary=programs.find(program=>program.is_primary)
 if(!primary) return null
 return {program_id:primary.program_id,academic_level_id:primary.academic_level_id,level_code:primary.level_code,curriculum_version:primary.curriculum_version}
}

export async function savePrimaryProgram(programId:ProgramId,levelCode?:string){
 const {data:{user},error:userError}=await supabase.auth.getUser()
 if(userError) throw userError
 if(!user) return
 const existing=await getPrimaryProgram()
 if(existing&&existing.program_id!==programId) throw new Error('Ton cursus est déjà défini et ne peut pas être changé depuis ton compte étudiant.')
 if(existing) return
 let academicLevelId:string|null=null
 if(levelCode){
  const {data:level,error:levelError}=await supabase.from('academic_levels').select('id').eq('program_id',programId).eq('code',levelCode).single()
  if(levelError) throw levelError
  academicLevelId=level.id
 }
 const curriculumVersion:CurriculumVersion=programId==='ifsi-fr'?'2009':'default'
 const {error}=await supabase.from('profile_programs').insert({user_id:user.id,program_id:programId,academic_level_id:academicLevelId,is_primary:true,curriculum_version:curriculumVersion,updated_at:new Date().toISOString()})
 if(error) throw error
}

export async function saveProgramLevel(programId:ProgramId,levelCode:string){
 const {data:{user},error:userError}=await supabase.auth.getUser()
 if(userError) throw userError
 if(!user) return
 const {data:level,error:levelError}=await supabase.from('academic_levels').select('id').eq('program_id',programId).eq('code',levelCode).single()
 if(levelError) throw levelError
 const {error}=await supabase.from('profile_programs').update({academic_level_id:level.id,updated_at:new Date().toISOString()}).eq('user_id',user.id).eq('program_id',programId)
 if(error) throw error
}

export async function saveProgramCurriculumVersion(programId:ProgramId,version:CurriculumVersion){
 const {data:{user},error:userError}=await supabase.auth.getUser()
 if(userError) throw userError
 if(!user) return
 if(programId!=='ifsi-fr'&&version!=='default') throw new Error('Ce référentiel est réservé au cursus IFSI France.')
 const {error}=await supabase.from('profile_programs').update({curriculum_version:version,updated_at:new Date().toISOString()}).eq('user_id',user.id).eq('program_id',programId)
 if(error) throw error
}
