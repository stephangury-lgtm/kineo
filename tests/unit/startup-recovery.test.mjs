import {test} from 'node:test'
import assert from 'node:assert/strict'
import {readFileSync} from 'node:fs'
import vm from 'node:vm'

const script=readFileSync(new URL('../../public/startup-recovery.js',import.meta.url),'utf8')
function fixture({offline=false}={}){
 const listeners={},replacements=[],storage=new Map()
 let release
 const pending=new Promise(resolve=>{release=resolve})
 const location={href:'https://leryko.example/profil',replace(value){replacements.push(value)}}
 const window={addEventListener(name,fn){(listeners[name]??=[]).push(fn)},setTimeout(){}}
 const navigator={onLine:!offline,serviceWorker:{getRegistrations:()=>pending}}
 vm.runInNewContext(script,{window,navigator,location,URL,Date,Promise,sessionStorage:{getItem:key=>storage.get(key),setItem:(key,value)=>storage.set(key,value)}})
 const fire=(name,event={})=>{for(const fn of listeners[name]??[])fn(event)}
 return {fire,location,replacements,release:()=>release([]),error:()=>fire('error',{message:'Importing a module script failed'})}
}
const settle=()=>new Promise(resolve=>setImmediate(resolve))
test('a real module failure still repairs the current page once',async()=>{
 const f=fixture();f.error();f.error();f.release();await settle()
 assert.equal(f.replacements.length,1)
 const url=new URL(f.replacements[0]);assert.equal(url.pathname,'/profil');assert.ok(Number(url.searchParams.get('recovery'))>0)
})
for(const event of ['beforeunload','pagehide']){
 test(`an asset cancellation during ${event} cannot start recovery`,async()=>{
  const f=fixture();f.fire(event);f.error();f.release();await settle();assert.deepEqual(f.replacements,[])
 })
 test(`pending recovery cannot replace a document leaving via ${event}`,async()=>{
  const f=fixture();f.error();f.fire(event);f.release();await settle();assert.deepEqual(f.replacements,[])
 })
}
test('a client-side route change is not overwritten after cleanup',async()=>{
 const f=fixture();f.error();f.location.href='https://leryko.example/revision/historique';f.release();await settle();assert.deepEqual(f.replacements,[])
})
test('a page restored from the back-forward cache can recover',async()=>{
 const f=fixture();f.fire('pagehide');f.fire('pageshow');f.error();f.release();await settle();assert.equal(f.replacements.length,1)
})
test('offline failures never erase caches or reload',async()=>{
 const f=fixture({offline:true});f.error();f.release();await settle();assert.deepEqual(f.replacements,[])
})
