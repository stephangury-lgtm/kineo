import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { getUnreadNotificationCount, subscribeToNotificationChanges } from '../services/notificationApi'
import './NotificationBell.css'

export default function NotificationBell() {
  const [count, setCount] = useState(0)

  useEffect(() => {
    let active = true
    const refresh = () => {
      void getUnreadNotificationCount()
        .then((value) => { if (active) setCount(value) })
        .catch(() => undefined)
    }

    refresh()
    const unsubscribeRealtime = subscribeToNotificationChanges(() => {
      refresh()
      window.dispatchEvent(new Event('kineo-notifications-updated'))
    })
    window.addEventListener('kineo-notifications-updated', refresh)
    window.addEventListener('focus', refresh)

    return () => {
      active = false
      unsubscribeRealtime()
      window.removeEventListener('kineo-notifications-updated', refresh)
      window.removeEventListener('focus', refresh)
    }
  }, [])

  return (
    <Link className="notification-bell" to="/notifications" aria-label={count > 0 ? `${count} notification${count > 1 ? 's' : ''} non lue${count > 1 ? 's' : ''}` : 'Notifications'}>
      <span aria-hidden="true">🔔</span>
      {count > 0 && <strong>{count > 9 ? '9+' : count}</strong>}
    </Link>
  )
}
