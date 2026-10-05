import { useEffect, useRef, useState } from 'react'
import { Link } from 'react-router-dom'
import { getCurrentProgram, programs, selectProgram, type ProgramId } from '../curriculum/programs'
import { supabase } from '../lib/supabase'
import { getAccessiblePrograms, type AccessibleProgram } from '../services/programApi'
import { getCurrentProfile, removeProfilePhoto, updateStudyProfile, uploadProfilePhoto, type StudentProfile } from '../services/profileApi'
import './ProfilePage.css'

function levelLabel(programId:ProgramId,access:AccessibleProgram|undefined,studyYear:number){
  if(programId==='kineo-fr') return `K${studyYear}`
  return access?.level_code ?? 'Niveau attribué'
}

export default function ProfilePage() {
  const [profile, setProfile] = useState<StudentProfile | null>(null)
  const [accessiblePrograms,setAccessiblePrograms]=useState<AccessibleProgram[]>([])
  const [email, setEmail] = useState('')
  const [firstName, setFirstName] = useState('')
  const [username, setUsername] = useState('')
  const [avatarUrl, setAvatarUrl] = useState<string | null>(null)
  const [studyYear, setStudyYear] = useState(2)
  const [busy, setBusy] = useState(false)
  const [photoBusy, setPhotoBusy] = useState(false)
  const [message, setMessage] = useState<string | null>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)
  const activeProgram=getCurrentProgram()

  useEffect(() => {
    void Promise.all([getCurrentProfile(), supabase.auth.getUser(), getAccessiblePrograms()]).then(([nextProfile, auth, nextPrograms]) => {
      setProfile(nextProfile)
      setAccessiblePrograms(nextPrograms)
      setFirstName(nextProfile?.first_name ?? '')
      setUsername(nextProfile?.username ?? '')
      setAvatarUrl(nextProfile?.avatar_url ?? null)
      setStudyYear(nextProfile?.study_year ?? 2)
      setEmail(auth.data.user?.email ?? '')
    })
  }, [])

  async function save() {
    setBusy(true); setMessage(null)
    try {
      const updated = await updateStudyProfile({ firstName, username, studyYear })
      setProfile(updated); setUsername(updated.username ?? '')
      window.dispatchEvent(new Event('kineo-profile-updated'))
      setMessage(activeProgram.id==='kineo-es'?'Perfil actualizado ✓':'Profil mis à jour ✓')
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

  function switchProgram(programId:ProgramId){
    selectProgram(programId)
    window.location.assign('/')
  }

  if (!profile) return <section className="card"><p>Chargement du profil…</p></section>
  const fallback = (firstName || username || '?').slice(0, 1).toUpperCase()
  const visiblePrograms=profile.role==='admin'
    ? programs
    : programs.filter(program=>accessiblePrograms.some(access=>access.program_id===program.id))
  const activeAccess=accessiblePrograms.find(access=>access.program_id===activeProgram.id)
  const activeLevel=levelLabel(activeProgram.id,activeAccess,studyYear)
  const isFrance=activeProgram.id==='kineo-fr'
  const isSpain=activeProgram.id==='kineo-es'

  return <div className="stack profile-stack">
    <section className="hero-card profile-hero"><div className="hero-copy"><span className="hero-kicker">{isSpain?'Mi espacio':'Mon espace'}</span><h1>{firstName ? `${isSpain?'Hola':'Salut'} ${firstName} 👋` : isSpain?'Mi perfil de estudiante':'Mon profil étudiant'}</h1><p>{isSpain?'Personaliza tu perfil y conserva el nivel asignado a cada plan de estudios.':'Personnalise ton profil et garde un niveau adapté à chaque cursus.'}</p></div><div className="hero-orbit" aria-hidden="true"><span>🎓</span></div></section>
    {profile.role==='admin'&&<section className="card social-entry-card"><div><p className="eyebrow">Administration</p><h2>Qualité pédagogique & retours</h2><p>Contrôle les contenus publiés, la traçabilité des CM, les schémas anatomiques et les signalements de test.</p></div><div className="friend-actions"><Link className="secondary-button" to="/admin">Centre admin</Link><Link className="secondary-button" to="/admin/visuels">Valider les visuels</Link></div></section>}
    {visiblePrograms.length>1&&<section className="card social-entry-card"><div><p className="eyebrow">{isSpain?'Mis estudios':'Mes cursus'}</p><h2>{isSpain?'Cambiar de plan de estudios':'Changer de base pédagogique'}</h2><p>{isSpain?'Solo puedes utilizar los planes asignados a tu cuenta.':'Tu peux utiliser uniquement les cursus attribués à ton compte.'} {isSpain?'Plan activo':'Base active'} : <strong>{activeProgram.name}</strong>.</p></div><div className="friend-actions">{visiblePrograms.map(program=><button key={program.id} className={program.id===activeProgram.id?'primary-button':'secondary-button'} onClick={()=>switchProgram(program.id)} disabled={program.id===activeProgram.id}>{program.flag} {program.name}{program.id===activeProgram.id?(isSpain?' · activo':' · active'):''}</button>)}</div></section>}
    <section className="card profile-photo-card"><div className="profile-photo-wrap"><div className="profile-photo-large">{avatarUrl ? <img src={avatarUrl} alt="Ma photo de profil" /> : <span>{fallback}</span>}</div><div><p className="eyebrow">Photo de profil</p><h2>Personnalise ton avatar</h2><p>Ta photo apparaît aussi dans les défis et en haut à droite de Kineo.</p></div></div><input ref={fileInputRef} className="visually-hidden" type="file" accept="image/*,.heic,.heif" onChange={(event) => void changePhoto(event.target.files?.[0])} /><div className="friend-actions"><button className="secondary-button" onClick={() => fileInputRef.current?.click()} disabled={photoBusy}>{photoBusy ? 'Traitement…' : avatarUrl ? 'Changer ma photo' : 'Ajouter ma photo'}</button>{avatarUrl&&<button className="text-link" onClick={()=>void removePhoto()} disabled={photoBusy}>Supprimer</button>}</div>{photoBusy&&<p className="field-hint">La photo peut être redimensionnée automatiquement avant l’envoi.</p>}</section>
    <section className="card"><div className="section-heading"><div><p className="eyebrow">{isSpain?'Estudios':'Études'}</p><h2>{isSpain?'Perfil de estudiante':'Profil étudiant'}</h2></div><span className="profile-chip">{activeLevel}</span></div><div className="auth-form"><label>{isSpain?'Nombre':'Prénom'}<input value={firstName} onChange={(event) => setFirstName(event.target.value)} placeholder={isSpain?'Tu nombre':'Ton prénom'} /></label><label>{isSpain?'Alias público':'Pseudo public'}<input value={username} onChange={(event) => setUsername(event.target.value)} placeholder="ex. kineo.stephan" autoCapitalize="none" /></label><small className="field-hint">{isSpain?'Tu alias permite que tus amigos te encuentren. 3 a 24 caracteres, sin espacios.':'Ton pseudo permet à tes amis de te retrouver. 3 à 24 caractères, sans espace.'}</small>{isFrance?<label>Année d’étude<select value={studyYear} onChange={(event) => setStudyYear(Number(event.target.value))}><option value={2}>K2 · 1re année IFMK</option><option value={3}>K3 · 2e année IFMK</option><option value={4}>K4 · 3e année IFMK</option><option value={5}>K5 · 4e année IFMK</option></select></label>:<div className="account-row"><div><strong>{isSpain?'Nivel asignado':'Niveau attribué'}</strong><span>{activeLevel} · {activeProgram.name}</span></div><span className="status-dot">{isSpain?'Activo':'Actif'}</span></div>}<button className="primary-button" onClick={save} disabled={busy}>{busy ? (isSpain?'Guardando…':'Enregistrement…') : (isSpain?'Guardar cambios':'Enregistrer les modifications')}</button>{message&&<p className="feedback">{message}</p>}</div></section>
    <section className="card revision-summary"><div className="revision-summary-heading"><div><p className="eyebrow">{isSpain?'Repaso':'Révisions'}</p><h2>{isSpain?'Parámetros de aprendizaje':'Paramètres d’apprentissage'}</h2></div><span className="revision-summary-year">{activeLevel}</span></div><div className="revision-summary-grid"><div className="revision-summary-item"><span>{isSpain?'Nivel activo':'Niveau actif'}</span><strong>{activeLevel}</strong></div><div className="revision-summary-item"><span>{isSpain?'Planes disponibles':'Parcours accessible'}</span><strong>{visiblePrograms.map(program=>program.shortName).join(' · ')}</strong></div><div className="revision-summary-item"><span>{isSpain?'Método':'Méthode'}</span><strong>SRS espacé</strong></div><div className="revision-summary-item"><span>{isSpain?'Ritmo':'Rythme'}</span><strong>{isSpain?'Regular':'Régulier'}</strong></div></div></section>
    <section className="card social-entry-card"><div><p className="eyebrow">Social</p><h2>{isSpain?'Amigos, retos y clasificación':'Amis, défis & classement'}</h2><p>{isSpain?'Encuentra a tus compañeros, lanza duelos de 10 preguntas y compara el XP semanal.':'Retrouve tes camarades, lance des duels de 10 questions et compare votre XP de la semaine.'}</p></div><div className="friend-actions"><Link className="secondary-button" to="/amis">{isSpain?'Mis amigos':'Mes amis'}</Link><Link className="secondary-button" to="/classement">{isSpain?'Clasificación':'Classement'}</Link></div></section>
    <section className="card account-card"><p className="eyebrow">{isSpain?'Cuenta':'Compte'}</p><h2>{isSpain?'Conexión':'Connexion'}</h2><div className="account-row"><div><strong>{isSpain?'Correo electrónico':'Adresse e-mail'}</strong><span>{email || (isSpain?'No disponible':'Non disponible')}</span></div><span className="status-dot">{isSpain?'Activo':'Actif'}</span></div><button className="secondary-button" onClick={() => supabase.auth.signOut()}>{isSpain?'Cerrar sesión':'Se déconnecter'}</button></section>
  </div>
}
