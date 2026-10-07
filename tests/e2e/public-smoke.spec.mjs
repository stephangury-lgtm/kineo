import { test, expect } from '@playwright/test'

const base=(process.env.KINEO_E2E_BASE_URL||'http://127.0.0.1:4173').replace(/\/$/,'')
const routes=['/','/parcours','/fondamentaux','/stats','/rewards','/amis','/profil']

test.use({viewport:{width:390,height:844}})

test('mobile shell stays renderable on critical routes',async({page})=>{
 const pageErrors=[]
 page.on('pageerror',error=>pageErrors.push(error.message))
 for(const route of routes){
  const response=await page.goto(`${base}${route}`,{waitUntil:'networkidle'})
  expect(response?.ok(),`${route} should load`).toBeTruthy()
  await expect(page.locator('#root')).toBeVisible()
  const overflow=await page.evaluate(()=>document.documentElement.scrollWidth>document.documentElement.clientWidth+1)
  expect(overflow,`${route} must not overflow horizontally`).toBeFalsy()
 }
 expect(pageErrors).toEqual([])
})

test('PWA assets are valid and service worker is reachable',async({request})=>{
 const manifestResponse=await request.get(`${base}/manifest.webmanifest`)
 expect(manifestResponse.ok()).toBeTruthy()
 const manifest=await manifestResponse.json()
 expect(manifest.display).toBe('standalone')
 expect(manifest.start_url).toBe('/')
 expect(Array.isArray(manifest.icons)&&manifest.icons.length>=2).toBeTruthy()
 for(const icon of manifest.icons){
  const response=await request.get(`${base}${icon.src}`)
  expect(response.ok(),`icon ${icon.src} should load`).toBeTruthy()
 }
 const sw=await request.get(`${base}/sw.js`)
 expect(sw.ok()).toBeTruthy()
 const swText=await sw.text()
 expect(swText).toContain('version.json')
})

test('authentication gate remains usable on small screens',async({page})=>{
 await page.goto(base,{waitUntil:'networkidle'})
 const bodyText=await page.locator('body').innerText()
 expect(bodyText.length).toBeGreaterThan(20)
 const buttons=page.locator('button')
 expect(await buttons.count()).toBeGreaterThan(0)
 const inputs=page.locator('input')
 expect(await inputs.count()).toBeGreaterThan(0)
})
