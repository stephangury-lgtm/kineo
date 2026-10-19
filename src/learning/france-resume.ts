import {getActiveRevisionSessionV1,type ActiveRevisionSession} from '../services/kineoApi'
import {supabase} from '../lib/supabase'
export async function getFranceActiveSession():Promise<ActiveRevisionSession|null>{
 const [regular,daily]=await Promise.all([getActiveRevisionSessionV1(),supabase.rpc('get_active_daily_revision_session_v1')])
 if(daily.error)throw daily.error
 return regular??daily.data
}
export function franceResumePath(session:ActiveRevisionSession){
 return '/quiz?mode='+(session.mode==='daily'?'daily':'resume')+'&session='+encodeURIComponent(session.id)
}
