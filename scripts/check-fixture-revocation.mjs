// Uses only this workflow's disposable account and a normal password sign-in.
// Keep tokens in memory, never in traces, logs, files or workflow artifacts.
import {createClient} from '@supabase/supabase-js'
const url='https://kimtiyuytikyseuzmjbv.supabase.co'
const key='sb_publishable_ANuwDKjYwbR2LF629eqK9Q_izXQUycB'
const {KINEO_E2E_USER_ID:id,KINEO_E2E_EMAIL:email,KINEO_E2E_PASSWORD:password,LERYKO_E2E_OIDC:oidc}=process.env
if(!id||!email||!password||!oidc||!/^kineo-e2e\+\d+-[a-zA-Z0-9_-]+@example\.com$/.test(email))throw new Error('Missing isolated workflow fixture')
const client=createClient(url,key,{auth:{persistSession:false,autoRefreshToken:false}})
const {data,error}=await client.auth.signInWithPassword({email,password})
if(error||!data.session||data.user?.id!==id)throw new Error('Unable to sign in to the exact workflow fixture')
const token=data.session.access_token
if(!data.session.expires_at||data.session.expires_at<=Date.now()/1000)throw new Error('Fixture token must still be valid during this test')
const deletion=await fetch(url+'/functions/v1/e2e-session-broker',{
 method:'POST',headers:{Authorization:'Bearer '+oidc,'Content-Type':'application/json'},
 body:JSON.stringify({action:'cleanup',user_id:id}),signal:AbortSignal.timeout(20000),
})
if(!deletion.ok)throw new Error('Fixture cleanup failed before the revocation test')
const headers={apikey:key,Authorization:'Bearer '+token,'Content-Type':'application/json'}
const api=await fetch(url+'/rest/v1/rpc/get_my_library_v1',{method:'POST',headers,body:'{}',signal:AbortSignal.timeout(15000)})
const storage=await fetch(url+'/storage/v1/object/sign/documents/courses/local-courses-2026-10/1e8a8660-69ad-47a3-8b56-6170cf61e9ae.pdf',{
 method:'POST',headers,body:JSON.stringify({expiresIn:60}),signal:AbortSignal.timeout(15000),
})
if(api.status!==403||storage.ok)throw new Error('Deleted fixture retained Data API or private Storage access')
console.log('Deleted workflow fixture denied by Data API and private Storage while its access token remains unexpired.')

