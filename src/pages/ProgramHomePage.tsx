import { useEffect,useState } from 'react'
import { Link } from 'react-router-dom'
import InstallAppCard from '../components/InstallAppCard'
import { getCurrentProgram,getUnlockedProgramLevels } from '../curriculum/programs'
import { getCurriculumFriendChallenges,type FriendChallenge } from '../services/challengeApi'
import { getBadgesV2,getGamificationSummaryV2,type BadgesV2,type GamificationSummaryV2 } from '../services/kineoApi'
import { getAccessiblePrograms,getCurriculumProgress,type AccessibleProgram,type CurriculumProgress } from '../services/programApi'
import { getFriendships,type FriendshipsSummary } from '../services/socialApi'

const emptyFriends:FriendshipsSummary={friends:[],incoming:[],outgoing:[]}

export default function ProgramHomePage(){
 const program=getCurrentProgram()
 const isSpain=program.id==='kineo-es'
 const isIfsi=program.id==='ifsi-fr'
 const [access,setAccess]=useState<AccessibleProgram|null>(null)
 const [accessLoaded,setAccessLoaded]=useState(false)
 const [progress,setProgress]=useState<CurriculumProgress|null>(null)
 const [game,setGame]=useState<GamificationSummaryV2|null>(null)
 const [badges,setBadges]=useState<BadgesV2|null>(null)
 const [friends,setFriends]=useState<FriendshipsSummary>(emptyFriends)
 const [challenges,setChallenges]=useState<FriendChallenge[]>([])
 const [error,setError]=useState<string|null>(null)
 useEffect(()=>{let cancelled=false
  setError(null);setAccessLoaded(false);setProgress(null)
  getAccessiblePrograms().then(async items=>{
   if(cancelled)return
   const nextAccess=items.find(item=>item.program_id===program.id)??null
   setAccess(nextAccess);setAccessLoaded(true)
   const common=await Promise.all([
    getGamificationSummaryV2(),
    getBadgesV2(),
    getFriendships(program.id),
    getCurriculumFriendChallenges(program.id),
   ])
   if(cancelled)return
   const [nextGame,nextBadges,nextFriends,nextChallenges]=common
   setGame(nextGame);setBadges(nextBadges);setFriends(nextFriends);setChallenges(nextChallenges)
   if(nextAccess?.academic_level_id){
    const nextProgress=await getCurriculumProgress(program.id)
    if(!cancelled)setProgress(nextProgress)
   }
  }).catch((e:Error)=>{if(!cancelled){setAccessLoaded(true);setError(e.message)}})
  return()=>{cancelled=true}
 },[program.id])
 const activeLevel=access?.level_code??'—'
 const unlockedLevels=getUnlockedProgramLevels(program,access?.level_code)
 const refLabel=isIfsi?`Référentiel ${access?.curriculum_version==='2026'?'2026':'2009'}`:null
 const coverage=progress?.coverage_percent??0
 const completion=progress?.completion_percent??0
 const xp=game?.xp_total??0
 const streak=game?.streak.current??0
 const incomingChallenges=challenges.filter(item=>item.direction==='received'&&item.status==='pending')
 const playableChallenges=challenges.filter(item=>(item.status==='accepted'||item.status==='in_progress')&&!item.has_played)
 const socialAttention=friends.incoming.length+incomingChallenges.length+playableChallenges.length
 if(error&&!game)return <section className="card"><h1>{isSpain?'Inicio no disponible':'Accueil indisponible'}</h1><p>{error}</p></section>
 if(!accessLoaded||!game||!badges)return <section className="card skeleton-card"><p>{isSpain?'Cargando tu progreso…':'Chargement de ta progression…'}</p></section>
 if(access&&!access.academic_level_id)return <div className="stack program-home-page"><section className="hero-card program-home-hero"><div className="hero-copy"><span className="hero-kicker">{program.flag} {isSpain?'Configura tu nivel':'Configure ton niveau'}</span><h1>{isSpain?'Elige tu año de estudios para empezar':'Choisis ton niveau d’étude pour commencer'}</h1><p>{isSpain?'Tu nivel desbloquea únicamente los contenidos correspondientes y los años anteriores.':'Ton niveau déverrouille uniquement les contenus correspondants et les niveaux précédents.'}</p><Link className="primary-button hero-action" to="/profil">{isSpain?'Elegir mi nivel':'Choisir mon niveau'}</Link></div><div className="hero-orbit"><span>🎓</span></div></section><section className="card"><p>{isSpain?'Tu cuenta tiene acceso a este plan, pero todavía no tiene un nivel asignado.':'Ton compte a accès à ce cursus, mais aucun niveau n’est encore attribué.'}</p></section></div>
 if(!progress)return <section className="card skeleton-card"><p>{isSpain?'Cargando tu progreso…':'Chargement de ta progression…'}</p></section>
 return <div className="stack dashboard-stack program-home-page">
  <section className="hero-card dashboard-daily-hero program-home-hero"><div className="hero-copy"><span className="hero-kicker">{program.flag} {isSpain?'Hoy · nivel':'Aujourd’hui · niveau'} {activeLevel}</span><h1>{streak>0?(isSpain?`${streak} día${streak>1?'s':''} seguidos 🔥`:`${streak} jour${streak>1?'s':''} de suite 🔥`):(isSpain?'Empieza tu racha hoy 🔥':'Commence ta série aujourd’hui 🔥')}</h1><p>{isSpain?'Retoma tu temario, consolida tus bases y sigue tu progreso desde un único espacio.':'Reprends ton cursus, consolide tes fondamentaux et suis ta progression depuis un seul espace.'}</p><Link className="primary-button hero-action" to="/fondamentaux?mode=mix">{isSpain?'Repasar · 10 preguntas':'Réviser · 10 questions'}</Link></div><div className="hero-orbit"><span>🧠</span></div></section>
  <InstallAppCard/>
  {socialAttention>0&&<section className="card challenge-card"><div className="challenge-icon">⚔️</div><div className="challenge-copy"><p className="eyebrow">{isSpain?'No te lo pierdas':'À ne pas manquer'}</p><h2>{socialAttention} {isSpain?(socialAttention>1?'acciones sociales':'acción social'):`action${socialAttention>1?'s':''} sociale${socialAttention>1?'s':''}`}</h2><p>{friends.incoming.length>0?(isSpain?`${friends.incoming.length} invitación${friends.incoming.length>1?'es':''} de amistad · `:`${friends.incoming.length} invitation${friends.incoming.length>1?'s':''} d’ami · `):''}{incomingChallenges.length>0?(isSpain?`${incomingChallenges.length} reto${incomingChallenges.length>1?'s':''} recibido${incomingChallenges.length>1?'s':''} · `:`${incomingChallenges.length} défi${incomingChallenges.length>1?'s':''} reçu${incomingChallenges.length>1?'s':''} · `):''}{playableChallenges.length>0?(isSpain?`${playableChallenges.length} duelo${playableChallenges.length>1?'s':''} por jugar`:`${playableChallenges.length} duel${playableChallenges.length>1?'s':''} à jouer`):''}</p></div><Link className="secondary-button" to="/amis">{isSpain?'Ver':'Voir'}</Link></section>}
  <section className="dashboard-metrics"><article className="metric-card"><span className="metric-icon">⚡</span><div><small>XP</small><strong>{xp}</strong></div></article><article className="metric-card"><span className="metric-icon">🔥</span><div><small>{isSpain?'Racha':'Série'}</small><strong>{streak} {isSpain?'d':'j'}</strong></div></article><article className="metric-card"><span className="metric-icon">◉</span><div><small>{isSpain?'Cobertura':'Couverture'}</small><strong>{coverage}%</strong></div></article></section>
  <section className="card progress-card"><div className="section-heading"><div><p className="eyebrow">{isSpain?'Progreso':'Progression'}</p><h2>{isSpain?`${coverage}% del nivel trabajado`:`${coverage}% du niveau travaillé`}</h2></div><Link className="text-link" to="/stats">{isSpain?'Detalles':'Détails'}</Link></div><div className="mastery-ring" style={{'--progress':`${Math.min(100,coverage)}%`} as React.CSSProperties}><span>{coverage}%</span></div><div className="progress-copy"><strong>{progress.questions_answered}/{progress.questions_total} {isSpain?'preguntas trabajadas':'questions travaillées'}</strong><span>{progress.topics_completed}/{progress.topics_total} {isSpain?'temas completados':'thèmes terminés'} · {completion}% {isSpain?'finalizado':'complété'}</span></div></section>
  <section className="card"><div className="section-heading"><div><p className="eyebrow">{isSpain?'Nivel activo':'Niveau actif'}</p><h2>{activeLevel}{refLabel?` · ${refLabel}`:''}</h2></div><span className="program-status live">{isSpain?'Asignado':'Attribué'}</span></div><p>{isSpain?'Tu nivel activo determina los contenidos desbloqueados. Puedes repasar este nivel y todos los anteriores desde el temario.':'Ton niveau actif détermine les contenus déverrouillés. Tu peux réviser ce niveau et tous les précédents depuis le parcours.'}</p><div className="program-steps">{unlockedLevels.map(level=><span key={level.id}>{level.shortLabel}</span>)}</div><Link className="secondary-button" to="/parcours">{isSpain?'Ver niveles accesibles':'Voir les niveaux accessibles'}</Link></section>
  <section className="quick-grid"><Link className="quick-card" to="/parcours"><span>▦</span><strong>{isSpain?'Temario':'Parcours'}</strong><small>{isSpain?'Elegir una materia':'Choisir une UE'}</small></Link><Link className="quick-card" to="/fondamentaux?mode=foundation"><span>🧱</span><strong>{isSpain?'Fundamentos':'Fondamentaux'}</strong><small>{isSpain?'Repasar lo esencial':'Revoir les acquis'}</small></Link><Link className="quick-card" to="/amis"><span>⚔️</span><strong>{isSpain?'Amigos y retos':'Amis & défis'}</strong><small>{socialAttention>0?(isSpain?`${socialAttention} acción${socialAttention>1?'es':''}`:`${socialAttention} action${socialAttention>1?'s':''} à traiter`):(isSpain?'Retar a un compañero':'Défier un camarade')}</small></Link><Link className="quick-card" to="/stats"><span>↗</span><strong>{isSpain?'Estadísticas':'Statistiques'}</strong><small>{isSpain?'Ver mi progreso':'Voir mes progrès'}</small></Link></section>
 </div>
}
