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
  const [marking, setMarking] = useState(false)
  const [readErrorId, setReadErrorId] = useState<string|null>(null)

  async function readBanner(id: string) {
    setMarking(true)
    setReadErrorId(null)
    try {
      await markNotificationRead(id)
      setChallenge(current => current?.id === id ? null : current)
    } catch {
      setReadErrorId(id)
    } finally {
      setMarking(false)
    }
  }

  useEffect(() => {
    let active = true
    let requestVersion = 0
    const refresh = () => {
      const version = ++requestVersion
      void Promise.all([getUnreadNotificationCount(),getLatestUnreadChallengeNotification()])
        .then(([value,latest]) => {
          // A read acknowledgement invalidates every request started before it.
          if (!active || version !== requestVersion) return
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
      window.dispatchEvent(new Event('kineo-notifications-updated'))
    })
    window.addEventListener('kineo-notifications-updated', refresh)
    window.addEventListener('focus', refresh)
    document.addEventListener('visibilitychange', onVisibility)

    return () => {
      active = false
      ++requestVersion
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
    {challenge&&<aside className="challenge-notice" aria-live="polite"><button className="challenge-notice-read" type="button" disabled={marking} aria-label={isSpain?'Marcar como leída':'Marquer comme lue'} title={isSpain?'Marcar como leída':'Marquer comme lue'} onClick={()=>void readBanner(challenge.id)}>×</button><Link className="challenge-notice-content" to={challengeNotificationDestination(challenge)} onClick={()=>void readBanner(challenge.id)}><span>⚔️ {challenge.type!=='challenge_received'?challenge.title:(isSpain?'¡Has recibido un reto!':'Tu as reçu un défi !')}</span>{challenge.body&&<p>{challenge.body}</p>}<span className="challenge-notice-action">{challenge.type==='challenge_message'?(isSpain?'Leer el mensaje':'Lire le message'):challenge.type==='challenge_completed'?(isSpain?'Ver el resultado':'Voir le résultat'):(isSpain?'Ver el reto':'Voir le défi')} →</span></Link>{readErrorId===challenge.id&&<p role="alert">{isSpain?'No se pudo guardar la lectura. Vuelve a intentarlo.':'La lecture n’a pas pu être enregistrée. Réessaie.'}</p>}</aside>}
    </>
  )
}
