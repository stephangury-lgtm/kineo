import { createClient } from 'npm:@supabase/supabase-js@2.57.4'
import { runRetention } from './worker.mjs'

const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), {
 status, headers: {'content-type': 'application/json', 'cache-control': 'no-store'},
})

Deno.serve(async (req: Request) => {
 if (req.method !== 'POST') return json({error: 'Method not allowed'}, 405)
 const token = req.headers.get('authorization')?.match(/^Bearer ([^\s]+)$/)?.[1]
 if (!token || token.length < 40 || token.length > 128) return json({error: 'Unauthorized'}, 401)
 const client = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, {
  auth: {persistSession: false, autoRefreshToken: false},
 })
 const rpc = async (name: string, args: Record<string, unknown>) => {
  const {data, error} = await client.rpc(name, args)
  if (error) throw new Error('Retention database operation failed')
  return data
 }
 let config
 try { config = await rpc('retention_worker_start_v1', {p_token: token}) }
 catch { return json({error: 'Retention unavailable'}, 503) }
 if (!config) return json({error: 'Unauthorized'}, 401)
 if (config.busy) return json({busy: true}, 202)
 let counts: Record<string, unknown> = {configured: Boolean(config.configured), errors: 1}
 try {
  let lastRequest = 0
  const resend = async (method: string, path: string, body?: unknown, idempotency?: string) => {
   const wait = 600 - (Date.now() - lastRequest)
   if (wait > 0) await new Promise(resolve => setTimeout(resolve, wait))
   lastRequest = Date.now()
   const headers: Record<string, string> = {Authorization: `Bearer ${config.resend_key}`, 'Content-Type': 'application/json'}
   if (idempotency) headers['Idempotency-Key'] = idempotency
   const response = await fetch(`https://api.resend.com${path}`, {
    method, headers, body: body === undefined ? undefined : JSON.stringify(body),
    signal: AbortSignal.timeout(15000),
   })
   // A previously recorded receipt remains valid after Resend's 30-day log retention.
   if (method === 'GET' && response.status === 404) return {retention_expired: true}
   if (!response.ok) throw new Error('Email provider unavailable')
   return response.json()
  }
  counts = await runRetention({rpc, auth: client.auth.admin, config, resend,
   removeAvatars: async (paths: string[]) => {
    const {error} = await client.storage.from('avatars').remove(paths)
    if (error) throw new Error('Storage cleanup failed')
   },
  })
  return json(counts, Number(counts.errors) ? 503 : 200)
 } catch { return json({error: 'Retention run failed'}, 503) }
 finally {
  await rpc('retention_worker_finish_v1', {p_lease: config.lease, p_result: counts}).catch(() => {})
 }
})
