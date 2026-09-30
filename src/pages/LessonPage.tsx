import { useEffect, useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { getLessonV2, startLessonQuizV2, type LessonV2 } from '../services/curriculumApi'

function renderListItem(value: unknown, index: number) {
  if (typeof value === 'string') return <li key={index}>{value}</li>
  if (value && typeof value === 'object') return <li key={index}>{JSON.stringify(value)}</li>
  return null
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
  if (!lesson) return <section className="card"><p>Chargement de la leçon…</p></section>

  return (
    <div className="stack">
      <section className="card">
        <p className="eyebrow">K{lesson.year.number} · {lesson.subject.icon ? `${lesson.subject.icon} ` : ''}{lesson.subject.name}</p>
        <h1>{lesson.title}</h1>
        <p>{lesson.chapter.name}</p>
        {lesson.image_url && <img className="question-image" src={lesson.image_url} alt="Illustration de la leçon" />}
        {lesson.summary && <p><strong>À retenir :</strong> {lesson.summary}</p>}
        <div className="progress-track"><div className="progress-fill" style={{ width: `${Math.min(100, lesson.mastery_percent)}%` }} /></div>
        <p>Maîtrise actuelle : <strong>{lesson.mastery_percent}%</strong> · {lesson.question_count} question{lesson.question_count > 1 ? 's' : ''}</p>
      </section>

      {lesson.content && (
        <section className="card">
          <p className="eyebrow">Cours</p>
          <div style={{ whiteSpace: 'pre-wrap', lineHeight: 1.65 }}>{lesson.content}</div>
        </section>
      )}

      {lesson.key_points.length > 0 && (
        <section className="card">
          <p className="eyebrow">Points clés</p>
          <ul>{lesson.key_points.map(renderListItem)}</ul>
        </section>
      )}

      {lesson.sources.length > 0 && (
        <section className="card">
          <p className="eyebrow">Sources</p>
          <ul>{lesson.sources.map(renderListItem)}</ul>
        </section>
      )}

      <section className="card centered">
        <h2>Vérifie ce que tu as retenu</h2>
        <button className="primary-button" disabled={busy || lesson.question_count === 0} onClick={launchQuiz}>
          {busy ? 'Préparation…' : `Lancer le quiz (${Math.min(10, lesson.question_count)} questions)`}
        </button>
        <Link className="secondary-button" to="/parcours">Retour au parcours</Link>
        {error && <p className="feedback">{error}</p>}
      </section>
    </div>
  )
}
