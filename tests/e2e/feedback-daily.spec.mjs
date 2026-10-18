import {test,expect} from '@playwright/test'
import {v5Student} from '../fixtures/v5Student.mjs'
const base=(process.env.KINEO_E2E_BASE_URL||'http://127.0.0.1:4173').replace(/\/$/,'')
test.describe('Feedback audit 2026-10-18',()=>{
 test.use({serviceWorkers:'block'})
 for(const program of ['kineo-fr','kineo-es','ifsi-fr'])test(`${program}: one badge entry and navigation starts at top`,async({page})=>{
  await v5Student(page,{program})
  await page.goto(base+'/progres?ui=v5')
  await expect(page.locator('main a[href="/rewards"]')).toHaveCount(1)
  await page.evaluate(()=>{document.body.style.minHeight='3000px';window.scrollTo(0,900)})
  await expect.poll(()=>page.evaluate(()=>window.scrollY)).toBeGreaterThan(500)
  await page.locator('main a[href="/rewards"]').click()
  await expect(page).toHaveURL(/\/rewards/)
  await expect.poll(()=>page.evaluate(()=>window.scrollY)).toBe(0)
 })
 test('friend search excludes friends and invitations in both directions',async({page})=>{
  await v5Student(page)
  const student=id=>({id,username:id,first_name:id,study_year:2,level:1,avatar_url:null})
  await page.route('**/rest/v1/rpc/get_friendships_v3',route=>route.fulfill({json:{friends:[{...student('friend'),friendship_id:'f'}],incoming:[{...student('incoming'),friendship_id:'i'}],outgoing:[{...student('outgoing'),friendship_id:'o'}]}}))
  await page.route('**/rest/v1/rpc/search_students_v3',route=>route.fulfill({json:['friend','incoming','outgoing','new-student'].map(student)}))
  await page.goto(base+'/amis?ui=v5')
  await page.getByRole('textbox',{name:'Rechercher un camarade'}).fill('test')
  await page.getByRole('button',{name:'Rechercher',exact:true}).click()
  await expect(page.getByRole('button',{name:'Ajouter',exact:true})).toHaveCount(1)
  await expect(page.locator('.person-row').filter({has:page.getByRole('button',{name:'Ajouter',exact:true})})).toContainText('new-student')
 })
 test('daily priorities have no stray dollar signs or duplicate hero flame',async({page})=>{
  await v5Student(page)
  await page.route('**/rest/v1/rpc/get_user_stats_v3',route=>route.fulfill({json:{summary:{reviews_due:0,fragile_questions:44},weak_questions:[{question_id:'weak-question',subject_name:'Anatomie',question_text:'Question à revoir',mastery_percent:10,accuracy_percent:20}]}}))
  await page.goto(base+'/quiz?mode=daily&ui=v5')
  await expect(page.locator('.focus-meta')).toHaveText('44 questions fragiles.')
  await expect(page.locator('.revision-play-hero .hero-orbit')).toHaveCount(0)
 })
})
