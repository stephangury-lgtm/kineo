import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { startAtlasSessionV1 } from '../services/kineoApi'

const areas = [
  { name: 'Hanche', icon: '◉', copy: 'Tête fémorale, col, grand trochanter et légendage.' },
  { name: 'Genou', icon: '◎', copy: 'Patella, ménisques et repérage articulaire.' },
  { name: 'Cheville', icon: '◇', copy: 'Talus, pilon tibial et malléole latérale.' },
  { name: 'Pied', icon: '◌', copy: 'Naviculaire, cuboïde, M5 et tarse antérieur.' },
] as const

export default function AtlasPage() {
  const navigate = useNavigate()
  const [busyArea, setBusyArea] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)

  async function launch(area: string) {
    setBusyArea(area)
    setError(null)
    try {
      const session = await startAtlasSessionV1(area, 8)
      navigate(`/revision?mode=atlas&session=${session.session_id}`)
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
        <h1>Repère les structures, pas seulement les mots.</h1>
        <p>Choisis une zone et enchaîne des exercices de pointage et de légendage issus des CM intégrés dans Kineo.</p>
      </div>
      <div className="hero-orbit" aria-hidden="true">🫀</div>
    </section>

    <section className="atlas-grid" aria-label="Zones anatomiques">
      {areas.map((area) => <article className="card atlas-card" key={area.name}>
        <div className="atlas-card-icon" aria-hidden="true">{area.icon}</div>
        <div>
          <p className="eyebrow">Atlas</p>
          <h2>{area.name}</h2>
          <p>{area.copy}</p>
        </div>
        <button className="primary-button wide" type="button" disabled={Boolean(busyArea)} onClick={() => launch(area.name)}>
          {busyArea === area.name ? 'Préparation…' : 'Lancer la série'}
        </button>
      </article>)}
    </section>

    <section className="card atlas-info">
      <strong>Comment ça marche ?</strong>
      <p>Une série contient jusqu’à 8 exercices visuels. Les bonnes positions restent cachées jusqu’à la correction. Les réponses alimentent ensuite la progression et la répétition espacée comme les autres quiz.</p>
    </section>

    {error && <section className="card centered"><p className="feedback">{error}</p></section>}
  </div>
}
