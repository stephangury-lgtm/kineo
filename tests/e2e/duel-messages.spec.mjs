import {test,expect} from '@playwright/test'
import {v5Student} from '../fixtures/v5Student.mjs'
test.use({serviceWorkers:'block'})
const base=process.env.KINEO_E2E_BASE_URL||'http://127.0.0.1:4173'
const id='31be7940-e9a3-4dba-9950-9cd91083da90'
async function setup(page,{program='kineo-fr',canSend=true,status='completed',failOnce=false}={}) {
 await v5Student(page,{program})
 const friend={id:'friend',friendship_id:'relation',first_name:'Alex',username:'alex',same_level:true}
 const duel={id,status,direction:'sent',challenger_score:40,challenged_score:80,created_at:'2026-10-24',completed_at:'2026-10-24',opponent:friend}
 const calls=[],messages=[],requests=[]
 let rematch=false,failed=false
 await page.route('**/rest/v1/rpc/*',async route=>{
  const rpc=new URL(route.request().url()).pathname.split('/').pop()
  const payload=route.request().postDataJSON()
  const send=data=>route.fulfill({json:data})
  if(rpc==='get_friendships_v3')return send({friends:canSend?[friend]:[],incoming:[],outgoing:[]})
  if(['get_friend_challenges_v3','get_curriculum_friend_challenges_v1'].includes(rpc))return send([duel,...(rematch?[{...duel,id:'new-duel',status:'pending'}]:[])])
  if(rpc==='get_curriculum_challenge_availability_v1')return send({can_challenge:true,validated_mcq:10})
  if(rpc==='read_friend_challenge_messages_v1'){expect(payload.p_challenge_id).toBe(id);expect(payload.p_program_id).toBe(program);return send({messages,can_send:canSend})}
  if(rpc==='send_friend_challenge_message_v1'){
   calls.push('send');requests.push(payload)
   if(failOnce&&!failed){failed=true;return route.fulfill({status:503,json:{message:'Temporary test failure'}})}
   messages.push({id:'message',body:payload.p_body,is_mine:true,sender_name:'Toi',created_at:new Date().toISOString()});return send('message')
  }
  if(rpc===(program==='kineo-fr'?'create_friend_challenge_v1':'create_curriculum_friend_challenge_v1')){calls.push('rematch');rematch=true;return send('new-duel')}
  return route.fallback()
 })
 return {calls,requests}
}
for(const program of ['kineo-fr','kineo-es','ifsi-fr'])test(`${program}: preset prepares a draft, explicit send then rematch`,async({page})=>{
 const {calls,requests}=await setup(page,{program})
 await page.goto(`${base}/amis?tab=challenges&ui=v5`)
 await page.locator('.rivalry-card').getByRole('button',{name:program==='kineo-es'?'💬 Conversar':'💬 Échanger'}).click()
 const modal=page.getByRole('dialog')
 await expect(modal).toBeVisible()
 await modal.locator('.duel-presets button').first().click()
 const text=await modal.getByRole('textbox').inputValue()
 expect(text).toContain(program==='kineo-es'?'ficha':'fiche')
 expect(calls).toEqual([])
 expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth)).toBe(true)
 await modal.getByRole('button',{name:program==='kineo-es'?'Enviar':'Envoyer',exact:true}).click()
 await expect(modal.locator('.duel-message')).toHaveText(new RegExp(program==='kineo-es'?'ficha':'fiche'))
 await expect(modal.getByRole('textbox')).toHaveValue('')
 expect(requests[0].p_program_id).toBe(program)
 expect(requests[0].p_challenge_id).toBe(id)
 await modal.getByRole('textbox').fill(program==='kineo-es'?'¡Vamos!':'On remet ça !')
 await modal.getByRole('button',{name:program==='kineo-es'?'Enviar y pedir revancha':'Envoyer et relancer',exact:true}).click()
 await expect(modal).not.toBeVisible()
 expect(calls).toEqual(['send','send','rematch'])
 await expect(page.locator('.challenge-row')).toBeVisible()
})
test('notification opens the precise private thread; plain text is escaped',async({page})=>{
 await setup(page)
 await page.route('**/rest/v1/notifications*',async route=>{
  if(route.request().method()==='HEAD')return route.fulfill({status:200,headers:{'content-range':'0-0/1'}})
  return route.fulfill({json:[{id:'notice',type:'challenge_message',title:'Un message d’après-match 💬',body:'Alex t’a laissé un petit mot.',data:{challenge_id:id,program_id:'kineo-fr'},read_at:null,created_at:'2026-10-24'}]})
 })
 await page.goto(`${base}/amis?ui=v5`)
 await page.locator('.challenge-notice').getByRole('link',{name:/Lire le message/}).click()
 await expect(page).toHaveURL(new RegExp(`discussion=${id}`))
 const modal=page.getByRole('dialog')
 await modal.getByRole('textbox').fill('<img src=x onerror=alert(1)> Bien joué !')
 await modal.getByRole('button',{name:'Envoyer',exact:true}).click()
 await expect(modal.locator('.duel-message p')).toHaveText('<img src=x onerror=alert(1)> Bien joué !')
 await expect(modal.locator('.duel-message img')).toHaveCount(0)
 await page.keyboard.press('Escape')
 await expect(modal).not.toBeVisible()
})
test('removed friendship preserves read access and disables messages and rematch',async({page})=>{
 await setup(page,{canSend:false})
 await page.goto(`${base}/amis?tab=challenges&discussion=${id}&ui=v5`)
 const modal=page.getByRole('dialog')
 await expect(modal).toContainText('Vous devez encore être amis')
 await expect(modal.getByRole('textbox')).toHaveCount(0)
 await expect(modal.getByRole('button',{name:'Lancer la revanche'})).toBeDisabled()
 await modal.getByRole('button',{name:'Fermer'}).click()
 await expect(modal).not.toBeVisible()
})
test('retry after a failed response keeps the request id and never starts a premature rematch',async({page})=>{
 const {calls,requests}=await setup(page,{failOnce:true})
 await page.goto(`${base}/amis?tab=challenges&discussion=${id}&ui=v5`)
 const modal=page.getByRole('dialog')
 await expect(modal.getByRole('textbox')).toBeVisible()
 await modal.getByRole('textbox').fill('Bien joué !')
 await modal.getByRole('button',{name:'Envoyer et relancer'}).click()
 await expect(modal.getByRole('alert')).toBeVisible()
 expect(calls).toEqual(['send'])
 await expect(modal.getByRole('textbox')).toHaveValue('Bien joué !')
 await modal.getByRole('button',{name:'Envoyer et relancer'}).click()
 await expect(modal).not.toBeVisible()
 expect(requests[1].p_request_id).toBe(requests[0].p_request_id)
 expect(calls).toEqual(['send','send','rematch'])
})
test('a pending duel has no conversation entry point',async({page})=>{
 await setup(page,{status:'pending'})
 await page.goto(`${base}/amis?tab=challenges&ui=v5`)
 await expect(page.locator('.challenge-row')).toBeVisible()
 await expect(page.getByRole('button',{name:'💬 Échanger'})).toHaveCount(0)
})
test('notification retains the duel program when another program is selected',async({page})=>{
 const {requests}=await setup(page,{program:'kineo-es'})
 await page.route('**/rest/v1/notifications*',async route=>{
  if(route.request().method()==='HEAD')return route.fulfill({status:200,headers:{'content-range':'0-0/1'}})
  return route.fulfill({json:[{id:'notice',type:'challenge_message',title:'Un mensaje después del duelo',data:{curriculum_challenge_id:id,program_id:'kineo-es'},read_at:null,created_at:'2026-10-24'}]})
 })
 await page.goto(`${base}/amis?ui=v5`)
 await page.evaluate(()=>localStorage.setItem('healthapp_program','kineo-fr'))
 await page.locator('.challenge-notice').getByRole('link',{name:/Leer el mensaje/}).click()
 const modal=page.getByRole('dialog')
 await expect(modal.getByRole('textbox')).toBeVisible()
 await modal.getByRole('textbox').fill('¡Buena revancha!')
 await modal.getByRole('button',{name:'Enviar',exact:true}).click()
 await expect(modal.locator('.duel-message p')).toHaveText('¡Buena revancha!')
 expect(requests[0].p_program_id).toBe('kineo-es')
})
