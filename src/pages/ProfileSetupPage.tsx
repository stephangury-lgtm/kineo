import { useMemo,useState } from 'react'
import { programs,selectProgram,type ProgramId } from '../curriculum/programs'
import type { PrimaryProgram } from '../services/programApi'
import { setupStudentProfile, type StudentProfile } from '../services/profileApi'

type Props = {
  current: StudentProfile
  onSaved: (profile: StudentProfile) => void
  existingProgram?: PrimaryProgram | null
}

export default function ProfileSetupPage({ current, onSaved, existingProgram }: Props) {
  const [firstName, setFirstName] = useState(current.first_name ?? '')
  const [username, setUsername] = useState(current.username ?? '')
  const [programId,setProgramId]=useState<ProgramId>(existingProgram?.program_id ?? 'kineo-fr')
  const program=useMemo(()=>programs.find(item=>item.id===programId)??programs[0],[programId])
  const [levelCode,setLevelCode]=useState(existingProgram?.level_code ?? program.levels[0]?.shortLabel??'')
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState<string | null>(null)

  function chooseProgram(id:ProgramId){
    const next=programs.find(item=>item.id===id)??programs[0]
    setProgramId(id)
    setLevelCode(next.levels[0]?.shortLabel??'')
  }

  async function save() {
    if (busy) return
    setBusy(true)
    setError(null)
    try {
      const selectedLevel=program.levels.find(level=>level.shortLabel===levelCode)??program.levels[0]
      if(!selectedLevel) throw new Error('Choisis un niveau d’étude.')
      const saved = await setupStudentProfile({programId:program.id,levelCode:selectedLevel.shortLabel,firstName,username})
      selectProgram(program.id)
      localStorage.setItem(`healthapp_level_${program.id}`,selectedLevel.shortLabel)
      onSaved(saved)
      window.location.reload()
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
          <p className="eyebrow">Bienvenue</p>
          <h1>Choisis ton parcours étudiant</h1>
          <p>Ce choix définit ton espace de cours, de révision, de progression et de défis. Une fois le compte configuré, le cursus ne pourra plus être changé depuis l’application.</p>
        </div>
        <div className="auth-form">
          <label>Prénom (facultatif)<input value={firstName} onChange={(event) => setFirstName(event.target.value)} placeholder="Ton prénom" /></label>
          <label>Pseudo (facultatif)<input value={username} onChange={(event) => setUsername(event.target.value)} placeholder="ex. kineo.marie" autoCapitalize="none" autoCorrect="off" /></label>
          <small className="field-hint">Le pseudo permet d’utiliser les amis, défis et classements.</small>
          <fieldset className="program-choice"><legend>Cursus</legend><div className="program-grid">{programs.map(item=><button type="button" key={item.id} className={`program-card ${programId===item.id?'active':''}`} onClick={()=>chooseProgram(item.id)} disabled={busy || Boolean(existingProgram)}><span className="program-avatar">{item.flag}</span><strong>{item.name}</strong><small>{item.subtitle}</small></button>)}</div></fieldset>
          <label>{program.levelKind==='semester'?'Semestre':'Année d’étude'}<select value={levelCode} onChange={(event)=>setLevelCode(event.target.value)} disabled={busy || Boolean(existingProgram?.academic_level_id)}>{program.levels.map(level=><option key={level.id} value={level.shortLabel}>{level.shortLabel} · {level.label}</option>)}</select></label>
          <button className="primary-button" onClick={save} disabled={busy}>{busy ? 'Création du parcours…' : 'Créer mon espace étudiant'}</button>
          {error && <p className="feedback">{error}</p>}
        </div>
      </section>
    </main>
  )
}
