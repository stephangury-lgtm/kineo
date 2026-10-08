import { test,expect } from '@playwright/test'

test.describe.configure({retries:0})

const base=(process.env.KINEO_E2E_BASE_URL||'http://127.0.0.1:4173').replace(/\/$/,'')
const email=process.env.KINEO_E2E_EMAIL
const password=process.env.KINEO_E2E_PASSWORD
const friendEmail=process.env.KINEO_E2E_FRIEND_EMAIL
const friendPassword=process.env.KINEO_E2E_FRIEND_PASSWORD
const friendUsername=process.env.KINEO_E2E_FRIEND_USERNAME

async function login(page,emailValue,passwordValue){
 await page.goto(base,{waitUntil:'domcontentloaded'})
 await page.getByLabel('E-mail').fill(emailValue)
 await page.locator('input[type="password"]').fill(passwordValue)
 await page.getByRole('button',{name:'Se connecter'}).click()
 await expect(page.locator('.bottom-nav')).toBeVisible({timeout:20000})
}

async function gotoStable(page,path){
 const target=base+path
 for(let attempt=0;attempt<3;attempt++){
  try{
   await page.goto(target,{waitUntil:'domcontentloaded'})
   await expect(page).toHaveURL(target,{timeout:10000})
   await page.waitForLoadState('load').catch(()=>undefined)
   await page.waitForTimeout(400)
   return
  }catch(error){
   if(attempt===2)throw error
   await page.waitForTimeout(500)
  }
 }
}

async function program(page,id,level,curriculum='default'){
 await page.evaluate(({id,level,curriculum})=>{
  localStorage.setItem('healthapp_program',id)
  localStorage.setItem('healthapp_level_'+id,level)
  localStorage.setItem('healthapp_curriculum_'+id,curriculum)
 },{id,level,curriculum})
 await gotoStable(page,'/parcours')
 await expect(page.locator('.bottom-nav')).toBeVisible()
}

async function assertIfsiScopedRevisionLinks(page,level){
 const semester=page.getByRole('link',{name:new RegExp('Réviser tout le semestre '+level)})
 await expect(semester).toBeVisible({timeout:15000})
 expect(await semester.getAttribute('href')).toContain('scope=semester')
 const toggles=page.locator('.curriculum-unit-toggle')
 for(let i=0;i<await toggles.count();i++){
  await toggles.nth(i).click()
  const opened=page.locator('.curriculum-unit.open')
  const unitRevision=opened.locator('.unit-revision-cta a').first()
  const empty=opened.locator('.curriculum-empty')
  await Promise.race([
   unitRevision.waitFor({state:'visible',timeout:5000}).catch(()=>undefined),
   empty.waitFor({state:'visible',timeout:5000}).catch(()=>undefined),
  ])
  if(await unitRevision.isVisible().catch(()=>false)){
   expect(await unitRevision.getAttribute('href')).toContain('scope=unit')
   await toggles.nth(i).click()
   return
  }
 }
 throw new Error('No IFSI UE revision link found')
}

async function openCurriculumQuiz(page){
 const toggles=page.locator('.curriculum-unit-toggle')
 await expect(toggles.first()).toBeVisible({timeout:15000})
 for(let i=0;i<await toggles.count();i++){
  await toggles.nth(i).click()
  const opened=page.locator('.curriculum-unit.open')
  const link=opened.locator('.curriculum-topic-actions a.primary-button').first()
  const empty=opened.locator('.curriculum-empty')
  await Promise.race([
   link.waitFor({state:'visible',timeout:5000}).catch(()=>undefined),
   empty.waitFor({state:'visible',timeout:5000}).catch(()=>undefined),
  ])
  if(await link.isVisible().catch(()=>false)){
   const destination=await link.getAttribute('href')
   if(!destination)throw new Error('Curriculum revision link has no destination')
   await gotoStable(page,destination)
   await expect(page.locator('#qcm')).toBeVisible({timeout:15000})
   return
  }
 }
 throw new Error('No accessible curriculum quiz found')
}

