import { useEffect, useRef, useState } from 'react'
import { Link } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { getCurrentProfile, removeProfilePhoto, updateStudyProfile, uploadProfilePhoto, type StudentProfile } from '../services/profileApi'
import './ProfilePage.css'

export default function ProfilePage() {
  const [profile, setProfile] = useState<StudentProfile | null>(null)
  const [email, setEmail] = useState('')
  const [firstName, setFirstName] = useState('')
  const [username, setUsername] = useState('')
  const [avatarUrl, setAvatarUrl] = useState<string | null>(null)
  const [studyYear, setStudyYear] = useState(1)
  const [busy, setBusy] = useState(false)
  const [photoBusy, setPhotoBusy] = useState(false)
  const [message, setMessage] = useState<string | null>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    void Promise.all([getCurrentProfile(), supabase.auth.getUser()]).then(([nextProfile, auth]) => {
      setProfile(nextProfile)
      setFirstName(nextProfile?.first_name ?? '')
      setUsername(nextProfile?.username ?? '')
      setAvatarUrl(nextProfile?.avatar_url ?? null)
      setStudyYear(nextProfile?.study_year ?? 1)
      setEmail(auth.data.user?.email ?? '')
    })
  }, [])

  async function save() {
    setBusy(true); setMessage(null)
    try {
      const updated = await updateStudyProfile({ firstName, username, studyYear })
      setProfile(updated); setUsername(updated.username ?? '')
      window.dispatchEvent(new Event('kineo-profile-updated'))
      setMessage('Profil mis à jour ✓')
    } catch (err) { setMessage(err instanceof Error ? err.message : 'Impossible de mettre à jour le profil.') }
    finally { setBusy(false) }
  }

  async function changePhoto(file?: File) {
    if (!file) return
    setPhotoBusy(true); setMessage('Préparation de la photo…')
    try {
      const nextUrl = await uploadProfilePhoto(file)
      setAvatarUrl(nextUrl)
      const refreshed = await getCurrentProfile()
      if (refreshed) setProfile(refreshed)
      setMessage('Photo de profil enregistrée ✓')
    } catch (err) { setMessage(err instanceof Error ? err.message : 'Impossible d’envoyer la photo.') }
    finally { setPhotoBusy(false); if (fileInputRef.current) fileInputRef.current.value = '' }
  }

  async function removePhoto() {
    setPhotoBusy(true); setMessage(null)
    try {
      await removeProfilePhoto(avatarUrl)
      setAvatarUrl(null)
      setProfile(current => current ? { ...current, avatar_url: null } : current)
      setMessage('Photo de profil supprimée ✓')
    } catch (err) { setMessage(err instanceof Error ? err.message : 'Impossible de supprimer la photo.') }
    finally { setPhotoBusy(false) }
  }

  if (!profile) return <section className="card"><p>Chargement du profil…</p></section>
  const fallback = (firstName || username || '?').slice(0, 1).toUpperCase()

  return <div className="stack profile-stack">
    <section className="hero-card profile-hero"><div className="hero-copy"><span className="hero-kicker">Mon espace</span><h1>{firstName ? `Salut ${firstName} 👋` : 'Mon profil étudiant'}</h1><p>Personnalise Kineo pour garder des révisions adaptées à ton année d’étude.</p></div><div className="hero-orbit" aria-hidden="true"><span>🎓</span></div></section>
    {profile.role==='admin'&&<section className="card social-entry-card"><div><p className="eyebrow">Administration</p><h2>Qualité pédagogique & retours</h2><p>Contrôle les contenus publiés, la traçabilité des CM, les schémas anatomiques et les signalements de test.</p></div><div className="friend-actions"><Link className="secondary-button" to="/admin">Centre admin</Link><Link className="secondary-button" to="/admin/visuels">Valider les visuels</Link></div></section>}
    <section className="card profile-photo-card"><div className="profile-photo-wrap"><div className="profile-photo-large">{avatarUrl ? <img src={avatarUrl} alt="Ma photo de profil" /> : <span>{fallback}</span>}</div><div><p className="eyebrow">Photo de profil</p><h2>Personnalise ton avatar</h2><p>Ta photo apparaît aussi dans les défis et en haut à droite de Kineo.</p></div></div><input ref={fileInputRef} className="visually-hidden" type="file" accept="image/*,.heic,.heif" onChange={(event) => void changePhoto(event.target.files?.[0])} /><div className="friend-actions"><button className="secondary-button" onClick={() => fileInputRef.current?.click()} disabled={photoBusy}>{photoBusy ? 'Traitement…' : avatarUrl ? 'Changer ma photo' : 'Ajouter ma photo'}</button>{avatarUrl&&<button className="text-link" onClick={()=>void removePhoto()} disabled={photoBusy}>Supprimer</button>}</div>{photoBusy&&<p className="field-hint">La photo peut être redimensionnée automatiquement avant l’envoi.</p>}</section>
    <section className="card"><div className="section-heading"><div><p className="eyebrow">Études</p><h2>Profil étudiant</h2></div><span className="profile-chip">K{studyYear}</span></div><div className="auth-form"><label>Prénom<input value={firstName} onChange={(event) => setFirstName(event.target.value)} placeholder="Ton prénom" /></label><label>Pseudo public<input value={username} onChange={(event) => setUsername(event.target.value)} placeholder="ex. kineo.stephan" autoCapitalize="none" /></label><small className="field-hint">Ton pseudo permet à tes amis de te retrouver. 3 à 24 caractères, sans espace.</small><label>Année d’étude<select value={studyYear} onChange={(event) => setStudyYear(Number(event.target.value))}><option value={1}>K1 · 1re année</option><option value={2}>K2 · 2e année</option><option value={3}>K3 · 3e année</option><option value={4}>K4 · 4e année</option></select></label><button className="primary-button" onClick={save} disabled={busy}>{busy ? 'Enregistrement…' : 'Enregistrer les modifications'}</button>{message&&<p className="feedback">{message}</p>}</div></section>
    <section className="card revision-summary"><div className="revision-summary-heading"><div><p className="eyebrow">Révisions</p><h2>Paramètres d’apprentissage</h2></div><span className="revision-summary-year">K{studyYear}</span></div><div className="revision-summary-grid"><div className="revision-summary-item"><span>Année active</span><strong>K{studyYear}</strong></div><div className="revision-summary-item"><span>Parcours accessible</span><strong>K1 → K4</strong></div><div className="revision-summary-item"><span>Méthode</span><strong>SRS espacé</strong></div><div className="revision-summary-item"><span>Rythme</span><strong>Régulier</strong></div></div></section>
    <section className="card social-entry-card"><div><p className="eyebrow">Social</p><h2>Amis, défis & classement</h2><p>Retrouve tes camarades, lance des duels de 10 questions et compare votre XP de la semaine.</p></div><div className="friend-actions"><Link className="secondary-button" to="/amis">Mes amis</Link><Link className="secondary-button" to="/classement">Classement</Link></div></section>
    <section className="card account-card"><p className="eyebrow">Compte</p><h2>Connexion</h2><div className="account-row"><div><strong>Adresse e-mail</strong><span>{email || 'Non disponible'}</span></div><span className="status-dot">Actif</span></div><button className="secondary-button" onClick={() => supabase.auth.signOut()}>Se déconnecter</button></section>
  </div>
}
