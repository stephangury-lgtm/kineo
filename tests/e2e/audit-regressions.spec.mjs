import { test,expect } from '@playwright/test'

const base=(process.env.KINEO_E2E_BASE_URL||'http://127.0.0.1:4173').replace(/\/$/,'')
const userId='a0000000-0000-4000-8000-000000000001'
const levelId='a0000000-0000-4000-8000-000000000002'
const topicId='a0000000-0000-4000-8000-000000000003'
const unitId='a0000000-0000-4000-8000-000000000004'
const game={xp_total:0,level:{number:1,name:'Débutant',progress_percent:0},streak:{current:0,longest:0},badges:{earned:0,total:0}}

// All Supabase traffic is intercepted. These tests never create real accounts.
async function mockStudent(page,{assigned=false,programId='ifsi-fr',levelCode='S1',profileYear}={}){
 const calls=[]
 const state={assigned,programId,levelCode,failProfile:false,holdProfile:false,releaseProfile:()=>{},setupError:null,holdSetup:false,releaseSetup:()=>{}}
 let profile={id:userId,first_name:'Audit',username:'audit.student',avatar_url:null,study_year:profileYear!==undefined?profileYear:assigned?1:null,role:'student'}
 const expiry=Math.floor(Date.now()/1000)+3600
 const user={id:userId,aud:'authenticated',role:'authenticated',email:'audit@example.invalid',app_metadata:{provider:'email'},user_metadata:{},created_at:new Date().toISOString()}
 const token=[{alg:'HS256',typ:'JWT'},{sub:userId,role:'authenticated',exp:expiry}].map(value=>Buffer.from(JSON.stringify(value)).toString('base64url')).join('.')+'.local-test-signature'
 await page.addInitScript(({user,token,expiry,assigned,programId})=>{
  localStorage.setItem('sb-kimtiyuytikyseuzmjbv-auth-token',JSON.stringify({access_token:token,refresh_token:'local-test',expires_at:expiry,expires_in:3600,token_type:'bearer',user}))
  if(assigned)localStorage.setItem('healthapp_program',programId)
 },{user,token,expiry,assigned,programId})
 await page.route('https://kimtiyuytikyseuzmjbv.supabase.co/**',async route=>{
  const request=route.request()
  const pathname=new URL(request.url()).pathname
  calls.push({pathname,method:request.method(),body:request.postDataJSON()})
  const send=data=>route.fulfill({status:200,contentType:'application/json',body:JSON.stringify(data)})
  if(pathname==='/auth/v1/user')return send(user)
  if(pathname==='/auth/v1/logout')return send({})
  if(pathname==='/rest/v1/profiles'){
   if(state.holdProfile)await new Promise(resolve=>{state.releaseProfile=resolve})
   if(state.failProfile&&page.url().endsWith('/profil'))return route.fulfill({status:500,contentType:'application/json',body:JSON.stringify({message:'Simulated profile request failure'})})
   return send(profile)
  }
  if(pathname==='/rest/v1/profile_programs')return send(state.assigned?[{program_id:state.programId,academic_level_id:levelId,is_primary:true,curriculum_version:state.programId==='ifsi-fr'?'2009':'default',academic_levels:{code:state.levelCode}}]:[])
  if(pathname.endsWith('/setup_student_profile_v1')){
   if(state.holdSetup)await new Promise(resolve=>{state.releaseSetup=resolve})
   if(state.setupError)return route.fulfill({status:400,contentType:'application/json',body:JSON.stringify({message:state.setupError})})
   const body=request.postDataJSON()
   state.assigned=true;state.programId=body.p_program_id;state.levelCode=body.p_level_code
   profile={...profile,first_name:body.p_first_name,username:body.p_username,study_year:body.p_program_id==='kineo-fr'?Number(body.p_level_code.slice(1)):1}
   return send(profile)
  }
  if(pathname.endsWith('/get_gamification_summary_v2'))return send(game)
  if(pathname.endsWith('/get_friendships_v3'))return send({friends:[],incoming:[],outgoing:[]})
  if(pathname.endsWith('/get_curriculum_progress_v1'))return send({coverage_percent:0,completion_percent:0,topics_total:0,topics_completed:0,questions_total:0,questions_answered:0})
  if(pathname.endsWith('/get_active_revision_session_v1'))return send(null)
  if(pathname.endsWith('/get_curriculum_friend_challenges_v1'))return send([])
  if(pathname.endsWith('/get_inactivity_reminder_preference_v1'))return send([{opted_in:true}])
  if(pathname.endsWith('/can_review_visuals_v1'))return send(false)
  if(pathname.endsWith('/get_user_dashboard_v3'))return send({})
  if(pathname.endsWith('/get_study_priorities_v1'))return send({study_year:profile.study_year,items:[]})
  if(pathname.endsWith('/get_revision_mode_availability_v1'))return send({total_questions:0,can_weak:false,can_visual:false,can_exam:false})
  if(pathname.includes('/rpc/'))return send([])
  if(pathname==='/rest/v1/curriculum_topics')return send({id:topicId,unit_id:unitId,name:'Audit chapter',curriculum_units:{program_id:state.programId,academic_level_id:levelId,curriculum_version:state.programId==='ifsi-fr'?'2009':'default'}})
  if(pathname==='/rest/v1/academic_levels')return send([{id:levelId,display_order:1}])
  return send([])
 })
 return {calls,state}
}

