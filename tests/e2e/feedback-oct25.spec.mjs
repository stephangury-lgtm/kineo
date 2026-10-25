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
