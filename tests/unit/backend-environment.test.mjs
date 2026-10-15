import {test} from 'node:test'
import assert from 'node:assert/strict'
import fs from 'node:fs'
import vm from 'node:vm'
import ts from 'typescript'
const source=fs.readFileSync(new URL('../../src/config/backend.ts',import.meta.url),'utf8')
const module={exports:{}}
vm.runInNewContext(ts.transpileModule(source,{compilerOptions:{module:ts.ModuleKind.CommonJS,target:ts.ScriptTarget.ES2022}}).outputText,{module,exports:module.exports,URL})
const {resolveBackend}=module.exports
test('Staging cannot silently use production or a server secret',()=>{
 const prod=resolveBackend({VITE_SUPABASE_URL:'https://obsolete.example'})
 assert.equal(prod.production,true)
 const staging={VITE_BACKEND_ENV:'staging',VITE_SUPABASE_URL:'https://isolated-test.supabase.co',VITE_SUPABASE_PUBLISHABLE_KEY:'sb_publishable_test'}
 assert.equal(resolveBackend(staging).production,false)
 for(const env of [{VITE_BACKEND_ENV:'staging'},{...staging,VITE_SUPABASE_URL:prod.url},{...staging,VITE_SUPABASE_PUBLISHABLE_KEY:prod.key},{...staging,VITE_SUPABASE_PUBLISHABLE_KEY:'sb_secret_forbidden'},{...staging,VITE_BACKEND_ENV:'typo'}])assert.throws(()=>resolveBackend(env))
})
