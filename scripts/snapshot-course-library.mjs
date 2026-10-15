import {readFile,writeFile,mkdir,copyFile} from 'node:fs/promises'
import {createHash} from 'node:crypto'
import path from 'node:path'
const [manifestFile,destination]=process.argv.slice(2)
if(!manifestFile||!destination)throw new Error('Provide the migration manifest and a new private snapshot directory')
const rows=JSON.parse(await readFile(manifestFile,'utf8'))
await mkdir(destination,{recursive:false,mode:0o700})
const result=[]
for(const item of rows){
 if(!/^[0-9a-f-]{36}$/.test(item.document_id))throw new Error('Invalid course ID')
 const bytes=await readFile(item.staged_path)
 if(bytes.length!==item.bytes||createHash('sha256').update(bytes).digest('hex')!==item.sha256)throw new Error('Original course hash mismatch')
 const file=item.document_id+'.pdf',target=path.join(destination,file)
 await copyFile(item.staged_path,target)
 const restored=await readFile(target)
 if(!restored.equals(bytes))throw new Error('Snapshot copy verification failed')
 result.push({document_id:item.document_id,title:item.title,bucket:'documents',storage_path:item.storage_path,file,bytes:item.bytes,sha256:item.sha256})
}
await writeFile(path.join(destination,'manifest.json'),JSON.stringify({created_at:new Date().toISOString(),scope:'course PDFs only; no database, avatars or user accounts',objects:result},null,2),{flag:'wx',mode:0o600})
console.log(`Verified local snapshot: ${result.length} course PDFs, ${result.reduce((n,x)=>n+x.bytes,0)} bytes. This is not an off-site database backup.`)
