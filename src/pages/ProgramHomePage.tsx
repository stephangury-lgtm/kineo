import { useEffect,useState } from 'react'
import { Link } from 'react-router-dom'
import InstallAppCard from '../components/InstallAppCard'
import { getCurrentProgram,getUnlockedProgramLevels } from '../curriculum/programs'
import { getCurriculumFriendChallenges,type FriendChallenge } from '../services/challengeApi'
import { getGamificationSummaryV2,type GamificationSummaryV2 } from '../services/kineoApi'
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
    getFriendships(program.id),
    getCurriculumFriendChallenges(program.id),
   ])
   if(cancelled)return
   const [nextGame,nextFriends,nextChallenges]=common
   setGame(nextGame);setFriends(nextFriends);setChallenges(nextChallenges)
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
 if(!accessLoaded||!game)return <section className="card skeleton-card"><p>{isSpain?'Cargando tu progreso…':'Chargement de ta progression…'}</p></section>
 if(access&&!access.academic_level_id)return <div className="stack program-home-page"><section className="hero-card program-home-hero"><div className="hero-copy"><span className="hero-kicker">{program.flag} {isSpain?'Configura tu nivel':'Configure ton niveau'}</span><h1>{isSpain?'Elige tu año de estudios para empezar':'Choisis ton niveau d’étude pour commencer'}</h1><p>{isSpain?'Tu nivel desbloquea únicamente los contenidos correspondientes y los años anteriores.':'Ton niveau déverrouille uniquement les contenus correspondants et les niveaux précédents.'}</p><Link className="primary-button hero-action" to="/profil">{isSpain?'Elegir mi nivel':'Choisir mon niveau'}</Link></div><div className="hero-orbit"><span>🎓</span></div></section><section className="card"><p>{isSpain?'Tu cuenta tiene acceso a este plan, pero todavía no tiene un nivel asignado.':'Ton compte a accès à ce cursus, mais aucun niveau n’est encore attribué.'}</p></section></div>
 if(!progress)return <section className="card skeleton-card"><p>{isSpain?'Cargando tu progreso…':'Chargement de ta progression…'}</p></section>
 return <div className="stack dashboard-stack program-home-page">
  <section className="home-v4-welcome"><div><span className="eyebrow">✨ {isSpain?'TU ESPACIO':'TON ESPACE'} {program.shortName.toUpperCase()}</span><h1>{isSpain?'¿Listo para una nueva sesión?':'Prêt pour une nouvelle session ?'} 👋</h1><p>{isSpain?'Cada pequeño paso te acerca a tus objetivos.':'Chaque petit progrès te rapproche de tes objectifs.'}</p></div><div className="home-v4-illustration" aria-hidden="true"><span>{isIfsi?'👩‍⚕️':'👨‍⚕️'}</span><i>✦</i></div></section><div className="home-v4-toprow"><section className="hero-card dashboard-daily-hero program-home-hero home-v3-hero"><div className="hero-copy"><span className="hero-kicker">{program.flag} {isSpain?'Hoy · nivel':'Aujourd’hui · niveau'} {activeLevel}</span><h1>{streak>0?(isSpain?`${streak} día${streak>1?'s':''} seguidos 🔥`:`${streak} jour${streak>1?'s':''} de suite 🔥`):(isSpain?'Empieza tu racha hoy 🔥':'Commence ta série aujourd’hui 🔥')}</h1><p>{isSpain?'Retoma tu temario, consolida tus bases y sigue tu progreso desde un único espacio.':'Reprends ton cursus, consolide tes fondamentaux et suis ta progression depuis un seul espace.'}</p><Link className="primary-button hero-action" to="/fondamentaux?mode=mix">{isSpain?'Repasar · 10 preguntas':'Réviser · 10 questions'}</Link></div><div className="hero-orbit"><span>🧠</span></div></section>
  <Link className="home-v4-streak" to="/stats"><span className="home-v4-fire">🔥</span><div><strong>{streak} {isSpain?'días':'jours'}</strong><span>{isSpain?'Racha actual':'Série actuelle'}</span><small>{isSpain?'¡Sigue así!':'Continue sur cette lancée !'}</small></div><span className="home-v4-arrow">›</span></Link></div>
  <Link to="/rewards" className="card dashboard-level-card"><div className="dashboard-level-top"><span className="dashboard-level-emblem">🏅<small>{isSpain?'NIVEL':'NIVEAU'}</small>{game.level.number}</span><div><span className="eyebrow">{isSpain?'Mi nivel XP':'Mon niveau XP'}</span><h2>{isSpain?'Nivel':'Niveau'} {game.level.number} · {game.level.name}</h2><p>{xp} XP · {game.level.next_level?game.level.xp_to_next+' XP '+(isSpain?'para el próximo nivel':'avant le prochain niveau'):(isSpain?'Nivel máximo':'Niveau maximum')}</p></div><span className="dashboard-level-arrow">→</span></div><div className="progress-track"><div className="progress-fill" style={{width:Math.max(0,Math.min(100,game.level.progress_percent))+'%'}}/></div><small>{Math.round(game.level.progress_percent)}% · {isSpain?'Ver mis logros':'Voir mes badges'}</small></Link>
  <div className="home-v3-shortcuts"><Link to="/fondamentaux?mode=mix" className="home-v3-shortcut"><span>📘</span><strong>{isSpain?'Repasar':'Réviser'}</strong><small>{isSpain?'Preguntas':'Questions'}</small></Link><Link to="/amis" className="home-v3-shortcut"><span>🎯</span><strong>{isSpain?'Retos':'Défis'}</strong><small>{isSpain?'Amigos':'Entre amis'}</small></Link><Link to="/rewards" className="home-v3-shortcut"><span>🏆</span><strong>{isSpain?'Logros':'Badges'}</strong><small>{isSpain?'Premios':'Récompenses'}</small></Link><Link to="/stats" className="home-v3-shortcut"><span>📊</span><strong>{isSpain?'Progreso':'Statistiques'}</strong><small>{isSpain?'Detalles':'Mes progrès'}</small></Link></div>
  <InstallAppCard/>
  {socialAttention>0&&<section className="card challenge-card"><div className="challenge-icon">⚔️</div><div className="challenge-copy"><p className="eyebrow">{isSpain?'No te lo pierdas':'À ne pas manquer'}</p><h2>{socialAttention} {isSpain?(socialAttention>1?'acciones sociales':'acción social'):`action${socialAttention>1?'s':''} sociale${socialAttention>1?'s':''}`}</h2><p>{friends.incoming.length>0?(isSpain?`${friends.incoming.length} invitación${friends.incoming.length>1?'es':''} de amistad · `:`${friends.incoming.length} invitation${friends.incoming.length>1?'s':''} d’ami · `):''}{incomingChallenges.length>0?(isSpain?`${incomingChallenges.length} reto${incomingChallenges.length>1?'s':''} recibido${incomingChallenges.length>1?'s':''} · `:`${incomingChallenges.length} défi${incomingChallenges.length>1?'s':''} reçu${incomingChallenges.length>1?'s':''} · `):''}{playableChallenges.length>0?(isSpain?`${playableChallenges.length} duelo${playableChallenges.length>1?'s':''} por jugar`:`${playableChallenges.length} duel${playableChallenges.length>1?'s':''} à jouer`):''}</p></div><Link className="secondary-button" to="/amis">{isSpain?'Ver':'Voir'}</Link></section>}
  <section className="dashboard-metrics"><article className="metric-card"><span className="metric-icon">⚡</span><div><small>XP</small><strong>{xp}</strong></div></article><article className="metric-card"><span className="metric-icon">🔥</span><div><small>{isSpain?'Racha':'Série'}</small><strong>{streak} {isSpain?'d':'j'}</strong></div></article><article className="metric-card"><span className="metric-icon">◉</span><div><small>{isSpain?'Cobertura':'Couverture'}</small><strong>{coverage}%</strong></div></article></section>
  <section className="card progress-card"><div className="section-heading"><div><p className="eyebrow">{isSpain?'Progreso':'Progression'}</p><h2>{isSpain?`${coverage}% del nivel trabajado`:`${coverage}% du niveau travaillé`}</h2></div><Link className="text-link" to="/stats">{isSpain?'Detalles':'Détails'}</Link></div><div className="mastery-ring" style={{'--progress':`${Math.min(100,coverage)}%`} as React.CSSProperties}><span>{coverage}%</span></div><div className="progress-copy"><strong>{progress.questions_answered}/{progress.questions_total} {isSpain?'preguntas trabajadas':'questions travaillées'}</strong><span>{progress.topics_completed}/{progress.topics_total} {isSpain?'temas completados':'thèmes terminés'} · {completion}% {isSpain?'finalizado':'complété'}</span></div></section>
  <section className="card"><div className="section-heading"><div><p className="eyebrow">{isSpain?'Nivel activo':'Niveau actif'}</p><h2>{activeLevel}{refLabel?` · ${refLabel}`:''}</h2></div><span className="program-status live">{isSpain?'Asignado':'Attribué'}</span></div><p>{isSpain?'Tu nivel activo determina los contenidos desbloqueados. Puedes repasar este nivel y todos los anteriores desde el temario.':'Ton niveau actif détermine les contenus déverrouillés. Tu peux réviser ce niveau et tous les précédents depuis le parcours.'}</p><div className="program-steps">{unlockedLevels.map(level=><span key={level.id}>{level.shortLabel}</span>)}</div><Link className="secondary-button" to="/parcours">{isSpain?'Ver niveles accesibles':'Voir les niveaux accessibles'}</Link></section>
  <section className="quick-grid"><Link className="quick-card" to="/parcours"><span>▦</span><strong>{isSpain?'Temario':'Parcours'}</strong><small>{isSpain?'Elegir una materia':'Choisir une UE'}</small></Link><Link className="quick-card" to="/fondamentaux?mode=foundation"><span>🧱</span><strong>{isSpain?'Fundamentos':'Fondamentaux'}</strong><small>{isSpain?'Repasar lo esencial':'Revoir les acquis'}</small></Link></section>
 </div>
}
