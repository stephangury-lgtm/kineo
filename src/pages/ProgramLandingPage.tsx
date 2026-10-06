import { useEffect,useState } from 'react'
import { Link } from 'react-router-dom'
import { getCurrentProgram } from '../curriculum/programs'
import { getAcademicLevelId,getProgramUnits,getUnitTopics,type ProgramCatalogUnit,type ProgramCatalogTopic } from '../services/programCatalogApi'
import { getAccessiblePrograms,saveProgramCurriculumVersion,saveProgramLevel,type AccessibleProgram,type CurriculumVersion } from '../services/programApi'

export default function ProgramLandingPage(){
 const p=getCurrentProgram()
 const isSpain=p.id==='kineo-es'
 const isIfsi=p.id==='ifsi-fr'
 const storageKey=`healthapp_level_${p.id}`
 const referenceStorageKey=`healthapp_curriculum_${p.id}`
 const [selectedLevel,setSelectedLevel]=useState(()=>localStorage.getItem(storageKey)??p.levels[0]?.shortLabel??'')
 const [curriculumVersion,setCurriculumVersion]=useState<CurriculumVersion>(()=>isIfsi?(localStorage.getItem(referenceStorageKey) as CurriculumVersion|null)??'2009':'default')
 const [assignedAccess,setAssignedAccess]=useState<AccessibleProgram|null>(null)
 const [syncing,setSyncing]=useState(false)
 const [syncError,setSyncError]=useState<string|null>(null)
 const [units,setUnits]=useState<ProgramCatalogUnit[]>([])
 const [loadingUnits,setLoadingUnits]=useState(false)
 const [catalogError,setCatalogError]=useState<string|null>(null)
 const [openUnitId,setOpenUnitId]=useState<string|null>(null)
 const [topicsByUnit,setTopicsByUnit]=useState<Record<string,ProgramCatalogTopic[]>>({})
 const [loadingTopics,setLoadingTopics]=useState<string|null>(null)

 useEffect(()=>{
  let cancelled=false
  getAccessiblePrograms().then(accesses=>{
   if(cancelled)return
   const access=accesses.find(item=>item.program_id===p.id)??null
   setAssignedAccess(access)
   if(access?.level_code){
    setSelectedLevel(access.level_code)
    localStorage.setItem(storageKey,access.level_code)
   }
   if(access&&isIfsi){
    const version=access.curriculum_version==='2026'?'2026':'2009'
    setCurriculumVersion(version)
    localStorage.setItem(referenceStorageKey,version)
   }
  }).catch(()=>{if(!cancelled)setAssignedAccess(null)})
  return()=>{cancelled=true}
 },[p.id,storageKey,referenceStorageKey,isIfsi])

 useEffect(()=>{
  if(!selectedLevel)return
  let cancelled=false
  setLoadingUnits(true);setCatalogError(null);setOpenUnitId(null);setTopicsByUnit({})
  getAcademicLevelId(p.id,selectedLevel).then(levelId=>getProgramUnits(p.id,levelId,curriculumVersion)).then(data=>{if(!cancelled)setUnits(data)}).catch(()=>{if(!cancelled){setUnits([]);setCatalogError(isSpain?'El contenido de este nivel está en preparación.':'Le catalogue de ce niveau est en préparation.')}}).finally(()=>{if(!cancelled)setLoadingUnits(false)})
  return()=>{cancelled=true}
 },[p.id,selectedLevel,isSpain,curriculumVersion])

 async function chooseLevel(code:string){
  if(code===selectedLevel||syncing)return
  setSyncing(true);setSyncError(null)
  try{
   await saveProgramLevel(p.id,code)
   setSelectedLevel(code)
   localStorage.setItem(storageKey,code)
   setAssignedAccess(current=>current?{...current,level_code:code}:current)
  }catch(error){
   setSyncError(error instanceof Error?error.message:(isSpain?'No se pudo actualizar el nivel.':'Impossible de mettre à jour le niveau.'))
  }finally{setSyncing(false)}
 }

 async function chooseReference(version:'2009'|'2026'){
  if(!isIfsi||version===curriculumVersion||syncing)return
  setSyncing(true);setSyncError(null)
  try{
   await saveProgramCurriculumVersion(p.id,version)
   setCurriculumVersion(version)
   localStorage.setItem(referenceStorageKey,version)
   setAssignedAccess(current=>current?{...current,curriculum_version:version}:current)
  }catch(error){
   setSyncError(error instanceof Error?error.message:'Impossible de mettre à jour le référentiel.')
  }finally{setSyncing(false)}
 }

 async function toggleUnit(unitId:string){
  if(openUnitId===unitId){setOpenUnitId(null);return}
  setOpenUnitId(unitId)
  if(topicsByUnit[unitId])return
  setLoadingTopics(unitId)
  try{const topics=await getUnitTopics(unitId);setTopicsByUnit(current=>({...current,[unitId]:topics}))}catch{setTopicsByUnit(current=>({...current,[unitId]:[]}))}finally{setLoadingTopics(null)}
 }

 return <div className="stack">
  <section className="hero-card"><div className="hero-copy"><span className="hero-kicker">{p.flag} {p.country}</span><h1>{p.name}</h1><p>{isSpain?'Un recorrido de Fisioterapia para aprender la materia y dominar progresivamente el vocabulario clínico en español, con apoyo FR ↔ ES.':isIfsi?'Un parcours IFSI organisé sur 3 ans et 6 semestres, avec séparation stricte entre les référentiels 2009 et 2026.':'Un parcours organisé avec des fiches de révision et des exercices accessibles chapitre par chapitre.'}</p><span className="program-status live">{isSpain?'Plan asignado a la cuenta':isIfsi?`Référentiel ${curriculumVersion}`:'Cursus du compte'}</span></div><div className="hero-orbit"><span>{isSpain?'🇪🇸':'🩺'}</span></div></section>
  {isIfsi&&<section className="card ifsi-reference-card"><div className="section-heading"><div><p className="eyebrow">Référentiel national</p><h2>Quand es-tu entré en IFSI ?</h2></div><span className="program-status foundation">Réf. {curriculumVersion}</span></div><p>Choisis simplement ta période d’entrée en formation. Kineo sélectionnera automatiquement le bon référentiel et n’affichera que les UE, fiches et quiz correspondants.</p><div className="ifsi-reference-grid"><button type="button" className={`semester-card ${curriculumVersion==='2009'?'active':''}`} onClick={()=>void chooseReference('2009')} disabled={syncing}><strong>Je suis entré avant septembre 2026</strong><small>Référentiel 2009 · UE historiques 1.x à 6.x.</small></button><button type="button" className={`semester-card ${curriculumVersion==='2026'?'active':''}`} onClick={()=>void chooseReference('2026')} disabled={syncing}><strong>Je suis entré à partir de septembre 2026</strong><small>Référentiel 2026 · nouveaux domaines de compétences et nouvelles UE.</small></button></div>{syncError&&<p className="form-error">{syncError}</p>}</section>}
  <section className="card"><div className="section-heading"><div><p className="eyebrow">{isSpain?'Estructura del grado':'Structure du parcours'}</p><h2>{isSpain?'4 años de Fisioterapia':'6 semestres IFSI'}</h2></div></div><p>{isSpain?'Selecciona tu nivel de trabajo. El contenido se organiza por materias y capítulos con práctica activa.':'Choisis ton semestre actif. Tu peux le mettre à jour au fil de ta formation.'}</p><div className="semester-grid">{p.levels.map(level=><button type="button" className={`semester-card ${selectedLevel===level.shortLabel?'active':''}`} key={level.id} onClick={()=>void chooseLevel(level.shortLabel)} disabled={syncing}><span>{String(level.order).padStart(2,'0')}</span><strong>{level.shortLabel}</strong><small>{level.label} · {isSpain?'Fichas · práctica FR/ES · casos · visuales':'UE · fiches · quiz · cas cliniques'}</small></button>)}</div>{!isIfsi&&syncError&&<p className="form-error">{syncError}</p>}</section>
  <section className="card"><div className="section-heading"><div><p className="eyebrow">{isSpain?'Materias':'Unités d’enseignement'}</p><h2>{selectedLevel}{isIfsi?` · Réf. ${curriculumVersion}`:''}</h2></div><span className="program-status foundation">{loadingUnits?(isSpain?'Cargando…':'Chargement…'):`${units.length} ${isSpain?'configurada'+(units.length!==1?'s':''):'configurée'+(units.length>1?'s':'')}`}</span></div>{catalogError&&<p>{catalogError}</p>}{!loadingUnits&&units.length===0&&!catalogError?<div className="admin-empty"><span>📚</span><div><strong>{isSpain?'Contenido pedagógico en preparación.':isIfsi&&curriculumVersion==='2026'?'Référentiel 2026 en cours d’intégration.':'Contenu pédagogique à intégrer.'}</strong><p>{isSpain?'Las materias se integran únicamente a partir de fuentes y documentos validados, sin inventar contenido.':isIfsi&&curriculumVersion==='2026'?'Les nouvelles UE seront ajoutées semestre par semestre exclusivement à partir de l’arrêté du 20 février 2026 et de supports validés.':'Les UE seront ajoutées à partir du référentiel et des supports validés, sans contenu inventé.'}</p></div></div>:<div className="subject-list">{units.map(unit=>{const isOpen=openUnitId===unit.id;const topics=topicsByUnit[unit.id]??[];return <article className={`subject-row curriculum-unit ${isOpen?'open':''}`} key={unit.id}><button type="button" className="curriculum-unit-toggle" onClick={()=>void toggleUnit(unit.id)}><div><strong>{unit.icon?`${unit.icon} `:''}{unit.code?`${unit.code} · `:''}{unit.name}</strong><span>{unit.description??(unit.translation_mode==='bilingual'?(isSpain?'Modo bilingüe FR/ES':'Mode bilingue FR/ES'):unit.unit_type.toUpperCase())}</span></div><span>{isOpen?'−':'+'}</span></button>{isOpen&&<div className="curriculum-topic-list">{loadingTopics===unit.id?<p>{isSpain?'Cargando capítulos…':'Chargement des chapitres…'}</p>:topics.length===0?<p className="curriculum-empty">{isSpain?'No hay capítulos publicados en esta materia.':'Aucun chapitre importé pour cette UE.'}</p>:topics.map(topic=><article className="curriculum-topic" key={topic.id}><span>{String(topic.display_order).padStart(2,'0')}</span><div className="curriculum-topic-copy"><strong>{topic.name}</strong>{topic.description&&<small>{topic.description}</small>}<div className="curriculum-topic-actions"><Link className="secondary-button compact-button" to={`/cours/${topic.id}#fiche`}>📖 {isSpain?'Ver ficha':'Lire la fiche'}</Link><Link className="primary-button compact-button" to={`/cours/${topic.id}#qcm`}>✅ {isSpain?'Práctica activa':'Révision active'}</Link></div></div></article>)}</div>}</article>})}</div>}</section>
  <section className="card"><div className="section-heading"><div><p className="eyebrow">{isSpain?'Progreso y comunidad':'Progression & communauté'}</p><h2>{isSpain?'Logros, amigos y retos':'Badges, amis et défis'}</h2></div></div><div className="quick-grid"><Link className="quick-card" to="/rewards"><span>🏅</span><strong>{isSpain?'Logros':'Badges'}</strong><small>{isSpain?'XP, rachas y recompensas.':'XP, séries et récompenses.'}</small></Link><Link className="quick-card" to="/amis"><span>⚔️</span><strong>{isSpain?'Amigos y retos':'Amis & défis'}</strong><small>{isSpain?'Invitaciones, duelos y desafíos.':'Invitations, duels et challenges.'}</small></Link><Link className="quick-card" to="/classement"><span>🏆</span><strong>{isSpain?'Clasificación':'Classement'}</strong><small>{isSpain?'Compara tu progreso con la comunidad.':'Comparer ta progression avec la communauté.'}</small></Link><Link className="quick-card" to="/profil"><span>👤</span><strong>{isSpain?'Perfil':'Profil'}</strong><small>{isSpain?'Alias, nivel y preferencias.':'Pseudo, niveau et préférences.'}</small></Link></div></section>
 </div>
}
