const url=process.env.KINEO_SUPABASE_URL||'https://kimtiyuytikyseuzmjbv.supabase.co'
const key=process.env.KINEO_SUPABASE_PUBLISHABLE_KEY||'sb_publishable_ANuwDKjYwbR2LF629eqK9Q_izXQUycB'

const response=await fetch(`${url}/rest/v1/release_health_status?id=eq.1&select=payload,checked_at`,{
 headers:{apikey:key,Authorization:`Bearer ${key}`},
 cache:'no-store',
})
if(!response.ok)throw new Error(`Release health endpoint returned ${response.status}: ${await response.text()}`)
const rows=await response.json()
const row=Array.isArray(rows)?rows[0]:null
const health=row?.payload
if(!health||typeof health!=='object')throw new Error('Release health endpoint returned an invalid payload')
const checkedAt=Date.parse(row.checked_at||health.generated_at||'')
if(!Number.isFinite(checkedAt))throw new Error('Release health timestamp is invalid')
const ageMinutes=(Date.now()-checkedAt)/60000
if(ageMinutes>90)throw new Error(`Release health snapshot is stale (${ageMinutes.toFixed(0)} min)`)
console.log('Release health:',JSON.stringify(health))
if(!health.ok||Number(health.critical_count)!==0){
 throw new Error(`Production content health failed with ${health.critical_count??'unknown'} critical issue(s)`)
}
if(Number(health.warning_count)>0)console.warn(`Release health warnings: ${health.warning_count}`)
