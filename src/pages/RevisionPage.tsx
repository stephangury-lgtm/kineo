import { useMemo, useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import {
  finishDailyChallengeV2,
  finishQuizSessionV2,
  getQuizQuestionsV3,
  startDailyChallengeV2,
  startSmartRevisionV2,
  submitQuizAnswerV3,
  type QuizQuestionV3,
} from '../services/kineoApi'

type AnswerResult = {
  correct?: boolean
  xp_earned?: number
  correction?: {
    explanation?: string | null
    correct_option_ids?: string[]
    correct_answer?: string | null
    correct_pairs?: Array<{ left: string; right: string }>
  }
}

type ChallengeFinish = {
  score?: number
  xp_earned?: number
  bonus_xp?: number
  current_streak?: number
  new_badges_count?: number
}

export default function RevisionPage() {
  const [searchParams] = useSearchParams()
  const isDaily = searchParams.get('mode') === 'daily'

  const [sessionId, setSessionId] = useState<string | null>(null)
  const [questions, setQuestions] = useState<QuizQuestionV3[]>([])
  const [index, setIndex] = useState(0)
  const [selected, setSelected] = useState<string | null>(null)
  const [textAnswer, setTextAnswer] = useState('')
  const [matching, setMatching] = useState<Record<string, string>>({})
  const [result, setResult] = useState<AnswerResult | null>(null)
  const [message, setMessage] = useState<string | null>(null)
  const [summary, setSummary] = useState<ChallengeFinish | null>(null)
  const [busy, setBusy] = useState(false)
  const [startedAt, setStartedAt] = useState<number>(Date.now())

  const current = questions[index]
  const progress = useMemo(
    () => (questions.length ? ((index + 1) / questions.length) * 100 : 0),
    [index, questions.length],
  )

  const leftItems = (current?.metadata?.left_items ?? []) as string[]
  const rightItems = (current?.metadata?.right_items ?? []) as string[]

  const canValidate = useMemo(() => {
    if (!current || result) return false
    if (current.type === 'mcq' || current.type === 'true_false') return Boolean(selected)
    if (current.type === 'fill_blank') return textAnswer.trim().length > 0
    if (current.type === 'matching') return leftItems.length > 0 && leftItems.every((left) => Boolean(matching[left]))
    return false
  }, [current, leftItems, matching, result, selected, textAnswer])

  function resetAnswerState() {
    setSelected(null)
    setTextAnswer('')
    setMatching({})
    setResult(null)
    setMessage(null)
    setStartedAt(Date.now())
  }

  async function start() {
    setBusy(true)
    setMessage(null)
    setSummary(null)
    try {
      const session = isDaily
        ? (await startDailyChallengeV2()).session_id
        : await startSmartRevisionV2(10)
      const qs = await getQuizQuestionsV3(session)
      setSessionId(session)
      setQuestions(qs)
      setIndex(0)
      resetAnswerState()
    } catch (err) {
      setMessage(err instanceof Error ? err.message : 'Impossible de démarrer la session.')
    } finally {
      setBusy(false)
    }
  }

  function buildAnswer() {
    if (!current) return {}
    if (current.type === 'mcq' || current.type === 'true_false') return { option_id: selected }
    if (current.type === 'fill_blank') return { text: textAnswer.trim() }
    if (current.type === 'matching') {
      return { pairs: leftItems.map((left) => ({ left, right: matching[left] })) }
    }
    return {}
  }

  async function validate() {
    if (!sessionId || !current || !canValidate) return
    setBusy(true)
    setMessage(null)
    try {
      const answerResult = await submitQuizAnswerV3({
        sessionId,
        questionId: current.id,
        answer: buildAnswer(),
        responseTimeMs: Date.now() - startedAt,
      }) as AnswerResult
      setResult(answerResult)
    } catch (err) {
      setMessage(err instanceof Error ? err.message : 'Impossible de valider la réponse.')
    } finally {
      setBusy(false)
    }
  }

  async function next() {
    if (!sessionId) return

    if (index + 1 >= questions.length) {
      setBusy(true)
      try {
        if (isDaily) {
          const dailySummary = await finishDailyChallengeV2(sessionId) as ChallengeFinish
          setSummary(dailySummary)
          setMessage(`Challenge terminé 🔥 ${dailySummary.score ?? 0}% · +${dailySummary.xp_earned ?? 0} XP`)
        } else {
          await finishQuizSessionV2(sessionId)
          setMessage('Session terminée 🎉 Ta progression a été mise à jour.')
        }
        setQuestions([])
        setSessionId(null)
        setResult(null)
      } catch (err) {
        setMessage(err instanceof Error ? err.message : 'Impossible de terminer la session.')
      } finally {
        setBusy(false)
      }
      return
    }

    setIndex((value) => value + 1)
    resetAnswerState()
  }

  function renderAnswerInput() {
    if (!current) return null

    if (current.type === 'mcq' || current.type === 'true_false') {
      return (
        <div className="answers">
          {current.question_options.map((option) => {
            const correctIds = result?.correction?.correct_option_ids ?? []
            const isCorrectOption = Boolean(result && correctIds.includes(option.id))
            const isSelected = selected === option.id
            const className = [
              'answer', isSelected ? 'selected' : '', isCorrectOption ? 'correct' : '',
              result && isSelected && !isCorrectOption ? 'incorrect' : '',
            ].filter(Boolean).join(' ')

            return (
              <button key={option.id} className={className} onClick={() => !result && setSelected(option.id)} disabled={busy || Boolean(result)}>
                {option.option_text}
              </button>
            )
          })}
        </div>
      )
    }

    if (current.type === 'fill_blank') {
      return (
        <div className="text-answer-wrap">
          <label htmlFor="fill-answer">Ta réponse</label>
          <input id="fill-answer" className="text-answer" value={textAnswer} onChange={(event) => setTextAnswer(event.target.value)} disabled={busy || Boolean(result)} autoComplete="off" />
          {result?.correction?.correct_answer && <p className="correction-line">Réponse attendue : <strong>{result.correction.correct_answer}</strong></p>}
        </div>
      )
    }

    if (current.type === 'matching') {
      return (
        <div className="matching-grid">
          {leftItems.map((left) => (
            <label className="matching-row" key={left}>
              <span>{left}</span>
              <select value={matching[left] ?? ''} onChange={(event) => setMatching((value) => ({ ...value, [left]: event.target.value }))} disabled={busy || Boolean(result)}>
                <option value="">Choisir…</option>
                {rightItems.map((right) => <option key={right} value={right}>{right}</option>)}
              </select>
            </label>
          ))}
          {result?.correction?.correct_pairs && (
            <div className="correction-box">
              <strong>Associations correctes</strong>
              {result.correction.correct_pairs.map((pair) => <span key={`${pair.left}-${pair.right}`}>{pair.left} → {pair.right}</span>)}
            </div>
          )}
        </div>
      )
    }

    return <p>Ce format de question sera bientôt disponible.</p>
  }

  if (!current) {
    return (
      <section className="card centered">
        <p className="eyebrow">{isDaily ? 'Challenge du jour' : 'Révision intelligente'}</p>
        <h1>{isDaily ? '10 questions pour garder ta flamme 🔥' : '10 questions adaptées à ta progression'}</h1>
        <p>{isDaily ? 'Termine le challenge du jour pour gagner le bonus quotidien.' : 'Le moteur choisit les révisions dues, erreurs récentes et notions fragiles.'}</p>
        <button className="primary-button" onClick={start} disabled={busy}>{busy ? 'Préparation…' : isDaily ? 'Lancer le challenge' : 'Commencer'}</button>
        {message && <p className="feedback">{message}</p>}
        {summary?.current_streak !== undefined && <p>🔥 Série actuelle : <strong>{summary.current_streak} jour{summary.current_streak > 1 ? 's' : ''}</strong></p>}
      </section>
    )
  }

  return (
    <div className="stack">
      <div className="progress-track"><div className="progress-fill" style={{ width: `${progress}%` }} /></div>
      <section className="card quiz-card">
        <p className="eyebrow">{isDaily ? 'Challenge · ' : ''}Question {index + 1} / {questions.length}</p>
        <h1>{current.question_text}</h1>
        {current.image_url && <img className="question-image" src={current.image_url} alt="Illustration de la question" />}
        {renderAnswerInput()}

        {!result ? (
          <button className="primary-button" onClick={validate} disabled={!canValidate || busy}>{busy ? 'Validation…' : 'Valider'}</button>
        ) : (
          <div className={result.correct ? 'result-box success' : 'result-box retry'}>
            <strong>{result.correct ? 'Bonne réponse ✅' : 'À revoir 💡'}</strong>
            {typeof result.xp_earned === 'number' && result.xp_earned > 0 && <span>+{result.xp_earned} XP</span>}
            {result.correction?.explanation && <p>{result.correction.explanation}</p>}
            <button className="primary-button" onClick={next} disabled={busy}>{index + 1 >= questions.length ? (isDaily ? 'Terminer le challenge' : 'Terminer la session') : 'Question suivante'}</button>
          </div>
        )}
        {message && <p className="feedback">{message}</p>}
      </section>
    </div>
  )
}
