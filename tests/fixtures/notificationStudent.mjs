import {v5Student} from './v5Student.mjs'
export const notificationDuelId='0c9b0764-f420-4b3a-9950-9cd91083da90'
export async function notificationStudent(page,{program='kineo-fr',unread=true}={}){
 await v5Student(page,{program})
 const friend={id:'friend',friendship_id:'relation',first_name:'Alex',username:'alex',same_level:true}
 const duel={id:notificationDuelId,status:'completed',direction:'sent',challenger_score:40,challenged_score:80,created_at:'2026-10-24',completed_at:'2026-10-24',opponent:friend}
 const state={notifications:[],messages:[],failPatch:false,patches:0,holdNextLatest:false,releaseLatest:null,holdRead:false,releaseRead:null}
 const addNotification=(id='c0000000-0000-4000-8000-000000000001')=>{
  state.notifications.push({id,type:'challenge_message',title:'Un message d’après-match',body:'Alex t’a laissé un message.',data:{program_id:program,[program==='kineo-fr'?'challenge_id':'curriculum_challenge_id']:notificationDuelId},read_at:null,created_at:new Date().toISOString()})
 }
 if(unread)addNotification()
 await page.route('**/rest/v1/notifications*',async route=>{
  const request=route.request(),url=new URL(request.url())
  const pending=()=>state.notifications.filter(row=>!row.read_at)
  if(request.method()==='HEAD')return route.fulfill({status:200,headers:{'content-range':'*/'+pending().length}})
  if(request.method()==='PATCH'){
   state.patches++
   if(state.failPatch)return route.fulfill({status:503,json:{message:'Temporary acknowledgement failure'}})
   const id=url.searchParams.get('id')?.replace(/^eq\./,'')
   for(const row of pending())if(!id||row.id===id)row.read_at=new Date().toISOString()
   return route.fulfill({status:204})
  }
  const latest=url.searchParams.get('limit')==='1'
  let rows=(url.searchParams.get('read_at')==='is.null'?pending():state.notifications).map(row=>({...row}))
  if(latest)rows=rows.slice(-1)
  if(latest&&state.holdNextLatest){
   state.holdNextLatest=false
   state.releaseLatest=()=>route.fulfill({json:rows,headers:{'x-notification-snapshot':'held'}})
   return
  }
  return route.fulfill({json:rows})
 })
 await page.route('**/rest/v1/rpc/*',async route=>{
  const rpc=new URL(route.request().url()).pathname.split('/').pop()
  if(rpc==='get_friendships_v3')return route.fulfill({json:{friends:[friend],incoming:[],outgoing:[]}})
  if(['get_friend_challenges_v3','get_curriculum_friend_challenges_v1'].includes(rpc))return route.fulfill({json:[duel]})
  if(rpc==='get_curriculum_challenge_availability_v1')return route.fulfill({json:{can_challenge:true,validated_mcq:10}})
  if(rpc==='read_friend_challenge_messages_v1'){
   const respond=()=>{
    for(const row of state.notifications)row.read_at??=new Date().toISOString()
    return route.fulfill({json:{messages:state.messages,can_send:true}})
   }
   if(state.holdRead){state.holdRead=false;state.releaseRead=respond;return}
   return respond()
  }
  return route.fallback()
 })
 return {state,addNotification}
}
