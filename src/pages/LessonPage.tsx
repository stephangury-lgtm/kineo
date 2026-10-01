import { useEffect, useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { getLessonV2, startLessonQuizV2, type LessonV2 } from '../services/curriculumApi'

function renderListItem(value: unknown, index: number) {
  if (typeof value === 'string') return <li key={index}>{value}</li>
  if (value && typeof value === 'object') return <li key={index}>{JSON.stringify(value)}</li>
  return null
}

function formatPageRange(start: number | null, end: number | null) {
  if (start == null && end == null) return 'Pages non précisées'
  if (start != null && (end == null || end === start)) return `Page ${start}`
  if (start == null) return `Jusqu’à la page ${end}`
  return `Pages ${start} à ${end}`
}

export default function LessonPage() {
  const { lessonId } = useParams()
  const navigate = useNavigate()
  const [lesson, setLesson] = useState<LessonV2 | null>(null)
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!lessonId) return
    getLessonV2(lessonId).then(setLesson).catch((err: Error) => setError(err.message))
  }, [lessonId])

  async function launchQuiz() {
    if (!lesson) return
    setBusy(true)
    setError(null)
    try {
      const sessionId = await startLessonQuizV2(lesson.id, 10)
      navigate(`/revision?mode=lesson&session=${encodeURIComponent(sessionId)}`)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Impossible de démarrer le quiz.')
    } finally {
      setBusy(false)
    }
  }

  if (error && !lesson) return <section className="card"><h1>Leçon indisponible</h1><p>{error}</p><Link className="secondary-button" to="/parcours">Retour au parcours</Link></section>
  if (!lesson) return <section className="card skeleton-card"><p>Chargement de la leçon…</p></section>

  const coveragePercent = lesson.question_count > 0
    ? Math.round((lesson.attempted_questions / lesson.question_count) * 100)
    : 0
  const hasValidatedIfmkSource = lesson.source_documents.some((source) => source.validation_status === 'validated')

  return (
    <div className="stack">
      <section className="stats-hero">
        <div>
          <p className="eyebrow light">K{lesson.year.number} · {lesson.subject.icon ? `${lesson.subject.icon} ` : ''}{lesson.subject.name}</p>
          <h1>{lesson.title}</h1>
          <p>{lesson.chapter.name}{lesson.summary ? ` · ${lesson.summary}` : ''}</p>
        </div>
        <div className="stats-hero-score">
          <span>Maîtrise</span>
          <strong>{lesson.mastery_percent}%</strong>
        </div>
      </section>

      {hasValidatedIfmkSource && (
        <section className="card challenge-card done">
          <div className="challenge-icon">✓</div>
          <div className="challenge-copy">
            <p className="eyebrow">Traçabilité pédagogique</p>
            <h2>Contenu issu d’un support IFMK validé</h2>
            <p>Les notions et questions de cette leçon sont rattachées à leur document de référence.</p>
          </div>
        </section>
      )}

      <section className="stats-grid">
        <article className="card score-card"><span>❓ Questions</span><strong>{lesson.question_count}</strong><small>dans cette leçon</small></article>
        <article className="card score-card"><span>✅ Déjà vues</span><strong>{lesson.attempted_questions}</strong><small>{coveragePercent}% de couverture</small></article>
        <article className="card score-card"><span>🧠 Maîtrise</span><strong>{lesson.mastery_percent}%</strong><small>progression actuelle</small></article>
        <article className="card score-card"><span>🎯 Quiz</span><strong>{Math.min(10, lesson.question_count)}</strong><small>questions proposées</small></article>
      </section>

      {lesson.question_count > 0 && (
        <section className="card">
          <div className="section-heading">
            <div>
              <p className="eyebrow">Progression</p>
              <h2>Couverture de la leçon</h2>
            </div>
            <strong>{coveragePercent}%</strong>
          </div>
          <div className="progress-track" style={{ marginTop: 14 }}>
            <div className="progress-fill" style={{ width: `${coveragePercent}%` }} />
          </div>
          <p className="activity-caption">{lesson.attempted_questions} question{lesson.attempted_questions > 1 ? 's' : ''} déjà travaillée{lesson.attempted_questions > 1 ? 's' : ''} sur {lesson.question_count}.</p>
        </section>
      )}

      {lesson.image_url && (
        <section className="card centered">
          <img className="question-image" src={lesson.image_url} alt="Illustration de la leçon" />
        </section>
      )}

      {lesson.content && (
        <section className="card">
          <div className="section-heading">
            <div>
              <p className="eyebrow">Cours</p>
              <h2>Comprendre l’essentiel</h2>
            </div>
          </div>
          <div style={{ whiteSpace: 'pre-wrap', lineHeight: 1.75 }}>{lesson.content}</div>
        </section>
      )}

      {lesson.key_points.length > 0 && (
        <section className="card focus-card">
          <div>
            <p className="eyebrow">Points clés</p>
            <h2>À retenir</h2>
            <ul>{lesson.key_points.map(renderListItem)}</ul>
          </div>
          <div className="focus-bubble">✓</div>
        </section>
      )}

      {lesson.source_documents.length > 0 && (
        <section className="card">
          <div className="section-heading">
            <div>
              <p className="eyebrow">Source IFMK</p>
              <h2>Document de référence</h2>
            </div>
          </div>
          <div className="weak-list" style={{ marginTop: 12 }}>
            {lesson.source_documents.map((source, index) => (
              <article key={`${source.title}-${index}`}>
                <strong>{source.title}</strong>
                <span>{formatPageRange(source.page_start, source.page_end)}</span>
                <span>{source.validation_status === 'validated' ? '✓ Support validé' : 'Support référencé'}</span>
              </article>
            ))}
          </div>
        </section>
      )}

      {lesson.sources.length > 0 && (
        <section className="card">
          <div className="section-heading">
            <div>
              <p className="eyebrow">Références complémentaires</p>
              <h2>Sources du contenu</h2>
            </div>
          </div>
          <ul>{lesson.sources.map(renderListItem)}</ul>
        </section>
      )}

      <section className="card centered">
        <p className="eyebrow">Passage à l’action</p>
        <h2>Vérifie ce que tu as retenu</h2>
        <p>Une courte série ciblée pour transformer la lecture en mémorisation active.</p>
        <button className="primary-button wide" disabled={busy || lesson.question_count === 0} onClick={launchQuiz}>
          {busy ? 'Préparation…' : `Lancer le quiz (${Math.min(10, lesson.question_count)} questions)`}
        </button>
        <Link className="secondary-button wide" to="/parcours">Retour au parcours</Link>
        {error && <p className="feedback">{error}</p>}
      </section>
    </div>
  )
}
