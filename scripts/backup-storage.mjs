import {createClient} from '@supabase/supabase-js'
import {mkdir,writeFile} from 'node:fs/promises'
import {createHash} from 'node:crypto'
import path from 'node:path'
import {encryptBackup,decryptBackup} from './backup-crypto.mjs'

const root=process.env.LERYKO_BACKUP_DIRECTORY,password=process.env.LERYKO_BACKUP_PASSPHRASE
const url=process.env.SUPABASE_URL,key=process.env.SUPABASE_SERVICE_ROLE_KEY
if(!root||!password||password.length<20||!url||!key)throw new Error('Private backup directory, passphrase and server-only Supabase credentials required')
const client=createClient(url,key,{auth:{persistSession:false,autoRefreshToken:false}})
const target=path.join(root,`storage-${new Date().toISOString().replace(/[:.]/g,'-')}`)
await mkdir(target,{recursive:true,mode:0o700})
const manifest={version:1,created_at:new Date().toISOString(),complete:false,buckets:[],objects:[]}
const {data:buckets,error}=await client.storage.listBuckets()
if(error)throw new Error('Cannot list storage buckets')
async function copy(bucket,prefix=''){
 for(let offset=0;;offset+=100){
  const {data:items,error}=await client.storage.from(bucket).list(prefix,{limit:100,offset,sortBy:{column:'name',order:'asc'}})
  if(error||!items)throw new Error('Storage listing failed')
  for(const item of items){
   if(!item.name||item.name==='.'||item.name==='..'||item.name.includes('/')||item.name.includes('\\'))throw new Error('Unexpected object name')
   const name=prefix?`${prefix}/${item.name}`:item.name
   if(!item.id){await copy(bucket,name);continue}
   const {data,error}=await client.storage.from(bucket).download(name)
   if(error||!data)throw new Error('Storage download failed')
   const bytes=Buffer.from(await data.arrayBuffer()),encrypted=encryptBackup(bytes,password)
   if(!decryptBackup(encrypted,password).equals(bytes))throw new Error('Storage encryption verification failed')
   const file=createHash('sha256').update(bucket+'\0'+name).digest('hex')+'.leryko-backup'
   await writeFile(path.join(target,file),encrypted,{flag:'wx',mode:0o600})
   manifest.objects.push({bucket,name,file,bytes:bytes.length,sha256:createHash('sha256').update(bytes).digest('hex'),content_type:data.type})
  }
  if(items.length<100)break
 }
}
for(const bucket of buckets){
 manifest.buckets.push({id:bucket.id,public:bucket.public,file_size_limit:bucket.file_size_limit,allowed_mime_types:bucket.allowed_mime_types})
 await copy(bucket.id)
}
manifest.complete=true
await writeFile(path.join(target,'manifest.leryko-backup'),encryptBackup(Buffer.from(JSON.stringify(manifest)),password),{flag:'wx',mode:0o600})
console.log(`Encrypted storage backup complete: ${manifest.objects.length} objects. Schedule during a quiet window and reconcile concurrent writes before declaring a recoverable snapshot.`)
