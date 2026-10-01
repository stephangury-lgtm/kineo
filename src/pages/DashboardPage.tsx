import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { getBadgesV2, getDashboardV2, getGamificationSummaryV2, type BadgesV2, type DashboardV2, type GamificationSummaryV2 } from '../services/kineoApi'

export default function DashboardPage() {
  const [dashboard, setDashboard] = useState<DashboardV2 | null>(null)
  const [game, setGame] = useState<GamificationSummaryV2 | null>(null)
  const [badges, setBadges] = useState<BadgesV2 | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    Promise.all([getDashboardV2(), getGamificationSummaryV2(), getBadgesV2()])
      .then(([dashboardData, gameData, badgeData]) => { setDashboard(dashboardData); setGame(gameData); setBadges(badgeData) })
      .catch((err: Error) => setError(err.message))
  }, [])

  if (error) return <section className="card"><h1>Progression indisponible</h1><p>{error}</p></section>
  if (!dashboard || !game || !badges) return <section className="card skeleton-card"><p>Chargement de ta progression…</p></section>

  const xp = game.xp_total ?? dashboard.profile?.xp ?? 0
  const level = game.level.number ?? dashboard.profile?.level ?? 1
  const streak = game.streak.current ?? dashboard.streak?.current ?? 0
  const mastery = dashboard.mastery?.overall_percent ?? 0
  const dailyDone = dashboard.daily?.completed === true || dashboard.daily?.status === 'completed'
  const due = dashboard.mastery?.due ?? 0
  const nextBadge = badges.badges.filter((badge) => !badge.earned).sort((a, b) => b.progress_percent - a.progress_percent)[0]
  const levelProgress = Math.min(100, game.level.progress_percent ?? 0)

  return (
    <div className="stack dashboard-stack">
      <section className="hero-card">
        <div className="hero-copy">
          <span className="hero-kicker">Ta session du jour</span>
          <h1>{streak > 0 ? `${streak} jour${streak > 1 ? 's' : ''} de suite 🔥` : 'Commence ta série aujourd’hui 🔥'}</h1>
          <p>{due > 0 ? `${due} notion${due > 1 ? 's' : ''} à revoir aujourd’hui.` : 'Ton programme est à jour. Quelques questions pour consolider ?'}</p>
          <Link className="primary-button hero-action" to="/revision">Commencer · 10 questions</Link>
        </div>
        <div className="hero-orbit" aria-hidden="true"><span>🧠</span></div>
      </section>

      <section className="dashboard-metrics">
        <article className="metric-card"><span className="metric-icon">⚡</span><div><small>XP</small><strong>{xp}</strong></div></article>
        <article className="metric-card"><span className="metric-icon">🔥</span><div><small>Série</small><strong>{streak} j</strong></div></article>
        <article className="metric-card"><span className="metric-icon">◉</span><div><small>Maîtrise</small><strong>{mastery}%</strong></div></article>
      </section>

      <section className="card level-progress-card">
        <div className="section-heading"><div><p className="eyebrow">Niveau {level}</p><h2>{game.level.name}</h2></div><strong>{levelProgress}%</strong></div>
        <div className="progress-track level-track"><div className="progress-fill" style={{ width: `${levelProgress}%` }} /></div>
        <div className="level-progress-copy"><span>{xp} XP au total</span><span>{game.level.next_level ? `${game.level.xp_to_next} XP avant ${game.level.next_name}` : 'Niveau maximum atteint'}</span></div>
      </section>

      <section className={`card challenge-card ${dailyDone ? 'done' : ''}`}>
        <div className="challenge-icon">{dailyDone ? '✓' : '🔥'}</div>
        <div className="challenge-copy"><p className="eyebrow">Challenge du jour</p><h2>{dailyDone ? 'Mission accomplie' : `${dashboard.daily?.question_count ?? 10} questions · bonus XP`}</h2><p>{dailyDone ? 'Ta série est protégée pour aujourd’hui.' : 'Une session rapide pour entretenir ta régularité.'}</p></div>
        {!dailyDone && <Link className="secondary-button" to="/revision?mode=daily">Jouer</Link>}
      </section>

      {nextBadge && <section className="card next-badge-card">
        <div className="next-badge-icon">{nextBadge.icon || '🎯'}</div>
        <div className="next-badge-copy"><p className="eyebrow">Prochain badge</p><h2>{nextBadge.name}</h2><p>{nextBadge.description}</p><div className="progress-track small"><div className="progress-fill" style={{ width: `${Math.min(100, nextBadge.progress_percent)}%` }} /></div><small>{nextBadge.current_value}/{nextBadge.target_value} · {nextBadge.progress_percent}%</small></div>
        <Link className="text-link" to="/rewards">Tous les badges</Link>
      </section>}

      <section className="card progress-card">
        <div className="section-heading"><div><p className="eyebrow">Connaissances</p><h2>Maîtrise du programme</h2></div><Link className="text-link" to="/stats">Détails</Link></div>
        <div className="mastery-ring" style={{ '--progress': `${Math.min(100, mastery)}%` } as React.CSSProperties}><span>{mastery}%</span></div>
        <div className="progress-copy"><strong>{dashboard.mastery?.mastered ?? 0} notions maîtrisées</strong><span>{dashboard.mastery?.fragile ?? 0} fragiles · {due} à revoir</span></div>
      </section>

      <section className="quick-grid"><Link className="quick-card" to="/parcours"><span>▦</span><strong>Parcours</strong><small>Choisir une leçon</small></Link><Link className="quick-card" to="/amis"><span>⚔️</span><strong>Amis & défis</strong><small>Défier un camarade</small></Link><Link className="quick-card" to="/stats"><span>↗</span><strong>Statistiques</strong><small>Voir mes progrès</small></Link></section>
    </div>
  )
}
