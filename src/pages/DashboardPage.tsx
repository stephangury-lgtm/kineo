import { useEffect,useMemo,useState } from 'react'
import { Link } from 'react-router-dom'
import InstallAppCard from '../components/InstallAppCard'
import { getFriendChallenges,type FriendChallenge } from '../services/challengeApi'
import { abandonRevisionSessionV1,getActiveRevisionSessionV1,getBadgesV2,getDashboardV2,getGamificationSummaryV2,getRecentRevisionSessionsV1,getRevisionModeAvailabilityV1,getStudyPrioritiesV1,type ActiveRevisionSession,type BadgesV2,type DashboardV2,type GamificationSummaryV2,type RevisionHistoryItem,type RevisionModeAvailability,type StudyPrioritiesV1 } from '../services/kineoApi'
import { getFriendships,type FriendshipsSummary } from '../services/socialApi'

const emptyFriends: FriendshipsSummary = { friends: [], incoming: [], outgoing: [] }
const ACTIVE_SMART_SESSION='kineo_active_smart_session'

export default function DashboardPage(){
 const [dashboard,setDashboard]=useState<DashboardV2|null>(null)
 const [game,setGame]=useState<GamificationSummaryV2|null>(null)
 const [badges,setBadges]=useState<BadgesV2|null>(null)
 const [modes,setModes]=useState<RevisionModeAvailability|null>(null)
 const [priorities,setPriorities]=useState<StudyPrioritiesV1|null>(null)
 const [active,setActive]=useState<ActiveRevisionSession|null>(null)
 const [recent,setRecent]=useState<RevisionHistoryItem[]>([])
 const [friends,setFriends]=useState<FriendshipsSummary>(emptyFriends)
 const [challenges,setChallenges]=useState<FriendChallenge[]>([])
 const [abandoning,setAbandoning]=useState(false)
 const [error,setError]=useState<string|null>(null)

 useEffect(()=>{
  Promise.all([
   getDashboardV2(),getGamificationSummaryV2(),getBadgesV2(),getRevisionModeAvailabilityV1(),getStudyPrioritiesV1(),getActiveRevisionSessionV1(),getRecentRevisionSessionsV1(30),getFriendships(),getFriendChallenges()
  ]).then(([d,g,b,m,p,a,r,f,c])=>{setDashboard(d);setGame(g);setBadges(b);setModes(m);setPriorities(p);setActive(a);setRecent(r);setFriends(f);setChallenges(c)}).catch((e:Error)=>setError(e.message))
 },[])

 const week=useMemo(()=>{
  const now=new Date(),day=(now.getDay()+6)%7,monday=new Date(now)
  monday.setHours(0,0,0,0);monday.setDate(now.getDate()-day)
  const sessions=recent.filter(r=>new Date(r.completed_at??r.started_at)>=monday)
  const activeDays=new Set(sessions.map(r=>new Date(r.completed_at??r.started_at).toISOString().slice(0,10))).size
  return{sessions:sessions.length,activeDays,progress:Math.min(100,Math.round((sessions.length/5)*100))}
 },[recent])

 async function abandonActive(){if(!active)return;setAbandoning(true);try{await abandonRevisionSessionV1(active.id);localStorage.removeItem(ACTIVE_SMART_SESSION);setActive(null)}catch(e){setError(e instanceof Error?e.message:'Impossible d’abandonner cette session.')}finally{setAbandoning(false)}}

 if(error)return <section className="card"><h1>Progression indisponible</h1><p>{error}</p></section>
 if(!dashboard||!game||!badges||!modes||!priorities)return <section className="card skeleton-card"><p>Chargement de ta progression…</p></section>

 const xp=game.xp_total??dashboard.profile?.xp??0
 const level=game.level.number??dashboard.profile?.level??1
 const streak=game.streak.current??dashboard.streak?.current??0
 const mastery=dashboard.mastery?.overall_percent??0
 const dailyDone=dashboard.daily?.completed===true||dashboard.daily?.status==='completed'
 const due=dashboard.mastery?.due??0
 const nextBadge=badges.badges.filter(b=>!b.earned).sort((a,b)=>b.progress_percent-a.progress_percent)[0]
 const levelProgress=Math.min(100,game.level.progress_percent??0)
 const incomingChallenges=challenges.filter(item=>item.direction==='received'&&item.status==='pending')
 const playableChallenges=challenges.filter(item=>(item.status==='accepted'||item.status==='in_progress')&&!item.has_played)
 const waitingChallenges=challenges.filter(item=>item.has_played&&!item.opponent_has_played&&item.status!=='completed')
 const socialAttention=friends.incoming.length+incomingChallenges.length+playableChallenges.length

 return <div className="stack dashboard-stack">
  <section className="hero-card"><div className="hero-copy"><span className="hero-kicker">Ta session du jour</span><h1>{streak>0?`${streak} jour${streak>1?'s':''} de suite 🔥`:'Commence ta série aujourd’hui 🔥'}</h1><p>{due>0?`${due} notion${due>1?'s':''} à revoir aujourd’hui.`:'Ton programme est à jour. Quelques questions pour consolider ?'}</p><Link className="primary-button hero-action" to="/revision">Commencer · 10 questions</Link></div><div className="hero-orbit"><span>🧠</span></div></section>
  <InstallAppCard/>

  {priorities.items.length>0&&<section className="card"><div className="section-heading"><div><p className="eyebrow">Priorités K{priorities.study_year??''}</p><h2>Ton plan de travail recommandé</h2></div><Link className="text-link" to="/parcours">Voir le parcours</Link></div><div className="people-list">{priorities.items.map((item,index)=><article className="person-row" key={item.subject_id}><div className="person-avatar">{item.icon||['🎯','📚','🧠'][index]}</div><div className="person-copy"><strong>{item.name}</strong><span>{item.reason} · maîtrise {item.mastery_percent}% · couverture {item.coverage_percent}%</span><div className="progress-track small"><div className="progress-fill" style={{width:`${Math.max(3,Math.min(100,item.coverage_percent))}%`}}/></div></div>{(item.due_questions>0||item.fragile_questions>0)&&<Link className="secondary-button compact-button" to="/mes-erreurs">Réviser</Link>}</article>)}</div></section>}

  {socialAttention>0&&<section className="card challenge-card"><div className="challenge-icon">⚔️</div><div className="challenge-copy"><p className="eyebrow">À ne pas manquer</p><h2>{socialAttention} action{socialAttention>1?'s':''} sociale{socialAttention>1?'s':''}</h2><p>{friends.incoming.length>0?`${friends.incoming.length} invitation${friends.incoming.length>1?'s':''} d’ami · `:''}{incomingChallenges.length>0?`${incomingChallenges.length} défi${incomingChallenges.length>1?'s':''} reçu${incomingChallenges.length>1?'s':''} · `:''}{playableChallenges.length>0?`${playableChallenges.length} duel${playableChallenges.length>1?'s':''} à jouer`:''}</p></div><Link className="secondary-button" to="/amis">Voir</Link></section>}
  {waitingChallenges.length>0&&<section className="card challenge-card done"><div className="challenge-icon">⏳</div><div className="challenge-copy"><p className="eyebrow">Défis</p><h2>{waitingChallenges.length} résultat{waitingChallenges.length>1?'s':''} en attente</h2><p>Ton score est enregistré. Kineo attend encore la réponse de ton adversaire.</p></div><Link className="text-link" to="/amis">Suivre</Link></section>}
  {active&&active.answered_count<active.question_count&&<section className="card challenge-card"><div className="challenge-icon">▶</div><div className="challenge-copy"><p className="eyebrow">Session en cours</p><h2>Reprendre là où tu t’es arrêté</h2><p>{active.answered_count}/{active.question_count} questions déjà répondues · session synchronisée avec ton compte.</p></div><div className="friend-actions"><Link className="secondary-button" to={`/revision?mode=resume&session=${encodeURIComponent(active.id)}`}>Reprendre</Link><button className="text-link" onClick={()=>void abandonActive()} disabled={abandoning}>{abandoning?'…':'Abandonner'}</button></div></section>}

  <section className="dashboard-metrics"><article className="metric-card"><span className="metric-icon">⚡</span><div><small>XP</small><strong>{xp}</strong></div></article><article className="metric-card"><span className="metric-icon">🔥</span><div><small>Série</small><strong>{streak} j</strong></div></article><article className="metric-card"><span className="metric-icon">◉</span><div><small>Maîtrise</small><strong>{mastery}%</strong></div></article></section>

  <section className="card level-progress-card"><div className="section-heading"><div><p className="eyebrow">Rythme de la semaine</p><h2>{week.sessions} session{week.sessions>1?'s':''} · {week.activeDays} jour{week.activeDays>1?'s':''} actif{week.activeDays>1?'s':''}</h2></div><strong>{week.progress}%</strong></div><div className="progress-track level-track"><div className="progress-fill" style={{width:`${week.progress}%`}}/></div><div className="level-progress-copy"><span>Repère hebdomadaire : 5 sessions</span><span>{week.sessions>=5?'Rythme atteint ✓':`${5-week.sessions} session${5-week.sessions>1?'s':''} pour atteindre le repère`}</span></div></section>
  <section className="card level-progress-card"><div className="section-heading"><div><p className="eyebrow">Niveau {level}</p><h2>{game.level.name}</h2></div><strong>{levelProgress}%</strong></div><div className="progress-track level-track"><div className="progress-fill" style={{width:`${levelProgress}%`}}/></div><div className="level-progress-copy"><span>{xp} XP au total</span><span>{game.level.next_level?`${game.level.xp_to_next} XP avant ${game.level.next_name}`:'Niveau maximum atteint'}</span></div></section>
  <section className={`card challenge-card ${dailyDone?'done':''}`}><div className="challenge-icon">{dailyDone?'✓':'🔥'}</div><div className="challenge-copy"><p className="eyebrow">Challenge du jour</p><h2>{dailyDone?'Mission accomplie':`${dashboard.daily?.question_count??10} questions · bonus XP`}</h2><p>{dailyDone?'Ta série est protégée pour aujourd’hui.':'Une session rapide pour entretenir ta régularité.'}</p></div>{!dailyDone&&<Link className="secondary-button" to="/revision?mode=daily">Jouer</Link>}</section>
  {nextBadge&&<section className="card next-badge-card"><div className="next-badge-icon">{nextBadge.icon||'🎯'}</div><div className="next-badge-copy"><p className="eyebrow">Prochain badge</p><h2>{nextBadge.name}</h2><p>{nextBadge.description}</p><div className="progress-track small"><div className="progress-fill" style={{width:`${Math.min(100,nextBadge.progress_percent)}%`}}/></div><small>{nextBadge.current_value}/{nextBadge.target_value} · {nextBadge.progress_percent}%</small></div><Link className="text-link" to="/rewards">Tous les badges</Link></section>}
  <section className="card progress-card"><div className="section-heading"><div><p className="eyebrow">Connaissances</p><h2>Maîtrise du programme</h2></div><Link className="text-link" to="/stats">Détails</Link></div><div className="mastery-ring" style={{'--progress':`${Math.min(100,mastery)}%`} as React.CSSProperties}><span>{mastery}%</span></div><div className="progress-copy"><strong>{dashboard.mastery?.mastered??0} notions maîtrisées</strong><span>{dashboard.mastery?.fragile??0} fragiles · {due} à revoir</span></div></section>

  <section className="quick-grid"><Link className="quick-card" to="/parcours"><span>▦</span><strong>Parcours</strong><small>Choisir une leçon</small></Link>{modes.can_weak?<Link className="quick-card" to="/mes-erreurs"><span>🎯</span><strong>Mes points faibles</strong><small>{modes.weak_questions} notion{modes.weak_questions>1?'s':''} à retravailler</small></Link>:<div className="quick-card"><span>✅</span><strong>Points faibles</strong><small>Rien d’urgent à retravailler</small></div>}{modes.can_visual?<Link className="quick-card" to="/anatomie"><span>🦴</span><strong>Anatomie visuelle</strong><small>{modes.visual_questions} exercices disponibles</small></Link>:<div className="quick-card"><span>🦴</span><strong>Anatomie visuelle</strong><small>Contenu à venir pour ton année</small></div>}{modes.can_exam&&<Link className="quick-card" to="/examen"><span>📝</span><strong>Examen blanc</strong><small>20 questions équilibrées</small></Link>}<Link className="quick-card" to="/bibliotheque"><span>★</span><strong>Ma bibliothèque</strong><small>Favoris et notes personnelles</small></Link><Link className="quick-card" to="/amis"><span>⚔️</span><strong>Amis & défis</strong><small>{socialAttention>0?`${socialAttention} action${socialAttention>1?'s':''} à traiter`:'Défier un camarade'}</small></Link><Link className="quick-card" to="/stats"><span>↗</span><strong>Statistiques</strong><small>Voir mes progrès</small></Link></section>
 </div>
}
