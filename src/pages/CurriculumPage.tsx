import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { getCurriculumV2, startLessonQuizV2, type CurriculumYear } from '../services/curriculumApi'

export default function CurriculumPage() {
  const navigate = useNavigate()
  const [years, setYears] = useState<CurriculumYear[]>([])
  const [busyLesson, setBusyLesson] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    getCurriculumV2().then(setYears).catch((err: Error) => setError(err.message))
  }, [])

  async function launchLesson(lessonId: string) {
    setBusyLesson(lessonId)
    setError(null)
    try {
      const sessionId = await startLessonQuizV2(lessonId, 10)
      navigate(`/revision?mode=lesson&session=${encodeURIComponent(sessionId)}`)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Impossible de démarrer ce quiz.')
      setBusyLesson(null)
    }
  }

  if (error && years.length === 0) {
    return <section className="card"><h1>Parcours indisponible</h1><p>{error}</p></section>
  }

  if (years.length === 0) {
    return <section className="card"><p>Chargement du parcours pédagogique…</p></section>
  }

  return (
    <div className="stack">
      <section className="card">
        <p className="eyebrow">Parcours pédagogique</p>
        <h1>Réviser par année et par thème</h1>
        <p>Le contenu affiché ici provient uniquement des éléments publiés dans Kineo. Les quiz de leçon utilisent le même moteur sécurisé que les révisions intelligentes.</p>
      </section>

      {years.map((year) => (
        <section className="card" key={year.id}>
          <p className="eyebrow">Année {year.number}</p>
          <h2>{year.name}</h2>
          {year.description && <p>{year.description}</p>}

          {year.subjects.length === 0 ? (
            <p>Aucun contenu publié pour cette année pour le moment.</p>
          ) : (
            <div className="subject-list">
              {year.subjects.map((subject) => (
                <details key={subject.id}>
                  <summary className="subject-row">
                    <div>
                      <strong>{subject.icon ? `${subject.icon} ` : ''}{subject.name}</strong>
                      <span>{subject.chapter_count} chapitre{subject.chapter_count > 1 ? 's' : ''}</span>
                    </div>
                  </summary>

                  <div className="stack">
                    {subject.chapters.map((chapter) => (
                      <article key={chapter.id} className="card">
                        <h3>{chapter.name}</h3>
                        {chapter.description && <p>{chapter.description}</p>}
                        <p>{chapter.published_questions} question{chapter.published_questions > 1 ? 's' : ''} publiée{chapter.published_questions > 1 ? 's' : ''}</p>

                        {chapter.lessons.length === 0 ? (
                          <p>Les questions de ce chapitre ne sont pas encore regroupées en leçons publiées.</p>
                        ) : chapter.lessons.map((lesson) => (
                          <div className="subject-row" key={lesson.id}>
                            <div>
                              <strong>{lesson.title}</strong>
                              {lesson.summary && <span>{lesson.summary}</span>}
                              <span>{lesson.published_questions} questions · maîtrise {lesson.mastery_percent}%</span>
                              <div className="progress-track">
                                <div className="progress-fill" style={{ width: `${Math.min(100, lesson.mastery_percent)}%` }} />
                              </div>
                            </div>
                            <button
                              className="primary-button"
                              onClick={() => launchLesson(lesson.id)}
                              disabled={busyLesson === lesson.id || lesson.published_questions === 0}
                            >
                              {busyLesson === lesson.id ? 'Préparation…' : 'Quiz'}
                            </button>
                          </div>
                        ))}
                      </article>
                    ))}
                  </div>
                </details>
              ))}
            </div>
          )}
        </section>
      ))}

      {error && <section className="card"><p className="feedback">{error}</p></section>}
    </div>
  )
}
