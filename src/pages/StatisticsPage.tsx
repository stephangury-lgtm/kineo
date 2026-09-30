import { useEffect, useState } from 'react'
import { getUserStatsV2, type UserStatsV2 } from '../services/kineoApi'

export default function StatisticsPage() {
  const [stats, setStats] = useState<UserStatsV2 | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    getUserStatsV2(30).then(setStats).catch((err: Error) => setError(err.message))
  }, [])

  if (error) return <section className="card"><h1>Statistiques indisponibles</h1><p>{error}</p></section>
  if (!stats) return <section className="card"><p>Calcul de ta progression…</p></section>

  const s = stats.summary

  return (
    <div className="stack">
      <section className="card">
        <p className="eyebrow">30 derniers jours</p>
        <h1>Ta progression</h1>
        <div className="stats-grid">
          <article className="mini-stat"><span>Précision</span><strong>{s.accuracy_percent}%</strong></article>
          <article className="mini-stat"><span>Maîtrise</span><strong>{s.mastery_percent}%</strong></article>
          <article className="mini-stat"><span>Sessions</span><strong>{s.completed_sessions}</strong></article>
          <article className="mini-stat"><span>XP</span><strong>{s.xp_total}</strong></article>
        </div>
      </section>

      <section className="card">
        <h2>À travailler</h2>
        <div className="stats-grid">
          <article className="mini-stat"><span>Questions fragiles</span><strong>{s.fragile_questions}</strong></article>
          <article className="mini-stat"><span>À revoir maintenant</span><strong>{s.reviews_due}</strong></article>
        </div>
      </section>

      <section className="card">
        <h2>Par matière</h2>
        <div className="subject-list">
          {stats.subjects.filter((subject) => subject.published_questions > 0).map((subject) => (
            <article className="subject-row" key={subject.id}>
              <div>
                <strong>{subject.name}</strong>
                <span>{subject.attempted_questions}/{subject.published_questions} questions vues</span>
              </div>
              <div className="subject-score">
                <strong>{subject.mastery_percent}%</strong>
                <span>maîtrise</span>
              </div>
            </article>
          ))}
        </div>
      </section>

      {stats.weak_questions.length > 0 && (
        <section className="card">
          <h2>Priorités de révision</h2>
          <div className="weak-list">
            {stats.weak_questions.slice(0, 5).map((question) => (
              <article key={question.question_id}>
                <strong>{question.subject_name}</strong>
                <p>{question.question_text}</p>
                <span>Maîtrise {question.mastery_percent}%</span>
              </article>
            ))}
          </div>
        </section>
      )}
    </div>
  )
}
