import { useEffect,useMemo,useState } from 'react'
import { Link,useParams } from 'react-router-dom'
import { getTopic,getTopicLessons,getTopicQuiz,type CurriculumHotspot,type CurriculumLesson,type CurriculumQuizQuestion,type CurriculumQuizOption,type ProgramCatalogTopic } from '../services/programCatalogApi'

function normalizeAnswer(value:string){
 return value.trim().toLocaleLowerCase('fr-FR').normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/\s+/g,' ')
}

function acceptedAnswers(q:CurriculumQuizQuestion){
 const raw=q.accepted_answers
 if(Array.isArray(raw))return raw.map(String)
 const fallback=q.options.find((o:CurriculumQuizOption)=>o.correct)?.text
 return fallback?[fallback]:[]
}

function hotspots(q:CurriculumQuizQuestion):CurriculumHotspot[]{
 const meta=q.metadata
 if(!meta||typeof meta!=='object'||!('hotspots' in meta))return[]
 const raw=(meta as {hotspots?:unknown}).hotspots
 return Array.isArray(raw)?raw.filter((item):item is CurriculumHotspot=>Boolean(item&&typeof item==='object'&&'id' in item&&'x' in item&&'y' in item)):[]
}

function isCorrect(q:CurriculumQuizQuestion,answer:string){
 if(q.question_type==='fill_blank'){
  const normalized=normalizeAnswer(answer)
  return acceptedAnswers(q).some(candidate=>normalizeAnswer(candidate)===normalized)
 }
 if(q.question_type==='visual_hotspot'){
  return hotspots(q).some(point=>point.correct&&point.id===answer)
 }
 const correct=q.options.find((o:CurriculumQuizOption)=>o.correct)?.text
 return answer===correct
}

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

 const score=useMemo(()=>quiz.reduce((total,q)=>checked[q.id]&&isCorrect(q,answers[q.id]??'')?total+1:total,0),[quiz,answers,checked])
 const checkedCount=Object.keys(checked).filter(id=>checked[id]).length

 if(loading)return <div className="card"><p>Chargement de la fiche…</p></div>
 if(error||!topic)return <div className="card"><p>{error??'Chapitre introuvable.'}</p><Link className="primary-button" to="/parcours">Retour au parcours</Link></div>

 return <div className="stack curriculum-learning-page">
  <section className="card curriculum-learning-hero">
   <Link className="text-link" to="/parcours">← Retour au parcours</Link>
   <p className="eyebrow">Chapitre</p>
   <h1>{topic.name}</h1>
   {topic.description&&<p>{topic.description}</p>}
   <div className="curriculum-learning-actions"><a className="secondary-button" href="#fiche">📖 Lire la fiche</a><a className="primary-button" href="#qcm">✅ Révision active</a></div>
  </section>

  <section className="card" id="fiche">
   <div className="section-heading"><div><p className="eyebrow">Fiche de révision</p><h2>Comprendre et retenir l’essentiel</h2></div><span className="program-status live">{lessons.length} fiche{lessons.length>1?'s':''}</span></div>
   {lessons.length===0?<div className="admin-empty"><span>📚</span><div><strong>Fiche en attente de contenu.</strong><p>Le chapitre est identifié mais aucun support exploitable n’a encore été publié.</p></div></div>:lessons.map(lesson=><article className="curriculum-lesson" key={lesson.id}>
    <h3>{lesson.title}</h3>
    {lesson.summary&&<p className="curriculum-summary">{lesson.summary}</p>}
    <div className="curriculum-course-content">{lesson.content.split(/\n{2,}/).map((part,i)=><p key={i}>{part}</p>)}</div>
    {Array.isArray(lesson.key_points)&&lesson.key_points.length>0&&<div className="curriculum-key-points"><strong>À retenir</strong><ul>{(lesson.key_points as unknown[]).map((point,i)=><li key={i}>{String(point)}</li>)}</ul></div>}
   </article>)}
  </section>

  <section className="card" id="qcm">
   <div className="section-heading"><div><p className="eyebrow">Révision active</p><h2>Teste tes acquis</h2></div>{quiz.length>0&&<span className="program-status foundation">{checkedCount}/{quiz.length} répondu{quiz.length>1?'s':''}</span>}</div>
   {quiz.length===0?<div className="admin-empty"><span>❓</span><div><strong>Exercices en préparation.</strong><p>La fiche est consultable mais les exercices de ce chapitre ne sont pas encore publiés.</p></div></div>:<div className="curriculum-quiz-list">{quiz.map((q,index)=>{
    const selected=answers[q.id]??''
    const isChecked=!!checked[q.id]
    const correct=isCorrect(q,selected)
    const accepted=acceptedAnswers(q)
    const points=hotspots(q)
    return <article className="curriculum-quiz-card" key={q.id}>
     <strong>Question {index+1}</strong>
     <p>{q.question_text}</p>
     {q.image_url&&<div style={{position:'relative',maxWidth:720,margin:'12px auto'}}><img src={q.image_url} alt="Support anatomique" style={{display:'block',width:'100%',borderRadius:16}}/>{q.question_type==='visual_hotspot'&&points.map(point=><button key={point.id} type="button" aria-label={point.label??'Zone anatomique'} disabled={isChecked} onClick={()=>setAnswers(current=>({...current,[q.id]:point.id}))} style={{position:'absolute',left:`${point.x}%`,top:`${point.y}%`,transform:'translate(-50%,-50%)',width:34,height:34,borderRadius:'50%',border:selected===point.id?'4px solid currentColor':'2px solid currentColor',background:'rgba(255,255,255,.85)',cursor:isChecked?'default':'pointer'}}>{selected===point.id?'✓':''}</button>)}</div>}
     {q.question_type==='fill_blank'?<input className="text-input" type="text" value={selected} disabled={isChecked} placeholder="Écris ta réponse" onChange={event=>setAnswers(current=>({...current,[q.id]:event.target.value}))}/>:q.question_type!=='visual_hotspot'?<div className="curriculum-options">{q.options.map((option:CurriculumQuizOption)=><label className={`curriculum-option ${isChecked&&option.correct?'correct':''} ${isChecked&&selected===option.text&&!option.correct?'incorrect':''}`} key={option.text}><input type="radio" name={q.id} value={option.text} checked={selected===option.text} disabled={isChecked} onChange={()=>setAnswers(current=>({...current,[q.id]:option.text}))}/><span>{option.text}</span></label>)}</div>:null}
     <button className="primary-button" type="button" disabled={!selected||isChecked} onClick={()=>setChecked(current=>({...current,[q.id]:true}))}>Valider</button>
     {isChecked&&<div className={`curriculum-feedback ${correct?'success':'error'}`}><strong>{correct?'Bonne réponse':'À revoir'}</strong>{!correct&&q.question_type==='fill_blank'&&accepted.length>0&&<p>Réponse attendue : {accepted[0]}</p>}{q.explanation&&<p>{q.explanation}</p>}{q.source_label&&<small>{q.source_label}</small>}</div>}
    </article>
   })}</div>}
   {checkedCount>0&&<p className="curriculum-score">Score actuel : <strong>{score}/{checkedCount}</strong></p>}
  </section>
 </div>
}
