import {test,expect} from '@playwright/test'
import {v5Student} from '../fixtures/v5Student.mjs'
const base=(process.env.KINEO_E2E_BASE_URL||'http://127.0.0.1:4173').replace(/\/$/,'')

test.describe('A single correction after submission',()=>{
 test.use({serviceWorkers:'block'})
 for(const type of ['short_answer','mcq']){
  test(`${type}: expected answer appears once and only after submission`,async({page})=>{
   await v5Student(page)
   await page.route('**/rest/v1/rpc/get_quiz_questions_v4',route=>route.fulfill({json:[{id:'question',type,question_text:'Question de recette de correction',difficulty:1,image_url:null,metadata:{},display_order:1,question_options:type==='mcq'?[{id:'right',option_text:'Option attendue',display_order:1},{id:'wrong',option_text:'Autre option',display_order:2}]:[]}]}))
   await page.route('**/rest/v1/rpc/submit_quiz_answer_v5',route=>route.fulfill({json:{submitted:true,correct:false,xp_earned:0,correction:{correct_answer:type==='mcq'?'Option attendue':'Réponse modèle',correct_option_ids:type==='mcq'?['right']:[],explanation:'Explication pédagogique distincte.'}}}))
   await page.goto(base+'/quiz?mode=lesson&session=single-correction&ui=v5')
   await expect(page.getByRole('heading',{name:'Question de recette de correction'})).toBeVisible()
   await expect(page.getByText('Réponse attendue :',{exact:true})).toHaveCount(0)
   await expect(page.getByText('Explication pédagogique distincte.')).toHaveCount(0)
   if(type==='mcq')await page.getByRole('button',{name:'Autre option',exact:true}).click()
   else await page.locator('textarea.text-answer').fill('Réponse à corriger')
   await page.getByRole('button',{name:'Valider ma réponse',exact:true}).click()
   await expect(page.locator('.result-box').getByText('Réponse attendue :',{exact:true})).toHaveCount(1)
   await expect(page.locator('.text-answer-wrap').getByText(/Réponse attendue/)).toHaveCount(0)
   await expect(page.locator('.result-box p').filter({hasText:type==='mcq'?'Option attendue':'Réponse modèle'})).toHaveCount(1)
   await expect(page.getByText('Explication pédagogique distincte.')).toBeVisible()
  })
 }
 test('exam mode keeps the correction hidden even when the response contains it',async({page})=>{
  await v5Student(page)
  await page.route('**/rest/v1/rpc/get_quiz_questions_v4',route=>route.fulfill({json:[{id:'exam-question',type:'short_answer',question_text:'Question examen de recette',difficulty:1,image_url:null,metadata:{},display_order:1,question_options:[]}]}))
  await page.route('**/rest/v1/rpc/submit_quiz_answer_v5',route=>route.fulfill({json:{submitted:true,exam_hidden:true,correction:{correct_answer:'Correction confidentielle examen',explanation:'Explication confidentielle examen'}}}))
  await page.goto(base+'/quiz?mode=exam&session=single-exam&ui=v5')
  await page.locator('textarea.text-answer').fill('Ma réponse examen')
  await page.getByRole('button',{name:'Valider ma réponse',exact:true}).click()
  await expect(page.getByText('Correction confidentielle examen')).toHaveCount(0)
  await expect(page.getByText('Explication confidentielle examen')).toHaveCount(0)
  await expect(page.getByRole('button',{name:'Terminer l’examen',exact:true})).toBeVisible()
 })
})
