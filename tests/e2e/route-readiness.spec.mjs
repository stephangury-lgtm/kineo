import {test,expect} from '@playwright/test'
import {v5Student} from '../fixtures/v5Student.mjs'
import {navigateConnected} from '../helpers/connected-navigation.mjs'
const base=(process.env.KINEO_E2E_BASE_URL||'http://127.0.0.1:4173').replace(/\/$/,'')
test.use({serviceWorkers:'block'})
test.describe.configure({retries:0})
test.skip(process.env.LERYKO_TEST_V5!=='1','Requires a V5 build')
for(const program of ['kineo-fr','kineo-es','ifsi-fr']){
 test(`${program}: connected navigation waits for lazy screen content`,async({page})=>{
  test.setTimeout(60000)
  await v5Student(page,{program})
  await page.route('**/rest/v1/rpc/get_curriculum_v2',route=>route.fulfill({json:[{id:'year-2',number:2,name:'K2',description:null,subjects:[]}]}))
  // Delay the lazy route chunks to expose the URL/content transition window.
  await page.route(/\/assets\/(?:CurriculumPage|ProgramLandingPage|RevisionHubPage)-.*\.js$/,async route=>{
   await new Promise(resolve=>setTimeout(resolve,400))
   await route.continue()
  })
  await page.goto(base+'/?ui=v5')
  await expect(page.locator('.v5-next-action')).toBeVisible()
  for(let repeat=0;repeat<3;repeat++){
   await navigateConnected(page,base,'/parcours')
   await expect(page.locator('.parcours-redesign')).toBeVisible()
   await expect(page.locator('.ritual-shortcuts')).toHaveCount(0)
   await navigateConnected(page,base,'/revision')
   await expect(page.locator('.revision-hub')).toBeVisible()
   await navigateConnected(page,base,'/')
  }
 })
}
