import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { challengeNotificationDestination, getUnreadNotificationCount, getLatestUnreadChallengeNotification, markNotificationRead, subscribeToNotificationChanges, type KineoNotification } from '../services/notificationApi'
import { getCurrentProgram } from '../curriculum/programs'
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
  const isSpain=getCurrentProgram().id==='kineo-es'
  const [count, setCount] = useState(0)
  const [challenge, setChallenge] = useState<KineoNotification|null>(null)

  useEffect(() => {
    let active = true
    const refresh = () => {
      void Promise.all([getUnreadNotificationCount(),getLatestUnreadChallengeNotification()])
        .then(([value,latest]) => {
          if (!active) return
          setCount(value)
          setChallenge(latest)
          syncAppBadge(value)
        })
        .catch(() => undefined)
    }

    refresh()
    const timer=window.setInterval(()=>{if(document.visibilityState==='visible')refresh()},30000)
    const onVisibility = () => {
      if (document.visibilityState === 'visible') refresh()
    }
    const unsubscribeRealtime = subscribeToNotificationChanges(() => {
      refresh()
      window.dispatchEvent(new Event('kineo-notifications-updated'))
    })
    window.addEventListener('kineo-notifications-updated', refresh)
    window.addEventListener('focus', refresh)
    document.addEventListener('visibilitychange', onVisibility)

    return () => {
      active = false
      window.clearInterval(timer)
      unsubscribeRealtime()
      window.removeEventListener('kineo-notifications-updated', refresh)
      window.removeEventListener('focus', refresh)
      document.removeEventListener('visibilitychange', onVisibility)
    }
  }, [])

  const notificationLabel=count>0?(isSpain?`${count} notificación${count>1?'es':''} sin leer`:`${count} notification${count > 1 ? 's' : ''} non lue${count > 1 ? 's' : ''}`):(isSpain?'Notificaciones':'Notifications')
  return (
    <>
    <Link className={`notification-bell${count > 0 ? ' has-unread' : ''}`} to="/notifications" aria-label={notificationLabel} title={notificationLabel}>
      <span aria-hidden="true">🔔</span>
      {count > 0 && <strong aria-live="polite">{count > 9 ? '9+' : count}</strong>}
    </Link>
    {challenge&&<aside className="challenge-notice" aria-live="polite"><span>⚔️ {challenge.type!=='challenge_received'?challenge.title:(isSpain?'¡Has recibido un reto!':'Tu as reçu un défi !')}</span>{challenge.body&&<p>{challenge.body}</p>}<Link to={challengeNotificationDestination(challenge)} onClick={()=>{void markNotificationRead(challenge.id).catch(()=>undefined);setChallenge(null)}}>{challenge.type==='challenge_message'?(isSpain?'Leer el mensaje':'Lire le message'):challenge.type==='challenge_completed'?(isSpain?'Ver el resultado':'Voir le résultat'):(isSpain?'Ver el reto':'Voir le défi')} →</Link></aside>}
    </>
  )
}
