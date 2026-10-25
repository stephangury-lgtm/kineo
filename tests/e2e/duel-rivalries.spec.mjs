import {test,expect} from '@playwright/test'
import {v5Student} from '../fixtures/v5Student.mjs'
test.use({serviceWorkers:'block'})
const base=process.env.KINEO_E2E_BASE_URL||'http://127.0.0.1:4173'
for(const program of ['kineo-fr','kineo-es','ifsi-fr'])test(`${program}: cumulative rivalry and rematch use the correct challenge engine`,async({page})=>{
 await v5Student(page,{program})
 const friend={id:'friend',friendship_id:'relation',first_name:'Alex',username:'alex',same_level:true}
 const completed={id:'duel',status:'completed',direction:'received',challenger_score:40,challenged_score:80,created_at:'2026-10-24',completed_at:'2026-10-24',opponent:friend}
 let sent=false
 await page.route('**/rest/v1/rpc/*',async route=>{
  const rpc=new URL(route.request().url()).pathname.split('/').pop()
  const send=data=>route.fulfill({contentType:'application/json',body:JSON.stringify(data)})
  if(rpc==='get_friendships_v3')return send({friends:[friend],incoming:[],outgoing:[]})
  if(['get_friend_challenges_v3','get_curriculum_friend_challenges_v1'].includes(rpc))return send([completed,...(sent?[{...completed,id:'pending',status:'pending',direction:'sent'}]:[])])
  if(rpc==='get_curriculum_challenge_availability_v1')return send({can_challenge:true,validated_mcq:10})
  if(rpc===(program==='kineo-fr'?'create_friend_challenge_v1':'create_curriculum_friend_challenge_v1')){sent=true;return send('new-duel')}
  return route.fallback()
 })
 await page.goto(`${base}/amis?tab=challenges&ui=v5`)
 const card=page.locator('.rivalry-card')
 await expect(card).toContainText(program==='kineo-es'?'Vas por delante':'Tu mènes')
 await expect(card.locator('.duel-score')).toContainText('1')
 await card.getByRole('button',{name:program==='kineo-es'?'Revancha':'Revanche',exact:true}).click()
 await expect(card.getByRole('button',{name:program==='kineo-es'?'Reto en curso':'Défi en cours',exact:true})).toBeDisabled()
 expect(sent).toBe(true)
})
test('received challenge appears in the application and opens the challenges tab',async({page})=>{
 await v5Student(page)
 await page.route('**/rest/v1/notifications*',async route=>{
  if(route.request().method()==='HEAD')return route.fulfill({status:200,headers:{'content-range':'0-0/1'}})
  return route.fulfill({contentType:'application/json',body:JSON.stringify([{id:'notice',type:'challenge_received',title:'Nouveau défi',body:'Alex te défie',data:{},read_at:null,created_at:'2026-10-24'}])})
 })
 await page.goto(`${base}/amis?ui=v5`)
 await expect(page.locator('.challenge-notice')).toContainText('Alex te défie')
 await page.locator('.challenge-notice').getByRole('link').click()
 await expect(page).toHaveURL(/tab=challenges/)
 await expect(page.locator('.v5-section-nav').getByRole('button',{name:/Défis/})).toHaveAttribute('aria-pressed','true')
})
for(const program of ['kineo-fr','kineo-es','ifsi-fr'])test(`${program}: sender can play before the offline recipient accepts`,async({page})=>{
 await v5Student(page,{program})
 const calls=[]
 await page.route('**/rest/v1/rpc/*',async route=>{
  const rpc=new URL(route.request().url()).pathname.split('/').pop();calls.push(rpc)
  if(['get_friend_challenges_v3','get_curriculum_friend_challenges_v1'].includes(rpc))return route.fulfill({json:[{id:'pending-duel',status:'pending',direction:'sent',has_played:false,opponent_has_played:false,opponent:{id:'friend',first_name:'Alex'}}]})
  if(rpc==='start_friend_challenge_session_v1')return route.fulfill({json:'pending-session'})
  return route.fallback()
 })
 await page.goto(`${base}/amis?tab=challenges&ui=v5`)
 await expect(page.locator('.challenge-row')).toBeVisible()
 expect(await page.evaluate(()=>document.documentElement.scrollWidth<=window.innerWidth)).toBe(true)
 await page.locator('.challenge-row').getByRole('button',{name:program==='kineo-es'?'Jugar ahora':'Jouer maintenant',exact:true}).click()
 await expect(page).toHaveURL(program==='kineo-fr'?/\/quiz\?.*challenge=pending-duel/:/\/defi-cursus\/pending-duel/)
 expect(calls.some(name=>name.startsWith('respond_'))).toBe(false)
})
test('completed asynchronous challenge shows both scores and opens the result',async({page})=>{
 await v5Student(page)
 await page.route('**/rest/v1/notifications*',async route=>{
  if(route.request().method()==='HEAD')return route.fulfill({status:200,headers:{'content-range':'0-0/1'}})
  return route.fulfill({json:[{id:'result',type:'challenge_completed',title:'Victoire ! 🏆',body:'Ton score : 80 % · Alex : 60 %. Vous avez terminé tous les deux.',data:{},read_at:null,created_at:'2026-10-24'}]})
 })
 await page.goto(`${base}/amis?ui=v5`)
 await expect(page.locator('.challenge-notice')).toContainText('80 % · Alex : 60 %')
 await page.locator('.challenge-notice').getByRole('link',{name:/Voir le résultat/}).click()
 await expect(page).toHaveURL(/tab=challenges/)
})

