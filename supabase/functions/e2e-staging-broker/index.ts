import { createClient } from "npm:@supabase/supabase-js@2.117.2"
import { createRemoteJWKSet, jwtVerify } from "npm:jose@5.9.6"
import { verifyWorkflowClaims, canDeleteFixture } from './policy.mjs'
import { createServerClient } from '../_shared/server-client.mjs'

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
 verifyWorkflowClaims(payload)
 return payload
}

Deno.serve(async(req)=>{
 if(req.method!=='POST')return json({error:'Method not allowed'},405)
 try{
  const claims=await verifyGitHubOidc(req)
  const body=await req.json().catch(()=>({}))
  const action=String(body.action??'')
  const supabaseUrl=Deno.env.get('SUPABASE_URL')
  if(supabaseUrl!=='https://cyzdivbdgpvhwpmikeqh.supabase.co')throw new Error('Staging broker cannot run against another project')
  const admin=createServerClient(createClient,(name:string)=>Deno.env.get(name))

  if(action==='prepare-storage'){
   const text='Synthetic software test PDF. No medical content.'
   const stream=`BT /F1 14 Tf 40 750 Td (${text}) Tj ET`
   const objects=['<< /Type /Catalog /Pages 2 0 R >>','<< /Type /Pages /Kids [3 0 R] /Count 1 >>','<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>','<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',`<< /Length ${stream.length} >>\nstream\n${stream}\nendstream`]
   let pdf='%PDF-1.4\n'; const offsets=[0]
   for(const [index,object] of objects.entries()){offsets.push(pdf.length);pdf+=`${index+1} 0 obj\n${object}\nendobj\n`}
   const xref=pdf.length
   pdf+=`xref\n0 6\n0000000000 65535 f \n${offsets.slice(1).map(n=>String(n).padStart(10,'0')+' 00000 n ').join('\n')}\ntrailer\n<< /Size 6 /Root 1 0 R >>\nstartxref\n${xref}\n%%EOF\n`
   for(const year of [2,3,4,5]){
    const {error}=await admin.storage.from('documents').upload(`staging-fixtures/k${year}.pdf`,new TextEncoder().encode(pdf),{contentType:'application/pdf',upsert:true})
    if(error)throw error
   }
   return json({prepared:4})
  }

  if(action==='operations-health'){
   const {data,error}=await admin.rpc('check_operations_health_v1')
   return json({ok:!error&&data===true},!error&&data===true?200:503)
  }

  if(action==='create'){
   const runId=String(claims.run_id??crypto.randomUUID()).replace(/[^a-zA-Z0-9_-]/g,'').slice(-20)
   const suffix=String(body.suffix??'job').replace(/[^a-zA-Z0-9_-]/g,'').slice(0,12)||'job'
   const email=`kineo-e2e+${runId}-${suffix}@example.com`
   const password=`K!neo-${crypto.randomUUID()}-Aa9!`
   const {data:userData,error:userError}=await admin.auth.admin.createUser({
    email,password,email_confirm:true,
    user_metadata:{e2e:true,github_run_id:runId},
    app_metadata:{leryko_e2e:true,github_run_id:runId,retention_exempt:true},
   })
   if(userError||!userData.user)throw userError??new Error('Unable to create E2E user')
   const userId=userData.user.id
   let companionId:string|null=null
   try{
    const username=`e2e_${(runId+'_'+suffix).toLowerCase().replace(/[^a-z0-9_]/g,'_').slice(-20)}`
    const {error:profileError}=await admin.from('profiles').upsert({
      id:userId,first_name:'E2E',username,role:'student',study_year:2,xp:0,level:1,updated_at:new Date().toISOString()
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

    const friendEmail=`kineo-e2e-friend+${runId}-${suffix}@example.com`
    const friendPassword=`K!neo-${crypto.randomUUID()}-Bb8!`
    const {data:friendData,error:friendError}=await admin.auth.admin.createUser({
      email:friendEmail,password:friendPassword,email_confirm:true,
      user_metadata:{e2e:true,github_run_id:runId,e2e_companion:true},
      app_metadata:{leryko_e2e:true,github_run_id:runId,retention_exempt:true},
    })
    if(friendError||!friendData.user)throw friendError??new Error('Unable to create E2E companion')
    const friendId=friendData.user.id
    companionId=friendId
    const friendUsername=`e2e_friend_${(runId+'_'+suffix).toLowerCase().replace(/[^a-z0-9_]/g,'_').slice(0,21)}`
    const {error:friendProfileError}=await admin.from('profiles').upsert({
      id:friendId,first_name:'E2E Friend',username:friendUsername,role:'student',study_year:2,xp:0,level:1,updated_at:new Date().toISOString()
    },{onConflict:'id'})
    if(friendProfileError)throw friendProfileError
    const friendRows=rows.map(row=>({...row,user_id:friendId}))
    const {error:friendProgramError}=await admin.from('profile_programs').upsert(friendRows,{onConflict:'user_id,program_id'})
    if(friendProgramError)throw friendProgramError
    const {error:friendshipError}=await admin.from('friendships').insert({
      requester_id:userId,addressee_id:friendId,status:'accepted'
    })
    if(friendshipError)throw friendshipError

    return json({
      user_id:userId,email,password,
      friend_user_id:friendId,friend_username:friendUsername,friend_email:friendEmail,friend_password:friendPassword,
      programs:['kineo-fr','kineo-es','ifsi-fr']
    })
   }catch(error){
    if(companionId){
      await admin.from('profile_programs').delete().eq('user_id',companionId)
      await admin.from('profiles').delete().eq('id',companionId)
      await admin.auth.admin.deleteUser(companionId)
    }
    await admin.from('profile_programs').delete().eq('user_id',userId)
    await admin.from('profiles').delete().eq('id',userId)
    await admin.auth.admin.deleteUser(userId)
    throw error
   }
  }

  if(action==='cleanup'){
   const userId=String(body.user_id??'')
   if(!/^[0-9a-f-]{36}$/i.test(userId))return json({error:'Invalid user id'},400)
   const {data:userData,error:lookupError}=await admin.auth.admin.getUserById(userId)
   if(lookupError?.status===404)return json({deleted:true})
   if(lookupError)throw lookupError
   if(!canDeleteFixture(userData.user,claims))return json({error:'Refusing to delete an account outside this test run'},403)
   await admin.from('profile_programs').delete().eq('user_id',userId)
   await admin.from('profiles').delete().eq('id',userId)
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



