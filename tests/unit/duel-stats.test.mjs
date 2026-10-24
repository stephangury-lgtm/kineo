import test from 'node:test'
import assert from 'node:assert/strict'
import fs from 'node:fs'
import vm from 'node:vm'
import ts from 'typescript'
const source=fs.readFileSync(new URL('../../src/services/duelStats.ts',import.meta.url),'utf8')
const compiled=ts.transpileModule(source,{compilerOptions:{module:ts.ModuleKind.CommonJS,target:ts.ScriptTarget.ES2022}}).outputText
const module={exports:{}}
vm.runInNewContext(compiled,{module,exports:module.exports})
const {getDuelRivalries}=module.exports
const duel=(id,mine,other,extra={})=>({id,status:'completed',direction:'sent',challenger_score:mine,challenged_score:other,created_at:'2026-10-24',completed_at:null,opponent:{id:'friend'},...extra})
test('shows first duel and accumulates both directions, including zero scores and draws',()=>{
 const [row]=getDuelRivalries([duel('1',100,50),duel('2',100,0,{direction:'received'}),duel('3',0,0)])
 assert.equal(row.duels,3);assert.equal(row.wins,1);assert.equal(row.losses,1);assert.equal(row.draws,1)
 assert.equal(getDuelRivalries([duel('1',100,50)]).length,1)
})
test('excludes unfinished, declined and cancelled challenges and incomplete scores; deduplicates IDs',()=>{
 const rows=getDuelRivalries([duel('1',0,100),duel('1',0,100),duel('2',null,100),...['pending','accepted','in_progress','declined','cancelled'].map(status=>duel(status,100,0,{status}))])
 assert.equal(rows.length,1);assert.equal(rows[0].duels,1);assert.equal(rows[0].losses,1)
})
test('keeps opponents separate and orders recent results by completion date without mutating input',()=>{
 const input=[duel('old',0,100,{completed_at:'2026-10-22'}),duel('other',0,0,{opponent:{id:'other'}}),duel('new',100,0,{completed_at:'2026-10-24'})]
 const result=getDuelRivalries(input)
 assert.equal(result.length,2);assert.equal(result[0].opponent.id,'friend');assert.equal(result[0].latestChallengeId,'new');assert.equal(result[0].recent.join(','),'W,L');assert.equal(input[0].id,'old')
})
