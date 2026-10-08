/** Migrate embedded question images to Supabase Storage safely.
 * Required: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
 * Optional: DRY_RUN=false to write. Defaults to dry-run.
 * Run: node scripts/migrate-question-images.mjs
 */
import { createClient } from '@supabase/supabase-js'
import { createHash } from 'node:crypto'
const url=process.env.SUPABASE_URL
const key=process.env.SUPABASE_SERVICE_ROLE_KEY
if(!url||!key)throw Error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY')
const dry=process.env.DRY_RUN!=='false'
const supabase=createClient(url,key,{auth:{persistSession:false,autoRefreshToken:false}})
const bucket='anatomy-images'
let offset=0,scanned=0,migrated=0,failed=0
while(true){
 const {data,error}=await supabase.from('questions').select('id,image_url').like('image_url','data:image/%').range(offset,offset+99)
 if(error)throw error
 if(!data?.length)break
 for(const q of data){
  scanned++
  try{
   const match=/^data:image\/(png|jpeg|webp);base64,([A-Za-z0-9+/=]+)$/.exec(q.image_url)
   if(!match)throw Error('Unsupported image format')
   const ext=match[1]==='jpeg'?'jpg':match[1]
   const bytes=Buffer.from(match[2],'base64')
   if(bytes.length<100||bytes.length>5_000_000)throw Error('Invalid image size')
   const hash=createHash('sha256').update(bytes).digest('hex')
   const path=`questions/${q.id}/${hash.slice(0,16)}.${ext}`
   if(dry){console.log('DRY RUN',q.id,path);continue}
   const uploaded=await supabase.storage.from(bucket).upload(path,bytes,{contentType:`image/${match[1]}`,upsert:false})
   if(uploaded.error&&!/already exists|duplicate/i.test(uploaded.error.message))throw uploaded.error
   const {data:signed,error:signError}=await supabase.storage.from(bucket).createSignedUrl(path,60)
   if(signError||!signed?.signedUrl)throw signError||Error('Unable to verify upload')
   const {data:updated,error:updateError}=await supabase.from('questions').update({image_url:`${url}/storage/v1/object/authenticated/${bucket}/${path}`}).eq('id',q.id).eq('image_url',q.image_url).select('id')
   if(updateError||updated?.length!==1)throw updateError||Error('Concurrent update; original retained')
   migrated++
  }catch(e){failed++;console.error('FAILED',q.id,String(e))}
 }
 if(data.length<100)break
 // Writes shrink the query result set, so only offset on dry runs.
 if(dry)offset+=100
}
console.log(JSON.stringify({dry,scanned,migrated,failed}))
if(failed)process.exitCode=1
