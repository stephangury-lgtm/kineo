const url=process.env.KINEO_SUPABASE_URL||'https://kimtiyuytikyseuzmjbv.supabase.co'
const key=process.env.KINEO_SUPABASE_PUBLISHABLE_KEY||'sb_publishable_ANuwDKjYwbR2LF629eqK9Q_izXQUycB'

async function rpc(name,body){
 return fetch(`${url}/rest/v1/rpc/${name}`,{
  method:'POST',
  headers:{apikey:key,Authorization:`Bearer ${key}`,'Content-Type':'application/json'},
  body:JSON.stringify(body??{}),
 })
}

const publicHealth=await rpc('get_release_health_v1',{})
if(!publicHealth.ok)throw new Error(`Public release-health contract failed: ${publicHealth.status}`)

const protectedCalls=[
 ['get_badges_v2',{}],
 ['get_friend_leaderboard_v2',{p_program_id:'kineo-es'}],
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
 if(response.ok){
  throw new Error(`Security regression: anonymous caller can execute ${name}`)
 }
}

console.log(`Anonymous security contracts passed for ${protectedCalls.length} protected RPCs`)
