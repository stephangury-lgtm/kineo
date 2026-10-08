import { Link, Navigate, useSearchParams } from 'react-router-dom'
import { getCurrentProgram } from '../curriculum/programs'
import './RevisionHubPage.css'
export default function RevisionHubPage(){
 const [params]=useSearchParams()
 const program=getCurrentProgram()
 const france=program.id==='kineo-fr'
 const spain=program.id==='kineo-es'
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
 return <div className="stack revision-hub"><section className="stats-hero"><div><p className="eyebrow light">{spain?'Tu espacio de repaso':'Ton espace de révision'}</p><h1>{spain?'¿Qué quieres repasar hoy ?':'Comment veux-tu réviser aujourd’hui ?'}</h1><p>{spain?'Elige un modo adaptado a tu nivel.':'Choisis un mode selon ton objectif et ton niveau.'}</p></div></section><div className="revision-hub-grid">{items.map(item=><Link key={item.title} className="card revision-hub-option" to={item.to}><span className="revision-hub-icon" aria-hidden="true">{item.icon}</span><span className="revision-hub-copy"><strong>{item.title}</strong><small>{item.desc}</small></span><span aria-hidden="true">→</span></Link>)}</div></div>
}
