import {test,expect} from '@playwright/test'
import {v5Student} from '../fixtures/v5Student.mjs'
const base=process.env.KINEO_E2E_BASE_URL||'http://127.0.0.1:4173'
test.use({serviceWorkers:'block'})
for(const answered of [0,1])test(`daily France resumes after ${answered} answers and keeps daily completion`,async({page})=>{
 await v5Student(page)
 await page.route('**/rest/v1/rpc/get_active_daily_revision_session_v1',r=>r.fulfill({json:{id:'daily-fixture',mode:'daily',question_count:2,answered_count:answered}}))
 await page.route('**/rest/v1/rpc/get_quiz_questions_v4',r=>r.fulfill({json:[{id:'daily-question',type:'mcq',question_text:'Question quotidienne',difficulty:1,metadata:{},display_order:answered+1,question_options:[{id:'daily-option',option_text:'Choix quotidien',display_order:1}]}]}))
 await page.route('**/rest/v1/rpc/submit_quiz_answer_v5',r=>r.fulfill({json:{submitted:true,correct:true,xp_earned:1,correction:{correct_option_ids:['daily-option'],explanation:'Correction quotidienne'}}}))
 const finishes=[]
 await page.route('**/rest/v1/rpc/finish_daily_challenge_v2',r=>{finishes.push(r.request().postDataJSON().p_session_id);return r.fulfill({json:{score:100,total_questions:2,correct_count:2,xp_earned:5}})})
 await page.goto(base+'/?ui=v5')
 await page.getByRole('link',{name:'Reprendre ma séance',exact:true}).click()
 await expect(page).toHaveURL(/mode=daily&session=daily-fixture/)
 await expect(page.getByRole('heading',{name:`Question ${answered+1} sur ${answered+1}`})).toBeVisible()
 await page.getByRole('button',{name:'Choix quotidien',exact:true}).click()
 await page.getByRole('button',{name:'Valider ma réponse',exact:true}).click()
 await page.getByRole('button',{name:/Voir mes résultats|Question suivante/}).click()
 expect(finishes).toEqual(['daily-fixture'])
})

