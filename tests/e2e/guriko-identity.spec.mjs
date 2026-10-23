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
 await expect(mascot.locator('image')).toHaveAttribute('href','/branding/guriko-approved-board.png')
 expect(await page.evaluate(async()=>{const i=new Image();i.src='/branding/guriko-approved-board.png';await i.decode();return i.naturalWidth})).toBe(1536)
 const dailyView=await mascot.getAttribute('viewBox')
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
 await expect(page.locator('[data-mascot-state="friends"] svg')).toBeVisible()
 expect(await page.locator('[data-mascot-state="friends"] svg').getAttribute('viewBox')).not.toBe(dailyView)
 expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1)).toBe(true)
 if(process.env.GURIKO_SCREENSHOT_DIR)await page.screenshot({path:process.env.GURIKO_SCREENSHOT_DIR+'/'+program+'-'+width+'-friends.png',fullPage:true})
 await page.goto(base+'/progres');await expect(page.locator('[data-mascot-state="streak"] svg')).toBeVisible()
 expect(await page.locator('[data-mascot-state="streak"] svg').getAttribute('viewBox')).not.toBe(dailyView)
 if(process.env.GURIKO_SCREENSHOT_DIR)await page.screenshot({path:process.env.GURIKO_SCREENSHOT_DIR+'/'+program+'-'+width+'-progress.png',fullPage:true})
 await page.goto(base+'/rewards');await expect(page.locator('[data-mascot-state="badge"] svg')).toBeVisible()
 expect(await page.locator('[data-mascot-state="badge"] svg').getAttribute('viewBox')).not.toBe(dailyView)
 if(process.env.GURIKO_SCREENSHOT_DIR)await page.screenshot({path:process.env.GURIKO_SCREENSHOT_DIR+'/'+program+'-'+width+'-badges.png',fullPage:true})
 await home.click();await expect(mascot).toBeVisible()
 if(process.env.GURIKO_SCREENSHOT_DIR)await page.screenshot({path:process.env.GURIKO_SCREENSHOT_DIR+'/'+program+'-'+width+'.png',fullPage:true})
})

// Computed styles catch fixed blue/green decoration leaking into another curriculum.
for(const program of ['kineo-fr','kineo-es','ifsi-fr'])test(`Curriculum colours follow the active theme across pages: ${program}`,async({page})=>{
 await v5Student(page,{program})
 await page.goto(base+'/?ui=v5')
 const palette=await page.locator('.program-theme').evaluate(el=>{
  const s=getComputedStyle(el)
  return {primary:s.getPropertyValue('--program-primary').trim(),soft:s.getPropertyValue('--program-soft').trim()}
 })
 const resolve=async colour=>page.evaluate(colour=>{
  const el=document.createElement('span');el.style.color=colour;document.body.append(el)
  const value=getComputedStyle(el).color;el.remove();return value
 },colour)
 const primary=await resolve(palette.primary),soft=await resolve(palette.soft)
 const hero=page.locator('.ritual-hero')
 await expect(hero).toBeVisible()
 expect(await hero.evaluate(el=>getComputedStyle(el).backgroundImage)).toContain(primary)
 for(const route of ['/','/progres','/rewards','/amis']){
  await page.goto(base+route+'?ui=v5')
  const symbol=page.locator('.guriko-mascot__symbol').first()
  await expect(symbol).toBeVisible()
  expect(await symbol.evaluate(el=>getComputedStyle(el).backgroundColor)).toBe(soft)
 }
 await page.goto(base+'/revision?ui=v5')
 const quick=page.locator('.revision-hub-option')
 await expect(quick.first()).toBeVisible()
 expect(await quick.count()).toBeGreaterThan(0)
 for(let i=0;i<await quick.count();i++)expect(await quick.nth(i).evaluate(el=>getComputedStyle(el).backgroundImage)).toContain(soft)
})
