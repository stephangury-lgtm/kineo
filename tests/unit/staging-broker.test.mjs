import {test} from 'node:test'
import assert from 'node:assert/strict'
import {verifyWorkflowClaims,canDeleteFixture} from '../../supabase/functions/e2e-staging-broker/policy.mjs'
const claims={repository:'stephangury-lgtm/kineo',ref:'refs/heads/feat/leryko-v5-interface',event_name:'push',workflow_ref:'stephangury-lgtm/kineo/.github/workflows/staging-acceptance.yml@refs/heads/feat/leryko-v5-interface',run_id:'123456'}
test('staging broker only trusts its exact repository, ref, workflow and run',()=>{
 assert.doesNotThrow(()=>verifyWorkflowClaims(claims))
 for(const invalid of [{repository:'someone/kineo'},{ref:'refs/pull/21/merge'},{event_name:'pull_request'},{workflow_ref:'stephangury-lgtm/kineo/.github/workflows/other.yml@refs/heads/main'},{run_id:'invalid'}])assert.throws(()=>verifyWorkflowClaims({...claims,...invalid}))
})
test('staging cleanup requires server metadata and ownership by the same workflow run',()=>{
 const user={email:'kineo-e2e+123456-staging@example.com',app_metadata:{leryko_e2e:true,github_run_id:'123456'}}
 assert.equal(canDeleteFixture(user,claims),true)
 assert.equal(canDeleteFixture({...user,app_metadata:{...user.app_metadata,github_run_id:'999'}},claims),false)
 assert.equal(canDeleteFixture({...user,app_metadata:{},user_metadata:user.app_metadata},claims),false)
 assert.equal(canDeleteFixture({...user,email:'real@example.com'},claims),false)
})
