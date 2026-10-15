const productionUrl='https://kimtiyuytikyseuzmjbv.supabase.co'
const productionKey='sb_publishable_ANuwDKjYwbR2LF629eqK9Q_izXQUycB'
export function resolveBackend(env:Record<string,string|undefined>){
 const mode=env.VITE_BACKEND_ENV||'production'
 // Production stays pinned even if an old hosting variable remains configured.
 if(mode==='production')return {url:productionUrl,key:productionKey,production:true}
 if(mode!=='staging')throw new Error('Unknown backend environment')
 const url=env.VITE_SUPABASE_URL?.replace(/\/$/,''),key=env.VITE_SUPABASE_PUBLISHABLE_KEY
 if(!url||!key)throw new Error('Staging requires its own URL and publishable key')
 const parsed=new URL(url)
 if(parsed.origin!==url||parsed.protocol!=='https:'||parsed.hostname==='kimtiyuytikyseuzmjbv.supabase.co')throw new Error('Staging must use a separate HTTPS backend')
 if(!key.startsWith('sb_publishable_')||key===productionKey)throw new Error('Staging requires its own public publishable key')
 return {url,key,production:false}
}
