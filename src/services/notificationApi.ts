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

export async function markNotificationRead(notificationId: string) {
  const { error } = await supabase
    .from('notifications')
    .update({ read_at: new Date().toISOString() })
    .eq('id', notificationId)
    .is('read_at', null)

  if (error) throw error
  window.dispatchEvent(new Event('kineo-notifications-updated'))
}

export async function markAllNotificationsRead() {
  const { error } = await supabase
    .from('notifications')
    .update({ read_at: new Date().toISOString() })
    .is('read_at', null)

  if (error) throw error
  window.dispatchEvent(new Event('kineo-notifications-updated'))
}

export function subscribeToNotificationChanges(onChange: () => void) {
  let active = true
  let channel: ReturnType<typeof supabase.channel> | null = null

  void supabase.auth.getUser().then(({ data }) => {
    if (!active || !data.user) return
    channel = supabase
      .channel(`kineo-notifications-${data.user.id}`)
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
