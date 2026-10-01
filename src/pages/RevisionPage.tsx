import { useEffect, useMemo, useRef, useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import {
  finishDailyChallengeV2,
  finishQuizSessionV2,
  getQuizQuestionsV4,
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

type ChallengeFinish = { score?: number; xp_earned?: number; bonus_xp?: number; current_streak?: number; new_badges_count?: number }
const ACTIVE_SMART_SESSION = 'kineo_active_smart_session'

export default function RevisionPage() {
  const [searchParams] = useSearchParams()
  const mode = searchParams.get('mode')
  const externalSession = searchParams.get('session')
  const isDaily = mode === 'daily'
  const isLesson = mode === 'lesson' && Boolean(externalSession)
  const resumeChecked = useRef(false)
  const externalChecked = useRef(false)

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
  const progress = useMemo(() => questions.length ? ((index + 1) / questions.length) * 100 : 0, [index, questions.length])
  const leftItems = (current?.metadata?.left_items ?? []) as string[]
  const rightItems = (current?.metadata?.right_items ?? []) as string[]

  useEffect(() => {
    if (!externalSession || externalChecked.current) return
    externalChecked.current = true
    setBusy(true)
    getQuizQuestionsV4(externalSession)
      .then(async (qs) => {
        if (qs.length === 0) {
          await finishQuizSessionV2(externalSession)
          setMessage('Ce quiz ciblé est déjà terminé.')
          return
        }
        setSessionId(externalSession)
        setQuestions(qs)
        setIndex(0)
        setStartedAt(Date.now())
      })
      .catch((err: Error) => setMessage(err.message))
      .finally(() => setBusy(false))
  }, [externalSession])

  useEffect(() => {
    if (isDaily || externalSession || resumeChecked.current) return
    resumeChecked.current = true
    const savedSession = localStorage.getItem(ACTIVE_SMART_SESSION)
    if (!savedSession) return

    setBusy(true)
    getQuizQuestionsV4(savedSession)
      .then(async (qs) => {
        if (qs.length === 0) {
          await finishQuizSessionV2(savedSession)
          localStorage.removeItem(ACTIVE_SMART_SESSION)
          setMessage('Ta session précédente a été finalisée automatiquement.')
          return
        }
        setSessionId(savedSession)
        setQuestions(qs)
        setIndex(0)
        setMessage('Session précédente reprise automatiquement.')
      })
      .catch(() => localStorage.removeItem(ACTIVE_SMART_SESSION))
      .finally(() => setBusy(false))
  }, [externalSession, isDaily])

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
    if (isLesson && externalSession) return
    setBusy(true)
    setMessage(null)
    setSummary(null)
    try {
      if (isDaily) {
        const daily = await startDailyChallengeV2()
        if (daily.completed) {
          setMessage(`Challenge déjà terminé aujourd’hui 🔥 ${daily.score ?? 0}% · ${daily.xp_earned ?? 0} XP`)
          return
        }
        const qs = await getQuizQuestionsV4(daily.session_id)
        if (qs.length === 0) {
          const done = await finishDailyChallengeV2(daily.session_id) as ChallengeFinish
          setSummary(done)
          setMessage(`Challenge terminé 🔥 ${done.score ?? 0}% · +${done.xp_earned ?? 0} XP`)
          return
        }
        setSessionId(daily.session_id)
        setQuestions(qs)
      } else {
        const session = await startSmartRevisionV2(10)
        localStorage.setItem(ACTIVE_SMART_SESSION, session)
        const qs = await getQuizQuestionsV4(session)
        setSessionId(session)
        setQuestions(qs)
      }
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
    if (current.type === 'matching') return { pairs: leftItems.map((left) => ({ left, right: matching[left] })) }
    return {}
  }

  async function validate() {
    if (!sessionId || !current || !canValidate) return
    setBusy(true)
    setMessage(null)
    try {
      setResult(await submitQuizAnswerV3({
        sessionId,
        questionId: current.id,
        answer: buildAnswer(),
        responseTimeMs: Date.now() - startedAt,
      }) as AnswerResult)
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
          const done = await finishDailyChallengeV2(sessionId) as ChallengeFinish
          setSummary(done)
          setMessage(`Challenge terminé 🔥 ${done.score ?? 0}% · +${done.xp_earned ?? 0} XP`)
        } else {
          await finishQuizSessionV2(sessionId)
          if (!externalSession) localStorage.removeItem(ACTIVE_SMART_SESSION)
          setMessage(isLesson ? 'Quiz de leçon terminé 🎉 Ta progression a été mise à jour.' : 'Session terminée 🎉 Ta progression a été mise à jour.')
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
      return <div className="answers">{current.question_options.map((option) => {
        const correctIds = result?.correction?.correct_option_ids ?? []
        const isCorrectOption = Boolean(result && correctIds.includes(option.id))
        const isSelected = selected === option.id
        const className = ['answer', isSelected ? 'selected' : '', isCorrectOption ? 'correct' : '', result && isSelected && !isCorrectOption ? 'incorrect' : ''].filter(Boolean).join(' ')
        return <button key={option.id} className={className} onClick={() => !result && setSelected(option.id)} disabled={busy || Boolean(result)}>{option.option_text}</button>
      })}</div>
    }
    if (current.type === 'fill_blank') {
      return <div className="text-answer-wrap">
        <label htmlFor="fill-answer">Ta réponse</label>
        <input id="fill-answer" className="text-answer" value={textAnswer} onChange={(e) => setTextAnswer(e.target.value)} disabled={busy || Boolean(result)} autoComplete="off" />
        {result?.correction?.correct_answer && <p className="correction-line">Réponse attendue : <strong>{result.correction.correct_answer}</strong></p>}
      </div>
    }
    if (current.type === 'matching') {
      return <div className="matching-grid">
        {leftItems.map((left) => <label className="matching-row" key={left}>
          <span>{left}</span>
          <select value={matching[left] ?? ''} onChange={(e) => setMatching((value) => ({ ...value, [left]: e.target.value }))} disabled={busy || Boolean(result)}>
            <option value="">Choisir…</option>
            {rightItems.map((right) => <option key={right} value={right}>{right}</option>)}
          </select>
        </label>)}
        {result?.correction?.correct_pairs && <div className="correction-box"><strong>Associations correctes</strong>{result.correction.correct_pairs.map((pair) => <span key={`${pair.left}-${pair.right}`}>{pair.left} → {pair.right}</span>)}</div>}
      </div>
    }
    return <p>Ce format de question sera bientôt disponible.</p>
  }

  if (!current) {
    const eyebrow = isDaily ? 'Challenge du jour' : isLesson ? 'Quiz de leçon' : 'Révision intelligente'
    const title = isDaily ? '10 questions pour garder ta flamme 🔥' : isLesson ? 'Quiz ciblé sur cette leçon' : '10 questions adaptées à ta progression'
    const description = isDaily ? 'Termine le challenge du jour pour gagner le bonus quotidien.' : isLesson ? 'Les questions sont choisies uniquement dans la leçon sélectionnée.' : 'Le moteur choisit les révisions dues, erreurs récentes et notions fragiles.'
    const icon = isDaily ? '🔥' : isLesson ? '🎯' : '🧠'

    return <div className="stack">
      <section className="hero-card">
        <div className="hero-copy">
          <p className="eyebrow light">{eyebrow}</p>
          <h1>{title}</h1>
          <p>{description}</p>
          {!isLesson && <button className="primary-button hero-action" onClick={start} disabled={busy}>{busy ? 'Préparation…' : isDaily ? 'Lancer le challenge' : 'Commencer'}</button>}
          {isLesson && busy && <p>Préparation du quiz…</p>}
        </div>
        <div className="hero-orbit" aria-hidden="true">{icon}</div>
      </section>

      <section className="quick-grid">
        <article className="quick-card"><span>10</span><strong>Questions</strong><small>Session courte</small></article>
        <article className="quick-card"><span>⚡</span><strong>XP</strong><small>Progression immédiate</small></article>
      </section>

      {message && <section className="card centered"><p className="feedback">{message}</p>{summary?.current_streak !== undefined && <p>🔥 Série actuelle : <strong>{summary.current_streak} jour{summary.current_streak > 1 ? 's' : ''}</strong></p>}</section>}
    </div>
  }

  return <div className="stack">
    <section className="card">
      <div className="section-heading">
        <div>
          <p className="eyebrow">{isDaily ? 'Challenge du jour' : isLesson ? 'Quiz de leçon' : 'Révision intelligente'}</p>
          <h2>Question {index + 1} sur {questions.length}</h2>
        </div>
        <strong>{Math.round(progress)}%</strong>
      </div>
      <div className="progress-track"><div className="progress-fill" style={{ width: `${progress}%` }} /></div>
    </section>

    <section className="card quiz-card">
      <p className="eyebrow">{current.type === 'mcq' ? 'QCM' : current.type === 'true_false' ? 'Vrai / Faux' : current.type === 'fill_blank' ? 'Texte à compléter' : current.type === 'matching' ? 'Association' : 'Question'}</p>
      <h1>{current.question_text}</h1>
      {current.image_url && <img className="question-image" src={current.image_url} alt="Illustration de la question" />}
      {renderAnswerInput()}
      {!result ? <button className="primary-button wide" onClick={validate} disabled={!canValidate || busy}>{busy ? 'Validation…' : 'Valider ma réponse'}</button> :
        <div className={result.correct ? 'result-box success' : 'result-box retry'}>
          <strong>{result.correct ? 'Bonne réponse ✅' : 'À revoir 💡'}</strong>
          {typeof result.xp_earned === 'number' && result.xp_earned > 0 && <span>+{result.xp_earned} XP</span>}
          {result.correction?.explanation && <p>{result.correction.explanation}</p>}
          <button className="primary-button wide" onClick={next} disabled={busy}>{index + 1 >= questions.length ? (isDaily ? 'Terminer le challenge' : 'Terminer la session') : 'Question suivante'}</button>
        </div>}
      {message && <p className="feedback">{message}</p>}
    </section>
  </div>
}
