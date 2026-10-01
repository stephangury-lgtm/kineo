import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { startVisualRevisionV1 } from '../services/kineoApi'

export default function VisualRevisionPage() {
  const navigate = useNavigate()
  const [busy, setBusy] = useState(false)
  const [message, setMessage] = useState<string | null>(null)

  async function start() {
    setBusy(true)
    setMessage(null)
    try {
      const sessionId = await startVisualRevisionV1(10)
      navigate(`/revision?mode=visual&session=${sessionId}`)
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Impossible de démarrer la session visuelle.')
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="stack">
      <section className="hero-card">
        <div className="hero-copy">
          <span className="hero-kicker">Anatomie visuelle</span>
          <h1>Repère. Touche. Mémorise. 🦴</h1>
          <p>10 exercices interactifs adaptés à ton année : repérage anatomique et placement d’étiquettes sur des schémas issus du contenu validé.</p>
          <button className="primary-button hero-action" onClick={() => void start()} disabled={busy}>{busy ? 'Préparation…' : 'Commencer · 10 exercices'}</button>
        </div>
        <div className="hero-orbit" aria-hidden="true">🦴</div>
      </section>
      <section className="card">
        <p className="eyebrow">Révision ciblée</p>
        <h2>Le moteur privilégie tes points faibles</h2>
        <p>Les notions dues, fragiles ou encore jamais travaillées passent en priorité, tout en limitant les répétitions récentes.</p>
      </section>
      {message && <section className="card feedback-card"><p className="feedback">{message}</p></section>}
    </div>
  )
}
