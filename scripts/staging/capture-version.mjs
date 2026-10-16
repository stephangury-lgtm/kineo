import {readFile,appendFile,writeFile} from 'node:fs/promises'
import {selectDeployment,validateTarget} from '../release-safety.mjs'
import {awaitRelease} from './await-release.mjs'
const current=selectDeployment(JSON.parse(await readFile('staging-deployments.json','utf8')))
validateTarget(current.version,process.env.GITHUB_SHA)
const live=await awaitRelease({url:'https://leryko-v5-staging.stephangury.workers.dev/version.json',sha:process.env.GITHUB_SHA,interface:'legacy'})
await writeFile('staging-rollback-target.json',JSON.stringify({...current,...live},null,2)+'\n')
await appendFile(process.env.GITHUB_ENV,`STAGING_PREVIOUS_VERSION=${current.version}\n`)
console.log('Exact staging rollback target captured: '+current.version)

