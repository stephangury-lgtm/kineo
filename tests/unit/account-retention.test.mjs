import test from 'node:test'
import assert from 'node:assert/strict'
import {deliveryState, runRetention, noticeEmail} from '../../supabase/functions/account-retention/worker.mjs'

const notice = {id: 'notice', user_id: 'student', recipient: 'student@example.invalid', provider_id: 'email', state: 'delivered'}
const config = {configured: true, lease: 'lease', sender: 'Leryko <support@example.invalid>'}
function harness(job = notice, claim = {user_id: 'student', avatars: []}) {
 const calls = []
 const adapters = {
  config,
  rpc: async (name, args) => {calls.push([name,args]); if (name==='retention_jobs_v1') return [job]; if (name==='retention_claim_delete_v1') return claim; return job},
  resend: async (...args) => {calls.push(['email',...args]); return {id: 'email', to: [notice.recipient], last_event: 'delivered'}},
  removeAvatars: async paths => {calls.push(['storage',paths]); claim.avatars=[]},
  auth: {updateUserById: async (...args) => {calls.push(['ban',...args]); return {}}, deleteUser: async (...args) => {calls.push(['delete',...args]); return {}}},
 }
 return {adapters,calls}
}
test('Missing sender configuration does not fetch candidates or delete', async () => {
 const h=harness(); h.adapters.config={configured:false}; const r=await runRetention(h.adapters)
 assert.equal(r.deleted,0); assert.deepEqual(h.calls,[])
})
test('Sent, mismatched recipient, unknown delivery and bounces never establish delivery', () => {
 for(const status of ['sent','delivery_delayed','queued']) assert.equal(deliveryState({id:'email',to:[notice.recipient],last_event:status},notice),'waiting')
 assert.equal(deliveryState({id:'email',to:['other@example.invalid'],last_event:'delivered'},notice),'blocked')
 assert.equal(deliveryState({id:'other',to:[notice.recipient],last_event:'delivered'},notice),'blocked')
 assert.equal(deliveryState({id:'email',to:[notice.recipient],last_event:'bounced'},notice),'blocked')
})
test('Database rejection of grace period or resumed activity prevents deletion', async () => {
 const h=harness(notice,null); const r=await runRetention(h.adapters)
 assert.equal(r.deleted,0); assert.equal(h.calls.some(c=>c[0]==='ban'||c[0]==='delete'),false)
})
test('Avatar binaries are removed after claim and before hard Auth deletion', async () => {
 const h=harness(notice,{user_id:'student',avatars:['student/photo.jpg']}); const r=await runRetention(h.adapters)
 assert.equal(r.deleted,1)
 assert.ok(h.calls.findIndex(c=>c[0]==='storage')<h.calls.findIndex(c=>c[0]==='delete'))
 assert.deepEqual(h.calls.at(-1),['delete','student',false])
})
test('Storage or account locking errors prevent Auth deletion', async () => {
 for(const stage of ['storage','ban']) {
  const h=harness(notice,{user_id:'student',avatars:['student/photo.jpg']})
  if(stage==='storage') h.adapters.removeAvatars=async()=>{throw new Error('failure')}
  else h.adapters.auth.updateUserById=async()=>({error:true})
  const r=await runRetention(h.adapters); assert.equal(r.errors,1); assert.equal(h.calls.some(c=>c[0]==='delete'),false)
 }
})
test('Warnings use persistent idempotency keys and do not delete in the same run', async () => {
 const h=harness({...notice,state:'pending'}); const r=await runRetention(h.adapters)
 assert.equal(r.warned,1); assert.equal(r.deleted,0)
 assert.equal(h.calls.find(c=>c[0]==='email').at(-1),'retention/notice')
 assert.match(noticeEmail(notice.recipient,config.sender).text,/30 jours/)
})
test('A failed delivery suspends deletion; provider failures also fail closed', async () => {
 for(const fail of ['bounce','unavailable']) {
  const h=harness()
  h.adapters.resend=async()=> {if(fail==='unavailable')throw new Error('failure');return {id:'email',to:[notice.recipient],last_event:'bounced'}}
  const r=await runRetention(h.adapters); assert.equal(r.deleted,0); assert.equal(h.calls.some(c=>c[0]==='delete'),false)
 }
})
test('Expired provider logs require a persisted receipt and database approval', async () => {
 for (const confirmed of [true,false]) {
  const h=harness({...notice,delivered_at:confirmed?'2026-01-01':null,delete_after:confirmed?'2026-01-31':null})
  h.adapters.resend=async()=>({retention_expired:true})
  const r=await runRetention(h.adapters); assert.equal(r.deleted,confirmed?1:0)
 }
 const h=harness({...notice,delivered_at:'2026-01-01',delete_after:'2026-01-31'},null)
 h.adapters.resend=async()=>({retention_expired:true})
 assert.equal((await runRetention(h.adapters)).deleted,0)
})
