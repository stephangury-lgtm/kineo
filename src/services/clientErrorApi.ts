import { supabase } from '../lib/supabase'

export type ClientErrorReport={
 message:string
 componentStack?:string|null
 pagePath?:string|null
 appVersion?:string|null
}


/** Minimal Sentry envelope transport. No SDK, cookies, user identifiers or answer payloads. */
const SENTRY_INGEST='https://o4512227188932608.ingest.de.sentry.io/api/4512227195289680/envelope/'
const SENTRY_PUBLIC_KEY='3b0b0fd98c21d1607f1c64156ad72a40'
function sendToSentry(report:ClientErrorReport){
 try{
  const eventId=crypto.randomUUID().replace(/-/g,'')
  const timestamp=new Date().toISOString()
  // Never transmit arbitrary error messages, stacks, query strings or student input.
  const category=report.message.startsWith('Window error:')?'window_error':
   report.message.startsWith('Promise rejection:')?'promise_rejection':'react_boundary'
  const payload={
   event_id:eventId,timestamp,platform:'javascript',level:'error',
   logger:'kineo.client',message:`Kineo client failure: ${category}`,
   tags:{source:'kineo',category},
   request:{url:location.origin+location.pathname},
  }
  const envelope=JSON.stringify({event_id:eventId,sent_at:timestamp,dsn:`https://${SENTRY_PUBLIC_KEY}@o4512227188932608.ingest.de.sentry.io/4512227195289680`})+'\\n'+
   JSON.stringify({type:'event'})+'\\n'+JSON.stringify(payload)
  void fetch(SENTRY_INGEST,{
   method:'POST',headers:{'Content-Type':'application/x-sentry-envelope'},
   body:envelope,keepalive:true,credentials:'omit',referrerPolicy:'no-referrer',
  }).catch(()=>undefined)
 }catch{ /* Telemetry must never interrupt student workflows. */ }
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
 sendToSentry(report)
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
