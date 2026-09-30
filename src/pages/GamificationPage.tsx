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
  if (!summary || !badges) return <section className="card"><p>Chargement de tes récompenses…</p></section>

  const level = summary.level
  const earned = badges.badges.filter((badge) => badge.earned)
  const locked = badges.badges.filter((badge) => !badge.earned)

  return (
    <div className="stack">
      <section className="card level-card">
        <p className="eyebrow">Ton niveau</p>
        <div className="level-heading">
          <span className="level-icon" aria-hidden="true">{level.icon || '⭐'}</span>
          <div>
            <h1>Niveau {level.number} · {level.name}</h1>
            <p>{summary.xp_total} XP au total</p>
          </div>
        </div>
        <div className="progress-track" aria-label={`Progression niveau ${level.progress_percent}%`}>
          <div className="progress-fill" style={{ width: `${Math.min(100, level.progress_percent)}%` }} />
        </div>
        <p>
          {level.next_level
            ? `${level.xp_to_next} XP avant le niveau ${level.next_level} · ${level.next_name}`
            : 'Niveau maximum atteint 👑'}
        </p>
      </section>

      <section className="stats-grid">
        <article className="card stat"><span>Série actuelle</span><strong>🔥 {summary.streak.current}</strong></article>
        <article className="card stat"><span>Meilleure série</span><strong>{summary.streak.longest} j</strong></article>
        <article className="card stat"><span>Badges</span><strong>{summary.badges.earned}/{summary.badges.total}</strong></article>
        <article className="card stat"><span>Bonnes réponses</span><strong>{badges.stats.correct_answers}</strong></article>
      </section>

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
          <div className="badge-grid">
            {earned.map((badge) => (
              <article className="badge-card earned" key={badge.id}>
                <span className="badge-icon" aria-hidden="true">{badge.icon || '🏅'}</span>
                <div>
                  <h3>{badge.name}</h3>
                  <p>{badge.description}</p>
                </div>
              </article>
            ))}
          </div>
        )}
      </section>

      <section className="card">
        <p className="eyebrow">Prochains objectifs</p>
        <h2>Badges à débloquer</h2>
        <div className="badge-grid">
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
