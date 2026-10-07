import { test,expect } from '@playwright/test'

const base=(process.env.KINEO_E2E_BASE_URL||'https://kineo.stephangury.workers.dev').replace(/\/$/,'')
const account=process.env.KINEO_E2E_EMAIL
const secret=process.env.KINEO_E2E_PASSWORD
const friendUsername=process.env.KINEO_E2E_FRIEND_USERNAME

async function signIn(page){
 if(!account||!secret)throw new Error('Missing E2E account')
 await page.goto(base,{waitUntil:'networkidle'})
 await page.getByLabel('E-mail').fill(account)
 await page.locator('input[type="password"]').fill(secret)
 await page.getByRole('button',{name:'Se connecter'}).click()
 await expect(page.locator('.bottom-nav')).toBeVisible({timeout:15000})
}

async function useProgram(page,program,level,curriculum='default'){
 await page.evaluate(({program,level,curriculum})=>{
  localStorage.setItem('healthapp_program',program)
  localStorage.setItem('healthapp_level_'+program,level)
  localStorage.setItem('healthapp_curriculum_'+program,curriculum)
 },{program,level,curriculum})
 await page.goto(base+'/parcours',{waitUntil:'networkidle'})
}

async function answerFirstFranceRevisionQuestion(page){
 await page.goto(base+'/revision',{waitUntil:'networkidle'})
 const start=page.getByRole('button',{name:'Commencer'})
 if(await start.count())await start.click()
 const card=page.locator('.quiz-card')
 await expect(card).toBeVisible({timeout:12000})
 const choices=card.locator('.answers .answer')
 const text=card.locator('.text-answer')
 const selects=card.locator('.matching-row select')
 if(await choices.count())await choices.first().click()
 else if(await text.count())await text.first().fill('e2e')
 else if(await selects.count()){
  for(let i=0;i<await selects.count();i++){
   const select=selects.nth(i)
   if(await select.locator('option').count()>1)await select.selectOption({index:1})
  }
 }else{
  throw new Error('Unsupported France question type in E2E')
 }
 const validate=card.getByRole('button',{name:'Valider ma réponse'})
 await expect(validate).toBeEnabled()
 await validate.click()
 await expect(card.locator('.result-box')).toBeVisible({timeout:10000})
}

test('authenticated France revision, stats, badges and social pages',async({page})=>{
 await signIn(page)
 await useProgram(page,'kineo-fr','K2')
 await expect(page.locator('.bottom-nav')).toBeVisible()
 await answerFirstFranceRevisionQuestion(page)
 await page.goto(base+'/amis',{waitUntil:'networkidle'})
 await expect(page.locator('.app-shell')).toBeVisible()
 if(!friendUsername)throw new Error('Missing E2E friend username')
 const friendRow=page.locator('.person-row').filter({hasText:'@'+friendUsername}).first()
 await expect(friendRow).toBeVisible({timeout:12000})
 const challengeButton=friendRow.locator('button.duel-button')
 await expect(challengeButton).toBeEnabled()
 await challengeButton.click()
 await expect(page.getByText(/Défi Kineo envoyé|Retos en curso|Défis en cours/)).toBeVisible({timeout:10000})
 for(const route of ['/stats','/rewards','/classement','/profil']){
  await page.goto(base+route,{waitUntil:'networkidle'})
  await expect(page.locator('.app-shell')).toBeVisible()
  await expect(page.locator('body')).not.toContainText('Une erreur est survenue')
 }
})

async function openFirstTopicAndCompleteQuiz(page){
 const toggles=page.locator('.curriculum-unit-toggle')
 await expect(toggles.first()).toBeVisible({timeout:12000})
 let opened=false
 for(let i=0;i<await toggles.count();i++){
  await toggles.nth(i).click()
  const unit=page.locator('.curriculum-unit.open').first()
  const link=unit.locator('.curriculum-topic-actions a.primary-button').first()
  try{
   await expect(link).toBeVisible({timeout:4000})
   await link.click()
   opened=true
   break
  }catch{
   if(await toggles.nth(i).getAttribute('aria-expanded')==='true')await toggles.nth(i).click()
  }
 }
 expect(opened).toBeTruthy()
 await expect(page.locator('#qcm')).toBeVisible({timeout:12000})
 const cards=page.locator('.curriculum-quiz-card')
 const total=await cards.count()
 expect(total).toBeGreaterThan(0)
 for(let i=0;i<total;i++){
  const card=cards.nth(i)
  const radios=card.locator('input[type="radio"]')
  const text=card.locator('input.text-input')
  const selects=card.locator('.matching-row select')
  const hotspots=card.locator('button[aria-label]')
  if(await radios.count())await radios.first().check()
  else if(await text.count())await text.first().fill('e2e')
  else if(await selects.count()){
   for(let j=0;j<await selects.count();j++){
    const select=selects.nth(j)
    if(await select.locator('option').count()>1)await select.selectOption({index:1})
   }
  }else if(await hotspots.count())await hotspots.first().click()
  else throw new Error('Unsupported curriculum question type')
  const validate=card.locator('button.primary-button').filter({hasText:/Valider|Validar/}).first()
  await expect(validate).toBeEnabled()
  await validate.click()
  await expect(card.locator('.curriculum-feedback')).toBeVisible({timeout:10000})
 }
 await expect(page.locator('.session-complete')).toBeVisible({timeout:12000})
}

test('authenticated IFSI cumulative access and quiz answer',async({page})=>{
 await signIn(page)
 await useProgram(page,'ifsi-fr','S2','2009')
 await expect(page.locator('select.text-answer')).toHaveValue('S2')
 const labels=await page.locator('select.text-answer option').allTextContents()
 expect(labels.some(v=>v.startsWith('S1'))).toBeTruthy()
 expect(labels.some(v=>v.startsWith('S2'))).toBeTruthy()
 expect(labels.some(v=>v.startsWith('S3'))).toBeFalsy()
 await openFirstTopicAndCompleteQuiz(page)
 await page.goto(base+'/stats',{waitUntil:'networkidle'})
 await expect(page.locator('.stats-hero')).toBeVisible()
})

test('authenticated Spain course, quiz, stats and badges',async({page})=>{
 await signIn(page)
 await useProgram(page,'kineo-es','ES1')
 await expect(page.getByText('Elige un nivel accesible')).toBeVisible()
 await expect(page.locator('select.text-answer')).toHaveValue('ES1')
 await openFirstTopicAndCompleteQuiz(page)
 await page.goto(base+'/stats',{waitUntil:'networkidle'})
 await expect(page.locator('.stats-hero')).toBeVisible()
 await page.goto(base+'/rewards',{waitUntil:'networkidle'})
 await expect(page.getByText('Colección')).toBeVisible()
})
