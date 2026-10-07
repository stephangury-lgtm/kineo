import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "jsr:@supabase/supabase-js@2"
import { createRemoteJWKSet, jwtVerify } from "npm:jose@5.9.6"

const allowedRepo='stephangury-lgtm/kineo'
const allowedRef='refs/heads/main'
const audience='kineo-e2e'
const jwks=createRemoteJWKSet(new URL('https://token.actions.githubusercontent.com/.well-known/jwks'))

function json(data:unknown,status=200){
 return new Response(JSON.stringify(data),{status,headers:{'content-type':'application/json'}})
}

async function verifyGitHubOidc(req:Request){
 const header=req.headers.get('authorization')||''
 const token=header.startsWith('Bearer ')?header.slice(7):''
 if(!token)throw new Error('Missing GitHub OIDC token')
 const {payload}=await jwtVerify(token,jwks,{
  issuer:'https://token.actions.githubusercontent.com',
  audience,
 })
 if(payload.repository!==allowedRepo)throw new Error('Repository not allowed')
 if(payload.ref!==allowedRef)throw new Error('Ref not allowed')
 const event=String(payload.event_name??'')
 if(!['push','workflow_dispatch'].includes(event))throw new Error('Event not allowed')
 return payload
}

Deno.serve(async(req)=>{
 if(req.method!=='POST')return json({error:'Method not allowed'},405)
 try{
  const claims=await verifyGitHubOidc(req)
  const body=await req.json().catch(()=>({}))
  const action=String(body.action??'')
  const supabaseUrl=Deno.env.get('SUPABASE_URL')
  const serviceKey=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  if(!supabaseUrl||!serviceKey)throw new Error('Supabase admin environment unavailable')
  const admin=createClient(supabaseUrl,serviceKey,{auth:{autoRefreshToken:false,persistSession:false}})

  if(action==='create'){
   const runId=String(claims.run_id??crypto.randomUUID()).replace(/[^a-zA-Z0-9_-]/g,'').slice(-24)
   const email=`kineo-e2e+${runId}@example.com`
   const password=`K!neo-${crypto.randomUUID()}-Aa9!`
   const {data:userData,error:userError}=await admin.auth.admin.createUser({
    email,password,email_confirm:true,
    user_metadata:{e2e:true,github_run_id:runId},
   })
   if(userError||!userData.user)throw userError??new Error('Unable to create E2E user')
   const userId=userData.user.id
   try{
    const username=`e2e_${runId.toLowerCase().replace(/[^a-z0-9_]/g,'_').slice(0,28)}`
    const {error:profileError}=await admin.from('profiles').upsert({
      id:userId,first_name:'E2E',username,role:'student',xp:0,level:1,updated_at:new Date().toISOString()
    },{onConflict:'id'})
    if(profileError)throw profileError

    const {data:levels,error:levelError}=await admin.from('academic_levels')
      .select('id,program_id,code')
      .in('program_id',['kineo-fr','kineo-es','ifsi-fr'])
      .in('code',['K2','ES1','S2'])
    if(levelError)throw levelError
    const byKey=new Map((levels??[]).map((row:any)=>[`${row.program_id}:${row.code}`,row.id]))
    const required=[
      ['kineo-fr','K2','default',true],
      ['kineo-es','ES1','default',false],
      ['ifsi-fr','S2','2009',false],
    ] as const
    const rows=required.map(([program_id,code,curriculum_version,is_primary])=>{
      const academic_level_id=byKey.get(`${program_id}:${code}`)
      if(!academic_level_id)throw new Error(`Missing academic level ${program_id}/${code}`)
      return {user_id:userId,program_id,academic_level_id,curriculum_version,is_primary}
    })
    const {error:programError}=await admin.from('profile_programs').upsert(rows,{onConflict:'user_id,program_id'})
    if(programError)throw programError

    return json({user_id:userId,email,password,programs:['kineo-fr','kineo-es','ifsi-fr']})
   }catch(error){
    await admin.auth.admin.deleteUser(userId)
    throw error
   }
  }

  if(action==='cleanup'){
   const userId=String(body.user_id??'')
   if(!/^[0-9a-f-]{36}$/i.test(userId))return json({error:'Invalid user id'},400)
   const {data:userData}=await admin.auth.admin.getUserById(userId)
   if(!userData.user?.user_metadata?.e2e)return json({error:'Refusing to delete a non-E2E user'},403)
   const {error}=await admin.auth.admin.deleteUser(userId)
   if(error)throw error
   return json({deleted:true})
  }

  return json({error:'Unknown action'},400)
 }catch(error){
  console.error(error)
  return json({error:error instanceof Error?error.message:'E2E broker error'},403)
 }
})
