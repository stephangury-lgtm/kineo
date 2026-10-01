import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { startMockExamV1 } from '../services/kineoApi'

export default function MockExamPage() {
  const navigate = useNavigate()
  const [busy, setBusy] = useState(false)
  const [message, setMessage] = useState<string | null>(null)

  async function start() {
    setBusy(true)
    setMessage(null)
    try {
      const sessionId = await startMockExamV1(20)
      navigate(`/revision?mode=exam&session=${sessionId}`)
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Impossible de générer l’examen blanc.')
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="stack">
      <section className="hero-card">
        <div className="hero-copy">
          <span className="hero-kicker">Examen blanc</span>
          <h1>Teste-toi sur une session complète 📝</h1>
          <p>20 questions équilibrées par format, chapitre et difficulté. Tes réponses sont enregistrées sans correction immédiate : le résultat est dévoilé à la fin.</p>
          <button className="primary-button hero-action" onClick={() => void start()} disabled={busy}>{busy ? 'Génération du sujet…' : 'Lancer l’examen · 20 questions'}</button>
        </div>
        <div className="hero-orbit" aria-hidden="true">📝</div>
      </section>
      <section className="card">
        <p className="eyebrow">Simulation</p>
        <h2>Un sujet plus représentatif</h2>
        <p>Le générateur diversifie les formats, les chapitres et les niveaux de difficulté. Pendant l’épreuve, aucune bonne réponse ni explication n’est affichée avant la fin.</p>
      </section>
      {message && <section className="card feedback-card"><p className="feedback">{message}</p></section>}
    </div>
  )
}
