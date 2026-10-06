import { supabase } from '../lib/supabase'

export type ClientErrorReport={
 message:string
 componentStack?:string|null
 pagePath?:string|null
 appVersion?:string|null
}

export async function reportClientError(report:ClientErrorReport){
 try{
  const {data,error}=await supabase.rpc('report_client_error_v1',{
   p_message:report.message,
   p_component_stack:report.componentStack??null,
   p_page_path:report.pagePath??`${window.location.pathname}${window.location.search}`,
   p_app_version:report.appVersion??null,
  })
  if(error)throw error
  return data as string|null
 }catch{
  return null
 }
}
