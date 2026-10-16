// CI only. Credentials stay masked in environment variables, never in artifacts.
import {appendFile} from 'node:fs/promises'
const endpoint='https://cyzdivbdgpvhwpmikeqh.supabase.co/functions/v1/e2e-staging-broker'
if(process.env.GITHUB_REPOSITORY!=='stephangury-lgtm/kineo'||!['refs/heads/main','refs/heads/feat/leryko-v5-interface'].includes(process.env.GITHUB_REF))throw Error('Unexpected CI context')
const response=await fetch(process.env.ACTIONS_ID_TOKEN_REQUEST_URL+'&audience=kineo-e2e',{headers:{Authorization:'bearer '+process.env.ACTIONS_ID_TOKEN_REQUEST_TOKEN}})
if(!response.ok)throw Error('OIDC token request failed')
const {value:token}=await response.json()
async function invoke(body){
 const r=await fetch(endpoint,{method:'POST',headers:{Authorization:'Bearer '+token,'Content-Type':'application/json'},body:JSON.stringify(body)})
 if(!r.ok)throw Error('Staging account broker rejected '+body.action+' ('+r.status+')')
 return r.json()
}
const action=process.argv[2]
if(action==='create'){
 await invoke({action:'prepare-storage'})
 const result=await invoke({action:'create',suffix:'staging'})
 const fields={KINEO_E2E_USER_ID:'user_id',KINEO_E2E_EMAIL:'email',KINEO_E2E_PASSWORD:'password',KINEO_E2E_FRIEND_USER_ID:'friend_user_id',KINEO_E2E_FRIEND_EMAIL:'friend_email',KINEO_E2E_FRIEND_PASSWORD:'friend_password',KINEO_E2E_FRIEND_USERNAME:'friend_username'}
 for(const [variable,key] of Object.entries(fields)){
  const value=String(result[key]??'')
  if(!value||/[\r\n]/.test(value))throw Error('Invalid broker result')
  console.log('::add-mask::'+value)
  await appendFile(process.env.GITHUB_ENV,`${variable}=${value}\n`)
 }
 console.log('Synthetic staging accounts created; no email sent.')
}else if(action==='cleanup'){
 for(const user_id of [process.env.KINEO_E2E_USER_ID,process.env.KINEO_E2E_FRIEND_USER_ID]){
  if(user_id)await invoke({action:'cleanup',user_id})
 }
 console.log('Staging fixture account cleanup complete.')
}else throw Error('Unknown account action')
