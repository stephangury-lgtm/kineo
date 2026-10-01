import { useEffect, useMemo, useRef, useState } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import {
  finishDailyChallengeV2,
  finishQuizSessionV2,
  startDailyChallengeV2,
  startSmartRevisionV2,
  type QuizQuestionV3,
} from '../services/kineoApi'
import { getQuizQuestionsV5, submitQuizAnswerV5 } from '../services/kineoInteractiveApi'
import '../interactive-quiz.css'

type HotspotPoint = { x: number; y: number; radius?: number; label?: string }
type LabelItem = { key: string; label: string }
type LabelPoint = HotspotPoint & { key: string; label?: string }
type AnswerResult = {
  correct?: boolean
  xp_earned?: number
  correction?: {
    explanation?: string | null
    correct_option_ids?: string[]
    correct_answer?: string | null
    correct_pairs?: Array<{ left: string; right: string }>
    correct_hotspot?: HotspotPoint | null
    correct_labels?: LabelPoint[] | null
  }
}
type ChallengeFinish = { score?: number; xp_earned?: number; bonus_xp?: number; current_streak?: number; new_badges_count?: number }
type SessionSummary = { answered: number; correct: number; xp: number; score: number; streak?: number; badges?: number; isDaily: boolean; isLesson: boolean }
const ACTIVE_SMART_SESSION = 'kineo_active_smart_session'

