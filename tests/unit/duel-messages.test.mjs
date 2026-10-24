import test from 'node:test'
import assert from 'node:assert/strict'
import fs from 'node:fs'
import vm from 'node:vm'
import ts from 'typescript'
function load(file){const module={exports:{}};const source=fs.readFileSync(new URL('../../src/services/'+file,import.meta.url),'utf8');vm.runInNewContext(ts.transpileModule(source,{compilerOptions:{module:ts.ModuleKind.CommonJS,target:ts.ScriptTarget.ES2022}}).outputText,{module,exports:module.exports,require:()=>({})});return module.exports}
const {getDuelMessagePresets}=load('duelMessagePresets.ts')
const {challengeNotificationDestination}=load('notificationApi.ts')
test('suggestions reflect the player perspective in French and Spanish, including ties and missing scores',()=>{
 const duel={direction:'sent',challenger_score:0,challenged_score:100}
 for(const spanish of [false,true]){
  const losing=getDuelMessagePresets(duel,spanish)
  const winning=getDuelMessagePresets({...duel,direction:'received'},spanish)
  const tied=getDuelMessagePresets({...duel,challenged_score:0},spanish)
  assert.match(losing[0],spanish?/ficha/:/fiche/)
  assert.match(winning[0],spanish?/punto para mí/:/point pour moi/)
  assert.match(tied[0],spanish?/Empate/:/Match nul/)
  for(const text of [...losing,...winning,...tied])assert.ok(text.length>0&&text.length<=240)
 }
 assert.equal(getDuelMessagePresets({...duel,challenger_score:null},false).length,0)
})
test('message notifications open their exact duel; malformed identifiers and other types fall back safely',()=>{
 const id='31be7940-e9a3-4dba-9950-9cd91083da90'
 for(const key of ['challenge_id','curriculum_challenge_id'])assert.equal(challengeNotificationDestination({type:'challenge_message',data:{[key]:id}}),`/amis?tab=challenges&discussion=${id}`)
 for(const id of ['javascript:alert(1)','../admin',null,42])assert.equal(challengeNotificationDestination({type:'challenge_message',data:{challenge_id:id}}),'/amis?tab=challenges')
 assert.equal(challengeNotificationDestination({type:'challenge_received',data:{challenge_id:id}}),'/amis?tab=challenges')
})

test('curriculum notifications retain their program even when a different program is selected',()=>{
 const id='31be7940-e9a3-4dba-9950-9cd91083da90'
 assert.equal(challengeNotificationDestination({type:'challenge_message',data:{curriculum_challenge_id:id,program_id:'kineo-es'}}),`/amis?tab=challenges&discussion=${id}&program=kineo-es`)
})
