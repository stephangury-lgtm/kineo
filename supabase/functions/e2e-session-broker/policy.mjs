const repo='stephangury-lgtm/kineo'
const workflows=['browser-smoke.yml','production-auth-smoke.yml']

// Called only after cryptographic JWT issuer/audience/signature verification.
export function verifyWorkflowClaims(claims){
 if(claims.repository!==repo||claims.ref!=='refs/heads/main')throw new Error('Repository or ref not allowed')
 if(!['push','workflow_dispatch','workflow_run','schedule'].includes(claims.event_name))throw new Error('Event not allowed')
 if(!workflows.some(file=>claims.workflow_ref===`${repo}/.github/workflows/${file}@refs/heads/main`))throw new Error('Workflow not allowed')
 if(!/^\d{1,20}$/.test(String(claims.run_id??'')))throw new Error('Missing run identity')
}

export function canDeleteFixture(user,claims){
 return user?.app_metadata?.leryko_e2e===true
  &&user.app_metadata.github_run_id===String(claims.run_id)
  &&/^kineo-e2e(?:-friend)?\+\d+-[a-zA-Z0-9_-]+@example\.com$/.test(user.email??'')
}
