import {test,expect} from '@playwright/test'
import {v5Student} from '../fixtures/v5Student.mjs'
const base=process.env.KINEO_E2E_BASE_URL||'http://127.0.0.1:4173'
test.use({serviceWorkers:'block'})

test('starting one duel shows its own progress and a failed start can be retried',async({page})=>{
 await v5Student(page)
 let release,attempts=0
 await page.route('**/rest/v1/rpc/get_friend_challenges_v3',route=>route.fulfill({json:['first','second'].map(id=>({id,status:'accepted',direction:'sent',has_played:false,opponent_has_played:false,opponent:{id:'friend-'+id,first_name:id}}))}))
 await page.route('**/rest/v1/rpc/start_friend_challenge_session_v1',async route=>{
  attempts++
  if(attempts===1){await new Promise(resolve=>{release=resolve});return route.fulfill({status:400,json:{message:'Ce défi ne contient pas 10 questions valides'}})}
  return route.fulfill({json:'retry-session'})
 })
 await page.goto(base+'/amis?tab=challenges&ui=v5')
 const rows=page.locator('.challenge-row')
 await rows.nth(0).getByRole('button',{name:'Jouer',exact:true}).click()
 await expect(rows.nth(0).getByRole('button',{name:'Préparation…'})).toBeDisabled()
 await expect(rows.nth(1).getByRole('button',{name:'Jouer',exact:true})).toBeDisabled()
 release()
 await expect(page.getByRole('status').filter({hasText:'Ce défi ne contient pas 10 questions valides'})).toBeVisible()
 await expect(rows.nth(0).getByRole('button',{name:'Jouer',exact:true})).toBeEnabled()
 await rows.nth(0).getByRole('button',{name:'Jouer',exact:true}).click()
 await expect(page).toHaveURL(/\/quiz\?mode=challenge&session=retry-session&challenge=first/)
})

test('a duel correction remains visible until the student explicitly continues',async({page})=>{
 await v5Student(page)
 await page.route('**/rest/v1/rpc/get_quiz_questions_v4',route=>route.fulfill({json:[1,2].map(n=>({id:'q'+n,type:'mcq',question_text:'Question duel '+n,difficulty:1,metadata:{},display_order:n,question_options:[{id:'wrong',option_text:'Autre réponse',display_order:1},{id:'right',option_text:'Réponse exacte',display_order:2}]}))}))
 await page.route('**/rest/v1/rpc/submit_quiz_answer_v5',route=>route.fulfill({json:{submitted:true,correct:false,correction:{correct_option_ids:['right'],explanation:'Prends le temps de comprendre cette correction.'}}}))
 await page.goto(base+'/quiz?mode=challenge&session=correction-session&challenge=duel&ui=v5')
 await page.getByRole('button',{name:'Autre réponse',exact:true}).click()
 await page.clock.install()
 await page.getByRole('button',{name:'Valider ma réponse',exact:true}).click()
 await expect(page.getByText('Prends le temps de comprendre cette correction.')).toBeVisible()
 await page.clock.runFor(5000)
 await expect(page.getByRole('heading',{name:'Question duel 1',exact:true})).toBeVisible()
 await page.getByRole('button',{name:'Question suivante',exact:true}).click()
 await expect(page.getByRole('heading',{name:'Question duel 2',exact:true})).toBeVisible()
})

for(const program of ['kineo-fr','kineo-es','ifsi-fr'])test(`${program}: the notification title and body open the notification`,async({page})=>{
 const {notificationStudent}=await import('../fixtures/notificationStudent.mjs')
 await notificationStudent(page,{program})
 await page.goto(base+'/amis?ui=v5')
 const banner=page.locator('.challenge-notice')
 await expect(banner).toBeVisible()
 await banner.locator('.challenge-notice-content>span').first().click()
 await expect(page).toHaveURL(/tab=challenges/)
 await expect(banner).toHaveCount(0)
})

test('MTP is displayed in full while matching answers retain their server keys',async({page})=>{
 await v5Student(page)
 let answer
 await page.route('**/rest/v1/rpc/get_quiz_questions_v4',route=>route.fulfill({json:[{id:'technique',type:'matching',question_text:'Associe le MTP',difficulty:1,display_order:1,metadata:{left_items:['MTP'],right_items:['Technique MTP']},question_options:[]}]}))
 await page.route('**/rest/v1/rpc/submit_quiz_answer_v5',route=>{answer=route.request().postDataJSON().p_answer;return route.fulfill({json:{submitted:true,correct:true,correction:{explanation:'Le MTP est une technique de massage.'}}})})
 await page.goto(base+'/quiz?mode=lesson&session=technique&ui=v5')
 await expect(page.getByRole('heading',{name:'Associe le massage transversal profond',exact:true})).toBeVisible()
 const select=page.getByRole('combobox',{name:'massage transversal profond',exact:true})
 await select.selectOption({label:'Technique massage transversal profond'})
 await page.getByRole('button',{name:'Valider ma réponse',exact:true}).click()
 await expect(page.getByText('Le massage transversal profond est une technique de massage.')).toBeVisible()
 expect(answer).toEqual({pairs:[{left:'MTP',right:'Technique MTP'}]})
})

test('an explanation repeating the expected answer is displayed once',async({page})=>{
 await v5Student(page)
 await page.route('**/rest/v1/rpc/get_quiz_questions_v4',route=>route.fulfill({json:[{id:'single-answer',type:'short_answer',question_text:'Cite les principes',difficulty:1,metadata:{},question_options:[],display_order:1}]}))
 await page.route('**/rest/v1/rpc/submit_quiz_answer_v5',route=>route.fulfill({json:{submitted:true,correct:false,correction:{correct_answer:'Respect, écoute et adaptation',explanation:'Réponse attendue : respect, écoute et adaptation.'}}}))
 await page.goto(base+'/quiz?mode=lesson&session=duplicate&ui=v5')
 await page.locator('textarea.text-answer').fill('Autre réponse')
 await page.getByRole('button',{name:'Valider ma réponse',exact:true}).click()
 await expect(page.locator('.result-box p').filter({hasText:/respect, écoute et adaptation/i})).toHaveCount(1)
})
