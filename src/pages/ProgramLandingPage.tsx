import { useState } from 'react'
import { Link } from 'react-router-dom'
import { getCurrentProgram } from '../curriculum/programs'
import { saveProgramLevel } from '../services/programApi'

export default function ProgramLandingPage(){
 const p=getCurrentProgram()
 const isSpain=p.id==='kineo-es'
 const storageKey=`healthapp_level_${p.id}`
 const [selectedLevel,setSelectedLevel]=useState(()=>localStorage.getItem(storageKey)??p.levels[0]?.shortLabel??'')
 const [syncing,setSyncing]=useState(false)
 async function chooseLevel(code:string){
  setSelectedLevel(code)
  localStorage.setItem(storageKey,code)
  setSyncing(true)
  try{await saveProgramLevel(p.id,code)}catch{/* local preference remains available */}finally{setSyncing(false)}
 }
 return <div className="stack">
  <section className="hero-card"><div className="hero-copy"><span className="hero-kicker">{p.flag} {p.country}</span><h1>{p.name}</h1><p>{isSpain?'Un parcours kiné pensé pour réviser la matière et maîtriser progressivement le vocabulaire médical espagnol.':'Un parcours IFSI organisé sur 3 ans et 6 semestres, avec le même moteur de révision ludique que Kineo.'}</p><Link className="primary-button hero-action" to="/programmes">Changer de cursus</Link></div><div className="hero-orbit"><span>{isSpain?'🇪🇸':'🩺'}</span></div></section>
  <section className="card"><div className="section-heading"><div><p className="eyebrow">Structure du parcours</p><h2>{isSpain?'4 années de Fisioterapia':'6 semestres IFSI'}</h2></div><span className="program-status foundation">Socle prêt</span></div><p>Choisis ton niveau pour préparer ton espace de révision.</p><div className="semester-grid">{p.levels.map(level=><button type="button" className={`semester-card ${selectedLevel===level.shortLabel?'active':''}`} key={level.id} onClick={()=>void chooseLevel(level.shortLabel)} disabled={syncing}><span>{String(level.order).padStart(2,'0')}</span><strong>{level.shortLabel}</strong><small>{level.label} · {isSpain?'Cours · fiches · quiz FR/ES':'UE · fiches · quiz · cas cliniques'}</small></button>)}</div></section>
  {isSpain?<section className="card"><p className="eyebrow">Mode bilingue</p><h2>Apprendre la kiné et l'espagnol ensemble</h2><div className="feature-grid"><article><span>↔️</span><strong>FR → ES / ES → FR</strong><small>Traductions anatomiques et cliniques.</small></article><article><span>🦴</span><strong>Anatomie visuelle</strong><small>Identifier une structure et la nommer en espagnol.</small></article><article><span>💬</span><strong>Situation patient</strong><small>Comprendre consignes, douleurs et vocabulaire de consultation.</small></article></div></section>:<section className="card"><p className="eyebrow">Moteur pédagogique</p><h2>Le socle Kineo réutilisé pour l'IFSI</h2><div className="feature-grid"><article><span>✅</span><strong>QCM & QCU</strong><small>Révision par UE et semestre.</small></article><article><span>🧩</span><strong>Cas cliniques</strong><small>Mises en situation et raisonnement.</small></article><article><span>🔥</span><strong>Progression</strong><small>XP, séries, challenges et points faibles.</small></article></div></section>}
 </div>
}
