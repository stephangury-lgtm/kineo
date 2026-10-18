import { useEffect,useState } from 'react'
import { Link,useParams } from 'react-router-dom'
import { getCourseDocument,type CourseDocument } from '../services/courseDocumentApi'
import CoursePdfReader from '../components/CoursePdfReader'
import {getCurrentProgram} from '../curriculum/programs'

export default function CourseDocumentPage(){
 const isSpain=getCurrentProgram().id==='kineo-es'
 const {documentId}=useParams()
 const [document,setDocument]=useState<(CourseDocument&{signedUrl:string})|null>(null)
 const [error,setError]=useState<string|null>(null)
 const [attempt,setAttempt]=useState(0)
 useEffect(()=>{
  let cancelled=false
  setDocument(null);setError(null)
  if(!documentId){setError(isSpain?'Documento no encontrado.':'Support introuvable.');return}
  getCourseDocument(documentId).then(data=>{if(!cancelled)setDocument(data)})
   .catch(()=>{if(!cancelled)setError(isSpain?'Este documento no está disponible o tu cuenta no tiene acceso.':'Ce support est indisponible ou ton compte ne peut pas y accéder.')})
  return()=>{cancelled=true}
 },[documentId,attempt,isSpain])
 return <div className="stack">
  <section className="card"><p className="eyebrow">{isSpain?'Material didáctico':'Support pédagogique'}</p><h1>{document?.title??(isSpain?'Curso original':'Cours original')}</h1>
   <Link className="text-link" to="/parcours">{isSpain?'← Volver al temario':'← Retour au parcours'}</Link>
   {error&&<p role="alert">{error}</p>}
   {!error&&!document&&<p>{isSpain?'Cargando el documento…':'Chargement du support…'}</p>}
   {(error||document)&&<button className="secondary-button" onClick={()=>setAttempt(value=>value+1)}>{isSpain?(error?'Reintentar':'Actualizar el acceso'):(error?'Réessayer':'Actualiser l’accès')}</button>}
  </section>
  {document&&<section className="card">
   <p>{isSpain?'Lee el documento aquí o ábrelo en otra pestaña.':'Lis le support ici, ou ouvre-le dans un nouvel onglet.'}</p>
   <a className="secondary-button" href={document.signedUrl} target="_blank" rel="noopener noreferrer">{isSpain?'Abrir el PDF':'Ouvrir le PDF'}</a>
   <CoursePdfReader url={document.signedUrl} title={document.title} isSpain={isSpain}/>
  </section>}
 </div>
}
