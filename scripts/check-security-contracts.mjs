const url=process.env.KINEO_SUPABASE_URL||'https://kimtiyuytikyseuzmjbv.supabase.co'
const key=process.env.KINEO_SUPABASE_PUBLISHABLE_KEY||'sb_publishable_ANuwDKjYwbR2LF629eqK9Q_izXQUycB'

async function rpc(name,body){
 return fetch(`${url}/rest/v1/rpc/${name}`,{
  method:'POST',
  headers:{apikey:key,Authorization:`Bearer ${key}`,'Content-Type':'application/json'},
  body:JSON.stringify(body??{}),
 })
}

const publicHealth=await fetch(`${url}/rest/v1/release_health_status?id=eq.1&select=id`,{
 headers:{apikey:key,Authorization:`Bearer ${key}`},
})
if(!publicHealth.ok)throw new Error(`Public release-health read contract failed: ${publicHealth.status}`)

const securityStatus=await fetch(`${url}/rest/v1/security_health_status?id=eq.1&select=payload,checked_at`,{
 headers:{apikey:key,Authorization:`Bearer ${key}`},
 cache:'no-store',
})
if(!securityStatus.ok)throw new Error(`Security health read failed: ${securityStatus.status}`)
const securityRows=await securityStatus.json()
const securityRow=Array.isArray(securityRows)?securityRows[0]:null
const securityHealth=securityRow?.payload
if(!securityHealth||!securityHealth.ok||Number(securityHealth.critical_count)!==0){
 throw new Error(`Security health gate failed with ${securityHealth?.critical_count??'unknown'} critical issue(s)`)
}
const securityCheckedAt=Date.parse(securityRow.checked_at||securityHealth.generated_at||'')
if(!Number.isFinite(securityCheckedAt)||(Date.now()-securityCheckedAt)>90*60*1000){
 throw new Error('Security health snapshot is missing or stale')
}

const protectedCalls=[
 ['get_badges_v2',{}],
 ['get_friend_leaderboard_v2',{p_program_id:'kineo-es'}],
 ['get_friend_challenges_v3',{}],
 ['get_friendships_v3',{p_program_id:'kineo-es'}],
 ['get_curriculum_progress_v1',{p_program_id:'kineo-es'}],
 ['report_client_error_v1',{p_message:'ci-anon-security-probe',p_component_stack:null,p_page_path:'/ci',p_app_version:'ci'}],
 ['submit_quiz_answer_v5',{
   p_session_id:'00000000-0000-0000-0000-000000000000',
   p_question_id:'00000000-0000-0000-0000-000000000000',
   p_answer:{text:'ci'},
   p_response_time_ms:1,
 }],
]

for(const [name,body] of protectedCalls){
 const response=await rpc(name,body)
 if(response.status===404)throw new Error(`Security contract invalid: ${name} RPC is missing or signature changed`)
 if(response.ok)throw new Error(`Security regression: anonymous caller can execute ${name}`)
}

console.log(`Anonymous security contracts passed for ${protectedCalls.length} protected RPCs`)
