import { useEffect, useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { getLessonV2, startLessonQuizV2, type LessonV2 } from '../services/curriculumApi'
import { getLessonPersonalState, saveLessonNote, toggleLessonFavorite } from '../services/libraryApi'
import './LessonPage.css'

function renderListItem(value: unknown, index: number) {
  if (typeof value === 'string') return <li key={index}>{value}</li>
  if (value && typeof value === 'object') return <li key={index}>{JSON.stringify(value)}</li>
  return null
}

function pageLabel(start:number|null,end:number|null){
 if(start==null)return null
 if(end!=null&&end!==start)return `pages ${start}–${end}`
 return `page ${start}`
}

export default function LessonPage() {
  const { lessonId } = useParams()
  const navigate = useNavigate()
  const [lesson, setLesson] = useState<LessonV2 | null>(null)
  const [favorite,setFavorite]=useState(false)
  const [note,setNote]=useState('')
  const [noteSaved,setNoteSaved]=useState(true)
  const [busy, setBusy] = useState(false)
  const [personalBusy,setPersonalBusy]=useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!lessonId) return
    Promise.all([getLessonV2(lessonId),getLessonPersonalState(lessonId)])
      .then(([lessonData,state])=>{setLesson(lessonData);setFavorite(state.favorite);setNote(state.note??'')})
      .catch((err: Error) => setError(err.message))
  }, [lessonId])

  async function launchQuiz() {
    if (!lesson) return
    setBusy(true); setError(null)
    try { const sessionId = await startLessonQuizV2(lesson.id, 10); navigate(`/revision?mode=lesson&session=${encodeURIComponent(sessionId)}`) }
    catch (err) { setError(err instanceof Error ? err.message : 'Impossible de démarrer le quiz.') }
    finally { setBusy(false) }
  }

  async function toggleFavorite(){
    if(!lesson)return
    setPersonalBusy(true)
    try{setFavorite(await toggleLessonFavorite(lesson.id))}catch(err){setError(err instanceof Error?err.message:'Impossible de modifier le favori.')}finally{setPersonalBusy(false)}
  }

  async function saveNote(){
    if(!lesson)return
    setPersonalBusy(true)
    try{setNote(await saveLessonNote(lesson.id,note));setNoteSaved(true)}catch(err){setError(err instanceof Error?err.message:'Impossible d’enregistrer la note.')}finally{setPersonalBusy(false)}
  }

  if (error && !lesson) return <section className="card"><h1>Leçon indisponible</h1><p>{error}</p><Link className="secondary-button" to="/parcours">Retour au parcours</Link></section>
  if (!lesson) return <section className="card skeleton-card"><p>Chargement de la leçon…</p></section>

  return <div className="stack">
    <section className="stats-hero"><div><p className="eyebrow light">K{lesson.year.number} · {lesson.subject.icon ? `${lesson.subject.icon} ` : ''}{lesson.subject.name}</p><h1>{lesson.title}</h1><p>{lesson.chapter.name}{lesson.summary ? ` · ${lesson.summary}` : ''}</p><button className={`lesson-favorite ${favorite?'active':''}`} onClick={()=>void toggleFavorite()} disabled={personalBusy}>{favorite?'★ Enregistré dans mes favoris':'☆ Ajouter aux favoris'}</button></div><div className="stats-hero-score"><span>Maîtrise</span><strong>{lesson.mastery_percent}%</strong></div></section>
    <section className="stats-grid"><article className="card score-card"><span>❓ Questions</span><strong>{lesson.question_count}</strong><small>validées et jouables</small></article><article className="card score-card"><span>🧠 Maîtrise</span><strong>{lesson.mastery_percent}%</strong><small>progression actuelle</small></article><article className="card score-card"><span>🎯 Quiz</span><strong>{Math.min(10, lesson.question_count)}</strong><small>questions proposées</small></article><article className="card score-card"><span>✅ Statut</span><strong>Validé</strong><small>contenu publié</small></article></section>
    {lesson.image_url&&<section className="card centered"><img className="question-image" src={lesson.image_url} alt="Illustration de la leçon" /></section>}
    {lesson.content&&<section className="card"><div className="section-heading"><div><p className="eyebrow">Cours</p><h2>Comprendre l’essentiel</h2></div></div><div style={{whiteSpace:'pre-wrap',lineHeight:1.75}}>{lesson.content}</div></section>}
    {lesson.key_points.length>0&&<section className="card focus-card"><div><p className="eyebrow">Points clés</p><h2>À retenir</h2><ul>{lesson.key_points.map(renderListItem)}</ul></div><div className="focus-bubble">✓</div></section>}
    <section className="card lesson-note-card"><div className="section-heading"><div><p className="eyebrow">Note personnelle</p><h2>Mon aide-mémoire</h2></div><Link className="text-link" to="/bibliotheque">Ma bibliothèque</Link></div><textarea value={note} maxLength={4000} onChange={e=>{setNote(e.target.value);setNoteSaved(false)}} placeholder="Ajoute ici un moyen mnémotechnique, une définition à retenir ou un point à revoir…"/><div className="lesson-note-footer"><small>{note.length}/4000{noteSaved?' · enregistré':''}</small><button className="secondary-button compact-button" onClick={()=>void saveNote()} disabled={personalBusy||noteSaved}>{personalBusy?'Enregistrement…':'Enregistrer la note'}</button></div></section>
    {lesson.source_documents.length>0&&<section className="card"><div className="section-heading"><div><p className="eyebrow">Traçabilité</p><h2>Documents de référence</h2></div><span className="status-dot">Validé</span></div><div className="people-list">{lesson.source_documents.map((source,index)=><article className="person-row" key={`${source.title}-${index}`}><div className="person-avatar">📄</div><div className="person-copy"><strong>{source.title}</strong><span>{pageLabel(source.page_start,source.page_end)??'Référence du cours'} · {source.validation_status==='published'?'validé':'référence'}</span></div></article>)}</div></section>}
    {lesson.sources.length>0&&<section className="card"><div className="section-heading"><div><p className="eyebrow">Sources complémentaires</p><h2>Références du contenu</h2></div></div><ul>{lesson.sources.map(renderListItem)}</ul></section>}
    <section className="card centered"><p className="eyebrow">Passage à l’action</p><h2>Vérifie ce que tu as retenu</h2><p>Une courte série ciblée pour transformer la lecture en mémorisation active.</p><button className="primary-button wide" disabled={busy||lesson.question_count===0} onClick={launchQuiz}>{busy?'Préparation…':lesson.question_count>0?`Lancer le quiz (${Math.min(10,lesson.question_count)} questions)`:'Quiz en attente de validation'}</button><Link className="secondary-button wide" to="/parcours">Retour au parcours</Link>{error&&<p className="feedback">{error}</p>}</section>
  </div>
}
