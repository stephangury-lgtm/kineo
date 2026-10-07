import { test,expect } from '@playwright/test'

const base=(process.env.KINEO_E2E_BASE_URL||'https://kineo.stephangury.workers.dev').replace(/\/$/,'')
const account=process.env.KINEO_E2E_EMAIL
const secret=process.env.KINEO_E2E_PASSWORD

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

test('authenticated France shell',async({page})=>{
 await signIn(page)
 await useProgram(page,'kineo-fr','K2')
 await expect(page.locator('.bottom-nav')).toBeVisible()
})

test('authenticated IFSI cumulative access',async({page})=>{
 await signIn(page)
 await useProgram(page,'ifsi-fr','S2','2009')
 await expect(page.locator('select.text-answer')).toHaveValue('S2')
 const labels=await page.locator('select.text-answer option').allTextContents()
 expect(labels.some(v=>v.startsWith('S1'))).toBeTruthy()
 expect(labels.some(v=>v.startsWith('S3'))).toBeFalsy()
})

test('authenticated Spain shell',async({page})=>{
 await signIn(page)
 await useProgram(page,'kineo-es','ES1')
 await expect(page.getByText('Elige un nivel accesible')).toBeVisible()
 await expect(page.locator('select.text-answer')).toHaveValue('ES1')
})
