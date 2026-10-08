import './ParcoursRedesign.css'
import { useEffect,useMemo,useState } from 'react'
import { Link } from 'react-router-dom'
import { getCurrentProgram,getUnlockedProgramLevels,isProgramLevelUnlocked } from '../curriculum/programs'
import { getAcademicLevelId,getProgramUnits,getUnitTopics,type ProgramCatalogUnit,type ProgramCatalogTopic } from '../services/programCatalogApi'
import { getAccessiblePrograms,saveProgramCurriculumVersion,type AccessibleProgram,type CurriculumVersion } from '../services/programApi'

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

 const activeLevelCode=assignedAccess?.level_code??null
 const unlockedLevels=useMemo(()=>getUnlockedProgramLevels(p,activeLevelCode),[p,activeLevelCode])

 useEffect(()=>{
  let cancelled=false
  getAccessiblePrograms().then(accesses=>{
   if(cancelled)return
   const access=accesses.find(item=>item.program_id===p.id)??null
   setAssignedAccess(access)
   if(access?.level_code){
    const stored=localStorage.getItem(storageKey)
    const next=stored&&isProgramLevelUnlocked(p,access.level_code,stored)?stored:access.level_code
    setSelectedLevel(next)
    localStorage.setItem(storageKey,next)
   }
   if(access&&isIfsi){
    const version=access.curriculum_version==='2026'?'2026':'2009'
    setCurriculumVersion(version)
    localStorage.setItem(referenceStorageKey,version)
   }
  }).catch(()=>{if(!cancelled)setAssignedAccess(null)})
  return()=>{cancelled=true}
 },[p,storageKey,referenceStorageKey,isIfsi])

 useEffect(()=>{
  if(!selectedLevel)return
  if(activeLevelCode&&!isProgramLevelUnlocked(p,activeLevelCode,selectedLevel))return
  let cancelled=false
  setLoadingUnits(true);setCatalogError(null);setOpenUnitId(null);setTopicsByUnit({})
  getAcademicLevelId(p.id,selectedLevel).then(levelId=>getProgramUnits(p.id,levelId,curriculumVersion)).then(data=>{if(!cancelled)setUnits(data)}).catch(()=>{if(!cancelled){setUnits([]);setCatalogError(isSpain?'El contenido de este nivel está en preparación.':'Le catalogue de ce niveau est en préparation.')}}).finally(()=>{if(!cancelled)setLoadingUnits(false)})
  return()=>{cancelled=true}
 },[p,selectedLevel,isSpain,curriculumVersion,activeLevelCode])

 function chooseLevel(code:string){
  if(activeLevelCode&&!isProgramLevelUnlocked(p,activeLevelCode,code))return
  setSelectedLevel(code)
  localStorage.setItem(storageKey,code)
 }

 async function chooseReference(version:'2009'|'2026'){
  if(!isIfsi||version===curriculumVersion||syncing)return
  setSyncing(true);setSyncError(null)
  try{
   await saveProgramCurriculumVersion(p.id,version)
   setCurriculumVersion(version)
   localStorage.setItem(referenceStorageKey,version)
   setAssignedAccess(current=>current?{...current,curriculum_version:version}:current)
   window.dispatchEvent(new CustomEvent('kineo:curriculum-version-updated',{detail:{programId:p.id,version}}))
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

 return <div className="stack kineo-parcours-v2 parcours-redesign">
  <header className="parcours-page-heading"><div><p className="eyebrow">{isSpain?'MI RECORRIDO':'MON PARCOURS'}</p><h1>{isSpain?'Mis cursos y materias':'Mes cours et unités'}</h1><p>{isSpain?'Elige tu nivel y abre una materia para estudiar.':'Choisis ton niveau, ouvre une UE et retrouve tes fiches et quiz.'}</p></div><span className="parcours-level-chip">{activeLevelCode??p.shortName}</span></header>
  <section className="card foundation-card"><div className="section-heading"><div><p className="eyebrow">{isSpain?'Repaso acumulativo':'Révision cumulative'}</p><h2>{isSpain?'Mantén tus bases sólidas':'Retour aux fondamentaux'}</h2></div><span>🧠</span></div><p>{isSpain?'Repasa tu nivel actual y todos los niveles anteriores, sin desbloquear contenidos futuros.':'Révise ton niveau actuel et tous les niveaux précédents, sans jamais débloquer les contenus futurs.'}</p><div className="quick-grid"><Link className="quick-card" to="/fondamentaux?mode=foundation"><span>🧱</span><strong>{isSpain?'Fundamentos':'Fondamentaux'}</strong><small>{isSpain?'10 preguntas esenciales de niveles ya cursados.':'10 questions essentielles issues des niveaux déjà étudiés.'}</small></Link><Link className="quick-card" to="/fondamentaux?mode=mix"><span>🔀</span><strong>{isSpain?'Mix acumulativo':'Mix complet'}</strong><small>{unlockedLevels.map(level=>level.shortLabel).join(' + ')}</small></Link></div></section>
  <section className="stats-grid parcours-summary"><article className="card score-card"><span>📚 {isSpain?'Materias':'Unités'}</span><strong>{units.length}</strong><small>{isSpain?'en el nivel seleccionado':'sur le niveau sélectionné'}</small></article><article className="card score-card"><span>🎓 {isSpain?'Niveles':'Niveaux'}</span><strong>{unlockedLevels.length}</strong><small>{isSpain?'desbloqueados':'déverrouillés'}</small></article><article className="card score-card"><span>🧠 {isSpain?'Repaso':'Révision'}</span><strong>{isSpain?'Activa':'Active'}</strong><small>{isSpain?'fundamentos + mezcla':'fondamentaux + mix'}</small></article><article className="card score-card"><span>▦ {isSpain?'Actual':'Actuel'}</span><strong>{selectedLevel||'—'}</strong><small>{isIfsi?`Réf. ${curriculumVersion}`:p.name}</small></article></section>
  {isIfsi&&<section className="card ifsi-reference-card"><div className="section-heading"><div><p className="eyebrow">Référentiel national</p><h2>Quand es-tu entré en IFSI ?</h2></div><span className="program-status foundation">Réf. {curriculumVersion}</span></div><p>Choisis simplement ta période d’entrée en formation. Kineo sélectionnera automatiquement le bon référentiel et n’affichera que les UE, fiches et quiz correspondants.</p><div className="ifsi-reference-grid"><button type="button" className={`semester-card ${curriculumVersion==='2009'?'active':''}`} onClick={()=>void chooseReference('2009')} disabled={syncing}><strong>Je suis entré avant septembre 2026</strong><small>Référentiel 2009 · UE historiques 1.x à 6.x.</small></button><button type="button" className={`semester-card ${curriculumVersion==='2026'?'active':''}`} onClick={()=>void chooseReference('2026')} disabled={syncing}><strong>Je suis entré à partir de septembre 2026</strong><small>Référentiel 2026 · nouveaux domaines de compétences et nouvelles UE.</small></button></div>{syncError&&<p className="form-error">{syncError}</p>}</section>}
  <section className="card parcours-filter"><div className="section-heading"><div><p className="eyebrow">{isSpain?'Filtrar':'Filtrer'}</p><h2>{isSpain?'Elige un nivel accesible':'Choisis un niveau accessible'}</h2></div></div><label className="text-answer-wrap"><span>{isSpain?'Nivel mostrado':'Niveau affiché'}</span><select className="text-answer" value={selectedLevel} onChange={event=>chooseLevel(event.target.value)}>{unlockedLevels.map(level=><option key={level.id} value={level.shortLabel}>{level.shortLabel} · {level.label}</option>)}</select></label><p className="field-hint">{activeLevelCode?(isSpain?`Puedes trabajar ${unlockedLevels.map(level=>level.shortLabel).join(', ')}. Los niveles posteriores a ${activeLevelCode} permanecen bloqueados.`:`Tu peux travailler ${unlockedLevels.map(level=>level.shortLabel).join(', ')}. Les niveaux supérieurs à ${activeLevelCode} restent verrouillés.`):(isSpain?'Tu nivel de estudios debe estar definido para aplicar el desbloqueo progresivo.':'Ton niveau d’étude doit être défini pour appliquer le déverrouillage progressif.')}</p></section>
  <section className={`card parcours-content program-units-card ${selectedLevel==='S5'?'focus-semester':''}`}><div className="section-heading"><div><p className="eyebrow">{isSpain?'Materias':'Unités d’enseignement'}</p><h2>{selectedLevel}{isIfsi?` · Réf. ${curriculumVersion}`:''}</h2>{isIfsi&&<p className="field-hint semester-focus-copy">Travaille chapitre par chapitre, puis révise l’ensemble d’une UE ou de tout le semestre quand tu veux consolider les notions abordées.</p>}</div><span className="program-status foundation">{loadingUnits?(isSpain?'Cargando…':'Chargement…'):`${units.length} ${isSpain?'configurada'+(units.length!==1?'s':''):'configurée'+(units.length>1?'s':'')}`}</span></div>{isIfsi&&units.length>0&&<div className="semester-revision-cta"><Link className="primary-button" to={`/fondamentaux?mode=mix&scope=semester&level=${encodeURIComponent(selectedLevel)}&label=${encodeURIComponent(`Révision complète ${selectedLevel}`)}`}>🧠 Réviser tout le semestre {selectedLevel}</Link><small>Jusqu’à 20 questions réparties entre les UE publiées et validées de ce semestre.</small></div>}{catalogError&&<p>{catalogError}</p>}{!loadingUnits&&units.length===0&&!catalogError?<div className="admin-empty"><span>📚</span><div><strong>{isSpain?'Contenido pedagógico en preparación.':isIfsi&&curriculumVersion==='2026'?'Référentiel 2026 en cours d’intégration.':'Contenu pédagogique à intégrer.'}</strong><p>{isSpain?'Las materias se integran únicamente a partir de fuentes y documentos validados, sin inventar contenido.':isIfsi&&curriculumVersion==='2026'?'Les nouvelles UE seront ajoutées semestre par semestre exclusivement à partir de l’arrêté du 20 février 2026 et de supports validés.':'Les UE seront ajoutées à partir du référentiel et des supports validés, sans contenu inventé.'}</p></div></div>:<div className="subject-list">{units.map(unit=>{const isOpen=openUnitId===unit.id;const topics=topicsByUnit[unit.id]??[];return <article className={`subject-row curriculum-unit ${isOpen?'open':''}`} key={unit.id}><button type="button" className="curriculum-unit-toggle" onClick={()=>void toggleUnit(unit.id)}><div className="curriculum-unit-copy"><div className="curriculum-unit-title">{unit.icon&&<span className="curriculum-unit-icon">{unit.icon}</span>}{unit.code&&<span className="curriculum-unit-code">{unit.code}</span>}<strong>{unit.name}</strong></div><span>{unit.description??(unit.translation_mode==='bilingual'?(isSpain?'Modo bilingüe FR/ES':'Mode bilingue FR/ES'):unit.unit_type.toUpperCase())}</span></div><span className="curriculum-unit-action">{isOpen?(isSpain?'Cerrar':'Fermer'):(isSpain?'Abrir':'Ouvrir')} <b aria-hidden="true">{isOpen?'−':'+'}</b></span></button>{isOpen&&<div className="curriculum-topic-list">{loadingTopics===unit.id?<p>{isSpain?'Cargando capítulos…':'Chargement des chapitres…'}</p>:topics.length===0?<p className="curriculum-empty">{isSpain?'No hay capítulos publicados en esta materia.':'Aucun chapitre importé pour cette UE.'}</p>:<>{isIfsi&&<div className="unit-revision-cta"><Link className="secondary-button" to={`/fondamentaux?mode=mix&scope=unit&unit=${encodeURIComponent(unit.id)}&level=${encodeURIComponent(selectedLevel)}&label=${encodeURIComponent(`Révision UE ${unit.code??unit.name}`)}`}>✦ Réviser toute l’UE {unit.code??''}</Link><small>Jusqu’à 15 questions transversales sur les notions publiées de cette UE.</small></div>}{topics.map(topic=><article className="curriculum-topic" key={topic.id}><span>{String(topic.display_order).padStart(2,'0')}</span><div className="curriculum-topic-copy"><strong>{topic.name}</strong>{topic.description&&<small>{topic.description}</small>}<div className="curriculum-topic-actions"><Link className="secondary-button compact-button" to={`/cours/${topic.id}#fiche`}>📖 {isSpain?'Ver ficha':'Lire la fiche'}</Link><Link className="primary-button compact-button" to={`/cours/${topic.id}#qcm`}>✅ {isSpain?'Práctica activa':'Révision active'}</Link></div></div></article>)}</>}</div>}</article>})}</div>}</section>
  <section className="card"><div className="section-heading"><div><p className="eyebrow">{isSpain?'Progreso y comunidad':'Progression & communauté'}</p><h2>{isSpain?'Logros, amigos y retos':'Badges, amis et défis'}</h2></div></div><p className="field-hint">{isSpain?'Los retos y clasificaciones se mantienen estrictamente en tu nivel actual para que la comparación sea justa.':'Les défis et classements restent strictement sur ton niveau actuel pour garantir une comparaison équitable.'}</p><div className="quick-grid"><Link className="quick-card" to="/rewards"><span>🏅</span><strong>{isSpain?'Logros':'Badges'}</strong><small>{isSpain?'XP, rachas y recompensas.':'XP, séries et récompenses.'}</small></Link><Link className="quick-card" to="/amis"><span>⚔️</span><strong>{isSpain?'Amigos y retos':'Amis & défis'}</strong><small>{isSpain?'Invitaciones, duelos y desafíos.':'Invitations, duels et challenges.'}</small></Link><Link className="quick-card" to="/classement"><span>🏆</span><strong>{isSpain?'Clasificación':'Classement'}</strong><small>{isSpain?'Compara tu progreso con la comunidad.':'Comparer ta progression avec la communauté.'}</small></Link><Link className="quick-card" to="/profil"><span>👤</span><strong>{isSpain?'Perfil':'Profil'}</strong><small>{isSpain?'Alias, nivel y preferencias.':'Pseudo, niveau et préférences.'}</small></Link></div></section>
 </div>
}
