import {test} from 'node:test'
import assert from 'node:assert/strict'
import fs from 'node:fs'
import vm from 'node:vm'
import ts from 'typescript'
const module={exports:{}}
vm.runInNewContext(ts.transpileModule(fs.readFileSync(new URL('../../src/learning/navigation.ts',import.meta.url),'utf8'),{compilerOptions:{module:ts.ModuleKind.CommonJS}}).outputText,{module,exports:module.exports})
test('deep links keep the relevant V5 navigation section',()=>{
 const section=module.exports.learningSection
 for(const path of ['/document/id','/lesson/id','/cours/id','/bibliotheque'])assert.equal(section(path),'/parcours')
 for(const path of ['/rewards','/stats','/session/id','/revision/historique'])assert.equal(section(path),'/progres')
 assert.equal(section('/defi-cursus/id'),'/amis')
 assert.equal(section('/quiz'),'/ma-seance')
 assert.equal(section('/admin'),'/profil')
})

test('daily action and profile have stable destinations',()=>{assert.equal(module.exports.learningSection('/'),'/ma-seance');assert.equal(module.exports.learningSection('/ma-seance'),'/ma-seance');assert.equal(module.exports.learningSection('/profil'),'/profil')})
