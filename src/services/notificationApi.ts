import { supabase } from '../lib/supabase'

export type KineoNotification = {
  id: string
  type: string
  title: string
  body: string | null
  data: Record<string, unknown>
  read_at: string | null
  created_at: string
}

export async function getNotifications(limit = 40) {
  const { data, error } = await supabase
    .from('notifications')
    .select('id,type,title,body,data,read_at,created_at')
    .order('created_at', { ascending: false })
    .limit(limit)

  if (error) throw error
  return (data ?? []) as KineoNotification[]
}

export async function getUnreadNotificationCount() {
  const { count, error } = await supabase
    .from('notifications')
    .select('id', { count: 'exact', head: true })
    .is('read_at', null)

  if (error) throw error
  return count ?? 0
}

export function notifyNotificationsUpdated() {
  window.dispatchEvent(new Event('kineo-notifications-updated'))
}

export async function markNotificationRead(notificationId: string) {
  const { error } = await supabase
    .from('notifications')
    .update({ read_at: new Date().toISOString() })
    .eq('id', notificationId)
    .is('read_at', null)

  if (error) throw error
  notifyNotificationsUpdated()
}

export async function markAllNotificationsRead() {
  const { error } = await supabase
    .from('notifications')
    .update({ read_at: new Date().toISOString() })
    .is('read_at', null)

  if (error) throw error
  notifyNotificationsUpdated()
}

let notificationSubscriptionId = 0

export function subscribeToNotificationChanges(onChange: () => void) {
  let active = true
  const subscriptionId = ++notificationSubscriptionId
  let channel: ReturnType<typeof supabase.channel> | null = null

  void supabase.auth.getUser().then(({ data }) => {
    if (!active || !data.user) return
    channel = supabase
      .channel(`kineo-notifications-${data.user.id}-${subscriptionId}`)
      .on('postgres_changes', {
        event: '*',
        schema: 'public',
        table: 'notifications',
        filter: `user_id=eq.${data.user.id}`,
      }, () => onChange())
      .subscribe()
  }).catch(() => undefined)

  return () => {
    active = false
    if (channel) void supabase.removeChannel(channel)
  }
}

export async function getLatestUnreadChallengeNotification() {
  const { data, error } = await supabase.from('notifications')
    .select('id,type,title,body,data,read_at,created_at')
    .in('type', ['challenge_received','challenge_completed','challenge_message']).is('read_at', null)
    .order('created_at', { ascending: false }).limit(1)
  if (error) throw error
  return (data?.[0] ?? null) as KineoNotification | null
}

export function challengeNotificationDestination(notification: KineoNotification) {
 const id=notification.data.challenge_id??notification.data.curriculum_challenge_id
 return notification.type==='challenge_message'&&typeof id==='string'&&/^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$/i.test(id)
  ? `/amis?tab=challenges&discussion=${encodeURIComponent(id)}${['kineo-fr','kineo-es','ifsi-fr'].includes(String(notification.data.program_id))?`&program=${notification.data.program_id}`:''}` : '/amis?tab=challenges'
}
