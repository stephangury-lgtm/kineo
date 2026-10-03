import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { getCurrentProgram,programs,selectProgram,type ProgramId } from '../curriculum/programs'
import { savePrimaryProgram } from '../services/programApi'

export default function ProgramsPage(){
 const navigate=useNavigate()
 const current=getCurrentProgram()
 const [busy,setBusy]=useState<ProgramId|null>(null)
 const [syncWarning,setSyncWarning]=useState(false)
 async function choose(id:ProgramId){
  setBusy(id)
  setSyncWarning(false)
  selectProgram(id)
  try{await savePrimaryProgram(id)}catch{setSyncWarning(true)}
  navigate('/')
  window.location.reload()
 }
 return <div className="stack">
  <section className="hero-card program-hero"><div className="hero-copy"><span className="hero-kicker">Plateforme santé</span><h1>Choisis ton cursus</h1><p>Kineo reste le parcours kiné. La plateforme peut maintenant accueillir plusieurs formations sans mélanger les contenus.</p></div><div className="hero-orbit"><span>🎓</span></div></section>
  {syncWarning&&<section className="card"><p>Le cursus reste enregistré sur cet appareil. La synchronisation du compte sera retentée lors d’une prochaine connexion.</p></section>}
  <section className="program-grid">{programs.map(program=><button key={program.id} className={`program-card ${current.id===program.id?'active':''}`} onClick={()=>void choose(program.id)} disabled={busy!==null}><div className="program-card-top"><span className="program-avatar">{program.flag}</span><span className={`program-status ${program.status}`}>{program.status==='live'?'Disponible':'Socle prêt'}</span></div><h2>{program.name}</h2><p>{program.subtitle}</p><div className="program-steps">{program.levels.map(level=><span key={level.id}>{level.shortLabel}</span>)}</div><strong className="program-cta">{busy===program.id?'Synchronisation…':current.id===program.id?'Cursus actuel':'Choisir ce cursus'} →</strong></button>)}</section>
 </div>
}
