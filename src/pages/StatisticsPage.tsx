import { useEffect, useMemo, useState } from 'react'
import { getUserStatsV2, type UserStatsV2 } from '../services/kineoApi'

export default function StatisticsPage() {
  const [stats, setStats] = useState<UserStatsV2 | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    getUserStatsV2(30).then(setStats).catch((err: Error) => setError(err.message))
  }, [])

  const recentActivity = useMemo(() => stats?.daily_activity.slice(-14) ?? [], [stats])
  const maxAttempts = Math.max(1, ...recentActivity.map((day) => day.attempts))

  if (error) return <section className="card"><h1>Statistiques indisponibles</h1><p>{error}</p></section>
  if (!stats) return <section className="card skeleton-card"><p>Calcul de ta progression…</p></section>

  const s = stats.summary

  return (
    <div className="stack">
      <section className="stats-hero">
        <div>
          <p className="eyebrow light">30 derniers jours</p>
          <h1>Ta progression en un coup d’œil</h1>
          <p>Identifie ce qui est acquis, ce qui progresse et ce qui mérite une nouvelle révision.</p>
        </div>
        <div className="stats-hero-score">
          <span>Maîtrise</span>
          <strong>{s.mastery_percent}%</strong>
        </div>
      </section>

      <section className="stats-grid">
        <article className="card score-card"><span>🎯 Précision</span><strong>{s.accuracy_percent}%</strong><small>{s.correct_answers} bonnes réponses</small></article>
        <article className="card score-card"><span>🧠 Maîtrise</span><strong>{s.mastery_percent}%</strong><small>{s.mastered_questions} questions maîtrisées</small></article>
        <article className="card score-card"><span>✅ Sessions</span><strong>{s.completed_sessions}</strong><small>{s.attempts} tentatives</small></article>
        <article className="card score-card"><span>⚡ XP total</span><strong>{s.xp_total}</strong><small>Niveau {s.level}</small></article>
      </section>

      <section className="card">
        <div className="section-heading">
          <div>
            <p className="eyebrow">Rythme</p>
            <h2>14 derniers jours</h2>
          </div>
          <span className="activity-caption">{recentActivity.reduce((sum, day) => sum + day.attempts, 0)} réponses</span>
        </div>
        <div className="activity-chart" aria-label="Activité des 14 derniers jours">
          {recentActivity.map((day) => {
            const height = Math.max(8, Math.round((day.attempts / maxAttempts) * 100))
            return (
              <div className="activity-day" key={day.date} title={`${day.date} · ${day.attempts} réponses · ${day.accuracy_percent}%`}>
                <div className="activity-bar-wrap">
                  <div className="activity-bar" style={{ height: `${height}%` }} />
                </div>
                <span>{new Date(`${day.date}T12:00:00`).toLocaleDateString('fr-FR', { weekday: 'narrow' })}</span>
              </div>
            )
          })}
        </div>
      </section>

      <section className="card focus-card">
        <div>
          <p className="eyebrow">À travailler maintenant</p>
          <h2>{s.reviews_due > 0 ? `${s.reviews_due} révision${s.reviews_due > 1 ? 's' : ''} due${s.reviews_due > 1 ? 's' : ''}` : 'Aucune révision urgente'}</h2>
          <p>{s.fragile_questions} question{s.fragile_questions > 1 ? 's' : ''} encore fragile{s.fragile_questions > 1 ? 's' : ''} dans ton parcours.</p>
        </div>
        <div className="focus-bubble">💡</div>
      </section>

      <section className="card">
        <div className="section-heading">
          <div>
            <p className="eyebrow">Par matière</p>
            <h2>Maîtrise des contenus</h2>
          </div>
        </div>
        <div className="subject-list">
          {stats.subjects.filter((subject) => subject.published_questions > 0).map((subject) => (
            <article className="subject-progress" key={subject.id}>
              <div className="subject-row">
                <div>
                  <strong>{subject.name}</strong>
                  <span>{subject.attempted_questions}/{subject.published_questions} questions vues</span>
                </div>
                <div className="subject-score">
                  <strong>{subject.mastery_percent}%</strong>
                  <span>maîtrise</span>
                </div>
              </div>
              <div className="progress-track small"><div className="progress-fill" style={{ width: `${Math.min(100, subject.mastery_percent)}%` }} /></div>
            </article>
          ))}
        </div>
      </section>

      {stats.weak_questions.length > 0 && (
        <section className="card">
          <div className="section-heading">
            <div>
              <p className="eyebrow">Priorités</p>
              <h2>À revoir en premier</h2>
            </div>
          </div>
          <div className="weak-list">
            {stats.weak_questions.slice(0, 5).map((question, idx) => (
              <article className="priority-row" key={question.question_id}>
                <span className="priority-rank">{idx + 1}</span>
                <div>
                  <strong>{question.subject_name}</strong>
                  <p>{question.question_text}</p>
                  <span>Maîtrise {question.mastery_percent}% · Précision {question.accuracy_percent}%</span>
                </div>
              </article>
            ))}
          </div>
        </section>
      )}
    </div>
  )
}
