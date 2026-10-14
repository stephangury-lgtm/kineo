export function deliveryState(email, notice) {
 if (email?.id !== notice.provider_id || !Array.isArray(email.to) ||
     email.to.length !== 1 || email.to[0].toLowerCase() !== notice.recipient.toLowerCase()) return 'blocked'
 if (['bounced','complained','failed','canceled','suppressed'].includes(email.last_event)) return 'blocked'
 if (['delivered','opened','clicked'].includes(email.last_event)) return 'delivered'
 return 'waiting'
}

export function noticeEmail(recipient, sender) {
 return {
  from: sender, to: [recipient], reply_to: 'stephangury@gmail.com',
  subject: 'Leryko : ton compte inactif pourra être supprimé dans 30 jours',
  text: 'Bonjour,\n\nTon compte Leryko est inactif depuis au moins 24 mois. Pour limiter la conservation des données, sa suppression est prévue au plus tôt 30 jours après la remise de cet avertissement.\n\nPour conserver ton compte et ta progression, reconnecte-toi et utilise l’application :\nhttps://kineo.stephangury.workers.dev\n\nUne nouvelle activité annule cette procédure. Sans reprise d’activité, le compte, la progression, les relations sociales et la photo de profil seront supprimés. Pour obtenir tes données ou demander une suspension, écris à stephangury@gmail.com. Ne communique jamais ton mot de passe.\n\nCet avertissement concerne la gestion de ton compte, indépendamment de ton choix de recevoir des rappels de révision.\n\nStéphan Gury — Leryko\nhttps://kineo.stephangury.workers.dev/informations',
 }
}

export async function runRetention({rpc, auth, removeAvatars, resend, config}) {
 const counts = {configured: Boolean(config.configured), warned: 0, delivered: 0, deleted: 0, blocked: 0, errors: 0}
 if (!config.configured) return counts
 const lease = config.lease
 const jobs = await rpc('retention_jobs_v1', {p_lease: lease})
 for (const job of jobs) {
  try {
   if (['pending','sending'].includes(job.state)) {
    const sending = await rpc('retention_notice_result_v1', {p_lease: lease, p_id: job.id, p_event: 'sending'})
    if (!sending) continue
    const sent = await resend('POST', '/emails', noticeEmail(job.recipient, config.sender), `retention/${job.id}`)
    if (!sent?.id) throw new Error('Provider did not confirm send')
    await rpc('retention_notice_result_v1', {p_lease: lease, p_id: job.id, p_event: 'sent', p_provider_id: sent.id})
    counts.warned++
    continue
   }
   if (job.state !== 'deleting') {
    const email = await resend('GET', `/emails/${encodeURIComponent(job.provider_id)}`)
    const state = deliveryState(email, job)
    if (state === 'waiting') continue
    const updated = await rpc('retention_notice_result_v1', {p_lease: lease, p_id: job.id, p_event: state})
    if (state === 'blocked') {counts.blocked++; continue}
    if (!updated) continue
    counts.delivered++
    // The database, not the browser/worker clock, enforces the complete grace period.
   }
   let claim = await rpc('retention_claim_delete_v1', {p_lease: lease, p_id: job.id})
   if (!claim) continue
   const userId = claim.user_id
   const banned = await auth.updateUserById(userId, {ban_duration: '876000h'})
   if (banned.error) throw new Error('Unable to lock account')
   let batches = 0
   while (claim.avatars.length) {
    if (++batches > 10) throw new Error('Storage cleanup will resume next run')
    // Delete the binary objects through Storage, never with SQL.
    await removeAvatars(claim.avatars)
    claim = await rpc('retention_claim_delete_v1', {p_lease: lease, p_id: job.id})
    if (!claim || claim.user_id !== userId) throw new Error('Deletion claim lost')
   }
   const deleted = await auth.deleteUser(userId, false)
   if (deleted.error) throw new Error('Auth deletion failed')
   counts.deleted++
  } catch {
   // Counts only: no addresses, credentials or arbitrary provider errors in logs.
   counts.errors++
  }
 }
 return counts
}
