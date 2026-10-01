import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { getCurrentProfile, updateStudyProfile, type StudentProfile } from '../services/profileApi'

export default function ProfilePage() {
  const [profile, setProfile] = useState<StudentProfile | null>(null)
  const [email, setEmail] = useState('')
  const [firstName, setFirstName] = useState('')
  const [username, setUsername] = useState('')
  const [studyYear, setStudyYear] = useState(1)
  const [busy, setBusy] = useState(false)
  const [message, setMessage] = useState<string | null>(null)

  useEffect(() => {
    void Promise.all([getCurrentProfile(), supabase.auth.getUser()]).then(([nextProfile, auth]) => {
      setProfile(nextProfile)
      setFirstName(nextProfile?.first_name ?? '')
      setUsername(nextProfile?.username ?? '')
      setStudyYear(nextProfile?.study_year ?? 1)
      setEmail(auth.data.user?.email ?? '')
    })
  }, [])

  async function save() {
    setBusy(true)
    setMessage(null)
    try {
      const updated = await updateStudyProfile({ firstName, username, studyYear })
      setProfile(updated)
      setUsername(updated.username ?? '')
      setMessage('Profil mis à jour ✓')
    } catch (err) {
      setMessage(err instanceof Error ? err.message : 'Impossible de mettre à jour le profil.')
    } finally {
      setBusy(false)
    }
  }

  if (!profile) return <section className="card"><p>Chargement du profil…</p></section>

  return (
    <div className="stack profile-stack">
      <section className="hero-card profile-hero">
        <div className="hero-copy">
          <span className="hero-kicker">Mon espace</span>
          <h1>{firstName ? `Salut ${firstName} 👋` : 'Mon profil étudiant'}</h1>
          <p>Personnalise Kineo pour garder des révisions adaptées à ton année d’étude.</p>
        </div>
        <div className="hero-orbit" aria-hidden="true"><span>🎓</span></div>
      </section>

      <section className="card">
        <div className="section-heading"><div><p className="eyebrow">Études</p><h2>Profil étudiant</h2></div><span className="profile-chip">K{studyYear}</span></div>
        <div className="auth-form">
          <label>Prénom<input value={firstName} onChange={(event) => setFirstName(event.target.value)} placeholder="Ton prénom" /></label>
          <label>Pseudo public<input value={username} onChange={(event) => setUsername(event.target.value)} placeholder="ex. kineo.stephan" autoCapitalize="none" /></label>
          <small className="field-hint">Ton pseudo permet à tes amis de te retrouver. 3 à 24 caractères, sans espace.</small>
          <label>Année d’étude<select value={studyYear} onChange={(event) => setStudyYear(Number(event.target.value))}><option value={1}>K1 · 1re année</option><option value={2}>K2 · 2e année</option><option value={3}>K3 · 3e année</option><option value={4}>K4 · 4e année</option></select></label>
          <button className="primary-button" onClick={save} disabled={busy}>{busy ? 'Enregistrement…' : 'Enregistrer les modifications'}</button>
          {message && <p className="feedback">{message}</p>}
        </div>
      </section>

      <section className="card social-entry-card">
        <div><p className="eyebrow">Social</p><h2>Mes amis</h2><p>Retrouve tes camarades et prépare les futurs défis entre amis.</p></div>
        <Link className="secondary-button" to="/amis">Ouvrir mes amis</Link>
      </section>

      <section className="card account-card">
        <p className="eyebrow">Compte</p><h2>Connexion</h2>
        <div className="account-row"><div><strong>Adresse e-mail</strong><span>{email || 'Non disponible'}</span></div><span className="status-dot">Actif</span></div>
        <button className="secondary-button" onClick={() => supabase.auth.signOut()}>Se déconnecter</button>
      </section>
    </div>
  )
}
