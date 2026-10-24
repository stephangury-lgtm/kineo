import { readFile } from 'node:fs/promises'
import { pathToFileURL } from 'node:url'
import path from 'node:path'

const repository = 'stephangury-lgtm/kineo'
const workflow = '.github/workflows/staging-acceptance.yml'

export function verifyStagingAcceptance(run, { sha, runId, repo, ref }) {
  if (repo !== repository || ref !== 'refs/heads/main' || !/^[a-f0-9]{40}$/.test(sha ?? '')) throw Error('Unexpected production context')
  if (!Number.isSafeInteger(runId) || runId <= 0 || run?.id !== runId) throw Error('Unexpected acceptance run')
  if (run.repository?.full_name !== repository || run.head_repository?.full_name !== repository) throw Error('Acceptance must come from this repository')
  if (run.path !== workflow || !['push', 'workflow_dispatch'].includes(run.event)) throw Error('Unexpected acceptance workflow or event')
  if (run.head_branch !== 'main' || run.head_sha !== sha) throw Error('Acceptance must cover the exact production commit on main')
  if (run.status !== 'completed' || run.conclusion !== 'success') throw Error('Connected acceptance has not succeeded')
  return run.head_sha
}

export async function loadVerifiedStagingAcceptance(event, context, fetchRun) {
  if (event?.repository?.full_name !== repository || event.workflow_run?.head_sha !== context.sha) throw Error('Stale or foreign acceptance event')
  const runId = event.workflow_run.id
  if (!Number.isSafeInteger(runId) || runId <= 0) throw Error('Invalid acceptance identity')
  const run = await fetchRun(runId)
  return verifyStagingAcceptance(run, { ...context, runId })
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  if (process.env.GITHUB_EVENT_NAME !== 'workflow_run' || !process.env.GH_TOKEN) throw Error('Trusted workflow-run context required')
  const event = JSON.parse(await readFile(process.env.GITHUB_EVENT_PATH, 'utf8'))
  const sha = await loadVerifiedStagingAcceptance(event, {
    sha: process.env.GITHUB_SHA, repo: process.env.GITHUB_REPOSITORY, ref: process.env.GITHUB_REF,
  }, async runId => {
    const response = await fetch(`https://api.github.com/repos/${repository}/actions/runs/${runId}`, {
      headers: { Authorization: `Bearer ${process.env.GH_TOKEN}`, Accept: 'application/vnd.github+json', 'X-GitHub-Api-Version': '2022-11-28' },
      redirect: 'error', signal: AbortSignal.timeout(15000),
    })
    if (!response.ok) throw Error(`Cannot verify acceptance run (${response.status})`)
    return response.json()
  })
  console.log(`Verified connected staging acceptance for ${sha}`)
}
