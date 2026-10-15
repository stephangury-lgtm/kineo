import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { getMyLibrary, type PersonalLibrary } from '../services/libraryApi'
import { getCourseDocuments,type CourseDocument } from '../services/courseDocumentApi'
import './LibraryPage.css'

export default function LibraryPage(){
  const [library,setLibrary]=useState<PersonalLibrary|null>(null)
  const [error,setError]=useState<string|null>(null)
  const [documents,setDocuments]=useState<Array<Pick<CourseDocument,'id'|'title'|'file_name'|'file_size'>>|null>(null)
  const [documentError,setDocumentError]=useState(false)
  const [attempt,setAttempt]=useState(0)
  useEffect(()=>{let cancelled=false;getCourseDocuments().then(data=>{if(!cancelled)setDocuments(data)}).catch(()=>{if(!cancelled)setDocumentError(true)});return()=>{cancelled=true}},[])
  useEffect(()=>{
    let active=true
    const controller=new AbortController()
    setError(null)
    const timer=window.setTimeout(()=>{
      if(!active)return
      active=false
      controller.abort()
      setError('Le chargement de tes notes et favoris prend trop de temps. Tu peux réessayer.')
    },12000)
    getMyLibrary(controller.signal).then(data=>{if(active)setLibrary(data)}).catch(()=>{
      if(active)setError('Tes notes et favoris sont momentanément indisponibles.')
    }).finally(()=>window.clearTimeout(timer))
    return()=>{active=false;window.clearTimeout(timer);controller.abort()}
  },[attempt])
  return <div className="stack">
    <section className="hero-card"><div className="hero-copy"><span className="hero-kicker">Ton espace personnel</span><h1>Ma bibliothèque 📚</h1><p>Retrouve les cours enregistrés et tes notes personnelles au même endroit.</p></div><div className="hero-orbit">★</div></section>
    <section className="card"><div className="section-heading"><div><p className="eyebrow">Supports pédagogiques</p><h2>Cours originaux</h2></div><strong>{documents?.length??'…'}</strong></div>{documentError?<p>Les supports sont momentanément indisponibles.</p>:documents===null?<p>Chargement des supports…</p>:documents.length===0?<p>Aucun support disponible pour le moment.</p>:<div className="library-list">{documents.map(document=><Link className="library-item" key={document.id} to={`/document/${document.id}`}><span className="library-icon">📄</span><div><strong>{document.title}</strong><small>PDF{document.file_size?` · ${(document.file_size/1048576).toFixed(1)} Mo`:''}</small></div><span>›</span></Link>)}</div>}</section>
    {error&&<section className="card"><p role="alert">{error}</p><button className="secondary-button" onClick={()=>setAttempt(value=>value+1)}>Réessayer les notes et favoris</button></section>}
    {!library&&!error&&<section className="card skeleton-card"><p>Chargement de tes notes et favoris…</p></section>}
    {library&&<><section className="card"><div className="section-heading"><div><p className="eyebrow">Favoris</p><h2>Cours enregistrés</h2></div><strong>{library.favorites.length}</strong></div>{library.favorites.length===0?<div className="library-empty"><span>☆</span><p>Ajoute une leçon en favori depuis le parcours pour la retrouver ici.</p><Link className="secondary-button" to="/parcours">Explorer le parcours</Link></div>:<div className="library-list">{library.favorites.map(item=><Link className="library-item" key={item.id} to={`/lesson/${item.id}`}><span className="library-icon">★</span><div><small>K{item.year} · {item.subject}</small><strong>{item.title}</strong>{item.summary&&<p>{item.summary}</p>}</div><span>›</span></Link>)}</div>}</section>
    <section className="card"><div className="section-heading"><div><p className="eyebrow">Notes</p><h2>Mes notes de cours</h2></div><strong>{library.notes.length}</strong></div>{library.notes.length===0?<div className="library-empty"><span>✎</span><p>Écris une note dans une leçon pour créer ton aide-mémoire personnel.</p></div>:<div className="library-list">{library.notes.map(note=><Link className="library-item note-item" key={note.id} to={`/lesson/${note.lesson_id}`}><span className="library-icon">✎</span><div><small>K{note.year} · {note.subject}</small><strong>{note.title}</strong><p>{note.content}</p></div><span>›</span></Link>)}</div>}</section>
    </>}
  </div>
}

