import {test} from 'node:test'
import assert from 'node:assert/strict'
import {mkdtemp,mkdir,writeFile,rm} from 'node:fs/promises'
import {tmpdir} from 'node:os'
import path from 'node:path'
import fs from 'node:fs'
import vm from 'node:vm'
import ts from 'typescript'
import {interfaceBuild} from '../../scripts/interface-build.mjs'
import {selectDeployment,assertUnchanged,validateTarget} from '../../scripts/release-safety.mjs'
import {packageRelease,verifyRelease} from '../../scripts/package-release.mjs'
const module={exports:{}}
vm.runInNewContext(ts.transpileModule(fs.readFileSync(new URL('../../src/learning/interfaceSelection.ts',import.meta.url),'utf8'),{compilerOptions:{module:ts.ModuleKind.CommonJS}}).outputText,{module,exports:module.exports})
test('explicit legacy choice survives a V5 default and disabled builds ignore opt-ins',()=>{
 const select=module.exports.selectInterface
 assert.equal(select(true,true,null,null),true)
 assert.equal(select(true,true,null,'legacy'),false)
 assert.equal(select(true,true,'legacy','v5'),false)
 assert.equal(select(true,false,'v5','legacy'),true)
 assert.equal(select(false,true,'v5','v5'),false)
 assert.equal(interfaceBuild({}),'legacy')
 assert.equal(interfaceBuild({VITE_ENABLE_V5_PREVIEW:'true'}),'preview')
 assert.equal(interfaceBuild({VITE_ENABLE_V5_PREVIEW:'true',VITE_V5_DEFAULT:'true'}),'v5')
 assert.throws(()=>interfaceBuild({VITE_V5_DEFAULT:'true'}))
})
const version='a0000000-0000-4000-8000-000000000001'
const deployment='b0000000-0000-4000-8000-000000000001'
const row={id:deployment,created_on:'2026-10-16T00:00:00Z',versions:[{version_id:version,percentage:100}]}
test('rollback selects an exact version, rejects split traffic and detects a competing deployer',()=>{
 const previous={...row,id:'b0000000-0000-4000-8000-000000000002',created_on:'2026-10-15T00:00:00Z'}
 const snapshot=selectDeployment([row,previous])
 assert.deepEqual(snapshot,{deployment,version})
 assertUnchanged([previous,row],snapshot)
 assert.throws(()=>assertUnchanged([previous],snapshot))
 assert.throws(()=>selectDeployment([{...row,versions:[{version_id:version,percentage:50}]}]))
 assert.throws(()=>selectDeployment([]))
 assert.throws(()=>selectDeployment([{...row,created_on:'unknown'}]))
 assert.throws(()=>validateTarget('--latest','abc'))
 assert.throws(()=>validateTarget(version+'\n','a'.repeat(40)))
 assert.throws(()=>validateTarget(version,'a'.repeat(40)+'\n'))
 validateTarget(version,'a'.repeat(40))
})
test('release checksums reject altered, extra and missing files',async()=>{
 const root=await mkdtemp(path.join(tmpdir(),'leryko-release-'))
 assert.ok(path.resolve(root).startsWith(path.resolve(tmpdir())+path.sep))
 assert.ok(path.basename(root).startsWith('leryko-release-'))
 try{
  await mkdir(path.join(root,'assets'))
  await writeFile(path.join(root,'version.json'),JSON.stringify({commit:'a'.repeat(40),interface:'v5',cache:'cache-v5'}))
  await writeFile(path.join(root,'assets','main.js'),'original')
  await packageRelease(root)
  await verifyRelease(root)
  await writeFile(path.join(root,'assets','main.js'),'changed')
  await assert.rejects(()=>verifyRelease(root))
  await writeFile(path.join(root,'assets','main.js'),'original')
  await writeFile(path.join(root,'extra.txt'),'unexpected')
  await assert.rejects(()=>verifyRelease(root))
  await rm(path.join(root,'extra.txt'))
  await rm(path.join(root,'assets','main.js'))
  await assert.rejects(()=>verifyRelease(root))
 }finally{await rm(root,{recursive:true,force:true})}
})