const resultDuelId='d0000000-0000-4000-8000-000000000001'
async function resultStudent(page,{program='kineo-fr',score=100,other=80,tiebreakWinner=false}={}){
 await v5Student(page,{program})
 const me='a0000000-0000-4000-8000-000000000001',friendId='b0000000-0000-4000-8000-000000000001'
 const friend={id:friendId,friendship_id:'relation',first_name:'Alex',username:'alex',same_level:true}
 const duel={id:resultDuelId,status:'completed',direction:'sent',challenger_id:me,challenged_id:friendId,challenger_score:score,challenged_score:other,created_at:'2026-10-25',completed_at:'2026-10-25',opponent:friend}
 await page.route('**/rest/v1/rpc/*',route=>{
  const rpc=new URL(route.request().url()).pathname.split('/').pop()
  if(rpc==='get_friendships_v3')return route.fulfill({json:{friends:[friend],incoming:[],outgoing:[]}})
  if(['get_friend_challenges_v3','get_curriculum_friend_challenges_v1'].includes(rpc))return route.fulfill({json:[duel]})
  if(rpc==='get_curriculum_challenge_availability_v1')return route.fulfill({json:{can_challenge:true,validated_mcq:20}})
  if(rpc==='get_duel_tiebreak_results_v1')return route.fulfill({json:tiebreakWinner?[{challenge_id:resultDuelId,winner_id:me,round:2}]:[]})
  return route.fallback()
 })
}

for(const program of ['kineo-fr','kineo-es','ifsi-fr'])test(`${program}: 100 percent fills the circle, celebrates and offers a rematch`,async({page})=>{
 await resultStudent(page,{program})
 await page.setViewportSize({width:320,height:760})
 await page.goto(`${base}/amis?tab=challenges&result=${resultDuelId}&ui=v5`)
 const dialog=page.getByRole('dialog'),ring=dialog.getByRole('progressbar')
 await expect(dialog).toBeVisible()
 await expect(ring).toHaveAttribute('aria-valuenow','100')
 await expect(ring).toHaveText('100%')
 expect(await ring.getAttribute('style')).toContain('100%')
 expect(await ring.getAttribute('style')).not.toContain('85%')
 await expect(dialog.locator('[data-celebration="perfect"]')).toBeVisible()
 await expect(dialog.getByRole('status')).toContainText(program==='kineo-es'?'Pleno':'Sans-faute')
 await expect(dialog.getByRole('button',{name:program==='kineo-es'?'Pedir revancha':'Lancer la revanche'})).toBeEnabled()
 expect(await dialog.evaluate(el=>el.scrollWidth<=el.clientWidth+1)).toBe(true)
})

test('a victory below 100 percent celebrates while a loss remains encouraging',async({page})=>{
 await resultStudent(page,{score:80,other:60})
 await page.goto(`${base}/amis?tab=challenges&result=${resultDuelId}&ui=v5`)
 await expect(page.getByRole('dialog').locator('[data-celebration="victory"]')).toBeVisible()
 await expect(page.getByRole('dialog').getByRole('status')).toContainText('Félicitations')
 await resultStudent(page,{score:60,other:80})
 await page.reload()
 await expect(page.getByRole('dialog').getByRole('status')).toContainText('Chaque duel te fait progresser')
 await expect(page.getByRole('dialog').locator('.score-confetti')).toHaveCount(0)
})

