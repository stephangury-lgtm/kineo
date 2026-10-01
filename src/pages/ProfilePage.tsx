import { useEffect, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { getCurrentProfile, updateStudyProfile } from '../services/profileApi'

export default function ProfilePage() {
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [firstName, setFirstName] = useState('')
  const [studyYear, setStudyYear] = useState(1)
  const [role, setRole] = useState<'student' | 'admin'>('student')
  const [loading, setLoading] = useState(true)
  const [busy, setBusy] = useState(false)
  const [message, setMessage] = useState<string | null>(null)

  useEffect(() => {
    Promise.all([supabase.auth.getUser(), getCurrentProfile()])
      .then(([userResult, profile]) => {
        if (userResult.error) throw userResult.error
        setEmail(userResult.data.user?.email ?? '')
        setFirstName(profile?.first_name ?? '')
        setStudyYear(profile?.study_year ?? 1)
        setRole(profile?.role ?? 'student')
      })
      .catch((err: Error) => setMessage(err.message))
      .finally(() => setLoading(false))
  }, [])

  async function saveProfile() {
    setBusy(true)
    setMessage(null)
    try {
      const updated = await updateStudyProfile({ firstName, studyYear })
      setFirstName(updated.first_name ?? '')
      setStudyYear(updated.study_year ?? studyYear)
      setRole(updated.role)
      setMessage('Profil mis à jour ✓')
    } catch (err) {
      setMessage(err instanceof Error ? err.message : 'Impossible de mettre à jour le profil.')
    } finally {
      setBusy(false)
    }
  }

  async function sendPasswordReset() {
    if (!email) return
    setBusy(true)
    setMessage(null)
    try {
      const { error } = await supabase.auth.resetPasswordForEmail(email, { redirectTo: window.location.origin })
      if (error) throw error
      setMessage('E-mail de changement de mot de passe envoyé.')
    } catch (err) {
      setMessage(err instanceof Error ? err.message : 'Impossible d’envoyer l’e-mail.')
    } finally {
      setBusy(false)
    }
  }

  async function signOut() {
    setBusy(true)
    await supabase.auth.signOut()
    navigate('/')
  }

  if (loading) return <section className="card skeleton-card"><p>Chargement de ton profil…</p></section>

  return (
    <div className="stack">
      <section className="stats-hero">
        <div>
          <p className="eyebrow light">Mon compte</p>
          <h1>{firstName ? `Bonjour ${firstName} 👋` : 'Ton profil Kineo'}</h1>
          <p>Gère ton identité étudiant et l’année utilisée pour personnaliser ton parcours.</p>
        </div>
        <div className="stats-hero-score">
          <span>Parcours</span>
          <strong>K{studyYear}</strong>
        </div>
      </section>

      <section className="stats-grid">
        <article className="card score-card"><span>🎓 Année</span><strong>K{studyYear}</strong><small>parcours prioritaire</small></article>
        <article className="card score-card"><span>📚 Cycle</span><strong>K1–K4</strong><small>4 années accessibles</small></article>
        <article className="card score-card"><span>🧠 Révision</span><strong>SRS</strong><small>adaptée à ta progression</small></article>
        <article className="card score-card"><span>🔥 Objectif</span><strong>Régulier</strong><small>quelques minutes par jour</small></article>
      </section>

      {role === 'admin' && (
        <section className="card challenge-card done">
          <div className="challenge-icon">✓</div>
          <div className="challenge-copy">
            <p className="eyebrow">Administration</p>
            <h2>Revue du contenu pédagogique</h2>
            <p>Relis les leçons, leurs sources et les questions avant publication.</p>
          </div>
          <Link className="secondary-button" to="/admin/review">Ouvrir la revue</Link>
        </section>
      )}

      <section className="card">
        <div className="section-heading">
          <div>
            <p className="eyebrow">Profil étudiant</p>
            <h2>Mes informations</h2>
          </div>
        </div>

        <div className="auth-form" style={{ marginTop: 16 }}>
          <label>
            Prénom
            <input value={firstName} onChange={(event) => setFirstName(event.target.value)} placeholder="Ton prénom" />
          </label>
          <label>
            Adresse e-mail
            <input value={email} readOnly disabled />
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
          <button className="primary-button wide" onClick={saveProfile} disabled={busy}>
            {busy ? 'Enregistrement…' : 'Enregistrer mes modifications'}
          </button>
        </div>
      </section>

      <section className="card">
        <div className="section-heading">
          <div>
            <p className="eyebrow">Sécurité</p>
            <h2>Connexion</h2>
          </div>
        </div>
        <p>Tu peux recevoir un nouveau lien sécurisé pour modifier ton mot de passe.</p>
        <div className="quick-grid">
          <button className="secondary-button" onClick={sendPasswordReset} disabled={busy}>Changer mon mot de passe</button>
          <button className="secondary-button" onClick={signOut} disabled={busy}>Se déconnecter</button>
        </div>
      </section>

      {message && <section className="card centered"><p className="feedback">{message}</p></section>}
    </div>
  )
}
