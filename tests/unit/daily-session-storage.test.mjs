import {test} from 'node:test'
import assert from 'node:assert/strict'
import fs from 'node:fs'
import vm from 'node:vm'
import ts from 'typescript'
function fixture(raw){
 const storage={['leryko_daily_v1:one']:raw,other:'keep',getItem(key){return this[key]??null},removeItem(key){delete this[key]}}
 const module={exports:{}}
 vm.runInNewContext(ts.transpileModule(fs.readFileSync(new URL('../../src/learning/daily-session-storage.ts',import.meta.url),'utf8'),{compilerOptions:{module:ts.ModuleKind.CommonJS}}).outputText,{module,exports:module.exports,sessionStorage:storage})
 return {storage,...module.exports}
}
const saved={ids:['a','b'],index:0,selected:'Choice',result:{correct:true,explanation:'Server correction'},correctCount:1}
test('local daily checkpoint restores only its exact scoped key without submitting answers',()=>{
 const f=fixture(JSON.stringify(saved))
 assert.equal(f.readDailySnapshot('leryko_daily_v1:one').selected,'Choice')
 assert.equal(f.readDailySnapshot('leryko_daily_v1:other'),null)
 f.clearDailySnapshots();assert.equal(f.storage['leryko_daily_v1:one'],undefined);assert.equal(f.storage.other,'keep')
})
test('corrupt and inconsistent local checkpoints are ignored',()=>{
 for(const raw of ['{',JSON.stringify({...saved,index:99}),JSON.stringify({...saved,ids:['a','a']}),JSON.stringify({...saved,result:{correct:'true'}}),JSON.stringify({...saved,correctCount:5})])assert.equal(fixture(raw).readDailySnapshot('leryko_daily_v1:one'),null)
})
