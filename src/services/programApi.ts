import { supabase } from '../lib/supabase'
import type { ProgramId } from '../curriculum/programs'

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

export type PrimaryProgram={program_id:ProgramId;academic_level_id:string|null;level_code:string|null}

export async function getProgramCatalog(){
 const {data,error}=await supabase
  .from('programs')
  .select('id,name,short_name,country_code,primary_language,secondary_language,level_kind,status,academic_levels(id,code,label,level_number,display_order,language,secondary_language)')
  .eq('is_active',true)
  .order('name')
 if(error) throw error
 return ((data??[]) as ProgramCatalogRow[]).map(program=>({...program,academic_levels:[...(program.academic_levels??[])].sort((a,b)=>a.display_order-b.display_order)}))
}

export async function getPrimaryProgram():Promise<PrimaryProgram|null>{
 const {data:{user},error:userError}=await supabase.auth.getUser()
 if(userError) throw userError
 if(!user) return null
 const {data,error}=await supabase
  .from('profile_programs')
  .select('program_id,academic_level_id,academic_levels(code)')
  .eq('user_id',user.id)
  .eq('is_primary',true)
  .maybeSingle()
 if(error) throw error
 if(!data) return null
 const relation=data.academic_levels as {code?:string}|null
 return {program_id:data.program_id as ProgramId,academic_level_id:data.academic_level_id,level_code:relation?.code??null}
}

export async function savePrimaryProgram(programId:ProgramId){
 const {data:{user},error:userError}=await supabase.auth.getUser()
 if(userError) throw userError
 if(!user) return
 const existing=await getPrimaryProgram()
 if(existing&&existing.program_id!==programId) throw new Error('Ton cursus est déjà défini et ne peut pas être changé depuis ton compte étudiant.')
 if(existing) return
 const {error}=await supabase.from('profile_programs').insert({user_id:user.id,program_id:programId,is_primary:true,updated_at:new Date().toISOString()})
 if(error) throw error
}

export async function saveProgramLevel(programId:ProgramId,levelCode:string){
 const {data:{user},error:userError}=await supabase.auth.getUser()
 if(userError) throw userError
 if(!user) return
 const primary=await getPrimaryProgram()
 if(primary&&primary.program_id!==programId) throw new Error('Ce niveau appartient à un autre cursus.')
 const {data:level,error:levelError}=await supabase.from('academic_levels').select('id').eq('program_id',programId).eq('code',levelCode).single()
 if(levelError) throw levelError
 const {error}=await supabase.from('profile_programs').update({academic_level_id:level.id,is_primary:true,updated_at:new Date().toISOString()}).eq('user_id',user.id).eq('program_id',programId)
 if(error) throw error
}
