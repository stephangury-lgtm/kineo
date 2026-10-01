import { useEffect,useState,type ReactNode } from 'react'
import { Link } from 'react-router-dom'
import { getRevisionModeAvailabilityV1,type RevisionModeAvailability } from '../services/kineoApi'
import { getCurrentProfile } from '../services/profileApi'

type Mode='visual'|'weak'|'exam'
const copy:Record<Mode,{icon:string;kicker:string;title:string;description:string}>={
 visual:{icon:'🦴',kicker:'Anatomie visuelle',title:'Les exercices visuels sont en validation',description:'Les anciens schémas ont été retirés. Ils ne seront réactivés qu’après contrôle du visuel, de la zone anatomique et de la validation de réponse.'},
 weak:{icon:'🎯',kicker:'Points faibles',title:'Pas encore de points faibles à cibler',description:'Ce mode devient disponible après quelques révisions, dès que Kineo dispose d’erreurs ou de notions fragiles à retravailler.'},
 exam:{icon:'📝',kicker:'Examen blanc',title:'Pas assez de contenu validé pour un examen',description:'Kineo attend au moins 10 questions validées dans ton année avant de proposer une simulation représentative.'},
}
export default function RevisionModeGate({mode,children}:{mode:Mode;children:ReactNode}){
 const [availability,setAvailability]=useState<RevisionModeAvailability|null>(null)
 const [studyYear,setStudyYear]=useState<number|null>(null)
 const [failed,setFailed]=useState(false)
 useEffect(()=>{let active=true;Promise.all([getRevisionModeAvailabilityV1(),getCurrentProfile()]).then(([m,p])=>{if(!active)return;setAvailability(m);setStudyYear(p?.study_year??null)}).catch(()=>{if(active)setFailed(true)});return()=>{active=false}},[])
 if(failed)return <>{children}</>
 if(!availability)return <section className="card"><p>Vérification des contenus disponibles…</p></section>
 const available=mode==='visual'?availability.can_visual:mode==='weak'?availability.can_weak:availability.can_exam
 if(available)return <>{children}</>
 const text=copy[mode]
 return <div className="stack"><section className="hero-card"><div className="hero-copy"><span className="hero-kicker">{text.kicker} · K{studyYear??''}</span><h1>{text.title}</h1><p>{text.description}</p><Link className="primary-button hero-action" to={availability.total_questions>0?'/revision':'/parcours'}>{availability.total_questions>0?'Révision intelligente':'Voir le parcours'}</Link></div><div className="hero-orbit"><span>{text.icon}</span></div></section></div>
}
