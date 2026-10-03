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

export async function getProgramCatalog(){
 const {data,error}=await supabase
  .from('programs')
  .select('id,name,short_name,country_code,primary_language,secondary_language,level_kind,status,academic_levels(id,code,label,level_number,display_order,language,secondary_language)')
  .eq('is_active',true)
  .order('name')
 if(error) throw error
 return ((data??[]) as ProgramCatalogRow[]).map(program=>({...program,academic_levels:[...(program.academic_levels??[])].sort((a,b)=>a.display_order-b.display_order)}))
}

export async function savePrimaryProgram(programId:ProgramId){
 const {data:{user},error:userError}=await supabase.auth.getUser()
 if(userError) throw userError
 if(!user) return
 const {error:resetError}=await supabase.from('profile_programs').update({is_primary:false,updated_at:new Date().toISOString()}).eq('user_id',user.id).eq('is_primary',true)
 if(resetError) throw resetError
 const {error}=await supabase.from('profile_programs').upsert({user_id:user.id,program_id:programId,is_primary:true,updated_at:new Date().toISOString()},{onConflict:'user_id,program_id'})
 if(error) throw error
}

export async function saveProgramLevel(programId:ProgramId,levelCode:string){
 const {data:{user},error:userError}=await supabase.auth.getUser()
 if(userError) throw userError
 if(!user) return
 const {data:level,error:levelError}=await supabase.from('academic_levels').select('id').eq('program_id',programId).eq('code',levelCode).single()
 if(levelError) throw levelError
 const {error}=await supabase.from('profile_programs').upsert({user_id:user.id,program_id:programId,academic_level_id:level.id,updated_at:new Date().toISOString()},{onConflict:'user_id,program_id'})
 if(error) throw error
}
