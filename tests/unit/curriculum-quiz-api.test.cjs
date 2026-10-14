const test=require('node:test')
const assert=require('node:assert/strict')
const fs=require('node:fs')
const vm=require('node:vm')
const path=require('node:path')
const ts=require('typescript')

function loadApi(rpc){
 const source=fs.readFileSync(path.join(__dirname,'../../src/services/curriculumQuizApi.ts'),'utf8')
 const compiled=ts.transpileModule(source,{compilerOptions:{module:ts.ModuleKind.CommonJS,target:ts.ScriptTarget.ES2022}}).outputText
 const module={exports:{}}
 vm.runInNewContext(compiled,{module,exports:module.exports,require:()=>({supabase:{rpc}})})
 return module.exports.getSafeCurriculumQuestions
}

test('fetches all pages and batches more than 200 distinct topics',async()=>{
 const calls=[]
 const api=loadApi((name,{p_topic_ids:topics})=>({range:async(from,to)=>{
  calls.push({name,topics,from,to})
  const count=topics.includes('topic-0')?501:1
  return {data:Array.from({length:count},(_,index)=>({id:`${topics[0]}-${index}`})).slice(from,to+1),error:null}
 }}))
 const ids=Array.from({length:201},(_,index)=>`topic-${index}`)
 const result=await api([...ids,'topic-0'])
 assert.equal(result.length,502)
 assert.deepEqual(calls.map(call=>call.from),[0,500,0])
 assert.deepEqual(calls.map(call=>call.topics.length),[200,200,1])
 assert(calls.every(call=>call.name==='get_curriculum_quiz_questions_v1'))
})

test('a failed later page rejects rather than silently returning a partial pool',async()=>{
 const error=new Error('Interrupted request')
 const api=loadApi(()=>({range:async(from)=>from===0?{data:Array.from({length:500},(_,id)=>({id})),error:null}:{data:null,error}}))
 await assert.rejects(api(['topic']),error)
})

test('empty topic lists make no request',async()=>{
 let calls=0
 const api=loadApi(()=>{calls++;throw new Error('Unexpected request')})
 assert.equal((await api([])).length,0)
 assert.equal(calls,0)
})
