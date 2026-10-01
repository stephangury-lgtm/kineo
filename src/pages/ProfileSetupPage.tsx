import { useState } from 'react'
import { updateStudyProfile, type StudentProfile } from '../services/profileApi'

type Props = {
  current: StudentProfile
  onSaved: (profile: StudentProfile) => void
}

export default function ProfileSetupPage({ current, onSaved }: Props) {
  const [firstName, setFirstName] = useState(current.first_name ?? '')
  const [studyYear, setStudyYear] = useState<number>(current.study_year ?? 1)
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState<string | null>(null)

  async function save() {
    setBusy(true)
    setError(null)
    try {
      onSaved(await updateStudyProfile({ firstName, studyYear }))
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Impossible d’enregistrer ton profil.')
    } finally {
      setBusy(false)
    }
  }

  return (
    <main className="auth-shell">
      <section className="card auth-card">
        <div>
          <p className="eyebrow">Bienvenue sur Kineo</p>
          <h1>Personnalise ton parcours</h1>
          <p>Indique simplement ton année d’étude. Tu pourras ensuite réviser les contenus adaptés à ton niveau.</p>
        </div>

        <div className="auth-form">
          <label>
            Prénom (facultatif)
            <input value={firstName} onChange={(event) => setFirstName(event.target.value)} placeholder="Ton prénom" />
          </label>

          <label>
            Année d’étude
            <select value={studyYear} onChange={(event) => setStudyYear(Number(event.target.value))}>
              <option value={1}>K1 · 1re année</option>
              <option value={2}>K2 · 2e année</option>
              <option value={3}>K3 · 3e année</option>
              <option value={4}>K4 · 4e année</option>
            </select>
          </label>

          <button className="primary-button" onClick={save} disabled={busy}>
            {busy ? 'Enregistrement…' : 'Continuer'}
          </button>
          {error && <p className="feedback">{error}</p>}
        </div>
      </section>
    </main>
  )
}
