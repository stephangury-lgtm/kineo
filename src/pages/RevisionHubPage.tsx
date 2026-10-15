import { useEffect,useState } from 'react'
import { useNavigate,Link,Navigate,useSearchParams } from 'react-router-dom'
import { getRecentRevisionSessionsV1,getActiveRevisionSessionV1,startRevisionSessionReplayV1,type RevisionHistoryItem } from '../services/kineoApi'
import { getCurrentProgram } from '../curriculum/programs'
import './RevisionHubPage.css'
import {useInterfaceVersion} from '../learning/InterfaceVersion'
export default function RevisionHubPage(){
 const {v5}=useInterfaceVersion()
 const [activeLoading,setActiveLoading]=useState(true)
 const [activeError,setActiveError]=useState(false)
 const [activeAttempt,setActiveAttempt]=useState(0)
 const [params]=useSearchParams()
 const navigate=useNavigate()
 const [active,setActive]=useState<{id:string;mode:string;answered_count:number;question_count:number}|null>(null)
 const [recent,setRecent]=useState<RevisionHistoryItem[]>([])
 const [busy,setBusy]=useState<string|null>(null)
 const [error,setError]=useState('')
 const [historyError,setHistoryError]=useState(false)
 useEffect(()=>{let alive=true;getRecentRevisionSessionsV1(3).then(rows=>{if(alive){setRecent(rows);setHistoryError(false)}}).catch(()=>{if(alive)setHistoryError(true)});return()=>{alive=false}},[])
 useEffect(()=>{let alive=true;setActiveLoading(true);setActiveError(false);const timer=window.setTimeout(()=>{if(alive){alive=false;setActiveLoading(false);setActiveError(true)}},12000);getActiveRevisionSessionV1().then(row=>{if(alive)setActive(row)}).catch(()=>{if(alive)setActiveError(true)}).finally(()=>{window.clearTimeout(timer);if(alive)setActiveLoading(false)});return()=>{alive=false;window.clearTimeout(timer)}},[activeAttempt])
 const replay=async(id:string)=>{setBusy(id);setError('');try{const next=await startRevisionSessionReplayV1(id);navigate('/quiz?mode=replay&session='+encodeURIComponent(next))}catch(e){setError(e instanceof Error?e.message:'Session indisponible')}finally{setBusy(null)}}
 const program=getCurrentProgram()
 const france=program.id==='kineo-fr'
 const spain=program.id==='kineo-es'
 const modeNames:Record<string,string>={smart:'Révision intelligente',visual:'Anatomie visuelle',exam:'Examen blanc',daily:'Défi du jour',clinical_case:'Cas clinique',matching:'Associations',mcq:'QCM',true_false:'Vrai / Faux',fill_blank:'Texte à trous',translation:'Traduction',mix:'Révision ciblée',weak:'Mes points faibles',replay:'Session refaite',subject:'Révision par matière',lesson:'Quiz de leçon',challenge:'Défi entre amis'}
 if(france&&['daily','challenge','lesson','subject','exam'].includes(params.get('mode')??''))return <Navigate to={'/quiz?'+params.toString()} replace/>
 if(france&&params.has('session'))return <Navigate to={'/quiz?'+params.toString()} replace/>
 const items=france?[
  {icon:'⚡',title:'Révision intelligente',desc:'Une session adaptée à ta progression',to:'/quiz'},
  {icon:'🔥',title:'Défi du jour',desc:'Entretiens ta série de révisions',to:'/quiz?mode=daily'},
  {icon:'📖',title:'Réviser une matière',desc:'Choisis les notions de ton parcours',to:'/parcours'},
  {icon:'🧱',title:'Retour aux fondamentaux',desc:'Revois les acquis essentiels',to:'/fondamentaux?mode=foundation'},
  {icon:'🎯',title:'Mes points faibles',desc:'Reprends les questions à renforcer',to:'/mes-erreurs'},
  {icon:'🦴',title:'Anatomie visuelle',desc:'Travaille les zones anatomiques',to:'/anatomie'},
  {icon:'📝',title:'Examen blanc',desc:'Entraîne-toi en conditions d’examen',to:'/examen'},
  {icon:'⚔️',title:'Défis entre amis',desc:'Affronte des étudiants de ton cursus',to:'/amis'},
 ]:[
  {icon:'🧱',title:spain?'Fundamentos':'Retour aux fondamentaux',desc:spain?'Repasa los conceptos esenciales':'Revois les notions essentielles',to:'/fondamentaux?mode=foundation'},
  {icon:'🔀',title:spain?'Repaso mixto':'Quiz variés',desc:spain?'Mezcla preguntas de tu nivel':'Mélange les questions de ton niveau',to:'/fondamentaux?mode=mix'},
  {icon:'📚',title:spain?'Repasar por materia':'Réviser par UE',desc:spain?'Elige una asignatura':'Choisis une unité d’enseignement',to:'/parcours'},
  {icon:'⚔️',title:spain?'Retos con amigos':'Défis entre amis',desc:spain?'Desafía a tus amigos':'Défie tes amis',to:'/amis'},
  {icon:'🏆',title:spain?'Mi progreso':'Ma progression',desc:spain?'Consulta tus resultados':'Consulte tes résultats',to:'/stats'},
 ]
 return <div className="stack revision-hub"><section className="stats-hero"><div><p className="eyebrow light">{spain?'Tu espacio de repaso':'Ton espace de révision'}</p><h1>{spain?'¿Qué quieres repasar hoy ?':'Comment veux-tu réviser aujourd’hui ?'}</h1><p>{spain?'Elige un modo adaptado a tu nivel.':'Choisis un mode selon ton objectif et ton niveau.'}</p></div></section>{v5&&france&&<section className="card" aria-live="polite">{activeLoading?<p>Recherche de ta séance en cours…</p>:activeError?<><h2>Vérifier ma séance en cours</h2><p>Impossible de vérifier la reprise. Réessaie avant de lancer une autre séance.</p><button className="secondary-button" onClick={()=>setActiveAttempt(value=>value+1)}>Réessayer la reprise</button></>:active?<><h2>Reprendre ma séance</h2><p>{active.answered_count} / {active.question_count} questions traitées</p><Link className="primary-button" to={'/quiz?mode=resume&session='+encodeURIComponent(active.id)}>Continuer ma séance</Link></>:<><h2>Ta prochaine révision</h2><p>Choisis un objectif ci-dessous. Pour suivre tes résultats et tes badges, ouvre Progrès.</p></>}</section>}{(!v5||!france||(!activeLoading&&!activeError))&&<div className="revision-hub-grid">{items.map(item=><Link key={item.title} className="card revision-hub-option" to={item.to}><span className="revision-hub-icon" aria-hidden="true">{item.icon}</span><span className="revision-hub-copy"><strong>{item.title}</strong><small>{item.desc}</small></span><span aria-hidden="true">→</span></Link>)}</div>}{active&&!v5&&<section className="card revision-history-card"><div className="revision-history-heading"><div><p className="eyebrow">En cours</p><h2>Reprendre ma session</h2></div><Link className="revision-history-all" to={'/quiz?mode=resume&session='+encodeURIComponent(active.id)}>Continuer →</Link></div><p>{active.answered_count} / {active.question_count} questions traitées</p></section>}{<section className="card revision-history-card"><div className="revision-history-heading"><div><p className="eyebrow">Reprendre</p><h2>Mes dernières sessions</h2></div><Link className="revision-history-all" to="/revision/historique">Voir tout →</Link></div>{error&&<p role="alert">{error}</p>}{historyError&&<p role="alert">Impossible de charger les sessions pour le moment.</p>}{!historyError&&recent.length===0&&<p className="revision-history-empty">Tes dernières sessions terminées apparaîtront ici après une révision.</p>}{recent.map(x=><div key={x.id} className="revision-history-row"><div className="revision-history-info"><strong>{modeNames[x.mode]??"Révision"}</strong><small>{new Date(x.completed_at??x.started_at).toLocaleDateString("fr-FR",{day:"numeric",month:"short"})} · {x.score_percent}% · {x.question_count} questions</small></div><button type="button" className="session-replay-mini" disabled={busy!==null} onClick={()=>void replay(x.id)}>{busy===x.id?'…':'↻ Refaire'}</button></div>)}</section>}</div>
}
