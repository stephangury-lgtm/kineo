import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { getDashboardV2, type DashboardV2 } from '../services/kineoApi'
import { getCurrentProfile, type StudentProfile } from '../services/profileApi'

export default function DashboardPage() {
  const [dashboard, setDashboard] = useState<DashboardV2 | null>(null)
  const [profile, setProfile] = useState<StudentProfile | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    Promise.all([getDashboardV2(), getCurrentProfile()])
      .then(([nextDashboard, nextProfile]) => {
        setDashboard(nextDashboard)
        setProfile(nextProfile)
      })
      .catch((err: Error) => setError(err.message))
  }, [])

  if (error) return <section className="card"><h1>Progression indisponible</h1><p>{error}</p></section>
  if (!dashboard) return <section className="card skeleton-card"><p>Chargement de ta progression…</p></section>

  const xp = dashboard.profile?.xp ?? 0
  const level = dashboard.profile?.level ?? dashboard.level?.current ?? 1
  const streak = dashboard.streak?.current ?? 0
  const mastery = dashboard.mastery?.overall_percent ?? 0
  const badges = dashboard.badges?.earned ?? 0
  const dailyDone = dashboard.daily?.completed === true || dashboard.daily?.status === 'completed'
  const due = dashboard.mastery?.due ?? 0
  const firstName = profile?.first_name?.trim()
  const studyYear = profile?.study_year ? `K${profile.study_year}` : null

  const nextAction = !dailyDone
    ? { to: '/revision?mode=daily', label: 'Faire le challenge · 10 questions', icon: '🔥', copy: 'Commence par ton challenge du jour et sécurise ta série.' }
    : due > 0
      ? { to: '/revision', label: 'Réviser maintenant', icon: '🧠', copy: `${due} notion${due > 1 ? 's' : ''} à revoir aujourd’hui selon ta progression.` }
      : { to: '/parcours', label: 'Continuer mon parcours', icon: '🎯', copy: 'Tout est à jour : avance sur une nouvelle leçon de ton année.' }

  return (
    <div className="stack dashboard-stack">
      <section className="hero-card">
        <div className="hero-copy">
          <span className="hero-kicker">{studyYear ? `${studyYear} · ` : ''}{firstName ? `Bonjour ${firstName}` : 'Ta session du jour'}</span>
          <h1>{dailyDone ? 'Bien joué. On garde le rythme ?' : 'Quelques minutes pour avancer.'}</h1>
          <p>{nextAction.copy}</p>
          <Link className="primary-button hero-action" to={nextAction.to}>{nextAction.label}</Link>
        </div>
        <div className="hero-orbit" aria-hidden="true"><span>{nextAction.icon}</span></div>
      </section>

      <section className="dashboard-metrics">
        <article className="metric-card"><span className="metric-icon">⚡</span><div><small>XP</small><strong>{xp}</strong></div></article>
        <article className="metric-card"><span className="metric-icon">🔥</span><div><small>Série</small><strong>{streak} j</strong></div></article>
        <article className="metric-card"><span className="metric-icon">◉</span><div><small>Maîtrise</small><strong>{mastery}%</strong></div></article>
      </section>

      <section className="card progress-card">
        <div className="section-heading"><div><p className="eyebrow">Progression</p><h2>Niveau {level}</h2></div><Link className="text-link" to="/rewards">Voir les badges</Link></div>
        <div className="mastery-ring" style={{ '--progress': `${Math.min(100, mastery)}%` } as React.CSSProperties}><span>{mastery}%</span></div>
        <div className="progress-copy"><strong>{dashboard.mastery?.mastered ?? 0} notions maîtrisées</strong><span>{dashboard.mastery?.fragile ?? 0} fragiles · {due} à revoir · {badges} badges</span></div>
      </section>

      <section className={`card challenge-card ${dailyDone ? 'done' : ''}`}>
        <div className="challenge-icon">{dailyDone ? '✓' : '🔥'}</div>
        <div className="challenge-copy"><p className="eyebrow">Challenge du jour</p><h2>{dailyDone ? 'Mission accomplie' : '10 questions · bonus +100 XP'}</h2><p>{dailyDone ? 'Ta série est protégée pour aujourd’hui.' : 'Une session rapide pour entretenir ta régularité.'}</p></div>
        {!dailyDone && <Link className="secondary-button" to="/revision?mode=daily">Jouer</Link>}
      </section>

      <section className="quick-grid">
        <Link className="quick-card" to="/parcours"><span>▦</span><strong>Parcours {studyYear ?? ''}</strong><small>Choisir une leçon</small></Link>
        <Link className="quick-card" to="/atlas"><span>◉</span><strong>Atlas anatomique</strong><small>Pointer et légender</small></Link>
        <Link className="quick-card" to="/stats"><span>↗</span><strong>Statistiques</strong><small>Voir mes progrès</small></Link>
      </section>
    </div>
  )
}
