import { useEffect,useState } from 'react'
import { Link } from 'react-router-dom'
import { getCurrentProgram } from '../curriculum/programs'
import { getAccessiblePrograms,getCurriculumProgress,saveProgramLevel,type AccessibleProgram,type CurriculumProgress } from '../services/programApi'

export default function ProgramHomePage(){
 const program=getCurrentProgram()
 const isSpain=program.id==='kineo-es'
 const isIfsi=program.id==='ifsi-fr'
 const [access,setAccess]=useState<AccessibleProgram|null>(null)
 const [progress,setProgress]=useState<CurriculumProgress|null>(null)
 const [selectedLevel,setSelectedLevel]=useState('')
 const [busy,setBusy]=useState(false)
 const [message,setMessage]=useState<string|null>(null)
 useEffect(()=>{let cancelled=false;Promise.all([getAccessiblePrograms(),getCurriculumProgress(program.id)]).then(([items,nextProgress])=>{if(cancelled)return;const next=items.find(item=>item.program_id===program.id)??null;setAccess(next);setSelectedLevel(next?.level_code??program.levels[0]?.shortLabel??'');setProgress(nextProgress)}).catch(()=>{if(!cancelled){setAccess(null);setProgress(null)}});return()=>{cancelled=true}},[program.id])
 async function chooseLevel(code:string){
  if(code===selectedLevel)return
  const previous=selectedLevel
  setSelectedLevel(code);setBusy(true);setMessage(null)
  try{
   await saveProgramLevel(program.id,code)
   setAccess(current=>current?{...current,level_code:code}:current)
   setProgress(await getCurriculumProgress(program.id))
   setMessage(isSpain?'Nivel actualizado ✓':'Niveau mis à jour ✓')
  }
  catch(error){setSelectedLevel(previous);setMessage(error instanceof Error?error.message:(isSpain?'No se pudo actualizar el nivel.':'Impossible de mettre à jour le niveau.'))}
  finally{setBusy(false)}
 }
 const refLabel=isIfsi?`Référentiel ${access?.curriculum_version==='2026'?'2026':'2009'}`:null
 const coverage=progress?.coverage_percent??0
 const completion=progress?.completion_percent??0
 return <div className="stack program-home-page">
  <section className="hero-card program-home-hero"><div className="hero-copy"><span className="hero-kicker">{program.flag} {isSpain?'Mi espacio de estudio':'Mon espace d’étude'}</span><h1>{isSpain?'¿Qué quieres trabajar hoy ?':'Que veux-tu travailler aujourd’hui ?'}</h1><p>{isSpain?'Accede rápidamente a tu temario, tus retos y tu progreso.':'Accède rapidement à ton cursus, tes défis et ta progression sans repasser par tout le catalogue.'}</p><Link className="primary-button hero-action" to="/parcours">{isSpain?'Abrir el temario':'Ouvrir mon cursus'}</Link></div><div className="hero-orbit"><span>{isSpain?'🎯':'🩺'}</span></div></section>
  <section className="card"><div className="section-heading"><div><p className="eyebrow">{isSpain?'Nivel activo':'Niveau actif'}</p><h2>{selectedLevel||'—'}{refLabel?` · ${refLabel}`:''}</h2></div></div><p>{isSpain?'Puedes cambiar de nivel cuando avances en tus estudios.':'Tu peux changer de semestre ou de niveau au fil de ta formation.'}</p><div className="semester-grid">{program.levels.map(level=><button key={level.id} type="button" className={`semester-card ${selectedLevel===level.shortLabel?'active':''}`} disabled={busy} onClick={()=>void chooseLevel(level.shortLabel)}><span>{String(level.order).padStart(2,'0')}</span><strong>{level.shortLabel}</strong><small>{level.label}</small></button>)}</div>{message&&<p className="feedback">{message}</p>}</section>
  {progress&&<section className="card"><div className="section-heading"><div><p className="eyebrow">{isSpain?'Tu progreso':'Ta progression'}</p><h2>{isSpain?`${coverage}% del nivel trabajado`:`${coverage}% du niveau travaillé`}</h2></div><strong>{selectedLevel||'—'}</strong></div><div className="progress-track" aria-label={isSpain?`Cobertura ${coverage}%`:`Couverture ${coverage}%`}><div className="progress-fill" style={{width:`${Math.min(100,coverage)}%`}}/></div><div className="stats-grid" style={{marginTop:14}}><article className="card score-card"><span>❓ {isSpain?'Preguntas':'Questions'}</span><strong>{progress.questions_answered}/{progress.questions_total}</strong><small>{isSpain?'trabajadas en este nivel':'travaillées sur ce niveau'}</small></article><article className="card score-card"><span>✅ {isSpain?'Temas':'Thèmes'}</span><strong>{progress.topics_completed}/{progress.topics_total}</strong><small>{isSpain?'completados':'terminés'}</small></article><article className="card score-card"><span>↗ {isSpain?'Finalización':'Complétion'}</span><strong>{completion}%</strong><small>{isSpain?'del nivel activo':'du niveau actif'}</small></article></div></section>}
  <section className="quick-grid program-home-actions"><Link className="quick-card" to="/parcours"><span>▦</span><strong>{isSpain?'Temario':'Cursus'}</strong><small>{isSpain?'Materias, fichas y práctica':'UE, fiches et exercices'}</small></Link><Link className="quick-card" to="/rewards"><span>★</span><strong>{isSpain?'Logros':'Badges'}</strong><small>{isSpain?'XP y recompensas':'XP et progression'}</small></Link><Link className="quick-card" to="/amis"><span>⚔️</span><strong>{isSpain?'Amigos':'Amis & défis'}</strong><small>{isSpain?'Retos entre estudiantes':'Défis entre étudiants'}</small></Link><Link className="quick-card" to="/profil"><span>●</span><strong>{isSpain?'Perfil':'Profil'}</strong><small>{isSpain?'Cuenta y preferencias':'Compte et préférences'}</small></Link></section>
 </div>
}
