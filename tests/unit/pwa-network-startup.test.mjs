import test from 'node:test'
import assert from 'node:assert/strict'
import {readFileSync} from 'node:fs'
import vm from 'node:vm'
const source=readFileSync(new URL('../../public/sw.js',import.meta.url),'utf8')
function fixture(fetch){
 const listeners={},timers=new Map(),cached=new Map(),calls=[],puts=[]
 const context={Response,URL,Promise,Error,AbortController,clearTimeout:id=>timers.delete(id),setTimeout:fn=>{timers.set(fn,fn);return fn},
  self:{location:{origin:'https://guriko.test'},addEventListener:(name,fn)=>{listeners[name]=fn}},
  fetch:(...args)=>{calls.push(args);return fetch(...args)},
  caches:{match:async key=>cached.get(typeof key==='string'?key:new URL(key.url).pathname),open:async()=>({put:async(key)=>{puts.push(key)}})}}
 vm.runInNewContext(source,context)
 function request(path,{destination='',mode='navigate'}={}){
  let response
  listeners.fetch({request:{method:'GET',url:'https://guriko.test'+path,mode,destination},respondWith:promise=>{response=promise},waitUntil:()=>{}})
  return response
 }
 return{request,cached,calls,puts,expire:()=>{for(const fn of [...timers.values()])fn()}}
}
test('a never-ending navigation falls back to the cached shell within the deadline',async()=>{
 const f=fixture(()=>new Promise(()=>{}))
 f.cached.set('/',new Response('cached application'))
 const pending=f.request('/amis')
 f.expire()
 assert.equal(await(await pending).text(),'cached application')
 assert.equal(f.calls[0][1].signal.aborted,true)
})
test('hashed startup scripts and CSS open from cache without waiting on the network',async()=>{
 const f=fixture(()=>{throw new Error('Network must not be needed')})
 for(const destination of ['script','style']){
  const path='/assets/index-hash.'+(destination==='script'?'js':'css')
  f.cached.set(path,new Response('cached asset'))
  assert.equal(await(await f.request(path,{mode:'cors',destination})).text(),'cached asset')
 }
 assert.equal(f.calls.length,0)
})
test('a server error also falls back to the usable shell',async()=>{
 const f=fixture(async()=>new Response('unavailable',{status:503}))
 f.cached.set('/',new Response('cached application'))
 assert.equal(await(await f.request('/')).text(),'cached application')
})
test('a cold launch without cache gives an explicit offline response after a stalled request',async()=>{
 const f=fixture(()=>new Promise(()=>{}))
 const pending=f.request('/')
 f.expire()
 assert.equal((await pending).status,503)
})

for(const path of ['/repair.html','/repair'])test(`opening ${path} never replaces the cached application shell`,async()=>{
 const f=fixture(async()=>new Response('repair page'))
 await f.request(path)
 await new Promise(resolve=>setImmediate(resolve))
 assert.deepEqual(f.puts,['/repair.html'])
})

function redirectedResponse(){
 const response=new Response('redirected page',{headers:{'Content-Type':'text/html','X-Content-Type-Options':'nosniff'}})
 Object.defineProperty(response,'redirected',{value:true})
 return response
}
test('a followed navigation redirect becomes a readable response without the redirect flag',async()=>{
 const f=fixture(async()=>redirectedResponse())
 const response=await f.request('/repair.html')
 assert.equal(response.redirected,false)
 assert.equal(response.headers.get('X-Content-Type-Options'),'nosniff')
 assert.equal(await response.text(),'redirected page')
})
test('an older cached redirected response is safe to render offline',async()=>{
 const f=fixture(async()=>{throw new Error('offline')})
 f.cached.set('/',redirectedResponse())
 const response=await f.request('/')
 assert.equal(response.redirected,false)
 assert.equal(await response.text(),'redirected page')
})
