import { supabase } from '../lib/supabase'

export type ClientErrorReport={
 message:string
 componentStack?:string|null
 pagePath?:string|null
 appVersion?:string|null
}

let appVersionPromise:Promise<string|null>|null=null
function getAppVersion(){
 if(!appVersionPromise){
  appVersionPromise=fetch('/version.json',{cache:'no-store'})
   .then(async response=>{
    if(!response.ok)return null
    const data=await response.json() as {version?:unknown;commit?:unknown}
    if(typeof data.version==='string')return data.version
    if(typeof data.commit==='string')return data.commit
    return null
   })
   .catch(()=>null)
 }
 return appVersionPromise
}

export async function reportClientError(report:ClientErrorReport){
 try{
  const version=report.appVersion===undefined?await getAppVersion():report.appVersion
  const connectivity=typeof navigator!=='undefined'&&navigator.onLine===false?'offline':'online'
  const {data,error}=await supabase.rpc('report_client_error_v1',{
   p_message:`[${connectivity}] ${report.message}`,
   p_component_stack:report.componentStack??null,
   p_page_path:report.pagePath??`${window.location.pathname}${window.location.search}`,
   p_app_version:version??null,
  })
  if(error)throw error
  return data as string|null
 }catch{
  return null
 }
}