test.describe('audit regressions with isolated API fixtures',()=>{
 test.use({serviceWorkers:'block'})
 test('publisher and privacy are accessible before sign-in',async({page})=>{
  await page.goto(base+'/informations')
  await expect(page.getByRole('heading',{name:'Stéphan Gury'})).toBeVisible()
  await expect(page.getByRole('link',{name:'stephangury@gmail.com'}).first()).toHaveAttribute('href','mailto:stephangury@gmail.com')
  await expect(page.getByRole('heading',{name:'Garder le contrôle de ses données'})).toBeVisible()
  await expect(page.locator('input[type="password"]')).toHaveCount(0)
  await page.getByRole('link',{name:'Retour à GURIKO'}).click()
  await expect(page.getByRole('link',{name:'Informations, confidentialité & assistance'})).toBeVisible()
 })

 for(const [programId,programName,levelCode] of [['kineo-fr','Kiné France','K2'],['kineo-fr','Kiné France','K5'],['ifsi-fr','IFSI','S1'],['ifsi-fr','IFSI','S2'],['kineo-es','Fisioterapia España','ES1']]){
  test(`first-year setup ${programId}/${levelCode} uses one atomic save`,async({page})=>{
   const {calls}=await mockStudent(page)
   await page.goto(base)
   await page.locator('.program-card').filter({hasText:programName}).click()
   await page.getByRole('combobox').selectOption(levelCode)
   await page.getByLabel('Prénom (facultatif)').fill('Étudiant audit')
   await page.getByRole('button',{name:'Créer mon espace étudiant'}).click()
   await expect(page.locator('.bottom-nav')).toBeVisible({timeout:15000})
   const setup=calls.filter(call=>call.pathname.endsWith('/setup_student_profile_v1'))
   expect(setup).toHaveLength(1)
   expect(setup[0].body).toMatchObject({p_program_id:programId,p_level_code:levelCode,p_first_name:'Étudiant audit'})
   expect(calls.filter(call=>call.pathname==='/rest/v1/profile_programs'&&call.method!=='GET')).toHaveLength(0)
  })
 }

 test('setup failure is visible on mobile and retry completes the account',async({page})=>{
  await page.setViewportSize({width:320,height:640})
  const {state,calls}=await mockStudent(page)
  state.setupError='Ce pseudo est déjà utilisé'
  await page.goto(base)
  await expect(page.getByRole('combobox')).toContainText('K2 · 1re année IFMK')
  await expect(page.getByRole('combobox')).toContainText('K5 · 4e année IFMK')
  await page.getByLabel('Pseudo (facultatif)').fill('already.used')
  await page.getByRole('button',{name:'Créer mon espace étudiant'}).click()
  await expect(page.getByRole('alert')).toHaveText('Ce pseudo est déjà utilisé')
  await expect(page.getByRole('alert')).toBeFocused()
  await expect(page.getByRole('button',{name:'Créer mon espace étudiant'})).toBeEnabled()
  state.setupError=null
  await page.getByLabel('Pseudo (facultatif)').fill('new.student')
  await page.getByLabel('Pseudo (facultatif)').press('Enter')
  await expect(page.locator('.bottom-nav')).toBeVisible()
  expect(calls.filter(c=>c.pathname.endsWith('/setup_student_profile_v1'))).toHaveLength(2)
 })

 test('pending setup shows feedback and prevents duplicate submissions',async({page})=>{
  const {state,calls}=await mockStudent(page)
  state.holdSetup=true
  await page.goto(base)
  await page.getByRole('button',{name:'Créer mon espace étudiant'}).click()
  await expect(page.getByRole('status')).toHaveText('Enregistrement de ton parcours en cours…')
  await expect(page.getByRole('button',{name:'Création du parcours…'})).toBeDisabled()
  await expect.poll(()=>calls.filter(c=>c.pathname.endsWith('/setup_student_profile_v1')).length).toBe(1)
  state.releaseSetup()
  await expect(page.locator('.bottom-nav')).toBeVisible()
 })

 test('setup opened from a protected deep link finishes on the home page',async({page})=>{
  await mockStudent(page)
  await page.goto(base+'/profil')
  await page.getByRole('button',{name:'Créer mon espace étudiant'}).click()
  await expect(page).toHaveURL(base+'/')
  await expect(page.locator('.bottom-nav')).toBeVisible()
 })

 test('unresponsive setup stops waiting and offers an explicit retry',async({page})=>{
  const {state}=await mockStudent(page)
  state.holdSetup=true
  await page.clock.install()
  await page.goto(base)
  await page.getByRole('button',{name:'Créer mon espace étudiant'}).click()
  await expect(page.getByRole('button',{name:'Création du parcours…'})).toBeDisabled()
  await page.clock.runFor(20_001)
  await expect(page.getByRole('alert')).toContainText('Le serveur met trop de temps à répondre')
  await expect(page.getByRole('button',{name:'Créer mon espace étudiant'})).toBeEnabled()
  state.releaseSetup()
 })

 test('partial setup resumes the existing assigned curriculum',async({page})=>{
  const {calls}=await mockStudent(page,{assigned:true,profileYear:null})
  await page.goto(base)
  await expect(page.getByRole('combobox')).toHaveValue('S1')
  await expect(page.getByRole('combobox')).toBeDisabled()
  await page.getByRole('button',{name:'Créer mon espace étudiant'}).click()
  await expect(page.locator('.bottom-nav')).toBeVisible()
  expect(calls.find(call=>call.pathname.endsWith('/setup_student_profile_v1')).body.p_program_id).toBe('ifsi-fr')
 })

 test('slow profile loading stays pending and ignores a late response after logout',async({page})=>{
  const {state}=await mockStudent(page,{assigned:true})
  state.holdProfile=true
  await page.clock.install()
  await page.goto(base,{waitUntil:'domcontentloaded'})
  await expect(page.getByText('Ouverture de ton espace…')).toBeVisible()
  await page.clock.runFor(12001)
  await expect(page.getByText(/Le chargement prend plus de temps/)).toBeVisible()
  await expect(page.getByRole('heading',{name:'Profil introuvable'})).toHaveCount(0)
  await page.getByRole('button',{name:'Se déconnecter'}).click()
  await expect(page.getByRole('button',{name:'Se connecter'})).toBeVisible()
  state.releaseProfile()
  await expect(page.getByRole('button',{name:'Se connecter'})).toBeVisible()
  await expect(page.locator('.bottom-nav')).toHaveCount(0)
 })

 test('profile request failure offers retry and recovers',async({page})=>{
  const {state}=await mockStudent(page,{assigned:true})
  await page.goto(base)
  await expect(page.locator('.bottom-nav')).toBeVisible()
  state.failProfile=true
  await page.getByRole('link',{name:'Ouvrir mon compte'}).click()
  await expect(page.getByRole('button',{name:'Réessayer'})).toBeVisible()
  state.failProfile=false
  await page.getByRole('button',{name:'Réessayer'}).click()
  await expect(page.getByRole('button',{name:'Réessayer'})).toHaveCount(0)
  await expect(page.locator('.bottom-nav')).toBeVisible()
  await expect(page.getByLabel('Prénom',{exact:true})).toHaveValue('Audit')
 })

 test('all curriculum formats render safe prompts and use server corrections',async({page})=>{
  const {calls}=await mockStudent(page,{assigned:true})
  const questions=Array.from({length:10},(_,index)=>({
   id:`b0000000-0000-4000-8000-${String(index+1).padStart(12,'0')}`,topic_id:topicId,
   question_text:`Audit question ${index+1}`,explanation:null,options:[{text:'Choice A'},{text:'Choice B'}],
   difficulty:1,display_order:index+1,question_type:'mcq',image_url:null,metadata:{},source_label:'Audit source',
  }))
  questions[1]={...questions[1],question_type:'fill_blank',options:[]}
  questions[2]={...questions[2],question_type:'matching',options:[],metadata:{left_items:['Muscle A','Muscle B'],right_items:['Action B','Action A']}}
  questions[3]={...questions[3],question_type:'visual_hotspot',options:[],image_url:'/quiz-assets/hotspot-genou.svg',metadata:{hotspots:[{id:'a',label:'Zone A',x:25,y:50},{id:'b',label:'Zone B',x:75,y:50}]}}
  await page.route('**/rest/v1/rpc/get_curriculum_quiz_questions_v1**',route=>route.fulfill({status:200,contentType:'application/json',body:JSON.stringify(questions)}))
  await page.route('**/rest/v1/rpc/submit_curriculum_topic_answer_v3**',route=>{
   const {p_question_id}=route.request().postDataJSON()
   const index=questions.findIndex(question=>question.id===p_question_id)
   return route.fulfill({status:200,contentType:'application/json',body:JSON.stringify({
    correct:index===0||index===2,correct_answer:index===0?'Choice B':index===1?'Expected text':null,
    correct_pairs:index===2?[{left:'Muscle A',right:'Action A'},{left:'Muscle B',right:'Action B'}]:[],
    correct_hotspot_id:index===3?'b':null,explanation:'Explanation only after submission',xp_earned:2,
   })})
  })
  await page.goto(base+`/cours/${topicId}#qcm`)
  const cards=page.locator('.curriculum-quiz-card')
  await expect(cards).toHaveCount(10)
  await expect(page.getByText('Explanation only after submission')).toHaveCount(0)
  await cards.nth(0).getByRole('radio',{name:'Choice B'}).check()
  await cards.nth(0).getByRole('button',{name:'Valider ma réponse'}).click()
  await expect(cards.nth(0).locator('.curriculum-feedback.success')).toContainText('Explanation only after submission')
  await expect(cards.nth(0).locator('.curriculum-option.correct')).toContainText('Choice B')
  await cards.nth(1).locator('input.text-input').fill('Wrong text')
  await cards.nth(1).getByRole('button',{name:'Valider ma réponse'}).click()
  await expect(cards.nth(1).locator('.curriculum-feedback')).toContainText('Expected text')
  await cards.nth(2).getByLabel('Muscle A').selectOption('Action A')
  await cards.nth(2).getByLabel('Muscle B').selectOption('Action B')
  await cards.nth(2).getByRole('button',{name:'Valider ma réponse'}).click()
  await expect(cards.nth(2).locator('.curriculum-feedback.success')).toBeVisible()
  await cards.nth(3).getByRole('button',{name:'Zone A',exact:true}).click()
  await cards.nth(3).getByRole('button',{name:'Valider ma réponse'}).click()
  await expect(cards.nth(3).locator('.curriculum-feedback')).toContainText('Zone B')
  expect(calls.some(call=>call.pathname==='/rest/v1/curriculum_quiz_questions')).toBeFalsy()
 })
})

