import {test} from 'node:test'
import assert from 'node:assert/strict'
import {verifyWorkflowClaims,canDeleteFixture} from '../../supabase/functions/e2e-session-broker/policy.mjs'
const claims={repository:'stephangury-lgtm/kineo',ref:'refs/heads/main',event_name:'workflow_run',run_id:'123',workflow_ref:'stephangury-lgtm/kineo/.github/workflows/production-auth-smoke.yml@refs/heads/main'}
test('Broker accepts only approved workflows from main',()=>{
 assert.doesNotThrow(()=>verifyWorkflowClaims(claims))
 for(const override of [{repository:'attacker/kineo'},{ref:'refs/pull/1/merge'},{event_name:'pull_request'},{workflow_ref:'stephangury-lgtm/kineo/.github/workflows/untrusted.yml@refs/heads/main'},{run_id:''}])assert.throws(()=>verifyWorkflowClaims({...claims,...override}))
})
test('Cleanup rejects editable metadata, foreign run and real users',()=>{
 const fixture={email:'kineo-e2e+123-webkit@example.com',app_metadata:{leryko_e2e:true,github_run_id:'123'}}
 assert.equal(canDeleteFixture(fixture,claims),true)
 assert.equal(canDeleteFixture({...fixture,app_metadata:{},user_metadata:{e2e:true}},claims),false)
 assert.equal(canDeleteFixture(fixture,{...claims,run_id:'456'}),false)
 assert.equal(canDeleteFixture({...fixture,email:'real@example.com'},claims),false)
})
