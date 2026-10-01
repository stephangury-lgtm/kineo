import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { getNotifications, markAllNotificationsRead, markNotificationRead, subscribeToNotificationChanges, type KineoNotification } from '../services/notificationApi'
import './NotificationsPage.css'

function iconFor(type: string) {
  if (type.includes('challenge')) return '⚔️'
  if (type.includes('friend')) return '👥'
  if (type.includes('badge')) return '🏅'
  if (type.includes('streak')) return '🔥'
  return '🔔'
}

function destination(notification: KineoNotification) {
  if (notification.type.includes('challenge') || notification.type.includes('friend')) return '/amis'
  if (notification.type.includes('badge')) return '/rewards'
  return '/'
}

function relativeDate(value: string) {
  const date = new Date(value)
  const diff = Date.now() - date.getTime()
  const minutes = Math.floor(diff / 60000)
  if (minutes < 1) return 'À l’instant'
  if (minutes < 60) return `Il y a ${minutes} min`
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `Il y a ${hours} h`
  const days = Math.floor(hours / 24)
  if (days < 7) return `Il y a ${days} j`
  return date.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' })
}

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<KineoNotification[]>([])
  const [loading, setLoading] = useState(true)
  const [busy, setBusy] = useState(false)
  const [message, setMessage] = useState<string | null>(null)

  async function refresh() {
    setNotifications(await getNotifications())
  }

  useEffect(() => {
    void refresh().catch((err: Error) => setMessage(err.message)).finally(() => setLoading(false))
    const unsubscribe = subscribeToNotificationChanges(() => {
      void refresh().catch(() => undefined)
    })
    return unsubscribe
  }, [])

  async function markOne(item: KineoNotification) {
    if (!item.read_at) {
      await markNotificationRead(item.id)
      setNotifications((rows) => rows.map((row) => row.id === item.id ? { ...row, read_at: new Date().toISOString() } : row))
    }
  }

  async function markAll() {
    setBusy(true)
    setMessage(null)
    try {
      await markAllNotificationsRead()
      const now = new Date().toISOString()
      setNotifications((rows) => rows.map((row) => ({ ...row, read_at: row.read_at ?? now })))
    } catch (err) {
      setMessage(err instanceof Error ? err.message : 'Impossible de mettre les notifications à jour.')
    } finally {
      setBusy(false)
    }
  }

  const unread = notifications.filter((item) => !item.read_at).length

  if (loading) return <section className="card skeleton-card"><p>Chargement des notifications…</p></section>

  return (
    <div className="stack notification-page">
      <section className="hero-card notification-hero">
        <div className="hero-copy"><span className="hero-kicker">Rester dans le rythme</span><h1>Notifications 🔔</h1><p>Retrouve tes défis, demandes d’amis et récompenses au même endroit.</p></div>
        <div className="notification-counter"><strong>{unread}</strong><span>non lue{unread > 1 ? 's' : ''}</span></div>
      </section>

      <section className="card notification-toolbar">
        <div><p className="eyebrow">Centre d’activité</p><h2>{notifications.length ? `${notifications.length} notification${notifications.length > 1 ? 's' : ''}` : 'Aucune notification'}</h2></div>
        {unread > 0 && <button className="secondary-button compact-button" disabled={busy} onClick={() => void markAll()}>{busy ? '…' : 'Tout marquer comme lu'}</button>}
      </section>

      {notifications.length === 0 ? <section className="card empty-notifications"><span>✨</span><strong>Tout est calme</strong><p>Les invitations, défis et récompenses apparaîtront ici.</p><Link className="primary-button" to="/amis">Voir mes amis</Link></section> : <section className="card notification-list">{notifications.map((item) => (
        <Link key={item.id} to={destination(item)} className={`notification-item ${item.read_at ? '' : 'is-unread'}`} onClick={() => void markOne(item)}>
          <div className="notification-icon">{iconFor(item.type)}</div>
          <div className="notification-copy"><div><strong>{item.title}</strong><span>{relativeDate(item.created_at)}</span></div>{item.body && <p>{item.body}</p>}</div>
          {!item.read_at && <i aria-label="Non lue" />}
        </Link>
      ))}</section>}

      {message && <section className="card feedback-card"><p className="feedback">{message}</p></section>}
    </div>
  )
}