test.describe('private course documents',()=>{
 test.use({serviceWorkers:'block'})
 test('course PDFs stay available while personal library stalls and recovers',async({page})=>{
  await mockStudent(page,{assigned:true,programId:'kineo-fr',levelCode:'K2',profileYear:2})
  let release
  const held=new Promise(resolve=>{release=resolve})
  let calls=0
  await page.route('**/rest/v1/rpc/get_course_documents_v1',route=>route.fulfill({status:200,contentType:'application/json',body:JSON.stringify([{id:'b0000000-0000-4000-8000-000000000001',title:'Available course PDF',file_name:'course.pdf',file_size:123}])}))
  await page.route('**/rest/v1/rpc/get_my_library_v1',async route=>{
   calls++
   if(calls===1){await held;return route.fulfill({status:503,contentType:'application/json',body:JSON.stringify({message:'fixture unavailable'})})}
   return route.fulfill({status:200,contentType:'application/json',body:JSON.stringify({favorites:[],notes:[]})})
  })
  try{
   await page.goto(base+'/bibliotheque')
   await expect(page.getByRole('link',{name:/Available course PDF/})).toBeVisible()
   await expect(page.getByText('Chargement de tes notes et favoris…')).toBeVisible()
   release()
   await expect(page.getByRole('alert')).toContainText('momentanément indisponibles')
   await expect(page.getByRole('link',{name:/Available course PDF/})).toBeVisible()
   await page.getByRole('button',{name:'Réessayer les notes et favoris'}).click()
   await expect(page.getByRole('heading',{name:'Mes notes de cours'})).toBeVisible()
  }finally{release()}
 })
 test('opens a protected PDF with a short signed URL and refreshes access',async({page})=>{
  await mockStudent(page,{assigned:true,programId:'kineo-fr',levelCode:'K2',profileYear:2})
  const documentId='b0000000-0000-4000-8000-000000000001'
  let signedRequests=0
  await page.route('**/rest/v1/rpc/get_course_document_v1',route=>route.fulfill({status:200,contentType:'application/json',body:JSON.stringify({id:documentId,title:'Protected anatomy course',file_name:'course.pdf',storage_path:'courses/test.pdf',mime_type:'application/pdf',file_size:123})}))
  await page.route('**/storage/v1/object/sign/documents/**',route=>{
   if(route.request().method()==='POST'){
    expect(route.request().postDataJSON().expiresIn).toBe(900)
    signedRequests++
    return route.fulfill({status:200,contentType:'application/json',body:JSON.stringify({signedURL:'/object/sign/documents/courses/test.pdf?token=local-fixture'})})
   }
   return route.fulfill({status:200,contentType:'application/pdf',body:'%PDF-1.4\n%%EOF'})
  })
  await page.goto(base+'/document/'+documentId)
  await expect(page.getByRole('heading',{name:'Protected anatomy course'})).toBeVisible()
  await expect(page.locator('.course-pdf-reader')).toBeVisible()
  await expect(page.getByRole('link',{name:'Ouvrir le PDF'})).not.toHaveAttribute('href',/google|\/public\//)
  await page.getByRole('button',{name:'Actualiser l’accès'}).click()
  await expect.poll(()=>signedRequests).toBe(2)
 })
 test('denied PDF access shows an error without a Google Drive fallback',async({page})=>{
  await mockStudent(page,{assigned:true,programId:'kineo-fr',levelCode:'K2',profileYear:2})
  await page.route('**/rest/v1/rpc/get_course_document_v1',route=>route.fulfill({status:403,contentType:'application/json',body:JSON.stringify({message:'Permission denied'})}))
  await page.goto(base+'/document/b0000000-0000-4000-8000-000000000001')
  await expect(page.getByRole('alert')).toContainText('indisponible')
  await expect(page.locator('iframe')).toHaveCount(0)
  await expect(page.getByRole('button',{name:'Réessayer'})).toBeVisible()
 })
})

test('offline deep-link reload falls back to the cached shell',async({page,context,browserName})=>{
 test.skip(browserName!=='chromium','Service worker behavior is verified in Chromium')
 await page.goto(base+'/profil',{waitUntil:'networkidle'})
 await page.evaluate(async()=>{await navigator.serviceWorker.ready})
 if(!await page.evaluate(()=>Boolean(navigator.serviceWorker.controller)))await page.reload({waitUntil:'networkidle'})
 await expect.poll(()=>page.evaluate(()=>Boolean(navigator.serviceWorker.controller))).toBeTruthy()
 await page.reload({waitUntil:'networkidle'})
 // Let the navigation cache write finish before disconnecting.
 await expect.poll(async()=>page.evaluate(async()=>{const cached=await caches.match('/');return Boolean(cached)})).toBeTruthy()
 try{
  await context.setOffline(true)
  await page.reload({waitUntil:'domcontentloaded'})
  await expect(page.locator('#root')).toBeVisible()
  await expect(page.getByRole('button',{name:'Se connecter'})).toBeVisible()
 }finally{await context.setOffline(false)}
})

