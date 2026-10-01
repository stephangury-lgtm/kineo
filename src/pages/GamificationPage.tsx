import { useEffect, useState } from 'react'
import {
  getBadgesV2,
  getGamificationSummaryV2,
  type BadgesV2,
  type GamificationSummaryV2,
} from '../services/kineoApi'

export default function GamificationPage() {
  const [summary, setSummary] = useState<GamificationSummaryV2 | null>(null)
  const [badges, setBadges] = useState<BadgesV2 | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    Promise.all([getGamificationSummaryV2(), getBadgesV2()])
      .then(([summaryData, badgeData]) => {
        setSummary(summaryData)
        setBadges(badgeData)
      })
      .catch((err: Error) => setError(err.message))
  }, [])

  if (error) return <section className="card"><h1>Gamification indisponible</h1><p>{error}</p></section>
  if (!summary || !badges) return <section className="card skeleton-card"><p>Chargement de tes récompenses…</p></section>

  const level = summary.level
  const earned = badges.badges.filter((badge) => badge.earned)
  const locked = badges.badges.filter((badge) => !badge.earned)
  const nextBadge = [...locked].sort((a, b) => b.progress_percent - a.progress_percent)[0]

  return (
    <div className="stack">
      <section className="hero-card">
        <div className="hero-copy">
          <span className="hero-kicker">Progression & récompenses</span>
          <h1>Niveau {level.number} · {level.name}</h1>
          <p>{summary.xp_total} XP accumulés. Continue tes sessions pour débloquer les prochains niveaux et badges.</p>
          <div className="progress-track" aria-label={`Progression niveau ${level.progress_percent}%`}>
            <div className="progress-fill" style={{ width: `${Math.min(100, level.progress_percent)}%` }} />
          </div>
        </div>
        <div className="hero-orbit" aria-hidden="true">{level.icon || '⭐'}</div>
      </section>

      <section className="stats-grid">
        <article className="card score-card"><span>🔥 Série actuelle</span><strong>{summary.streak.current} j</strong><small>Meilleure : {summary.streak.longest} j</small></article>
        <article className="card score-card"><span>🏅 Badges</span><strong>{summary.badges.earned}/{summary.badges.total}</strong><small>{earned.length} débloqué{earned.length > 1 ? 's' : ''}</small></article>
        <article className="card score-card"><span>✅ Bonnes réponses</span><strong>{badges.stats.correct_answers}</strong><small>Sur l’ensemble de tes révisions</small></article>
        <article className="card score-card"><span>⚡ Prochain niveau</span><strong>{level.next_level ? level.xp_to_next : 0} XP</strong><small>{level.next_level ? `Vers ${level.next_name}` : 'Niveau maximum'}</small></article>
      </section>

      {nextBadge && (
        <section className="card challenge-card">
          <div className="challenge-icon" aria-hidden="true">{nextBadge.icon || '🎯'}</div>
          <div className="challenge-copy">
            <p className="eyebrow">Objectif le plus proche</p>
            <h2>{nextBadge.name}</h2>
            <p>{nextBadge.description}</p>
            <div className="progress-track small" style={{ marginTop: 10 }}>
              <div className="progress-fill" style={{ width: `${Math.min(100, nextBadge.progress_percent)}%` }} />
            </div>
          </div>
          <strong>{nextBadge.progress_percent}%</strong>
        </section>
      )}

      <section className="card">
        <div className="section-heading">
          <div>
            <p className="eyebrow">Collection</p>
            <h2>Badges débloqués</h2>
          </div>
          <strong>{earned.length}</strong>
        </div>
        {earned.length === 0 ? (
          <p>Ton premier badge arrivera dès tes premières réussites.</p>
        ) : (
          <div className="badge-grid" style={{ marginTop: 14 }}>
            {earned.map((badge) => (
              <article className="badge-card earned" key={badge.id}>
                <span className="badge-icon" aria-hidden="true">{badge.icon || '🏅'}</span>
                <div className="badge-copy">
                  <h3>{badge.name}</h3>
                  <p>{badge.description}</p>
                  <span>Débloqué · {badge.progress_percent}%</span>
                </div>
              </article>
            ))}
          </div>
        )}
      </section>

      <section className="card">
        <div className="section-heading">
          <div>
            <p className="eyebrow">À venir</p>
            <h2>Prochains badges</h2>
          </div>
          <strong>{locked.length}</strong>
        </div>
        <div className="badge-grid" style={{ marginTop: 14 }}>
          {locked.map((badge) => (
            <article className="badge-card" key={badge.id}>
              <span className="badge-icon muted" aria-hidden="true">{badge.icon || '🔒'}</span>
              <div className="badge-copy">
                <h3>{badge.name}</h3>
                <p>{badge.description}</p>
                <div className="progress-track small">
                  <div className="progress-fill" style={{ width: `${Math.min(100, badge.progress_percent)}%` }} />
                </div>
                <span>{badge.current_value}/{badge.target_value} · {badge.progress_percent}%</span>
              </div>
            </article>
          ))}
        </div>
      </section>
    </div>
  )
}
