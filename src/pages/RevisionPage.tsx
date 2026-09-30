import { useMemo, useState } from 'react'
import {
  finishQuizSessionV2,
  getQuizQuestionsV3,
  startSmartRevisionV2,
  submitQuizAnswerV3,
  type QuizQuestionV3,
} from '../services/kineoApi'

export default function RevisionPage() {
  const [sessionId, setSessionId] = useState<string | null>(null)
  const [questions, setQuestions] = useState<QuizQuestionV3[]>([])
  const [index, setIndex] = useState(0)
  const [selected, setSelected] = useState<string | null>(null)
  const [feedback, setFeedback] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)
  const [startedAt, setStartedAt] = useState<number>(Date.now())

  const current = questions[index]
  const progress = useMemo(() => questions.length ? ((index + 1) / questions.length) * 100 : 0, [index, questions.length])

  async function start() {
    setBusy(true)
    setFeedback(null)
    try {
      const session = await startSmartRevisionV2(10)
      const qs = await getQuizQuestionsV3(session)
      setSessionId(session)
      setQuestions(qs)
      setIndex(0)
      setSelected(null)
      setStartedAt(Date.now())
    } catch (err) {
      setFeedback(err instanceof Error ? err.message : 'Impossible de démarrer la session.')
    } finally {
      setBusy(false)
    }
  }

  async function validate() {
    if (!sessionId || !current || !selected) return
    setBusy(true)
    try {
      const result = await submitQuizAnswerV3({
        sessionId,
        questionId: current.id,
        answer: { option_id: selected },
        responseTimeMs: Date.now() - startedAt,
      }) as { is_correct?: boolean; explanation?: string }

      setFeedback(result?.is_correct ? 'Bonne réponse ✅' : 'À revoir 💡')

      if (index + 1 >= questions.length) {
        await finishQuizSessionV2(sessionId)
        setFeedback('Session terminée 🎉 Ta progression a été mise à jour.')
        setQuestions([])
        setSessionId(null)
        return
      }

      setTimeout(() => {
        setIndex((value) => value + 1)
        setSelected(null)
        setFeedback(null)
        setStartedAt(Date.now())
      }, 650)
    } catch (err) {
      setFeedback(err instanceof Error ? err.message : 'Impossible de valider la réponse.')
    } finally {
      setBusy(false)
    }
  }

  if (!current) {
    return (
      <section className="card centered">
        <p className="eyebrow">Révision intelligente</p>
        <h1>10 questions adaptées à ta progression</h1>
        <p>Le contenu est choisi par le moteur SRS. Les bonnes réponses ne sont jamais envoyées au client avant ta validation.</p>
        <button className="primary-button" onClick={start} disabled={busy}>{busy ? 'Préparation…' : 'Commencer'}</button>
        {feedback && <p className="feedback">{feedback}</p>}
      </section>
    )
  }

  return (
    <div className="stack">
      <div className="progress-track"><div className="progress-fill" style={{ width: `${progress}%` }} /></div>
      <section className="card quiz-card">
        <p className="eyebrow">Question {index + 1} / {questions.length}</p>
        <h1>{current.question_text}</h1>
        <div className="answers">
          {current.question_options.map((option) => (
            <button
              key={option.id}
              className={selected === option.id ? 'answer selected' : 'answer'}
              onClick={() => setSelected(option.id)}
              disabled={busy}
            >
              {option.option_text}
            </button>
          ))}
        </div>
        <button className="primary-button" onClick={validate} disabled={!selected || busy}>Valider</button>
        {feedback && <p className="feedback">{feedback}</p>}
      </section>
    </div>
  )
}
