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
 await expect(card.getByRole('button')).toBeDisabled()
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
