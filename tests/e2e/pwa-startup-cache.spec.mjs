import {test,expect} from '@playwright/test'
import {createServer} from 'node:http'
import {readFile} from 'node:fs/promises'
import {extname,resolve} from 'node:path'
let server,base,stallAssets=false,originUnavailable=false,unavailableRequests=0
const sockets=new Set()
const mime={'.html':'text/html','.js':'text/javascript','.css':'text/css','.png':'image/png','.svg':'image/svg+xml','.json':'application/json','.webmanifest':'application/manifest+json'}
test.beforeAll(async()=>{
 server=createServer(async(req,res)=>{
  if(originUnavailable){unavailableRequests++;res.destroy();return}
  const url=new URL(req.url,'http://localhost')
  if(url.searchParams.get('stallNavigation')==='1'||(stallAssets&&url.pathname.startsWith('/assets/')))return
  // Cloudflare canonicalizes .html URLs. Exercise that redirect with an
  // already installed worker instead of only testing Vite's direct file route.
  if(url.pathname==='/repair.html'){res.writeHead(301,{Location:'/repair'});res.end();return}
  const path=resolve('dist','.'+(url.pathname==='/repair'?'/repair.html':url.pathname))
  try{
   const data=await readFile(path)
   res.writeHead(200,{'Content-Type':mime[extname(path)]||'application/octet-stream','Cache-Control':'no-store'});res.end(data)
  }catch{
   if(extname(url.pathname)){res.writeHead(404);res.end();return}
   res.writeHead(200,{'Content-Type':'text/html','Cache-Control':'no-store'});res.end(await readFile('dist/index.html'))
  }
 })
 server.on('connection',socket=>{sockets.add(socket);socket.on('close',()=>sockets.delete(socket))})
 await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve))
 base='http://127.0.0.1:'+server.address().port
})
test.afterAll(async()=>{for(const socket of sockets)socket.destroy();await new Promise(resolve=>server.close(resolve))})
test.beforeEach(()=>{stallAssets=false;originUnavailable=false;unavailableRequests=0})
async function install(page){
 await page.route('https://kimtiyuytikyseuzmjbv.supabase.co/**',route=>route.fulfill({json:[]}))
 await page.goto(base)
 await expect(page.getByRole('button',{name:'Se connecter',exact:true})).toBeVisible()
 await page.evaluate(()=>navigator.serviceWorker.ready)
 await expect.poll(()=>page.evaluate(()=>Boolean(navigator.serviceWorker.controller))).toBe(true)
}
test('installed app leaves the launch screen even when navigation and startup asset network requests stall',async({page})=>{
 await install(page)
 stallAssets=true
 await page.goto(base+'/amis?stallNavigation=1',{waitUntil:'domcontentloaded',timeout:12000})
 await expect(page.getByRole('button',{name:'Se connecter',exact:true})).toBeVisible()
 await expect(page.locator('#startup-help')).toHaveCount(0)
})
test('independent repair removes only app shell caches and preserves stored account and learning data',async({page})=>{
 await install(page)
 await page.evaluate(async()=>{
  localStorage.setItem('repair-test-progress','kept')
  sessionStorage.setItem('repair-test-session','kept')
  await caches.open('unrelated-cache')
 })
 await page.goto(base+'/repair.html')
 await expect(page.getByRole('heading',{name:'Relançons GURIKO'})).toBeVisible()
 await page.getByRole('button',{name:'Réparer et ouvrir GURIKO'}).click()
 await expect(page).toHaveURL(/[?]repaired=\d+/)
 await expect(page.getByRole('button',{name:'Se connecter',exact:true})).toBeVisible()
 const saved=await page.evaluate(async()=>({progress:localStorage.getItem('repair-test-progress'),session:sessionStorage.getItem('repair-test-session'),otherCache:(await caches.keys()).includes('unrelated-cache')}))
 expect(saved).toEqual({progress:'kept',session:'kept',otherCache:true})
})

test('startup and repair instructions match the real device platform',async({page,browserName})=>{
 test.skip(browserName==='firefox','Mobile instructions are exercised on Pixel and iPhone projects')
 const ios=browserName==='webkit'
 await page.route('**/assets/*.js',()=>{})
 const navigation=page.goto(base,{waitUntil:'commit'})
 await navigation
 await expect(page.locator('#startup-help')).toContainText(ios?'Sur iPhone/iPad':'Sur Android')
 await expect(page.locator('#startup-help')).toContainText(ios?'Safari':'Chrome')
 await expect(page.locator('#startup-help')).not.toContainText(ios?'Chrome':'Safari')
 await page.goto(base+'/repair.html')
 await expect(page.locator('#device-guidance')).toContainText(ios?'Sur iPhone/iPad':'Sur Android')
 await expect(page.locator('#device-guidance')).toContainText(ios?'Safari':'Chrome')
 await expect(page.locator('#device-guidance')).not.toContainText(ios?'Chrome':'Safari')
})

test('installed app opens a canonicalized repair page online and during an origin outage',async({page})=>{
 await install(page)
 await page.goto(base+'/repair.html',{waitUntil:'domcontentloaded'})
 await expect(page.getByRole('heading',{name:'Relançons GURIKO'})).toBeVisible()
 await expect(page.locator('link[rel="apple-touch-icon"]')).toHaveAttribute('href','/icons/guriko-v2-180.png')
 // Drop real origin connections. Browser offline switches can suppress the
 // worker's response in Firefox/WebKit before its fallback is even evaluated.
 originUnavailable=true
 try{
  await page.reload({waitUntil:'domcontentloaded'})
  await expect(page.getByRole('heading',{name:'Relançons GURIKO'})).toBeVisible()
  await page.goto(base+'/repair',{waitUntil:'domcontentloaded'})
  await expect(page.getByRole('heading',{name:'Relançons GURIKO'})).toBeVisible()
  expect(unavailableRequests).toBeGreaterThan(0)
 }finally{originUnavailable=false}
})
