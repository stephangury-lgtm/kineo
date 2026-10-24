import {test} from 'node:test'
import assert from 'node:assert/strict'
import {verifyStagingAcceptance,loadVerifiedStagingAcceptance} from '../../scripts/verify-staging-acceptance.mjs'
const repo='stephangury-lgtm/kineo', sha='a'.repeat(40)
const context={sha,runId:123,repo,ref:'refs/heads/main'}
const run={id:123,repository:{full_name:repo},head_repository:{full_name:repo},path:'.github/workflows/staging-acceptance.yml',event:'push',head_branch:'main',head_sha:sha,status:'completed',conclusion:'success'}
test('only successful connected acceptance from the exact main commit authorizes publication',()=>{
 assert.equal(verifyStagingAcceptance(run,context),sha)
 for(const delta of [{id:124},{repository:{full_name:'foreign/repo'}},{head_repository:{full_name:'foreign/repo'}},{path:'.github/workflows/ci.yml'},{event:'pull_request'},{head_branch:'feature'},{head_sha:'b'.repeat(40)},{status:'in_progress'},{conclusion:'failure'},{conclusion:'cancelled'},{conclusion:'skipped'}])assert.throws(()=>verifyStagingAcceptance({...run,...delta},context))
 for(const delta of [{repo:'foreign/repo'},{ref:'refs/pull/46/merge'},{sha:'invalid'},{runId:NaN}])assert.throws(()=>verifyStagingAcceptance(run,{...context,...delta}))
})
test('the event cannot substitute a successful payload for a failed API run',async()=>{
 const event={repository:{full_name:repo},workflow_run:{...run}}
 await assert.rejects(loadVerifiedStagingAcceptance(event,context,async()=>({...run,conclusion:'failure'})))
 assert.equal(await loadVerifiedStagingAcceptance(event,context,async id=>{assert.equal(id,123);return run}),sha)
})
test('stale and foreign events fail before requesting a run',async()=>{
 let requests=0
 const fetchRun=async()=>{requests++;return run}
 for(const event of [{repository:{full_name:'foreign/repo'},workflow_run:run},{repository:{full_name:repo},workflow_run:{...run,head_sha:'b'.repeat(40)}},{repository:{full_name:repo},workflow_run:{...run,id:'123'}}])await assert.rejects(loadVerifiedStagingAcceptance(event,context,fetchRun))
 assert.equal(requests,0)
})
