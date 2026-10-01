import { useEffect, useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { startAtlasSessionV1 } from '../services/kineoApi'
import { getAtlasStatsV1, type AtlasAreaStats } from '../services/atlasApi'

const areas = [
  { name: 'Hanche', icon: '◉', copy: 'Tête fémorale, col, trochanters et muscles de hanche.' },
  { name: 'Genou', icon: '◎', copy: 'Patella, ménisques, ligaments croisés et quadriceps.' },
  { name: 'Cheville', icon: '◇', copy: 'Talus, pilon tibial, malléoles, ligaments et tendons.' },
  { name: 'Pied', icon: '◌', copy: 'Naviculaire, cuboïde, cunéiformes, hallux et M5.' },
] as const

function formatTime(ms?: number) {
  if (!ms && ms !== 0) return '—'
  const total = Math.max(0, Math.round(ms / 1000))
  const min = Math.floor(total / 60)
  const sec = total % 60
  return `${min}:${sec.toString().padStart(2, '0')}`
}

export default function AtlasPage() {
  const navigate = useNavigate()
  const [busyArea, setBusyArea] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [stats, setStats] = useState<AtlasAreaStats[]>([])

  useEffect(() => {
    getAtlasStatsV1().then(setStats).catch(() => undefined)
  }, [])

  const statsByArea = useMemo(() => new Map(stats.map((item) => [item.area, item])), [stats])

  async function launch(area: string) {
    setBusyArea(area)
    setError(null)
    try {
      const session = await startAtlasSessionV1(area, 8)
      navigate(`/atlas/play?session=${session.session_id}&area=${encodeURIComponent(area)}`)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Impossible de lancer l’Atlas.')
    } finally {
      setBusyArea(null)
    }
  }

  return <div className="stack atlas-page">
    <section className="hero-card atlas-hero">
      <div className="hero-copy">
        <p className="eyebrow light">Atlas anatomique</p>
        <h1>Repère vite. Repère juste.</h1>
        <p>8 exercices chronométrés par zone, avec précision, combo et record personnel.</p>
      </div>
      <div className="hero-orbit" aria-hidden="true">🫀</div>
    </section>

    <section className="atlas-grid" aria-label="Zones anatomiques">
      {areas.map((area) => {
        const stat = statsByArea.get(area.name)
        return <article className="card atlas-card" key={area.name}>
          <div className="atlas-card-icon" aria-hidden="true">{area.icon}</div>
          <div>
            <p className="eyebrow">Atlas · 8 exercices</p>
            <h2>{area.name}</h2>
            <p>{area.copy}</p>
          </div>
          <div className="atlas-record-row">
            <span><small>Record précision</small><strong>{stat ? `${stat.best_accuracy_percent}%` : '—'}</strong></span>
            <span><small>Meilleur temps</small><strong>{stat ? formatTime(stat.best_duration_ms) : '—'}</strong></span>
            <span><small>Séries</small><strong>{stat?.attempts ?? 0}</strong></span>
          </div>
          <button className="primary-button wide" type="button" disabled={Boolean(busyArea)} onClick={() => launch(area.name)}>
            {busyArea === area.name ? 'Préparation…' : 'Lancer le chrono'}
          </button>
        </article>
      })}
    </section>

    <section className="card atlas-info">
      <strong>Classement personnel</strong>
      <p>Ton record privilégie d’abord la précision. À précision égale, le meilleur temps devient ton record de la zone.</p>
    </section>

    {error && <section className="card centered"><p className="feedback">{error}</p></section>}
  </div>
}
