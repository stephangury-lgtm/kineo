import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { getDashboardV2, type DashboardV2 } from '../services/kineoApi'

export default function DashboardPage() {
  const [dashboard, setDashboard] = useState<DashboardV2 | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    getDashboardV2().then(setDashboard).catch((err: Error) => setError(err.message))
  }, [])

  if (error) return <section className="card"><h1>Connexion nécessaire</h1><p>{error}</p></section>
  if (!dashboard) return <section className="card"><p>Chargement de ta progression…</p></section>

  const xp = dashboard.profile?.xp ?? 0
  const level = dashboard.profile?.level ?? dashboard.level?.current ?? 1
  const streak = dashboard.streak?.current ?? 0
  const mastery = dashboard.mastery?.overall_percent ?? 0
  const badges = dashboard.badges?.earned ?? 0

  return (
    <div className="stack">
      <section className="hero card">
        <div>
          <p className="eyebrow">Aujourd’hui</p>
          <h1>Prêt pour une session courte ?</h1>
          <p>Le moteur choisit en priorité tes révisions dues, erreurs récentes et notions fragiles.</p>
        </div>
        <Link className="primary-button" to="/revision">Lancer une révision</Link>
      </section>

      <section className="stats-grid">
        <article className="card stat"><span>Niveau</span><strong>{level}</strong></article>
        <article className="card stat"><span>XP</span><strong>{xp}</strong></article>
        <article className="card stat"><span>Série</span><strong>🔥 {streak}</strong></article>
        <article className="card stat"><span>Maîtrise</span><strong>{mastery}%</strong></article>
      </section>

      <section className="card">
        <h2>Progression</h2>
        <div className="progress-track"><div className="progress-fill" style={{ width: `${Math.min(100, mastery)}%` }} /></div>
        <p>{dashboard.mastery?.mastered ?? 0} questions maîtrisées · {dashboard.mastery?.fragile ?? 0} fragiles · {dashboard.mastery?.due ?? 0} à revoir.</p>
        <p>{badges} badge{badges > 1 ? 's' : ''} débloqué{badges > 1 ? 's' : ''}.</p>
      </section>
    </div>
  )
}
