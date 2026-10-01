import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import {
  getContentReviewQueue,
  publishLessonBundle,
  setContentReviewStatus,
  type ContentReviewQueue,
  type ReviewLesson,
} from '../services/contentReviewApi'

function statusLabel(status: string) {
  if (status === 'review') return 'À relire'
  if (status === 'validated') return 'Validé'
  if (status === 'published') return 'Publié'
  if (status === 'draft') return 'Brouillon'
  return status
}

function renderSource(source: unknown) {
  if (typeof source === 'string') return source
  if (source && typeof source === 'object') {
    const value = source as Record<string, unknown>
    return [value.title, value.url, value.reference].filter(Boolean).join(' · ') || JSON.stringify(source)
  }
  return String(source ?? '')
}

export default function ContentReviewPage() {
  const [queue, setQueue] = useState<ContentReviewQueue | null>(null)
  const [busyId, setBusyId] = useState<string | null>(null)
  const [message, setMessage] = useState<string | null>(null)

  async function load() {
    try {
      setMessage(null)
      setQueue(await getContentReviewQueue())
    } catch (err) {
      setMessage(err instanceof Error ? err.message : 'Impossible de charger la file de revue.')
    }
  }

  useEffect(() => { void load() }, [])

  async function updateStatus(kind: 'lesson' | 'question', id: string, status: 'review' | 'validated') {
    setBusyId(id)
    setMessage(null)
    try {
      await setContentReviewStatus(kind, id, status)
      await load()
      setMessage(status === 'validated' ? 'Contenu marqué comme validé.' : 'Contenu remis en revue.')
    } catch (err) {
      setMessage(err instanceof Error ? err.message : 'Modification impossible.')
    } finally {
      setBusyId(null)
    }
  }

  async function publish(lesson: ReviewLesson) {
    setBusyId(lesson.id)
    setMessage(null)
    try {
      await publishLessonBundle(lesson.id)
      await load()
      setMessage(`« ${lesson.title} » et ses questions sont maintenant publiées.`)
    } catch (err) {
      setMessage(err instanceof Error ? err.message : 'Publication impossible.')
    } finally {
      setBusyId(null)
    }
  }

  if (!queue && !message) return <section className="card skeleton-card"><p>Chargement de la revue…</p></section>

  if (!queue) return (
    <div className="stack">
      <section className="card">
        <h1>Accès à la revue impossible</h1>
        <p>{message}</p>
        <Link className="secondary-button" to="/profile">Retour au profil</Link>
      </section>
    </div>
  )

  return (
    <div className="stack">
      <section className="stats-hero">
        <div>
          <p className="eyebrow light">Administration · contenu</p>
          <h1>Revue pédagogique</h1>
          <p>Vérifie le fond, les sources et les corrections avant de rendre un contenu accessible aux étudiants.</p>
        </div>
        <div className="stats-hero-score"><span>À relire</span><strong>{queue.counts.review ?? 0}</strong></div>
      </section>

      <section className="card">
        <p className="eyebrow">Règle de publication</p>
        <h2>Une validation humaine reste nécessaire</h2>
        <p>Le statut « Validé » doit être utilisé uniquement après relecture du contenu et de ses sources par une personne compétente. Kineo distingue volontairement contenu sourcé et contenu validé.</p>
      </section>

      <section className="stats-grid">
        <article className="card score-card"><span>À relire</span><strong>{queue.counts.review ?? 0}</strong><small>leçons en attente</small></article>
        <article className="card score-card"><span>Validées</span><strong>{queue.counts.validated ?? 0}</strong><small>prêtes pour publication</small></article>
        <article className="card score-card"><span>Publiées</span><strong>{queue.counts.published ?? 0}</strong><small>visibles par les étudiants</small></article>
        <article className="card score-card"><span>Workflow</span><strong>3 étapes</strong><small>revue → validation → publication</small></article>
      </section>

      {queue.lessons.map((lesson) => {
        const allQuestionsValidated = lesson.question_count > 0 && lesson.validated_questions === lesson.question_count
        const canPublish = lesson.validation_status === 'validated' && allQuestionsValidated
        return (
          <section className="card" key={lesson.id}>
            <div className="section-heading">
              <div>
                <p className="eyebrow">K{lesson.year_number} · {lesson.subject_name} · {lesson.chapter_name}</p>
                <h2>{lesson.title}</h2>
              </div>
              <strong>{statusLabel(lesson.validation_status)}</strong>
            </div>

            {lesson.summary && <p>{lesson.summary}</p>}
            <div className="quick-grid" style={{ marginTop: 12 }}>
              <article className="quick-card"><span>{lesson.question_count}</span><strong>Questions</strong><small>{lesson.validated_questions} validées</small></article>
              <article className="quick-card"><span>✓</span><strong>{lesson.published_questions}</strong><small>questions publiées</small></article>
            </div>

            {Array.isArray(lesson.sources) && lesson.sources.length > 0 && (
              <div style={{ marginTop: 18 }}>
                <p className="eyebrow">Sources</p>
                <div className="weak-list">
                  {lesson.sources.map((source, index) => <article key={index}><span>{renderSource(source)}</span></article>)}
                </div>
              </div>
            )}

            <div style={{ marginTop: 18 }}>
              <p className="eyebrow">Questions</p>
              <div className="weak-list">
                {lesson.questions.map((question, index) => (
                  <article key={question.id}>
                    <div className="section-heading">
                      <div>
                        <strong>{index + 1}. {question.question_text}</strong>
                        <p>{question.type.toUpperCase()} · difficulté {question.difficulty}/5 · {statusLabel(question.validation_status)}</p>
                      </div>
                      {question.validation_status === 'review' && (
                        <button className="secondary-button" disabled={busyId === question.id} onClick={() => updateStatus('question', question.id, 'validated')}>Valider</button>
                      )}
                      {question.validation_status === 'validated' && (
                        <button className="secondary-button" disabled={busyId === question.id} onClick={() => updateStatus('question', question.id, 'review')}>Remettre en revue</button>
                      )}
                    </div>
                    {question.explanation && <p><strong>Correction :</strong> {question.explanation}</p>}
                    {(question.source_document || question.source) && <span>Source : {question.source_document || question.source}</span>}
                  </article>
                ))}
              </div>
            </div>

            <div className="quick-grid" style={{ marginTop: 18 }}>
              {lesson.validation_status === 'review' && (
                <button className="secondary-button" disabled={busyId === lesson.id} onClick={() => updateStatus('lesson', lesson.id, 'validated')}>Valider la leçon</button>
              )}
              {lesson.validation_status === 'validated' && !canPublish && (
                <button className="secondary-button" disabled>Valider toutes les questions avant publication</button>
              )}
              {canPublish && (
                <button className="primary-button" disabled={busyId === lesson.id} onClick={() => publish(lesson)}>Publier la leçon + les questions</button>
              )}
              <Link className="secondary-button" to="/parcours">Voir le parcours étudiant</Link>
            </div>
          </section>
        )
      })}

      {message && <section className="card centered"><p className="feedback">{message}</p></section>}
    </div>
  )
}
