import {test,expect} from '@playwright/test'
import {v5Student} from '../fixtures/v5Student.mjs'
const base=(process.env.KINEO_E2E_BASE_URL||'http://127.0.0.1:4173').replace(/\/$/,'')
test.use({serviceWorkers:'block'})
test('resumed session keeps original question numbers and does not resubmit completed answers',async({page})=>{
 await v5Student(page,{active:{id:'resume-progress',mode:'smart',question_count:3,answered_count:1}})
 await page.route('**/rest/v1/rpc/get_quiz_questions_v4',route=>route.fulfill({json:[2,3].map(n=>({id:'remaining-'+n,type:'mcq',question_text:'Question restante '+n,difficulty:1,metadata:{},display_order:n,question_options:[{id:'answer-'+n,option_text:'Réponse '+n,display_order:1}]}))}))
 const submissions=[]
 await page.route('**/rest/v1/rpc/submit_quiz_answer_v5',route=>{
  submissions.push(route.request().postDataJSON().p_question_id)
  return route.fulfill({json:{submitted:true,correct:true,xp_earned:0,correction:{correct_option_ids:['answer-2'],explanation:'Correction de la question reprise'}}})
 })
 await page.goto(base+'/?ui=v5')
 await page.getByRole('link',{name:'Reprendre ma séance',exact:true}).click()
 await expect(page.getByRole('heading',{name:'Question 2 sur 3',exact:true})).toBeVisible()
 await expect(page.getByText('Question restante 1',{exact:true})).toHaveCount(0)
 await page.getByRole('button',{name:'Réponse 2',exact:true}).click()
 await page.getByRole('button',{name:'Valider ma réponse',exact:true}).click()
 await expect(page.getByText('Correction de la question reprise')).toBeVisible()
 await page.getByRole('button',{name:'Question suivante',exact:true}).click()
 await expect(page.getByRole('heading',{name:'Question 3 sur 3',exact:true})).toBeVisible()
 expect(submissions).toEqual(['remaining-2'])
})
