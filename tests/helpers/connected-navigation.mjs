import {expect} from '@playwright/test'

const screens={
 '/':'.v5-next-action',
 '/parcours':'.parcours-redesign',
 '/revision':'.revision-hub',
 '/progres':'.learning-v5',
 '/amis':'.friends-stack',
 '/profil':'.profile-stack',
}

async function ready(page,base,path){
 await expect(page).toHaveURL(base+path)
 // The router changes the URL before a lazy screen has committed. #root and
 // the fixed navigation remain visible throughout that transition; neither
 // proves that links from the previous screen have disappeared.
 if(screens[path])await expect(page.locator('main.content').locator(screens[path])).toBeVisible({timeout:20000})
 else await expect(page.locator('#root')).toBeVisible()
}

export async function navigateConnected(page,base,path){
 const internal=page.locator(`a[href="${path}"]:visible`).first()
 if(page.url().startsWith(base+'/')&&await internal.count()){
  await internal.click({timeout:8000})
  await ready(page,base,path)
  return
 }
 for(let attempt=0;attempt<2;attempt++){
  try{await page.goto(base+path,{waitUntil:'domcontentloaded'});break}
  catch(error){if(attempt||!/NS_BINDING_ABORTED|interrupted by another navigation/.test(String(error)))throw error}
 }
 await ready(page,base,path)
}
