import {test,expect} from '@playwright/test'
import {v5Student} from '../fixtures/v5Student.mjs'
const base=(process.env.KINEO_E2E_BASE_URL||'http://127.0.0.1:4173').replace(/\/$/,'')
test.describe('V5 React opt-in with isolated API fixtures',()=>{
 test.skip(process.env.LERYKO_TEST_V5!=='1','Requires a build with VITE_ENABLE_V5_PREVIEW=true')
 test.use({serviceWorkers:'block'})
 test('active session wins over daily completion and optional gamification failure',async({page})=>{
  await v5Student(page,{active:{id:'saved-session',question_count:10,answered_count:4,mode:'smart'},dailyDone:true,failGame:true})
  await page.goto(base+'/?ui=v5')
  await expect(page.getByRole('link',{name:'Reprendre ma séance',exact:true})).toHaveAttribute('href','/quiz?mode=resume&session=saved-session')
  await expect(page.locator('.v5-navigation a')).toHaveCount(5)
  await expect(page.getByRole('link',{name:'Commencer ma séance',exact:true})).toHaveCount(0)
 })
 test('failed active-session lookup offers retry without starting another session',async({page})=>{
  const {state,calls}=await v5Student(page,{failActive:true})
  await page.goto(base+'/?ui=v5')
  await expect(page.getByRole('button',{name:'Réessayer la reprise'})).toBeVisible()
  await expect(page.getByRole('link',{name:'Commencer ma séance',exact:true})).toHaveCount(0)
  state.failActive=false
  await page.getByRole('button',{name:'Réessayer la reprise'}).click()
  await expect(page.getByRole('link',{name:'Commencer ma séance',exact:true})).toBeVisible()
  expect(calls.some(x=>/start_.*session|start_smart_revision/.test(x))).toBe(false)
 })
 test('comparison returns to legacy navigation and keeps real progression links',async({page})=>{
  await v5Student(page)
  await page.goto(base+'/?ui=v5')
  await page.getByRole('link',{name:'Progrès',exact:true}).click()
  await expect(page.getByRole('link',{name:'Ouvrir ma collection de badges'})).toHaveAttribute('href','/rewards')
  await expect(page.getByRole('main').getByText('⚡ 240 XP',{exact:true})).toBeVisible()
  await page.getByRole('button',{name:'Interface actuelle',exact:true}).click()
  await expect(page.locator('.v5-navigation')).toHaveCount(0)
  await expect(page.locator('.bottom-nav').getByRole('link',{name:'Badges',exact:true})).toBeVisible()
  await page.getByRole('button',{name:'Interface V5',exact:true}).click()
  await expect(page.locator('.v5-navigation')).toBeVisible()
 })
 test('IFSI keeps its own curriculum without requesting France-only daily or library data',async({page})=>{
  const {calls}=await v5Student(page,{program:'ifsi-fr'})
  await page.goto(base+'/?ui=v5')
  await expect(page.getByRole('link',{name:'Ouvrir mon parcours',exact:true})).toBeVisible()
  expect(calls.some(x=>/get_user_dashboard_v3|get_revision_mode_availability_v1|get_my_library_v1/.test(x))).toBe(false)
  await expect(page.getByRole('link',{name:'Retrouver mes supports et mes notes'})).toHaveCount(0)
 })
})
