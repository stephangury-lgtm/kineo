import { useEffect,useState } from 'react'
import { Link,useNavigate,useSearchParams } from 'react-router-dom'
import { startSubjectRevisionV1 } from '../services/kineoApi'

export default function SubjectRevisionPage(){
 const navigate=useNavigate()
 const [params]=useSearchParams()
 const subjectId=params.get('subjectId')
 const subject=params.get('subject')||'cette matière'
 const [error,setError]=useState<string|null>(null)

 useEffect(()=>{
  if(!subjectId){setError('Matière introuvable.');return}
  let cancelled=false
  startSubjectRevisionV1(subjectId,10).then(session=>{
   if(!cancelled)navigate(`/revision?mode=subject&session=${encodeURIComponent(session)}&subjectId=${encodeURIComponent(subjectId)}&subject=${encodeURIComponent(subject)}`,{replace:true})
  }).catch((e:Error)=>{if(!cancelled)setError(e.message)})
  return()=>{cancelled=true}
 },[navigate,subjectId,subject])

 if(error)return <div className="stack"><section className="card centered"><p className="eyebrow">Révision ciblée</p><h1>Impossible de préparer la session</h1><p>{error}</p><Link className="secondary-button" to="/parcours">Retour au parcours</Link></section></div>
 return <div className="stack"><section className="hero-card"><div className="hero-copy"><p className="eyebrow light">Révision ciblée</p><h1>Préparation de {subject}…</h1><p>Kineo sélectionne en priorité les notions à revoir, fragiles ou encore jamais travaillées.</p></div><div className="hero-orbit"><span>🎯</span></div></section></div>
}
