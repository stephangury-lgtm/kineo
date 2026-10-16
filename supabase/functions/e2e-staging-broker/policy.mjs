const repository='stephangury-lgtm/kineo'
export function verifyWorkflowClaims(claims){
 if(claims.repository!==repository||!['refs/heads/main','refs/heads/feat/leryko-v5-interface'].includes(claims.ref))throw Error('Repository or ref not allowed')
 if(!['push','workflow_dispatch'].includes(claims.event_name))throw Error('Event not allowed')
 if(claims.workflow_ref!==`${repository}/.github/workflows/staging-acceptance.yml@${claims.ref}`)throw Error('Workflow not allowed')
 if(!/^\d{1,20}$/.test(String(claims.run_id??'')))throw Error('Missing run identity')
}
export function canDeleteFixture(user,claims){
 return user?.app_metadata?.leryko_e2e===true&&user.app_metadata.github_run_id===String(claims.run_id)
  &&/^kineo-e2e(?:-friend)?\+\d+-[a-zA-Z0-9_-]+@example\.com$/.test(user.email??'')
}
