import {test,expect} from '@playwright/test'
import {v5Student} from '../fixtures/v5Student.mjs'
const base=(process.env.KINEO_E2E_BASE_URL||'http://127.0.0.1:4173').replace(/\/$/,'')
test.use({serviceWorkers:'block'})
for(const program of ['kineo-fr','kineo-es','ifsi-fr']){
 test(`a stored ${program} session opens without another login`,async({page})=>{
  await v5Student(page,{program})
  await page.goto(base)
  await expect(page.locator('.app-shell')).toBeVisible()
  await expect(page.getByText('Ouverture de ton espace…')).toHaveCount(0)
 })
}
test('a profile request that never responds offers retry and ignores the late response',async({page})=>{
 test.setTimeout(40000)
 await v5Student(page)
 const pending=[]
 let block=true
 await page.route('**/rest/v1/profiles?*',route=>{
  if(block){pending.push(route);return}
  return route.fallback()
 })
 await page.goto(base)
 await expect(page.getByRole('heading',{name:'Profil indisponible'})).toBeVisible({timeout:22000})
 await expect(page.locator('.app-shell')).toHaveCount(0)
 block=false
 await page.getByRole('button',{name:'Réessayer',exact:true}).click()
 await expect(page.locator('.app-shell')).toBeVisible()
 for(const route of pending)await route.fulfill({json:null})
 await expect(page.getByRole('heading',{name:'Profil introuvable'})).toHaveCount(0)
 await expect(page.locator('.app-shell')).toBeVisible()
})
test('an expired session with a stalled refresh leaves a usable retry screen',async({page})=>{
 test.setTimeout(40000)
 await v5Student(page)
 await page.addInitScript(()=>{
  const key='sb-kimtiyuytikyseuzmjbv-auth-token'
  const session=JSON.parse(localStorage.getItem(key))
  session.expires_at=Math.floor(Date.now()/1000)-60
  const parts=session.access_token.split('.')
  const payload=JSON.parse(atob(parts[1]));payload.exp=session.expires_at
  parts[1]=btoa(JSON.stringify(payload)).replace(/=/g,'').replace(/\+/g,'-').replace(/\//g,'_')
  session.access_token=parts.join('.')
  localStorage.setItem(key,JSON.stringify(session))
 })
 await page.route('**/auth/v1/token?*',()=>{})
 await page.goto(base)
 await expect(page.getByRole('heading',{name:'Connexion interrompue'})).toBeVisible({timeout:22000})
 await expect(page.getByRole('button',{name:'Réessayer',exact:true})).toBeEnabled()
 await expect(page.getByRole('button',{name:'Relancer l’application'})).toBeEnabled()
 expect(await page.evaluate(()=>Boolean(localStorage.getItem('sb-kimtiyuytikyseuzmjbv-auth-token')))).toBe(true)
 await expect(page.locator('.app-shell')).toHaveCount(0)
})
