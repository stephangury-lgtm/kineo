import { useEffect,useState,type ReactNode } from 'react'
import { Link,useSearchParams } from 'react-router-dom'
import { getRevisionModeAvailabilityV1,type RevisionModeAvailability } from '../services/kineoApi'
import { getCurrentProfile } from '../services/profileApi'

export default function RevisionContentGate({children}:{children:ReactNode}){
 const [searchParams]=useSearchParams()
 const [availability,setAvailability]=useState<RevisionModeAvailability|null>(null)
 const [studyYear,setStudyYear]=useState<number|null>(null)
 const [failed,setFailed]=useState(false)
 const hasSession=Boolean(searchParams.get('session'))
 useEffect(()=>{let active=true;Promise.all([getRevisionModeAvailabilityV1(),getCurrentProfile()]).then(([m,p])=>{if(!active)return;setAvailability(m);setStudyYear(p?.study_year??null)}).catch(()=>{if(active)setFailed(true)});return()=>{active=false}},[])
 if(hasSession||failed)return <>{children}</>
 if(!availability)return <section className="card"><p>Préparation de ton espace de révision…</p></section>
 if(availability.total_questions===0)return <div className="stack"><section className="hero-card"><div className="hero-copy"><span className="hero-kicker">Révisions K{studyYear??''}</span><h1>Les contenus sont en préparation</h1><p>Kineo ne te proposera aucune question d’une autre année ni de contenu non validé. Les révisions seront activées dès que les CM K{studyYear??''} auront été intégrés et contrôlés.</p><Link className="primary-button hero-action" to="/parcours">Voir le parcours</Link></div><div className="hero-orbit"><span>📚</span></div></section></div>
 return <>{children}</>
}
