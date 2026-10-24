import test from 'node:test'
import assert from 'node:assert/strict'
import {readFileSync} from 'node:fs'
import ts from 'typescript'
const source=readFileSync(new URL('../../src/auth/startupDeadline.ts',import.meta.url),'utf8')
const {withStartupDeadline}=await import('data:text/javascript;base64,'+Buffer.from(ts.transpile(source,{module:ts.ModuleKind.ESNext})).toString('base64'))
test('a session operation that never resolves expires instead of blocking startup',async()=>{
 await assert.rejects(withStartupDeadline(new Promise(()=>{}),10),/chargement.*expiré/)
})
test('a late profile result cannot replace a timed out attempt',async()=>{
 let release
 const pending=withStartupDeadline(new Promise(resolve=>{release=resolve}),10)
 await assert.rejects(pending,/expiré/)
 release('old profile')
 await assert.rejects(pending,/expiré/)
 assert.equal(await withStartupDeadline(Promise.resolve('new profile'),10),'new profile')
})
test('successful results and genuine API errors propagate unchanged',async()=>{
 assert.equal(await withStartupDeadline(Promise.resolve('session'),10),'session')
 const error=new Error('access denied')
 await assert.rejects(withStartupDeadline(Promise.reject(error),10),value=>value===error)
})
