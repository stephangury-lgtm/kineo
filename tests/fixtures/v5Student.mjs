export async function v5Student(page,{program='kineo-fr',active=null,failActive=false,failGame=false,dailyDone=false,role='student'}={}){
 const state={active,failActive,failGame,dailyDone},calls=[]
 const id='a0000000-0000-4000-8000-000000000001',level='a0000000-0000-4000-8000-000000000002'
 const expires=Math.floor(Date.now()/1000)+3600
 const user={id,aud:'authenticated',role:'authenticated',email:'v5@example.invalid',app_metadata:{provider:'email'},user_metadata:{},created_at:new Date().toISOString()}
 const token=[{alg:'HS256',typ:'JWT'},{sub:id,role:'authenticated',exp:expires}].map(x=>Buffer.from(JSON.stringify(x)).toString('base64url')).join('.')+'.local-test-signature'
 await page.addInitScript(({user,token,expires,program})=>{localStorage.setItem('healthapp_program',program);localStorage.setItem('sb-kimtiyuytikyseuzmjbv-auth-token',JSON.stringify({access_token:token,refresh_token:'local-test',expires_at:expires,expires_in:3600,token_type:'bearer',user}))},{user,token,expires,program})
 await page.route('https://kimtiyuytikyseuzmjbv.supabase.co/**',async route=>{
  const path=new URL(route.request().url()).pathname;calls.push(path)
  const send=(data,status=200)=>route.fulfill({status,contentType:'application/json',body:JSON.stringify(data)})
  if(path==='/auth/v1/user')return send(user)
  if(path==='/rest/v1/profiles')return send({id,first_name:'Test V5',username:'test.v5',study_year:program==='kineo-fr'?2:1,role,avatar_url:null})
  if(path.endsWith('/can_review_visuals_v1'))return send(false)
  if(path.endsWith('/get_content_quality_summary_v1'))return send({years:[],quality:{published_total:0,published_without_source:0,published_incomplete_source:0,visual_quarantined:0},feedback:{new_feedback:0,reviewed_feedback:0,resolved_feedback:0},documents:{total:0,validated:0}})
  if(path.endsWith('/get_content_review_queue_v4'))return send({counts:{review:0,validated:0,published:0,quarantined_visual:0},questions:[]})
  if(path==='/rest/v1/profile_programs')return send([{program_id:program,academic_level_id:level,is_primary:true,curriculum_version:program==='ifsi-fr'?'2009':'default',academic_levels:{code:program==='ifsi-fr'?'S1':'K2'}}])
  if(path.endsWith('/get_active_revision_session_v1'))return state.failActive?send({message:'Fixture failure'},500):send(state.active)
  if(path.endsWith('/get_user_dashboard_v3'))return send({daily:{completed:state.dailyDone,question_count:10}})
  if(path.endsWith('/get_revision_mode_availability_v1'))return send({total_questions:10,can_weak:false,can_visual:false,can_exam:false})
  if(path.endsWith('/get_study_priorities_v1'))return send({study_year:2,items:[]})
  if(path.endsWith('/get_user_stats_v3'))return send({period_days:30,summary:{attempts:0,correct_answers:0,incorrect_answers:0,accuracy_percent:0,avg_response_ms:0,completed_sessions:0,xp_total:240,level:3,attempted_questions:0,mastered_questions:0,fragile_questions:0,reviews_due:0,mastery_percent:0},daily_activity:[],subjects:[],modes:[],weak_questions:[]})
  if(path.endsWith('/get_gamification_summary_v2'))return state.failGame?send({message:'Fixture failure'},500):send({xp_total:240,level:{number:3,name:'Progression',progress_percent:80,xp_to_next:60},streak:{current:3,longest:4},badges:{earned:2,total:9}})
  if(path.endsWith('/get_badges_v2'))return send({badges:[],stats:{completed_quizzes:1,correct_answers:1,current_streak:3,daily_challenges:0,daily_perfect:false}})
  if(path.endsWith('/get_friendships_v3'))return send({friends:[],incoming:[],outgoing:[]})
  if(path.endsWith('/get_curriculum_progress_v1'))return send({coverage_percent:0,completion_percent:0,topics_total:0,topics_completed:0,questions_total:0,questions_answered:0})
  return send([])
 })
 return {state,calls}
}
