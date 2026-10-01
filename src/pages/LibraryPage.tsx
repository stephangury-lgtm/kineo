import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { getMyLibrary, type PersonalLibrary } from '../services/libraryApi'
import './LibraryPage.css'

export default function LibraryPage(){
  const [library,setLibrary]=useState<PersonalLibrary|null>(null)
  const [error,setError]=useState<string|null>(null)
  useEffect(()=>{getMyLibrary().then(setLibrary).catch((err:Error)=>setError(err.message))},[])
  if(error)return <section className="card"><h1>Bibliothèque indisponible</h1><p>{error}</p></section>
  if(!library)return <section className="card skeleton-card"><p>Chargement de ta bibliothèque…</p></section>
  return <div className="stack">
    <section className="hero-card"><div className="hero-copy"><span className="hero-kicker">Ton espace personnel</span><h1>Ma bibliothèque 📚</h1><p>Retrouve les cours enregistrés et tes notes personnelles au même endroit.</p></div><div className="hero-orbit">★</div></section>
    <section className="card"><div className="section-heading"><div><p className="eyebrow">Favoris</p><h2>Cours enregistrés</h2></div><strong>{library.favorites.length}</strong></div>{library.favorites.length===0?<div className="library-empty"><span>☆</span><p>Ajoute une leçon en favori depuis le parcours pour la retrouver ici.</p><Link className="secondary-button" to="/parcours">Explorer le parcours</Link></div>:<div className="library-list">{library.favorites.map(item=><Link className="library-item" key={item.id} to={`/lesson/${item.id}`}><span className="library-icon">★</span><div><small>K{item.year} · {item.subject}</small><strong>{item.title}</strong>{item.summary&&<p>{item.summary}</p>}</div><span>›</span></Link>)}</div>}</section>
    <section className="card"><div className="section-heading"><div><p className="eyebrow">Notes</p><h2>Mes notes de cours</h2></div><strong>{library.notes.length}</strong></div>{library.notes.length===0?<div className="library-empty"><span>✎</span><p>Écris une note dans une leçon pour créer ton aide-mémoire personnel.</p></div>:<div className="library-list">{library.notes.map(note=><Link className="library-item note-item" key={note.id} to={`/lesson/${note.lesson_id}`}><span className="library-icon">✎</span><div><small>K{note.year} · {note.subject}</small><strong>{note.title}</strong><p>{note.content}</p></div><span>›</span></Link>)}</div>}</section>
  </div>
}
