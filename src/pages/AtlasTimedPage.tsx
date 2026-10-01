import { useEffect, useMemo, useRef, useState } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import { finishQuizSessionV2, type QuizQuestionV3 } from '../services/kineoApi'
import { getQuizQuestionsV5, submitQuizAnswerV5 } from '../services/kineoInteractiveApi'
import { finishAtlasSessionV1, type AtlasAttemptSummary } from '../services/atlasApi'
import '../atlas-timed.css'

type HotspotPoint = { x: number; y: number; radius?: number; label?: string }
type LabelItem = { key: string; label: string }
type LabelPoint = HotspotPoint & { key: string; label?: string }
type AnswerResult = {
  correct?: boolean
  xp_earned?: number
  correction?: { explanation?: string | null; correct_hotspot?: HotspotPoint | null; correct_labels?: LabelPoint[] | null }
}

function formatTime(ms: number) {
  const total = Math.max(0, Math.floor(ms / 1000))
  return `${Math.floor(total / 60)}:${(total % 60).toString().padStart(2, '0')}`
}

export default function AtlasTimedPage() {
  const [params] = useSearchParams()
  const sessionId = params.get('session')
  const area = params.get('area') ?? 'Atlas'
  const [questions, setQuestions] = useState<QuizQuestionV3[]>([])
  const [index, setIndex] = useState(0)
  const [hotspot, setHotspot] = useState<{ x: number; y: number } | null>(null)
  const [labelPlacements, setLabelPlacements] = useState<Record<string, { x: number; y: number }>>({})
  const [selectedLabel, setSelectedLabel] = useState<string | null>(null)
  const [result, setResult] = useState<AnswerResult | null>(null)
  const [answered, setAnswered] = useState(0)
  const [correct, setCorrect] = useState(0)
  const [combo, setCombo] = useState(0)
  const [maxCombo, setMaxCombo] = useState(0)
  const [elapsed, setElapsed] = useState(0)
  const [busy, setBusy] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [final, setFinal] = useState<AtlasAttemptSummary | null>(null)
  const sessionStarted = useRef(Date.now())
  const questionStarted = useRef(Date.now())

  const current = questions[index]
  const labels = (current?.metadata?.label_items ?? []) as LabelItem[]
  const liveAccuracy = answered ? Math.round(correct * 100 / answered) : 0
  const progress = questions.length ? Math.round(((index + 1) / questions.length) * 100) : 0
  const canValidate = useMemo(() => {
    if (!current || result) return false
    if (current.type === 'hotspot') return Boolean(hotspot)
    if (current.type === 'image') return labels.length > 0 && labels.every((item) => Boolean(labelPlacements[item.key]))
    return false
  }, [current, result, hotspot, labels, labelPlacements])

  useEffect(() => {
    if (!sessionId) { setError('Session Atlas manquante.'); setBusy(false); return }
    getQuizQuestionsV5(sessionId)
      .then((items) => {
        setQuestions(items)
        sessionStarted.current = Date.now()
        questionStarted.current = Date.now()
      })
      .catch((err: Error) => setError(err.message))
      .finally(() => setBusy(false))
  }, [sessionId])

  useEffect(() => {
    if (final || !questions.length) return
    const timer = window.setInterval(() => setElapsed(Date.now() - sessionStarted.current), 250)
    return () => window.clearInterval(timer)
  }, [final, questions.length])

  function point(event: React.MouseEvent<HTMLElement> | React.DragEvent<HTMLElement>) {
    const rect = event.currentTarget.getBoundingClientRect()
    return {
      x: Math.max(0, Math.min(100, ((event.clientX - rect.left) / rect.width) * 100)),
      y: Math.max(0, Math.min(100, ((event.clientY - rect.top) / rect.height) * 100)),
    }
  }

  function resetQuestion() {
    setHotspot(null)
    setLabelPlacements({})
    setSelectedLabel(null)
    setResult(null)
    setError(null)
    questionStarted.current = Date.now()
  }

  async function validate() {
    if (!sessionId || !current || !canValidate) return
    setBusy(true)
    setError(null)
    try {
      const answer = current.type === 'hotspot'
        ? hotspot
        : { labels: labels.map((item) => ({ key: item.key, ...labelPlacements[item.key] })) }
      const answerResult = await submitQuizAnswerV5({
        sessionId,
        questionId: current.id,
        answer,
        responseTimeMs: Date.now() - questionStarted.current,
      }) as AnswerResult
      setResult(answerResult)
      setAnswered((v) => v + 1)
      if (answerResult.correct) {
        setCorrect((v) => v + 1)
        setCombo((v) => { const next = v + 1; setMaxCombo((best) => Math.max(best, next)); return next })
      } else {
        setCombo(0)
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Impossible de valider la réponse.')
    } finally {
      setBusy(false)
    }
  }

  async function next() {
    if (!sessionId) return
    if (index + 1 < questions.length) {
      setIndex((v) => v + 1)
      resetQuestion()
      return
    }
    setBusy(true)
    setError(null)
    try {
      const atlas = await finishAtlasSessionV1(sessionId)
      await finishQuizSessionV2(sessionId)
      setFinal(atlas)
      setElapsed(atlas.duration_ms)
      setQuestions([])
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Impossible de terminer la série Atlas.')
    } finally {
      setBusy(false)
    }
  }

  if (final) {
    const record = final.accuracy_percent === final.best_accuracy_percent && final.duration_ms <= final.best_duration_ms
    return <div className="stack atlas-play-page">
      <section className="hero-card atlas-result-hero"><div className="hero-copy"><p className="eyebrow light">Atlas · {final.area}</p><h1>{record ? 'Nouveau record 🏆' : 'Série terminée'}</h1><p>{final.correct_count}/{final.question_count} repères correctement identifiés.</p><Link className="primary-button hero-action" to="/atlas">Retour à l’Atlas</Link></div><div className="hero-orbit">🎯</div></section>
      <section className="atlas-live-stats atlas-final-stats">
        <article><small>Précision</small><strong>{final.accuracy_percent}%</strong></article>
        <article><small>Temps</small><strong>{formatTime(final.duration_ms)}</strong></article>
        <article><small>Meilleur combo</small><strong>×{maxCombo}</strong></article>
        <article><small>Record</small><strong>{final.best_accuracy_percent}% · {formatTime(final.best_duration_ms)}</strong></article>
      </section>
    </div>
  }

  if (busy && !current) return <section className="card skeleton-card"><p>Préparation de l’Atlas…</p></section>
  if (error && !current) return <section className="card centered"><h1>Atlas indisponible</h1><p>{error}</p><Link className="secondary-button" to="/atlas">Retour</Link></section>
  if (!current) return <section className="card centered"><h1>Aucun exercice disponible</h1><p>Cette zone ne contient pas encore d’exercice visuel utilisable.</p><Link className="secondary-button" to="/atlas">Retour à l’Atlas</Link></section>

  const correctHotspot = result?.correction?.correct_hotspot
  const correctLabels = result?.correction?.correct_labels ?? []

  return <div className="stack atlas-play-page">
    <section className="atlas-live-bar">
      <div><small>Atlas</small><strong>{area}</strong></div>
      <div><small>Chrono</small><strong>{formatTime(elapsed)}</strong></div>
      <div><small>Précision</small><strong>{liveAccuracy}%</strong></div>
      <div className={combo >= 2 ? 'combo-hot' : ''}><small>Combo</small><strong>×{combo}</strong></div>
    </section>

    <section className="card atlas-progress-card"><div className="section-heading"><div><p className="eyebrow">Repérage {index + 1}/{questions.length}</p><h2>{current.type === 'image' ? 'Légendage' : 'Pointage'}</h2></div><strong>{progress}%</strong></div><div className="progress-track"><div className="progress-fill" style={{ width: `${progress}%` }} /></div></section>

    <section className="card quiz-card atlas-quiz-card">
      <h1>{current.question_text}</h1>

      {current.type === 'hotspot' && current.image_url && <div className="hotspot-wrap"><p className="hotspot-hint">Touchez la structure demandée.</p><div className="hotspot-stage" onClick={(e) => { if (!result && !busy) setHotspot(point(e)) }}><img src={current.image_url} alt="Schéma anatomique interactif" />{hotspot && <span className={['hotspot-marker', result ? (result.correct ? 'correct' : 'incorrect') : ''].filter(Boolean).join(' ')} style={{ left: `${hotspot.x}%`, top: `${hotspot.y}%` }} />}{correctHotspot && <span className="hotspot-marker correct-target" style={{ left: `${correctHotspot.x}%`, top: `${correctHotspot.y}%` }} />}</div>{result && correctHotspot?.label && <p className="correction-line">Zone attendue : <strong>{correctHotspot.label}</strong></p>}</div>}

      {current.type === 'image' && current.image_url && <div className="image-label-wrap"><div className="label-bank"><strong>Étiquettes à placer</strong><div className="match-chips">{labels.map((item) => <button key={item.key} type="button" className={['match-chip', labelPlacements[item.key] ? 'used' : '', selectedLabel === item.key ? 'active' : ''].filter(Boolean).join(' ')} draggable={!result} disabled={Boolean(result)} onDragStart={(e) => e.dataTransfer.setData('text/plain', item.key)} onClick={() => !result && setSelectedLabel(selectedLabel === item.key ? null : item.key)}>{item.label}</button>)}</div><small>Glisse ou touche une étiquette, puis sa position sur le schéma.</small></div><div className="label-stage" onDragOver={(e) => e.preventDefault()} onDrop={(e) => { if (result) return; e.preventDefault(); const key = e.dataTransfer.getData('text/plain'); if (!key) return; const p = point(e); setLabelPlacements((v) => ({ ...v, [key]: p })) }} onClick={(e) => { if (!selectedLabel || result || busy) return; const p = point(e); setLabelPlacements((v) => ({ ...v, [selectedLabel]: p })); setSelectedLabel(null) }}><img src={current.image_url} alt="Schéma anatomique à légender" />{labels.map((item, i) => { const p = labelPlacements[item.key]; return p ? <span key={item.key} className="label-marker" style={{ left: `${p.x}%`, top: `${p.y}%` }}>{i + 1}</span> : null })}{correctLabels.map((item, i) => <span key={`correct-${item.key}`} className="label-marker label-correct" style={{ left: `${item.x}%`, top: `${item.y}%` }}>{i + 1}</span>)}</div><div className="label-legend">{labels.map((item, i) => <span key={item.key}><b>{i + 1}</b>{item.label}</span>)}</div></div>}

      {!result ? <button className="primary-button wide" onClick={validate} disabled={!canValidate || busy}>{busy ? 'Validation…' : 'Valider'}</button> : <div className={result.correct ? 'result-box success' : 'result-box retry'}><strong>{result.correct ? `Juste ! Combo ×${combo} 🔥` : 'À revoir 💡'}</strong>{typeof result.xp_earned === 'number' && result.xp_earned > 0 && <span>+{result.xp_earned} XP</span>}{result.correction?.explanation && <p>{result.correction.explanation}</p>}<button className="primary-button wide" onClick={next} disabled={busy}>{index + 1 >= questions.length ? 'Voir mon score Atlas' : 'Repère suivant'}</button></div>}
      {error && <p className="feedback">{error}</p>}
    </section>
  </div>
}
