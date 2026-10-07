const url=process.env.KINEO_SUPABASE_URL||'https://kimtiyuytikyseuzmjbv.supabase.co'
const key=process.env.KINEO_SUPABASE_PUBLISHABLE_KEY||'sb_publishable_ANuwDKjYwbR2LF629eqK9Q_izXQUycB'

const response=await fetch(`${url}/rest/v1/rpc/get_release_health_v1`,{
 method:'POST',
 headers:{
  apikey:key,
  Authorization:`Bearer ${key}`,
  'Content-Type':'application/json',
 },
 body:'{}',
})
if(!response.ok)throw new Error(`Release health RPC returned ${response.status}: ${await response.text()}`)
const health=await response.json()
if(!health||typeof health!=='object')throw new Error('Release health RPC returned an invalid payload')
console.log('Release health:',JSON.stringify(health))
if(!health.ok||Number(health.critical_count)!==0){
 throw new Error(`Production content health failed with ${health.critical_count??'unknown'} critical issue(s)`)
}
if(Number(health.warning_count)>0){
 console.warn(`Release health warnings: ${health.warning_count}`)
}
