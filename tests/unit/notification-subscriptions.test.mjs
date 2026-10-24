import test from 'node:test'
import assert from 'node:assert/strict'
import fs from 'node:fs'
import vm from 'node:vm'
import ts from 'typescript'
test('page and header subscriptions stay independent when one page unmounts',async()=>{
 const channels=[],removed=[]
 const supabase={auth:{getUser:async()=>({data:{user:{id:'student'}}})},channel:topic=>{const channel={topic,on(){return this},subscribe(){return this}};channels.push(channel);return channel},removeChannel:async channel=>{removed.push(channel)}}
 const module={exports:{}}
 const source=fs.readFileSync(new URL('../../src/services/notificationApi.ts',import.meta.url),'utf8')
 vm.runInNewContext(ts.transpileModule(source,{compilerOptions:{module:ts.ModuleKind.CommonJS,target:ts.ScriptTarget.ES2022}}).outputText,{module,exports:module.exports,require:()=>({supabase})})
 const header=module.exports.subscribeToNotificationChanges(()=>{}),page=module.exports.subscribeToNotificationChanges(()=>{})
 await new Promise(resolve=>setImmediate(resolve))
 assert.equal(channels.length,2);assert.notEqual(channels[0].topic,channels[1].topic)
 page();assert.equal(removed.length,1);assert.equal(removed[0],channels[1])
 header();assert.equal(removed[1],channels[0])
})
