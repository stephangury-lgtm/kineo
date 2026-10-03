import { useEffect,useState } from 'react'
import { Link } from 'react-router-dom'
import { getCurrentProgram } from '../curriculum/programs'
import { getAcademicLevelId,getProgramUnits,getUnitTopics,type ProgramCatalogUnit,type ProgramCatalogTopic } from '../services/programCatalogApi'
import { saveProgramLevel } from '../services/programApi'

export default function ProgramLandingPage(){
 const p=getCurrentProgram()
 const isSpain=p.id==='kineo-es'
 const storageKey=`healthapp_level_${p.id}`
 const [selectedLevel,setSelectedLevel]=useState(()=>localStorage.getItem(storageKey)??p.levels[0]?.shortLabel??'')
 const [syncing,setSyncing]=useState(false)
 const [units,setUnits]=useState<ProgramCatalogUnit[]>([])
 const [loadingUnits,setLoadingUnits]=useState(false)
 const [catalogError,setCatalogError]=useState<string|null>(null)
 const [openUnitId,setOpenUnitId]=useState<string|null>(null)
 const [topicsByUnit,setTopicsByUnit]=useState<Record<string,ProgramCatalogTopic[]>>({})
 const [loadingTopics,setLoadingTopics]=useState<string|null>(null)

 useEffect(()=>{
  if(!selectedLevel)return
  let cancelled=false
  setLoadingUnits(true);setCatalogError(null);setOpenUnitId(null);setTopicsByUnit({})
  getAcademicLevelId(p.id,selectedLevel).then(levelId=>getProgramUnits(p.id,levelId)).then(data=>{if(!cancelled)setUnits(data)}).catch(()=>{if(!cancelled){setUnits([]);setCatalogError('Le catalogue de ce niveau est en préparation.')}}).finally(()=>{if(!cancelled)setLoadingUnits(false)})
  return()=>{cancelled=true}
 },[p.id,selectedLevel])

 async function chooseLevel(code:string){
  setSelectedLevel(code)
  localStorage.setItem(storageKey,code)
  setSyncing(true)
  try{await saveProgramLevel(p.id,code)}catch{/* local preference remains available */}finally{setSyncing(false)}
 }

 async function toggleUnit(unitId:string){
  if(openUnitId===unitId){setOpenUnitId(null);return}
  setOpenUnitId(unitId)
  if(topicsByUnit[unitId])return
  setLoadingTopics(unitId)
  try{const topics=await getUnitTopics(unitId);setTopicsByUnit(current=>({...current,[unitId]:topics}))}catch{setTopicsByUnit(current=>({...current,[unitId]:[]}))}finally{setLoadingTopics(null)}
 }

 return <div className="stack">
  <section className="hero-card"><div className="hero-copy"><span className="hero-kicker">{p.flag} {p.country}</span><h1>{p.name}</h1><p>{isSpain?'Un parcours kiné pensé pour réviser la matière et maîtriser progressivement le vocabulaire médical espagnol.':'Un parcours IFSI organisé sur 3 ans et 6 semestres, avec des fiches de révision et des quiz accessibles chapitre par chapitre.'}</p><Link className="primary-button hero-action" to="/programmes">Changer de cursus</Link></div><div className="hero-orbit"><span>{isSpain?'🇪🇸':'🩺'}</span></div></section>
  <section className="card"><div className="section-heading"><div><p className="eyebrow">Structure du parcours</p><h2>{isSpain?'4 années de Fisioterapia':'6 semestres IFSI'}</h2></div><span className="program-status foundation">Socle prêt</span></div><p>Choisis ton niveau pour préparer ton espace de révision.</p><div className="semester-grid">{p.levels.map(level=><button type="button" className={`semester-card ${selectedLevel===level.shortLabel?'active':''}`} key={level.id} onClick={()=>void chooseLevel(level.shortLabel)} disabled={syncing}><span>{String(level.order).padStart(2,'0')}</span><strong>{level.shortLabel}</strong><small>{level.label} · {isSpain?'Cours · fiches · quiz FR/ES':'UE · fiches · quiz · cas cliniques'}</small></button>)}</div></section>
  <section className="card"><div className="section-heading"><div><p className="eyebrow">{isSpain?'Matières':'Unités d’enseignement'}</p><h2>{selectedLevel}</h2></div><span className="program-status foundation">{loadingUnits?'Chargement…':`${units.length} configurée${units.length>1?'s':''}`}</span></div>{catalogError&&<p>{catalogError}</p>}{!loadingUnits&&units.length===0&&!catalogError?<div className="admin-empty"><span>📚</span><div><strong>Structure prête, contenu à intégrer.</strong><p>{isSpain?'Les matières seront ajoutées à partir des documents validés du cursus espagnol, avec leurs variantes FR/ES.':'Les UE seront ajoutées à partir du référentiel et des supports validés, sans contenu inventé.'}</p></div></div>:<div className="subject-list">{units.map(unit=>{const isOpen=openUnitId===unit.id;const topics=topicsByUnit[unit.id]??[];return <article className={`subject-row curriculum-unit ${isOpen?'open':''}`} key={unit.id}><button type="button" className="curriculum-unit-toggle" onClick={()=>void toggleUnit(unit.id)}><div><strong>{unit.icon?`${unit.icon} `:''}{unit.code?`UE ${unit.code} · `:''}{unit.name}</strong><span>{unit.description??(unit.translation_mode==='bilingual'?'Mode bilingue FR/ES':unit.unit_type.toUpperCase())}</span></div><span>{isOpen?'−':'+'}</span></button>{isOpen&&<div className="curriculum-topic-list">{loadingTopics===unit.id?<p>Chargement des chapitres…</p>:topics.length===0?<p className="curriculum-empty">Aucun chapitre importé pour cette UE.</p>:topics.map(topic=><article className="curriculum-topic" key={topic.id}><span>{String(topic.display_order).padStart(2,'0')}</span><div className="curriculum-topic-copy"><strong>{topic.name}</strong>{topic.description&&<small>{topic.description}</small>}<div className="curriculum-topic-actions"><Link className="secondary-button compact-button" to={`/cours/${topic.id}#fiche`}>📖 Lire la fiche</Link><Link className="primary-button compact-button" to={`/cours/${topic.id}#qcm`}>✅ Faire le QCM</Link></div></div></article>)}</div>}</article>})}</div>}</section>
  {isSpain?<section className="card"><p className="eyebrow">Mode bilingue</p><h2>Apprendre la kiné et l'espagnol ensemble</h2><div className="feature-grid"><article><span>↔️</span><strong>FR → ES / ES → FR</strong><small>Traductions anatomiques et cliniques.</small></article><article><span>🦴</span><strong>Anatomie visuelle</strong><small>Identifier une structure et la nommer en espagnol.</small></article><article><span>💬</span><strong>Situation patient</strong><small>Comprendre consignes, douleurs et vocabulaire de consultation.</small></article></div></section>:<section className="card"><p className="eyebrow">Moteur pédagogique</p><h2>Le socle Kineo réutilisé pour l'IFSI</h2><div className="feature-grid"><article><span>📖</span><strong>Fiches de révision</strong><small>Lecture ciblée chapitre par chapitre.</small></article><article><span>✅</span><strong>QCM & situations</strong><small>Révision active par UE et semestre.</small></article><article><span>🔥</span><strong>Progression</strong><small>XP, séries, challenges et points faibles.</small></article></div></section>}
 </div>
}