test('celebration respects reduced motion and does not block the close button',async({page})=>{
 await page.emulateMedia({reducedMotion:'reduce'})
 await resultStudent(page)
 await page.goto(`${base}/amis?tab=challenges&result=${resultDuelId}&ui=v5`)
 const dialog=page.getByRole('dialog')
 await expect(dialog.locator('.score-confetti:visible')).toHaveCount(0)
 await dialog.getByRole('button',{name:'Fermer',exact:true}).click()
 await expect(dialog).toHaveCount(0)
})

test('the actual quiz summary uses its server score instead of a fixed 85 percent fill',async({page})=>{
 await v5Student(page)
 await page.route('**/rest/v1/rpc/get_quiz_questions_v4',route=>route.fulfill({json:[{id:'q-perfect',type:'mcq',question_text:'Dernière question',difficulty:2,metadata:{},display_order:5,question_options:[{id:'right',option_text:'Bonne réponse',display_order:1},{id:'wrong',option_text:'Autre réponse',display_order:2}]}]}))
 await page.route('**/rest/v1/rpc/submit_quiz_answer_v5',route=>route.fulfill({json:{submitted:true,correct:true,xp_earned:10,correction:{correct_option_ids:['right'],explanation:'Notion maîtrisée.'}}}))
 await page.route('**/rest/v1/rpc/finish_quiz_session_v2',route=>route.fulfill({json:{score:100,correct_count:5,total_questions:5,xp_earned:50}}))
 await page.goto(`${base}/quiz?mode=lesson&session=perfect-session&ui=v5`)
 await page.getByRole('button',{name:'Bonne réponse',exact:true}).click()
 await page.getByRole('button',{name:'Valider ma réponse',exact:true}).click()
 await page.getByRole('button',{name:'Voir mes résultats',exact:true}).click()
 await expect(page.locator('.session-complete').getByRole('progressbar')).toHaveAttribute('aria-valuenow','100')
 await expect(page.locator('.session-complete [data-celebration="perfect"]')).toBeVisible()
})

for(const program of ['kineo-fr','kineo-es','ifsi-fr'])test(`${program}: asynchronous sudden death hides correction until both answers`,async({page})=>{
 await resultStudent(page,{program,score:100,other:100})
 let answered=false,otherAnswered=false
 await page.route('**/rest/v1/rpc/duel_tiebreak_v1',route=>{
  const payload=route.request().postDataJSON()
  expect(payload.p_program_id).toBe(program)
  expect(payload.p_challenge_id).toBe(resultDuelId)
  if(payload.p_answer){expect(payload.p_round).toBe(1);expect(payload.p_answer).toBe('right');answered=true}
  return route.fulfill({json:{round:1,question:'Question de départage',options:[{id:'right',text:'Option A'},{id:'wrong',text:'Option B'}],my_answered:answered,other_answered:otherAnswered,round_closed:answered&&otherAnswered,outcome:answered&&otherAnswered?'win':'waiting',my_correct:answered&&otherAnswered?true:null,correct_answer:answered&&otherAnswered?'Option A':null,explanation:answered&&otherAnswered?'Explication après les deux réponses.':null,can_next:false}})
 })
 await page.goto(`${base}/amis?tab=challenges&result=${resultDuelId}&program=${program}&tiebreak=1&ui=v5`)
 const dialog=page.getByRole('dialog')
 await dialog.getByRole('button',{name:'Option A',exact:true}).click()
 await dialog.getByRole('button',{name:program==='kineo-es'?'Validar mi respuesta':'Valider ma réponse',exact:true}).click()
 await expect(dialog.getByRole('status')).toContainText(program==='kineo-es'?'guardada':'enregistrée')
 await expect(dialog.getByText('Explication après les deux réponses.')).toHaveCount(0)
 await page.reload()
 await expect(dialog.getByRole('status')).toContainText(program==='kineo-es'?'guardada':'enregistrée')
 otherAnswered=true
 await page.evaluate(()=>window.dispatchEvent(new Event('focus')))
 await expect(dialog.getByText('Explication après les deux réponses.')).toBeVisible()
 await expect(dialog.getByText(program==='kineo-es'?'¡Ganas el desempate!':'Tu remportes le départage !',{exact:true})).toBeVisible()
})

test('a sudden-death win counts once in the rivalry without altering the original percentages',async({page})=>{
 await resultStudent(page,{score:100,other:100,tiebreakWinner:true})
 await page.goto(`${base}/amis?tab=challenges&ui=v5`)
 await expect(page.locator('.rivalry-card')).toContainText('1 victoires · 0 défaites · 0 égalités')
 await expect(page.locator('.duel-result').filter({hasText:'Victoire · départage'})).toContainText('100%')
})

