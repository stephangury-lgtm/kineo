// Modern server keys only. Never expose values in diagnostics or fall back to
// a legacy JWT after the old API keys have been disabled.
export function readServerKey(getEnv){
 let keys
 try{keys=JSON.parse(getEnv('SUPABASE_SECRET_KEYS')||'{}')}catch{throw new Error('Invalid server key configuration')}
 const key=keys?.default
 if(typeof key!=='string'||!/^sb_secret_[A-Za-z0-9_-]{20,}$/.test(key))throw new Error('Modern default server key required')
 return key
}
export function createServerClient(createClient,getEnv){
 const url=getEnv('SUPABASE_URL')
 if(!url||new URL(url).protocol!=='https:')throw new Error('Server project URL required')
 const key=readServerKey(getEnv),origin=new URL(url).origin
 return createClient(url,key,{
  auth:{persistSession:false,autoRefreshToken:false},
  global:{fetch:async(input,init)=>{
   const target=new URL(typeof input==='string'?input:input.url||input.toString())
   if(target.origin!==origin)throw new Error('Unexpected server API destination')
   const headers=new Headers(init?.headers)
   if(headers.get('authorization')===`Bearer ${key}`)headers.delete('authorization')
   return fetch(input,{...init,headers,redirect:'error'})
  }},
 })
}

