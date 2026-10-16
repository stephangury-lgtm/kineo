import {readFile,appendFile,writeFile} from 'node:fs/promises'
import {selectDeployment,validateTarget} from '../release-safety.mjs'
const current=selectDeployment(JSON.parse(await readFile('staging-deployments.json','utf8')))
validateTarget(current.version,process.env.GITHUB_SHA)
const response=await fetch('https://leryko-v5-staging.stephangury.workers.dev/version.json',{cache:'no-store',signal:AbortSignal.timeout(15000)})
if(!response.ok)throw Error('Staging version unavailable')
const live=await response.json()
if(live.commit!==process.env.GITHUB_SHA||live.interface!=='legacy')throw Error('Unexpected staging rollback baseline')
await writeFile('staging-rollback-target.json',JSON.stringify({...current,...live},null,2)+'\n')
await appendFile(process.env.GITHUB_ENV,`STAGING_PREVIOUS_VERSION=${current.version}\n`)
console.log('Exact staging rollback target captured: '+current.version)
