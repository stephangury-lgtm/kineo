import {test,expect} from '@playwright/test'
import {v5Student} from '../fixtures/v5Student.mjs'
const base=process.env.KINEO_E2E_BASE_URL||'http://127.0.0.1:4173'
test.use({serviceWorkers:'block'})
test.skip(process.env.LERYKO_TEST_V5!=='1','Requires the V5 candidate')
for(const program of ['kineo-fr','kineo-es','ifsi-fr'])for(const width of [320,390])test(`GURIKO identity ${program} ${width}px`,async({page})=>{
 await page.setViewportSize({width,height:844});await v5Student(page,{program})
 await page.goto(base+'/?ui=v5')
 const home=page.getByRole('link',{name:program==='kineo-es'?'GURIKO, volver al inicio':'GURIKO, retour à l’accueil',exact:true})
 await expect(home).toBeVisible();await expect(home).toContainText('GURIKO')
 const mascot=page.locator('.guriko-mascot__image');await expect(mascot).toBeVisible()
 await expect(mascot).toHaveAttribute('src','/icons/guriko-192.png')
 await mascot.evaluate(i=>i.decode());expect(await mascot.evaluate(i=>i.naturalWidth)).toBe(192)
 const layout=await page.evaluate(()=>{
  const card=document.querySelector('.ritual-hero').getBoundingClientRect(),row=document.querySelector('.ritual-hero .guriko-mascot').getBoundingClientRect(),image=document.querySelector('.guriko-mascot__image').getBoundingClientRect(),logo=document.querySelector('.brand-logo img').getBoundingClientRect()
  return {mascotWidth:image.width,logoWidth:logo.width,centerOffset:Math.abs((row.left+row.right-card.left-card.right)/2)}
 })
 expect(layout.mascotWidth).toBeGreaterThanOrEqual(88)
 expect(layout.logoWidth).toBeGreaterThanOrEqual(40)
 expect(layout.centerOffset).toBeLessThanOrEqual(1)
 await expect(page.locator('.v5-next-action a.primary-button')).toBeVisible()
 await expect(page.locator('.v5-navigation a')).toHaveCount(5)
 expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1)).toBe(true)
 await page.locator('.v5-navigation a[href="/amis"]').click()
 await expect(page.getByRole('heading',{name:program==='kineo-es'?'Compartir GURIKO':'Partager GURIKO'})).toBeVisible()
 await home.click();await expect(mascot).toBeVisible()
 if(process.env.GURIKO_SCREENSHOT_DIR)await page.screenshot({path:process.env.GURIKO_SCREENSHOT_DIR+'/'+program+'-'+width+'.png',fullPage:true})
})
