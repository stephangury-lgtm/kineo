import {test,expect} from '@playwright/test'
import {v5Student} from '../fixtures/v5Student.mjs'
import {coursePdf} from '../fixtures/coursePdf.mjs'
import {readFileSync} from 'node:fs'
const base=(process.env.KINEO_E2E_BASE_URL||'http://127.0.0.1:4173').replace(/\/$/,'')
test.use({serviceWorkers:'block'})
async function setup(page,{invalid=false,body,program='kineo-fr',hold}={}){
 await v5Student(page,{program})
 await page.route('**/rest/v1/rpc/get_course_document_v1',route=>route.fulfill({json:{id:'course',title:'Cours anatomie',storage_path:'courses/test.pdf'}}))
 await page.route('**/storage/v1/object/sign/documents/**',async route=>{
  if(route.request().method()==='POST')return route.fulfill({json:{signedURL:'/object/sign/documents/courses/test.pdf?token=test'}})
  if(hold)await hold
  await route.fulfill({contentType:'application/pdf',body:body??(invalid?Buffer.from('invalid pdf'):coursePdf())}).catch(()=>{})
 })
 await page.goto(base+'/document/course?ui=v5')
}
test('renders private PDF pixels and navigates pages without a native viewer',async({page})=>{
 await setup(page)
 const canvas=page.getByRole('img',{name:'Cours anatomie — page 1'})
 await expect(canvas).toBeVisible()
 await expect(page.getByText('Page 1 / 2',{exact:true})).toBeVisible()
 expect(await canvas.evaluate(node=>node.getContext('2d').getImageData(0,0,node.width,node.height).data.some((value,index)=>index%4!==3&&value<100))).toBe(true)
 await expect(page.locator('iframe')).toHaveCount(0)
 await page.getByRole('button',{name:'Suivante',exact:true}).click()
 await expect(page.getByRole('img',{name:'Cours anatomie — page 2'})).toBeVisible()
 await page.getByText('Texte de la page',{exact:true}).click()
 await expect(page.locator('.pdf-page-text p')).toContainText('page deux')
 await page.getByRole('combobox',{name:'Taille'}).selectOption('2')
 await expect(page.getByRole('img',{name:'Cours anatomie — page 2'})).toBeVisible()
 expect(await page.evaluate(()=>document.documentElement.scrollWidth<=window.innerWidth)).toBe(true)
 await expect(page.getByRole('button',{name:'Suivante',exact:true})).toBeDisabled()
})
test('invalid PDF gives an actionable error while preserving signed access link',async({page})=>{
 await setup(page,{invalid:true})
 await expect(page.getByRole('alert')).toContainText('Cette page ne peut pas être affichée')
 await expect(page.getByRole('link',{name:'Ouvrir le PDF'})).toHaveAttribute('href',/\/sign\/documents\//)
 await expect(page.getByRole('button',{name:'Actualiser l’accès'})).toBeVisible()
})
test('stalled document stops loading and retains recovery actions',async({page})=>{
 await page.clock.install()
 let release
 const hold=new Promise(resolve=>{release=resolve})
 try{
  await setup(page,{hold})
  await expect(page.getByRole('status')).toContainText('Chargement de la page')
  await page.clock.fastForward(31000)
  await expect(page.getByRole('alert')).toContainText('Cette page ne peut pas être affichée')
  await expect(page.getByRole('button',{name:'Actualiser l’accès'})).toBeVisible()
 }finally{release()}
})
for(const program of ['kineo-es','ifsi-fr'])test(`course reader follows ${program} language and layout`,async({page})=>{
 await setup(page,{program})
 const spain=program==='kineo-es'
 await expect(page.getByRole('img',{name:'Cours anatomie — page 1'})).toBeVisible()
 await expect(page.getByRole('button',{name:spain?'Siguiente':'Suivante',exact:true})).toBeVisible()
 await expect(page.getByRole('link',{name:spain?'Abrir el PDF':'Ouvrir le PDF',exact:true})).toBeVisible()
 expect(await page.evaluate(()=>document.documentElement.scrollWidth<=window.innerWidth)).toBe(true)
})
test('reported local course renders under production content security policy',async({page})=>{
 test.skip(!process.env.LERYKO_LOCAL_PDF_PATH,'Requires the local original; no course is committed to the test repository')
 const csp=readFileSync('public/_headers','utf8').split('\n').find(line=>line.includes('Content-Security-Policy:')).split('Content-Security-Policy:')[1].trim().replace('; upgrade-insecure-requests','')
 await page.route(base+'/document/**',async route=>{
  const response=await route.fetch()
  await route.fulfill({response,headers:{...response.headers(),'content-security-policy':csp}})
 })
 await setup(page,{body:readFileSync(process.env.LERYKO_LOCAL_PDF_PATH)})
 await expect(page.getByRole('img',{name:'Cours anatomie — page 1'})).toBeVisible({timeout:20000})
 await expect(page.getByRole('alert')).toHaveCount(0)
 await page.getByRole('button',{name:'Suivante',exact:true}).click()
 await expect(page.getByRole('img',{name:'Cours anatomie — page 2'})).toBeVisible({timeout:20000})
})
