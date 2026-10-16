import test from 'node:test'
import assert from 'node:assert/strict'
import {readServerKey,createServerClient} from '../../supabase/functions/_shared/server-client.mjs'
const key='sb_secret_'+ 'synthetic_test_key_'.repeat(3)
test('server key selection requires the modern named default without legacy fallback',()=>{
 assert.equal(readServerKey(name=>name==='SUPABASE_SECRET_KEYS'?JSON.stringify({default:key}):undefined),key)
 for(const value of [undefined,'{','{}',JSON.stringify({default:'legacy-jwt'}),JSON.stringify({other:key})]){
  assert.throws(()=>readServerKey(name=>name==='SUPABASE_SECRET_KEYS'?value:'legacy-service-role'))
 }
})
test('modern server requests use apikey, preserve user JWTs and reject other origins',async()=>{
 let options
 createServerClient((_url,_key,config)=>{options=config;return {}},name=>({SUPABASE_URL:'https://example.invalid',SUPABASE_SECRET_KEYS:JSON.stringify({default:key})})[name])
 const original=globalThis.fetch,calls=[]
 globalThis.fetch=async(input,init)=>{calls.push(init);return new Response('{}')}
 try{
  await options.global.fetch('https://example.invalid/storage/v1/bucket',{headers:{apikey:key,authorization:`Bearer ${key}`}})
  assert.equal(calls[0].headers.get('apikey'),key)
  assert.equal(calls[0].headers.has('authorization'),false)
  assert.equal(calls[0].redirect,'error')
  await options.global.fetch('https://example.invalid/rest/v1/',{headers:{authorization:'Bearer user-jwt'}})
  assert.equal(calls[1].headers.get('authorization'),'Bearer user-jwt')
  await assert.rejects(options.global.fetch('https://different.invalid/',{}))
 }finally{globalThis.fetch=original}
})