export default function RevisionPageInteractive() {
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
  const [selectedMatch, setSelectedMatch] = useState<string | null>(null)
  const [hotspot, setHotspot] = useState<{ x: number; y: number } | null>(null)
  const [labelPlacements, setLabelPlacements] = useState<Record<string, { x: number; y: number }>>({})
  const [selectedLabel, setSelectedLabel] = useState<string | null>(null)
  const [result, setResult] = useState<AnswerResult | null>(null)
  const [message, setMessage] = useState<string | null>(null)
  const [summary, setSummary] = useState<ChallengeFinish | null>(null)
  const [sessionSummary, setSessionSummary] = useState<SessionSummary | null>(null)
  const [answeredCount, setAnsweredCount] = useState(0)
  const [correctCount, setCorrectCount] = useState(0)
  const [earnedXp, setEarnedXp] = useState(0)
  const [busy, setBusy] = useState(false)
  const [startedAt, setStartedAt] = useState(Date.now())

  const current = questions[index]
  const progress = questions.length ? ((index + 1) / questions.length) * 100 : 0
  const leftItems = (current?.metadata?.left_items ?? []) as string[]
  const rightItems = (current?.metadata?.right_items ?? []) as string[]
  const labelItems = (current?.metadata?.label_items ?? []) as LabelItem[]

  const canValidate = useMemo(() => {
    if (!current || result) return false
    if (current.type === 'mcq' || current.type === 'true_false') return Boolean(selected)
    if (current.type === 'fill_blank') return textAnswer.trim().length > 0
    if (current.type === 'matching') return leftItems.length > 0 && leftItems.every((left) => Boolean(matching[left]))
    if (current.type === 'hotspot') return Boolean(hotspot)
    if (current.type === 'image') return labelItems.length > 0 && labelItems.every((item) => Boolean(labelPlacements[item.key]))
    return false
  }, [current, result, selected, textAnswer, leftItems, matching, hotspot, labelItems, labelPlacements])

  useEffect(() => {
    if (!externalSession || externalChecked.current) return
    externalChecked.current = true
    setBusy(true)
    getQuizQuestionsV5(externalSession)
      .then(async (qs) => {
        if (!qs.length) {
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
    const saved = localStorage.getItem(ACTIVE_SMART_SESSION)
    if (!saved) return
    setBusy(true)
    getQuizQuestionsV5(saved)
      .then(async (qs) => {
        if (!qs.length) {
          await finishQuizSessionV2(saved)
          localStorage.removeItem(ACTIVE_SMART_SESSION)
          setMessage('Ta session précédente a été finalisée automatiquement.')
          return
        }
        setSessionId(saved)
        setQuestions(qs)
        setIndex(0)
        setMessage('Session précédente reprise automatiquement.')
      })
      .catch(() => localStorage.removeItem(ACTIVE_SMART_SESSION))
      .finally(() => setBusy(false))
  }, [externalSession, isDaily])

  function resetAnswerState() {
    setSelected(null)
    setTextAnswer('')
    setMatching({})
    setSelectedMatch(null)
    setHotspot(null)
    setLabelPlacements({})
    setSelectedLabel(null)
    setResult(null)
    setMessage(null)
    setStartedAt(Date.now())
  }

  function resetStats() {
    setAnsweredCount(0)
    setCorrectCount(0)
    setEarnedXp(0)
    setSessionSummary(null)
  }

  async function start() {
    if (isLesson && externalSession) return
    setBusy(true)
    setMessage(null)
    setSummary(null)
    resetStats()
    try {
      let id: string
      if (isDaily) {
        const daily = await startDailyChallengeV2()
        if (daily.completed) {
          setMessage(`Challenge déjà terminé aujourd’hui 🔥 ${daily.score ?? 0}% · ${daily.xp_earned ?? 0} XP`)
          return
        }
        id = daily.session_id
      } else {
        id = await startSmartRevisionV2(10)
        localStorage.setItem(ACTIVE_SMART_SESSION, id)
      }
      const qs = await getQuizQuestionsV5(id)
      setSessionId(id)
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
    if (current.type === 'matching') return { pairs: leftItems.map((left) => ({ left, right: matching[left] })) }
    if (current.type === 'hotspot' && hotspot) return hotspot
    if (current.type === 'image') return { labels: labelItems.map((item) => ({ key: item.key, ...labelPlacements[item.key] })) }
    return {}
  }

  async function validate() {
    if (!sessionId || !current || !canValidate) return
    setBusy(true)
    setMessage(null)
    try {
      const answerResult = await submitQuizAnswerV5({ sessionId, questionId: current.id, answer: buildAnswer(), responseTimeMs: Date.now() - startedAt }) as AnswerResult
      setResult(answerResult)
      setAnsweredCount((v) => v + 1)
      if (answerResult.correct) setCorrectCount((v) => v + 1)
      if (typeof answerResult.xp_earned === 'number') setEarnedXp((v) => v + answerResult.xp_earned!)
    } catch (err) {
      setMessage(err instanceof Error ? err.message : 'Impossible de valider la réponse.')
    } finally {
      setBusy(false)
    }
  }

  async function next() {
    if (!sessionId) return
    if (index + 1 < questions.length) {
      setIndex((v) => v + 1)
      resetAnswerState()
      return
    }
    setBusy(true)
    try {
      let finalXp = earnedXp
      let finalScore = answeredCount ? Math.round((correctCount / answeredCount) * 100) : 0
      let streak: number | undefined
      let badges: number | undefined
      if (isDaily) {
        const done = await finishDailyChallengeV2(sessionId) as ChallengeFinish
        setSummary(done)
        finalXp = done.xp_earned ?? finalXp
        finalScore = done.score ?? finalScore
        streak = done.current_streak
        badges = done.new_badges_count
      } else {
        await finishQuizSessionV2(sessionId)
        if (!externalSession) localStorage.removeItem(ACTIVE_SMART_SESSION)
      }
      setSessionSummary({ answered: answeredCount, correct: correctCount, xp: finalXp, score: finalScore, streak, badges, isDaily, isLesson })
      setQuestions([])
      setSessionId(null)
      setResult(null)
    } catch (err) {
      setMessage(err instanceof Error ? err.message : 'Impossible de terminer la session.')
    } finally {
      setBusy(false)
    }
  }

  function assignMatch(left: string, right: string) {
    if (result) return
    setMatching((previous) => {
      const next = { ...previous }
      Object.keys(next).forEach((key) => { if (next[key] === right) delete next[key] })
      next[left] = right
      return next
    })
    setSelectedMatch(null)
  }

  function placeLabel(key: string, x: number, y: number) {
    if (result) return
    setLabelPlacements((v) => ({ ...v, [key]: { x, y } }))
    setSelectedLabel(null)
  }

  function imagePoint(event: React.MouseEvent<HTMLElement> | React.DragEvent<HTMLElement>) {
    const rect = event.currentTarget.getBoundingClientRect()
    return {
      x: Math.max(0, Math.min(100, ((event.clientX - rect.left) / rect.width) * 100)),
      y: Math.max(0, Math.min(100, ((event.clientY - rect.top) / rect.height) * 100)),
    }
  }

  function renderAnswerInput() {
    if (!current) return null

    if (current.type === 'mcq' || current.type === 'true_false') {
      return <div className="answers">{current.question_options.map((option) => {
        const correctIds = result?.correction?.correct_option_ids ?? []
        const isCorrect = Boolean(result && correctIds.includes(option.id))
        const isSelected = selected === option.id
        const cls = ['answer', isSelected ? 'selected' : '', isCorrect ? 'correct' : '', result && isSelected && !isCorrect ? 'incorrect' : ''].filter(Boolean).join(' ')
        return <button key={option.id} className={cls} onClick={() => !result && setSelected(option.id)} disabled={busy || Boolean(result)}>{option.option_text}</button>
      })}</div>
    }

    if (current.type === 'fill_blank') {
      return <div className="text-answer-wrap"><label htmlFor="fill-answer">Ta réponse</label><input id="fill-answer" className="text-answer" value={textAnswer} onChange={(e) => setTextAnswer(e.target.value)} disabled={busy || Boolean(result)} autoComplete="off" />{result?.correction?.correct_answer && <p className="correction-line">Réponse attendue : <strong>{result.correction.correct_answer}</strong></p>}</div>
    }

    if (current.type === 'matching') {
      return <div className="matching-dnd">
        <div className="match-bank"><strong>Étiquettes à placer</strong><div className="match-chips">{rightItems.map((right) => {
          const used = Object.values(matching).includes(right)
          return <button key={right} type="button" className={['match-chip', used ? 'used' : '', selectedMatch === right ? 'active' : ''].filter(Boolean).join(' ')} draggable={!result} disabled={Boolean(result)} onDragStart={(e) => e.dataTransfer.setData('text/plain', right)} onClick={() => !result && setSelectedMatch(selectedMatch === right ? null : right)}>{right}</button>
        })}</div><small>Glisse une étiquette vers sa cible. Sur mobile, touche l’étiquette puis la cible.</small></div>
        <div className="match-targets">{leftItems.map((left) => <div className="matching-drop-row" key={left}><span className="match-left">{left}</span><button type="button" className={['match-dropzone', matching[left] ? 'filled' : ''].filter(Boolean).join(' ')} disabled={Boolean(result)} onDragOver={(e) => e.preventDefault()} onDrop={(e) => { e.preventDefault(); const right = e.dataTransfer.getData('text/plain'); if (right) assignMatch(left, right) }} onClick={() => selectedMatch && assignMatch(left, selectedMatch)}>{matching[left] ?? 'Déposer ici'}</button>{matching[left] && !result && <button className="match-clear" type="button" onClick={() => setMatching((p) => { const n = { ...p }; delete n[left]; return n })}>×</button>}</div>)}</div>
        {result?.correction?.correct_pairs && <div className="correction-box"><strong>Associations correctes</strong>{result.correction.correct_pairs.map((p) => <span key={`${p.left}-${p.right}`}>{p.left} → {p.right}</span>)}</div>}
      </div>
    }

    if (current.type === 'hotspot' && current.image_url) {
      const correct = result?.correction?.correct_hotspot
      return <div className="hotspot-wrap"><p className="hotspot-hint">Touchez directement la structure demandée sur le schéma.</p><div className="hotspot-stage" onClick={(e) => { if (result || busy) return; setHotspot(imagePoint(e)) }}><img src={current.image_url} alt="Schéma anatomique interactif" />{hotspot && <span className={['hotspot-marker', result ? (result.correct ? 'correct' : 'incorrect') : ''].filter(Boolean).join(' ')} style={{ left: `${hotspot.x}%`, top: `${hotspot.y}%` }} />}{correct && <span className="hotspot-marker correct-target" style={{ left: `${correct.x}%`, top: `${correct.y}%` }} />}</div>{!result && hotspot && <small>Point sélectionné. Touchez ailleurs pour le déplacer.</small>}{result && correct?.label && <p className="correction-line">Zone attendue : <strong>{correct.label}</strong></p>}</div>
    }

    if (current.type === 'image' && current.image_url) {
      const correctLabels = result?.correction?.correct_labels ?? []
      return <div className="image-label-wrap">
        <div className="label-bank"><strong>Étiquettes</strong><div className="match-chips">{labelItems.map((item) => <button key={item.key} type="button" className={['match-chip', labelPlacements[item.key] ? 'used' : '', selectedLabel === item.key ? 'active' : ''].filter(Boolean).join(' ')} draggable={!result} disabled={Boolean(result)} onDragStart={(e) => e.dataTransfer.setData('text/plain', item.key)} onClick={() => !result && setSelectedLabel(selectedLabel === item.key ? null : item.key)}>{item.label}</button>)}</div><small>Glisse chaque étiquette sur le schéma. Sur mobile, touche l’étiquette puis sa position.</small></div>
        <div className="label-stage" onDragOver={(e) => e.preventDefault()} onDrop={(e) => { if (result) return; e.preventDefault(); const key = e.dataTransfer.getData('text/plain'); if (!key) return; const p = imagePoint(e); placeLabel(key, p.x, p.y) }} onClick={(e) => { if (!selectedLabel || result || busy) return; const p = imagePoint(e); placeLabel(selectedLabel, p.x, p.y) }}>
          <img src={current.image_url} alt="Schéma anatomique à légender" />
          {labelItems.map((item, i) => { const p = labelPlacements[item.key]; return p ? <span key={item.key} className={['label-marker', result ? 'submitted' : ''].filter(Boolean).join(' ')} style={{ left: `${p.x}%`, top: `${p.y}%` }} title={item.label}>{i + 1}</span> : null })}
          {correctLabels.map((item, i) => <span key={`correct-${item.key}`} className="label-marker label-correct" style={{ left: `${item.x}%`, top: `${item.y}%` }} title={item.label}>{i + 1}</span>)}
        </div>
        <div className="label-legend">{labelItems.map((item, i) => <span key={item.key}><b>{i + 1}</b>{item.label}</span>)}</div>
        {!result && Object.keys(labelPlacements).length > 0 && <button type="button" className="secondary-button" onClick={() => { setLabelPlacements({}); setSelectedLabel(null) }}>Recommencer le placement</button>}
      </div>
    }

    return <p>Ce format de question sera bientôt disponible.</p>
  }

  if (!current) {
    if (sessionSummary) {
      const verdict = sessionSummary.score >= 80 ? 'Très solide 👏' : sessionSummary.score >= 60 ? 'Bonne progression 💪' : 'Encore un tour et ça rentre 🧠'
      return <div className="stack"><section className="hero-card"><div className="hero-copy"><p className="eyebrow light">Session terminée</p><h1>{verdict}</h1><p>{sessionSummary.isDaily ? 'Challenge du jour validé.' : sessionSummary.isLesson ? 'Ta leçon vient d’être consolidée.' : 'Ta progression et tes prochaines révisions ont été mises à jour.'}</p><Link className="primary-button hero-action" to="/">Retour à l’accueil</Link></div><div className="hero-orbit" aria-hidden="true">🏁</div></section><section className="stats-grid"><article className="card stat"><span>Score</span><strong>{sessionSummary.score}%</strong></article><article className="card stat"><span>Bonnes réponses</span><strong>{sessionSummary.correct}/{sessionSummary.answered}</strong></article><article className="card stat"><span>XP gagnés</span><strong>+{sessionSummary.xp}</strong></article><article className="card stat"><span>Objectif</span><strong>{sessionSummary.score >= 90 ? 'Solide' : '90%'}</strong></article></section>{(sessionSummary.streak !== undefined || (sessionSummary.badges ?? 0) > 0) && <section className="card centered">{sessionSummary.streak !== undefined && <p>🔥 Série actuelle : <strong>{sessionSummary.streak} jour{sessionSummary.streak > 1 ? 's' : ''}</strong></p>}{(sessionSummary.badges ?? 0) > 0 && <p>🏆 Nouveau badge débloqué !</p>}</section>}<section className="quick-grid">{!sessionSummary.isLesson && <button className="quick-card" type="button" onClick={start}><span>↻</span><strong>Nouvelle session</strong><small>Continuer à progresser</small></button>}<Link className="quick-card" to="/stats"><span>↗</span><strong>Voir mes stats</strong><small>Suivre ma progression</small></Link></section></div>
    }
    const eyebrow = isDaily ? 'Challenge du jour' : isLesson ? 'Quiz de leçon' : 'Révision intelligente'
    const title = isDaily ? '10 questions pour garder ta flamme 🔥' : isLesson ? 'Quiz ciblé sur cette leçon' : '10 questions adaptées à ta progression'
    const description = isDaily ? 'Termine le challenge du jour pour gagner le bonus quotidien.' : isLesson ? 'Les questions sont choisies uniquement dans la leçon sélectionnée.' : 'Le moteur choisit les révisions dues, erreurs récentes et notions fragiles.'
    const icon = isDaily ? '🔥' : isLesson ? '🎯' : '🧠'
    return <div className="stack"><section className="hero-card"><div className="hero-copy"><p className="eyebrow light">{eyebrow}</p><h1>{title}</h1><p>{description}</p>{!isLesson && <button className="primary-button hero-action" onClick={start} disabled={busy}>{busy ? 'Préparation…' : isDaily ? 'Lancer le challenge' : 'Commencer'}</button>}{isLesson && busy && <p>Préparation du quiz…</p>}</div><div className="hero-orbit" aria-hidden="true">{icon}</div></section><section className="quick-grid"><article className="quick-card"><span>{isLesson ? '🎯' : '10'}</span><strong>{isLesson ? 'Quiz ciblé' : 'Questions'}</strong><small>{isLesson ? 'Selon le contenu disponible' : 'Session courte'}</small></article><article className="quick-card"><span>⚡</span><strong>XP</strong><small>Progression immédiate</small></article></section>{message && <section className="card centered"><p className="feedback">{message}</p>{summary?.current_streak !== undefined && <p>🔥 Série actuelle : <strong>{summary.current_streak} jour{summary.current_streak > 1 ? 's' : ''}</strong></p>}</section>}</div>
  }

  const typeLabel = current.type === 'mcq' ? 'QCM' : current.type === 'true_false' ? 'Vrai / Faux' : current.type === 'fill_blank' ? 'Texte à compléter' : current.type === 'matching' ? 'Glisser-déposer' : current.type === 'hotspot' ? 'Zone à pointer' : current.type === 'image' ? 'Légendage' : 'Question'

  return <div className="stack"><section className="card"><div className="section-heading"><div><p className="eyebrow">{isDaily ? 'Challenge du jour' : isLesson ? 'Quiz de leçon' : 'Révision intelligente'}</p><h2>Question {index + 1} sur {questions.length}</h2></div><strong>{Math.round(progress)}%</strong></div><div className="progress-track"><div className="progress-fill" style={{ width: `${progress}%` }} /></div></section><section className="card quiz-card"><p className="eyebrow">{typeLabel}</p><h1>{current.question_text}</h1>{current.image_url && current.type !== 'hotspot' && current.type !== 'image' && <img className="question-image" src={current.image_url} alt="Illustration de la question" />}{renderAnswerInput()}{!result ? <button className="primary-button wide" onClick={validate} disabled={!canValidate || busy}>{busy ? 'Validation…' : 'Valider ma réponse'}</button> : <div className={result.correct ? 'result-box success' : 'result-box retry'}><strong>{result.correct ? 'Bonne réponse ✅' : 'À revoir 💡'}</strong>{typeof result.xp_earned === 'number' && result.xp_earned > 0 && <span>+{result.xp_earned} XP</span>}{result.correction?.explanation && <p>{result.correction.explanation}</p>}<button className="primary-button wide" onClick={next} disabled={busy}>{index + 1 >= questions.length ? (isDaily ? 'Voir mon résultat' : 'Voir mon bilan') : 'Question suivante'}</button></div>}{message && <p className="feedback">{message}</p>}</section></div>
}
