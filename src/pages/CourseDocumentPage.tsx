import { useEffect,useState } from 'react'
import { Link,useParams } from 'react-router-dom'
import { getCourseDocument,type CourseDocument } from '../services/courseDocumentApi'

export default function CourseDocumentPage(){
 const {documentId}=useParams()
 const [document,setDocument]=useState<(CourseDocument&{signedUrl:string})|null>(null)
 const [error,setError]=useState<string|null>(null)
 const [attempt,setAttempt]=useState(0)
 useEffect(()=>{
  let cancelled=false
  setDocument(null);setError(null)
  if(!documentId){setError('Support introuvable.');return}
  getCourseDocument(documentId).then(data=>{if(!cancelled)setDocument(data)})
   .catch(()=>{if(!cancelled)setError('Ce support est indisponible ou ton compte ne peut pas y accéder.')})
  return()=>{cancelled=true}
 },[documentId,attempt])
 return <div className="stack">
  <section className="card"><p className="eyebrow">Support pédagogique</p><h1>{document?.title??'Cours original'}</h1>
   <Link className="text-link" to="/parcours">← Retour au parcours</Link>
   {error&&<p role="alert">{error}</p>}
   {!error&&!document&&<p>Chargement du support…</p>}
   {(error||document)&&<button className="secondary-button" onClick={()=>setAttempt(value=>value+1)}>{error?'Réessayer':'Actualiser l’accès'}</button>}
  </section>
  {document&&<section className="card">
   <p>Le support s’ouvre dans Leryko. Si ton navigateur n’affiche pas le PDF, tu peux l’ouvrir dans un nouvel onglet.</p>
   <a className="secondary-button" href={document.signedUrl} target="_blank" rel="noopener noreferrer">Ouvrir le PDF</a>
   <iframe src={document.signedUrl} title={document.title} referrerPolicy="no-referrer" style={{width:'100%',height:'75vh',border:0,marginTop:'1rem'}}/>
  </section>}
 </div>
}
