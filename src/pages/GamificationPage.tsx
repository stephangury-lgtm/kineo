import { useEffect, useState } from 'react'
import { getCurrentProgram } from '../curriculum/programs'
import {
  getBadgesV2,
  getGamificationSummaryV2,
  type BadgesV2,
  type GamificationSummaryV2,
} from '../services/kineoApi'

export default function GamificationPage() {
  const isSpain = getCurrentProgram().id === 'kineo-es'
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

  if (error) return <section className="card"><h1>{isSpain?'Recompensas no disponibles':'Gamification indisponible'}</h1><p>{error}</p></section>
  if (!summary || !badges) return <section className="card skeleton-card"><p>{isSpain?'Cargando tus recompensas…':'Chargement de tes récompenses…'}</p></section>

  const level = summary.level
  const earned = badges.badges.filter((badge) => badge.earned)
  const locked = badges.badges.filter((badge) => !badge.earned)
  const nextBadge = [...locked].sort((a, b) => b.progress_percent - a.progress_percent)[0]

  return (
    <div className="stack">
      <section className="hero-card">
        <div className="hero-copy">
          <span className="hero-kicker">{isSpain?'Progreso y recompensas':'Progression & récompenses'}</span>
          <h1>{isSpain?'Nivel':'Niveau'} {level.number} · {level.name}</h1>
          <p>{summary.xp_total} XP {isSpain?'acumulados. Continúa tus sesiones para desbloquear los próximos niveles y logros.':'accumulés. Continue tes sessions pour débloquer les prochains niveaux et badges.'}</p>
          <div className="progress-track" aria-label={`${isSpain?'Progreso del nivel':'Progression niveau'} ${level.progress_percent}%`}>
            <div className="progress-fill" style={{ width: `${Math.min(100, level.progress_percent)}%` }} />
          </div>
        </div>
        <div className="hero-orbit" aria-hidden="true">{level.icon || '⭐'}</div>
      </section>

      <section className="stats-grid">
        <article className="card score-card"><span>🔥 {isSpain?'Racha actual':'Série actuelle'}</span><strong>{summary.streak.current} {isSpain?'d':'j'}</strong><small>{isSpain?'Mejor':'Meilleure'} : {summary.streak.longest} {isSpain?'d':'j'}</small></article>
        <article className="card score-card"><span>🏅 {isSpain?'Logros':'Badges'}</span><strong>{summary.badges.earned}/{summary.badges.total}</strong><small>{earned.length} {isSpain?'desbloqueados':`débloqué${earned.length > 1 ? 's' : ''}`}</small></article>
        <article className="card score-card"><span>✅ {isSpain?'Respuestas correctas':'Bonnes réponses'}</span><strong>{badges.stats.correct_answers}</strong><small>{isSpain?'En todas tus revisiones':'Sur l’ensemble de tes révisions'}</small></article>
        <article className="card score-card"><span>⚡ {isSpain?'Próximo nivel':'Prochain niveau'}</span><strong>{level.next_level ? level.xp_to_next : 0} XP</strong><small>{level.next_level ? `${isSpain?'Hacia':'Vers'} ${level.next_name}` : (isSpain?'Nivel máximo':'Niveau maximum')}</small></article>
      </section>

      {nextBadge && (
        <section className="card challenge-card">
          <div className="challenge-icon" aria-hidden="true">{nextBadge.icon || '🎯'}</div>
          <div className="challenge-copy">
            <p className="eyebrow">{isSpain?'Objetivo más cercano':'Objectif le plus proche'}</p>
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
            <p className="eyebrow">{isSpain?'Colección':'Collection'}</p>
            <h2>{isSpain?'Logros desbloqueados':'Badges débloqués'}</h2>
          </div>
          <strong>{earned.length}</strong>
        </div>
        {earned.length === 0 ? (
          <p>{isSpain?'Tu primer logro llegará con tus primeros éxitos.':'Ton premier badge arrivera dès tes premières réussites.'}</p>
        ) : (
          <div className="badge-grid" style={{ marginTop: 14 }}>
            {earned.map((badge) => (
              <article className="badge-card earned" key={badge.id}>
                <span className="badge-icon" aria-hidden="true">{badge.icon || '🏅'}</span>
                <div className="badge-copy">
                  <h3>{badge.name}</h3>
                  <p>{badge.description}</p>
                  <span>{isSpain?'Desbloqueado':'Débloqué'} · {badge.progress_percent}%</span>
                </div>
              </article>
            ))}
          </div>
        )}
      </section>

      <section className="card">
        <div className="section-heading">
          <div>
            <p className="eyebrow">{isSpain?'Próximamente':'À venir'}</p>
            <h2>{isSpain?'Próximos logros':'Prochains badges'}</h2>
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
