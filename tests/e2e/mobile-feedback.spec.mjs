import {test,expect} from '@playwright/test'
import {v5Student} from '../fixtures/v5Student.mjs'
test.use({serviceWorkers:'block'})
const base=(process.env.KINEO_E2E_BASE_URL||'http://127.0.0.1:4173').replace(/\/$/,'')
const history=[{id:'audit-session',mode:'smart',question_count:5,correct_count:4,xp_earned:40,started_at:'2026-10-19T04:00:00Z',completed_at:'2026-10-19T05:01:00Z',score_percent:80,duration_seconds:3660}]
test('badges show correct category totals and four earned cards per row',async({page})=>{
 await v5Student(page)
 const conditions=['streak','streak','correct_answers','correct_answers','perfect','quiz_completed','challenge','friends_added']
 const badges=conditions.map((condition_type,i)=>({id:'badge-'+i,name:'Badge '+i,description:'Récompense de progression',condition_type,target_value:5,current_value:i<4?5:2,earned:i<4,progress_percent:i<4?100:40,icon:'🏅'}))
 await page.route('**/rest/v1/rpc/get_badges_v2',route=>route.fulfill({json:{badges,stats:{}}}))
 await page.goto(base+'/rewards?ui=v5')
 const categories=page.locator('.badge-category-card')
 await expect(categories).toHaveCount(6)
 await expect(categories.filter({hasText:'Régularité'}).locator('.badge-category-count>strong')).toHaveText('2 / 2')
 await expect(categories.filter({hasText:'Connaissances'}).locator('.badge-category-count>strong')).toHaveText('2 / 2')
 await expect(categories.filter({hasText:'Performance'}).locator('.badge-category-count>strong')).toHaveText('0 / 1')
 await expect(page.locator('.badge-showcase-card')).toHaveCount(4)
 for(const width of [320,390]){
  await page.setViewportSize({width,height:844})
  const layout=await page.locator('.badge-showcase-card').evaluateAll(cards=>({rows:new Set(cards.map(c=>Math.round(c.getBoundingClientRect().top))).size,overflow:document.documentElement.scrollWidth>innerWidth}))
  expect(layout).toEqual({rows:1,overflow:false})
 }
 await expect(page.locator('main h1')).toHaveCount(0)
})
test('review filters actually restrict the questions displayed',async({page})=>{
 await v5Student(page)
 const items=[false,true,false].map((is_correct,i)=>({display_order:i+1,question_id:'question-'+i,question_type:'mcq',question_text:'Question '+i,explanation:'Explication détaillée '+i,image_url:null,subject_name:'Anatomie',is_correct,user_answer_display:'Réponse donnée',correct_answer_display:'Réponse attendue',response_time_ms:1200,source_title:null,source_page:null}))
 await page.route('**/rest/v1/rpc/get_revision_session_review_v2',route=>route.fulfill({json:items}))
 await page.goto(base+'/session/audit-session?ui=v5')
 await expect(page.locator('.review-question')).toHaveCount(3)
 await page.getByRole('button',{name:'À revoir (2)',exact:true}).click()
 await expect(page.locator('.review-question')).toHaveCount(2)
 await expect(page.locator('.review-question.is-correct')).toHaveCount(0)
 await page.getByRole('button',{name:'Correctes (1)',exact:true}).click()
 await expect(page.locator('.review-question')).toHaveCount(1)
 await expect(page.locator('.review-question')).toContainText('Question 1')
 await page.getByRole('button',{name:'Toutes (3)',exact:true}).click()
 await expect(page.locator('.review-question')).toHaveCount(3)
})
test('history uses its stylesheet without mobile overflow',async({page})=>{
 await v5Student(page)
 await page.route('**/rest/v1/rpc/get_recent_revision_sessions_v1',route=>route.fulfill({json:history}))
 await page.goto(base+'/revision/historique?ui=v5')
 await expect(page.locator('.revision-history-row')).toContainText('Révision intelligente')
 for(const width of [320,390]){
  await page.setViewportSize({width,height:844})
  const box=await page.locator('.revision-history-row').evaluate(el=>({overflow:document.documentElement.scrollWidth>innerWidth,display:getComputedStyle(el).display,paddingTop:parseFloat(getComputedStyle(el).paddingTop),borderTop:parseFloat(getComputedStyle(el).borderTopWidth)}))
  expect(box.overflow).toBe(false);expect(box.display).toBe('flex');expect(box.paddingTop).toBe(11);expect(box.borderTop).toBe(1)
 }
 await expect(page.getByRole('button',{name:'↻ Refaire',exact:true})).toBeVisible()
})
for(const program of ['kineo-fr','kineo-es','ifsi-fr'])test(`${program}: statistics format hours and resize seven and thirty day charts`,async({page})=>{
 await v5Student(page,{program})
 await page.route('**/rest/v1/rpc/get_recent_revision_sessions_v1',route=>route.fulfill({json:history}))
 await page.route(program==='kineo-fr'?'**/rest/v1/rpc/get_user_stats_v3':'**/rest/v1/rpc/get_curriculum_stats_v1',route=>{
  const days=route.request().postDataJSON().p_days
  const daily_activity=Array.from({length:days},(_,i)=>({date:new Date(Date.UTC(2026,9,19-i)).toISOString().slice(0,10),attempts:i%4+1,correct:1,accuracy_percent:50,xp:10})).reverse()
  return route.fulfill({json:{units:[],period_days:days,summary:{xp_period:50,streak_current:3,streak_longest:4,questions_total:10,questions_answered:5,coverage_percent:50,attempts:50,correct_answers:25,incorrect_answers:25,accuracy_percent:50,avg_response_ms:1000,completed_sessions:1,xp_total:240,level:3,attempted_questions:10,mastered_questions:2,fragile_questions:8,reviews_due:1,mastery_percent:20},daily_activity,subjects:[],modes:[],weak_questions:[]}})
 })
 await page.goto(base+'/stats?ui=v5')
 if(program==='kineo-fr')await expect(page.locator('.stat-kpi').filter({hasText:'Temps de révision'})).toContainText('1 h 01 min')
 await expect(page.locator('.activity-day')).toHaveCount(30)
 for(const width of [320,390]){
  await page.setViewportSize({width,height:844})
  await page.getByRole('button',{name:program==='kineo-es'?'7 días':'7 jours',exact:true}).click()
  await expect(page.locator('.activity-day')).toHaveCount(7)
  await expect.poll(()=>page.locator('.activity-chart').evaluate(el=>({fits:el.scrollWidth<=el.clientWidth+1,overflow:document.documentElement.scrollWidth>innerWidth,filled:(el.lastElementChild.getBoundingClientRect().right-el.firstElementChild.getBoundingClientRect().left)/el.getBoundingClientRect().width}))).toMatchObject({fits:true,overflow:false,filled:expect.any(Number)})
  await expect.poll(()=>page.locator('.activity-chart').evaluate(el=>(el.lastElementChild.getBoundingClientRect().right-el.firstElementChild.getBoundingClientRect().left)/el.getBoundingClientRect().width)).toBeGreaterThan(0.9)
  await page.getByRole('button',{name:program==='kineo-es'?'30 días':'30 jours',exact:true}).click()
  await expect(page.locator('.activity-day')).toHaveCount(30)
  expect(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth)).toBe(false)
 }
})
