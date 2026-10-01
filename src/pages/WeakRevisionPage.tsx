import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { startWeakRevisionV1 } from '../services/kineoApi'

export default function WeakRevisionPage() {
  const navigate = useNavigate()
  const [busy, setBusy] = useState(false)
  const [message, setMessage] = useState<string | null>(null)

  async function start() {
    setBusy(true)
    setMessage(null)
    try {
      const sessionId = await startWeakRevisionV1(10)
      navigate(`/revision?mode=weak&session=${sessionId}`)
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Impossible de préparer cette révision.')
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="stack">
      <section className="hero-card">
        <div className="hero-copy">
          <span className="hero-kicker">Révision ciblée</span>
          <h1>Transforme tes erreurs en acquis 🎯</h1>
          <p>Kineo sélectionne en priorité les questions ratées, les notions fragiles et celles qui arrivent à échéance.</p>
          <button className="primary-button hero-action" onClick={() => void start()} disabled={busy}>{busy ? 'Analyse de ta progression…' : 'Réviser mes points faibles'}</button>
        </div>
        <div className="hero-orbit" aria-hidden="true">🎯</div>
      </section>
      <section className="card">
        <p className="eyebrow">Répétition espacée</p>
        <h2>Une session utile, pas une session au hasard</h2>
        <p>Les erreurs récentes, les faibles taux de maîtrise et les révisions dues sont remontés en premier. Les questions vues très récemment sont pénalisées pour éviter la répétition artificielle.</p>
      </section>
      {message && <section className="card feedback-card"><p className="feedback">{message}</p></section>}
    </div>
  )
}
