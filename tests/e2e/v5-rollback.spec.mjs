import {test,expect} from '@playwright/test'
import {v5Student} from '../fixtures/v5Student.mjs'
test('installed frontend upgrades to V5 and rolls back to the legacy build',async({page})=>{
 test.skip(process.env.LERYKO_TEST_ROLLBACK!=='1','Requires both candidates and the local rollback harness')
 const base='http://127.0.0.1:4180'
 await v5Student(page)
 await page.goto(base+'/?ui=v5')
 await expect(page.locator('.v5-navigation')).toHaveCount(0)
 await expect(page.locator('.bottom-nav').getByRole('link',{name:'Badges',exact:true})).toBeVisible()
 await page.evaluate(async()=>{await navigator.serviceWorker.ready})
 await expect.poll(()=>page.evaluate(()=>Boolean(navigator.serviceWorker.controller))).toBe(true)
 // Reopen the already-installed app: first installation intentionally avoids a
 // controller-change reload so that an in-flight login is never interrupted.
 await page.reload()
 await expect(page.locator('.bottom-nav').getByRole('link',{name:'Badges',exact:true})).toBeVisible()
 for(const variant of ['v5','legacy']){
  await page.request.post(base+'/__test-release?variant='+variant)
  try{await page.evaluate(async()=>{const registration=await navigator.serviceWorker.getRegistration();await registration.update()})}
  catch(error){if(!String(error).includes('Execution context was destroyed'))throw error}
  await expect(page.locator('.v5-navigation')).toHaveCount(variant==='v5'?1:0)
  await expect.poll(async()=>{
   try{return await page.evaluate(()=>caches.keys())}
   catch(error){if(String(error).includes('Execution context was destroyed'))return [];throw error}
  }).toEqual([expect.stringMatching(new RegExp('-'+variant+'$'))])
  if(variant==='legacy')await expect(page.locator('.bottom-nav').getByRole('link',{name:'Badges',exact:true})).toBeVisible()
 }
})