async function answerOneCurriculumQuestion(page){
 const card=page.locator('.curriculum-quiz-card').first()
 if(!await card.isVisible().catch(()=>false)){
  const preparing=page.locator('#qcm .admin-empty').first()
  await expect(preparing).toBeVisible({timeout:7000})
  await expect(preparing).toContainText(/10/)
  return false
 }
 const radio=card.locator('input[type="radio"]').first()
 const input=card.locator('input.text-input').first()
 const select=card.locator('.matching-row select').first()
 const hotspot=card.locator('button[aria-label]').first()
 if(await radio.count())await radio.check()
 else if(await input.count())await input.fill('e2e')
 else if(await select.count())await select.selectOption({index:1})
 else if(await hotspot.count())await hotspot.click()
 else throw new Error('Unsupported curriculum question')
 const validate=card.locator('button.primary-button').filter({hasText:/Valider|Validar/}).first()
 await expect(validate).toBeEnabled()
 await validate.click()
 await expect(card.locator('.curriculum-feedback')).toBeVisible({timeout:10000})
 return true
}

test('single-login authenticated critical journey',async({page,browser})=>{
 test.setTimeout(180000)
 if(!email||!password||!friendEmail||!friendPassword||!friendUsername)throw new Error('Missing E2E credentials')
 await login(page,email,password)

 await program(page,'kineo-fr','K2')
 await gotoStable(page,'/quiz')
 await expect(page.getByRole('button',{name:'Commencer'})).toBeVisible()
 await gotoStable(page,'/amis')
 const friend=page.locator('.person-row').filter({hasText:'@'+friendUsername}).first()
 await expect(friend).toBeVisible({timeout:15000})
 const duel=friend.locator('button.duel-button')
 if(await duel.isEnabled())await duel.click()
 await expect(page.locator('.challenge-row').first()).toBeVisible({timeout:15000})

 const friendContext=await browser.newContext()
 const friendPage=await friendContext.newPage()
 await login(friendPage,friendEmail,friendPassword)
 await program(friendPage,'kineo-fr','K2')
 await gotoStable(friendPage,'/amis')
 const incoming=friendPage.locator('.challenge-row').filter({has:friendPage.getByRole('button',{name:'Accepter'})}).first()
 if(await incoming.count())await incoming.getByRole('button',{name:'Accepter'}).click()
 await expect(friendPage.locator('.challenge-row').first()).toBeVisible({timeout:15000})
 await friendContext.close()

 for(const route of ['/stats','/rewards','/classement','/profil','/notifications']){
  await gotoStable(page,route)
  await expect(page.locator('.app-shell')).toBeVisible()
  await expect(page.locator('body')).not.toContainText('Une erreur est survenue')
 }

 await gotoStable(page,'/')
 await page.locator('.feedback-fab').click()
 const dialog=page.getByRole('dialog')
 await expect(dialog).toBeVisible()
 await dialog.locator('.feedback-kind').filter({hasText:'Suggestion'}).click()
 await page.locator('#feedback-message').fill('Test E2E automatique.')
 await page.getByRole('button',{name:'Envoyer le retour'}).click()
 await expect(page.getByText('Merci, retour enregistré.')).toBeVisible({timeout:10000})

 await program(page,'ifsi-fr','S2','2009')
 await expect(page.locator('select.text-answer')).toHaveValue('S2',{timeout:15000})
 await expect(page.locator('select.text-answer option').filter({hasText:/^S1/})).toHaveCount(1,{timeout:15000})
 const labels=await page.locator('select.text-answer option').allTextContents()
 expect(labels.some(v=>v.startsWith('S1'))).toBeTruthy()
 expect(labels.some(v=>v.startsWith('S2'))).toBeTruthy()
 expect(labels.some(v=>v.startsWith('S3'))).toBeFalsy()
 await assertIfsiScopedRevisionLinks(page,'S2')
 await openCurriculumQuiz(page)
 await answerOneCurriculumQuestion(page)

 await program(page,'kineo-es','ES1')
 await expect(page.locator('select.text-answer')).toHaveValue('ES1',{timeout:15000})
 await expect(page.getByText('Elige un nivel accesible')).toBeVisible({timeout:15000})
 await openCurriculumQuiz(page)
 await answerOneCurriculumQuestion(page)
 await gotoStable(page,'/rewards')
 await expect(page.getByText('Colección')).toBeVisible()
})
