import {test,expect} from '@playwright/test'
test.describe.configure({retries:0})
test.use({trace:'off',video:'off',screenshot:'off'})
test.skip(process.env.LERYKO_STAGING_ACCEPTANCE!=='1','Requires isolated staging accounts')
const base=process.env.KINEO_E2E_BASE_URL
const backend='https://cyzdivbdgpvhwpmikeqh.supabase.co'
async function navigate(page,path){
 // Exercise the application's router when its link is available. Repeated
 // document reloads interrupt Auth/RPC requests and do not model tab navigation.
 const internal=page.locator(`a[href="${path}"]:visible`).first()
 if(page.url().startsWith(base+'/')&&await internal.count()){
  await internal.click()
  await expect(page).toHaveURL(base+path)
  await expect(page.locator('#root')).toBeVisible()
  return
 }
 for(let attempt=0;attempt<2;attempt++){
  try{await page.goto(base+path,{waitUntil:'domcontentloaded'});break}
  catch(error){if(attempt||!/NS_BINDING_ABORTED|interrupted by another navigation/.test(String(error)))throw error}
 }
 // Background profile/realtime requests may remain active. The caller checks
 // the actual screen and content rather than waiting for global network silence.
 await expect(page.locator('#root')).toBeVisible()
}
async function login(page,email=process.env.KINEO_E2E_EMAIL,password=process.env.KINEO_E2E_PASSWORD){
 await navigate(page,'/')
 await page.getByLabel('E-mail').fill(email)
 await page.locator('input[type=password]').fill(password)
 await page.getByRole('button',{name:'Se connecter',exact:true}).click()
 await expect(page.locator('.bottom-nav.v5-navigation')).toBeVisible({timeout:25000})
}
for(const [program,level,version] of [['kineo-fr','K2','default'],['kineo-es','ES1','default'],['ifsi-fr','S2','2009']]){
 test(`connected V5 ${program}: real login, navigation, content and logout`,async({page,browser})=>{
  test.setTimeout(120000)
  expect(base).toBe('https://leryko-v5-staging.stephangury.workers.dev')
  const errors=[],forbidden=[]
  await page.addInitScript(({origin,program,level,version})=>{
   if(location.origin!==origin)return
   localStorage.setItem('healthapp_program',program)
   localStorage.setItem('healthapp_level_'+program,level)
   localStorage.setItem('healthapp_curriculum_'+program,version)
  },{origin:base,program,level,version})
  page.on('pageerror',e=>errors.push(e.message))
  await page.route('**/kimtiyuytikyseuzmjbv.supabase.co/**',route=>{forbidden.push(route.request().url());return route.abort()})
  await login(page)
  await navigate(page,'/')
  await expect(page.locator('.v5-next-action')).toBeVisible({timeout:20000})
  const nav=page.locator('.bottom-nav.v5-navigation')
  await expect(nav.locator('a')).toHaveCount(5)
  for(const path of ['/parcours','/revision','/progres','/amis','/profil']){
   await navigate(page,path)
   await expect(nav).toBeVisible({timeout:20000})
   await expect(page.locator('body')).not.toContainText('Une erreur est survenue')
  }
  await navigate(page,'/amis')
  await expect(page.getByRole('button',{name:program==='kineo-es'?'Compartir la aplicación':'Partager l’application',exact:true})).toBeVisible({timeout:20000})
  await expect(page.locator('.person-row').filter({hasText:process.env.KINEO_E2E_FRIEND_USERNAME})).toBeVisible({timeout:20000})
  const friend=page.locator('.person-row').filter({hasText:process.env.KINEO_E2E_FRIEND_USERNAME})
  const duel=friend.locator('button.duel-button')
  await expect(duel).toBeEnabled({timeout:20000})
  await duel.click()
  const challengeTab=page.getByRole('button',{name:program==='kineo-es'?/^Retos ·/:/^Défis ·/})
  await expect(challengeTab).toHaveAttribute('aria-pressed','true',{timeout:20000})
  const sent=page.locator('.challenge-row').first()
  await expect(sent).toBeVisible({timeout:20000})
  const recipientContext=await browser.newContext()
  try{
   await recipientContext.addInitScript(({origin,program,level,version})=>{
    if(location.origin!==origin)return
    localStorage.setItem('healthapp_program',program)
    localStorage.setItem('healthapp_level_'+program,level)
    localStorage.setItem('healthapp_curriculum_'+program,version)
   },{origin:base,program,level,version})
   const recipient=await recipientContext.newPage()
   await recipient.route('**/kimtiyuytikyseuzmjbv.supabase.co/**',route=>{forbidden.push(route.request().url());return route.abort()})
   recipient.on('pageerror',e=>errors.push(e.message))
   await login(recipient,process.env.KINEO_E2E_FRIEND_EMAIL,process.env.KINEO_E2E_FRIEND_PASSWORD)
   await navigate(recipient,'/amis')
   const receivedTab=recipient.getByRole('button',{name:program==='kineo-es'?/^Retos ·/:/^Défis ·/})
   await expect(receivedTab).toBeVisible({timeout:20000})
   await receivedTab.click()
   await expect(recipient.locator('.challenge-row').getByRole('button',{name:program==='kineo-es'?'Aceptar':'Accepter',exact:true})).toBeVisible({timeout:20000})
  }finally{await recipientContext.close()}
  await sent.getByRole('button',{name:program==='kineo-es'?'Cancelar':'Annuler',exact:true}).click({timeout:20000})
  await expect(sent).toHaveCount(0,{timeout:20000})
  if(program==='kineo-fr'){
   await navigate(page,'/bibliotheque')
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
  await navigate(page,'/profil')
  await page.getByRole('button',{name:program==='kineo-es'?'Cerrar sesión':'Se déconnecter',exact:true}).click()
  await expect(page.locator('input[type=password]')).toBeVisible({timeout:15000})
  expect(forbidden).toEqual([])
  expect(errors).toEqual([])
 })
}


