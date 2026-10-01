import { useEffect, useMemo, useState } from 'react'
import { useLocation } from 'react-router-dom'
import { getRevisionSessionMetaV1, type RevisionSessionMeta } from '../services/kineoApi'
import './ExamTimerBar.css'

function formatDuration(totalSeconds: number) {
  const minutes = Math.floor(totalSeconds / 60)
  const seconds = totalSeconds % 60
  return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`
}

export default function ExamTimerBar() {
  const location = useLocation()
  const params = useMemo(() => new URLSearchParams(location.search), [location.search])
  const sessionId = params.get('session')
  const active = location.pathname === '/revision' && params.get('mode') === 'exam' && Boolean(sessionId)
  const [meta, setMeta] = useState<RevisionSessionMeta | null>(null)
  const [elapsed, setElapsed] = useState(0)

  useEffect(() => {
    if (!active || !sessionId) { setMeta(null); setElapsed(0); return }
    let mounted = true
    void getRevisionSessionMetaV1(sessionId).then((value) => {
      if (!mounted || !value) return
      setMeta(value)
      setElapsed(value.elapsed_seconds ?? 0)
    }).catch(() => undefined)
    return () => { mounted = false }
  }, [active, sessionId])

  useEffect(() => {
    if (!active || !meta || meta.completed_at) return
    const timer = window.setInterval(() => setElapsed((value) => value + 1), 1000)
    return () => window.clearInterval(timer)
  }, [active, meta])

  if (!active || !meta) return null

  const targetSeconds = Math.max(15 * 60, meta.question_count * 90)
  const progress = Math.min(100, Math.round((elapsed / targetSeconds) * 100))
  const overtime = elapsed > targetSeconds

  return (
    <div className={`exam-timer-bar ${overtime ? 'overtime' : ''}`} role="status" aria-live="polite">
      <div><strong>📝 Examen blanc</strong><span>{meta.question_count} questions · objectif {Math.round(targetSeconds / 60)} min</span></div>
      <div className="exam-timer-clock"><span>{overtime ? 'Temps dépassé' : 'Temps écoulé'}</span><strong>{formatDuration(elapsed)}</strong></div>
      <div className="exam-timer-track" aria-hidden="true"><i style={{ width: `${progress}%` }} /></div>
    </div>
  )
}
