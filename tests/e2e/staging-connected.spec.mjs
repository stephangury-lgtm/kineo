import {test,expect} from '@playwright/test'
test.describe.configure({retries:0})
test.use({trace:'off',video:'off',screenshot:'off'})
test.skip(process.env.LERYKO_STAGING_ACCEPTANCE!=='1','Requires isolated staging accounts')
const base=process.env.KINEO_E2E_BASE_URL
const backend='https://cyzdivbdgpvhwpmikeqh.supabase.co'
async function login(page){
 await page.goto(base,{waitUntil:'domcontentloaded'})
 await page.getByLabel('E-mail').fill(process.env.KINEO_E2E_EMAIL)
 await page.locator('input[type=password]').fill(process.env.KINEO_E2E_PASSWORD)
 await page.getByRole('button',{name:'Se connecter',exact:true}).click()
 await expect(page.locator('.bottom-nav.v5-navigation')).toBeVisible({timeout:25000})
}
for(const [program,level,version] of [['kineo-fr','K2','default'],['kineo-es','ES1','default'],['ifsi-fr','S2','2009']]){
 test(`connected V5 ${program}: real login, navigation, content and logout`,async({page})=>{
  test.setTimeout(120000)
  expect(base).toBe('https://leryko-v5-staging.stephangury.workers.dev')
  const errors=[],forbidden=[]
  page.on('pageerror',e=>errors.push(e.message))
  await page.route('**/kimtiyuytikyseuzmjbv.supabase.co/**',route=>{forbidden.push(route.request().url());return route.abort()})
  await login(page)
  await page.evaluate(({program,level,version})=>{
   localStorage.setItem('healthapp_program',program)
   localStorage.setItem('healthapp_level_'+program,level)
   localStorage.setItem('healthapp_curriculum_'+program,version)
  },{program,level,version})
  await page.goto(base+'/',{waitUntil:'domcontentloaded'})
  await expect(page.locator('.v5-next-action')).toBeVisible({timeout:20000})
  const nav=page.locator('.bottom-nav.v5-navigation')
  await expect(nav.locator('a')).toHaveCount(5)
  for(const path of ['/parcours','/revision','/progres','/amis','/profil']){
   await page.goto(base+path,{waitUntil:'domcontentloaded'})
   await expect(nav).toBeVisible({timeout:20000})
   await expect(page.locator('body')).not.toContainText('Une erreur est survenue')
  }
  await page.goto(base+'/amis')
  await expect(page.locator('.person-row').filter({hasText:process.env.KINEO_E2E_FRIEND_USERNAME})).toBeVisible({timeout:20000})
  if(program==='kineo-fr'){
   await page.goto(base+'/bibliotheque')
   await page.getByRole('link',{name:/Document synthétique K2/}).click()
   const pdf=page.getByRole('link',{name:'Ouvrir le PDF',exact:true})
   await expect(pdf).toBeVisible({timeout:20000})
   const url=await pdf.getAttribute('href')
   expect(url.startsWith(backend+'/storage/v1/object/sign/documents/')).toBeTruthy()
   const response=await page.request.get(url)
   expect(response.status()).toBe(200)
   expect(response.headers()['content-type']).toContain('application/pdf')
   expect((await response.body()).subarray(0,5).toString()).toBe('%PDF-')
   const anonymous=await page.request.get(backend+'/storage/v1/object/public/documents/staging-fixtures/k2.pdf')
   expect(anonymous.ok()).toBeFalsy()
  }
  await page.goto(base+'/profil')
  await page.getByRole('button',{name:program==='kineo-es'?'Cerrar sesión':'Se déconnecter',exact:true}).click()
  await expect(page.locator('input[type=password]')).toBeVisible({timeout:15000})
  expect(forbidden).toEqual([])
  expect(errors).toEqual([])
 })
}
