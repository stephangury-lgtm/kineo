import { useEffect, useState } from 'react'
import { getCurrentProgram } from '../curriculum/programs'

export default function OfflineStatus() {
  const isSpain=getCurrentProgram().id==='kineo-es'
  const [online, setOnline] = useState(() => navigator.onLine)

  useEffect(() => {
    const onOnline = () => setOnline(true)
    const onOffline = () => setOnline(false)
    window.addEventListener('online', onOnline)
    window.addEventListener('offline', onOffline)
    return () => {
      window.removeEventListener('online', onOnline)
      window.removeEventListener('offline', onOffline)
    }
  }, [])

  if (online) return null
  return <div className="offline-banner" role="status">{isSpain?'Sin conexión · las pantallas ya cargadas siguen disponibles':'Hors connexion · les écrans déjà chargés restent disponibles'}</div>
}
