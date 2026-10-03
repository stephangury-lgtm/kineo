import { useState } from 'react'
import { updateStudyProfile, type StudentProfile } from '../services/profileApi'

type Props = {
  current: StudentProfile
  onSaved: (profile: StudentProfile) => void
}

export default function ProfileSetupPage({ current, onSaved }: Props) {
  const [firstName, setFirstName] = useState(current.first_name ?? '')
  const [username, setUsername] = useState(current.username ?? '')
  const initialStudyYear = current.study_year && current.study_year >= 2 && current.study_year <= 5 ? current.study_year : 2
  const [studyYear, setStudyYear] = useState<number>(initialStudyYear)
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState<string | null>(null)

  async function save() {
    setBusy(true)
    setError(null)
    try {
      onSaved(await updateStudyProfile({ firstName, username, studyYear }))
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
          <h1>Prépare ton parcours étudiant</h1>
          <p>Ton année détermine les cours et quiz proposés. Le pseudo est facultatif, mais il permet d’utiliser les amis, défis et classements.</p>
        </div>
        <div className="auth-form">
          <label>Prénom (facultatif)<input value={firstName} onChange={(event) => setFirstName(event.target.value)} placeholder="Ton prénom" /></label>
          <label>Pseudo (facultatif)<input value={username} onChange={(event) => setUsername(event.target.value)} placeholder="ex. kineo.marie" autoCapitalize="none" autoCorrect="off" /></label>
          <small className="field-hint">3 à 24 caractères : lettres, chiffres, point, tiret ou underscore. Tu pourras le modifier plus tard.</small>
          <label>Année d’étude<select value={studyYear} onChange={(event) => setStudyYear(Number(event.target.value))}><option value={2}>K2 · 1re année IFMK</option><option value={3}>K3 · 2e année IFMK</option><option value={4}>K4 · 3e année IFMK</option><option value={5}>K5 · 4e année IFMK</option></select></label>
          <button className="primary-button" onClick={save} disabled={busy}>{busy ? 'Enregistrement…' : 'Entrer dans Kineo'}</button>
          {error && <p className="feedback">{error}</p>}
        </div>
      </section>
    </main>
  )
}
