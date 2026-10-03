import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { getUnreadNotificationCount, subscribeToNotificationChanges } from '../services/notificationApi'
import './NotificationBell.css'

type BadgeNavigator = Navigator & {
  setAppBadge?: (contents?: number) => Promise<void>
  clearAppBadge?: () => Promise<void>
}

function syncAppBadge(count: number) {
  const badgeNavigator = navigator as BadgeNavigator
  if (count > 0 && badgeNavigator.setAppBadge) {
    void badgeNavigator.setAppBadge(count).catch(() => undefined)
    return
  }
  if (count === 0 && badgeNavigator.clearAppBadge) {
    void badgeNavigator.clearAppBadge().catch(() => undefined)
  }
}

export default function NotificationBell() {
  const [count, setCount] = useState(0)

  useEffect(() => {
    let active = true
    const refresh = () => {
      void getUnreadNotificationCount()
        .then((value) => {
          if (!active) return
          setCount(value)
          syncAppBadge(value)
        })
        .catch(() => undefined)
    }

    refresh()
    const unsubscribeRealtime = subscribeToNotificationChanges(() => {
      refresh()
      window.dispatchEvent(new Event('kineo-notifications-updated'))
    })
    window.addEventListener('kineo-notifications-updated', refresh)
    window.addEventListener('focus', refresh)
    document.addEventListener('visibilitychange', refresh)

    return () => {
      active = false
      unsubscribeRealtime()
      window.removeEventListener('kineo-notifications-updated', refresh)
      window.removeEventListener('focus', refresh)
      document.removeEventListener('visibilitychange', refresh)
    }
  }, [])

  return (
    <Link className={`notification-bell${count > 0 ? ' has-unread' : ''}`} to="/notifications" aria-label={count > 0 ? `${count} notification${count > 1 ? 's' : ''} non lue${count > 1 ? 's' : ''}` : 'Notifications'} title={count > 0 ? `${count} notification${count > 1 ? 's' : ''} non lue${count > 1 ? 's' : ''}` : 'Notifications'}>
      <span aria-hidden="true">🔔</span>
      {count > 0 && <strong aria-live="polite">{count > 9 ? '9+' : count}</strong>}
    </Link>
  )
}
