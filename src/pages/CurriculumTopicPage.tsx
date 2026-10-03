import { useEffect,useMemo,useState } from 'react'
import { Link,useParams } from 'react-router-dom'
import { getTopic,getTopicLessons,getTopicQuiz,type CurriculumLesson,type CurriculumQuizQuestion,type CurriculumQuizOption,type ProgramCatalogTopic } from '../services/programCatalogApi'

export default function CurriculumTopicPage(){
 const {topicId}=useParams()
 const [topic,setTopic]=useState<ProgramCatalogTopic|null>(null)
 const [lessons,setLessons]=useState<CurriculumLesson[]>([])
 const [quiz,setQuiz]=useState<CurriculumQuizQuestion[]>([])
 const [loading,setLoading]=useState(true)
 const [error,setError]=useState<string|null>(null)
 const [answers,setAnswers]=useState<Record<string,string>>({})
 const [checked,setChecked]=useState<Record<string,boolean>>({})

 useEffect(()=>{
  if(!topicId)return
  let cancelled=false
  setLoading(true);setError(null)
  Promise.all([getTopic(topicId),getTopicLessons(topicId),getTopicQuiz(topicId)])
   .then(([t,l,q])=>{if(cancelled)return;setTopic(t);setLessons(l);setQuiz(q)})
   .catch(()=>{if(!cancelled)setError('Impossible de charger ce chapitre pour le moment.')})
   .finally(()=>{if(!cancelled)setLoading(false)})
  return()=>{cancelled=true}
 },[topicId])

 const score=useMemo(()=>quiz.reduce((total,q)=>{
  if(!checked[q.id])return total
  const correct=q.options.find(o=>o.correct)?.text
  return total+(answers[q.id]===correct?1:0)
 },0),[quiz,answers,checked])
 const checkedCount=Object.keys(checked).filter(id=>checked[id]).length

 if(loading)return <div className="card"><p>Chargement du cours…</p></div>
 if(error||!topic)return <div className="card"><p>{error??'Chapitre introuvable.'}</p><Link className="primary-button" to="/parcours">Retour au parcours</Link></div>

 return <div className="stack curriculum-learning-page">
  <section className="card curriculum-learning-hero">
   <Link className="text-link" to="/parcours">← Retour aux UE</Link>
   <p className="eyebrow">Chapitre IFSI</p>
   <h1>{topic.name}</h1>
   {topic.description&&<p>{topic.description}</p>}
  </section>

  <section className="card">
   <div className="section-heading"><div><p className="eyebrow">Cours</p><h2>Fiche de révision</h2></div><span className="program-status live">{lessons.length} fiche{lessons.length>1?'s':''}</span></div>
   {lessons.length===0?<p>Aucune fiche publiée pour ce chapitre.</p>:lessons.map(lesson=><article className="curriculum-lesson" key={lesson.id}>
    <h3>{lesson.title}</h3>
    {lesson.summary&&<p className="curriculum-summary">{lesson.summary}</p>}
    <div className="curriculum-course-content">{lesson.content.split(/\n{2,}/).map((part,i)=><p key={i}>{part}</p>)}</div>
    {Array.isArray(lesson.key_points)&&lesson.key_points.length>0&&<div className="curriculum-key-points"><strong>À retenir</strong><ul>{(lesson.key_points as unknown[]).map((point,i)=><li key={i}>{String(point)}</li>)}</ul></div>}
   </article>)}
  </section>

  <section className="card">
   <div className="section-heading"><div><p className="eyebrow">QCM</p><h2>Teste tes acquis</h2></div>{quiz.length>0&&<span className="program-status foundation">{checkedCount}/{quiz.length} répondu{quiz.length>1?'s':''}</span>}</div>
   {quiz.length===0?<p>Le QCM de ce chapitre n’est pas encore publié.</p>:<div className="curriculum-quiz-list">{quiz.map((q,index)=>{
    const selected=answers[q.id]
    const isChecked=!!checked[q.id]
    const correct=q.options.find((o:CurriculumQuizOption)=>o.correct)?.text
    return <article className="curriculum-quiz-card" key={q.id}>
     <strong>Question {index+1}</strong>
     <p>{q.question_text}</p>
     <div className="curriculum-options">{q.options.map((option:CurriculumQuizOption)=><label className={`curriculum-option ${isChecked&&option.text===correct?'correct':''} ${isChecked&&selected===option.text&&option.text!==correct?'incorrect':''}`} key={option.text}><input type="radio" name={q.id} value={option.text} checked={selected===option.text} disabled={isChecked} onChange={()=>setAnswers(current=>({...current,[q.id]:option.text}))}/><span>{option.text}</span></label>)}</div>
     <button className="primary-button" type="button" disabled={!selected||isChecked} onClick={()=>setChecked(current=>({...current,[q.id]:true}))}>Valider</button>
     {isChecked&&<div className={`curriculum-feedback ${selected===correct?'success':'error'}`}><strong>{selected===correct?'Bonne réponse':'À revoir'}</strong>{q.explanation&&<p>{q.explanation}</p>}{q.source_label&&<small>{q.source_label}</small>}</div>}
    </article>
   })}</div>}
   {checkedCount>0&&<p className="curriculum-score">Score actuel : <strong>{score}/{checkedCount}</strong></p>}
  </section>
 </div>
}
