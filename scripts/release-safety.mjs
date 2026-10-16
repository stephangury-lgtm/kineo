import {appendFile,readFile,writeFile} from 'node:fs/promises'
import {pathToFileURL} from 'node:url'
import path from 'node:path'
const uuid=/^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/i
const isUuid=value=>typeof value==='string'&&value.length===36&&uuid.test(value)
export function validateTarget(version,commit){
 if(!isUuid(version)||typeof commit!=='string'||commit.length!==40||!/^[a-f0-9]{40}$/.test(commit))throw new Error('An explicit Cloudflare version UUID and full commit SHA are required')
}
export function selectDeployment(rows){
 if(!Array.isArray(rows)||!rows.length||rows.some(row=>!Number.isFinite(Date.parse(row.created_on))))throw new Error('Invalid deployment history')
 const latest=[...rows].sort((a,b)=>Date.parse(b.created_on)-Date.parse(a.created_on))[0]
 if(!isUuid(latest.id)||latest.versions?.length!==1||latest.versions[0].percentage!==100||!isUuid(latest.versions[0].version_id))throw new Error('Rollback requires a known single version at 100 percent')
 return {deployment:latest.id,version:latest.versions[0].version_id}
}
export function assertUnchanged(rows,snapshot){
 const current=selectDeployment(rows)
 if(current.deployment!==snapshot.deployment||current.version!==snapshot.version)throw new Error('Cloudflare deployment changed after capture; publication stopped')
}
if(process.argv[1]&&import.meta.url===pathToFileURL(path.resolve(process.argv[1])).href){
 const mode=process.argv[2]
 if(mode==='validate-target')validateTarget(process.env.TARGET_VERSION,process.env.TARGET_COMMIT)
 else{
  const rows=JSON.parse(await readFile('cloudflare-deployments.json','utf8'))
  if(mode==='assert-current')assertUnchanged(rows,JSON.parse(await readFile('release-before.json','utf8')))
  else if(mode==='capture'){
   const current=selectDeployment(rows)
   const response=await fetch('https://kineo.stephangury.workers.dev/version.json?release='+Date.now(),{cache:'no-store',redirect:'error',signal:AbortSignal.timeout(15000)})
   if(!response.ok)throw new Error('Cannot identify the live frontend before publication')
   const live=await response.json()
   validateTarget(current.version,live.commit)
   const interfaceMode=live.interface??'legacy'
   if(!['legacy','preview','v5'].includes(interfaceMode))throw new Error('Unknown live interface')
   const snapshot={...current,commit:live.commit,interface:interfaceMode,captured_at:new Date().toISOString()}
   await writeFile('release-before.json',JSON.stringify(snapshot,null,2)+'\n')
   if(process.env.GITHUB_OUTPUT)await appendFile(process.env.GITHUB_OUTPUT,`previous_version=${current.version}\nprevious_commit=${live.commit}\nprevious_interface=${interfaceMode}\n`)
   console.log(`Captured exact rollback target ${current.version}`)
  }else throw new Error('Unknown release-safety operation')
 }
}
